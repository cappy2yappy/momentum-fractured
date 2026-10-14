"""Reuse INT-01 runner, discover extra assertion suites, and reject silent passes."""
import argparse, ast, json, os, pathlib, re, subprocess, sys, time
ROOT = pathlib.Path(__file__).resolve().parents[2]
LOGS = ROOT / 'build/int01/logs'
KNOWN = set('approved_baseline approved_combat_swing annex_expansion annex_traversal save_compatibility skyworks_progression storm_keeper movement_momentum sprite_integration world_expansion expansion_gates_save expansion_traversal gameplay_stabilization traversal_transitions world_cohesion_traversal integration_candidate integration_descent'.split())
# Exact known engine teardown diagnostics remain visible but do not hide runtime errors.
NONFATAL = re.compile(r'^(WARNING:.*(?:ObjectDB instances leaked|RID.*leaked)|ERROR: (?:\d+ RID allocations.*leaked at exit\.|\d+ resources still in use at exit.*|Condition "ret != noErr" is true\. Returning: ""))$')
def hard_errors(text):
    return [line for line in text.splitlines() if re.search(r'SCRIPT ERROR|Parse Error|Failed to load|^FAIL:|^ERROR:', line) and not NONFATAL.match(line)]
def validate(rows, discovered):
    failures = []
    expected = discovered | {'import', 'verify_baseline', 'profile_prepare', 'profile_reload'}
    if set(r['suite'] for r in rows) != expected: failures.append('Missing/unexpected suite results')
    for r in rows:
        output = (LOGS / (r['suite'] + '.log')).read_text()
        r['hard_errors'] = hard_errors(output)
        if r['returncode'] or r['failures'] or r['script_errors'] or r['hard_errors']:
            failures.append(r['suite'])
        if r['suite'] not in {'import', 'verify_baseline'} and (not r['passes'] or not re.search(r'\b0 failure\(s\)', output)):
            failures.append(r['suite'] + ': missing assertions/completion')
    return failures

def main():
    p = argparse.ArgumentParser(); p.add_argument('--godot', required=True); args = p.parse_args()
    LOGS.mkdir(parents=True, exist_ok=True)
    assert subprocess.check_output([args.godot, '--version'], text=True).strip() == '4.6.1.stable.official.14d19694e'
    tree = ast.parse((ROOT / 'tools/run_int01_qa.py').read_text())
    listed = set(next(ast.literal_eval(n.value) for n in tree.body if isinstance(n, ast.Assign) and any(isinstance(t, ast.Name) and t.id == 'suites' for t in n.targets)))
    discovered = listed | {f.stem for f in (ROOT / 'tests').glob('*.gd') if 'PASS:' in f.read_text() and f.stem != 'integration_profile'}
    assert KNOWN <= listed and all((ROOT/'tests'/f'{name}.gd').is_file() for name in discovered), 'Required suite missing'
    result = subprocess.run([sys.executable, 'tools/run_int01_qa.py', '--godot', args.godot], cwd=ROOT)
    rows = json.loads((LOGS / 'int01_reproduction_results.json').read_text())
    for suite in sorted(discovered - listed):
        env = os.environ.copy(); env['HOME'] = str(ROOT / 'build/ci/profiles' / suite)
        env['XDG_DATA_HOME'] = env['HOME'] + '/.local/share'; pathlib.Path(env['HOME']).mkdir(parents=True, exist_ok=True)
        start = time.monotonic()
        try:
            r = subprocess.run([args.godot, '--headless', '--path', str(ROOT), '--script', f'res://tests/{suite}.gd', '--', '--test'], env=env, capture_output=True, text=True, timeout=300)
            output, rc = r.stdout + r.stderr, r.returncode
        except subprocess.TimeoutExpired as e:
            output, rc = (e.stdout or b'').decode() + (e.stderr or b'').decode(), 124
        (LOGS / (suite + '.log')).write_text(output)
        rows.append(dict(suite=suite, returncode=rc, passes=len(re.findall(r'^PASS:', output, re.M)), failures=len(re.findall(r'^FAIL:', output, re.M)), script_errors=len(re.findall(r'SCRIPT ERROR|Parse Error|Failed to load', output)), seconds=round(time.monotonic()-start,2)))
    failures = validate(rows, discovered)
    report = dict(status='passed' if not failures and not result.returncode else 'failed', suite_count=len(discovered), assertion_count=sum(r['passes'] for r in rows), failures=failures, results=rows)
    (LOGS / 'CI_QA_REPORT.json').write_text(json.dumps(report, indent=2))
    print(json.dumps({k:v for k,v in report.items() if k != 'results'}, indent=2))
    if 'GITHUB_STEP_SUMMARY' in os.environ:
        with open(os.environ['GITHUB_STEP_SUMMARY'], 'a') as f: f.write(f"QA: **{report['status']}**, {len(discovered)} suites + save prepare/reload, {report['assertion_count']} assertions.\n")
    return int(report['status'] != 'passed')
if __name__ == '__main__': sys.exit(main())
