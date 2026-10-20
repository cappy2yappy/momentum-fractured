"""Builds the Canal (R13 left exit) architecture layers to CANAL_CONTRACT v1 numbers.
Run from repo root: python3 tools/pm_pilot_art/build_canal.py
Writes game-scale PNGs to assets/pm_pilot/canal/ and 2x masters + ORA to source_art/pm_pilot/."""
import json, os, sys, zipfile, io
sys.path.insert(0, os.path.dirname(__file__))
from common import *

OUT = 'assets/pm_pilot/canal'; SRC = 'source_art/pm_pilot'
os.makedirs(OUT, exist_ok=True); os.makedirs(SRC + '/masters_2x', exist_ok=True)
C = json.load(open(os.path.join(os.path.dirname(__file__), 'canal_contract_v1.json')))
R = {k: tuple(v) for k, v in C['rects'].items()}   # name -> (x,y,w,h) in room 13 px

def light_grad(w, h, side, strength, color):
    """Soft light spill from the left or right edge, returned as RGBA float."""
    x = np.linspace(0, 1, w)[None, :]
    if side == 'right': x = 1 - x
    a = np.clip(1 - x, 0, 1) ** 2.2 * strength
    y = np.linspace(0.6, 1.0, h)[:, None]
    a = a * y
    out = np.zeros((h, w, 4)); out[..., :3] = color; out[..., 3] = a * 255
    return out

def comp(base_rgb, overlays):
    im = Image.fromarray(base_rgb).convert('RGBA')
    for o in overlays:
        im = Image.alpha_composite(im, Image.fromarray(np.clip(o, 0, 255).astype(np.uint8), 'RGBA').resize(im.size) if o.shape[:2] != (im.height, im.width) else Image.fromarray(np.clip(o, 0, 255).astype(np.uint8), 'RGBA'))
    return im

layers = {}

# L0 hall back wall: rear plane, dark, tileable horizontally, cool mooring light creeping in from the mouth (right).
x, y, w, h = R['L0_hall_back_wall']
m = masonry(w, h, 11, course=20, wmin=28, wmax=52, wrap=True, base=(50, 62, 70), moss=0.15, stain_from=0.6)
base = (m.astype(float) * 0.62).astype(np.uint8)
im = to_img(base)
im = Image.alpha_composite(im, Image.fromarray(light_grad(w * SS, h * SS, 'right', 0.30, PAL['cool']).astype(np.uint8), 'RGBA'))
# floor shadow line where the rear plane meets the pad
d = ImageDraw.Draw(im)
d.rectangle([0, (h - 6) * SS, w * SS, h * SS], fill=(8, 12, 16, 150))
layers['L0_hall_back_wall'] = im

# L1a door interior: a short passage seen through the aperture, warm lamp at the far (R0) end.
x, y, w, h = R['L1_door_aperture']
W, H = w * SS, h * SS
yy, xx = np.mgrid[0:H, 0:W]
a = np.zeros((H, W, 3), float)
a[:] = (9, 13, 19)
# reveal walls: darker stone trapezoids converging toward a vanishing point at the far end
vx, vy = W * 0.5, H * 0.52
fw, fh = W * 0.36, H * 0.40            # far end half-size
t_left = np.clip((xx - 0) / np.maximum(vx - fw, 1), 0, 1)
for side in (-1, 1):
    pass
# far wall rectangle
fx0, fx1, fy0, fy1 = int(vx - fw / 2), int(vx + fw / 2), int(vy - fh / 2), int(H - H * 0.14)
glow = np.exp(-(((xx - vx) / (W * 0.30)) ** 2 + ((yy - (vy + fh * 0.2)) / (H * 0.35)) ** 2))
warm = np.array(PAL['warm'], float)
a += glow[..., None] * warm * 0.55
# side wall shading: blocks recede, darker near the viewer, picking up warm bounce toward the far end
depth = np.clip(1 - np.abs(xx - vx) / (W * 0.5), 0, 1)
a *= (0.55 + 0.45 * depth)[..., None] ** 1.0
# floor reflection of the lamp (wet floor)
fl = np.clip((yy - H * 0.72) / (H * 0.28), 0, 1) * np.exp(-((xx - vx) / (W * 0.18)) ** 2)
a += fl[..., None] * warm * 0.22
# ceiling falloff
a *= (0.65 + 0.35 * np.clip(1 - (H * 0.2 - yy) / (H * 0.2), 0, 1))[..., None]
im = to_img(np.clip(a, 0, 255).astype(np.uint8))
d = ImageDraw.Draw(im, 'RGBA')
# receding course lines on both reveal walls
for i in range(1, 6):
    f = i / 6.0
    ex = int((vx - fw / 2) * f)       # left reveal edge at this depth
    ey0 = int(fy0 * f); ey1 = int(H - (H - fy1) * f)
    d.line([ex, ey0, ex, ey1], fill=(5, 8, 12, 120), width=SS)
    d.line([W - ex, ey0, W - ex, ey1], fill=(5, 8, 12, 120), width=SS)
fo = Image.new('RGBA', (W, H), (0, 0, 0, 0))
ImageDraw.Draw(fo).rectangle([fx0, fy0, fx1, fy1], fill=(244, 219, 150, 80))   # far opening lit by the R0 lamp
im = Image.alpha_composite(im, fo.filter(ImageFilter.GaussianBlur(5 * SS)))
layers['L1_door_interior'] = im

# L1b door frame: jambs and flat dressed head with corbelled ends; aperture is transparent.
x, y, w, h = R['L1_door_frame']
ax, ay, aw, ah = R['L1_door_aperture']
W, H = w * SS, h * SS
base = masonry(w, h, 21, course=21, wmin=26, wmax=44, wrap=False, base=(82, 96, 100), moss=0.12, stain_from=0.7)
im = to_img(base)
mask = Image.new('L', (W, H), 255)
md = ImageDraw.Draw(mask)
md.rectangle([(ax - x) * SS, (ay - y) * SS, (ax - x + aw) * SS - 1, (ay - y + ah) * SS - 1], fill=0)
im.putalpha(mask)
d = ImageDraw.Draw(im, 'RGBA')
# head course: one heavy lintel stone, slightly lighter, with a worn lower edge
head_h = (ay - y) * SS
d.rectangle([0, 0, W, head_h], fill=(92, 106, 110, 255))
d.rectangle([0, head_h - 5 * SS, W, head_h], fill=(54, 68, 74, 255))
d.line([0, 0, W, 0], fill=(128, 142, 140, 255), width=2 * SS)
for cx in (W // 3, 2 * W // 3):
    d.line([cx, SS, cx, head_h - 5 * SS], fill=(20, 28, 34, 200), width=SS)
# reveal shadow on the inner jamb faces (inside the frame, not inside the aperture)
d.rectangle([(ax - x) * SS - 4 * SS, head_h, (ax - x) * SS - 1, H], fill=(10, 16, 22, 140))
d.rectangle([(ax - x + aw) * SS, head_h, (ax - x + aw) * SS + 4 * SS, H], fill=(10, 16, 22, 140))
# warm kick on the inner edges from the R0 lamp
d.rectangle([(ax - x + aw) * SS - 2 * SS, head_h + 2 * SS, (ax - x + aw) * SS - 1, H], fill=(244, 219, 150, 0))
im = outline(im, px=1)
# re-cut the aperture after outlining so the clear opening stays exactly 96x132
al = np.asarray(im.split()[-1]).copy()
al[(ay - y) * SS:(ay - y + ah) * SS, (ax - x) * SS:(ax - x + aw) * SS] = 0
im.putalpha(Image.fromarray(al))
layers['L1_door_frame'] = im

# Optional door leaf: heavy timber leaf standing ajar on its left hinge, foreshortened so the opening stays readable.
x, y, w, h = R['L1_door_leaf']
W, H = w * SS, h * SS
im = Image.new('RGBA', (W, H), (0, 0, 0, 0))
d = ImageDraw.Draw(im, 'RGBA')
lw = int(W * 0.30)                                   # visible foreshortened width
poly = [(0, 0), (lw, int(H * 0.035)), (lw, int(H * 0.965)), (0, H)]
d.polygon(poly, fill=PAL['wood'] + (255,))
n = rng(31)
for i in range(1, 5):                                 # vertical planks
    px = int(lw * i / 5)
    d.line([px, int(H * 0.035 * i / 5), px, H - int(H * 0.035 * i / 5)], fill=PAL['wood_dark'] + (255,), width=SS)
for fy in (0.2, 0.5, 0.8):                            # iron straps
    yy_ = int(H * fy)
    d.polygon([(0, yy_ - 4 * SS), (lw, yy_ - 3 * SS), (lw, yy_ + 3 * SS), (0, yy_ + 4 * SS)], fill=PAL['iron'] + (255,))
for fy in (0.12, 0.88):
    d.ellipse([0, int(H * fy) - 3 * SS, 7 * SS, int(H * fy) + 4 * SS], fill=(150, 150, 140, 255))
d.line([lw, int(H * 0.035), lw, int(H * 0.965)], fill=(10, 14, 20, 255), width=2 * SS)
d.line([0, 0, 0, H], fill=(10, 14, 20, 255), width=2 * SS)
layers['L1_door_leaf'] = im

# L2 gatehouse face + lintel course
x, y, w, h = R['L2_gatehouse_face']
m = masonry(w, h, 41, course=24, wmin=36, wmax=64, wrap=False, base=(60, 74, 82), moss=0.28, stain_from=0.80)
im = to_img(m)
# a darker vertical band toward the far (left, outer) edge reads as the quay wall turning away
d = ImageDraw.Draw(im, 'RGBA')
for i in range(40 * SS):
    d.line([i, 0, i, h * SS], fill=(6, 10, 14, int(110 * (1 - i / (40 * SS)))))
# dressed quoin stones on the mouth edge (right side, x 296)
qh = 30 * SS
for qy in range(0, h * SS, qh):
    qw = (30 + (qy // qh) % 2 * 10) * SS
    d.rectangle([w * SS - qw, qy + SS, w * SS - SS, qy + qh - SS], fill=(86, 100, 106, 255), outline=(14, 20, 26, 255))
# iron mooring ring on the quay face above the mouth
rx, ry = 244 * SS, 900 * SS
d.ellipse([rx - 12 * SS, ry - 12 * SS, rx + 12 * SS, ry + 12 * SS], outline=(30, 34, 40, 255), width=4 * SS)
d.rectangle([rx - 5 * SS, ry - 22 * SS, rx + 5 * SS, ry - 12 * SS], fill=(30, 34, 40, 255))
d.line([w * SS - 2 * SS, 0, w * SS - 2 * SS, h * SS], fill=(8, 12, 18, 255), width=3 * SS)
layers['L2_gatehouse_face'] = im

x, y, w, h = R['L2_lintel_course']
m = masonry(w, h, 51, course=30, wmin=44, wmax=76, wrap=True, base=(76, 90, 96), moss=0.05, stain_from=0.35)
im = to_img((m.astype(float) * 0.9).astype(np.uint8))
d = ImageDraw.Draw(im, 'RGBA')
# underside: soffit shadow plus tide stain so the physical ceiling edge (y1020) reads as heavy and damp
for i in range(14 * SS):
    d.line([0, h * SS - i, w * SS, h * SS - i], fill=(8, 14, 20, int(170 * (1 - i / (14 * SS)))))
d.line([0, h * SS - 2 * SS, w * SS, h * SS - 2 * SS], fill=(10, 14, 20, 255), width=2 * SS)
d.line([0, 0, w * SS, 0], fill=(150, 164, 160, 255), width=2 * SS)
layers['L2_lintel_course'] = im

# L3 back pier face
x, y, w, h = R['L3_back_pier']
m = masonry(w, h, 61, course=22, wmin=24, wmax=36, wrap=False, base=(62, 76, 84), moss=0.2, stain_from=0.55)
im = to_img(m)
d = ImageDraw.Draw(im, 'RGBA')
for i in range(10 * SS):                      # inner face (right) darkened toward the aperture reveal
    d.line([w * SS - i, 0, w * SS - i, h * SS], fill=(6, 10, 14, int(120 * (1 - i / (10 * SS)))))
layers['L3_back_pier'] = im

# L4 foreground corbel at the mouth (above Kaze's head, never over the walking envelope)
x, y, w, h = R['L4_mouth_corbel']
W, H = w * SS, h * SS
im = Image.new('RGBA', (W, H), (0, 0, 0, 0))
d = ImageDraw.Draw(im, 'RGBA')
d.polygon([(0, 0), (W, 0), (W, int(H * 0.45)), (int(W * 0.55), H), (0, H)], fill=(80, 94, 100, 255))
d.polygon([(0, 0), (W, 0), (W, 3 * SS), (0, 3 * SS)], fill=(150, 164, 160, 255))
d.line([(0, H - SS), (int(W * 0.55), H - SS), (W - SS, int(H * 0.45))], fill=(10, 14, 20, 255), width=2 * SS)
d.line([(0, 0), (0, H)], fill=(10, 14, 20, 255), width=2 * SS)
n = smooth_noise(W, H, 71, cell=8 * SS, octaves=2)
arr = np.asarray(im, float); arr[..., :3] *= (0.85 + 0.3 * n)[..., None]
im = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), 'RGBA')
layers['L4_mouth_corbel'] = im

# Write game-scale PNGs, 2x masters, ORA
meta = {}
for name, big in layers.items():
    x, y, w, h = R[name]
    small = down(big)
    assert small.size == (w, h), (name, small.size, (w, h))
    small.save(f'{OUT}/canal_{name}.png', optimize=False)
    big.save(f'{SRC}/masters_2x/canal_{name}_2x.png')
    meta[name] = dict(rect=[x, y, w, h])

# OpenRaster (layered, opens in Krita/GIMP): full R13 gate area 0..330 x 940..1210, bottom to top.
order = ['L0_hall_back_wall', 'L1_door_interior', 'L1_door_frame', 'L1_door_leaf', 'L2_gatehouse_face', 'L2_lintel_course', 'L3_back_pier', 'L4_mouth_corbel']
ox, oy, ow, oh = 0, 940, 330, 270
stack = ['<?xml version="1.0"?><image w="%d" h="%d"><stack>' % (ow, oh)]
z = zipfile.ZipFile(f'{SRC}/canal_layers.ora', 'w')
z.writestr('mimetype', 'image/openraster', compress_type=zipfile.ZIP_STORED)
for name in reversed(order):   # ORA lists top layer first
    x, y, w, h = R[name]
    lay = Image.new('RGBA', (ow, oh), (0, 0, 0, 0)); lay.alpha_composite(Image.open(f'{OUT}/canal_{name}.png'), (x - ox, y - oy)) if y - oy >= 0 else lay.alpha_composite(Image.open(f'{OUT}/canal_{name}.png').crop((0, oy - y, w, h)), (x - ox, 0))
    b = io.BytesIO(); lay.save(b, 'PNG'); z.writestr(f'data/{name}.png', b.getvalue())
    stack.append(f'<layer name="{name}" src="data/{name}.png" x="0" y="0" visibility="visible"/>')
stack.append('</stack></image>')
z.writestr('stack.xml', ''.join(stack)); z.close()
json.dump(meta, open(f'{SRC}/canal_layer_rects.json', 'w'), indent=1)
print('ok', list(layers))
