"""PM pilot comparison package builder: pinned source, native export, strict checks.

Derived from PR52 tools/build06/candidate.py (see PROVENANCE.json). The export
override, pack/resource comparison, archive layout, extraction-with-spaces test
and launcher idioms are kept; what is new is that the source variant, regression
set, demo launchers and policy checks come from pins.json / demos.json, and that
candidate preservation is an allowlist diff against the candidate's base rather
than a PR37-exact comparison. No gameplay edits; nothing is committed or released.

Hosts: windows / macos (hosted or real) run every step. A linux host can only
cross-export the Windows x86_64 package (--local-smoke) and cannot execute the
Windows launchers, release binary or macOS bundle; those steps are recorded as
not executed, never as passed.
"""
from pathlib import Path
import argparse, datetime, fnmatch, hashlib, importlib.util, json, os, platform, re, shutil, stat, struct, subprocess, sys, time, zipfile

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import pins as pinlib  # noqa: E402

VERSION = '4.6.1.stable.official.14d19694e'
SAVE_NAME = 'silent_district_alpha_v3.json'  # ordinary save identity (scripts/world.gd)
FORBIDDEN_ALWAYS = ('assets/art07/', 'tools/art07/')


def digest(data):
    return hashlib.sha256(data).hexdigest()


def git(root, *args):
    return subprocess.check_output(['git', '-c', 'safe.directory=*', '-C', str(root), *args])


def snapshot(root):
    return {n: digest((root / n).read_bytes()) for n in git(root, 'ls-files').decode().splitlines() if (root / n).is_file()}


def pack_bytes(path):
    data = path.read_bytes()
    if data[:4] == b'GDPC':
        return data
    assert data[:2] == b'MZ' and data[-4:] == b'GDPC'
    start = len(data) - 12 - struct.unpack_from('<Q', data, len(data) - 12)[0]
    return data[start:-12]


def pack_records(data, source):
    """Compare payloads independently of pack offsets/order and prove text scripts."""
    start = 0
    if data[:4] != b'GDPC':
        assert data[:2] == b'MZ' and data[-4:] == b'GDPC'
        start = len(data) - 12 - struct.unpack_from('<Q', data, len(data) - 12)[0]
    version, major, minor, patch, flags = struct.unpack_from('<5I', data, start + 4)
    assert version in (2, 3) and (major, minor, patch) == (4, 6, 1) and not flags & 1
    base = struct.unpack_from('<Q', data, start + 24)[0]
    if version == 3 or flags & 2:
        base += start
    pos = start + 96 if version == 2 else start + struct.unpack_from('<Q', data, start + 32)[0]
    count = struct.unpack_from('<I', data, pos)[0]
    pos += 4
    records = {}
    scripts = {}
    for _ in range(count):
        length = struct.unpack_from('<I', data, pos)[0]
        pos += 4
        name = data[pos:pos + length].rstrip(b'\0').decode().removeprefix('res://')
        pos += length
        offset, size = struct.unpack_from('<QQ', data, pos)
        pos += 16
        md5 = data[pos:pos + 16]
        pos += 16
        file_flags = struct.unpack_from('<I', data, pos)[0]
        pos += 4
        assert file_flags == 0 and name not in records
        payload = data[base + offset:base + offset + size]
        assert len(payload) == size and hashlib.md5(payload).digest() == md5, name
        records[name] = digest(payload)
        if name.endswith('.gd'):
            assert (source / name).resolve().is_relative_to(source.resolve())
            assert payload == (source / name).read_bytes(), 'Exported script differs from source: ' + name
            scripts[name] = records[name]
    assert scripts and 'scripts/player.gd' in scripts
    return records, scripts


def seed_for(spec, version):
    room, at = spec['room'], spec['position']
    seed = dict(version=version, checkpoint_room=room, checkpoint_position=at, double_jump=True, tether_unlocked=True,
                dash_unlocked=True, completed=True, guard_defeated=True, boss_defeated=True, speed_upgrade_level=0,
                kunai_unlocked=dict(wind=True, fire=True, electric=True),
                opened_kunai_gates=dict(skyworks_wind_intake=True, cistern_wind_cache=True, spire_wind_shutter=True),
                relay_fragments=dict(undercroft_sigil=True, terrace_west=True, terrace_fire_cache=True),
                expansion_flags=dict(junction_return=True), visited=[i == room for i in range(21)])
    seed.update(spec.get('overrides', {}))
    return seed


def launcher_text(host, exe_name, variant, demo, seeded):
    flags = ' '.join(demo.get('flags', []))
    profile_name = variant + '-' + demo['name'] + '.json'
    if host == 'windows':
        seed = 'copy /y "fixtures\\%s.json" "profiles\\%s" >nul\r\n' % (demo['name'], profile_name) if seeded else ''
        return ('@echo off\r\ncd /d "%~dp0"\r\nif not exist "profiles" mkdir "profiles"\r\n' + seed +
                '"%~dp0' + exe_name + '" %* -- ' + flags + ' "--tr05-save=%~dp0profiles\\' + profile_name + '"\r\nexit /b %errorlevel%\r\n')
    seed = 'cp "$HERE/fixtures/%s.json" "$HERE/profiles/%s"\n' % (demo['name'], profile_name) if seeded else ''
    return ('#!/bin/bash\nset -euo pipefail\nHERE="$(cd "$(dirname "$0")" && pwd)"\nmkdir -p "$HERE/profiles"\n' + seed +
            'exec "$HERE/' + exe_name + '/Contents/MacOS/EXECUTABLE" "$@" -- ' + flags + ' "--tr05-save=$HERE/profiles/' + profile_name + '"\n')


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--godot', required=True)
    p.add_argument('--variant', required=True)
    p.add_argument('--purpose', choices=['preparation-smoke', 'comparison'], default='preparation-smoke')
    p.add_argument('--pins')
    p.add_argument('--target', choices=['windows', 'macos'])
    p.add_argument('--graphical', action='store_true')
    p.add_argument('--local-smoke', action='store_true', help='linux host: cross-export Windows only, skip native execution steps')
    p.add_argument('--quick', action='store_true', help='skip the long source regression suites (marks the manifest incomplete)')
    a = p.parse_args()

    pins = pinlib.load(a.pins)
    problems = pinlib.validate(pins, [a.variant], a.purpose)
    assert not problems, problems
    spec = pins['variants'][a.variant]
    demos_doc = json.loads((HERE / 'demos.json').read_text(encoding='utf-8'))
    demos = demos_doc['default'] if spec.get('demos', 'default') == 'default' else spec['demos']
    root = Path(os.environ['PMPILOT_SOURCE_ROOT']).resolve()
    sysname = platform.system()
    host = {'Windows': 'windows', 'Darwin': 'macos', 'Linux': 'linux'}[sysname]
    target = a.target or ('windows' if host == 'linux' else host)
    if host == 'linux':
        assert a.local_smoke and target == 'windows', 'linux host supports only --local-smoke with the windows target'
    else:
        assert target == host, 'native execution requires target == host'
    native = host != 'linux'
    name = 'Kaze-PMPILOT-' + a.variant

    head = git(root, 'rev-parse', 'HEAD').decode().strip()
    tree = git(root, 'rev-parse', 'HEAD^{tree}').decode().strip()
    commit, members, _ = pinlib.resolve(pins, a.variant)
    if commit:
        assert head == commit, 'Source HEAD %s is not the pinned commit %s' % (head, commit)
    else:
        cbase = spec['compose']['base']
        for _m, mcommit in members:
            subprocess.run(['git', '-c', 'safe.directory=*', '-C', str(root), 'merge-base', '--is-ancestor', mcommit, 'HEAD'], check=True)
        subprocess.run(['git', '-c', 'safe.directory=*', '-C', str(root), 'merge-base', '--is-ancestor', cbase, 'HEAD'], check=True)
        first_parent = int(git(root, 'rev-list', '--first-parent', '--count', cbase + '..HEAD').decode())
        assert first_parent == len(members), 'Composed source does not have the pinned merge shape'
    if spec.get('expected_tree'):
        assert tree == spec['expected_tree']
    assert not git(root, 'status', '--porcelain', '--untracked-files=no').strip(), 'Source must start clean'
    assert subprocess.check_output([a.godot, '--version'], text=True).strip() == VERSION
    before = snapshot(root)
    out = root / 'build/pmpilot' / a.variant
    if out.exists():
        shutil.rmtree(out)
    evidence = out / 'evidence'
    evidence.mkdir(parents=True)
    rows = []
    notes = []  # steps deliberately not executed on this host

    def profile(label):
        home = out / 'profiles' / label
        home.mkdir(parents=True, exist_ok=True)
        env = os.environ.copy()
        env.update(HOME=str(home), APPDATA=str(home), LOCALAPPDATA=str(home), XDG_DATA_HOME=str(home / 'xdg'), PYTHONIOENCODING='utf-8')
        return env

    def run(label, cmd, env=None, timeout=180, expected=None, regex=None, gate=True):
        start = time.monotonic()
        env = env or profile(label)
        try:
            r = subprocess.run(list(map(str, cmd)), cwd=root, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=timeout)
            text = r.stdout.decode('utf-8', errors='replace')
            rc = r.returncode
        except subprocess.TimeoutExpired as e:
            text = (e.stdout or b'').decode('utf-8', errors='replace') + '\nERROR: timeout\n'
            rc = 124
        raw = text.encode('utf-8')
        (evidence / (label + '.log')).write_bytes(raw)
        errors = [line for line in text.splitlines() if re.search(r'SCRIPT ERROR|Parse Error|Failed to load|FAIL:|Could not open|^ERROR:', line)]
        inherited = [x for x in errors if any(t in x for t in ['ret != noErr', 'RID allocations', 'RID of type', 'resources still in use', 'Pages in use exist at exit'])]
        errors = [x for x in errors if x not in inherited]
        row = dict(test=label, command=list(map(str, cmd)), exit=rc, seconds=round(time.monotonic() - start, 3),
                   passes=len(re.findall(r'^PASS:', text, re.M)), errors=errors, inherited_diagnostics=inherited,
                   log_sha256=digest(raw), expected=expected or regex)
        ok = rc == 0 and not errors
        if expected is not None:
            ok = ok and expected in text
        if regex is not None:
            ok = ok and re.search(regex, text) is not None
        row['passed'] = ok
        rows.append(row)
        save_results()
        print(label, 'PASS' if ok else 'FAIL', row['passes'], flush=True)
        if gate:
            assert ok, text[-5000:]
        return text, row

    def save_results():
        (out / 'QA_RESULTS.json').write_text(json.dumps(dict(
            variant=a.variant, source_head=head, source_tree=tree, host=platform.platform(), architecture=platform.machine(),
            mode='graphical automated fixture' if a.graphical else 'native headless automated' if native else 'linux cross-export smoke (no native execution)',
            not_executed=notes, checks=rows), indent=2) + '\n', encoding='utf-8')

    # 1. Source policy: diff allowlist + ART-07 exclusion in the source itself.
    diff = pinlib.diff_check(pins, a.variant, root)
    (evidence / 'PRESERVATION_DIFF.json').write_text(json.dumps(diff, indent=2) + '\n')
    assert not diff['violations'], diff['violations']
    art07 = [n for n in git(root, 'ls-files').decode().splitlines() if n.startswith(FORBIDDEN_ALWAYS)]
    assert not art07, 'ART-07 files present in source: %s' % art07[:5]

    base = [a.godot, '--headless', '--path', root]
    # The cold import must be clean on native hosts (BUILD-06 discipline). On the linux smoke host the
    # MetSys editor scripts fail to resolve before the UID cache exists; that is recorded, not gated.
    _, warm = run('import-warmup', base + ['--editor', '--import', '--quit'], timeout=300, gate=native)
    if not warm['passed']:
        notes.append('linux smoke: cold import reported %d script/UID errors before the cache existed; settled import is gated' % len(warm['errors']))
    run('import-settled', base + ['--editor', '--import', '--quit'], timeout=300)

    reg = spec['regression']
    waivers = spec.get('preservation_waivers', [])

    def preservation(label, script):
        text, row = run(label, [sys.executable, root / 'tools' / script], gate=reg['baseline_verifiers'])
        if not reg['baseline_verifiers']:
            bad = [l for l in text.splitlines() if re.search(r'^FAIL|differs|changed|Missing', l)]
            unexplained = [l for l in bad if not any(w in l for w in waivers)]
            row['waived'] = [l for l in bad if l not in unexplained]
            row['unexplained'] = unexplained
            row['passed'] = row['exit'] == 0 or not unexplained
            save_results()
            assert row['passed'], 'Unexplained preservation failures: %s' % unexplained[:10]

    preservation('baseline', 'verify_baseline.py')
    preservation('preservation', 'verify_tr05_preservation.py')

    suites = None
    if a.quick:
        notes.append('source regression suites skipped by --quick (package is NOT a complete candidate)')
    else:
        run('source-regressions', [sys.executable, root / 'tools/run_tr05_qa.py', '--godot', a.godot], timeout=1800)
        suites = json.loads((root / 'build/tr05/qa/results.json').read_text())
        tr05 = reg.get('tr05') or {}
        if tr05.get('suites') is not None:
            assert len(suites) == tr05['suites'], 'Suite count %d != pinned %s' % (len(suites), tr05['suites'])
        if tr05.get('assertions') is not None:
            assert sum(x['passes'] for x in suites) == tr05['assertions']
        assert all(x['passes'] > 0 and not (x['exit'] or x['failures'] or x['script_errors']) for x in suites)
        if reg.get('tr06') is not None and (root / 'tools/run_tr06_qa.py').is_file():
            run('tr06-automatic-passage', [sys.executable, root / 'tools/run_tr06_qa.py', '--godot', a.godot, '--label', 'pmpilot'], timeout=600)
            tr06 = json.loads((root / 'build/tr06/pmpilot.json').read_text())
            if reg['tr06'].get('passes') is not None:
                assert tr06['passes'] == reg['tr06']['passes'], tr06
        for extra in reg.get('extra', []):
            argv = [x.format(godot=a.godot, root=root, python=sys.executable) for x in extra['argv']]
            run('extra-' + extra['name'], argv, timeout=extra.get('timeout', 900), regex=extra.get('pass_regex'))

    # 2. Exports (text script mode, restored byte for byte).
    export_env = profile('export')
    templates = Path(os.environ['PMPILOT_TEMPLATES'])
    if host == 'windows':
        template_dest = Path(export_env['APPDATA']) / 'Godot'
    elif host == 'macos':
        template_dest = Path(export_env['HOME']) / 'Library/Application Support/Godot'
    else:
        template_dest = Path(export_env['XDG_DATA_HOME']) / 'godot'
    shutil.copytree(templates, template_dest / 'export_templates/4.6.1.stable', dirs_exist_ok=True)
    preset = 'Windows Desktop' if target == 'windows' else 'macOS'
    raw = out / ('raw.exe' if target == 'windows' else 'raw.zip')
    repeat = out / ('repeat.exe' if target == 'windows' else 'repeat.zip')
    presets = root / 'export_presets.cfg'
    original_presets = presets.read_bytes()
    assert b'script_export_mode=' not in original_presets
    export_presets = re.sub(rb'(\[preset\.\d+\]\r?\n)', rb'\1script_export_mode=0\n', original_presets)
    assert export_presets != original_presets
    overrides = ['script_export_mode=0 (text)']
    if host == 'linux':
        # rcedit needs wine; icon/version resources are not needed for the pack smoke test.
        export_presets = export_presets.replace(b'application/modify_resources=true', b'application/modify_resources=false')
        overrides.append('application/modify_resources=false (linux smoke only)')
    (evidence / 'EXPORT_PRESETS_OVERRIDE.cfg').write_bytes(export_presets)
    try:
        presets.write_bytes(export_presets)
        run('export', base + ['--export-release', preset, raw], export_env, 300)
        run('export-repeat', base + ['--export-release', preset, repeat], export_env, 300)
    finally:
        presets.write_bytes(original_presets)

    stage = out / 'staging'
    stage.mkdir()
    exe_name = name + ('.exe' if target == 'windows' else '.app')
    if target == 'windows':
        binary = stage / exe_name
        shutil.copy2(raw, binary)
        packed = binary
        repeat_pack = pack_bytes(repeat)
        architectures = ['x86_64']
    else:
        subprocess.run(['ditto', '-x', '-k', str(raw), str(stage)], check=True)
        app = next(stage.glob('*.app'))
        app.rename(stage / exe_name)
        app = stage / exe_name
        binary = next((app / 'Contents/MacOS').iterdir())
        packed = next(app.rglob('*.pck'))
        repeat_dir = out / 'repeat-app'
        repeat_dir.mkdir()
        subprocess.run(['ditto', '-x', '-k', str(repeat), str(repeat_dir)], check=True)
        repeat_pack = next(repeat_dir.rglob('*.pck')).read_bytes()
        architectures = subprocess.check_output(['lipo', '-archs', str(binary)], text=True).split()
        assert set(architectures) == {'x86_64', 'arm64'}
    first_pack = pack_bytes(packed)
    records_a, scripts = pack_records(packed.read_bytes(), root)
    records_b, _ = pack_records(repeat.read_bytes() if target == 'windows' else repeat_pack, root)
    differences = [n for n in sorted(records_a.keys() | records_b.keys()) if records_a.get(n) != records_b.get(n)]
    reproducibility = {'export_a_sha256': digest(raw.read_bytes()), 'export_b_sha256': digest(repeat.read_bytes()),
                       'export_bytes_identical': raw.read_bytes() == repeat.read_bytes(), 'pck_a_sha256': digest(first_pack),
                       'pck_b_sha256': digest(repeat_pack), 'pck_bytes_identical': first_pack == repeat_pack,
                       'resource_payloads_identical': not differences, 'resource_differences': differences,
                       'canonical_resource_sha256': digest(json.dumps(records_a, sort_keys=True).encode()),
                       'source_text_scripts_verified': len(scripts)}
    (evidence / 'REPRODUCIBILITY.json').write_text(json.dumps(reproducibility, indent=2) + '\n')
    (evidence / 'RESOURCE_SHA256.json').write_text(json.dumps(records_a, sort_keys=True, indent=2) + '\n')
    assert not differences, 'Repeated export changed resource payloads: ' + str(differences)
    control_hash = (spec.get('control_canonical_resource_sha256') or {}).get(target)
    control_equal = None
    if control_hash:
        control_equal = control_hash == reproducibility['canonical_resource_sha256']
        reproducibility['control_canonical_resource_sha256'] = control_hash
        reproducibility['equals_build06_control'] = control_equal
        (evidence / 'REPRODUCIBILITY.json').write_text(json.dumps(reproducibility, indent=2) + '\n')
        print('BUILD-06 control resource equality (%s): %s' % (target, control_equal), flush=True)
        if native:
            assert control_equal, 'Canonical resource hash differs from the BUILD-06 control for the same pinned source'
        else:
            notes.append('BUILD-06 control resource equality recorded (%s) but not gated on a linux cross-export' % control_equal)

    # 3. Pack audit and package policy (ART-07 exclusion, required/forbidden prefixes, changed assets present).
    os.environ['BUILD05_SOURCE_ROOT'] = str(root)
    loader = importlib.util.spec_from_file_location('pmpilot_pack_audit', HERE / 'audit_pack.py')
    audit = importlib.util.module_from_spec(loader)
    loader.loader.exec_module(audit)
    pack_audit = audit.audit_pack(packed.read_bytes())
    assert 'scripts/cinematic_transitions.gd' in pack_audit['entries']
    forbidden = tuple(sorted(set(spec.get('forbidden_pack_prefixes', [])) | set(FORBIDDEN_ALWAYS)))
    bad = [n for n in pack_audit['entries'] if n.startswith(forbidden)]
    assert not bad, 'Forbidden pack entries: %s' % bad[:5]
    required = spec.get('required_pack_entries', [])
    missing = [n for n in required if not any(fnmatch.fnmatchcase(r, n) for r in records_a)]  # entries may be globs
    assert not missing, 'Required pack entries missing: %s' % missing
    absent = []
    for _status, path in diff['changed']:
        if _status == 'D' or not path.startswith(('assets/', 'world/', 'scripts/', 'scenes/')):
            continue
        if not any(c in records_a for c in (path, path + '.import', path + '.remap')):
            absent.append(path)
    # Allowlisted source changes that never reach the pack are reported; assets are gated.
    asset_absent = [n for n in absent if n.startswith(('assets/', 'world/'))]
    assert not asset_absent, 'Changed assets missing from the exported pack: %s' % asset_absent
    policy = {'forbidden_prefixes': list(forbidden), 'forbidden_found': [], 'required_entries': required,
              'changed_not_in_pack': absent, 'art07_in_source': [], 'art07_in_package': []}
    (evidence / 'PACK_AUDIT.json').write_text(json.dumps(pack_audit, indent=2) + '\n')
    (evidence / 'PACKAGE_POLICY.json').write_text(json.dumps(policy, indent=2) + '\n')

    # 4. Fixtures and launchers.
    fixtures = stage / 'fixtures'
    fixtures.mkdir()
    launcher_names = []
    for demo in demos:
        seeded = demo.get('seed') is not None
        if seeded:
            (fixtures / (demo['name'] + '.json')).write_text(json.dumps(seed_for(demo['seed'], demos_doc['save_version'])) + '\n')
        text = launcher_text(target, exe_name, a.variant, demo, seeded)
        if target == 'windows':
            (stage / ('Play-' + demo['name'] + '.cmd')).write_bytes(text.encode())
        else:
            launcher = stage / ('Play-' + demo['name'] + '.command')
            launcher.write_bytes(text.replace('EXECUTABLE', binary.name).encode())
            launcher.chmod(0o755)
        launcher_names.append('Play-' + demo['name'])
    provisional = [d['name'] for d in demos if d.get('status') == 'provisional']
    (stage / 'README.txt').write_text(
        'KAZE PM PILOT / ' + a.variant.upper() + ' / INTERNAL PLAYTEST / NO PRODUCTION RELEASE\n'
        'Purpose: ' + a.purpose + '\nVariant: ' + spec['label'] + '\nSource head: ' + head + '\nSource tree: ' + tree + '\n\n'
        'Extract fully into a writable folder (spaces in the path are fine). Use the Play-*.' + ('cmd' if target == 'windows' else 'command') +
        ' launchers.\nEvery launcher writes only to profiles/' + a.variant + '-<Name>.json inside this folder.\n'
        'Play-Fresh keeps one persistent unseeded campaign. Demo launchers reset only their own seeded profile on each launch.\n'
        'Seeded unlocks are fixtures, not earned progression. Direct EXE/app launch uses the historical ordinary save\n'
        'identity (user://' + SAVE_NAME + '); do not use it for comparison.\n\n'
        'Launchers: ' + ', '.join(launcher_names) + '\n' +
        ('PROVISIONAL launcher arguments: ' + ', '.join(provisional) + '\n' if provisional else '') +
        '\nA/D move, double-tap run, Space jump, E meaningful interactions, Q tether, Shift dash, J attack, F parry,\n'
        'R kunai, T element, M map, I kit, Escape pause, F6 reduced motion.\n'
        'Unsigned/unnotarized. Scripted checks do not certify a human campaign, gamepad, or sustained FPS.\n'
        'See docs/pm_pilot/build/README.md in the repository for the tester checklist and coverage limits.\n', encoding='utf-8')
    archive = out / (name + '-' + target + '-' + head[:8] + '.zip')
    with zipfile.ZipFile(archive, 'w', zipfile.ZIP_DEFLATED, compresslevel=9) as z:
        for f in sorted(stage.rglob('*')):
            if not f.is_file():
                continue
            info = zipfile.ZipInfo(f.relative_to(stage).as_posix(), (2026, 1, 1, 0, 0, 0))
            info.compress_type = zipfile.ZIP_DEFLATED
            info.create_system = 3
            info.external_attr = ((stat.S_IFREG | (0o755 if os.access(f, os.X_OK) else 0o644)) << 16)
            z.writestr(info, f.read_bytes())
    extracted = out / 'Downloaded Candidate With Spaces'
    extracted.mkdir()
    with zipfile.ZipFile(archive) as z:
        assert z.testzip() is None
        for entry in z.infolist():
            assert (extracted / entry.filename).resolve().is_relative_to(extracted.resolve())
            z.extract(entry, extracted)
            if target == 'macos':
                (extracted / entry.filename).chmod(entry.external_attr >> 16 & 0o777)
        members_hash = {i.filename: digest(z.read(i)) for i in z.infolist()}
    package_bad = [n for n in members_hash if n.startswith(FORBIDDEN_ALWAYS) or '/art07/' in n]
    assert not package_bad, package_bad
    if target == 'windows':
        release = extracted / exe_name
        export_pack = release
    else:
        release = next((extracted / exe_name / 'Contents/MacOS').iterdir())
        export_pack = next(extracted.rglob('*.pck'))

    # 5. Native execution (hosted/real hosts only).
    launcher_checks = []
    if native:
        fresh = str(out / 'release-fresh.json')
        run('native-release-startup', [release, '--headless', '--fixed-fps', '60', '--quit-after', '120', '--', '--tr05-save=' + fresh],
            profile('release'), 90, 'Godot Engine v4.6.1')
        for launcher in sorted(extracted.glob('Play-*')):
            env = profile('launcher-' + launcher.stem)
            cmd = ([os.environ.get('COMSPEC', 'cmd.exe'), '/d', '/c', str(launcher)] if target == 'windows' else [launcher])
            run('launcher-' + launcher.stem, cmd + ['--headless', '--fixed-fps', '60', '--quit-after', '120'], env, 90, 'Godot Engine v4.6.1')
            ordinary = [str(x) for x in Path(env['HOME']).rglob(SAVE_NAME)]
            demo = launcher.stem.removeprefix('Play-')
            profile_file = extracted / 'profiles' / (a.variant + '-' + demo + '.json')
            seeded = (extracted / 'fixtures' / (demo + '.json')).is_file()
            ok_profile = True
            if seeded:
                try:
                    ok_profile = 'checkpoint_room' in json.loads(profile_file.read_text(encoding='utf-8'))
                except Exception:
                    ok_profile = False
            row = dict(launcher=launcher.name, ordinary_save_files=ordinary, seeded_profile_present=ok_profile if seeded else None,
                       isolated=not ordinary and ok_profile)
            launcher_checks.append(row)
            assert row['isolated'], row
        (evidence / 'LAUNCHER_ISOLATION.json').write_text(json.dumps(launcher_checks, indent=2) + '\n')
    else:
        notes.append('native release startup and actual launcher runs: not executed (linux host cannot run the Windows binary or .cmd launchers)')

    # 6. Exported-resource suites (the exported pack is mounted into the editor binary; works on any host).
    env = profile('packaged')
    env.update(BUILD06_PACK=str(export_pack), BUILD06_CAPTURE_DIR=str(evidence / 'native-captures'), BUILD06_GRAPHICAL='1' if a.graphical else '0')
    run('native-exported-input', [a.godot] + ([] if a.graphical else ['--headless']) + ['--path', root, '--fixed-fps', '60', '--script', HERE / 'packaged_native.gd', '--', '--test'],
        env, 300, regex=reg['packaged_native_regex'])
    for suite in ['intentional_space', 'audit_intentional_space', 'movement_momentum', 'save_compatibility', 'expansion_gates_save', 'skyworks_progression']:
        method = '_run' if suite in ['movement_momentum', 'save_compatibility', 'skyworks_progression'] else 'run'
        wrapper = out / ('packaged-' + suite + '.gd')
        init = ('func _init():\n\tif not ProjectSettings.load_resource_pack(OS.get_environment("BUILD06_PACK"),true):\n'
                '\t\tpush_error("PMPILOT pack mount failed");quit(1);return\n\tcall_deferred("' + method + '")\n')
        text = 'extends "res://tests/' + suite + '.gd"\n' + init
        if suite == 'audit_intentional_space':
            text = (root / 'tests/audit_intentional_space.gd').read_text().replace('func _init(): call_deferred("run")', init.rstrip()).replace(
                '"res://build/ld03"', json.dumps(str(evidence / 'packaged-room-audit')))
        wrapper.write_text(text, encoding='utf-8')
        run('exported-' + suite, base + ['--fixed-fps', '60', '--script', wrapper, '--', '--test'], env, 120)
        assert rows[-1]['passes'] > 0

    # 7. Source preservation and manifest.
    after = snapshot(root)
    changes = [n for n in before if before[n] != after.get(n)]
    (evidence / 'SOURCE_PRESERVATION.json').write_text(json.dumps(dict(source=head, tracked_files=len(before), changes=changes), indent=2) + '\n')
    assert not changes, changes
    controls = git(HERE, 'rev-parse', 'HEAD').decode().strip()
    complete = native and not a.quick
    coverage = ('graphical automated input fixture; headless release/launchers' if a.graphical else 'native headless release, launchers and input fixture') if native else \
        'linux cross-export smoke: pack, resource equality and exported-resource suites only'
    manifest = dict(
        schema=1, purpose=a.purpose, variant=a.variant, variant_label=spec['label'], kind=spec['kind'], complete_checks=complete,
        source_head=head, source_tree=tree, source_pin=pins['variants'][a.variant].get('commit'),
        composition=[dict(variant=m, commit=c) for m, c in members] or None,
        compare_base=diff['compared_to'], changed_files=diff['changed'], allowed_paths=diff.get('allowed_paths'),
        controls_commit=controls, export_override='; '.join(overrides) + '; original preset restored byte-for-byte',
        engine=VERSION, engine_sha256=digest(Path(a.godot).read_bytes()), host=platform.platform(), target=target,
        architectures=architectures, timestamp_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
        run_url='https://github.com/' + os.environ.get('GITHUB_REPOSITORY', 'cappy2yappy/momentum-fractured') + '/actions/runs/' + os.environ.get('GITHUB_RUN_ID', 'local'),
        run_attempt=os.environ.get('GITHUB_RUN_ATTEMPT', 'local'), reproducibility=reproducibility,
        archive=archive.name, archive_sha256=digest(archive.read_bytes()), archive_bytes=archive.stat().st_size,
        pck_sha256=digest(first_pack), pck_entries=pack_audit['entry_count'], members=members_hash,
        launchers=launcher_names, provisional_launchers=provisional, launcher_isolation=launcher_checks,
        source_suites=len(suites) if suites else None, source_assertions=sum(x['passes'] for x in suites) if suites else None,
        exported_assertions=sum(x['passes'] for x in rows if x['test'].startswith(('native-exported', 'exported-'))),
        source_files_unchanged=len(before), native_coverage=coverage, not_executed=notes, signing='unsigned/unnotarized',
        art07_excluded=True, policy=policy,
        limitations=['No hands-on human campaign', 'No physical gamepad', 'No sustained FPS',
                     'Hosted runs are headless; graphical coverage requires a desktop host',
                     'macOS Universal contains arm64 and x86_64; hosted macOS-15-intel executes x86_64 only'])
    (out / 'MANIFEST.json').write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8')
    (out / 'SHA256SUMS.txt').write_text(manifest['archive_sha256'] + '  ' + archive.name + '\n')
    if os.environ.get('PMPILOT_INSTALL') and Path(os.environ['PMPILOT_INSTALL']).is_file():
        shutil.copy2(os.environ['PMPILOT_INSTALL'], evidence / 'INSTALL.json')
    save_results()
    print(json.dumps({k: v for k, v in manifest.items() if k not in ('members', 'policy', 'changed_files')}), flush=True)


def annotate(level, title, message):
    """GitHub workflow command: surfaces in the check-run annotations API even when job logs are not readable."""
    text = message.replace('%', '%25').replace('\r', '').replace('\n', '%0A')
    print('::%s title=%s::%s' % (level, title, text[:8000]), flush=True)


if __name__ == '__main__':
    import traceback
    try:
        main()
    except BaseException as exc:  # noqa: B902 - report then re-raise so the job still fails
        if os.environ.get('GITHUB_ACTIONS'):
            annotate('error', 'pmpilot failure', ''.join(traceback.format_exception_only(type(exc), exc))[-3500:] + '\n' + ''.join(traceback.format_tb(exc.__traceback__)[-3:]))
        raise
