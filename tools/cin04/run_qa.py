"""Reproducible bounded CIN04 checks with isolated writable saves."""
import argparse,json,os,re,subprocess
from pathlib import Path
p=argparse.ArgumentParser()
p.add_argument('--godot',required=True)
p.add_argument('--rendered',action='store_true')
a=p.parse_args()
root=Path(__file__).resolve().parents[2]
out=root/'build/cin04';out.mkdir(parents=True,exist_ok=True)
profile=out/'profile';profile.mkdir(exist_ok=True)
env=os.environ.copy()
if os.name=='nt':env['APPDATA']=str(profile)
# Inherited fixtures retain their assertions; only registry scope/save path adapts.
legacy=(root/'tests/story_cinematics/runtime.gd').read_text()
(out/'legacy_runtime.gd').write_text(legacy.replace('for id in Presenter.PRESETS:','for id in Presenter.COPY:'))
original=(root/'tests/cin_tools_01/runtime.gd').read_text()
(out/'tools_runtime.gd').write_text(original.replace('/tmp/kaze-cin-tools-01-regression-save.json','res://build/cin04/tools_sentinel.json'))
names=['tests/cin04/runtime.gd','tests/cin04/authoring.gd']
if not a.rendered:names+=['build/cin04/legacy_runtime.gd','build/cin04/tools_runtime.gd']
mode='rendered' if a.rendered else 'headless'
rows=[]
for name in names:
 cmd=[a.godot]+([] if a.rendered else ['--headless'])+['--path',str(root),'--script','res://'+name,'--','--test']
 result=subprocess.run(cmd,cwd=root,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=90)
 text=result.stdout.decode(errors='replace')
 label=Path(name).stem
 if name.startswith('tests/cin04'):label='cin04_'+label
 (out/(mode+'_'+label+'.log')).write_text(text)
 row=dict(suite=name,mode=mode,exit=result.returncode,passes=len(re.findall(r'^PASS:',text,re.M)),failures=len(re.findall(r'^FAIL:|SCRIPT ERROR|Parse Error',text,re.M)))
 rows.append(row);print(json.dumps(row),flush=True)
(out/(mode+'_results.json')).write_text(json.dumps(rows,indent=2))
raise SystemExit(any(r['exit'] or r['failures'] for r in rows))
