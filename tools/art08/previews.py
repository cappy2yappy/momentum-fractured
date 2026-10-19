#!/usr/bin/env python3
"""ART-08 previews: labelled contact sheets and GIFs at game scale (0.303125, shown 3x) and cinematic scale (1.9x).
Labels carry provenance. Stair clips are composited over a drawn stair profile (stand-in, from the measured treads)."""
import json, os, sys
import numpy as np
from PIL import Image, ImageDraw, ImageFont
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import rig
ROOT = rig.ROOT
OUT = os.path.join(ROOT, "docs/art/art08")
W, H = 480, 724

def font(sz):
    for p in ("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", "/usr/share/fonts/dejavu/DejaVuSans.ttf"):
        if os.path.exists(p): return ImageFont.truetype(p, sz)
    return ImageFont.load_default()

def strip_frames(path, n):
    a = Image.open(path).convert("RGBA")
    return [a.crop((i * W, 0, (i + 1) * W, H)) for i in range(n)]

def label(img, lines, size=13):
    d = ImageDraw.Draw(img); f = font(size); y = 4
    for ln in lines:
        d.rectangle([2, y - 1, 2 + d.textlength(ln, font=f) + 4, y + size + 2], fill=(0, 0, 0))
        d.text((4, y), ln, fill=(255, 255, 255), font=f); y += size + 4
    return img

def compose(frame, bg=None, scale=1.0, crop=(40, 230, 440, 660), flip=False):
    base = Image.new("RGBA", (W, H), (96, 112, 122, 255)) if bg is None else bg.copy()
    if bg is not None and base.mode != "RGBA": base = base.convert("RGBA")
    if bg is not None:
        base2 = Image.new("RGBA", (W, H), (96, 112, 122, 255)); base2.alpha_composite(bg); base = base2
    f = frame.transpose(Image.FLIP_LEFT_RIGHT) if flip else frame
    base.alpha_composite(f)
    im = base.convert("RGB").crop(crop)
    if scale != 1.0: im = im.resize((int(im.width * scale), int(im.height * scale)), Image.LANCZOS if scale < 1 else Image.BICUBIC)
    return im

def save_gif(frames, path, fps, loops=0):
    q = [f.convert("P", palette=Image.ADAPTIVE, colors=128) for f in frames]
    q[0].save(path, save_all=True, append_images=q[1:], duration=int(1000 / fps), loop=loops, optimize=False, disposal=2)

def sheet(clip, frames, title, bgs=None, cols=8, scale=0.7):
    ims = []
    for i, f in enumerate(frames):
        im = compose(f, bgs[i] if bgs else None, scale)
        d = ImageDraw.Draw(im); d.text((4, im.height - 16), f"f{i}", fill=(255, 255, 0), font=font(12)); ims.append(im)
    w, h = ims[0].size; rows = (len(ims) + cols - 1) // cols
    S = Image.new("RGB", (w * min(cols, len(ims)), h * rows + 44), (30, 30, 30))
    for i, im in enumerate(ims): S.paste(im, ((i % cols) * w, 44 + (i // cols) * h))
    label(S, title, 12)
    return S

def make(clip_entry, bg_fn=None, tag=None):
    """clip_entry: manifest dict. bg_fn(i) -> RGBA bg image or None."""
    name = clip_entry["name"]; n = clip_entry["hframes"]; fps = clip_entry["fps"]
    frames = strip_frames(os.path.join(ROOT, clip_entry["strip"]), n)
    bgs = [bg_fn(i) for i in range(n)] if bg_fn else None
    title = [f"ART-08 {name}  {n}f @ {fps}fps  loop={clip_entry['loop']}  status={clip_entry['status']}",
             "provenance: " + clip_entry["provenance"][:150]]
    os.makedirs(os.path.join(OUT, "sheets"), exist_ok=True); os.makedirs(os.path.join(OUT, "gif"), exist_ok=True)
    sheet(name, frames, title, bgs, cols=min(n, 8)).save(os.path.join(OUT, "sheets", f"{name}_sheet.png"))
    # game scale: sprite scale 0.303125 -> shown 3x nearest so it is viewable
    g = []
    for i, f in enumerate(frames):
        im = compose(f, bgs[i] if bgs else None, 1.0)
        sm = im.resize((int(im.width * 0.303125), int(im.height * 0.303125)), Image.LANCZOS)
        big = sm.resize((sm.width * 3, sm.height * 3), Image.NEAREST)
        g.append(label(big, [f"{name} f{i} game scale 0.303 (x3 view)", "ART-08 rig candidate"], 11))
    save_gif(g, os.path.join(OUT, "gif", f"{name}_game.gif"), fps)
    c = []
    for i, f in enumerate(frames):
        im = compose(f, bgs[i] if bgs else None, 1.9)
        c.append(label(im, [f"{name} f{i} cinematic 1.9x", "provenance: " + clip_entry["provenance"][:60]], 12))
    save_gif(c, os.path.join(OUT, "gif", f"{name}_cine.gif"), fps)
