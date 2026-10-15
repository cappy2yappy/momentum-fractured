"""Package the ART-04 comparison for Build Shogun. Stdlib only; no personal saves."""
from pathlib import Path
import argparse,hashlib,json,shutil,stat,struct,subprocess,zipfile
p=argparse.ArgumentParser();p.add_argument('--platform',choices=['windows','macos'],required=True);p.add_argument('--input',type=Path,required=True);p.add_argument('--source-sha');a=p.parse_args()
r=Path(__file__).resolve().parents[1];source=a.source_sha or subprocess.check_output(['git','rev-parse','HEAD'],cwd=r,text=True).strip()
out=r/'build/int-tr03/packages'/a.platform;out.mkdir(parents=True,exist_ok=True)
if (out/'profiles').exists():raise SystemExit('Refusing to package a directory containing playtest profiles; use a fresh output directory.')
if a.platform=='windows':
 exe=out/'Kaze-INT-TR03-ART04.exe';shutil.copy2(a.input,exe);binary=exe
else:
 subprocess.run(['ditto','-x','-k',str(a.input.resolve()),str(out)],check=True)
 app=next(out.glob('*.app'));binary=next((app/'Contents/MacOS').iterdir());binary.chmod(binary.stat().st_mode|stat.S_IXUSR|stat.S_IXGRP|stat.S_IXOTH)
fixtures={'fresh':None,'passage':(15,[1950,1118]),'stair-up':(14,[1390,478]),'stair-down':(17,[1640,1298]),'depth':(14,[120,1098]),'reverse-depth':(13,[1680,558]),'special':(20,[540,518]),'structure14':(14,[950,1298]),'structure15':(15,[1600,1298])}
comparisons={'original':['--tr03-original'],'refined':[],'art-preview':['--tr03-art-preview'],'reduced':['--tr03-art-preview','--tr03-reduced-motion'],'plain':['--tr03-art-preview','--tr03-plain']}
def seed(fixture):
 room,at=fixture
 return dict(version=8,checkpoint_room=room,checkpoint_position=at,double_jump=True,tether_unlocked=True,dash_unlocked=True,completed=True,guard_defeated=True,boss_defeated=True,speed_upgrade_level=0,kunai_unlocked=dict(wind=True,fire=True,electric=True),selected_kunai='wind',opened_kunai_gates=dict(skyworks_wind_intake=True,cistern_wind_cache=True),relay_fragments=dict(undercroft_sigil=True,terrace_west=True,terrace_fire_cache=True),expansion_flags=dict(junction_return=True),visited=[i==room for i in range(21)])
for pilot,fixture in fixtures.items():
 for mode,flags in comparisons.items():
  args=flags+(['--tr03-depth-demo'] if pilot in ['depth','reverse-depth'] else [])
  relative='profiles/'+pilot+'-'+mode
  fixture_json=json.dumps(seed(fixture),separators=(',',':')) if fixture else None
  if a.platform=='macos':
   # No interpreter dependency; each explicit profile/save remains local to package.
   script='#!/bin/zsh\nset -eu\nPACKAGE_DIR="${0:A:h}"\nPROFILE_DIR="$PACKAGE_DIR/'+relative+'"\nmkdir -p "$PROFILE_DIR"\nexport HOME="$PROFILE_DIR"\nSAVE_FILE="$PROFILE_DIR/comparison.json"\n'
   if fixture_json:script+='if [[ ! -f "$SAVE_FILE" ]]; then\ncat > "$SAVE_FILE" <<\'KAZE_FIXTURE\'\n'+fixture_json+'\nKAZE_FIXTURE\nfi\n'
   script+='exec "$PACKAGE_DIR/'+str(binary.relative_to(out))+'" "$@" -- "--tr03-save=$SAVE_FILE" '+' '.join(args)+'\n'
   launcher=out/f'Play-{pilot}-{mode}.command';launcher.write_text(script);launcher.chmod(0o755)
  else:
   # PowerShell ArgumentList is joined by Windows; quote the whole path-bearing arg.
   script="$ErrorActionPreference='Stop'\n$profilePath=Join-Path $PSScriptRoot '"+relative+"'\nNew-Item -ItemType Directory -Force -Path $profilePath | Out-Null\n$env:APPDATA=$profilePath\n$savePath=Join-Path $profilePath 'comparison.json'\n"
   if fixture_json:script+="if (-not (Test-Path -LiteralPath $savePath)) { [IO.File]::WriteAllText($savePath,'"+fixture_json+"',(New-Object Text.UTF8Encoding $false)) }\n"
   script+="$arguments=@('--',('\"--tr03-save='+$savePath+'\"'))\n"
   for flag in args:script+="$arguments+='"+flag+"'\n"
   script+="$process=Start-Process -FilePath (Join-Path $PSScriptRoot 'Kaze-INT-TR03-ART04.exe') -ArgumentList $arguments -Wait -PassThru\nexit $process.ExitCode\n"
   ps=out/f'launch-{pilot}-{mode}.ps1';ps.write_text(script)
   (out/f'Play-{pilot}-{mode}.cmd').write_text('@echo off\r\npowershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0'+ps.name+'"\r\n')
readme=f'''KAZE — INT-TR03 / ART-04 production-asset integration REVIEW COMPARISON
Source: {source}
PR27 foundation: c2c002267c58e991966c0eebf7e098c6e7fff769
ART04 runtime assets: a6b76b9938825307bdcd4efb687c7198ea0d8681
Godot4.6.1. Existing executable product metadata/save identity intentionally retained.
No mainline merge, public production release or final animation acceptance.

Extract this ZIP before playing. START Play-stair-up-art-preview, then compare
Play-stair-up-refined and Play-stair-up-original. On macOS use .command files;
on Windows use .cmd. Launchers create profiles/<pilot>-<comparison>/comparison.json
and pass an explicit absolute --tr03-save. Normal creator saves are not loaded.
Directly opening the EXE/.app DOES use the normal historical save identity;
back up existing saves before deliberately testing that path.
No profiles or personal save data are included in this archive.

MODES: original=TR02; refined=existing TR03 placeholders; art-preview=new ART04
held keys and scoped architecture; reduced=static ART04 held key; plain=fade/fallback.
The four drawings are SINGLE KEYS, not completed motion cycles. Real walk art,
outward/front-quarter/reorientation and opposite-facing arrivals are absent.
They use labelled approved-idle fallbacks, never reversed/mirrored rear art.
Approved running/physics, loader0.65s/swap tick20, gates, topology and saves remain.

PILOTS: stair-up R14->17; stair-down R17->14; depth R14->13; reverse-depth R13->14;
passage R15->16 (wait1s then holdD, double-tapD to run); special R20 wind-fold;
structure14/15 view supports; fresh starts unseeded Haven campaign.
All targeted pilots seed abilities/progression ON FIRST LAUNCH ONLY as QA fixtures,
not earned playthroughs. Each comparison keeps a separate persistent test save.
Stair/door uses E; normal reversible gate rules still apply. Depth is opt-in.
Windows/macOS packages share exactly these fixture definitions and switches.

A/D/arrows move; double-tap direction runs; Space/W/Up jump; Q tether; Shift dash;
J/left mouse attack; F/K/right mouse parry; R kunai; T element; E use; M map;
I kit; Escape pause. Physical gamepad review remains pending.
macOS candidate is unsigned/not notarized; approve this specific local app per
Mac policy if blocked. Intel runtime may remain untested. Windows native smoke
and launcher evidence must be established by Build Shogun; cross-export alone
is not Windows startup certification. Consult PM report for actual QA boundaries.
'''
(out/'README.txt').write_text(readme);(out/'SOURCE.txt').write_text(source+'\n')
# Audit the exported PCK table independently of source directory contents.
if a.platform=='windows':
 b=binary.read_bytes();pe=struct.unpack_from('<I',b,0x3c)[0];assert b[:2]==b'MZ' and b[pe:pe+4]==b'PE\0\0' and struct.unpack_from('<H',b,pe+4)[0]==0x8664
 size=struct.unpack_from('<Q',b,len(b)-12)[0];start=len(b)-12-size
else:b=next((app/'Contents/Resources').glob('*.pck')).read_bytes();start=0
assert b[start:start+4]==b'GDPC' and struct.unpack_from('<I',b,start+4)[0]==3
pos=start+struct.unpack_from('<Q',b,start+32)[0];count=struct.unpack_from('<I',b,pos)[0];pos+=4;names=[]
for _ in range(count):
 length=struct.unpack_from('<I',b,pos)[0];pos+=4;names.append(b[pos:pos+length].rstrip(b'\0').decode());pos+=length+36
forbidden=[name for name in names if name.removeprefix('res://').startswith(('build/','tests/','docs/','tools/','source_art/'))]
assert not forbidden,forbidden
assert any('ART04_key_poses' in name for name in names)
manifest=dict(source_sha=source,art_sha='a6b76b9938825307bdcd4efb687c7198ea0d8681',platform=a.platform,engine='4.6.1.stable.official.14d19694e',resource_count=count,excluded_resources=forbidden,launchers=len(fixtures)*len(comparisons),binary_sha256=hashlib.sha256(binary.read_bytes()).hexdigest(),binary_bytes=binary.stat().st_size)
(out/'BUILD_MANIFEST.json').write_text(json.dumps(manifest,indent=2)+'\n')
archive=out.parent/('Kaze-INT-TR03-ART04-'+('Windows' if a.platform=='windows' else 'macOS-Universal')+'.zip')
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 for f in sorted(out.rglob('*')):
  if f.is_file():z.write(f,str(f.relative_to(out)))
with zipfile.ZipFile(archive) as z:assert z.testzip() is None
manifest.update(zip=str(archive),zip_bytes=archive.stat().st_size,zip_sha256=hashlib.sha256(archive.read_bytes()).hexdigest(),zip_crc='PASS')
(out.parent/(a.platform+'-manifest.json')).write_text(json.dumps(manifest,indent=2)+'\n');print(json.dumps(manifest,indent=2))
