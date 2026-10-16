"""Package exported Windows demonstrations with isolated seeded save profiles."""
from pathlib import Path
import json,hashlib,zipfile,struct,argparse
p=argparse.ArgumentParser();p.add_argument('--source',required=True);a=p.parse_args()
r=Path(__file__).resolve().parents[1];out=r/'build/tr05/windows';exe=out/'Kaze-TR05-Windows.exe';b=exe.read_bytes()
assert b[:2]==b'MZ'
start=len(b)-12-struct.unpack_from('<Q',b,len(b)-12)[0];assert b[start:start+4]==b'GDPC'
pos=start+struct.unpack_from('<Q',b,start+32)[0];count=struct.unpack_from('<I',b,pos)[0];pos+=4;names=[]
for _ in range(count):
 n=struct.unpack_from('<I',b,pos)[0];pos+=4;names.append(b[pos:pos+n].rstrip(b'\0').decode());pos+=n+36
assert any('cinematic_transitions.gdc' in n for n in names)
assert not [n for n in names if n.removeprefix('res://').startswith(('build/','tests/','docs/','tools/','source_art/'))]
fixtures=out/'fixtures';fixtures.mkdir(exist_ok=True)
pilots=[('Canal-Automatic',13,[220,1198],[]),('Door-East',13,[1560,558],[]),('Door-West',14,[220,1098],[]),('Stair-Cinematic',14,[1450,478],[]),('Stair-Descending',17,[1680,1298],[]),('Stair-Reduced-Motion',14,[1450,478],['--tr05-reduced-motion'])]
for name,room,at,flags in pilots:
 seed=dict(version=8,checkpoint_room=room,checkpoint_position=at,double_jump=True,tether_unlocked=True,dash_unlocked=True,completed=True,guard_defeated=True,boss_defeated=True,speed_upgrade_level=0,kunai_unlocked=dict(wind=True,fire=True,electric=True),opened_kunai_gates=dict(skyworks_wind_intake=True,cistern_wind_cache=True,spire_wind_shutter=True),relay_fragments=dict(undercroft_sigil=True,terrace_west=True,terrace_fire_cache=True),expansion_flags=dict(junction_return=True),visited=[i==room for i in range(21)])
 (fixtures/(name+'.json')).write_text(json.dumps(seed),encoding='utf-8')
 # Always copy a reviewed fixture into this DEMO profile, making replays reliable.
 cmd='@echo off\r\ncd /d "%~dp0"\r\nif not exist "profiles" mkdir "profiles"\r\ncopy /y "fixtures\\'+name+'.json" "profiles\\'+name+'.json" >nul\r\nstart "" /wait "%~dp0'+exe.name+'" %* -- '+ ' '.join(flags)+' "--tr05-save=%~dp0profiles\\'+name+'.json"\r\n'
 (out/('Play-'+name+'.cmd')).write_bytes(cmd.encode())
(out/'Play-Fresh.cmd').write_bytes(('@echo off\r\ncd /d "%~dp0"\r\nif not exist "profiles" mkdir "profiles"\r\nstart "" /wait "%~dp0'+exe.name+'" %* -- "--tr05-save=%~dp0profiles\\Fresh.json"\r\n').encode())
(out/'README.txt').write_text('''KAZE TR-05 / SEAMLESS & CINEMATIC TRANSITION PROTOTYPES
Runtime source: '''+a.source+'''
Godot4.6.1 / Windows x86_64 / internal draft review, no merge.

Extract the whole ZIP, then choose:
1. Play-Canal-Automatic.cmd: hold A. Canal-left crosses without E.
2. Play-Door-East.cmd: hold D through R13's right doorway. In Bellroof Walk,
   release movement, wait a second, then hold A to return. Play-Door-West.cmd
   starts the reverse direction. Arrows show outgoing direction; arrivals face inward.
3. Play-Stair-Cinematic.cmd: press E beside the stairs. Kaze's render proxy
   moves along a short ascending flight with close-up framing. Play-Stair-Descending.cmd
   starts the reverse route. These use held authored keys, not finished gait cycles.
4. Play-Stair-Reduced-Motion.cmd: same E route with fixed camera/pose and plain fade.
F6 toggles reduced motion during play. No persistent settings/save-schema change.
Play-Fresh.cmd: unseeded campaign, separate persistent Fresh profile.

39 ordinary side endpoints are automatic. Meaningful interior doors, shortcuts,
shrines, stairs and wind-fold still use E. Gates and their earned prerequisites remain.
Door approaches need outward movement at the correct elevation; proximity alone
or holding E cannot activate a side passage. Arrival cooldown and inward rearm
protect against bounce loops. Discrete room loading remains0.65s; not streamed rooms.

Each DEMO launcher resets ONLY its own supplied fixture profile on each launch.
Fresh is kept separately and persists. Launchers never load the ordinary creator save.
Opening the EXE directly uses the historical normal save identity: use launchers to review.
Seeded abilities/progression are deliberate QA fixtures, not earned campaign proof.

A/D move; double-tap run; Space jump; E use; Q tether; Shift dash; J attack;
F parry; R kunai; T element; M map; I kit; Escape pause; F6 reduced motion.
Full authored stair/walk/outward cycles, gamepad bindings, human campaign and
sustained60FPS certification remain pending. Binary is unsigned.
''',encoding='utf-8')
manifest=dict(runtime_source=a.source,base='b950373efb5c4621d7da7e0be1506db048e3043a',engine='4.6.1.stable.official.14d19694e',pck_resources=count,binary_sha256=hashlib.sha256(b).hexdigest(),binary_bytes=len(b),forbidden_resources=[],demo_launchers=len(pilots),fresh_launchers=1)
(out/'BUILD_MANIFEST.json').write_text(json.dumps(manifest,indent=2)+'\n')
archive=out.parent/'Kaze-TR05-Windows-Demos.zip'
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED,compresslevel=9) as z:
 for f in sorted(out.rglob('*')):
  if f.is_file() and 'profiles' not in f.relative_to(out).parts: z.write(f,f.relative_to(out))
with zipfile.ZipFile(archive) as z: assert z.testzip() is None
manifest.update(zip_sha256=hashlib.sha256(archive.read_bytes()).hexdigest(),zip_bytes=archive.stat().st_size,zip_crc='PASS')
(out.parent/'windows-manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print(json.dumps(manifest,indent=2))
