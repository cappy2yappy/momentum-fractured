"""Package the isolated GP09 main scene without editing production configuration."""
import argparse,pathlib,shutil,subprocess,os,json,hashlib,zipfile
p=argparse.ArgumentParser();p.add_argument("--godot",required=True);p.add_argument("--template",required=True)
args=p.parse_args();root=pathlib.Path(__file__).resolve().parents[2]
build=root/"build/gp09";stage=build/"export-source";out=build/"Kaze-GP09-Windows"
stage.mkdir(parents=True,exist_ok=True);out.mkdir(parents=True,exist_ok=True)
for name in ["addons","assets","scripts","scenes","data","presets","world","tools"]:
    if (root/name).exists():shutil.copytree(root/name,stage/name,dirs_exist_ok=True,ignore=shutil.ignore_patterns("__pycache__"))
shutil.copytree(root/".godot",stage/".godot",dirs_exist_ok=True)
shutil.copyfile(root/"MetSysSettings.tres",stage/"MetSysSettings.tres")
config=(root/"project.godot").read_text()
config=config.replace('run/main_scene="res://scenes/main.tscn"','run/main_scene="res://scenes/gp09/demo.tscn"')
config=config.replace('config/name="Kaze - Silent District Alpha 0.5.0"','config/name="Kaze GP09 Provisional Review"')
(stage/"project.godot").write_text(config)
preset=(root/"export_presets.cfg").read_text().replace('data/hazards/*"','data/hazards/*,data/gp09/*"').replace('tests/*,docs/*,tools/*,build/*','tests/*,docs/*,build/*')
(stage/"export_presets.cfg").write_text(preset)
profile=build/"package-profile";profile.mkdir(exist_ok=True)
env=os.environ.copy();env.update(APPDATA=str(profile),LOCALAPPDATA=str(profile))
r=subprocess.run([args.godot,"--headless","--path",str(stage),"--export-pack","Windows Desktop",str(out/"Kaze-GP09.pck")],env=env,capture_output=True,text=True,timeout=120)
(root/"docs/gp09/evidence/export.log").write_text(r.stdout+r.stderr)
if r.returncode:raise SystemExit(r.returncode)
shutil.copyfile(args.template,out/"Kaze-GP09.exe")
(out/"Play.cmd").write_text('@echo off\ncd /d "%~dp0"\nstart "" "Kaze-GP09.exe"\n')
(out/"Play-Fresh.cmd").write_text('@echo off\ncd /d "%~dp0"\nstart "" "Kaze-GP09.exe" -- --gp09-fresh\n')
(out/"Play-Reduced-Motion.cmd").write_text('@echo off\ncd /d "%~dp0"\nstart "" "Kaze-GP09.exe" -- --reduced-motion\n')
(out/"README.txt").write_text("KAZE GP-09 — PROVISIONAL PLAYABLE ROOM\n\nExtract the entire ZIP, then open Play.cmd or Kaze-GP09.exe.\nKeep the EXE and PCK together. No Godot install is required.\nPlay-Fresh resets ONLY this demo save. Play-Reduced-Motion shortens the cut-in.\n\nA/D: move. Space: jump. J: attack. F: parry. E: examine, recover, exit.\nE: advance inspection; Esc: close. Space: skip cut-in. F5: save. F9: reload.\n\nExamine the bundle, resolve the encounter, wait for the vent SAFE/RECOVERY window,\nrecover at a shelter, and use E at the exit. Movement returns after the exit fade.\nThe safe shelter remains available to retreat and heal.\n\nThis room, dialogue, enemy placement and architecture are NOT new canon.\nThe demo has its own save location and never opens campaign rooms.\nWindows x64; Godot 4.6.1 release template, unsigned review build.\n")
manifest={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in out.iterdir() if p.is_file()}
(out/"SHA256.json").write_text(json.dumps(manifest,indent=2)+"\n")
archive=build/"Kaze-GP09-Windows.zip"
with zipfile.ZipFile(archive,"w",zipfile.ZIP_DEFLATED) as z:
    for p in out.iterdir():z.write(p,"Kaze-GP09-Windows/"+p.name)
print(archive)
