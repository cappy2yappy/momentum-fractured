"""Exercise the real EditorPlugin/EditorUndoRedoManager in a disposable editor project."""
from pathlib import Path
import argparse,subprocess,tempfile,uuid,re,json
p=argparse.ArgumentParser();p.add_argument('--godot',required=True);p.add_argument('--rendered',action='store_true');a=p.parse_args()
r=Path(__file__).resolve().parents[2];out=r/'build/ld-tools-02'/('editor-native' if a.rendered else 'editor');out.mkdir(parents=True,exist_ok=True)
with tempfile.TemporaryDirectory(prefix='kaze-room-editor-') as temp:
 shadow=Path(temp)
 for entry in r.iterdir():
  if entry.name not in {'.git','project.godot','override.cfg'}:(shadow/entry.name).symlink_to(entry,target_is_directory=entry.is_dir())
 source=(r/'project.godot').read_text();source=re.sub(r'enabled=PackedStringArray\(.*?\)', 'enabled=PackedStringArray("res://addons/room_creator/plugin.cfg")',source)
 (shadow/'project.godot').write_text(source)
 (shadow/'override.cfg').write_text('[application]\nconfig/use_custom_user_dir=true\nconfig/custom_user_dir_name="Kaze-Room-Editor-QA-'+uuid.uuid4().hex+'"\n')
 warmup=subprocess.run([a.godot,'--headless','--editor','--path',str(shadow),'--log-file',str(out/'import-engine.log'),'--import','--quit'],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=90)
 (out/'import.log').write_bytes(warmup.stdout)
 try:
  command=[a.godot,'--editor','--path',str(shadow),'--log-file',str(out/'engine.log'),'--','--room-creator-editor-qa']
  if not a.rendered:command.insert(1,'--headless')
  result=subprocess.run(command,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=90)
  text=result.stdout.decode(errors='replace');code=result.returncode
 except subprocess.TimeoutExpired as e:text=(e.stdout or b'').decode(errors='replace');code=124
 (out/'editor.log').write_text(text)
 row=dict(exit=code,passes=len(re.findall(r'^PASS:',text,re.M)),failures=len(re.findall(r'^FAIL:',text,re.M)),script_errors=len(re.findall('SCRIPT ERROR|Parse Error|Failed to load',text)))
 (out/'results.json').write_text(json.dumps(row,indent=2));print(json.dumps(row))
 raise SystemExit(bool(code or row['failures'] or row['script_errors'] or not row['passes']))
