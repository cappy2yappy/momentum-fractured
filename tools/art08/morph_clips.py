#!/usr/bin/env python3
"""ART-08: interpolated frames by symmetric optical-flow morph (DIS) between two registered frames. Provenance: interpolated."""
import os, sys, json
import numpy as np, cv2
from PIL import Image
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import rig
FR = os.path.join(rig.ROOT, "source_art/art08/frames")
def flat(f, bg=(110, 128, 140)):
    a = f[..., 3:4] / 255.0
    return (f[..., :3] * a + np.array(bg) * (1 - a)).astype(np.uint8)
def morph(A, B, alphas):
    ga, gb = cv2.cvtColor(flat(A), cv2.COLOR_RGB2GRAY), cv2.cvtColor(flat(B), cv2.COLOR_RGB2GRAY)
    dis = cv2.DISOpticalFlow_create(cv2.DISOPTICAL_FLOW_PRESET_MEDIUM)
    fab = dis.calc(ga, gb, None); fba = dis.calc(gb, ga, None)
    H, W = ga.shape; gx, gy = np.meshgrid(np.arange(W, dtype=np.float32), np.arange(H, dtype=np.float32))
    def pm(f): p = f.astype(np.float32).copy(); p[..., :3] *= p[..., 3:4] / 255; return p
    pa, pb = pm(A), pm(B); out = []
    for t in alphas:
        wa = cv2.remap(pa, gx - t * fab[..., 0], gy - t * fab[..., 1], cv2.INTER_LINEAR)       # A pulled toward B
        wb = cv2.remap(pb, gx - (1 - t) * fba[..., 0], gy - (1 - t) * fba[..., 1], cv2.INTER_LINEAR)
        m = (1 - t) * wa + t * wb
        a = m[..., 3:4]; rgb = np.where(a > 1, m[..., :3] / np.maximum(a / 255, 1e-6), 0)
        o = np.concatenate([rgb, a], -1).clip(0, 255).astype(np.uint8); o[o[..., 3] < 40] = 0; out.append(o)
    return out
def strip_frame(name, i):
    a = np.array(Image.open(os.path.join(FR, name + "_strip.png")).convert("RGBA")); return a[:, i * 480:(i + 1) * 480]
