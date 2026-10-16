"""Reproducible headless TR-03 suites; never uses the creator's save profile."""
import argparse,json,os,pathlib,re,subprocess,sys,time
p=argparse.ArgumentParser();p.add_argument('--godot',required=True);args=p.parse_args()
root=pathlib.Path(__file__).resolve().parents[1];out=root/'build/tr04/qa';out.mkdir(parents=True,exist_ok=True)
suites=['approved_baseline','approved_combat_swing','annex_expansion','annex_traversal','save_compatibility','skyworks_progression','storm_keeper','movement_momentum','sprite_integration','world_expansion','expansion_gates_save','expansion_traversal','gameplay_stabilization','traversal_transitions','world_cohesion_traversal','integration_candidate','integration_descent','room_transition_prototype','mixed_transitions','embodied_transitions','art04_transitions','level_geometry']
rows=[]
restart_profile='restart-'+str(time.time_ns())
def run(name,cmd,profile=None,diagnostic=False):
    env=os.environ.copy();profile=out/('profile-'+(profile or name));profile.mkdir(exist_ok=True)
    env['HOME']=str(profile);env['XDG_DATA_HOME']=str(profile/'xdg');env['APPDATA']=str(profile)
    start=time.monotonic()
    try:
        result=subprocess.run(cmd,cwd=root,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=300);text=result.stdout.decode(errors='replace');rc=result.returncode
    except subprocess.TimeoutExpired as e:text=(e.stdout or b'').decode(errors='replace');rc=124
    (out/(name+'.log')).write_text(text)
    row={'name':name,'command':cmd,'exit':rc,'seconds':round(time.monotonic()-start,3),'passes':len(re.findall(r'^PASS:',text,re.M)),'failures':len(re.findall(r'^FAIL:',text,re.M)),'script_errors':len(re.findall(r'SCRIPT ERROR|Parse Error|Failed to load',text)),'diagnostic_only':diagnostic,'profile':str(profile),'warnings':[line for line in text.splitlines() if line.startswith(('WARNING:','ERROR:'))]}
    rows.append(row);(out/'results.json').write_text(json.dumps(rows,indent=2)+'\n');print(json.dumps(row),flush=True)
base=[args.godot,'--headless','--path',str(root)]
# First-run inherited MetSys UID registration can log editor-only errors. Preserve
# that attempt, then independently require a clean settled import and all suites.
run('import_warmup',base+['--editor','--import','--quit'],diagnostic=True)
run('import',base+['--editor','--import','--quit'])
run('verify_baseline',[sys.executable,'tools/verify_baseline.py'])
run('verify_tr03_preservation',[sys.executable,'tools/verify_tr03_preservation.py'])
run('verify_tr04_preservation',[sys.executable,'tools/verify_tr04_preservation.py'])
for name in suites:
    run(name,base+(['--fixed-fps','60'] if name=='integration_descent' else [])+['--script','res://tests/'+name+'.gd','--','--test'])
for stage in ['prepare','reload']:run('profile_'+stage,base+['--script','res://tests/integration_profile.gd','--','--'+stage],profile=restart_profile)
run('endpoint_audit',base+['--script','res://tests/audit_embodied_endpoints.gd','--','--test'])
raise SystemExit(any(r['exit'] or (not r['diagnostic_only'] and (r['failures'] or r['script_errors'])) for r in rows))
