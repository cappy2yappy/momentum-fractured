#!/usr/bin/env python3
"""ART-07 Phase 1: deterministic PROCEDURAL idle candidate for Kaze.

This is NOT redrawn animation. It displaces the pixels of ONE approved idle drawing
(frame 1 of assets/kaze/cleaned/kaze_idle_strip.png) with smooth, analytic
displacement fields: chest breathing, a weight-shift sway pinned at the feet, and
lagged hair / ribbon rotation. No new artwork is painted or generated. Frame 0 of
every output equals the approved source frame byte-for-byte in RGBA values.

Usage: python3 tools/art07/idle_procedural.py [--repo ROOT] [--frames 8] [--out DIR]
Deterministic: same inputs and parameters always give identical PNG pixels.
Requires numpy, scipy, Pillow.
"""
import argparse
import hashlib
import json
import math
import os

import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage as ndi

CELL_W, CELL_H = 272, 724
SOURCE_STRIP = "assets/kaze/cleaned/kaze_idle_strip.png"
SOURCE_STRIP_SHA256 = "03db06f8670a4247bf98100b2a40e936bc3fff7ee27f90a02c7a3d47aea95697"
SOURCE_FRAME = 1  # approved frame used as the single source drawing
BASELINE = 591

PARAMS = {
    "schema_version": 1,
    "method": "procedural_displacement_of_one_approved_frame",
    "source_frame_index": SOURCE_FRAME,
    # chest breathing: vertical stretch about the hips, feet and legs pinned
    "breath": {"pivot_y": 450.0, "falloff_px": 70.0, "k": 0.011, "chest_dx_k": 0.008,
               "chest_center": [150.0, 335.0], "chest_sigma_y": 38.0},
    # weight shift: horizontal upper-body sway, zero at and below the boots
    "sway": {"amp_px": 3.0, "y_pinned": 540.0, "y_full": 300.0},
    # long hair swings as one lagged pendulum about the ponytail base
    "hair": {"pivot": [122.0, 242.0], "amp_rad": 0.018, "lag_cycles": 0.20,
             "ramp_px": [35.0, 120.0],
             "polygon": [[28, 262], [95, 232], [116, 222], [128, 250], [136, 300], [112, 312],
                         [96, 340], [84, 372], [72, 388], [66, 424], [28, 424]],
             "rgb_max_blue": 95, "lum_max": 80, "dilate_px": 3, "blur_sigma": 3.5},
    # ribbon bow tails flutter with a second harmonic
    "ribbon": {"pivot": [104.0, 250.0], "amp_rad": 0.04, "lag_cycles": 0.30,
               "h2_mix": 0.3, "h2_lag_cycles": 0.10, "ramp_px": [8.0, 45.0],
               "y_max": 312, "x_max": 140, "dilate_px": 3, "blur_sigma": 2.0},
}


def sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        h.update(f.read())
    return h.hexdigest()


def smoothstep(e0, e1, x):
    t = np.clip((x - e0) / (e1 - e0), 0.0, 1.0)
    return t * t * (3.0 - 2.0 * t)


def load_source(repo):
    path = os.path.join(repo, SOURCE_STRIP)
    digest = sha256_file(path)
    if digest != SOURCE_STRIP_SHA256:
        raise SystemExit(f"source strip hash mismatch: {digest}")
    strip = Image.open(path).convert("RGBA")
    assert strip.size == (CELL_W * 8, CELL_H), strip.size
    x0 = SOURCE_FRAME * CELL_W
    return strip.crop((x0, 0, x0 + CELL_W, CELL_H))


def build_masks(src, P):
    a = np.array(src).astype(np.float32)
    R, G, B, A = a[..., 0], a[..., 1], a[..., 2], a[..., 3]
    lum = 0.3 * R + 0.59 * G + 0.11 * B
    yy, xx = np.mgrid[0:CELL_H, 0:CELL_W]
    pm = Image.new("L", (CELL_W, CELL_H), 0)
    ImageDraw.Draw(pm).polygon([tuple(p) for p in P["hair"]["polygon"]], fill=255)
    pm = np.array(pm) > 0
    hair = (A > 128) & (B < P["hair"]["rgb_max_blue"]) & (lum < P["hair"]["lum_max"]) & pm & (G < R + 30)
    hair = ndi.binary_dilation(hair, iterations=P["hair"]["dilate_px"]) & (A > 0) & pm
    green = (A > 128) & (G > 150) & (R < 120) & (B < 120) & (yy < P["ribbon"]["y_max"]) & (xx < P["ribbon"]["x_max"])
    green = ndi.binary_dilation(green, iterations=P["ribbon"]["dilate_px"]) & (A > 0)
    # the ribbon wins where the two overlap
    hair &= ~green
    mh = ndi.gaussian_filter(hair.astype(np.float32), P["hair"]["blur_sigma"])
    mr = ndi.gaussian_filter(green.astype(np.float32), P["ribbon"]["blur_sigma"])
    return mh, mr, hair, green


def rot_field(px, py, xx, yy, theta, ramp, mask):
    d = np.hypot(xx - px, yy - py)
    w = mask * smoothstep(ramp[0], ramp[1], d)
    # small-angle rotation about (px, py)
    return -theta * (yy - py) * w, theta * (xx - px) * w


def fields(t, P, mh, mr, xx, yy):
    """Forward displacement D(p) (dx, dy) in source pixels at loop phase t in [0,1)."""
    b, s, h, r = P["breath"], P["sway"], P["hair"], P["ribbon"]
    sb = (1.0 - math.cos(2 * math.pi * t)) / 2.0           # 0 at t=0
    ss = math.sin(2 * math.pi * t)                          # 0 at t=0
    th_h = h["amp_rad"] * (math.sin(2 * math.pi * (t - h["lag_cycles"])) + math.sin(2 * math.pi * h["lag_cycles"]))
    th_r = r["amp_rad"] * ((1 - r["h2_mix"]) * (math.sin(2 * math.pi * (t - r["lag_cycles"])) + math.sin(2 * math.pi * r["lag_cycles"]))
                           + r["h2_mix"] * (math.sin(4 * math.pi * (t - r["h2_lag_cycles"])) + math.sin(4 * math.pi * r["h2_lag_cycles"])))
    # breath: stretch upward about pivot_y, weight eases to zero toward the hips
    up = np.clip(b["pivot_y"] - yy, 0, None)
    wb = smoothstep(0.0, 1.0, up / b["falloff_px"])
    dy = -up * b["k"] * sb * wb
    bell = np.exp(-((yy - b["chest_center"][1]) ** 2) / (2 * b["chest_sigma_y"] ** 2))
    dx = (xx - b["chest_center"][0]) * b["chest_dx_k"] * sb * bell
    # sway: smooth 0 at/below boots to 1 at the shoulders
    ws = smoothstep(0.0, 1.0, (s["y_pinned"] - yy) / (s["y_pinned"] - s["y_full"]))
    dx = dx + s["amp_px"] * ss * ws
    hx, hy = rot_field(h["pivot"][0], h["pivot"][1], xx, yy, th_h, h["ramp_px"], mh)
    rx, ry = rot_field(r["pivot"][0], r["pivot"][1], xx, yy, th_r, r["ramp_px"], mr)
    return dx + hx + rx, dy + hy + ry


def warp(src, Dx, Dy, xx, yy):
    a = np.array(src).astype(np.float32) / 255.0
    prem = a.copy()
    prem[..., :3] *= a[..., 3:4]
    # invert the forward field by fixed-point iteration
    qx, qy = xx.astype(np.float32), yy.astype(np.float32)
    for _ in range(4):
        sx = ndi.map_coordinates(Dx, [qy, qx], order=1, mode="nearest")
        sy = ndi.map_coordinates(Dy, [qy, qx], order=1, mode="nearest")
        qx, qy = xx - sx, yy - sy
    out = np.zeros_like(prem)
    for c in range(4):
        out[..., c] = ndi.map_coordinates(prem[..., c], [qy, qx], order=1, mode="constant", cval=0.0)
    al = out[..., 3:4]
    rgb = np.where(al > 1e-6, out[..., :3] / np.maximum(al, 1e-6), 0.0)
    res = np.concatenate([rgb, al], axis=-1)
    out8 = np.clip(np.rint(res * 255.0), 0, 255).astype(np.uint8)
    out8[out8[..., 3] == 0, :3] = 0  # no hidden RGB under fully transparent pixels
    return Image.fromarray(out8, "RGBA")


def jacobian_max(Dx, Dy):
    gy_x, gx_x = np.gradient(Dx)
    gy_y, gx_y = np.gradient(Dy)
    return float(max(np.abs(gx_x).max(), np.abs(gy_x).max(), np.abs(gx_y).max(), np.abs(gy_y).max()))


def generate(repo, n_frames, out_dir):
    P = PARAMS
    src = load_source(repo)
    mh, mr, hair, green = build_masks(src, P)
    yy, xx = np.mgrid[0:CELL_H, 0:CELL_W].astype(np.float32)
    os.makedirs(out_dir, exist_ok=True)
    frames, stats = [], []
    for k in range(n_frames):
        t = k / n_frames
        Dx, Dy = fields(t, P, mh, mr, xx, yy)
        if k == 0 or (np.abs(Dx).max() < 1e-9 and np.abs(Dy).max() < 1e-9):
            img = src.copy()
        else:
            img = warp(src, Dx, Dy, xx, yy)
        frames.append(img)
        stats.append({"index": k, "t": round(t, 6),
                      "max_disp_px": round(float(np.hypot(Dx, Dy).max()), 4),
                      "max_jacobian": round(jacobian_max(Dx, Dy), 5)})
    strip = Image.new("RGBA", (CELL_W * n_frames, CELL_H), (0, 0, 0, 0))
    for k, f in enumerate(frames):
        strip.paste(f, (k * CELL_W, 0))
    return src, frames, strip, stats, (hair, green)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--repo", default=os.path.join(os.path.dirname(__file__), "..", ".."))
    ap.add_argument("--frames", type=int, default=8)
    ap.add_argument("--out", required=True)
    args = ap.parse_args()
    src, frames, strip, stats, masks = generate(os.path.abspath(args.repo), args.frames, args.out)
    os.makedirs(args.out, exist_ok=True)
    strip.save(os.path.join(args.out, f"strip_{args.frames}f.png"), optimize=False)
    for k, f in enumerate(frames):
        f.save(os.path.join(args.out, f"frame_{args.frames}f_{k:02d}.png"), optimize=False)
    with open(os.path.join(args.out, f"stats_{args.frames}f.json"), "w") as fh:
        json.dump({"params": PARAMS, "frames": stats}, fh, indent=2, sort_keys=True)
    print("wrote", args.out)


if __name__ == "__main__":
    main()
