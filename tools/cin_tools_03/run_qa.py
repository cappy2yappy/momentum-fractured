#!/usr/bin/env python3
"""Reuse the headless runner; launch rendered cases serially from the main thread."""
import argparse,json,re,subprocess,time
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--godot',required=True);p.add_argument('--rendered',action='store_true');p.add_argument('--gameplay-rendered',action='store_true');a=p.parse_args()
r=Path(__file__).resolve().parents[2]
suites=['cin_tools_03/workspace','cin_tools_01/authoring','cin_tools_01/runtime']
if not a.rendered:
 suites+=['tr08_embodied_cinematics','tr08_canal_hang_regression','tr08_stage_labels','automatic_passage_reliability','save_compatibility','movement_momentum','sprite_integration']
 raise SystemExit(subprocess.call(['python3',str(r/'tools/cin_tools_01/run_qa.py'),'--godot',a.godot,'--suites']+suites,cwd=r))
if a.gameplay_rendered:suites+=['tr08_canal_hang_regression','automatic_passage_reliability']
out=r/'build/cin_tools_03/qa/rendered';out.mkdir(parents=True,exist_ok=True)
rows=[]
for name in suites:
 label=name.replace('/','_');profile=out/('profile_'+label);profile.mkdir(exist_ok=True)
 source=(r/'tests'/f'{name}.gd').read_text().replace('user://',str(profile)+'/')
 script=out/(label+'.gd');script.write_text(source)
 if name in ['tr08_canal_hang_regression','automatic_passage_reliability']:
  save=profile/'normal_save.json'
  if save.exists():save.unlink()
  flags=['--tr05-save='+str(save)]
 else:flags=['--test']
 cmd=[a.godot,'--path',str(r),'--log-file',str(out/(label+'.engine.log')),'--fixed-fps','60','--script','res://'+str(script.relative_to(r)),'--']+flags
 started=time.monotonic()
 try:
  proc=subprocess.run(cmd,cwd=r,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=120);text=proc.stdout.decode(errors='replace');code=proc.returncode
 except subprocess.TimeoutExpired as e:text=(e.stdout or b'').decode(errors='replace');code=124
 (out/(label+'.log.txt')).write_text(text)
 row=dict(suite=name,mode='rendered',exit=code,seconds=round(time.monotonic()-started,2),passes=len(re.findall(r'^PASS:',text,re.M)),failures=len(re.findall(r'^FAIL:',text,re.M)),script_errors=len(re.findall(r'SCRIPT ERROR|Parse Error|Failed to load',text)),command=cmd)
 rows.append(row);print(json.dumps(row),flush=True);(out/'results.json').write_text(json.dumps(rows,indent=2))
raise SystemExit(any(x['exit'] or x['failures'] or x['script_errors'] for x in rows))
