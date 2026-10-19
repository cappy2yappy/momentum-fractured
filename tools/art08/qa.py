#!/usr/bin/env python3
"""ART-08 quality gates. Usage: qa.py <clip> ... (reads source_art/art08/frames/<clip>_strip.png + <clip>.json)
Writes docs/art/art08/qa/<clip>.json and prints a summary. Gates are measurements, not creative acceptance."""
import json, os, sys, math, itertools
import numpy as np, cv2
from PIL import Image
from scipy.spatial import cKDTree
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import rig, gait

ROOT = rig.ROOT
FR = os.path.join(ROOT, "source_art/art08/frames")
OUTQ = os.path.join(ROOT, "docs/art/art08/qa")
W, H = rig.CELL

def load_strip(path, n):
    a = np.array(Image.open(path).convert("RGBA"))
    assert a.shape[0] == H and a.shape[1] == W * n, (a.shape, n)
    return [a[:, i * W:(i + 1) * W] for i in range(n)]

_pal = None
def approved_palette():
    global _pal
    if _pal is None:
        cols = []
        srcs = ["assets/art04/kaze/stair_up_key.png", "assets/art04/kaze/turn_depth_key.png", "assets/art04/kaze/enter_depth_key.png",
                "assets/kaze/cleaned/kaze_run_strip.png", "assets/kaze/cleaned/kaze_idle_strip.png"]
        for s in srcs:
            a = np.array(Image.open(os.path.join(ROOT, s)).convert("RGBA")); m = a[..., 3] > 250
            c = (a[m][:, :3] // 4) * 4
            cols.append(np.unique(c, axis=0))
        allc = np.unique(np.concatenate(cols), axis=0)
        _pal = cKDTree(allc.astype(np.float32))
    return _pal

def palette_drift(f, thr=24.0):
    m = f[..., 3] > 250
    px = f[m][:, :3].astype(np.float32)
    if len(px) == 0: return 1.0
    d, _ = approved_palette().query(px)
    return float((d > thr).mean())

def class_means(f):
    """mean colour of ribbon green / jacket purple / skin per frame (compared with donor)"""
    m = f[..., 3] > 250; rgb = f[..., :3].astype(int)
    green = m & (rgb[..., 1] > rgb[..., 0] + 60) & (rgb[..., 1] > 150)
    purple = m & (rgb[..., 2] > 125) & (rgb[..., 0] > 80) & (rgb[..., 0] < 150) & (rgb[..., 1] < 75)
    skin = m & (rgb[..., 0] > rgb[..., 2] + 40) & (rgb[..., 1] > 80)
    r = {}
    for k, mk in (("green", green), ("purple", purple), ("skin", skin)):
        r[k] = rgb[mk].mean(0).round(1).tolist() if mk.sum() > 30 else None
    return r

def silhouette_stats(f):
    a = (f[..., 3] > 20).astype(np.uint8)
    ys, xs = np.nonzero(a)
    n, lab, st, _ = cv2.connectedComponentsWithStats(a, connectivity=8)
    big = [int(st[i, cv2.CC_STAT_AREA]) for i in range(1, n) if st[i, cv2.CC_STAT_AREA] > 40]
    return dict(bbox=[int(xs.min()), int(ys.min()), int(xs.max()), int(ys.max())], height=int(ys.max() - ys.min() + 1),
                margin_l=int(xs.min()), margin_r=int(W - 1 - xs.max()), margin_t=int(ys.min()), margin_b=int(H - 1 - ys.max()),
                components=len(big), specks=int(n - 1 - len(big)), lowest_row=int(ys.max()), area=int(a.sum()))

def band_xor(fa, fb, y0, y1):
    a = fa[y0:y1, :, 3] > 40; b = fb[y0:y1, :, 3] > 40
    u = (a | b).sum()
    return float((a ^ b).sum() / max(u, 1))

def run_clip(name, loop=False, plan_fn=None, expected_lowest=None):
    strip = os.path.join(FR, f"{name}_strip.png"); meta = json.load(open(os.path.join(FR, f"{name}.json")))
    n = len(meta["times"]); frames = load_strip(strip, n)
    rep = dict(clip=name, frames=n, cell=[W, H])
    # limb difference: legs (below hip, rows 440..650) and arm/upper (rows 300..470, x<=...)
    leg = [[band_xor(frames[i], frames[j], 470, 660) for j in range(n)] for i in range(n)]
    upper = [[band_xor(frames[i], frames[j], 300, 470) for j in range(n)] for i in range(n)]
    adj = [leg[i][(i + 1) % n] for i in range(n - (0 if loop else 1))]
    pairs = [leg[i][j] for i in range(n) for j in range(i + 1, n)]
    rep["leg_band_xor"] = dict(min_adjacent=round(min(adj), 3), mean_adjacent=round(float(np.mean(adj)), 3), min_any_pair=round(min(pairs), 3), mean_pairs=round(float(np.mean(pairs)), 3))
    padj = [upper[i][(i + 1) % n] for i in range(n - (0 if loop else 1))]
    rep["upper_band_xor"] = dict(min_adjacent=round(min(padj), 3), mean_adjacent=round(float(np.mean(padj)), 3))
    # joint angle ranges from the poses
    L = rig.Rig.ik
    hip, knee = [], []
    for p in meta["poses"]:
        for side in ("near", "far"):
            k, a = L(np.array(p["pelvis"]), np.array(p[side + "_leg"]["ankle"]), 65.5, 65.5)
            v1 = k - np.array(p["pelvis"]); v2 = a - k
            hip.append(math.degrees(math.atan2(v1[1], v1[0])))
            cosk = np.dot(-v1, v2) / (np.linalg.norm(v1) * np.linalg.norm(v2)); knee.append(180 - math.degrees(math.acos(max(-1, min(1, cosk)))))
    rep["leg_angles_deg"] = dict(thigh_dir_range=[round(min(hip)), round(max(hip))], knee_flex_range=[round(min(knee)), round(max(knee))])
    rep["arm_angles_deg"] = dict(upper_range=[round(min(p["near_arm"]["upper"] for p in meta["poses"])), round(max(p["near_arm"]["upper"] for p in meta["poses"]))])
    # unique frames
    hashes = {f.tobytes().__hash__() for f in frames}
    rep["unique_frames"] = len(hashes)
    # hidden RGB / alpha
    rep["hidden_rgb_pixels"] = int(sum(((f[..., 3] == 0) & (f[..., :3].sum(-1) != 0)).sum() for f in frames))
    rep["low_alpha_pixels_1_to_19"] = int(sum(((f[..., 3] > 0) & (f[..., 3] < 20)).sum() for f in frames))
    # silhouettes
    sil = [silhouette_stats(f) for f in frames]
    rep["min_margin_px"] = min(min(s["margin_l"], s["margin_r"], s["margin_t"], s["margin_b"]) for s in sil)
    rep["max_components"] = max(s["components"] for s in sil)
    rep["height_range"] = [min(s["height"] for s in sil), max(s["height"] for s in sil)]
    rep["lowest_rows"] = [s["lowest_row"] for s in sil]
    # palette
    rep["palette_outside_pct"] = [round(100 * palette_drift(f), 2) for f in frames]
    cm = [class_means(f) for f in frames]
    rep["class_means_first"] = cm[0]
    # contact / baseline expectation from analytic sole position
    rep["stance_flags"] = [[p["near_leg"]["state"][0], p["far_leg"]["state"][0]] for p in meta["poses"]]
    return rep, frames, meta

if __name__ == "__main__":
    os.makedirs(OUTQ, exist_ok=True)
    for name in sys.argv[1:]:
        rep, _, _ = run_clip(name, loop=name.endswith("loop") or name == "walk_loop")
        json.dump(rep, open(os.path.join(OUTQ, name + ".json"), "w"), indent=1)
        print(json.dumps({k: rep[k] for k in ("clip", "frames", "leg_band_xor", "upper_band_xor", "leg_angles_deg", "min_margin_px", "max_components", "height_range", "lowest_rows", "palette_outside_pct", "unique_frames", "hidden_rgb_pixels")}))
