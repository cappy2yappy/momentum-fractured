#!/usr/bin/env python3
"""ART-06 review package: ORA layered source, asset sheet, before/after boards, manifest.

Usage: build_package.py LAYOUT ASSET_DIR PASS_DIR MOCK_DIR CONCEPT_DIR OUT_DIR
"""
import json, sys, zipfile, hashlib, io
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
sys.path.insert(0, str(Path(__file__).parent))
import compose_mockup as cm

def font(size):
    for p in ["/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", "/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf"]:
        try: return ImageFont.truetype(p, size)
        except OSError: pass
    return ImageFont.load_default()

def checker(w, h, s=16):
    im = Image.new("RGBA", (w, h), (70, 74, 84, 255)); d = ImageDraw.Draw(im)
    for y in range(0, h, s):
        for x in range((y // s % 2) * s, w, 2 * s): d.rectangle([x, y, x + s - 1, y + s - 1], fill=(88, 92, 104, 255))
    return im

def asset_sheet(asset_dir, out):
    files = sorted(p for p in Path(asset_dir).glob("r18_*.png"))
    cols, cell = 4, 340; rows = (len(files) + cols - 1) // cols
    sheet = Image.new("RGBA", (cols * cell, rows * (cell + 40) + 60), (30, 32, 40, 255)); d = ImageDraw.Draw(sheet)
    d.text((16, 16), "ART-06 R18 modular set: transparent PNG, 1 px = 1 world px at zoom 1.0 (shown scaled to fit)", fill=(230, 220, 200), font=font(20))
    for i, f in enumerate(files):
        im = Image.open(f).convert("RGBA"); x, y = (i % cols) * cell, 60 + (i // cols) * (cell + 40)
        bg = checker(cell - 20, cell - 20); s = min((cell - 30) / im.width, (cell - 30) / im.height, 1.0)
        t = im.resize((max(1, round(im.width * s)), max(1, round(im.height * s))), Image.LANCZOS)
        bg.alpha_composite(t, ((bg.width - t.width) // 2, (bg.height - t.height) // 2)); sheet.alpha_composite(bg, (x + 10, y))
        d.text((x + 12, y + cell - 14), f"{f.stem}  {im.width}x{im.height}", fill=(230, 220, 200), font=font(14))
    sheet.convert("RGB").save(out)

def stack_ora(layout, asset_dir, passes, out):
    W, H = layout["world_size"]
    layers = []
    names = ["fg_occluder", "gate_dressing", "surface", "support", "bg_props", "bg_wall", "bg_far"]
    for L in names: layers.append((f"ART06 {L}", cm.world_layer(layout, asset_dir, L), True))
    guide = Image.new("RGBA", (W, H)); d = ImageDraw.Draw(guide)
    for s in layout["surfaces"]:
        x, y, w, h = s["rect"]; col = (80, 220, 255, 255) if s["collider"] == "one_way" else (255, 70, 70, 255)
        d.rectangle([x, y, x + w, y + h], outline=col, width=3)
    for k in layout["keep_clear"]:
        if "circle" in k: x, y, r = k["circle"]; d.ellipse([x - r, y - r, x + r, y + r], outline=(140, 255, 120, 255), width=3)
        else: x, y, w, h = k["rect"]; d.rectangle([x, y, x + w, y + h], outline=(255, 210, 60, 255), width=3)
    layers.insert(0, ("GUIDE colliders + keep-clear (hidden, do not export)", guide, False))
    stack = ['<?xml version="1.0" encoding="UTF-8"?>', f'<image version="0.0.3" w="{W}" h="{H}">', "<stack>"]
    z = zipfile.ZipFile(out, "w")
    z.writestr(zipfile.ZipInfo("mimetype"), "image/openraster")  # first, stored
    for i, (name, im, vis) in enumerate(layers):
        buf = io.BytesIO(); im.save(buf, "PNG"); z.writestr(f"data/layer{i:02d}.png", buf.getvalue(), zipfile.ZIP_DEFLATED)
        stack.append(f'<layer name="{name}" src="data/layer{i:02d}.png" x="0" y="0" opacity="1.0" visibility="{"visible" if vis else "hidden"}"/>')
    flat = Image.new("RGBA", (W, H), (20, 22, 30, 255))
    for name, im, vis in reversed(layers):
        if vis: flat.alpha_composite(im)
    buf = io.BytesIO(); flat.save(buf, "PNG"); z.writestr("mergedimage.png", buf.getvalue())
    th = flat.copy(); th.thumbnail((256, 256)); buf = io.BytesIO(); th.save(buf, "PNG"); z.writestr("Thumbnails/thumbnail.png", buf.getvalue())
    stack += ["</stack>", "</image>"]; z.writestr("stack.xml", "\n".join(stack)); z.close()
    flat.convert("RGB").save(Path(out).with_suffix(".flat.png"))

def board(pairs, out, title):
    w = 1280; h = 720; pad = 40
    im = Image.new("RGB", (w * 2 + pad * 3, (h + pad) * len(pairs) + 80), (24, 26, 34)); d = ImageDraw.Draw(im)
    d.text((pad, 24), title, fill=(235, 225, 205), font=font(28))
    for i, (label, a, b) in enumerate(pairs):
        y = 80 + i * (h + pad)
        im.paste(Image.open(a).convert("RGB"), (pad, y)); im.paste(Image.open(b).convert("RGB"), (pad * 2 + w, y))
        d.text((pad + 8, y + h - 34), f"BEFORE  {label}  (native Godot 4.6.1, zoom 1.0)", fill=(255, 255, 255), font=font(20))
        d.text((pad * 2 + w + 8, y + h - 34), f"AFTER  {label}  (ART-06 dressing registered to same frame)", fill=(255, 255, 255), font=font(20))
    im.save(out, quality=90) if str(out).endswith(".jpg") else im.save(out)

def main(layout_p, assets, passes, mock, concepts, out):
    layout = json.load(open(layout_p)); out = Path(out); out.mkdir(parents=True, exist_ok=True)
    passes, mock, concepts = Path(passes), Path(mock), Path(concepts)
    asset_sheet(assets, out / "MODULAR_SET_SHEET.png")
    stack_ora(layout, assets, passes, out / "r18_dressing_layers.ora")
    views = ["west_arrival", "guard_shelf", "lower_bay", "lore_shelf", "east_gate"]
    board([(v, passes / f"{v}_plate.png", mock / f"r18_after_{v}.png") for v in views[:3]], out / "BEFORE_AFTER_A.jpg", "R18 Pump Gallery: gameplay-scale before / after (1 of 2)")
    board([(v, passes / f"{v}_plate.png", mock / f"r18_after_{v}.png") for v in views[3:]] + [("overview", passes / "overview_plate.png", mock / "r18_after_overview.png")], out / "BEFORE_AFTER_B.jpg", "R18 Pump Gallery: gameplay-scale before / after (2 of 2)")
    board([(v, mock / f"r18_after_{v}.png", mock / f"r18_after_{v}_collision.png") for v in ["overview", "guard_shelf"]], out / "COLLISION_AGREEMENT.jpg", "Art vs runtime colliders: cyan = one-way top, red = solid, yellow = keep-clear, green = tether anchor")
    man = {}
    for p in sorted(list(out.glob("*")) + list(Path(assets).glob("*.png")) + list(concepts.glob("*.png")) + list(mock.glob("*.png"))):
        if p.is_file(): man[str(p.relative_to(p.parents[1]))] = hashlib.sha256(p.read_bytes()).hexdigest()
    (out / "PACKAGE_MANIFEST.json").write_text(json.dumps(man, indent=1))
    print("package files", len(man))

if __name__ == "__main__":
    main(*sys.argv[1:7])
