from pathlib import Path
import subprocess, concurrent.futures, json, hashlib
root=Path(__file__).resolve().parents[2]
out=root.parent/'integration-qa-authoritative-evidence'; out.mkdir(exist_ok=True)
suites=['tests/approved_baseline.gd','tests/approved_combat_swing.gd','tests/movement_momentum.gd','tests/sprite_integration.gd','tests/save_compatibility.gd','tests/tr08_canal_hang_regression.gd','tests/story_cinematics/runtime.gd','tests/story_demo/contracts.gd','tests/en01/framework.gd','tests/en01/persistence.gd','tests/haz01_toolkit.gd','tests/haz01_contract.gd']
def run(source):
 name=Path(source).stem; text=(root/source).read_text(); executed=source; substitutions={}
 if source=='tests/save_compatibility.gd':
  substitutions={'user://alpha05_regression_only.json':'res://build/alpha07_qa/compatibility.json','user://missing_folder/cannot_save.json':'res://build/alpha07_qa/missing_folder/cannot_save.json'}
 if source=='tests/movement_momentum.gd':
  substitutions={'user://momentum_regression_only.json':'res://build/alpha07_qa/momentum.json'}
 if source=='tests/story_demo/contracts.gd':
  substitutions={'res://../int01-evidence/disk-roundtrip.json':'res://build/alpha07_qa/interaction-roundtrip.json'}
 if substitutions:
  for a,b in substitutions.items():
   assert a in text;text=text.replace(a,b)
  executed='tests/alpha07_qa/disposable_'+name+'.gd';(root/executed).write_text(text)
 extra=['--test']
 if source=='tests/tr08_canal_hang_regression.gd':
  probe=(root/'tests/tr08_canal_hang_probe.gd').read_text()
  original='w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w'
  replacement='w=load("res://scenes/main.tscn").instantiate();w.save_path=save_path();root.add_child(w);current_scene=w'
  assert probe.count(original)==1
  (root/'tests/alpha07_qa/disposable_hang_probe.gd').write_text(probe.replace(original,replacement))
  executed='tests/alpha07_qa/disposable_hang_regression.gd'
  text=text.replace('res://tests/tr08_canal_hang_probe.gd','res://tests/alpha07_qa/disposable_hang_probe.gd')
  (root/executed).write_text(text)
  substitutions={'test inheritance':'disposable_hang_probe.gd sets explicit save_path before adding unchanged campaign scene to tree'}
  extra=['--tr05-save='+str(root/'build/alpha07_qa/hang-fixture.json')]
 cmd=['/Applications/Godot.app/Contents/MacOS/Godot','--headless','--path',str(root),'--log-file',str(out/(name+'-engine.log')),'--script','res://'+executed,'--']+extra
 try:
  p=subprocess.run(cmd,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=240)
  (out/(name+'.log')).write_text(p.stdout)
  result={'source':source,'source_sha256':hashlib.sha256((root/source).read_bytes()).hexdigest(),'executed':executed,'substitutions':substitutions,'exit':p.returncode,'failed_lines':[l for l in p.stdout.splitlines() if 'FAIL' in l or 'SCRIPT ERROR' in l or 'Parse Error' in l],'pass_count':sum('PASS' in l for l in p.stdout.splitlines())}
 except subprocess.TimeoutExpired as e:
  (out/(name+'.log')).write_bytes(e.stdout or b''); result={'source':source,'exit':'timeout'}
 print(json.dumps(result),flush=True); return result
with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool: results=list(pool.map(run,suites))
(out/'regressions.json').write_text(json.dumps(results,indent=2)+'\n')
raise SystemExit(any(x['exit']!=0 or x.get('failed_lines') for x in results))
