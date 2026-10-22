"""Read-only Kaze file inventory. Run from the project mirror on the source Mac."""
from pathlib import Path
import os, json, subprocess, hashlib, collections, datetime

ROOT = Path.cwd()
OUT = ROOT / 'output/home-sync-2026-10-22'
AUDIT = ROOT / 'work/home-sync-audit'
DOC = Path('/Users/tonysantiago/Documents/Codex')
BASE = DOC / '2026-10-22/kaze-codex-alpha07-coordinated-gameplay-narrative'
repos = json.loads((OUT/'initial-repos.json').read_text())
repo_paths = {Path(r['path']) for r in repos}
remote_objects = set(line.split(' ', 1)[0] for line in subprocess.check_output(
    ['git','-C',str(AUDIT),'rev-list','--objects','--remotes=origin'],text=True).splitlines())
skip_repos = {AUDIT, ROOT/'asset01-controlled'}
skip_repos.update(Path(r['path']) for r in json.loads((OUT/'recovery-checkpoints.json').read_text()))
extra = [ROOT/'work', ROOT/'output', ROOT/'tmp', BASE/'outputs', BASE/'work',
         Path('/Users/tonysantiago/Downloads/Packs'),
         Path('/Users/tonysantiago/Documents/Playground/recovery-archives'),
         Path('/Users/tonysantiago/momentum-fractured-main')]
extra += [Path(f'/Users/tonysantiago/m-0m-3-ntum-godot-({i})') for i in range(1,5)]
for day in DOC.iterdir():
    if day.is_dir():
        extra += [p for p in day.iterdir() if p.is_dir() and 'kaze' in p.name.lower()]
roots = list(repo_paths) + extra
seen=set(); counts=collections.Counter(); sizes=collections.Counter(); cache=[]; errors=[]
tracked={}
for r in repos:
    p=Path(r['path'])
    names=subprocess.check_output(['git','-C',str(p),'ls-tree','-rz','--name-only','HEAD']).split(b'\0')
    tracked[p]={os.fsdecode(n) for n in names if n}
    changed=subprocess.check_output(['git','-C',str(p),'diff','HEAD','--name-only','-z']).split(b'\0')
    tracked[p].difference_update(os.fsdecode(n) for n in changed if n)

def classify(p):
    s=str(p)
    if p.suffix=='.import': return 'generated-import-metadata'
    if '/asset01-staging/' in s or '/asset01-stage-repro/' in s or '/Downloads/Packs/' in s:
        return 'source-or-third-party-staging-do-not-publish'
    if any(t in s for t in ['/profile/', '/profiles/', '/.tmphome/', '/app_userdata/']): return 'local-profile-or-save'
    if p.suffix.lower() in ['.mp4','.mov','.webm']: return 'local-recording'
    if '/build/' in s or p.suffix.lower() in ['.png','.jpg','.jpeg','.pdf','.pck','.dmg','.exe','.zip']:
        return 'generated-preview-build-or-art-reference'
    if p.name.startswith('disposable_') or '/int01_disposable/' in s: return 'reproducible-disposable-test'
    if p.suffix.lower() in ['.py','.gd','.m','.swift','.sh','.command']: return 'local-helper-source'
    return 'local-report-or-other'

with (OUT/'local-files.jsonl').open('w') as out:
    for scan in roots:
        if not scan.exists(): continue
        for d,ds,fs in os.walk(scan):
            directory=Path(d)
            if directory in skip_repos or directory==OUT:
                ds[:]=[]; continue
            if directory in repo_paths and directory!=scan:
                ds[:]=[]; continue
            ds[:]=[n for n in ds if n not in ['.git','node_modules','__pycache__']]
            if '.godot' in ds:
                cp=directory/'.godot'; num=total=0
                for cd,_,cf in os.walk(cp):
                    for name in cf:
                        try: total+=(Path(cd)/name).stat().st_size;num+=1
                        except OSError: pass
                cache.append(dict(path=str(cp),files=num,bytes=total));ds.remove('.godot')
            owner=next((p for p in repo_paths if directory==p or p in directory.parents),None)
            for name in fs:
                p=directory/name
                if p in seen: continue
                seen.add(p)
                if owner and str(p.relative_to(owner)) in tracked[owner]: continue
                try:
                    if p.is_symlink():
                        row=dict(path=str(p),kind='symlink',target=os.readlink(p));out.write(json.dumps(row)+'\n');continue
                    st=p.stat(); sha=hashlib.sha256(); blob=hashlib.sha1()
                    blob.update(('blob '+str(st.st_size)+'\0').encode())
                    with p.open('rb') as f:
                        for block in iter(lambda:f.read(1024*1024),b''):sha.update(block);blob.update(block)
                    oid=blob.hexdigest();kind=classify(p)
                    row=dict(path=str(p),bytes=st.st_size,sha256=sha.hexdigest(),git_blob=oid,
                             blob_already_on_remote=oid in remote_objects,kind=kind,
                             mtime_utc=datetime.datetime.fromtimestamp(st.st_mtime,datetime.timezone.utc).isoformat())
                    out.write(json.dumps(row)+'\n');counts[kind]+=1;sizes[kind]+=st.st_size
                except (OSError,ValueError) as e:errors.append(dict(path=str(p),error=str(e)))
summary=dict(timestamp_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
    scope=[str(p) for p in roots],counts=dict(counts),bytes=dict(sizes),cache_directories=cache,errors=errors,
    limitations=['Cache contents aggregated by directory; not hashed.',
                  'Concurrent asset01-controlled session excluded here and audited in the final session snapshot.',
                  'Standalone old exports inventoried, not asserted to be canonical or safe to integrate.'])
(OUT/'local-summary.json').write_text(json.dumps(summary,indent=2)+'\n')
print(json.dumps(dict(counts=dict(counts),bytes=dict(sizes),cache_dirs=len(cache),errors=errors),indent=2))
