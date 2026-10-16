import os,pathlib,struct,hashlib
ROOT=pathlib.Path(os.environ["BUILD05_SOURCE_ROOT"])
MAGIC=b"GDPC"
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
        assert not any(p in {'build','tests','docs','tools','source_art','.autoconverted','.git'} for p in pathlib.PurePosixPath(name).parts), f'Forbidden PCK entry: {name}'
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
