#!/usr/bin/env python3
"""ART-08 descent QA: posture metrics measured from the rendered pixels (not from rig parameters).
spine angle  = angle of the line skirt-centroid (waist) -> collar (white collar pixels above the cuffs) from vertical, + = leaning forward (toward facing)
head offset  = horizontal distance collar -> centroid of face skin pixels above the collar, px in the 480x724 cell (+ = head ahead of the collar)
neck-pelvis  = vertical gap, for normalising
Run: python3 qa_spine.py <label> <strips_dir> <out.json>   (strips_dir holds stair_descend_{enter,loop,exit}_strip.png + .json)"""
import json, os, sys, math
import numpy as np
from PIL import Image

def metrics(frame, pelvis):
    a = frame[..., 3] > 128
    rgb = frame[..., :3].astype(int)
    yy, xx = np.mgrid[0:frame.shape[0], 0:frame.shape[1]]
    sk = a & (rgb.sum(-1) < 260) & ((rgb[..., 2] - rgb[..., 0]) < 14) & (abs(yy - pelvis[1]) < 60) & (abs(xx - pelvis[0]) < 80)
    if sk.sum() < 30: return None
    waist = (float(xx[sk].mean()), float(yy[sk].mean())); pelvis = waist
    white = a & (rgb.min(-1) > 215)
    ys, xs = np.nonzero(white)
    sel = ys < pelvis[1] - 50
    if sel.sum() < 4: return None
    cx, cy = xs[sel].mean(), ys[sel].mean()
    skin = a & (rgb[..., 0] > rgb[..., 2] + 40) & (rgb[..., 0] > 120) & (rgb[..., 1] > 60)
    sy, sx = np.nonzero(skin)
    m = (sy < cy - 4) & (sy > cy - 70)
    hx, hy = (sx[m].mean(), sy[m].mean()) if m.sum() > 10 else (cx, cy)
    spine = math.degrees(math.atan2(cx - pelvis[0], pelvis[1] - cy))
    return dict(waist=waist, spine_deg=spine, head_offset_px=float(hx - cx), collar=(float(cx), float(cy)), neck_pelvis_px=float(pelvis[1] - cy))

def main(label, d, out):
    res = {}
    for clip in ("enter", "loop", "exit"):
        name = f"stair_descend_{clip}"
        im = np.array(Image.open(os.path.join(d, name + "_strip.png")).convert("RGBA"))
        meta = json.load(open(os.path.join(d, name + ".json")))
        rows = []
        for i, p in enumerate(meta["poses"]):
            fr = im[:, i * 480:(i + 1) * 480]
            m = metrics(fr, p["pelvis"])
            if m: rows.append(m)
        sp = [r["spine_deg"] for r in rows]; ho = [r["head_offset_px"] for r in rows]
        res[name] = dict(frames=len(rows), spine_deg=dict(mean=round(float(np.mean(sp)), 1), min=round(min(sp), 1), max=round(max(sp), 1)),
                         head_offset_px=dict(mean=round(float(np.mean(ho)), 1), min=round(min(ho), 1), max=round(max(ho), 1)),
                         per_frame_spine=[round(x, 1) for x in sp])
    json.dump(dict(label=label, metrics=res), open(out, "w"), indent=1); print(json.dumps(res, indent=0)[:1500])

if __name__ == "__main__":
    main(*sys.argv[1:4])
