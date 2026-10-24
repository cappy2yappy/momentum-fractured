"""Compare protected bytes and normalized tracked content against the pinned base."""
from pathlib import Path
import subprocess, json, hashlib
ROOT=Path(__file__).resolve().parents[2]
BASE='6ab1454ea44e946265d2a65d1495d81e7aae840f'
audit=json.loads((ROOT/'docs/anim_stop_01/pixel_audit.json').read_text())
changed=[p for p,h in audit['protected_sha256'].items() if hashlib.sha256((ROOT/p).read_bytes()).hexdigest()!=h]
gitdiff=subprocess.run(['git','diff','--name-only',BASE],cwd=ROOT,capture_output=True,text=True,check=True).stdout.splitlines()
outside=[p for p in gitdiff if not p.startswith(('tools/anim_stop_01/','tests/anim_stop_01/','docs/anim_stop_01/'))]
approved_pngs=[p for p in audit['protected_sha256'] if p.endswith('.png')]
blob_mismatch=[]
for p in approved_pngs:
    blob=subprocess.run(['git','show',BASE+':'+p],cwd=ROOT,capture_output=True,check=True).stdout
    if blob!=(ROOT/p).read_bytes():blob_mismatch.append(p)
result={'base':BASE,'protected_files':len(audit['protected_sha256']),'changed_protected_bytes':changed,'approved_png_blob_mismatch':blob_mismatch,'outside_namespace_tracked_changes':outside,'passed':not(changed or outside or blob_mismatch),'note':'Text files compared to initial cloned bytes and Git normalized content; PNGs also compared byte-for-byte to Git blobs. Existing worktrees and user saves were not accessed for mutation.'}
(ROOT/'docs/anim_stop_01/preservation_result.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result,indent=2))
raise SystemExit(0 if result['passed'] else 1)
