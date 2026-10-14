"""Local Windows comparison package and original captured-frame previews."""
from pathlib import Path
import hashlib,json,shutil,sys,zipfile,subprocess
r=Path(__file__).resolve().parents[1];sys.path.insert(0,str(r/'build/tr02/python-lib'))
from PIL import Image,ImageDraw
out=r/'build/tr02/playable';out.mkdir(parents=True,exist_ok=True)
runtime_sha=sys.argv[1] if len(sys.argv)>1 else subprocess.check_output(['git','rev-parse','HEAD'],cwd=r,text=True).strip()
shutil.copy2(r/'build/tr02/windows/Kaze-TR02.exe',out/'Kaze-TR02.exe')
launcher=r'''param([ValidateSet('fresh','walk','stair','special')][string]$Pilot='walk',[ValidateSet('plain','graphic','reduced')][string]$Treatment='graphic',[switch]$Headless,[int]$QuitAfter=0)
$trRoot=$PSScriptRoot
$trProfile=Join-Path $trRoot ('profiles/'+$Pilot+'-'+$Treatment)
New-Item -ItemType Directory -Force $trProfile | Out-Null
$env:APPDATA=$trProfile
$trSaveDir=Join-Path $trProfile 'Godot/app_userdata/Kaze - Silent District Alpha 0.5.0'
New-Item -ItemType Directory -Force $trSaveDir | Out-Null
$trSave=Join-Path $trSaveDir 'silent_district_alpha_v3.json'
if ($Pilot -ne 'fresh') {
 if (-not (Test-Path -LiteralPath $trSave)) {
  $trRoom=@{walk=15;stair=14;special=20}[$Pilot]
  $trPosition=@{walk=@(1950,1118);stair=@(1390,478);special=@(540,518)}[$Pilot]
  $trFixture=@{version=8;checkpoint_room=$trRoom;checkpoint_position=$trPosition;double_jump=$true;tether_unlocked=$true;dash_unlocked=$true;completed=$true;guard_defeated=$true;boss_defeated=$true;speed_upgrade_level=0;kunai_unlocked=@{wind=$true;fire=$true;electric=$true};selected_kunai='wind';opened_kunai_gates=@{skyworks_wind_intake=$true;cistern_wind_cache=$true};relay_fragments=@{undercroft_sigil=$true;terrace_west=$true;terrace_fire_cache=$true};expansion_flags=@{junction_return=$true};visited=@((0..20 | ForEach-Object {$_ -eq $trRoom}))}
  $trJson=$trFixture | ConvertTo-Json -Depth 8
  [System.IO.File]::WriteAllText($trSave,$trJson,(New-Object System.Text.UTF8Encoding $false))
 }
}
$trArguments=@()
if ($Headless) {$trArguments+='--headless'}
if ($QuitAfter -gt 0) {$trArguments+=@('--quit-after',[string]$QuitAfter)}
$trArguments+='--'
if ($Treatment -eq 'plain') {$trArguments+='--tr02-plain'}
if ($Treatment -eq 'reduced') {$trArguments+='--tr02-reduced-motion'}
$trArguments+=('--tr02-save="'+$trSave+'"')
$trProcessOptions=@{FilePath=(Join-Path $trRoot 'Kaze-TR02.exe');Wait=$true;PassThru=$true}
if ($trArguments.Count -gt 0) {$trProcessOptions.ArgumentList=$trArguments}
if ($Headless) {$trProcessOptions.WindowStyle='Hidden'}
$trProcess=Start-Process @trProcessOptions
exit $trProcess.ExitCode
'''
(out/'launch.ps1').write_text(launcher,encoding='utf-8')
for pilot in ['fresh','walk','stair','special']:
 for treatment in (['graphic'] if pilot=='fresh' else ['plain','graphic','reduced']):
  (out/f'Play-{pilot}-{treatment}.cmd').write_text('@echo off\npowershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0launch.ps1" -Pilot '+pilot+' -Treatment '+treatment+'\n',encoding='utf-8')
(out/'README.txt').write_text('''KAZE TR-02-0061 - review prototype, Godot4.6.1, Windows x86_64.
Runtime source commit: RUNTIME_SHA (tree verified against published implementation).
Unzip before playing. Use included Play-*.cmd files, not the executable directly.
launch.ps1 is readable: it sets APPDATA to profiles/<pilot>-<treatment> beside this package,
then starts this game with an explicit --tr02-save absolute path. Seeded fixtures are QA progress, not earned campaign saves.
No personal saves included; default creator APPDATA is never used by these launchers.
Each comparison has its own profile. Play-fresh-graphic starts an unseeded campaign.
Stride tier starts0 and optional momentum remains disabled by default.
Walk: start R15 just left of culvert. Hold D to cross automatically into R16.
Wait one second after load/arrival for the safety cooldown before crossing.
For reverse: move right at least96px inside R16 first, wait a beat, then walk left across the opening.
Stair: start near R14 upper service stairwell. Press/release E to reach R17; use E to return.
Special: start R20 beside the unlocked junction Wind-fold. E goes to R13; E returns.
Special fixture deliberately seeds junction switch/regional flags; fresh progression is unchanged.
Plain=fade; graphic=original indigo/rose wind-cloth wipe; reduced=static badge/fade, no camera accent.
Try all three walk launchers, then stairs/special. Camera normal1280x720 zoom1.0.
A/D move; double-tap run; Space jump; Q held tether; Shift dash; J attack; F parry;
R kunai; T element; E interact; M atlas; I kit; Escape pause.
The culvert uses Archive restoration in BOTH directions. At locked gates, no flags are granted.
Discrete room loader keeps0.65s transition; horizontal carry applies only to walk-through.
Vertical velocity and rope/dash transients reset for safe landing. No seamless streaming claim.
Signed/notarized production release and global rollout are not approved. PM/creator review pending.
'''.replace('RUNTIME_SHA',runtime_sha),encoding='utf-8')
archive=r/'build/tr02/Kaze-TR02-Mixed-Transitions-Windows.zip'
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED) as z:
 for p in out.iterdir():
  if p.is_file(): z.write(p,p.name)
with zipfile.ZipFile(archive) as z: assert z.testzip() is None
capture=r/'build/tr02/capture'
for pilot in ['walk','stair','special']:
 frames=[]
 files=sorted((capture/('graphic_'+pilot)).glob('frame_*.png'))
 for i,p in enumerate(files):
  canvas=Image.new('RGB',(1260,270),'#161525');draw=ImageDraw.Draw(canvas)
  for j,mode in enumerate(['plain','graphic','reduced']):
   src=Image.open(capture/(mode+'_'+pilot)/p.name).convert('RGB');src.thumbnail((420,237))
   canvas.paste(src,(j*420,30));draw.text((j*420+10,8),f'{pilot.upper()} - {mode.upper()} (live scripted input)',fill='white')
  frames.append(canvas.quantize(colors=128))
 frames[0].save(r/f'build/tr02/TR02-{pilot}-Comparison.gif',save_all=True,append_images=frames[1:],duration=33,loop=0,optimize=False)
manifest={'runtime_sha':runtime_sha,'engine':'4.6.1.stable.official.14d19694e','windows_zip':archive.name,'bytes':archive.stat().st_size,'sha256':hashlib.sha256(archive.read_bytes()).hexdigest(),'exe_sha256':hashlib.sha256((out/'Kaze-TR02.exe').read_bytes()).hexdigest(),'zip_crc':'PASS','macOS':'not exported - template unavailable','remote_binary_release':False}
(r/'build/tr02/build_manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
print(json.dumps(manifest,indent=2))
