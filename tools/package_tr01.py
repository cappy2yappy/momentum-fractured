from pathlib import Path
import subprocess,zipfile,json,hashlib,shutil
r=Path.cwd();out=r/'build/tr01/playable';out.mkdir(exist_ok=True)
subprocess.run(['ditto','-x','-k',str(r/'build/tr01/macos/Kaze-TR01-macOS.zip'),str(out)],check=True)
app=next(out.glob('*.app'));binary=next((app/'Contents/MacOS').iterdir())
launcher='''import json, os, pathlib, subprocess, sys
package=pathlib.Path(__file__).resolve().parent
mode=sys.argv[1] if len(sys.argv)>1 else 'fresh'
profile=package/('playtest-profile-'+mode);profile.mkdir(exist_ok=True)
env=os.environ.copy();env['HOME']=str(profile);env['XDG_DATA_HOME']=str(profile/'.local/share')
if mode in ['rooftop','canal']:
 folder=profile/'Library/Application Support/Godot/app_userdata/Kaze — Silent District Alpha 0.5.0';folder.mkdir(parents=True,exist_ok=True)
 save=folder/'silent_district_alpha_v3.json'
 if not save.exists():
  room=14 if mode=='rooftop' else 15
  fixture=dict(version=8,checkpoint_room=room,checkpoint_position=[185,1098 if room==14 else 498],double_jump=True,tether_unlocked=True,dash_unlocked=True,completed=True,kunai_unlocked={'wind':True,'fire':False,'electric':False},opened_kunai_gates={'cistern_wind_cache':True},guard_defeated=True,boss_defeated=True,visited=[i in [0,room] for i in range(21)])
  save.write_text(json.dumps(fixture))
subprocess.run([str(package/BINARY)]+sys.argv[2:],env=env,check=True)
'''.replace('BINARY',repr(str(binary.relative_to(out))))
(out/'launch.py').write_text(launcher)
for title,mode,extra in [('Play Fresh','fresh',''),('Play Rooftop','rooftop',''),('Play Canal','canal',''),('Play Rooftop Reduced Motion','rooftop','--tr01-reduced-motion'),('Play Canal Reduced Motion','canal','--tr01-reduced-motion')]:
 p=out/(title+'.command');p.write_text('#!/bin/zsh\nset -eu\nTR01_PACKAGE="${0:A:h}"\nexec /usr/bin/env python3 "$TR01_PACKAGE/launch.py" '+mode+' '+extra+' "$@"\n');p.chmod(0o755)
(out/'README-TR01.txt').write_text('''KAZE — TR-01-0061 PROTOTYPE, Godot 4.6.1, Alpha 0.6.1 review only.
macOS universal, unsigned and not notarized. Apple M4 execution tested; Intel untested.
Use Play Rooftop / Play Canal for explicitly seeded QA fixtures, not earned progression.
These launchers write only to playtest-profile-rooftop/canal beside this package.
Play Fresh uses a separate new campaign. Normal creator profiles are not accessed.
Python 3 is required for isolated launchers. Opening the app normally uses normal saves;
use the included launchers for this review. No personal saves shipped.
R14 rooftop: start near west entrance, E -> R13, release E, E -> R14.
Walk right to R9 route, or climb/tether to upper R17 route. Test returns.
R15 canal: start near upper-west entrance, E -> R2, release E, E -> R15.
Descend ledges to lower-east R16 entrance; test both directions.
E remains the only entrance trigger. Walk outside 85 pixels: cue becomes APPROACH.
Warm entrances are not elemental seals. Original Wind/relay/climb requirements remain.
Reduced Motion launchers remove rotating wind strokes; inherited fade timing remains.
A/D move; double tap runs; Space jumps; Q tether; Shift dash; J attack; F parry;
R kunai; T cycle; E interact; M map; I kit; Escape pause.
This prototype is not a final art or release approval. Never merge without creator/PM.
''')
archive=r/'build/tr01/Kaze-TR01-Alpha061-macOS-Universal.zip'
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED) as z:
 for p in sorted(out.rglob('*')):
  if p.is_file() and not any(part.startswith('playtest-profile') for part in p.parts): z.write(p,str(p.relative_to(out)))
with zipfile.ZipFile(archive) as z: assert z.testzip() is None
manifest=dict(engine='4.6.1.stable.official.14d19694e',source_base='afecef1922231081807a332c511de85c7941fec8',runtime_hashes={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in [Path('scripts/hud.gd'),Path('scripts/world_expansion.gd'),Path('scripts/room_presentation.gd')]},path=str(archive),bytes=archive.stat().st_size,sha256=hashlib.sha256(archive.read_bytes()).hexdigest(),zip_crc='PASS',tested_platform='macOS Apple M4 native and headless boot; Intel untested; Windows not exported',remote_binary_publication=False)
(r/'docs/agent_handoffs/tr01_evidence/BUILD_MANIFEST.json').write_text(json.dumps(manifest,indent=2));print(str(archive))
