#!/usr/bin/env python3
"""ART-06 asset processor: generated transparent masters -> production game textures.

Usage: process_assets.py MASTERS_DIR OUT_DIR
Deterministic: alpha cleanup (alpha<=16 -> 0), tight crop, Lanczos resize to the
production size listed below (world px at zoom 1.0), seamless horizontal tiles for
ledge/floor/pipe strips, 2px transparent margin on non-tiling sprites.
"""
import json, sys, hashlib
from pathlib import Path
from PIL import Image, ImageChops

# key: (master, mode, target) ; mode crop = fit width (w,None) or height (None,h)
SPEC = {
    "r18_ledge_cap_tile":   ("a11_ledge.png",     "tile", (512, 48)),
    "r18_floor_face_tile":  ("a22_floor.png",     "tile", (512, 140)),
    "r18_pipe_h_tile":      ("a13_pipe_h.png",    "tile", (512, 44)),
    "r18_masonry_pier":     ("a10_pier.png",      "fit",  (96, None)),
    "r18_relief_arch":      ("a15_arch.png",      "fit",  (360, None)),
    "r18_timber_beam":      ("a16_beam.png",      "fit",  (320, None)),
    "r18_pump_drum":        ("a12_pump.png",      "fit",  (420, None)),
    "r18_pipe_elbow":       ("a14_pipe_elbow.png","fit",  (None, 450)),
    "r18_broken_support":   ("a17_broken.png",    "fit",  (None, 380)),
    "r18_damaged_building": ("a18_building.png",  "fit",  (640, None)),
    "r18_fg_pipe_roots":    ("a19_fg.png",        "fit",  (None, 520)),
    "r18_isolator_frame":   ("a20_isolator.png",  "fit",  (None, 268)),
    "r18_lantern_bracket":  ("a21_lantern.png",   "fit",  (None, 96)),
    "r18_routing_plate":    ("a23_plate.png",     "fit",  (150, None)),
    "r18_steam_column":     ("a24_steam.png",     "fit",  (None, 220)),
    "r18_back_wall":        ("a25_backwall.png",  "fit",  (None, 700)),
}

def clean(im):
    im = im.convert("RGBA")
    r, g, b, a = im.split()
    a = a.point(lambda v: 0 if v <= 16 else v)
    im = Image.merge("RGBA", (r, g, b, a))
    return im.crop(a.getbbox())

def seamless(strip, width):
    """Take a centered band 1.25x target width and cross-fade its ends (25% overlap)."""
    w, h = strip.size
    band = int(width * 1.25)
    x0 = max(0, (w - band) // 2)
    src = strip.crop((x0, 0, x0 + band, h))
    ov = band - width
    out = src.crop((0, 0, width, h)).copy()
    tail = src.crop((width, 0, band, h))
    head = out.crop((0, 0, ov, h))
    mask = Image.linear_gradient("L").rotate(90, expand=True).resize((ov, h))  # 255 at left -> 0 at right
    blended = Image.composite(tail, head, mask)
    out.paste(blended, (0, 0))
    return out

def main(src, dst):
    src, dst = Path(src), Path(dst); dst.mkdir(parents=True, exist_ok=True)
    report = {}
    for key, (master, mode, (tw, th)) in SPEC.items():
        m = clean(Image.open(src / master))
        if mode == "tile":
            scale = th / m.height
            scaled = m.resize((max(tw, round(m.width * scale)), th), Image.LANCZOS)
            out = seamless(scaled, tw)
            # Opaque top rows are the walkable lip: force full alpha so the cap line is crisp.
            r, g, b, a = out.split()
            a = a.point(lambda v: 255 if v > 96 else v)
            out = Image.merge("RGBA", (r, g, b, a))
        else:
            scale = (tw / m.width) if tw else (th / m.height)
            size = (round(m.width * scale), round(m.height * scale))
            out = m.resize(size, Image.LANCZOS)
            pad = Image.new("RGBA", (size[0] + 4, size[1] + 4), (0, 0, 0, 0))
            pad.paste(out, (2, 2)); out = pad
        p = dst / f"{key}.png"
        out.save(p, optimize=True)
        report[key] = {"master": master, "size": list(out.size), "mode": mode,
                       "sha256": hashlib.sha256(p.read_bytes()).hexdigest()}
        print(key, out.size)
    (dst / "PROCESS_REPORT.json").write_text(json.dumps(report, indent=2))

if __name__ == "__main__":
    main(*sys.argv[1:3])
