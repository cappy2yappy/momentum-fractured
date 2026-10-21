#!/usr/bin/env python3
"""Bounded Godot checks, disposable save paths, complete raw logs and JSON summary.
No environment HOME changes. Original regression scripts remain unchanged.
"""
import argparse, concurrent.futures, json, re, subprocess, time
from pathlib import Path
p=argparse.ArgumentParser()
p.add_argument('--godot',required=True)
p.add_argument('--rendered', action='store_true')
p.add_argument('--new-only', action='store_true')
p.add_argument('--suites', nargs='*')
a=p.parse_args()
root=Path(__file__).resolve().parents[2]
mode='rendered' if a.rendered else 'headless'
out=root/'build/cin_tools_01/qa'/mode
out.mkdir(parents=True,exist_ok=True)
new=['cin_tools_01/authoring','cin_tools_01/runtime']
regressions=['approved_baseline','approved_combat_swing','annex_expansion','annex_traversal','save_compatibility','skyworks_progression','storm_keeper','movement_momentum','sprite_integration','world_expansion','expansion_gates_save','expansion_traversal','gameplay_stabilization','traversal_transitions','world_cohesion_traversal','integration_candidate','integration_descent','level_geometry','intentional_space','audit_intentional_space','cinematic_transitions','room_transition_prototype','mixed_transitions','embodied_transitions','art04_transitions','tr08_embodied_cinematics','tr08_canal_hang_regression','tr08_stage_labels','automatic_passage_reliability','pm_staged_stair_cinematic','pm_canal_left_passage']
if a.rendered: regressions=['tr08_embodied_cinematics','tr08_canal_hang_regression','tr08_stage_labels','automatic_passage_reliability','native_cinematic_transitions']
legacy=['room_transition_prototype','mixed_transitions','embodied_transitions','art04_transitions']
def run(name):
    label=name.replace('/','_')
    profile=out/('profile_'+label)
    profile.mkdir(exist_ok=True)
    source=(root/'tests'/f'{name}.gd').read_text()
    # Every direct user:// path in the selected harness is confined to its own
    # ignored directory. World is run with --test, which disables normal saves.
    source=source.replace('user://',str(profile)+'/')
    script=out/(label+'.gd')
    script.write_text(source)
    flags=[] if name in ['automatic_passage_reliability','tr08_canal_hang_regression'] else ['--test']
    if name == 'pm_staged_stair_cinematic': flags += ['--pm-staged-stair']
    if name in ['automatic_passage_reliability','tr08_canal_hang_regression']:
        save=profile/'normal_save.json'
        if save.exists(): save.unlink()
        flags += ['--tr05-save='+str(save)]
    cmd=[a.godot]+([] if a.rendered else ['--headless'])+['--path',str(root),'--log-file',str(out/(label+'.engine.log')),'--fixed-fps','60','--script','res://'+str(script.relative_to(root)),'--']+flags+(['--tr05-legacy'] if name in legacy else [])
    start=time.monotonic()
    try:
        proc=subprocess.run(cmd,cwd=root,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=100)
        text=proc.stdout.decode(errors='replace'); code=proc.returncode
    except subprocess.TimeoutExpired as e:
        text=(e.stdout or b'').decode(errors='replace'); code=124
    (out/(label+'.log.txt')).write_text(text)
    row={'suite':name,'mode':mode,'exit':code,'seconds':round(time.monotonic()-start,2),'passes':len(re.findall(r'^PASS:',text,re.M)),'failures':len(re.findall(r'^FAIL:',text,re.M)),'script_errors':len(re.findall(r'SCRIPT ERROR|Parse Error|Failed to load',text)),'command':cmd}
    print(json.dumps(row),flush=True)
    return row
names=a.suites or new+([] if a.new_only else regressions)
# Rendered windows run serially to keep focus deterministic.
with concurrent.futures.ThreadPoolExecutor(max_workers=1 if a.rendered else 2) as pool:
    rows=[]
    for row in pool.map(run,names):
        rows.append(row)
        (out/'results.json').write_text(json.dumps(rows,indent=2))
(out/'results.json').write_text(json.dumps(rows,indent=2))
raise SystemExit(any(r['exit'] or r['failures'] or r['script_errors'] for r in rows))
