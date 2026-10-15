"""Reuse INT-01 runner, discover extra assertion suites, and reject silent passes."""
import argparse, ast, json, os, pathlib, re, subprocess, sys, time
ROOT = pathlib.Path(os.environ.get('CI_SOURCE_ROOT', pathlib.Path(__file__).resolve().parents[2])).resolve()
LOGS = ROOT / 'build/int01/logs'
KNOWN = set('approved_baseline approved_combat_swing annex_expansion annex_traversal save_compatibility skyworks_progression storm_keeper movement_momentum sprite_integration world_expansion expansion_gates_save expansion_traversal gameplay_stabilization traversal_transitions world_cohesion_traversal integration_candidate integration_descent'.split())
# Exact known engine teardown diagnostics remain visible but do not hide runtime errors.
NONFATAL = re.compile(r'^(WARNING:.*(?:ObjectDB instances leaked|RID.*leaked)|ERROR: (?:\d+ RID allocations.*leaked at exit\.|\d+ resources still in use at exit.*|Condition "ret != noErr" is true\. Returning: ""))$')
def hard_errors(text):
    return [line for line in text.splitlines() if re.search(r'SCRIPT ERROR|Parse Error|Failed to load|^FAIL:|^ERROR:', line) and not NONFATAL.match(line)]
def validate(rows, discovered):
    failures = []
    expected = discovered | {'import', 'verify_baseline', 'profile_prepare', 'profile_reload'} | {r['suite'] for r in rows if r['suite'].startswith('mixed_profile_')}
    if set(r['suite'] for r in rows) != expected: failures.append('Missing/unexpected suite results')
    for r in rows:
        output = (LOGS / (r['suite'] + '.log')).read_text()
        r['hard_errors'] = hard_errors(output)
        if r['returncode'] or r['failures'] or r['script_errors'] or r['hard_errors']:
            failures.append(r['suite'])
        completion = re.search(r'\b0 failure\(s\)', output) or (r['suite'] == 'sprite_integration' and r['passes'] >= 43) or (r['suite'].startswith('mixed_profile_') and r['passes'] == 1)
        if r['suite'] not in {'import', 'verify_baseline'} and (not r['passes'] or not completion):
            failures.append(r['suite'] + ': missing assertions/completion')
    return failures

def main():
    p = argparse.ArgumentParser(); p.add_argument('--godot', required=True); args = p.parse_args()
    LOGS.mkdir(parents=True, exist_ok=True)
    assert subprocess.check_output([args.godot, '--version'], text=True).strip() == '4.6.1.stable.official.14d19694e'
    if not (ROOT / 'tools/run_int01_qa.py').is_file():
        return legacy_qa(args.godot)
    tree = ast.parse((ROOT / 'tools/run_int01_qa.py').read_text())
    listed = set(next(ast.literal_eval(n.value) for n in tree.body if isinstance(n, ast.Assign) and any(isinstance(t, ast.Name) and t.id == 'suites' for t in n.targets)))
    discovered = listed | {f.stem for f in (ROOT / 'tests').glob('*.gd') if 'PASS:' in f.read_text() and f.stem not in {'integration_profile', 'mixed_profile'}}
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
    if (ROOT/'tests/mixed_profile.gd').is_file():
        for pilot, room, position in [('fresh',0,None),('walk',15,[1950,1118]),('stair',14,[1390,478]),('special',20,[540,518])]:
            profile=ROOT/'build/ci/profiles'/('fixture-'+pilot); profile.mkdir(parents=True,exist_ok=True)
            save=profile/'fixture.json'
            if position:
                fixture=dict(version=8,checkpoint_room=room,checkpoint_position=position,double_jump=True,tether_unlocked=True,dash_unlocked=True,completed=True,guard_defeated=True,boss_defeated=True,speed_upgrade_level=0,kunai_unlocked=dict(wind=True,fire=True,electric=True),selected_kunai='wind',opened_kunai_gates=dict(skyworks_wind_intake=True,cistern_wind_cache=True),relay_fragments=dict(undercroft_sigil=True,terrace_west=True,terrace_fire_cache=True),expansion_flags=dict(junction_return=True),visited=[i==room for i in range(21)])
                save.write_text(json.dumps(fixture))
            env=os.environ.copy();env['XDG_DATA_HOME']=str(profile/'xdg')
            r=subprocess.run([args.godot,'--headless','--path',str(ROOT),'--script','res://tests/mixed_profile.gd','--',f'--tr02-save={save}',f'--expected-room={room}'],env=env,capture_output=True,text=True,timeout=90)
            output=r.stdout+r.stderr;name='mixed_profile_'+pilot
            (LOGS/(name+'.log')).write_text(output)
            rows.append(dict(suite=name,returncode=r.returncode,passes=len(re.findall(r'^PASS:',output,re.M)),failures=len(re.findall(r'^FAIL:',output,re.M)),script_errors=len(re.findall(r'SCRIPT ERROR|Parse Error|Failed to load',output))))
    failures = validate(rows, discovered)
    report = dict(qa_mode='candidate-full-regression', source_sha=os.environ.get('SOURCE_SHA'), status='passed' if not failures and not result.returncode else 'failed', suite_count=len(discovered), assertion_count=sum(r['passes'] for r in rows), failures=failures, results=rows)
    (LOGS / 'CI_QA_REPORT.json').write_text(json.dumps(report, indent=2))
    print(json.dumps({k:v for k,v in report.items() if k != 'results'}, indent=2))
    if 'GITHUB_STEP_SUMMARY' in os.environ:
        with open(os.environ['GITHUB_STEP_SUMMARY'], 'a') as f: f.write(f"QA: **{report['status']}**, {len(discovered)} suites + save prepare/reload, {report['assertion_count']} assertions.\n")
    return int(report['status'] != 'passed')

def legacy_qa(godot):
    project = (ROOT/'project.godot').read_text()
    assert '0.6.1' not in project and not (ROOT/'tests/integration_candidate.gd').exists(), 'Candidate source missing mandatory INT-01 runner'
    assert not (ROOT/'tests').exists(), 'Source has tests without a recognized runner; explicit adapter required'
    rows=[]
    for name, flags in [('import',['--import','--quit']),('main_scene_startup',['--fixed-fps','60','--quit-after','120'])]:
        profile=ROOT/'build/ci/profiles'/name;profile.mkdir(parents=True,exist_ok=True)
        env=os.environ.copy();env['HOME']=str(profile);env['XDG_DATA_HOME']=str(profile/'.local/share')
        start=time.monotonic()
        try:
            p=subprocess.run([godot,'--headless','--path',str(ROOT)]+flags,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=300)
            output,rc=p.stdout,p.returncode
        except subprocess.TimeoutExpired as e:output,rc=(e.stdout or b'').decode(),124
        (LOGS/(name+'.log')).write_text(output)
        rows.append(dict(suite=name,returncode=rc,passes=0,failures=0,script_errors=len(re.findall(r'SCRIPT ERROR|Parse Error|Failed to load',output)),hard_errors=hard_errors(output),seconds=round(time.monotonic()-start,2)))
    failed=[r['suite'] for r in rows if r['returncode'] or r['hard_errors'] or r['script_errors']]
    report=dict(status='failed' if failed else 'passed',source_sha=os.environ.get('SOURCE_SHA'),qa_mode='legacy-import-startup',suite_count=0,assertion_count=0,unavailable_checks=['No regression tests or baseline preservation verifier exist in this source'],failures=failed,results=rows)
    (LOGS/'CI_QA_REPORT.json').write_text(json.dumps(report,indent=2))
    print(json.dumps(report,indent=2))
    return int(bool(failed))

if __name__ == '__main__': sys.exit(main())


