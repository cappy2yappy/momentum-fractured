"""BUILD-07 targeted rebuild: re-pin variants to SHAs supplied by the coordinator, then validate locally. DRY RUN unless --write.
Nothing here starts a hosted run; the request is written to request.json only with --write-request (that push is the run).

  python tools/pmpilot/w3_repin.py --repo . --transition <sha> --art <sha> --combined <sha> [--combined-tree <tree>]
        [--level <sha>] [--control <sha>] --request-variants w3-combined --request-platforms windows [--write] [--write-request]

For art and combined it switches the .gdignore handling from the legacy build-time overlay (build_gdignore) to
require_gdignore (the pinned source must track source_art/art08/.gdignore). SHAs are never guessed: every one must be
given on the command line and must resolve to a commit.
"""
from pathlib import Path
import argparse, json, re, subprocess, sys
HERE = Path(__file__).resolve().parent
SHA = re.compile(r'[0-9a-f]{40}')


def git(repo, *a):
    r = subprocess.run(['git', '-c', 'safe.directory=*', '-C', str(repo), *a], capture_output=True)
    return r.returncode, r.stdout.decode(errors='replace').strip(), r.stderr.decode(errors='replace').strip()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--repo', type=Path, required=True)
    for k in ('control', 'transition', 'level', 'art', 'combined', 'targeted'):
        ap.add_argument('--' + k)
    ap.add_argument('--combined-tree')
    ap.add_argument('--request-variants', default='w3-combined')
    ap.add_argument('--request-platforms', default='windows', choices=['windows', 'macos', 'both'])
    ap.add_argument('--apple-silicon', action='store_true')
    ap.add_argument('--write', action='store_true')
    ap.add_argument('--write-request', action='store_true')
    a = ap.parse_args()
    pins_path = HERE / 'pins.json'
    pins = json.loads(pins_path.read_text(encoding='utf-8'))
    V = pins['variants']
    change = {}
    for key, name in (('control', 'w3-control'), ('transition', 'w3-transition'), ('level', 'w3-level'), ('art', 'w3-art'), ('combined', 'w3-combined'), ('targeted', 'w3-targeted')):
        sha = getattr(a, key)
        if not sha:
            continue
        assert SHA.fullmatch(sha), '%s is not a 40-hex SHA' % key
        rc, _, _ = git(a.repo, 'cat-file', '-e', sha + '^{commit}')
        if rc:
            rc, _, err = git(a.repo, 'fetch', '--depth=1', 'origin', sha)
            assert rc == 0, 'cannot fetch %s: %s' % (sha, err)
        _, tree, _ = git(a.repo, 'rev-parse', sha + '^{tree}')
        V[name]['commit'] = sha
        change[name] = dict(commit=sha, tree=tree)
        if name in ('w3-combined', 'w3-targeted'):
            if a.combined_tree:
                assert a.combined_tree == tree, 'supplied combined tree %s != actual %s' % (a.combined_tree, tree)
            V[name]['expected_tree'] = tree
        if name in ('w3-art', 'w3-combined', 'w3-targeted') and 'build_gdignore' in V[name]:
            V[name]['require_gdignore'] = V[name].pop('build_gdignore')
        V[name].pop('native_input_informational', None)
    print(json.dumps(change, indent=2))
    if a.write:
        pins_path.write_text(json.dumps(pins, indent=2) + '\n', encoding='utf-8')
        print('pins.json updated')
    names = ','.join(sorted(change)) if change else a.request_variants
    cmd = [sys.executable, str(HERE / 'w3_prep_check.py'), '--repo', str(a.repo), '--variants', names] + ([] if a.write else ['--pins', str(pins_path)])
    if not a.write:
        tmp = HERE / '.pins.dryrun.json'
        tmp.write_text(json.dumps(pins, indent=2), encoding='utf-8')
        cmd = [sys.executable, str(HERE / 'w3_prep_check.py'), '--repo', str(a.repo), '--variants', names, '--pins', str(tmp)]
    rc = subprocess.run(cmd).returncode
    if not a.write and (HERE / '.pins.dryrun.json').exists():
        (HERE / '.pins.dryrun.json').unlink()
    if a.write_request and rc == 0:
        req = dict(variants=a.request_variants, purpose='comparison', platforms=a.request_platforms, apple_silicon=bool(a.apple_silicon), quick=False)
        (HERE / 'request.json').write_text(json.dumps(req, indent=2) + '\n', encoding='utf-8')
        print('request.json written (committing and pushing it STARTS the run):', req)
    raise SystemExit(rc)


if __name__ == '__main__':
    main()
