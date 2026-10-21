#!/usr/bin/env python3
"""Build before/after descent comparison from two real-cinematic capture dirs (frames captured every TR08_EVERY ticks at 60 Hz).
Usage: descent_compare.py <before_dir> <after_dir> <out_dir> <every_ticks>
Outputs contact sheet(s) and a side-by-side GIF at native speed (frame delay = every/60 s)."""
import sys, os, glob, json
from PIL import Image, ImageDraw
def frames(d):
    fs = sorted(glob.glob(os.path.join(d, "stair_17-14_*_t*.png")))
    fs = [f for f in fs if "_-1_" not in os.path.basename(f) and "_99_" not in os.path.basename(f)]
    return fs
def main(bd, ad, out, every):
    every = int(every); os.makedirs(out, exist_ok=True)
    b, a = frames(bd), frames(ad); n = max(len(b), len(a)); print("frames", len(b), len(a))
    W = 640; ims = []
    for i in range(n):
        L = Image.open(b[min(i, len(b) - 1)]).convert("RGB"); R = Image.open(a[min(i, len(a) - 1)]).convert("RGB")
        sc = W / L.width; L = L.resize((W, int(L.height * sc))); R = R.resize((W, int(R.height * sc)))
        c = Image.new("RGB", (W * 2 + 6, L.height + 22), (20, 20, 20)); c.paste(L, (0, 22)); c.paste(R, (W + 6, 22))
        d = ImageDraw.Draw(c); t = i * every / 60.0
        d.text((6, 5), f"BEFORE (v1 descent, PR62 head 82d5998)   t={t:.2f}s", fill=(255, 200, 120)); d.text((W + 12, 5), f"AFTER (v2 descent, upright, stair_down_key donor)   t={t:.2f}s", fill=(140, 255, 160))
        ims.append(c)
    ims[0].save(os.path.join(out, "descent_before_after.gif"), save_all=True, append_images=ims[1:], duration=int(round(every / 60.0 * 1000)), loop=0, optimize=True)
    cols = 4; sel = ims[::max(1, len(ims) // 12)][:12]; rows = (len(sel) + cols - 1) // cols
    cw, ch = sel[0].size; sh = Image.new("RGB", (cw // 2 * 2, 0))
    s = Image.new("RGB", (cw * 2 // 2 * 1, ch * len(sel) // 2)); 
    # contact sheet: one before/after pair per row, 6 rows, half size
    pick = ims[::max(1, len(ims) // 8)][:8]
    sheet = Image.new("RGB", (pick[0].width // 2, (pick[0].height // 2) * len(pick)))
    for k, im in enumerate(pick): sheet.paste(im.resize((im.width // 2, im.height // 2)), (0, k * (im.height // 2)))
    sheet.save(os.path.join(out, "descent_before_after_sheet.png"))
if __name__ == "__main__":
    main(*sys.argv[1:5])
