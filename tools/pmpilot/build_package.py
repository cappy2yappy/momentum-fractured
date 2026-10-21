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
import w3_inventory  # noqa: E402

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
    userdata = 'userdata-' + variant + '-' + demo['name']
    if host == 'windows':
        seed = 'copy /y "fixtures\\%s.json" "profiles\\%s" >nul\r\n' % (demo['name'], profile_name) if seeded else ''
        # APPDATA points at a launcher-owned folder so user:// logs and caches are isolated too (campaign save is redirected by --tr05-save).
        return ('@echo off\r\ncd /d "%~dp0"\r\nif not exist "profiles" mkdir "profiles"\r\nif not exist "profiles\\' + userdata + '" mkdir "profiles\\' + userdata + '"\r\n' + seed +
                'set "APPDATA=%~dp0profiles\\' + userdata + '"\r\n'
                '"%~dp0' + exe_name + '" %* -- ' + flags + ' "--tr05-save=%~dp0profiles\\' + profile_name + '"\r\nexit /b %errorlevel%\r\n')
    seed = 'cp "$HERE/fixtures/%s.json" "$HERE/profiles/%s"\n' % (demo['name'], profile_name) if seeded else ''
    return ('#!/bin/bash\nset -euo pipefail\nHERE="$(cd "$(dirname "$0")" && pwd)"\nmkdir -p "$HERE/profiles/' + userdata + '"\n' + seed +
            'export HOME="$HERE/profiles/' + userdata + '"\n'
            'exec "$HERE/' + exe_name + '/Contents/MacOS/EXECUTABLE" "$@" -- ' + flags + ' "--tr05-save=$HERE/profiles/' + profile_name + '"\n')


def resolve_demos(demos_doc, spec):
    """Launcher set for a variant: 'default' (pilot), a named list in demos.json ('w3'), or an inline list.
    Per-variant flags: `flags` apply everywhere, `flags_no_tr08` are used instead when the variant has no TR-08
    (spec tr08 false), so the control shows the previous staged stair rather than silently showing nothing."""
    sel = spec.get('demos', 'default')
    base = sel if isinstance(sel, list) else demos_doc[sel]
    has_tr08 = spec.get('tr08')
    out = []
    for demo in base:
        d = dict(demo)
        if has_tr08 is False and 'flags_no_tr08' in d:
            d['flags'] = list(d['flags_no_tr08'])
        out.append(d)
    return out


def wave3_readme(spec, inv, demos):
    L = ['\n==== WAVE 3 PACKAGE NOTES ====\n',
         'Validation level: ' + w3_inventory.VALIDATION_STATEMENT + '\n',
         'NATIVE GRAPHICAL VALIDATION: NOT PERFORMED by the build. Export success is not visual approval.\n']
    art = inv['art08']
    if art['present']:
        m = art['manifest']
        L.append(w3_inventory.NOT_APPROVED_SENTENCE + '\n'
                 'The ART-08 clips are labelled in INVENTORY.md: %s. "candidate" means a real multi-frame animation whose creator visual acceptance is still pending; '
                 '"stand-in" is usable but not final art; "unfinished" means no frames exist. Held poses, scaling, bobbing and wipes are not animation.\n'
                 'Clips shipped: %d entries, %d distinct PNG files. Whether this build PLAYS them: %s\n' % (
                     m['label_counts'], m['clip_count'], m['distinct_png_files'],
                     'game code references assets/art08' if art['code_references']['art08_path_mentioned_in_scripts'] else
                     'no. The strips are packaged but nothing in this variant draws them.'))
    else:
        L.append('This build contains no ART-08 clips. ' + w3_inventory.NOT_APPROVED_SENTENCE + '\n')
    L.append('ART-07 (PR #53) is excluded from source, pack and package and the build fails if it is present.\n')
    if inv['ld05']:
        sw = inv['ld05']['switches']
        L.append('LD-05 switches: roof course default %s (original rooms R0 to R7 default %s). Launch argument %s turns the roof course off. See GEOMETRY_TEST.txt.\n' % (
            sw['ROOF_ENABLED'], sw['ORIGINAL_ROOMS_ENABLED'], ', '.join(sw['command_line_flags']) or '(none)'))
    L.append('Launchers and their exact arguments:')
    for d in demos:
        L.append('  Play-%s: %s [args: %s]%s' % (d['name'], d.get('describe', ''), ' '.join(d.get('flags', [])) or 'none',
                                              ' (PROVISIONAL)' if d.get('status') == 'provisional' else ''))
    L.append('')
    return '\n'.join(L)


def geometry_text(inv):
    ra = inv['ld05']['room_audit']
    L = ['LD-05 GEOMETRY TEST (variant ' + inv['variant'] + ', source ' + inv['source_head'] + ')', '',
         'Launch Play-Geometry-Test (roof course on) and Play-Geometry-OpenTop (roof course off) to compare. All 21 rooms are already on your map.',
         'Intent: the level should guide progression and not allow unintended areas. Try to wall-jump, double-jump and dash out of the top and sides of each room.',
         'Judge by feel: scripted probes cannot decide whether a space is acceptable. Known residual items are listed in docs/ld05/ROOM_AUDIT.md (not shipped).', '',
         'Every room (0 to %d) has the roof course when it is on. Rooms with a specific non-roof fix:' % (ra['rooms'] - 1)]
    for r in ra['rooms_with_fixes']:
        L.append('  R%d %s: %s' % (r['room'], r['name'], ', '.join(r['fixed_findings'])))
    L += ['', 'Rooms with before/after captures in the LD-05 evidence: R1, R6, R8, R9, R13 (footing, gatehouse top, right wall, trusses, Canal door unchanged), R14, R15, R16, R17, R19.',
          'Totals from the LD-05 audit (scripted, one bot per probe, not exhaustive): ' + json.dumps(ra.get('totals')), '']
    return '\n'.join(L)


def first_existing(root, spec_value):
    for rel in ([spec_value] if isinstance(spec_value, str) else spec_value):
        if (root / rel).is_file():
            return rel
    return None


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
    demos = resolve_demos(demos_doc, spec)
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
    # Build-time packaging exclusions: a .gdignore in a source-art folder keeps it out of the project resource set (and so out of
    # the pack). Untracked, not part of the pinned tree, recorded in the manifest. The owner should commit it.
    overlays = []
    for pat in spec.get('require_export_exclude', []):  # the export filter itself must cover it (committed in export_presets.cfg)
        assert all(pat in line for line in (root / 'export_presets.cfg').read_text(encoding='utf-8').splitlines() if line.startswith('exclude_filter=')), 'export_presets.cfg exclude_filter must contain ' + pat
    for rel in spec.get('require_gdignore', []):  # the owner committed it: assert, never create
        tracked = git(root, 'ls-files', '--', rel + '/.gdignore').decode().strip()
        assert tracked == rel + '/.gdignore', 'Pinned source must TRACK %s/.gdignore (no build-time overlay in this mode)' % rel
    for rel in spec.get('build_gdignore', []):
        if (root / rel).is_dir() and not (root / rel / '.gdignore').exists():
            (root / rel / '.gdignore').write_text('', encoding='utf-8')
            overlays.append(rel + '/.gdignore')
    before = snapshot(root)
    out = root / 'build/pmpilot' / a.variant
    if out.exists():
        shutil.rmtree(out)
    evidence = out / 'evidence'
    evidence.mkdir(parents=True)
    rows = []
    notes = []  # steps deliberately not executed on this host
    findings = []  # recorded observations that are not failures

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
            fails = [l for l in text.splitlines() if l.startswith('FAIL')]
            assert ok, 'FAIL-LINES(%d): %s || TAIL: %s' % (len(fails), ' // '.join(fails[:40]), text[-1500:])
        return text, row

    def save_results():
        (out / 'QA_RESULTS.json').write_text(json.dumps(dict(
            variant=a.variant, source_head=head, source_tree=tree, host=platform.platform(), architecture=platform.machine(),
            mode='graphical automated fixture' if a.graphical else 'native headless automated' if native else 'linux cross-export smoke (no native execution)',
            not_executed=notes, findings=findings, checks=rows), indent=2) + '\n', encoding='utf-8')

    # 1. Source policy: diff allowlist + ART-07 exclusion in the source itself.
    diff = pinlib.diff_check(pins, a.variant, root)
    (evidence / 'PRESERVATION_DIFF.json').write_text(json.dumps(diff, indent=2) + '\n')
    assert not diff['violations'], diff['violations']
    art07 = [n for n in git(root, 'ls-files').decode().splitlines() if n.startswith(FORBIDDEN_ALWAYS)]
    assert not art07, 'ART-07 files present in source: %s' % art07[:5]

    harness = None
    qa_pin = pins.get('qa_harness') or {}
    if any(x.get('requires') == 'qa_harness' for x in spec['regression'].get('extra', [])) and not a.quick:
        harness = root.parent / ('pmpilot-qa-harness-' + a.variant)  # outside the Godot project directory
        pinlib.git(root, 'worktree', 'add', '--detach', str(harness), qa_pin['commit'])
    base = [a.godot, '--headless', '--path', root]
    # The cold import must be clean on native hosts (BUILD-06 discipline). On the linux smoke host the
    # MetSys editor scripts fail to resolve before the UID cache exists; that is recorded, not gated.
    _, warm = run('import-warmup', base + ['--editor', '--import', '--quit'], timeout=300, gate=native)
    if not warm['passed']:
        findings.append('linux smoke: cold import reported %d script/UID errors before the cache existed; settled import is gated' % len(warm['errors']))
    # The settled import must be clean. The editor occasionally fails to load the MetSys plugin script on one pass
    # (observed once on hosted Windows, run 39206728741); allow up to two clean re-attempts and record every attempt.
    for attempt in range(3):
        _, settled = run('import-settled' if attempt == 0 else 'import-settled-retry%d' % attempt, base + ['--editor', '--import', '--quit'], timeout=300, gate=False)
        if settled['passed']:
            break
        findings.append('settled import attempt %d failed (%d errors); retried' % (attempt + 1, len(settled['errors'])))
    assert settled['passed'], 'settled import failed 3 times: %s' % settled['errors'][:5]

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
            argv = [x.format(godot=a.godot, root=root, python=sys.executable, harness=harness, variant=a.variant, head=head) for x in extra['argv']]
            _, qrow = run('extra-' + extra['name'], argv, timeout=extra.get('timeout', 900), regex=extra.get('pass_regex'), gate=not extra.get('informational'))
            if extra.get('informational') and not qrow['passed']:
                findings.append('informational command %s did not pass (exit %s); recorded, not gating (QA pending)' % (extra['name'], qrow['exit']))

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
    pack_file_list_sha256 = digest('\n'.join(sorted(records_a)).encode())
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
        mode = spec.get('control_equality', 'record')
        if native and mode == 'require':
            assert control_equal, 'Canonical resource hash differs from the BUILD-06 control for the same pinned source'
        if not control_equal:
            findings.append('canonical resource hash differs from the BUILD-06 control for the same pinned source (mode=%s, host=%s); '
                         'BUILD-06 claims identical repeated exports within a run, not cross-run identity' % (mode, host))
    groups = {}
    for rname, rhash in sorted(records_a.items()):
        groups.setdefault('/'.join(rname.split('/')[:2]), []).append(rname + rhash)
    group_hashes = {k: digest(''.join(v).encode())[:10] for k, v in groups.items()}
    reproducibility['group_hashes'] = group_hashes
    (evidence / 'REPRODUCIBILITY.json').write_text(json.dumps(reproducibility, indent=2) + '\n')
    if os.environ.get('GITHUB_ACTIONS'):
        annotate('notice', 'pmpilot resource hashes', 'canonical=%s entries=%d groups: %s' % (
            reproducibility['canonical_resource_sha256'], len(records_a), ' '.join('%s=%s' % kv for kv in sorted(group_hashes.items()))))

    # 3. Pack audit and package policy (ART-07 exclusion, required/forbidden prefixes, changed assets present).
    os.environ['BUILD05_SOURCE_ROOT'] = str(root)
    loader = importlib.util.spec_from_file_location('pmpilot_pack_audit', HERE / 'audit_pack.py')
    audit = importlib.util.module_from_spec(loader)
    loader.loader.exec_module(audit)
    pack_audit = audit.audit_pack(packed.read_bytes())
    assert 'scripts/cinematic_transitions.gd' in pack_audit['entries']
    forbidden = tuple(sorted(set(spec.get('forbidden_pack_prefixes', [])) | set(FORBIDDEN_ALWAYS)))
    bad = [n for n in pack_audit['entries'] if n.startswith(forbidden) or '__pycache__' in n or n.endswith('.pyc') or n.startswith('source_art/')]
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
    fixture_checks = []
    for demo in demos:
        if demo.get('seed') is not None and demo.get('fixture_check'):
            found = first_existing(root, demo['fixture_check'])
            if found:
                same = json.loads((root / found).read_text(encoding='utf-8')) == seed_for(demo['seed'], demos_doc['save_version'])
                fixture_checks.append(dict(demo=demo['name'], fixture=found, equals_generated_seed=same))
                assert same, 'Generated seed for %s differs from the candidate fixture %s' % (demo['name'], found)
            else:
                fixture_checks.append(dict(demo=demo['name'], fixture=demo['fixture_check'], equals_generated_seed=None, note='fixture not present in this source'))
    (evidence / 'FIXTURE_CHECKS.json').write_text(json.dumps(fixture_checks, indent=2) + '\n')
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
    inventory = None
    wave3_text = ''
    if spec.get('wave3'):
        inventory = w3_inventory.build(
            root, a.variant, head, tree, spec, pack_records=records_a, purpose=a.purpose, export_ok=True,
            launchers=[dict(name='Play-' + d['name'], flags=d.get('flags', []), describe=d.get('describe', ''), seeded=d.get('seed') is not None,
                            status=d.get('status', 'confirmed')) for d in demos])
        if a.graphical:
            inventory['validation']['native_graphical_validation'] = 'software-GL automated fixture only; not a native desktop playtest'
        (evidence / 'INVENTORY.json').write_text(json.dumps(inventory, indent=2) + '\n', encoding='utf-8')
        assert not inventory['problems'], inventory['problems']
        for dest in (stage, out):
            (dest / 'INVENTORY.json').write_text(json.dumps(inventory, indent=2) + '\n', encoding='utf-8')
            (dest / 'INVENTORY.md').write_text(w3_inventory.to_markdown(inventory), encoding='utf-8')
        wave3_text = wave3_readme(spec, inventory, demos)
        if inventory['ld05'] and inventory['ld05'].get('room_audit'):
            (stage / 'GEOMETRY_TEST.txt').write_text(geometry_text(inventory), encoding='utf-8')
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
        'See docs/wave3/build/README.md in the repository for the tester checklist and coverage limits.\n' + wave3_text, encoding='utf-8')
    if spec.get('wave3'):
        readme = (stage / 'README.txt').read_text(encoding='utf-8')
        assert w3_inventory.NOT_APPROVED_SENTENCE in readme and 'NATIVE GRAPHICAL VALIDATION' in readme and 'ART-07' in readme
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
    package_bad = [n for n in members_hash if n.startswith(FORBIDDEN_ALWAYS) or '/art07/' in n or '__pycache__' in n or n.endswith('.pyc') or n.startswith('source_art/')]
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
            demo = launcher.stem.removeprefix('Play-')
            owned = extracted / 'profiles' / ('userdata-' + a.variant + '-' + demo)
            ordinary = [str(x) for x in Path(env['HOME']).rglob(SAVE_NAME)] + [str(x) for x in owned.rglob(SAVE_NAME)]
            profile_file = extracted / 'profiles' / (a.variant + '-' + demo + '.json')
            seeded = (extracted / 'fixtures' / (demo + '.json')).is_file()
            ok_profile = True
            if seeded:
                try:
                    ok_profile = 'checkpoint_room' in json.loads(profile_file.read_text(encoding='utf-8'))
                except Exception:
                    ok_profile = False
            row = dict(launcher=launcher.name, ordinary_save_files=ordinary, seeded_profile_present=ok_profile if seeded else None,
                       launcher_owned_userdata_exists=owned.is_dir(), isolated=not ordinary and ok_profile)
            launcher_checks.append(row)
            assert row['isolated'], row
        (evidence / 'LAUNCHER_ISOLATION.json').write_text(json.dumps(launcher_checks, indent=2) + '\n')
    else:
        notes.append('native release startup and actual launcher runs: not executed (linux host cannot run the Windows binary or .cmd launchers)')

    # 6. Exported-resource suites (the exported pack is mounted into the editor binary; works on any host).
    env = profile('packaged')
    env.update(BUILD06_PACK=str(export_pack), BUILD06_CAPTURE_DIR=str(evidence / 'native-captures'), BUILD06_GRAPHICAL='1' if a.graphical else '0')
    run('native-exported-input', [a.godot] + ([] if a.graphical else ['--headless']) + ['--path', root, '--fixed-fps', '60', '--script', HERE / 'packaged_native.gd', '--', '--test'],
        env, 300, regex=reg['packaged_native_regex'])  # BLOCKING for every variant
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
        source_files_unchanged=len(before), native_coverage=coverage, not_executed=notes, findings=findings, signing='unsigned/unnotarized',
        art07_excluded=True, pycache_and_source_art_excluded=True, qa_status=spec.get('qa_status', 'n/a'), policy=policy,
        validation_levels=dict(
            export_success=True,
            native_graphical_validation=inventory['validation']['native_graphical_validation'] if inventory else 'NOT PERFORMED',
            hosted_run_headless=native and not a.graphical, statement=w3_inventory.VALIDATION_STATEMENT),
        inventory_sha256=digest(json.dumps(inventory, sort_keys=True).encode()) if inventory else None,
        art08_label_counts=(inventory['art08']['manifest'] or {}).get('label_counts') if inventory else None,
        art08_creator_approved_clips=0 if inventory else None,
        build_overlays=overlays, pack_file_list_sha256=pack_file_list_sha256,
        launcher_args={'Play-' + d['name']: d.get('flags', []) for d in demos},
        limitations=['No hands-on human campaign', 'No physical gamepad', 'No sustained FPS',
                     'Hosted runs are headless; graphical coverage requires a desktop host',
                     'macOS Universal contains arm64 and x86_64; hosted macOS-15-intel executes x86_64 only'])
    (out / 'MANIFEST.json').write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8')
    (out / 'SHA256SUMS.txt').write_text(manifest['archive_sha256'] + '  ' + archive.name + '\n')
    if os.environ.get('PMPILOT_INSTALL') and Path(os.environ['PMPILOT_INSTALL']).is_file():
        shutil.copy2(os.environ['PMPILOT_INSTALL'], evidence / 'INSTALL.json')
    save_results()
    print(json.dumps({k: v for k, v in manifest.items() if k not in ('members', 'policy', 'changed_files')}), flush=True)
    emit_facts(manifest, inventory, rows, pins['variants'][a.variant], launcher_checks)


def emit_facts(manifest, inventory, rows, spec, launcher_checks):
    """Echo the key integrity facts into check-run annotations, which are readable through the REST API when artifacts and logs are not.
    GitHub keeps at most 10 notices per step; this emits 4 (plus the resource-hash notice)."""
    if not os.environ.get('GITHUB_ACTIONS'):
        return
    v = manifest['variant']
    annotate('notice', 'pmpilot facts identity %s' % v, json.dumps(dict(
        variant=v, target=manifest['target'], source_head=manifest['source_head'], source_tree=manifest['source_tree'], pinned_commit=spec.get('commit'),
        head_equals_pin=manifest['source_head'] == spec.get('commit'), expected_tree=spec.get('expected_tree'), tree_equals_expected=(manifest['source_tree'] == spec['expected_tree']) if spec.get('expected_tree') else None,
        controls_commit=manifest['controls_commit'], run_url=manifest['run_url'], archive=manifest['archive'], archive_sha256_inner=manifest['archive_sha256'],
        archive_bytes=manifest['archive_bytes'], pck_sha256=manifest['pck_sha256'], pck_entries=manifest['pck_entries'],
        pack_file_list_sha256=manifest['pack_file_list_sha256'], canonical_resource_sha256=manifest['reproducibility']['canonical_resource_sha256'],
        export_bytes_identical=manifest['reproducibility']['export_bytes_identical'], resource_payloads_identical=manifest['reproducibility']['resource_payloads_identical'],
        members=len(manifest['members']), compare_base=manifest['compare_base'], changed_files=len(manifest['changed_files'])), sort_keys=True))
    checks = [dict(t=r['test'], ok=r['passed'], passes=r['passes'], exit=r['exit'], err=len(r['errors'])) for r in rows]
    annotate('notice', 'pmpilot facts checks %s' % v, json.dumps(dict(
        variant=v, complete_checks=manifest['complete_checks'], checks=checks, findings=manifest['findings'], not_executed=manifest['not_executed'],
        build_overlays=manifest['build_overlays'], launcher_isolation=[(l['launcher'], l['isolated']) for l in launcher_checks],
        source_suites=manifest['source_suites'], source_assertions=manifest['source_assertions'], exported_assertions=manifest['exported_assertions'],
        validation=manifest['validation_levels']['native_graphical_validation'], export_success=manifest['validation_levels']['export_success']), sort_keys=True))
    if inventory:
        clips = [[c['name'], c['provenance_label'], c['sha256'], c['alias_of'], c['in_exported_pack']] for c in (inventory['art08']['clips'] or [])]
        annotate('notice', 'pmpilot facts inventory %s' % v, json.dumps(dict(
            variant=v, art08_present=inventory['art08']['present'], art08_manifest_sha256=(inventory['art08']['manifest'] or {}).get('manifest_sha256'),
            art08_label_counts=(inventory['art08']['manifest'] or {}).get('label_counts'), art08_creator_approved=0, clips=clips,
            art07_excluded=inventory['art07']['excluded'], ld05=(inventory['ld05'] or {}).get('switches'), tr08_present=inventory['tr08']['tr08_present'],
            inventory_problems=inventory['problems'], inventory_sha256=manifest['inventory_sha256']), sort_keys=True))
    annotate('notice', 'pmpilot facts launchers %s' % v, json.dumps(manifest['launcher_args'], sort_keys=True))


def annotate(level, title, message):
    """GitHub workflow command: surfaces in the check-run annotations API even when job logs are not readable."""
    text = message.replace('%', '%25').replace('\r', '').replace('\n', '%0A')
    print('::%s title=%s::%s' % (level, title, text[:60000]), flush=True)


if __name__ == '__main__':
    import traceback
    try:
        main()
    except BaseException as exc:  # noqa: B902 - report then re-raise so the job still fails
        if os.environ.get('GITHUB_ACTIONS'):
            annotate('error', 'pmpilot failure', ''.join(traceback.format_exception_only(type(exc), exc))[-3500:] + '\n' + ''.join(traceback.format_tb(exc.__traceback__)[-3:]))
        raise
