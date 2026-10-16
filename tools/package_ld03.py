"""Package the LD03 service-walk review with isolated, explicit fixture saves."""
from pathlib import Path
import argparse,hashlib,json,shutil,struct,zipfile,subprocess
r=Path(__file__).resolve().parents[1];out=r/'build/ld03/windows'
exe=out/'Kaze-LD03-Intentional-Space-Windows.exe';b=exe.read_bytes()
assert b[:2]==b'MZ'
start=len(b)-12-struct.unpack_from('<Q',b,len(b)-12)[0]
assert b[start:start+4]==b'GDPC'
pos=start+struct.unpack_from('<Q',b,start+32)[0];count=struct.unpack_from('<I',b,pos)[0];pos+=4;names=[]
for i in range(count):
 n=struct.unpack_from('<I',b,pos)[0];pos+=4;names.append(b[pos:pos+n].rstrip(b'\0').decode());pos+=n+36
assert not [n for n in names if n.removeprefix('res://').startswith(('build/','tests/','tools/','docs/','source_art/'))]
assert any('bellroof_walk' in n for n in names)
p=argparse.ArgumentParser();p.add_argument('--source');a=p.parse_args()
source=a.source or subprocess.check_output(['git','rev-parse','HEAD'],cwd=r,text=True).strip()
fixtures=out/'fixtures';fixtures.mkdir(exist_ok=True)
for name,room,at,flags in [('Lower-West',14,[350,1298],['--tr03-art-preview']),('Lower-Court',14,[1300,1218],['--tr03-art-preview']),('East-Recovery',14,[2480,1298],['--tr03-art-preview']),('Roof-Route',14,[120,1098],['--tr03-art-preview']),('Old-Save-Staging',14,[1300,1298],['--tr03-art-preview'])]:
 seed=dict(version=8,checkpoint_room=room,checkpoint_position=at,double_jump=True,tether_unlocked=True,dash_unlocked=True,completed=True,guard_defeated=True,boss_defeated=True,speed_upgrade_level=0,kunai_unlocked=dict(wind=True,fire=True,electric=True),opened_kunai_gates=dict(skyworks_wind_intake=True,cistern_wind_cache=True),relay_fragments=dict(undercroft_sigil=True,terrace_west=True,terrace_fire_cache=True),expansion_flags=dict(junction_return=True),visited=[i==room for i in range(21)])
 (fixtures/(name+'.json')).write_text(json.dumps(seed),encoding='utf-8')
 cmd='@echo off\r\ncd /d "%~dp0"\r\nif not exist "profiles" mkdir "profiles"\r\nif not exist "profiles\\'+name+'.json" copy /y "fixtures\\'+name+'.json" "profiles\\'+name+'.json" >nul\r\nstart "" /wait "%~dp0'+exe.name+'" -- '+ ' '.join(flags)+' "--tr03-save=%~dp0profiles\\'+name+'.json"\r\n'
 (out/('Play-'+name+'.cmd')).write_bytes(cmd.encode('utf-8'))
(out/'Play-Fresh.cmd').write_bytes(('@echo off\r\ncd /d "%~dp0"\r\nif not exist "profiles" mkdir "profiles"\r\nstart "" /wait "%~dp0'+exe.name+'" -- "--tr03-save=%~dp0profiles\\Fresh.json"\r\n').encode())
(out/'README.txt').write_text("""KAZE LD03 - INTENTIONAL PLAYABLE SPACE - WINDOWS REVIEW
Source: """+source+"""
Game implementation:1dc714e2249cf39ada9fdcc5cd2225bdda5c5cc0
PR33 baseline:1835fcca272fd6a925b3d8ad4834fb225a6caef6. Godot4.6.1 x86_64.
Draft review:https://github.com/cappy2yappy/momentum-fractured/pull/37
Extract everything, then open the windows folder if delivered as an Actions artifact.
Start Play-Lower-West.cmd. Explore the masonry supports, find the existing
bellkeeper log in the lower court, and use west/central/east steps to regain roofs.
The original upper route, grapple anchors and all3 exits remain intact.
Play-Lower-Court.cmd starts at the optional log; Play-East-Recovery.cmd at the
far recovery end; Play-Roof-Route.cmd compares the established route.
Play-Old-Save-Staging.cmd demonstrates an old lower-floor position safely staged
above the new log plinth. Only blocked R14 feet move; save flags/schema stay intact.
Play-Fresh.cmd starts the ordinary campaign using an isolated save.
All other launchers are deliberately seeded QA fixtures, not earned progression.
Each launcher keeps a separate profiles/*.json and avoids your normal save.
Opening EXE directly uses the existing historical normal save identity instead.
A/D move; double-tap direction runs; Space jump; E use; Q tether; Shift dash;
J attack; F parry; R kunai; T element; M map; I kit; Escape pause.
No optional Stride or momentum bonus is needed. Momentum stays disabled.
ART04 is still held-key preview, not completed animation cycles. Existing atlas
materials are reused; authored final environment art remains a follow-up.
Native automated tests are fixture checks, not a full human campaign or FPS proof.
This is a review candidate. Do not treat it as milestone acceptance or merge it.
""",encoding='utf-8')
manifest=dict(runtime_source=source,base='1835fcca272fd6a925b3d8ad4834fb225a6caef6',engine='4.6.1.stable.official.14d19694e',resources=count,binary_sha256=hashlib.sha256(b).hexdigest(),binary_bytes=len(b))
(out/'BUILD_MANIFEST.json').write_text(json.dumps(manifest,indent=2)+'\n')
archive=out.parent/'Kaze-LD03-Intentional-Space-Windows.zip'
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 for f in sorted(out.rglob('*')):
  if f.is_file() and 'profiles' not in f.relative_to(out).parts:z.write(f,f.relative_to(out))
with zipfile.ZipFile(archive) as z:assert z.testzip() is None
manifest.update(zip_bytes=archive.stat().st_size,zip_sha256=hashlib.sha256(archive.read_bytes()).hexdigest(),zip_crc='PASS')
(out.parent/'windows-manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print(json.dumps(manifest,indent=2))
