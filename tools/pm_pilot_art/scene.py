"""PIL composition of the Canal exit at game scale (1 px = 1 room px, zoom 1.0).
This is a 2D composition of repo assets, NOT an engine capture."""
import json, os
from PIL import Image, ImageDraw, ImageFont
import numpy as np
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
P = lambda *a: os.path.join(ROOT, *a)
RECTS = json.load(open(P('source_art/pm_pilot/canal_layer_rects.json')))
ROOM = (1800, 1440)
KAZE = {  # clip: (strip, frames, scale, baseline)  from scripts/player.gd
    'idle': ('assets/kaze/cleaned/kaze_idle_strip.png', 8, 0.2649908807267889, 591.0),
    'run': ('assets/kaze/cleaned/kaze_run_strip.png', 8, 0.3825780535911868, 491.0),
}
_cache = {}
def img(path):
    if path not in _cache: _cache[path] = Image.open(P(path)).convert('RGBA')
    return _cache[path]

def kaze(clip, idx, facing, shade=None):
    """Return (RGBA image, (dx, dy)) such that pasting at feet + (dx, dy) registers the sprite like player.gd."""
    path, n, sc, base = KAZE[clip]
    strip = img(path); fw = strip.width // n
    cell = strip.crop((idx % n * fw, 0, idx % n * fw + fw, strip.height))
    w, h = round(fw * sc), round(strip.height * sc)
    cell = cell.resize((w, h), Image.LANCZOS)
    if facing < 0: cell = cell.transpose(Image.FLIP_LEFT_RIGHT)   # flip_h = facing < 0
    if shade is not None:
        a = np.asarray(cell, float); a[..., :3] *= np.array(shade)[None, None, :]
        cell = Image.fromarray(a.clip(0, 255).astype(np.uint8), 'RGBA')
    return cell, (-w / 2, -base * sc)

def backdrop(view):
    bg = img('assets/web/district-fidelity.png').convert('RGB').resize(ROOM, Image.LANCZOS)
    a = np.asarray(bg, float) * np.array([0.72, 0.70, 0.86])[None, None, :] * 0.92  # world.gd modulate
    return Image.fromarray(a.clip(0, 255).astype(np.uint8)).convert('RGBA').crop((view[0], view[1], view[0] + 1280, view[1] + 720))

def layer(name):
    x, y, w, h = RECTS[name]['rect']
    return Image.open(P('assets/pm_pilot/canal', f'canal_{name}.png')).convert('RGBA'), (x, y)

def draw_pad(d, view):
    # Stand-in for the existing pad (x0..360, top y1200, 40 thick) and shelf (200,1160); same flat colours as world.gd caps.
    for (x, y, w, h) in [(0, 1200, 360, 40), (200, 1160, 120, 40)]:
        r = [x - view[0], y - view[1], x + w - view[0], y + h - view[1]]
        d.rectangle(r, fill=(38, 52, 62, 255)); d.line([r[0], r[1], r[2], r[1]], fill=(217, 201, 173, 255), width=3)

def compose(view=(0, 720), kaze_spec=None, layers=('L0_hall_back_wall', 'L1_door_interior', 'L1_door_frame', 'L1_door_leaf', 'L2_gatehouse_face', 'L2_lintel_course', 'L3_back_pier'),
            front=('L4_mouth_corbel',), pad=True, leaf=True, ghost_hitbox=False):
    im = backdrop(view)
    # z-order: back to front per contract (pad drawn with the world platforms, before the architecture is fine because they do not overlap)
    d = ImageDraw.Draw(im)
    if pad: draw_pad(d, view)
    for n in layers:
        if n == 'L1_door_leaf' and not leaf: continue
        l, (x, y) = layer(n); im.alpha_composite(l, (x - view[0], y - view[1]))
    if kaze_spec:
        spr, (dx, dy), fx, fy = kaze_spec
        im.alpha_composite(spr, (round(fx + dx - view[0]), round(fy + dy - view[1])))
    for n in front:
        l, (x, y) = layer(n); im.alpha_composite(l, (x - view[0], y - view[1]))
    if ghost_hitbox:
        d = ImageDraw.Draw(im)
        d.rectangle([72 - view[0], 1068 - view[1], 168 - view[0], 1200 - view[1]], outline=(255, 80, 80, 255))
    return im

def font(sz=14):
    for f in ['/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', '/usr/share/fonts/dejavu/DejaVuSans.ttf']:
        if os.path.exists(f): return ImageFont.truetype(f, sz)
    return ImageFont.load_default()
