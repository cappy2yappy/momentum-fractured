"""Read-only source pixel audit. No image files are modified."""
from pathlib import Path
import hashlib, json
from PIL import Image
import numpy as np

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'docs/anim_stop_01'
OUT.mkdir(parents=True, exist_ok=True)
def digest(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def box(a, threshold):
    y,x = np.nonzero(a > threshold)
    return [int(x.min()),int(y.min()),int(x.max()+1),int(y.max()+1)] if len(x) else None
run = ROOT/'assets/kaze/cleaned/kaze_run_strip.png'
im = np.array(Image.open(run).convert('RGBA'))
frames=[]
for i in range(8):
    a=im[:, i*272:(i+1)*272,3]
    boxes={str(t):box(a,t) for t in [0,32,128,230]}
    frames.append({'frame':i,'alpha_boxes':boxes,'display_height_alpha128':round((boxes['128'][3]-boxes['128'][1])*.85,3),'sole_baseline_actor_relative_alpha128':round((boxes['128'][3]-1-362-238)*.85,3)})
parts=[]
for p in sorted((ROOT/'assets/cin_tools_03/rig_parts').glob('*.png')):
    a=np.array(Image.open(p).convert('RGBA'))[:,:,3]
    parts.append({'path':p.relative_to(ROOT).as_posix(),'size':list(Image.open(p).size),'alpha128':box(a,128),'sha256':digest(p)})
protected=['presets/cutins/studio/actor.tscn','presets/cutins/studio/sprint_stop.tres','tools/cin_tools_03/actor.gd','tools/cin_tools_03/studio.gd','scripts/player.gd','project.godot']
protected += [p.relative_to(ROOT).as_posix() for folder in ['assets/kaze/cleaned','assets/web'] for p in (ROOT/folder).glob('kaze_*.png')]
data={'base':'6ab1454ea44e946265d2a65d1495d81e7aae840f','run_size':[2176,724],'cell':[272,724],'sprite_scale':.85,'sprite_offset':[0,-238],'frames':frames,'parts':parts,'protected_sha256':{p:digest(ROOT/p) for p in protected},'limits':'Alpha bounds are visible silhouette measurements, not anatomical landmarks. Scale 0.68 is a review proposal, not approved proportions. Sole markers are support pixels, not proof of heel/forefoot anatomy.'}
(OUT/'pixel_audit.json').write_text(json.dumps(data,indent=2)+'\n',encoding='utf-8')
print('Read-only pixel audit: 8 run frames, 8 rig images, protected source hashes recorded.')
