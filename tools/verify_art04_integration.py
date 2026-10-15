"""Pin ART-04 runtime delivery and PR27's authoritative simulation bytes."""
from pathlib import Path
import subprocess,hashlib,json
r=Path(__file__).resolve().parents[1];art='a6b76b9938825307bdcd4efb687c7198ea0d8681';base='c2c002267c58e991966c0eebf7e098c6e7fff769'
checks=[]
def check(ok,label):
 checks.append(bool(ok));print(('PASS: ' if ok else 'FAIL: ')+label)
paths=subprocess.check_output(['git','ls-tree','-r','--name-only',art,'assets/art04'],cwd=r,text=True).splitlines()
for path in paths:
 check((r/path).read_bytes()==subprocess.check_output(['git','show',art+':'+path],cwd=r),path+' matches pinned ART-04 delivery')
for path in ['scripts/world.gd','scripts/player.gd','scripts/mixed_transitions.gd','scripts/hud.gd','scripts/momentum_profile.gd','scripts/route_extension.gd','scripts/skyworks_region.gd','project.godot','export_presets.cfg','assets/web/kaze_manifest.json','world/MapData.txt']:
 check((r/path).read_bytes()==subprocess.check_output(['git','show',base+':'+path],cwd=r),path+' matches PR27 byte for byte')
print(json.dumps(dict(art_sha=art,base_sha=base,checks=len(checks),failures=checks.count(False))))
raise SystemExit(not all(checks))
