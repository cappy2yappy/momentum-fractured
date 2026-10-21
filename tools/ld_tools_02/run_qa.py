"""Stock + Room Creator suites, both modes, disposable Godot profiles and raw evidence."""
import argparse, json, pathlib, re, subprocess, tempfile, time, uuid
p=argparse.ArgumentParser();p.add_argument('--godot',required=True);p.add_argument('--rendered',action='store_true');p.add_argument('--pilot-only',action='store_true');a=p.parse_args()
r=pathlib.Path(__file__).resolve().parents[2];out=r/'build/ld-tools-02'/('rendered' if a.rendered else 'headless');out.mkdir(parents=True,exist_ok=True)
stock=['approved_baseline','approved_combat_swing','annex_expansion','annex_traversal','save_compatibility','skyworks_progression','storm_keeper','movement_momentum','sprite_integration','world_expansion','expansion_gates_save','expansion_traversal','gameplay_stabilization','traversal_transitions','world_cohesion_traversal','integration_candidate','integration_descent','level_geometry','intentional_space','audit_intentional_space','cinematic_transitions','room_transition_prototype','mixed_transitions','embodied_transitions','art04_transitions']
legacy={'room_transition_prototype','mixed_transitions','embodied_transitions','art04_transitions'}
rows=[]
with tempfile.TemporaryDirectory(prefix='kaze-room-qa-') as temp:
 shadow=pathlib.Path(temp)
 for entry in r.iterdir():
  if entry.name not in {'.git','project.godot','override.cfg'}:(shadow/entry.name).symlink_to(entry,target_is_directory=entry.is_dir())
 (shadow/'project.godot').write_bytes((r/'project.godot').read_bytes())
 # A unique native Godot profile isolates every user:// save from personal progress.
 (shadow/'override.cfg').write_text('[application]\nconfig/use_custom_user_dir=true\nconfig/custom_user_dir_name='+json.dumps("Kaze-Room-Creator-QA-"+uuid.uuid4().hex)+'\n')
 suites=[('room_creator','tools/ld_tools_02/qa',False),('contract_negative','tools/ld_tools_02/contract_qa',False)]
 if not a.pilot_only:
  suites += [('ld_tools_01','tools/ld_tools_01/qa',False)]
  suites += [(name+('-on' if enabled else '-off'),'tests/'+name,enabled) for enabled in [False,True] for name in stock]
 suites += [('profile-prepare','tools/ld_tools_02/save_fixture',True),('profile-reload-on','tools/ld_tools_02/save_fixture',True),('profile-reload-off','tools/ld_tools_02/save_fixture',False)]
 for label,script,enabled in suites:
  command=[a.godot,'--path',str(shadow),'--fixed-fps','60','--log-file',str(out/(label+'-engine.log')),'--script','res://'+script+'.gd','--','--test']
  if not a.rendered:command.insert(1,'--headless')
  if enabled:command.append('--authored-r18')
  if label=='profile-prepare':command.append('--prepare')
  if script.rsplit('/',1)[-1] in legacy:command.append('--tr05-legacy')
  start=time.monotonic()
  try:
   result=subprocess.run(command,cwd=r,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=150);text=result.stdout.decode(errors='replace');rc=result.returncode
  except subprocess.TimeoutExpired as e:text=(e.stdout or b'').decode(errors='replace');rc=124
  (out/(label+'.log')).write_text(text)
  row=dict(suite=label,exit=rc,seconds=round(time.monotonic()-start,2),passes=len(re.findall(r'^PASS:',text,re.M)),failures=len(re.findall(r'^FAIL:',text,re.M)),script_errors=len(re.findall(r'SCRIPT ERROR|Parse Error|Failed to load',text)),command=command)
  rows.append(row);(out/'results.json').write_text(json.dumps(rows,indent=2)+'\n');print(json.dumps(row),flush=True)
raise SystemExit(any(x['exit'] or x['failures'] or x['script_errors'] or not x['passes'] for x in rows))
