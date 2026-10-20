"""Original wind-cloth wipe kit, matching the repo's TR-02 direction (angled indigo/rose panels, pale thread lines,
directional travel, destination badge). Procedural, no external art, no Persona assets."""
import os, sys
sys.path.insert(0, os.path.dirname(__file__))
from common import *
OUT = 'assets/pm_pilot/wipe'; os.makedirs(OUT, exist_ok=True)
PW, PH = 1800, 300   # panel size; skew ~ 10 deg, drawn for travel toward -x (leftward); flip_h for rightward

def panel(seed, indigo, rose):
    W, H = PW * SS, PH * SS
    skew = int(H * 0.35)
    base = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    mask = Image.new('L', (W, H), 0)
    ImageDraw.Draw(mask).polygon([(skew, 0), (W, 0), (W - skew, H), (0, H)], fill=255)
    n = smooth_noise(W, H, seed, cell=60 * SS, octaves=3)
    yy = np.linspace(0, 1, H)[:, None]
    xx = np.linspace(0, 1, W)[None, :]
    k = (0.55 + 0.45 * (1 - xx)) * (0.85 + 0.3 * n)           # cloth fold shading, trailing edge lighter
    rgb = np.zeros((H, W, 3), float)
    for i in range(3): rgb[..., i] = indigo[i] * k * (0.8 + 0.4 * yy[:, 0:1] * 0 + 0.2 * (1 - yy))
    # long diagonal fold highlights
    for f in (0.2, 0.5, 0.78):
        band = np.exp(-(((xx + (yy - 0.5) * 0.25) - f) / 0.015) ** 2)
        rgb += band[..., None] * np.array(rose, float) * 0.18
    im = Image.fromarray(np.clip(rgb, 0, 255).astype(np.uint8)).convert('RGBA')
    im.putalpha(mask)
    d = ImageDraw.Draw(im, 'RGBA')
    # pale thread lines following the panel diagonal, and a rose leading edge
    for t in (0.18, 0.38, 0.62, 0.84):
        y = int(H * t)
        x0 = int(skew * (1 - t)); x1 = W - int(skew * t)
        d.line([x0, y, x1, y], fill=(224, 214, 232, 150), width=SS)
    d.line([skew, 0, 0, H], fill=rose + (255,), width=5 * SS)       # leading (left) edge
    d.line([W - skew, H, W, 0], fill=(224, 214, 232, 120), width=2 * SS)
    return down(im)

panels = [panel(81, (52, 41, 79), (209, 130, 158)), panel(82, (62, 49, 94), (209, 130, 158)), panel(83, (72, 57, 105), (209, 130, 158))]
panels = [p.rotate(6, expand=True, resample=Image.BICUBIC) for p in panels]   # tilt the whole cloth band; thread lines run along the tilt
for i, p in enumerate(panels): p.save(f'{OUT}/wipe_panel_{"abc"[i]}.png')

# destination badge plate (text is drawn by the engine; no font is shipped)
W, H = 460, 54
b = Image.new('RGBA', (W * SS, H * SS), (0, 0, 0, 0)); d = ImageDraw.Draw(b)
d.rectangle([0, 0, W * SS, H * SS], fill=(20, 20, 43, 230))
d.rectangle([0, (H - 4) * SS, W * SS, H * SS], fill=(209, 130, 158, 255))
d.rectangle([0, 0, 8 * SS, H * SS], fill=(212, 182, 206, 255))
down(b).save(f'{OUT}/wipe_badge_plate.png')
print('wipe ok')
