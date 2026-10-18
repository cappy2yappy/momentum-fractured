"""Verify every PR39 tracked blob remains byte-exact; the pilot is additive."""
from pathlib import Path
import hashlib, json, subprocess, sys

root = Path(__file__).resolve().parents[2]
base = '5dfc4c4f077c5408ecbe49f1cafafea1dcb1003c'
entries = subprocess.check_output(['git','ls-tree','-r','-z',base],cwd=root).split(b'\0')
changed = []
count = 0
for entry in entries:
    if not entry: continue
    meta, raw_path = entry.split(b'\t',1)
    mode, kind, sha = meta.decode().split()
    if kind != 'blob': continue
    name = raw_path.decode()
    file = root/name
    count += 1
    if not file.is_file():
        changed.append(name)
        continue
    data = file.read_bytes()
    actual = hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest()
    if actual != sha: changed.append(name)
result = {'baseline':base,'checked_blobs':count,'changed':changed,'pass':not changed}
print(json.dumps(result,indent=2))
sys.exit(bool(changed))
