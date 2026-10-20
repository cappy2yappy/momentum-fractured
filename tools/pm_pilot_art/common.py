"""Shared deterministic helpers for the PM-pilot Canal architecture art.
Everything here is procedural: seeded noise, masonry layout, shading. No generative model,
no network, no Higgsfield. Output is reproducible byte for byte on the same Pillow/numpy."""
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

SS = 2  # supersample factor; masters are saved at SS x, game assets are downsampled

# Palette taken from the repo room art and draw_exit (677074, 141c29, 63777a, 7c8c8b, 354850,
# d9c9ad, f4db96) so the layers sit with the existing night-canal masonry.
PAL = dict(
    stone_dark=(46, 58, 66), stone=(88, 106, 110), stone_lit=(124, 140, 139),
    mortar=(18, 26, 33), moss=(74, 100, 64), stain=(20, 34, 44),
    cool=(150, 190, 205), warm=(244, 219, 150), wood=(104, 70, 44), wood_dark=(58, 38, 26),
    iron=(40, 44, 52),
)

def rng(seed):
    return np.random.default_rng(seed)

def smooth_noise(w, h, seed, cell=24, octaves=3, wrap_x=False):
    """Value noise in [0,1], optionally tileable horizontally."""
    r = rng(seed)
    out = np.zeros((h, w)); amp = 1.0; tot = 0
    for o in range(octaves):
        c = max(2, cell // (2 ** o))
        gx = max(1, int(round(w / c))); gy = h // c + 2
        g = r.random((gy, gx + (0 if wrap_x else 1)))
        if wrap_x: g = np.concatenate([g, g[:, :1]], axis=1)
        im = Image.fromarray((g * 255).astype(np.uint8)).resize((w, h), Image.BICUBIC)
        out += np.asarray(im, dtype=float) / 255 * amp; tot += amp; amp *= 0.5
    return out / tot

def masonry(w, h, seed, course=22, wmin=30, wmax=58, wrap=True, base=None, moss=0.0, stain_from=0.55):
    """Dressed-stone wall at SS scale. Rows of blocks; widths sum exactly to w when wrap=True so
    the layer tiles horizontally."""
    base = base or PAL['stone']
    r = rng(seed)
    W, H = w * SS, h * SS
    img = Image.new('RGB', (W, H), PAL['mortar'])
    d = ImageDraw.Draw(img)
    y = 0; ch = course * SS
    while y < H:
        rh = ch + int(r.integers(-2, 3)) * SS // 2
        widths = []; total = 0
        while total < w:
            bw = int(r.integers(wmin, wmax + 1))
            if total + bw > w - wmin: bw = w - total
            widths.append(bw); total += bw
        shift = int(r.integers(0, w)) if wrap else 0   # stagger joints between courses
        acc = 0
        for bw in widths:
            tone = r.random()
            col = tuple(int(base[i] * (0.82 + 0.34 * tone)) for i in range(3))
            for ox in ([0, -W] if wrap else [0]):
                bx0 = (((acc + shift) % w) * SS if wrap else acc * SS) + ox
                rect = [bx0 + SS, y + SS, bx0 + bw * SS - SS, y + rh - SS]
                d.rectangle(rect, fill=col)
                d.line([rect[0], rect[1], rect[2], rect[1]], fill=tuple(min(255, int(c * 1.25)) for c in col), width=SS)
                d.line([rect[0], rect[1], rect[0], rect[3]], fill=tuple(min(255, int(c * 1.12)) for c in col), width=SS)
                d.line([rect[0], rect[3], rect[2], rect[3]], fill=tuple(int(c * 0.6) for c in col), width=SS)
                d.line([rect[2], rect[1], rect[2], rect[3]], fill=tuple(int(c * 0.72) for c in col), width=SS)
            acc += bw
        y += rh
    a = np.asarray(img, dtype=float)
    n = smooth_noise(W, H, seed + 1, cell=10 * SS, octaves=3, wrap_x=wrap)
    grain = rng(seed + 2).random((H, W))
    a *= (0.88 + 0.24 * n)[..., None] * (0.95 + 0.1 * grain)[..., None]
    if moss > 0:
        m = smooth_noise(W, H, seed + 3, cell=18 * SS, octaves=3, wrap_x=wrap)
        edge = np.linspace(0.6, 1.0, H)[:, None]
        mm = np.clip((m * edge - (1 - moss)) * 6, 0, 1)
        a = a * (1 - mm[..., None] * 0.7) + np.array(PAL['moss']) * (mm[..., None] * 0.7)
    # tide stain: darker, wetter lower band with ragged upper edge
    s = smooth_noise(W, H, seed + 4, cell=14 * SS, octaves=2, wrap_x=wrap)
    yy = np.linspace(0, 1, H)[:, None]
    stain = np.clip((yy - stain_from + (s - 0.5) * 0.18) * 6, 0, 1)
    a = a * (1 - stain[..., None] * 0.45) + np.array(PAL['stain']) * (stain[..., None] * 0.45)
    return np.clip(a, 0, 255).astype(np.uint8)

def to_img(a):
    return Image.fromarray(a).convert('RGBA')

def down(img):
    return img.resize((img.width // SS, img.height // SS), Image.LANCZOS)

def outline(mask_img, color=(10, 14, 20, 255), px=2):
    """Dark ink edge around the opaque area, matching the thick dark edges of the repo's room art."""
    a = np.asarray(mask_img.split()[-1])
    m = Image.fromarray(a).filter(ImageFilter.MaxFilter(2 * px * SS + 1))
    edge = np.asarray(m, dtype=int) - a
    o = np.zeros(a.shape + (4,), np.uint8)
    o[..., :3] = color[:3]; o[..., 3] = np.clip(edge, 0, 255) * 0 + (edge > 0) * color[3]
    return Image.alpha_composite(Image.fromarray(o), mask_img)
