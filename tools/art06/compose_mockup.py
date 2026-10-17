#!/usr/bin/env python3
"""ART-06 registered mockup compositor.

Reproduces the draw order the proposed Godot overlay would have (world draw ->
ART-06 dressing -> Kaze/enemies -> foreground occluders -> HUD) from native
Godot 4.6.1 render passes, placing every asset at its layout world coordinates.

Usage: compose_mockup.py LAYOUT ASSET_DIR PASS_DIR OUT_DIR [GEOMETRY_JSON]
"""
import json, sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageEnhance, ImageChops, ImageFilter

ORDER = ["bg_far", "bg_wall", "bg_props", "support", "surface", "gate_dressing"]
SUPPORT_DARKEN = 0.85

def load(asset_dir, name, cache={}):
    if name not in cache: cache[name] = Image.open(Path(asset_dir) / f"{name}.png").convert("RGBA")
    return cache[name]

def tiled(tex, w, h):
    t = tex.resize((tex.width, h), Image.LANCZOS) if tex.height != h else tex
    out = Image.new("RGBA", (max(1, w), h))
    for x in range(0, w, t.width): out.paste(t, (x, 0))
    return out

def pier(tex, w, h, top=24, bottom=56):
    s = w / tex.width
    t = tex.resize((w, round(tex.height * s)), Image.LANCZOS)
    top, bottom = round(top * s), round(bottom * s)
    out = Image.new("RGBA", (w, h))
    if h <= top + bottom:
        return t.crop((0, t.height - h, w, t.height))
    mid = t.crop((0, top, w, t.height - bottom))
    out.paste(t.crop((0, 0, w, top)), (0, 0))
    for y in range(top, h - bottom, mid.height): out.paste(mid, (0, y))
    out.paste(t.crop((0, t.height - bottom, w, t.height)), (0, h - bottom))
    return out

def modulate(im, m):
    if not m: return im
    r, g, b, a = im.split()
    r = r.point(lambda v: int(v * m[0])); g = g.point(lambda v: int(v * m[1])); b = b.point(lambda v: int(v * m[2]))
    a = a.point(lambda v: int(v * m[3]))
    return Image.merge("RGBA", (r, g, b, a))

def world_layer(layout, assets, layer):
    W, H = layout["world_size"]
    canvas = Image.new("RGBA", (W, H))
    def put(im, x, y):
        x, y = round(x), round(y)
        sx, sy = max(0, -x), max(0, -y)
        if sx or sy: im = im.crop((sx, sy, im.width, im.height)); x, y = x + sx, y + sy
        if x < W and y < H: canvas.alpha_composite(im.crop((0, 0, min(im.width, W - x), min(im.height, H - y))), (x, y))
    if layer == "surface":
        for s in layout["surfaces"]:
            x, y, w, h = s["rect"]
            tex = load(assets, s["tile"])
            th = 140 if s["id"] == "floor" else tex.height  # caps keep 8px lip below the 40px collider
            put(tiled(tex, round(w), th), x, y)
    elif layer == "support":
        for s in layout["supports"]:
            tex = load(assets, s["asset"])
            if "x" in s: im = pier(tex, s["w"], s["bottom"] - s["top"]); put(modulate(im, [SUPPORT_DARKEN] * 3 + [1]), s["x"], s["top"])
            else:
                x, y, w, h = s["rect"]; put(modulate(tex.resize((round(w), round(h)), Image.LANCZOS), [SUPPORT_DARKEN] * 3 + [1]), x, y)
    for p in layout["props"]:
        if p["layer"] != layer: continue
        x, y, w, h = p["rect"]; tex = load(assets, p["asset"])
        im = tiled(tex, round(w), round(h)) if p.get("tile") else tex.resize((round(w), round(h)), Image.LANCZOS)
        if p.get("flip_h"): im = im.transpose(Image.FLIP_LEFT_RIGHT)
        put(modulate(im, p.get("modulate")), x, y)
    return canvas

def markers(passes, view):
    """Runtime-drawn interactive markers = pixels that change when markers are switched off.
    Enclosed interiors (door frames, anchor rings) are filled so they stay intact."""
    a = Image.open(passes / f"{view}_plate.png").convert("RGB")
    b = Image.open(passes / f"{view}_plate_nomarkers.png").convert("RGB")
    diff = ImageChops.difference(a, b).convert("L").point(lambda v: 255 if v > 4 else 0)
    diff = diff.filter(ImageFilter.MaxFilter(3)).filter(ImageFilter.MinFilter(3))
    outside = diff.copy(); ImageDraw.floodfill(outside, (0, 0), 128)
    mask = outside.point(lambda v: 0 if v == 128 else 255)
    m = a.convert("RGBA"); m.putalpha(mask)
    return m

def to_screen(world_img, cam):
    cx, cy = cam["center"]; z = cam["zoom"]
    tl = (cx - 640 / z, cy - 360 / z)
    crop = world_img.crop((round(tl[0]), round(tl[1]), round(tl[0] + 1280 / z), round(tl[1] + 720 / z)))
    return crop.resize((1280, 720), Image.LANCZOS) if z != 1 else crop

def overlay_geometry(img, layout, cam, geo):
    d = ImageDraw.Draw(img, "RGBA"); cx, cy = cam["center"]; z = cam["zoom"]
    S = lambda x, y: ((x - cx) * z + 640, (y - cy) * z + 360)
    for b in geo["bodies"]:
        x0, y0 = S(b["x"], b["y"]); x1, y1 = S(b["x"] + b["w"], b["y"] + b["h"])
        col = (80, 220, 255, 230) if b["one_way"] else (255, 70, 70, 230)
        d.rectangle([x0, y0, x1, y1], outline=col, width=2)
        if b["one_way"]: d.line([x0, y0, x1, y0], fill=(80, 220, 255, 255), width=4)
    for k in layout["keep_clear"]:
        if "circle" in k:
            x, y, r = k["circle"]; a, b = S(x - r, y - r); c, e = S(x + r, y + r)
            d.ellipse([a, b, c, e], outline=(140, 255, 120, 220), width=2)
        else:
            x, y, w, h = k["rect"]; a, b = S(x, y); c, e = S(x + w, y + h)
            d.rectangle([a, b, c, e], outline=(255, 210, 60, 200), width=2)
    return img

def main(layout_p, assets, passes, out, geo_p=None):
    layout = json.load(open(layout_p)); passes, out = Path(passes), Path(out); out.mkdir(parents=True, exist_ok=True)
    cams = json.load(open(passes / "cameras.json")); geo = json.load(open(geo_p)) if geo_p else None
    layers = {L: world_layer(layout, assets, L) for L in ORDER + ["fg_occluder"]}
    for view, cam in cams.items():
        img = Image.open(passes / f"{view}_plate_nomarkers.png").convert("RGBA")
        for L in ORDER: img.alpha_composite(to_screen(layers[L], cam))
        img.alpha_composite(markers(passes, view))
        img.alpha_composite(Image.open(passes / f"{view}_actors.png").convert("RGBA"))
        img.alpha_composite(to_screen(layers["fg_occluder"], cam))
        hud = passes / f"{view}_hud.png"
        if hud.exists(): img.alpha_composite(Image.open(hud).convert("RGBA"))
        img.convert("RGB").save(out / f"r18_after_{view}.png")
        if geo:
            overlay_geometry(img.copy(), layout, cam, geo).convert("RGB").save(out / f"r18_after_{view}_collision.png")
        print("mockup", view)

if __name__ == "__main__":
    main(*sys.argv[1:])
