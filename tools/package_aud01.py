"""Export review candidates using supplied Godot 4.6.1 templates; audit packs.

Native launchers use --test: no normal profile is loaded/saved. Export preset
custom-template paths are temporary and restored exactly in finally.
"""
import argparse, hashlib, json, pathlib, shutil, struct, subprocess, zipfile
ROOT = pathlib.Path(__file__).resolve().parents[1]
OUT = ROOT/'build/aud01/exports'
EVIDENCE = ROOT/'docs/agent_handoffs/aud01_evidence'

def audit(data):
    start = 0
    if data[:4] != b'GDPC':
        assert data[:2] == b'MZ' and data[-4:] == b'GDPC'
        start = len(data)-12-struct.unpack_from('<Q',data,len(data)-12)[0]
    assert data[start:start+4] == b'GDPC'
    version,major,minor,patch,flags = struct.unpack_from('<5I',data,start+4)
    assert version in [2,3] and (major,minor,patch)==(4,6,1) and not flags & 1
    base = struct.unpack_from('<Q',data,start+24)[0]
    if version==3 or flags & 2: base += start
    pos = start+96 if version==2 else start+struct.unpack_from('<Q',data,start+32)[0]
    count = struct.unpack_from('<I',data,pos)[0]; pos += 4
    assert 0<count<10000
    names = []; contents = {}
    for _ in range(count):
        length = struct.unpack_from('<I',data,pos)[0];pos += 4
        assert 0<length<4096
        name = data[pos:pos+length].rstrip(b'\0').decode().removeprefix('res://');pos += length
        offset,size = struct.unpack_from('<QQ',data,pos);pos += 16
        digest = data[pos:pos+16];pos += 16
        file_flags = struct.unpack_from('<I',data,pos)[0];pos += 4
        assert file_flags==0
        content = data[base+offset:base+offset+size]
        assert len(content)==size and hashlib.md5(content).digest()==digest
        assert not set(pathlib.PurePosixPath(name).parts) & {'docs','tests','tools','build','.git','.autoconverted'}
        names.append(name);contents[name]=content
    assert len(set(names))==count
    for path in (ROOT/'world').glob('*.txt'):
        assert contents.get(path.relative_to(ROOT).as_posix())==path.read_bytes()
    samples = [name for name in names if name.startswith('.godot/imported/') and '.wav-' in name and name.endswith('.sample')]
    assert len(samples)==22, samples
    assert any(name.startswith('default_bus_layout.tres') for name in names) and any('scripts/audio/audio_director.' in name for name in names)
    return dict(entries=count,imported_audio_samples=len(samples),world_data='byte-identical',forbidden_entries=[],files=names)

def main():
    p=argparse.ArgumentParser();p.add_argument('--godot',default='/Applications/Godot.app/Contents/MacOS/Godot');p.add_argument('--templates',type=pathlib.Path,required=True);args=p.parse_args()
    assert subprocess.check_output([args.godot,'--version'],text=True).strip()=='4.6.1.stable.official.14d19694e'
    templates=args.templates.resolve();assert (templates/'version.txt').read_text().strip()=='4.6.1.stable'
    OUT.mkdir(parents=True,exist_ok=True);EVIDENCE.mkdir(parents=True,exist_ok=True)
    presets=ROOT/'export_presets.cfg';original=presets.read_text()
    adjusted=original.replace('custom_template/release=""',f'custom_template/release="{templates / "windows_release_x86_64.exe"}"',1).replace('[preset.1.options]',f'[preset.1.options]\ncustom_template/release="{templates / "macos.zip"}"',1)
    try:
        presets.write_text(adjusted)
        for name,file in [('macOS','Kaze-AUD01-macOS.zip'),('Windows Desktop','Kaze-AUD01-Windows.exe')]:
            command=[args.godot,'--headless','--path',str(ROOT),'--log-file',str(OUT/(file+'.engine.log')),'--export-release',name,str(OUT/file)]
            result=subprocess.run(command,cwd=ROOT,capture_output=True,text=True,timeout=300)
            text=result.stdout+result.stderr;(EVIDENCE/('export-'+name.replace(' ','-')+'.txt')).write_text(text)
            assert not result.returncode and not any(error in text for error in ['SCRIPT ERROR','Parse Error','Failed to load','ERROR: Cannot export','ERROR: Export failed'])
    finally: presets.write_text(original)
    with zipfile.ZipFile(OUT/'Kaze-AUD01-macOS.zip') as z:
        assert z.testzip() is None
        pack=next(name for name in z.namelist() if name.endswith('.pck'));data=z.read(pack)
        (OUT/'Kaze-AUD01.pck').write_bytes(data)
        mac_audit=audit(data)
        native=next(name for name in z.namelist() if '.app/Contents/MacOS/' in name and not name.endswith('/'))
        binary=z.read(native);assert binary[:4]==b'\xca\xfe\xba\xbe' and struct.unpack_from('>I',binary,4)[0]==2
    win_audit=audit((OUT/'Kaze-AUD01-Windows.exe').read_bytes())
    folder=OUT/'playable';folder.mkdir(exist_ok=True)
    subprocess.run(['ditto','-x','-k',str(OUT/'Kaze-AUD01-macOS.zip'),str(folder)],check=True)
    native=next((next(folder.glob('*.app'))/'Contents/MacOS').iterdir())
    native.chmod(0o755)
    launcher=folder/'Play Audio Review.command'
    launcher.write_text('#!/bin/zsh\nset -eu\nAUD01_PACKAGE="${0:A:h}"\nexec "$AUD01_PACKAGE/'+str(native.relative_to(folder))+'" --log-file "$AUD01_PACKAGE/AUD01-review.log" -- --test "$@"\n');launcher.chmod(0o755)
    readme='''Kaze AUD-01 audio review, Godot 4.6.1. Candidate, creator taste approval pending.
Launch with Play Audio Review.command (Mac) or Play Audio Review.bat (Windows).
These pass --test: no personal saves are loaded or written. Progress is temporary.
A/D move, double tap runs, Space jumps, J attack, F parry, E interact.
Q tether / Shift dash / R kunai / T cycle after earning abilities in the campaign.
M map, I kit, Escape pause. Music is intentionally silent.
R0 Canal Haven -> E at east exit -> R1 Lantern Market changes canal to city bed.
E at Haven shrine plays checkpoint. Fight guard in R1 for real hit/parry/damage.
Full source seeded fixtures: tests/audio_playtest.gd with --test, --roof or --canal.
Use --audio-sfx=0.8 --audio-ambience=0.6 --audio-ui=0.8 after -- for volume.
Unsigned/not notarized. Intel Mac and Windows execution are untested.
Human listening and sustained 60 FPS remain pending. No merge authorized.
'''
    (folder/'README-AUD01.txt').write_text(readme)
    archives=[]
    mac_zip=OUT/'Kaze-AUD01-Alpha061-macOS-Review.zip'
    with zipfile.ZipFile(mac_zip,'w',zipfile.ZIP_DEFLATED) as z:
        for path in sorted(folder.rglob('*')):
            if path.is_file() and path.suffix not in ['.log']:z.write(path,str(path.relative_to(folder)))
    win_zip=OUT/'Kaze-AUD01-Alpha061-Windows-Review.zip'
    with zipfile.ZipFile(win_zip,'w',zipfile.ZIP_DEFLATED) as z:
        z.write(OUT/'Kaze-AUD01-Windows.exe','Kaze-AUD01-Windows.exe')
        z.writestr('Play Audio Review.bat','@echo off\r\ncd /d "%~dp0"\r\nKaze-AUD01-Windows.exe --log-file "%~dp0AUD01-review.log" -- --test %*\r\n')
        z.writestr('README-AUD01.txt',readme)
    for path in [mac_zip,win_zip]:
        with zipfile.ZipFile(path) as z:assert z.testzip() is None
        archives.append(dict(path=str(path),bytes=path.stat().st_size,sha256=hashlib.sha256(path.read_bytes()).hexdigest(),zip_crc='PASS'))
    runtime_paths=['scripts/player.gd','scripts/world.gd','scripts/guard.gd','scripts/storm_keeper.gd','scripts/route_extension.gd','scripts/skyworks_region.gd','scripts/world_expansion.gd','scripts/audio/audio_director.gd','default_bus_layout.tres','project.godot','export_presets.cfg']
    manifest=dict(source_sha=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),branch=subprocess.check_output(['git','branch','--show-current'],cwd=ROOT,text=True).strip(),runtime_hashes={name:hashlib.sha256((ROOT/name).read_bytes()).hexdigest() for name in runtime_paths},engine='4.6.1.stable.official.14d19694e',template_hashes={name:hashlib.sha256((templates/name).read_bytes()).hexdigest() for name in ['macos.zip','windows_release_x86_64.exe']},mac_audit=mac_audit,windows_audit=win_audit,archives=archives,mac_native_boot='pending separate smoke',windows_execution='NOT TESTED',intel_execution='NOT TESTED',remote_binary_publication=False)
    (EVIDENCE/'BUILD_MANIFEST.json').write_text(json.dumps(manifest,indent=2)+'\n')
    print(json.dumps(archives,indent=2))

if __name__=='__main__': main()
