#!/usr/bin/env python3
"""TR-01: full combined QA plus dedicated regression, optionally native captures."""
import argparse, os, pathlib, subprocess, sys, json, time, re
p=argparse.ArgumentParser();p.add_argument('--render',action='store_true');p.add_argument('--godot',default='/Applications/Godot.app/Contents/MacOS/Godot');args=p.parse_args()
r=pathlib.Path(__file__).resolve().parents[1];logs=r/'build/tr01';logs.mkdir(parents=True,exist_ok=True)
rc=subprocess.call([sys.executable,'tools/run_int01_qa.py','--godot',args.godot],cwd=r)
results=[]
for name,extra,headless in [('room_transition_prototype',[],True)]+([('capture_room_transition_prototype',[],False),('capture_room_transition_prototype',['--tr01-reduced-motion'],False)] if args.render else []):
 profile=logs/('profile-'+name+('-reduced' if extra else ''));profile.mkdir(parents=True,exist_ok=True)
 env=os.environ.copy();env['HOME']=str(profile);env['XDG_DATA_HOME']=str(profile/'.local/share')
 command=[args.godot]+(['--headless'] if headless else [])+['--path',str(r),'--script','res://tests/'+name+'.gd','--','--test']+extra
 start=time.time()
 with (logs/(name+('-reduced' if extra else '')+'.log')).open('w') as log:
  result=subprocess.run(command,cwd=r,env=env,stdout=log,stderr=subprocess.STDOUT,timeout=180)
 out=(logs/(name+('-reduced' if extra else '')+'.log')).read_text()
 row=dict(suite=name,command=command,returncode=result.returncode,seconds=round(time.time()-start,2),passes=len(re.findall(r'^PASS:',out,re.M)),failures=len(re.findall(r'^FAIL:',out,re.M)),script_errors=len(re.findall('SCRIPT ERROR|Parse Error',out)));results.append(row)
 rc=rc or result.returncode or row['failures'] or row['script_errors']
(logs/'tr01_results.json').write_text(json.dumps(results,indent=2));sys.exit(1 if rc else 0)
