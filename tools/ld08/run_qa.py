"""Reproduce the scoped LD-08 evidence; engine path is supplied, profiles are disposable."""
import argparse,json,os,re,subprocess,time
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--godot',required=True);p.add_argument('--group',default='regression');args=p.parse_args()
root=Path(__file__).resolve().parents[2]
engine=str(Path(args.godot).resolve())
out=root/'docs/ld08/evidence';out.mkdir(exist_ok=True,parents=True)
suites={
 'regression':['approved_baseline','approved_combat_swing','movement_momentum','expansion_traversal','expansion_gates_save','save_compatibility','level_geometry','intentional_space','canal_geometry','gn06_dash_offsets','tr08_embodied_cinematics'],
 'contract':['ld08/contract'],
 'before':['ld08/traversal'],
 'after':['ld08/traversal'],
 'sweep':['ld08/cornice_sweep'],
 'native':['ld08/traversal'],
 'roof':['ld05_boundaries'],
}[args.group]
results=[]
for suite in suites:
 name=suite.replace('/','_');profile=root/'build/ld08/profiles'/f'{args.group}_{name}';profile.mkdir(parents=True,exist_ok=True)
 env=os.environ.copy();env['APPDATA']=str(profile)
 command=[engine,'--path',str(root),'--fixed-fps','60','--script',f'res://tests/{suite}.gd']
 if args.group!='native':command.insert(1,'--headless')
 else:command+=['--rendering-method','gl_compatibility']
 command+=['--']
 if args.group!='contract':command+=['--test']
 if args.group=='before':command+=['--ld08-before']
 if args.group=='roof':command+=['--ld08-roof-reference']
 log=out/f'{args.group}_{name}.log'
 started=time.monotonic()
 with log.open('w',encoding='utf-8') as f:
  try:result=subprocess.run(command,cwd=root,env=env,stdout=f,stderr=subprocess.STDOUT,timeout=300);code=result.returncode
  except subprocess.TimeoutExpired:code=124
 text=log.read_text(encoding='utf-8',errors='replace')
 item=dict(suite=suite,exit=code,pass_lines=len(re.findall(r'^PASS:',text,re.M)),fail_lines=len(re.findall(r'^FAIL:',text,re.M)),script_errors=text.count('SCRIPT ERROR'),seconds=round(time.monotonic()-started,2),log=log.relative_to(root).as_posix())
 results.append(item);print(json.dumps(item),flush=True)
 (out/f'{args.group}_results.json').write_text(json.dumps(results,indent=2)+'\n')
raise SystemExit(any(r['exit'] or r['fail_lines'] or r['script_errors'] for r in results))
