from pathlib import Path
import subprocess,json
r=Path('work/int01').resolve();out=r.parent/'int01-evidence';engine='/Applications/Godot.app/Contents/MacOS/Godot'
suites=['tests/story_demo/smoke.gd','tests/story_demo/contracts.gd','tools/story/validate_data.gd','tests/approved_baseline.gd','tests/integration_candidate.gd','tests/tr08_canal_hang_regression.gd','tests/save_compatibility.gd','tests/expansion_gates_save.gd','tests/st04_approved_copy.gd','tests/automatic_passage_reliability.gd']
results=[]
for suite in suites:
 name=Path(suite).stem
 original=r/suite
 generated=r/'tests'/'int01_disposable'/Path(suite).name
 generated.parent.mkdir(exist_ok=True)
 generated.write_text(original.read_text().replace('user://',str(out/'profile')+'/'))
 suite=str(generated.relative_to(r))
 with (out/(name+'.txt')).open('w') as f:
  try: code=subprocess.run([engine,'--headless','--log-file',str(out/(name+'-engine.log')),'--path',str(r),'--script',suite,'--','--test'],stdout=f,stderr=subprocess.STDOUT,timeout=60).returncode
  except subprocess.TimeoutExpired: code=124
 text=(out/(name+'.txt')).read_text();result={'suite':suite,'exit':code,'passes':sum(x.startswith('PASS') for x in text.splitlines()),'failures':[x for x in text.splitlines() if x.startswith('FAIL') or 'SCRIPT ERROR' in x]};results.append(result);print(json.dumps(result),flush=True)
(out/'results.json').write_text(json.dumps(results,indent=2))
