"""Isolated rights-cleared exports; includes no creator reference recordings.
Reuses AUD01's payload/world/pack integrity audit with 34 expected samples.
"""
import argparse, hashlib, json, os, pathlib, struct, subprocess, zipfile
from package_aud01 import audit
ROOT=pathlib.Path(__file__).resolve().parents[1]

def main():
    p=argparse.ArgumentParser();p.add_argument('--godot',required=True);p.add_argument('--templates',required=True);p.add_argument('--deliver',required=True);a=p.parse_args()
    template=pathlib.Path(a.templates).resolve();out=ROOT/'build/aud02/exports';out.mkdir(parents=True,exist_ok=True)
    evidence=ROOT/'docs/agent_handoffs/aud02_evidence';evidence.mkdir(parents=True,exist_ok=True)
    deliver=pathlib.Path(a.deliver).resolve();deliver.mkdir(parents=True,exist_ok=True)
    presets=ROOT/'export_presets.cfg';original=presets.read_bytes();text=original.decode()
    text=text.replace('custom_template/release=""','custom_template/release="'+(template/'windows_release_x86_64.exe').as_posix()+'"',1)
    text=text.replace('[preset.1.options]','[preset.1.options]\ncustom_template/release="'+(template/'macos.zip').as_posix()+'"',1)
    env=os.environ.copy();env['APPDATA']=str(ROOT/'build/aud02/export-profile');env['LOCALAPPDATA']=env['APPDATA'];pathlib.Path(env['APPDATA']).mkdir(parents=True,exist_ok=True)
    rows=[]
    try:
        presets.write_text(text,encoding='utf-8')
        for platform,name in [('Windows Desktop','Kaze-AUD02-Windows.exe'),('macOS','Kaze-AUD02-macOS.zip')]:
            r=subprocess.run([a.godot,'--headless','--path',str(ROOT),'--log-file',str(out/(name+'.engine.log')),'--export-release',platform,str(out/name)],cwd=ROOT,env=env,capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=300)
            output=r.stdout+r.stderr;(evidence/('export-'+platform.replace(' ','-')+'.txt')).write_text(output,encoding='utf-8')
            assert r.returncode==0 and not any(e in output for e in ['SCRIPT ERROR','Parse Error','Failed to load','ERROR: Cannot export','ERROR: Export failed']),output[-3000:]
            print(platform,'export PASS',flush=True)
    finally:presets.write_bytes(original)
    win=audit((out/'Kaze-AUD02-Windows.exe').read_bytes(),34)
    with zipfile.ZipFile(out/'Kaze-AUD02-macOS.zip') as z:
        assert z.testzip() is None
        pck=next(n for n in z.namelist() if n.endswith('.pck'));mac=audit(z.read(pck),34)
        (out/'Kaze-AUD02.pck').write_bytes(z.read(pck))
        native=next(n for n in z.namelist() if '.app/Contents/MacOS/' in n and not n.endswith('/'))
        binary=z.read(native);assert binary[:4]==b'\xca\xfe\xba\xbe' and struct.unpack_from('>I',binary,4)[0]==2
    readme='''KAZE AUD02 / Alpha0.6.1 — ORIGINAL AUDIO CANDIDATE
Creator listening approval is PENDING. No soundtrack selected.
Use the supplied Play AUD02 Review launcher. It enables --test and
--audio-bank=aud02: temporary progress, no personal save loading/writing.
Normal direct launch preserves AUD01 audio and the established save identity.
A/D move; double-tap run; Space jump; J melee; F parry; E interact.
Shift dash, Q tether, R kunai, T element switch after campaign unlocks.
M map; I kit; Escape pause. Source tests/audio_playtest.gd gives seeded abilities.
12 new original CC0 effects; 10 AUD01 fallbacks/loops remain. Reference recordings
are unverified and EXCLUDED. No changes to gameplay or saves.
Windows export/runtime smoke and exported audio suites are recorded separately.
macOS cross-export is not macOS execution. No sustained60FPS or listening claim.
Unzip first. macOS build is unsigned; launcher may need chmod +x.
'''
    winzip=deliver/'Kaze-AUD02-Alpha061-Windows-Review.zip'
    with zipfile.ZipFile(winzip,'w',zipfile.ZIP_DEFLATED) as z:
        z.write(out/'Kaze-AUD02-Windows.exe','Kaze-AUD02-Windows.exe')
        z.writestr('Play AUD02 Review.bat','@echo off\r\ncd /d "%~dp0"\r\nKaze-AUD02-Windows.exe --log-file "%~dp0AUD02-review.log" -- --test --audio-bank=aud02 %*\r\n')
        z.writestr('README-AUD02.txt',readme)
    maczip=deliver/'Kaze-AUD02-Alpha061-macOS-Review.zip'
    with zipfile.ZipFile(out/'Kaze-AUD02-macOS.zip') as source,zipfile.ZipFile(maczip,'w',zipfile.ZIP_DEFLATED) as dest:
        for item in source.infolist():dest.writestr(item,source.read(item.filename))
        launcher=zipfile.ZipInfo('Play AUD02 Review.command');launcher.create_system=3;launcher.external_attr=0o100755<<16
        dest.writestr(launcher,'#!/bin/sh\ncd -- "$(dirname -- "$0")" || exit 1\nexec "./'+native+'" --log-file "$PWD/AUD02-review.log" -- --test --audio-bank=aud02 "$@"\n')
        dest.writestr('README-AUD02.txt',readme)
    for file in [winzip,maczip]:
        with zipfile.ZipFile(file) as z:assert z.testzip() is None
        rows.append(dict(filename=file.name,bytes=file.stat().st_size,sha256=hashlib.sha256(file.read_bytes()).hexdigest(),zip_crc='PASS'))
    report=dict(engine='4.6.1.stable.official.14d19694e',windows_pack=win,macos_pack=mac,macos_architectures=2,artifacts=rows,source_recordings_included=False,windows_native_smoke='pending separate test',macos_execution='NOT AVAILABLE',creator_listening='PENDING')
    (evidence/'BUILD_MANIFEST.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(rows),flush=True)

if __name__=='__main__':main()
