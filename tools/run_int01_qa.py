#!/usr/bin/env python3
"""Reproduce INT-01-0061 suites with disposable profiles; no creator saves touched."""
import argparse, json, os, pathlib, re, shutil, subprocess, time
parser = argparse.ArgumentParser()
parser.add_argument('--godot', default=shutil.which('godot') or '/Applications/Godot.app/Contents/MacOS/Godot')
args = parser.parse_args()
root = pathlib.Path(__file__).resolve().parents[1]
logs = root / 'build/int01/logs'; logs.mkdir(parents=True, exist_ok=True)
suites = ['approved_baseline','approved_combat_swing','annex_expansion','annex_traversal','save_compatibility','skyworks_progression','storm_keeper','movement_momentum','sprite_integration','world_expansion','expansion_gates_save','expansion_traversal','gameplay_stabilization','traversal_transitions','world_cohesion_traversal','integration_candidate','integration_descent']
results = []
def run(name, command, profile):
    env = os.environ.copy()
    env['HOME'] = str(root / 'build/int01/profiles' / profile)
    # Linux also honors XDG_DATA_HOME; Windows requires a disposable OS user.
    env['XDG_DATA_HOME'] = str(pathlib.Path(env['HOME']) / '.local/share')
    pathlib.Path(env['HOME']).mkdir(parents=True, exist_ok=True)
    start = time.time()
    try:
        p = subprocess.run(command, cwd=root, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, timeout=300)
        out, rc = p.stdout, p.returncode
    except subprocess.TimeoutExpired as e:
        out, rc = (e.stdout or b'').decode(), 124
    (logs / (name + '.log')).write_text(out)
    row = dict(suite=name, command=command, home=env['HOME'], returncode=rc, seconds=round(time.time()-start,2), passes=len(re.findall(r'^PASS:',out,re.M)), failures=len(re.findall(r'^FAIL:',out,re.M)), script_errors=len(re.findall(r'SCRIPT ERROR|Parse Error|Failed to load',out)), warnings=[s for s in out.splitlines() if s.startswith(('ERROR:','WARNING:'))])
    results.append(row)
    (logs / 'int01_reproduction_results.json').write_text(json.dumps(results,indent=2))
    print(name, row['passes'], rc, flush=True)
base = [args.godot, '--headless', '--path', str(root)]
run('import', base + ['--import','--quit'], 'import')
run('verify_baseline', [shutil.which('python3') or 'python3','tools/verify_baseline.py'], 'verify')
for suite in suites:
    extra = ['--fixed-fps','60'] if suite == 'integration_descent' else []
    run(suite, base + extra + ['--script',f'res://tests/{suite}.gd','--','--test'], suite)
# Use a new profile per reproduction, but preserve it across the two processes.
profile = 'restart-' + str(time.time_ns())
for stage in ['prepare','reload']:
    run('profile_'+stage, base + ['--script','res://tests/integration_profile.gd','--','--'+stage], profile)
raise SystemExit(1 if any(r['returncode'] or r['failures'] or r['script_errors'] for r in results) else 0)
