"""Download PM pilot Actions artifacts and independently verify them (SHA-256 discipline).

Derived from PR52 docs/build06/verify_delivery.py (see PROVENANCE.json). For each
package artifact: the Actions digest, outer/inner ZIP integrity, inner SHA-256 vs
the manifest, every member hash, every packed resource payload (MD5 in the PCK and
SHA-256 canonical hash) against the independently re-assembled pinned source, text
script equality with source bytes, ART-07 absence, and the QA artifact's pass state.
Needs `gh` auth and a local clone that contains every pinned commit.
"""
from pathlib import Path
import argparse, hashlib, importlib.util, io, json, shutil, subprocess, sys, tempfile, zipfile

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import pins as pinlib  # noqa: E402
REPO = 'cappy2yappy/momentum-fractured'
FORBIDDEN = ('assets/art07/', 'tools/art07/')


def api(path):
    return json.loads(subprocess.check_output(['gh', 'api', 'repos/' + REPO + '/' + path]))


def load_builder():
    spec = importlib.util.spec_from_file_location('pmpilot_build', HERE / 'build_package.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--run', help='Actions run id (online mode)')
    p.add_argument('--from-dir', type=Path, help='offline mode: directory of already downloaded artifact ZIPs (name = artifact name)')
    p.add_argument('--clone', type=Path, required=True, help='local clone containing every pinned commit')
    p.add_argument('--downloads', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--require-complete', action='store_true', help='fail unless manifests report complete_checks')
    a = p.parse_args()
    a.downloads.mkdir(parents=True, exist_ok=True)
    a.out.mkdir(parents=True, exist_ok=True)
    assert a.run or a.from_dir, 'give --run or --from-dir'
    if a.run:
        run = api('actions/runs/' + a.run)
        assert run['conclusion'] == 'success', 'run conclusion: %s' % run['conclusion']
        artifacts = api('actions/runs/' + a.run + '/artifacts?per_page=100')
        jobs = api('actions/runs/' + a.run + '/jobs?per_page=100')
        (a.out / 'RUN.json').write_text(json.dumps(run, indent=2) + '\n')
        (a.out / 'JOBS.json').write_text(json.dumps(jobs, indent=2) + '\n')
        (a.out / 'ARTIFACTS.json').write_text(json.dumps(artifacts, indent=2) + '\n')
    else:
        artifacts = {'artifacts': [{'id': i, 'name': z.stem, 'digest': 'sha256:' + hashlib.sha256(z.read_bytes()).hexdigest(), 'expired': False,
                                    'expires_at': 'offline', '_path': z} for i, z in enumerate(sorted(a.from_dir.glob('*.zip')))]}
    builder = load_builder()
    results = []
    for artifact in artifacts['artifacts']:
        assert not artifact['expired'], artifact['name'] + ' expired'
        if '_path' in artifact:
            target = artifact['_path']
        else:
            target = a.downloads / (str(artifact['id']) + '.zip')
            with target.open('wb') as stream:
                subprocess.run(['gh', 'api', 'repos/' + REPO + '/actions/artifacts/' + str(artifact['id']) + '/zip'], stdout=stream, check=True)
        sha = hashlib.sha256(target.read_bytes()).hexdigest()
        assert 'sha256:' + sha == artifact['digest'], 'Actions digest mismatch for ' + artifact['name']
        with zipfile.ZipFile(target) as outer:
            assert outer.testzip() is None
            names = outer.namelist()
            if '-QA-' in artifact['name']:
                qa = [n for n in names if n.endswith('QA_RESULTS.json')]
                if qa:
                    assert all(c['passed'] for c in json.loads(outer.read(qa[0]))['checks']), 'failing QA check in ' + artifact['name']
                results.append({'artifact': artifact['name'], 'id': artifact['id'], 'outer_sha256': sha, 'crc': 'pass', 'type': 'QA evidence'})
                continue
            manifest = json.loads(outer.read(next(n for n in names if n.endswith('MANIFEST.json'))))
            if a.require_complete:
                assert manifest['complete_checks'], 'manifest says checks were incomplete'
            inner = outer.read(next(n for n in names if n.endswith(manifest['archive'])))
            assert hashlib.sha256(inner).hexdigest() == manifest['archive_sha256']
            distribution = a.downloads / manifest['archive']
            distribution.write_bytes(inner)
            # Re-assemble the exact pinned source from the pins at the controls commit.
            pins_text = subprocess.check_output(['git', '-C', str(a.clone), 'show', manifest['controls_commit'] + ':tools/pmpilot/pins.json'])
            pins_file = a.downloads / ('pins-' + manifest['controls_commit'][:8] + '.json')
            pins_file.write_bytes(pins_text)
            pins = json.loads(pins_text)
            tmp = Path(tempfile.mkdtemp(prefix='pmpilot-src-', dir=a.downloads))
            shutil.rmtree(tmp)
            subprocess.run(['git', '-C', str(a.clone), 'worktree', 'add', '--detach', str(tmp), manifest['controls_commit']], check=True, capture_output=True)
            try:
                record = pinlib.assemble(pins, manifest['variant'], tmp)
                assert record['head'] == manifest['source_head'] or record['tree'] == manifest['source_tree'], 'source mismatch'
                assert record['tree'] == manifest['source_tree']
                with zipfile.ZipFile(io.BytesIO(inner)) as z:
                    assert z.testzip() is None
                    assert set(z.namelist()) == set(manifest['members'])
                    for name, digest in manifest['members'].items():
                        assert hashlib.sha256(z.read(name)).hexdigest() == digest, name
                    assert not [n for n in z.namelist() if n.startswith(FORBIDDEN)], 'ART-07 path in package'
                    pack = next(n for n in z.namelist() if n.endswith('.pck') or n.endswith('.exe'))
                    records, scripts = builder.pack_records(z.read(pack), tmp)
                    assert len(records) == manifest['pck_entries']
                    assert builder.digest(json.dumps(records, sort_keys=True).encode()) == manifest['reproducibility']['canonical_resource_sha256']
                    assert len(scripts) == manifest['reproducibility']['source_text_scripts_verified']
                    assert not [n for n in records if n.startswith(FORBIDDEN)], 'ART-07 resource in pack'
                    for prefix in pins['variants'][manifest['variant']].get('forbidden_pack_prefixes', []):
                        assert not [n for n in records if n.startswith(prefix)], 'forbidden resource ' + prefix
                    assert manifest['reproducibility']['resource_payloads_identical']
            finally:
                subprocess.run(['git', '-C', str(a.clone), 'worktree', 'remove', '--force', str(tmp)], capture_output=True)
            (a.out / (artifact['name'] + '-MANIFEST.json')).write_text(json.dumps(manifest, indent=2) + '\n')
            results.append({'artifact': artifact['name'], 'id': artifact['id'], 'purpose': manifest['purpose'], 'variant': manifest['variant'],
                            'outer_sha256': sha, 'inner_sha256': manifest['archive_sha256'], 'crc': 'pass',
                            'members_verified': len(manifest['members']), 'resource_payloads_verified': len(records),
                            'exact_source_scripts_verified': len(scripts), 'expires_at': artifact['expires_at'],
                            'complete_checks': manifest['complete_checks']})
    (a.out / 'DOWNLOAD_VERIFICATION.json').write_text(json.dumps(results, indent=2) + '\n')
    print(json.dumps(results, indent=2))


if __name__ == '__main__':
    main()
