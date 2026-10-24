#!/usr/bin/env python3
"""Check ENV12 scope, pinned bytes, room coverage and recorded native evidence."""
import hashlib, json, pathlib, re, struct, subprocess, sys
sys.dont_write_bytecode=True
ROOT=pathlib.Path(__file__).resolve().parents[2]
BASE='250afde28517fcc05984038ac9e1487114729b78'
PREFIXES=('docs/env12/','tools/env12/','tests/env12/')
checks=0
failures=[]
def check(ok,msg):
    global checks
    checks+=1
    if not ok:failures.append(msg)
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def git(*args):return subprocess.check_output(['git','-C',str(ROOT),*args]).decode()
def blob(data):return hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest()
def main():
    rows=git('ls-tree','-r',BASE).splitlines()
    for row in rows:
        meta,name=row.split('\t',1);mode,kind,expected=meta.split()
        if kind=='blob':check(blob((ROOT/name).read_bytes())==expected,'Base file changed: '+name)
    paths=git('diff','--name-only',BASE).splitlines()
    paths+=git('ls-files','--others','--exclude-standard').splitlines()
    for p in paths:
        check(p.startswith(PREFIXES),'Out-of-scope file: '+p)
        check(pathlib.Path(p).suffix.lower() in ('.md','.gd','.py','.json','.html','.txt','') or pathlib.Path(p).name.startswith('.'),'Binary/unsupported publication: '+p)
    matrix=(ROOT/'docs/env12/ROOM_MATRIX.md').read_text(encoding='utf-8-sig')
    ids=[int(x) for x in re.findall(r'^\| R(\d+) ',matrix,re.M)]
    check(ids==list(range(21)),'Room matrix coverage/order')
    world=(ROOT/'scripts/world.gd').read_text()
    for exact in ['The refuge was attacked. I have to find the others.','Search for survivors. Defeat the Market sentinel for Windstep.']:
        check(exact in (ROOT/'docs/env12/AUTHORITY.md').read_text(encoding='utf-8-sig'),'Approved handoff copy absent: '+exact)
    rights=(ROOT/'docs/env12/RIGHTS_AND_PROVENANCE.md').read_text(encoding='utf-8-sig')
    check('DarkCave independent rights are unresolved' in rights,'Rights uncertainty missing')
    manifest=json.loads((ROOT/'docs/env12/capture-manifest.json').read_text())
    for name,expected in manifest['code_sha256'].items():check(sha(ROOT/name)==expected,'Capture code changed: '+name)
    expected_counts={0:15,4:15,14:15,16:16}
    total_native=0
    for room,count in expected_counts.items():
        a=json.loads((ROOT/f'docs/env12/evidence/R{room}.json').read_text())
        check(a['pass'] and not a['failures'],'Native evidence failed R'+str(room))
        check(len(a['captures'])==count,'Capture coverage R'+str(room))
        check(a['engine'].startswith('4.6.1'),'Engine pin')
        check(a['audit']['four_layers']==4 and not a['audit']['violations'],'Layer/readability evidence')
        check(a['audit']['protected_counts'].get('grapple',0)=={0:0,4:3,14:3,16:2}[room],'Locked anchor reservation')
        check(a['initial_state']['rooms']==21 and len(a['initial_state']['edges'])==29,'Graph evidence')
        check(not a['audit']['integration_enabled'] and a['audit']['category_C_devices']==0,'Unexpected integration/device')
        check(a['decoded_frames']==185 and a['texture_bytes']==3795784,'Cache drift')
        total_native+=a['assertions']
    private=ROOT/'tools/env12/.private'
    local_count=0
    for frame in manifest['captures']:
        file=ROOT/frame['local_path']
        if file.exists():
            check(sha(file)==frame['sha256'],'Changed native screenshot: '+file.name)
            b=file.read_bytes();check(b[:8]==b'\x89PNG\r\n\x1a\n' and struct.unpack('>II',b[16:24])==(1280,720),'Native screenshot dimensions')
            local_count+=1
    if local_count:check(local_count==61,'Partial local capture set')
    else:print('Private screenshot pixels unavailable in this checkout: integrity check skipped.')
    prior=ROOT.parent/'art11-repo'; guard=private/'reference-before.json'
    if prior.exists() and guard.exists():
        before=json.loads(guard.read_text());status=subprocess.check_output(['git','-C',str(prior),'status','--porcelain','--untracked-files=all']);head=subprocess.check_output(['git','-C',str(prior),'rev-parse','HEAD']).decode().strip()
        check(head==before['art11_head'],'Read-only ART11 HEAD changed')
        check(hashlib.sha256(status).hexdigest()==before['status_sha256'],'Read-only ART11 status changed')
    result={'checks':checks,'failures':failures,'base_files_verified':len(rows),'recorded_native_assertions':total_native,'local_capture_pixels_verified':local_count,'known_base_gaps':['PR99 runtime predates the approved opening/objective and Foundry Rest Station copy. Runtime copy acceptance is NOT passed; source stays unchanged and gallery HUD is hidden.'],'note':'Native evidence checks do not rerun traversal, exports or ART11 alpha tests.'}
    print(json.dumps(result,indent=2))
    if private.exists():(private/'verification.json').write_text(json.dumps(result,indent=2)+'\n')
    return 1 if failures else 0
if __name__=='__main__':raise SystemExit(main())
