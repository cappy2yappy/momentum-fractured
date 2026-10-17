#!/usr/bin/env python3
"""ART-06 preview composer. Builds timed, gameplay-scale animated previews from the registered frames.

HONEST LABEL: these are PIL composites on stand-in rooms, NOT Godot framebuffer captures. In-room
Kaze is drawn at the real engine scale (0.38258) on a 1280x720 canvas; the cutaway uses the hero
strip at 2.4x. Timeline = 13 ticks of 50 ms = the loader's 0.65 s.
"""
import argparse, json, os, sys
import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageFilter
sys.path.insert(0, os.path.dirname(__file__))
import cutaway as cw

W, H = 1280, 720
GROUND = 520
RUN_SCALE = 0.3825780535911868
HERO_SCALE = RUN_SCALE * 2.4 / 2.0  # hero strips are 2x supersampled
TICK_MS = 50


def strip_cell(path, idx, cell):
    s = Image.open(path).convert("RGBA")
    return s.crop((idx * cell[0], 0, (idx + 1) * cell[0], cell[1]))


def place(canvas, sprite, scale, root_x, base_y, base_px, cell_w):
    w, h = round(sprite.width * scale), round(sprite.height * scale)
    sp = sprite.resize((w, h), Image.LANCZOS)
    x = round(root_x - (cell_w / 2) * scale)
    y = round(base_y - base_px * scale)
    canvas.alpha_composite(sp, (x, y)) if x >= 0 and y >= 0 else canvas.paste(sp, (x, y), sp)
    return sp, (x, y)


def outline(sprite, grow=9):
    a = sprite.getchannel("A").filter(ImageFilter.MaxFilter(grow if grow % 2 else grow + 1))
    o = Image.new("RGBA", sprite.size, cw.CREAM + (255,))
    o.putalpha(a)
    return o


def room(kind, label):
    img = Image.new("RGBA", (W, H), (0, 0, 0, 255))
    d = ImageDraw.Draw(img)
    top, bot = ((38, 52, 84), (14, 20, 36)) if kind == "src" else ((54, 78, 74), (16, 28, 30))
    for y in range(H):
        t = y / H
        d.line([(0, y), (W, y)], fill=tuple(int(top[i] * (1 - t) + bot[i] * t) for i in range(3)) + (255,))
    for i in range(9):  # distant ruin silhouettes
        x = (i * 173 + (40 if kind == "src" else 90)) % W
        hh = 120 + (i * 61) % 170
        d.rectangle([x, GROUND - hh, x + 70 + (i % 3) * 26, GROUND], fill=tuple(int(c * 0.55) for c in top) + (255,))
    d.rectangle([0, GROUND, W, H], fill=(30, 34, 46, 255))
    d.line([(0, GROUND), (W, GROUND)], fill=(150, 150, 165, 255), width=3)
    ex = 1150 if kind == "src" else 130
    d.rectangle([ex - 38, GROUND - 190, ex + 38, GROUND], outline=(220, 200, 150, 255), width=4)
    d.text((16, 14), label, fill=(235, 235, 235, 255))
    d.text((16, 30), "stand-in room (not game art); in-room Kaze at real engine scale 0.3826", fill=(200, 200, 200, 255))
    return img


def timeline(man, root, hero=True):
    """13 entries: (kind, clip, frame_index)."""
    return [("D", 0), ("D", 1), ("D", 2)] + [("T", i) for i in range(6)] + [("E", 0), ("E", 1), ("E", 2), ("E", 3)]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=".")
    ap.add_argument("--lat", default="assets/art06/kaze/lateral")
    ap.add_argument("--out", default="assets/art06/preview")
    a = ap.parse_args()
    man = json.load(open(os.path.join(a.root, a.lat, "MANIFEST.json")))
    cell = man["contract"]["cell_size"]
    base_px = man["contract"]["baseline_y"]
    clips = {c["id"]: c for c in man["clips"]}
    P = lambda c, hero=False: os.path.join(a.root, clips[c]["hero_path" if hero else "path"])
    src, dst = room("src", "SOURCE ROOM"), room("dst", "DESTINATION ROOM")
    os.makedirs(os.path.join(a.root, a.out), exist_ok=True)
    seq = timeline(man, a.root)
    frames, lum = [], []
    for tick, (kind, i) in enumerate(seq):
        world = (dst if tick >= 9 else src).copy()
        if kind == "D":
            spr = strip_cell(P("lat_depart"), i, cell)
            place(world, spr, RUN_SCALE, 760 + 8 * tick, GROUND, base_px, cell[0])
        elif kind == "E":
            spr = strip_cell(P("lat_emerge"), i, cell)
            place(world, spr, RUN_SCALE, 330 - 24 + 8 * (tick - 9), GROUND, base_px, cell[0])
        comp = world
        if cw.covered(float(tick)) or kind == "T":
            bg, fg = cw.render(float(tick))
            comp = Image.alpha_composite(comp, bg)
            if kind == "T":
                hs = strip_cell(P("lat_travel", True), i, [c * 2 for c in cell])
                w, h = round(hs.width * HERO_SCALE), round(hs.height * HERO_SCALE)
                hs = hs.resize((w, h), Image.LANCZOS)
                x, y = round(600 - w / 2), round(GROUND - base_px * 2 * HERO_SCALE)
                shadow = Image.new("RGBA", hs.size, cw.DEEP + (150,)); shadow.putalpha(hs.getchannel("A").point(lambda v: v * 150 // 255))
                comp.alpha_composite(shadow, (x + 12, y + 12))
                comp.alpha_composite(outline(hs), (x, y))
                comp.alpha_composite(hs, (x, y))
            comp = Image.alpha_composite(comp, fg)
        # draw hero outline layer for E0 only partially: nothing, in-room sprite is part of the world
        d = ImageDraw.Draw(comp)
        d.text((16, H - 22), f"tick {tick:02d}  t={tick * TICK_MS / 1000:.2f}s  {kind}{i}", fill=(255, 255, 255, 255))
        frames.append(comp.convert("RGB"))
        lum.append(float(np.asarray(comp.convert("L")).mean()))
    # QA: luminance step between ticks (photosensitivity guard)
    steps = [abs(lum[i + 1] - lum[i]) / 255 for i in range(len(lum) - 1)]
    print("mean luminance per tick:", [round(x, 1) for x in lum])
    print("max tick-to-tick mean-luminance step: %.1f%% of full range" % (100 * max(steps)))
    out = os.path.join(a.root, a.out)
    pal = [f.quantize(colors=128, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE) for f in frames]
    durations = [TICK_MS] * 12 + [TICK_MS + 450]
    pal[0].save(os.path.join(out, "lateral_pilot_sequence_20fps.gif"), save_all=True, append_images=pal[1:], duration=durations, loop=0, optimize=False)
    for i, f in enumerate(frames):
        f.save(os.path.join(out, f"tick_{i:02d}.png"))
    # contact board
    cols, tw = 5, 384
    th = int(H * tw / W)
    rows = (len(frames) + cols - 1) // cols
    board = Image.new("RGB", (cols * tw, rows * th), (0, 0, 0))
    for i, f in enumerate(frames):
        board.paste(f.resize((tw, th), Image.LANCZOS), ((i % cols) * tw, (i // cols) * th))
    board.save(os.path.join(out, "sequence_board.png"))
    json.dump({"mean_luminance": lum, "max_step_pct": 100 * max(steps), "ticks": len(frames), "tick_ms": TICK_MS,
               "label": "PIL composite on stand-in rooms, not a Godot capture"}, open(os.path.join(out, "preview_qa.json"), "w"), indent=1)


if __name__ == "__main__":
    main()
