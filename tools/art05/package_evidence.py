"""Package native Godot frame captures into review sequences; never repaint pixels."""
from pathlib import Path
import hashlib,json,shutil
from PIL import Image
ROOT=Path(__file__).resolve().parents[2]
DOC=ROOT/'docs/art/art05/evidence';NATIVE=ROOT/'build/art05/native'
DOC.mkdir(parents=True,exist_ok=True)
for p in sorted(NATIVE.glob('*.png')):
    assert Image.open(p).size==(1280,720)
    shutil.copyfile(p,DOC/p.name)
for clip in ['turn_depth','enter_depth','stair_up']:
    frames=[Image.open(p).convert('RGB') for p in sorted(NATIVE.glob(clip+'_*.png'))]
    frames[0].save(DOC/(clip+'_native.gif'),save_all=True,append_images=frames[1:],duration=[50]*(len(frames)-1)+[450],loop=0,disposal=2)
for name,src in [('NATIVE_RENDER.txt','/tmp/art05-native-stdout.txt'),('TRANSITION_REGRESSION.txt','/tmp/art05-regression-stdout.txt')]:
    p=Path(src)
    if p.exists():shutil.copyfile(p,DOC/name)
items=[]
for p in sorted(DOC.iterdir()):
    if p.name=='CAPTURE_MANIFEST.json' or not p.is_file():continue
    items.append({'path':p.relative_to(ROOT).as_posix(),'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'bytes':p.stat().st_size})
(DOC/'CAPTURE_MANIFEST.json').write_text(json.dumps({'origin':'native Godot4.6.1 Apple M4 OpenGL3 on macOS; PNGs are actual1280x720 framebuffer captures','gif_timing':'each authored frame50ms (20fps), final frame450ms includes400ms endpoint review hold; GIFs are derivatives, not continuous recording','files':items},indent=2)+'\n')
print('Packaged',len(items),'native evidence files')
