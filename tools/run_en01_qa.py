#!/usr/bin/env python3
"""EN-01 regressions. Redirect legacy test save paths into disposable temp storage."""
import argparse, json, pathlib, re, subprocess, tempfile
p=argparse.ArgumentParser()
p.add_argument('--godot',default='/Applications/Godot.app/Contents/MacOS/Godot')
p.add_argument('--rendered',action='store_true')
a=p.parse_args()
root=pathlib.Path(__file__).resolve().parents[1]
out=root/'build/en01'; out.mkdir(parents=True,exist_ok=True)
results=[]
suites=['approved_baseline','approved_combat_swing','movement_momentum','save_compatibility','gameplay_stabilization','expansion_gates_save','sprite_integration','integration_candidate']
def run(name,cmd):
    r=subprocess.run(cmd,cwd=root,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=180)
    (out/(name+'.txt')).write_text(r.stdout)
    row=dict(suite=name,exit=r.returncode,passes=len(re.findall(r'^PASS:',r.stdout,re.M)),failures=len(re.findall(r'^FAIL:',r.stdout,re.M)),script_errors=len(re.findall('SCRIPT ERROR|Parse Error|Failed to load',r.stdout)))
    results.append(row); print(row,flush=True)
base=[a.godot,'--path',str(root),'--log-file',str(out/'engine.log'),'--fixed-fps','60']
with tempfile.TemporaryDirectory(prefix='kaze-en01-') as temp:
    for suite in suites:
        source=(root/'tests'/(suite+'.gd')).read_text()
        # Only test fixture paths change; production scripts and assertions are untouched.
        generated=pathlib.Path(temp)/(suite+'.gd')
        generated.write_text(source.replace('user://',temp+'/'))
        run(suite,base+['--headless','--script',str(generated),'--','--test'])
    run('en01_framework',base+([] if a.rendered else ['--headless'])+['--audio-driver','Dummy','--script','res://tests/en01/framework.gd','--','--test'])
run('en01_persistence',base+['--headless','--script','res://tests/en01/persistence.gd','--','--test'])
run('preservation',['python3','tools/verify_baseline.py'])
(out/'results.json').write_text(json.dumps(results,indent=2)+'\n')
raise SystemExit(int(any(x['exit'] or x['failures'] or x['script_errors'] for x in results)))
