"""Package an isolated Windows comparison; capture evidence is scripted, not human QA."""
from pathlib import Path
import hashlib,json,shutil,subprocess,zipfile
from PIL import Image,ImageDraw
r=Path(__file__).resolve().parents[1];out=r/'build/tr03/playable';out.mkdir(parents=True,exist_ok=True)
source_sha=subprocess.check_output(['git','rev-parse','a2b0052'],cwd=r,text=True).strip()
source_remote='3c57ec1b57d0b02ecb9649bfb0b5795f74d0ee70'
exe=r/'build/tr03/windows/Kaze-TR03-Embodied-Transitions.exe';shutil.copy2(exe,out/exe.name)
launcher=r'''param([ValidateSet('fresh','passage','stair','depth','special','structure')][string]$Pilot='stair',[ValidateSet('original','refined','reduced','plain')][string]$Comparison='refined')
$trRoot=$PSScriptRoot
$trProfile=Join-Path $trRoot ('profiles/'+$Pilot+'-'+$Comparison)
New-Item -ItemType Directory -Force $trProfile | Out-Null
$env:APPDATA=$trProfile
$trSave=Join-Path $trProfile 'tr03_comparison_save.json'
if ($Pilot -ne 'fresh' -and -not (Test-Path -LiteralPath $trSave)) {
 $trRoom=@{passage=15;stair=14;depth=14;special=20;structure=15}[$Pilot]
 $trPosition=@{passage=@(1950,1118);stair=@(1390,478);depth=@(120,1098);special=@(540,518);structure=@(1600,1298)}[$Pilot]
 $trFixture=@{version=8;checkpoint_room=$trRoom;checkpoint_position=$trPosition;double_jump=$true;tether_unlocked=$true;dash_unlocked=$true;completed=$true;guard_defeated=$true;boss_defeated=$true;speed_upgrade_level=0;kunai_unlocked=@{wind=$true;fire=$true;electric=$true};selected_kunai='wind';opened_kunai_gates=@{skyworks_wind_intake=$true;cistern_wind_cache=$true};relay_fragments=@{undercroft_sigil=$true;terrace_west=$true;terrace_fire_cache=$true};expansion_flags=@{junction_return=$true};visited=@((0..20 | ForEach-Object {$_ -eq $trRoom}))}
 [System.IO.File]::WriteAllText($trSave,($trFixture | ConvertTo-Json -Depth 8),(New-Object System.Text.UTF8Encoding $false))
}
$trArgs=@('--',('--tr03-save="'+$trSave+'"'))
if ($Comparison -eq 'original') {$trArgs+='--tr03-original'}
if ($Comparison -eq 'reduced') {$trArgs+='--tr03-reduced-motion'}
if ($Comparison -eq 'plain') {$trArgs+='--tr03-plain'}
if ($Pilot -eq 'depth') {$trArgs+='--tr03-depth-demo'}
$trProcess=Start-Process -FilePath (Join-Path $trRoot 'Kaze-TR03-Embodied-Transitions.exe') -ArgumentList $trArgs -Wait -PassThru
exit $trProcess.ExitCode
'''
(out/'launch.ps1').write_text(launcher)
for pilot in ['fresh','passage','stair','depth','special','structure']:
    for mode in (['refined'] if pilot=='fresh' else ['original','refined','reduced','plain']):
        (out/f'Play-{pilot}-{mode}.cmd').write_text('@echo off\npowershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0launch.ps1" -Pilot '+pilot+' -Comparison '+mode+'\n')
(out/'README.txt').write_text(f'''KAZE TR-03 LANE A - Alpha0.6.1 comparison prototype, NOT a completed release.
Official Godot4.6.1 / Windows x86_64. Extract ZIP before launching.
Export source: {source_sha}
Matching published implementation tree: {source_remote}
TR-02 base: e9a2d1ab0537f3f903c543b080451b3556961179 (PR16).

START WITH Play-stair-refined.cmd and compare Play-stair-original.cmd.
Each launcher creates its own profiles/<pilot>-<comparison> save directory beside
this package. It sets APPDATA and passes an explicit --tr03-save absolute file.
Your normal profile is not used. Direct EXE launch does use the normal profile.
Targeted pilots seed progress/abilities once as a SCRIPTED QA FIXTURE, not earned
campaign progress. Play-fresh-refined.cmd starts an unseeded comparison campaign.
Speed tier starts0; optional momentum remains disabled. Default save identity and
version8 schema are unchanged. No personal saves or credentials are included.

PILOTS
passage: R15 culvert toR16. Wait1 second, then holdD to walk or double-tapD to run.
For reverse, first move96px right insideR16 and wait, then walk left through.
stair: R14 upper service stairwell. Press/releaseE to enterR17; E returns.
depth: opt-in existing R14/R13 connection. PressE to review inward entry staging.
special: R20/R13 wind-fold. E keeps TR-02's exceptional graphic and requirements.
structure: R15 retaining piers. Compare original/refined; no new colliders.

COMPARISONS
original = TR-02 presentation, no new dressing/proxy (--tr03-original).
refined = scoped TR-03 staging with visibly labeled missing poses (default).
reduced = static pose/fade, no new translation/cycling (--tr03-reduced-motion).
plain = fallback fade without staging (--tr03-plain).
Depth demonstration additionally requires --tr03-depth-demo. No link is added.
--tr03-no-dressing disables only visual backing; simulation remains identical.

These are short local entry/exit contacts within the existing0.65s loader.
Not seamless streaming or an entire staircase compressed into a short wipe.
Approved run frames are reused; walk uses an idle placeholder. Separate walk,
rear/turn and stair-up/down poses await art approval. No unapproved art imported.
Depth proxy is an explicit quarter/depth-axis placeholder, not an authored back.

A/D/arrows move; double-tap direction runs; Space/W/Up jumps; Q tether;
Shift dash; J/left-mouse attack; F/K/right-mouse parry; R Kunai; T element;
E use; M atlas; I kit; Escape pause. Keyboard mappings are inherited unchanged.
Baseline has no built-in gamepad interaction binding; hardware testing pending.

Linux source/headless and native llvmpipe captures passed. Windows cross-export
succeeded; this Linux environment cannot claim native Windows launch or launcher
execution. macOS export not part of this Lane A delivery. Full human playtest,
finished character animations, and sustained60FPS certification remain pending.
Binary metadata retains the protected INT-01 version/product strings; this README
and filename identify this isolated TR-03 prototype. No main/integration merge.
''')
archive=r/'build/tr03/Kaze-TR03-Embodied-Transitions-Windows.zip'
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
    for f in out.iterdir():
        if f.is_file():z.write(f,f.name)
with zipfile.ZipFile(archive) as z:assert z.testzip() is None
manifest={'export_source_local':source_sha,'export_source_remote':source_remote,'engine':'4.6.1.stable.official.14d19694e','zip':archive.name,'zip_bytes':archive.stat().st_size,'zip_sha256':hashlib.sha256(archive.read_bytes()).hexdigest(),'exe_sha256':hashlib.sha256(exe.read_bytes()).hexdigest(),'zip_crc':'PASS','Windows_native_launch':'not run - Linux host; no Wine','macOS':'not exported','captured_fixture_runtime':'a2b0052 (scripted input/seeded progress, not human playtest)'}
(r/'build/tr03/BUILD_MANIFEST.json').write_text(json.dumps(manifest,indent=2)+'\n')
capture=r/'build/tr03/capture';review=r/'docs/agent_handoffs/tr03_evidence';review.mkdir(parents=True,exist_ok=True)
for name in ['refined_stair_up_staging','refined_depth_staging','structure_R14_original','structure_R14_refined','structure_R15_original','structure_R15_refined']:
    im=Image.open(capture/(name+'.png')).convert('RGB');assert im.size==(1280,720);im.save(review/(name+'.jpg'),quality=82,optimize=True)
for label,pilot in [('passage','run'),('stair','stair_up'),('depth','depth')]:
    frames=[]
    for source in sorted((capture/('original_'+pilot)).glob('frame_*.png'))[::2]:
        panel=Image.new('RGB',(768,168),'#151521');draw=ImageDraw.Draw(panel)
        for index,mode in enumerate(['original','refined','reduced']):
            image=Image.open(capture/(mode+'_'+pilot)/source.name).convert('RGB').resize((256,144),Image.Resampling.LANCZOS)
            panel.paste(image,(index*256,24));draw.text((index*256+6,6),f'{mode.upper()} / SCRIPTED FIXTURE',fill='white')
        frames.append(panel.quantize(colors=48,dither=Image.Dither.NONE))
    frames[0].save(review/f'TR03-{label}-comparison.gif',save_all=True,append_images=frames[1:],duration=100,loop=0,optimize=True)
print(json.dumps(manifest,indent=2))
