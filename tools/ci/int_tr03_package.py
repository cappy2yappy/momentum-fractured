"""Reuse exact source recipe; add bounded Windows QA options and final CI manifests."""
import argparse,hashlib,json,os,pathlib,shutil,subprocess,sys,zipfile
from package import audit_pack
p=argparse.ArgumentParser();p.add_argument('--platform',choices=['windows','macos'],required=True);p.add_argument('--artifact',type=pathlib.Path,required=True);a=p.parse_args()
root=pathlib.Path(os.environ['CI_SOURCE_ROOT']).resolve();folder=a.artifact.resolve();m=json.loads((folder/'BUILD_MANIFEST.json').read_text());sha=os.environ['SOURCE_SHA'];assert m['source_sha']==sha
original=folder/m['zip']['name'];assert hashlib.sha256(original.read_bytes()).hexdigest()==m['zip']['sha256']
recipe=root/'tools/package_int_tr03_art04.py'
if a.platform=='windows':
    scratch=root/'build/ci/comparison-input';scratch.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(original) as z:
        name=next(n for n in z.namelist() if n.endswith('.exe'));raw=scratch/'game.exe';raw.write_bytes(z.read(name))
else:raw=original
subprocess.run([sys.executable,str(recipe),'--platform',a.platform,'--input',str(raw),'--source-sha',sha],cwd=root,check=True)
staging=root/'build/int-tr03/packages'/a.platform
assert not (staging/'profiles').exists()
if a.platform=='windows':
    for ps in staging.glob('launch-*.ps1'):
        s=ps.read_text();s="param([switch]$Headless,[int]$QuitAfter=0,[string]$LogFile='', [string]$ValidationScript='')\n"+s
        s=s.replace("$arguments=@('--',", "$engineArgs=@()\nif ($Headless) { $engineArgs+='--headless' }\nif ($QuitAfter -gt 0) { $engineArgs+=@('--quit-after',[string]$QuitAfter) }\nif ($LogFile) { $engineArgs+=@('--log-file',('\"'+$LogFile+'\"')) }\nif ($ValidationScript) { $engineArgs+=@('--script',('\"'+$ValidationScript+'\"')) }\n$arguments=$engineArgs+@('--',")
        ps.write_text(s)
    for cmd in staging.glob('Play-*.cmd'):cmd.write_text(cmd.read_text().rstrip()+ ' %*\r\n')
archive=folder/f'Kaze-INT-TR03-ART04-{m["target"]}-{sha[:8]}.zip'
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED) as z:
    for f in sorted(staging.rglob('*')):
        if f.is_file():z.write(f,f.relative_to(staging).as_posix())
with zipfile.ZipFile(archive) as z:
    assert z.testzip() is None
    names=z.namelist();assert len([n for n in names if n.startswith('Play-')])==45
    assert not any('profiles/' in n or n.endswith('.log') for n in names)
    if a.platform=='windows':pack=z.read('Kaze-INT-TR03-ART04.exe')
    else:pack=z.read(next(n for n in names if n.endswith('.pck')))
    audit=audit_pack(pack);assert any('ART04_key_poses' in n for n in audit['entries'])
    members=[dict(path=i.filename,size=i.file_size,sha256=hashlib.sha256(z.read(i)).hexdigest()) for i in z.infolist()]
m.update(feature_set='INT-TR03 / ART04 review comparison; four held keys, not animation cycles',comparison_modes=['original','refined','art-preview','reduced','plain'],pilot_count=9,launcher_count=45,package_recipe_sha256=hashlib.sha256(recipe.read_bytes()).hexdigest(),pack_audit=dict(entry_count=audit['entry_count'],world_data_verified=True,art04_present=True,forbidden_entries=[]),members=members,zip=dict(name=archive.name,size=archive.stat().st_size,sha256=hashlib.sha256(archive.read_bytes()).hexdigest()),windows_launcher_qa_options=a.platform=='windows')
(folder/'BUILD_MANIFEST.json').write_text(json.dumps(m,indent=2));original.unlink();print(json.dumps(m['zip']))
