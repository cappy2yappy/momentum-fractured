"""TR05 source regressions; isolated data, bounded timeouts and exact logs."""
from pathlib import Path
import os,sys,subprocess,time,json,re,argparse
p=argparse.ArgumentParser();p.add_argument('--godot',required=True);a=p.parse_args()
r=Path(__file__).resolve().parents[1];out=r/'build/tr05/qa';out.mkdir(parents=True,exist_ok=True)
suites=['approved_baseline','approved_combat_swing','annex_expansion','annex_traversal','save_compatibility','skyworks_progression','storm_keeper','movement_momentum','sprite_integration','world_expansion','expansion_gates_save','expansion_traversal','gameplay_stabilization','traversal_transitions','world_cohesion_traversal','integration_candidate','integration_descent','level_geometry','cinematic_transitions']
legacy=['room_transition_prototype','mixed_transitions','embodied_transitions','art04_transitions']
rows=[]
for name in suites+legacy:
 profile=out/('profile-'+name);profile.mkdir(exist_ok=True);env=os.environ.copy();env['APPDATA']=str(profile);env['HOME']=str(profile);env['XDG_DATA_HOME']=str(profile/'xdg')
 command=[a.godot,'--headless','--path',str(r),'--fixed-fps','60','--script','res://tests/'+name+'.gd','--','--test']+(['--tr05-legacy'] if name in legacy else [])
 start=time.monotonic()
 try:
  result=subprocess.run(command,cwd=r,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=90);text=result.stdout.decode(errors='replace');rc=result.returncode
 except subprocess.TimeoutExpired as e:text=(e.stdout or b'').decode(errors='replace');rc=124
 (out/(name+'.log')).write_text(text,encoding='utf-8')
 row=dict(suite=name,exit=rc,seconds=round(time.monotonic()-start,2),legacy=name in legacy,passes=len(re.findall(r'^PASS:',text,re.M)),failures=len(re.findall(r'^FAIL:',text,re.M)),script_errors=len(re.findall('SCRIPT ERROR|Parse Error|Failed to load',text)),command=command)
 rows.append(row);(out/'results.json').write_text(json.dumps(rows,indent=2));print(json.dumps(row),flush=True)
sys.exit(any(x['exit'] or x['failures'] or x['script_errors'] for x in rows))
