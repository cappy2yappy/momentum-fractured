"""Build a disposable-profile Windows review ZIP from the existing export."""
from pathlib import Path
import hashlib,json,shutil,struct,zipfile
r=Path(__file__).resolve().parents[1];out=r/'build/tr04/windows'
exe=out/'Kaze-TR04-Geometry-Windows.exe';b=exe.read_bytes()
assert b[:2]==b'MZ'
start=len(b)-12-struct.unpack_from('<Q',b,len(b)-12)[0]
assert b[start:start+4]==b'GDPC'
pos=start+struct.unpack_from('<Q',b,start+32)[0];count=struct.unpack_from('<I',b,pos)[0];pos+=4;names=[]
for i in range(count):
 n=struct.unpack_from('<I',b,pos)[0];pos+=4;names.append(b[pos:pos+n].rstrip(b'\0').decode());pos+=n+36
assert not [n for n in names if n.removeprefix('res://').startswith(('build/','tests/','tools/','docs/','source_art/'))]
assert any('level_geometry' in n for n in names)
source='e7c308abd93de6f2191fbf000961d6fa1bb80721'
fixtures=out/'fixtures';fixtures.mkdir(exist_ok=True)
for name,room,at,flags in [('Canal-Left',13,[150,1198],[]),('Stair-Up',14,[1450,478],['--tr03-art-preview']),('Stair-Down',17,[1680,1298],['--tr03-art-preview']),('Depth-Door',14,[120,1098],['--tr03-art-preview','--tr03-depth-demo'])]:
 seed=dict(version=8,checkpoint_room=room,checkpoint_position=at,double_jump=True,tether_unlocked=True,dash_unlocked=True,completed=True,guard_defeated=True,boss_defeated=True,speed_upgrade_level=0,kunai_unlocked=dict(wind=True,fire=True,electric=True),opened_kunai_gates=dict(skyworks_wind_intake=True,cistern_wind_cache=True),relay_fragments=dict(undercroft_sigil=True,terrace_west=True,terrace_fire_cache=True),expansion_flags=dict(junction_return=True),visited=[i==room for i in range(21)])
 (fixtures/(name+'.json')).write_text(json.dumps(seed),encoding='utf-8')
 cmd='@echo off\r\ncd /d "%~dp0"\r\nif not exist "profiles" mkdir "profiles"\r\nif not exist "profiles\\'+name+'.json" copy /y "fixtures\\'+name+'.json" "profiles\\'+name+'.json" >nul\r\nstart "" /wait "%~dp0'+exe.name+'" -- '+ ' '.join(flags)+' "--tr03-save=%~dp0profiles\\'+name+'.json"\r\n'
 (out/('Play-'+name+'.cmd')).write_bytes(cmd.encode('utf-8'))
(out/'Play-Fresh.cmd').write_bytes(('@echo off\r\ncd /d "%~dp0"\r\nif not exist "profiles" mkdir "profiles"\r\nstart "" /wait "%~dp0'+exe.name+'" -- "--tr03-save=%~dp0profiles\\Fresh.json"\r\n').encode())
(out/'README.txt').write_text('''KAZE TR-04 / LD-02 WINDOWS GEOMETRY REVIEW CANDIDATE
Runtime source: '''+source+'''
Base PR31 c2c6b08bfb3b85ad174dcc7ef60bddf1a3a48c15. Godot4.6.1 x86_64.
Draft PR33: https://github.com/cappy2yappy/momentum-fractured/pull/33
Extract the whole ZIP. Launch Play-Canal-Left.cmd for the repaired left exit.
Walk/run left into the wall, release movement, wait, return right, then press E.
Play-Fresh.cmd starts the ordinary campaign with an isolated save.
Other launchers are deliberately seeded QA fixtures, not earned progression.
Launchers persist separate local profiles without loading the normal save.
Opening the EXE directly uses the historical normal save identity instead.
A/D move; double-tap to run; Space jump; E interact; Q tether; Shift dash;
J attack; F parry; R kunai; T element; M map; I kit; Escape pause.
ART04 stair and depth fixtures use approved single held keys, not finished cycles.
Missing walk/outward/arrival/cycle frames remain labelled fallbacks.
Momentum remains disabled by default; add --momentum-prototype only for comparison.
Native Windows scripted input, exported-PCK tests and executable boot were checked
on NVIDIA RTX4070 Laptop/OpenGL3.3. No full human campaign, gamepad or sustained FPS
certification. No topology, save schema, controller, combat or progression rewrite.
Keep the original Alpha0.5.2 builds. Do not merge or treat this as milestone acceptance.
''',encoding='utf-8')
manifest=dict(runtime_source=source,base='c2c6b08bfb3b85ad174dcc7ef60bddf1a3a48c15',engine='4.6.1.stable.official.14d19694e',resources=count,binary_sha256=hashlib.sha256(b).hexdigest(),binary_bytes=len(b))
(out/'BUILD_MANIFEST.json').write_text(json.dumps(manifest,indent=2)+'\n')
archive=out.parent/'Kaze-TR04-Geometry-Windows.zip'
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 for f in sorted(out.rglob('*')):
  if f.is_file() and 'profiles' not in f.relative_to(out).parts:z.write(f,f.relative_to(out))
with zipfile.ZipFile(archive) as z:assert z.testzip() is None
manifest.update(zip_bytes=archive.stat().st_size,zip_sha256=hashlib.sha256(archive.read_bytes()).hexdigest(),zip_crc='PASS')
(out.parent/'windows-manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print(json.dumps(manifest,indent=2))
