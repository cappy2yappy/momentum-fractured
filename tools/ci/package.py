"""Cross-export, audit actual PCK entries and ZIP CRC, then write source manifests."""
import argparse, datetime, hashlib, io, json, os, pathlib, struct, subprocess, zipfile
from qa import hard_errors
ROOT = pathlib.Path(os.environ.get('CI_SOURCE_ROOT', pathlib.Path(__file__).resolve().parents[2])).resolve()
OUT = ROOT / 'build/ci'
MAGIC = b'GDPC'
def audit_pack(data):
    start = 0
    if data[:4] != MAGIC:
        assert data[:2] == b'MZ' and data[-4:] == MAGIC, 'Missing embedded PCK trailer'
        size = struct.unpack_from('<Q', data, len(data)-12)[0]
        start = len(data)-12-size
    assert data[start:start+4] == MAGIC, 'Missing PCK header'
    version, major, minor, patch, flags = struct.unpack_from('<5I', data, start+4)
    assert version in (2,3) and (major,minor,patch)==(4,6,1) and flags & 1 == 0
    base = struct.unpack_from('<Q',data,start+24)[0]
    if version == 3 or flags & 2: base += start
    pos = start+96 if version==2 else start+struct.unpack_from('<Q',data,start+32)[0]
    count = struct.unpack_from('<I',data,pos)[0]; pos+=4
    assert 0<count<100000, 'Invalid PCK count'
    names=[]; contents={}
    for _ in range(count):
        length=struct.unpack_from('<I',data,pos)[0]; pos+=4
        assert 0<length<4096
        name=data[pos:pos+length].rstrip(b'\0').decode(); pos+=length
        offset,size=struct.unpack_from('<QQ',data,pos); pos+=16
        md5=data[pos:pos+16]; pos+=16
        file_flags=struct.unpack_from('<I',data,pos)[0]; pos+=4
        assert file_flags==0, 'Unexpected encrypted/removed/delta entry'
        name=name.removeprefix('res://'); names.append(name)
        assert not any(p in {'build','tests','docs','tools','.autoconverted','.git'} for p in pathlib.PurePosixPath(name).parts), f'Forbidden PCK entry: {name}'
        assert not name.endswith(('.log','.zip','.tpz')) and 'app_userdata' not in name
        payload=data[base+offset:base+offset+size]
        assert len(payload)==size and hashlib.md5(payload).digest()==md5, f'Invalid PCK contents: {name}'
        contents[name]=payload
    assert len(set(names))==count
    for f in (ROOT/'world').glob('*.txt'):
        name=f.relative_to(ROOT).as_posix(); assert contents.get(name)==f.read_bytes(), f'Missing/changed world data: {name}'
    assert 'project.binary' in names
    main_scene = __import__('re').search(r'run/main_scene="res://([^"]+)"', (ROOT/'project.godot').read_text()).group(1)
    assert main_scene in names or main_scene+'.remap' in names, 'Missing main scene'
    if (ROOT/'addons/MetroidvaniaSystem').exists():
        assert any(n.startswith('addons/MetroidvaniaSystem/') for n in names)
    return {'entry_count':count,'entries':names,'world_data_verified':True,'forbidden_entries':[]}

def add_intel_template(path):
    # Preserve the verified official universal template; add its byte-exact Intel slice.
    with zipfile.ZipFile(path) as z: entries=[(i,z.read(i)) for i in z.infolist()]
    if any(i.filename.endswith('godot_macos_release.x86_64') for i,_ in entries):return
    additions=[]
    for info,data in entries:
        if not info.filename.endswith('.universal'):continue
        assert data[:4]==b'\xca\xfe\xba\xbe'
        count=struct.unpack_from('>I',data,4)[0]
        for index in range(count):
            cpu,sub,offset,size,alignment=struct.unpack_from('>5I',data,8+index*20)
            if cpu==0x1000007:
                thin=data[offset:offset+size]
                assert thin[:4]==b'\xcf\xfa\xed\xfe' and struct.unpack_from('<I',thin,4)[0]==cpu
                item=zipfile.ZipInfo(info.filename.removesuffix('.universal')+'.x86_64',info.date_time)
                item.external_attr=info.external_attr;item.create_system=info.create_system
                additions.append((item,thin))
    assert len(additions)==2, 'Missing official Intel template slices'
    with zipfile.ZipFile(path,'w',zipfile.ZIP_DEFLATED) as z:
        for info,data in entries+additions:z.writestr(info,data)

def run_export(godot,preset,path):
    env=os.environ.copy(); env['HOME']=str(OUT/'export-profile'); env['XDG_DATA_HOME']=env['HOME']+'/.local/share'
    pathlib.Path(env['HOME']).mkdir(parents=True,exist_ok=True)
    # Copy only verified templates into the disposable export profile.
    original=pathlib.Path(os.environ['CI_TEMPLATES_DIR']) if 'CI_TEMPLATES_DIR' in os.environ else pathlib.Path.home()/'.local/share/godot/export_templates/4.6.1.stable'
    if not original.exists(): original=pathlib.Path.home()/'Library/Application Support/Godot/export_templates/4.6.1.stable'
    destination=pathlib.Path(env['XDG_DATA_HOME'])/'godot/export_templates/4.6.1.stable'
    if not destination.exists():
        import shutil
        shutil.copytree(original,destination)
    if os.uname().sysname=='Darwin':
        import shutil
        mac_dest=pathlib.Path(env['HOME'])/'Library/Application Support/Godot/export_templates/4.6.1.stable'
        if not mac_dest.exists(): shutil.copytree(original,mac_dest)
    if preset=='macOS' and os.environ.get('CI_PRESETS_FROM_SOURCE')=='false':
        for template_dir in {destination, locals().get('mac_dest', destination)}:
            add_intel_template(template_dir/'macos.zip')
    result=subprocess.run([godot,'--headless','--path',str(ROOT),'--export-release',preset,str(path)],cwd=ROOT,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=300)
    (OUT/'logs'/f'export-{preset}.log').write_text(result.stdout)
    assert result.returncode==0 and not hard_errors(result.stdout), result.stdout[-4000:]
def main():
    p=argparse.ArgumentParser();p.add_argument('--godot',required=True); args=p.parse_args()
    prepare_presets()
    qa=json.loads((ROOT/'build/int01/logs/CI_QA_REPORT.json').read_text());assert qa['status']=='passed'
    sha=os.environ.get('SOURCE_SHA') or subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip()
    assert len(sha)==40 and all(c in '0123456789abcdef' for c in sha)
    branch=os.environ.get('SOURCE_BRANCH') or subprocess.check_output(['git','branch','--show-current'],cwd=ROOT,text=True).strip()
    (OUT/'logs').mkdir(parents=True,exist_ok=True)
    for folder_name,preset in [('Windows-x86_64','Windows Desktop'),('macOS','macOS')]:
        target=folder_name if folder_name.startswith('Windows') else ('macOS-Universal' if qa['qa_mode']=='candidate-full-regression' else 'macOS-x86_64')
        folder=OUT/folder_name;folder.mkdir(parents=True,exist_ok=True)
        label='Kaze-Alpha-0.6.1-Candidate' if qa['qa_mode']=='candidate-full-regression' else 'Momentum-Fractured-Main-Playtest'
        stem=f'{label}-{target}-{sha[:8]}'
        archive=folder/(stem+'.zip')
        if target.startswith('Windows'):
            executable=OUT/(stem+'.exe'); run_export(args.godot,preset,executable)
            audit=audit_pack(executable.read_bytes())
            with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED) as z: z.write(executable,executable.name)
        else:
            run_export(args.godot,preset,archive)
            with zipfile.ZipFile(archive) as z:
                packs=[n for n in z.namelist() if n.endswith('.pck')];assert len(packs)==1
                audit=audit_pack(z.read(packs[0]))
                binaries=[n for n in z.namelist() if '.app/Contents/MacOS/' in n and not n.endswith('/')];assert len(binaries)==1
                binary=z.read(binaries[0])
                if target=='macOS-Universal':
                    assert binary[:4] in (b'\xca\xfe\xba\xbe',b'\xca\xfe\xba\xbf') and struct.unpack_from('>I',binary,4)[0]==2, 'Expected universal binary'
                else:
                    assert binary[:4]==b'\xcf\xfa\xed\xfe' and struct.unpack_from('<I',binary,4)[0]==0x1000007, 'Expected Intel Mach-O'
        with zipfile.ZipFile(archive) as z:
            assert z.testzip() is None
            members=[dict(path=i.filename,size=i.file_size,sha256=hashlib.sha256(z.read(i)).hexdigest()) for i in z.infolist() if not i.is_dir()]
            assert all('.app/' in i['path'] for i in members) if target.startswith('macOS') else len(members)==1
        (OUT/'logs'/f'pack-audit-{target}.json').write_text(json.dumps(audit,indent=2))
        manifest=dict(branch=branch,source_sha=sha,godot_version='4.6.1.stable.official.14d19694e',templates='4.6.1.stable',templates_sha256='e6d372afd4fdfaae9571eb5e3568afcd96ce6db9a569244034154faf0ac69875',timestamp_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),target=target,qa_outcome=qa['status'],qa_suite_count=qa['suite_count'],qa_mode=qa['qa_mode'],qa_unavailable_checks=qa.get('unavailable_checks',[]),temporary_export_overrides=[],template_derivation='none' if os.environ.get('CI_PRESETS_FROM_SOURCE')=='true' else 'byte-exact Intel slice from checksum-verified official universal macOS template',preset_origin='source' if os.environ.get('CI_PRESETS_FROM_SOURCE')=='true' else 'temporary CI-only fallback',native_boot='untested; export/package verified only',tested_architectures=['Linux x86_64 headless source QA'] if os.environ.get('GITHUB_ACTIONS') else ['macOS local headless source QA'],untested_architectures=['Windows x86_64'] if target.startswith('Windows') else ['macOS arm64','macOS x86_64'],zip=dict(name=archive.name,size=archive.stat().st_size,sha256=hashlib.sha256(archive.read_bytes()).hexdigest()),members=members,pack_audit=dict(entry_count=audit['entry_count'],world_data_verified=True,forbidden_entries=[]))
        (folder/'BUILD_MANIFEST.json').write_text(json.dumps(manifest,indent=2))
        print(target,manifest['zip'])

def prepare_presets():
    preset=ROOT/'export_presets.cfg'
    if preset.exists():
        text=preset.read_text()
        assert 'name="Windows Desktop"' in text and 'name="macOS"' in text, 'Unrecognized source presets'
        assert 'world/*.txt' in text and all(x+'/*' in text for x in ('tests','docs','tools','build','.autoconverted')), 'Source exclusions/data include incompatible'
        os.environ['CI_PRESETS_FROM_SOURCE']='true'
        return
    project=(ROOT/'project.godot').read_text()
    assert '0.6.1' not in project and not (ROOT/'tools/run_int01_qa.py').exists(), 'Candidate presets missing'
    # This checkout is disposable. Never commit or copy fallback presets into game source.
    preset.write_text("""[preset.0]
name="Windows Desktop"
platform="Windows Desktop"
runnable=true
export_filter="all_resources"
include_filter="world/*.txt"
exclude_filter="tests/*,docs/*,tools/*,build/*,.autoconverted/*"
export_path=""
[preset.0.options]
binary_format/architecture="x86_64"
binary_format/embed_pck=true
application/modify_resources=false
codesign/enable=false
texture_format/s3tc_bptc=true
texture_format/etc2_astc=false
[preset.1]
name="macOS"
platform="macOS"
runnable=true
export_filter="all_resources"
include_filter="world/*.txt"
exclude_filter="tests/*,docs/*,tools/*,build/*,.autoconverted/*"
export_path=""
[preset.1.options]
export/distribution_type=1
binary_format/architecture="x86_64"
application/bundle_identifier="com.momentumfractured.ci.playtest"
application/short_version="0.0.0"
application/version="0.0.0"
codesign/codesign=0
notarization/notarization=0
texture_format/s3tc_bptc=true
texture_format/etc2_astc=false
""")
    os.environ['CI_PRESETS_FROM_SOURCE']='false'

if __name__=='__main__':main()
