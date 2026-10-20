#!/usr/bin/env python3
"""ART-08 foot slide against declared root motion, and identity drift against approved Kaze art (test-only, heuristic).

  art08_motion.py --repo <worktree> --approved <checkout with assets/kaze/cleaned and assets/art04> [--out file.json]

Foot slide: in each frame the lowest 10 percent of the silhouette is split into foot components. For consecutive frames a
component is matched to the one whose world position (cell x + cumulative root motion) is closest; a pair is a STANCE pair
when the matched foot keeps its world height within 4 px. Per frame pair, slide = the smallest residual world x displacement among height-stable foot matches (the stance foot), in source px.
Root motion convention is ambiguous (motion applied entering frame i, or leaving it); both are reported, best first.
Identity drift: alpha-weighted 6x6x6 RGB histogram distance (L1/2, 0..1) of every frame to the approved idle strip frame 0,
compared with the spread inside the approved art (idle vs run strips). Height: alpha bbox height relative to the approved
ART-04 stair key.
"""
import argparse, json
from pathlib import Path
import numpy as np
from PIL import Image


def frames(path, n):
    im = Image.open(path).convert('RGBA'); w = im.width // n
    return [im.crop((i * w, 0, (i + 1) * w, im.height)) for i in range(n)]


def feet(f):
    a = np.asarray(f)[:, :, 3] > 24
    ys, xs = np.where(a)
    if len(ys) == 0: return [], 0
    y1 = ys.max(); y0 = ys.min(); band = y1 - int(0.10 * (y1 - y0))
    cols = np.where(a[band:y1 + 1].any(axis=0))[0]
    comps, start = [], None
    for i, c in enumerate(cols):
        if start is None: start = prev = c
        elif c - prev > 6: comps.append((start, prev)); start = c
        prev = c
    if start is not None: comps.append((start, prev))
    out = []
    for s, e in comps:
        sub = a[:, s:e + 1]; yy = np.where(sub.any(axis=1))[0].max()
        out.append((float(s + e) / 2.0, float(yy)))
    return out, int(y1 - y0)


def slide(path, n, root, conv):
    fr = [feet(f)[0] for f in frames(path, n)]
    res = []
    for i in range(n - 1):
        r = root[i + 1] if conv == 'enter' else root[i]
        cand = []
        for (x0, y0) in fr[i]:
            for (x1, y1) in fr[i + 1]:
                dx = x1 + r[0] - x0; dy = y1 + r[1] - y0
                if abs(dy) <= 4: cand.append(abs(dx))
        if cand: res.append(min(cand))   # the stance foot: best planted match of the pair
    return res


def hist(f):
    a = np.asarray(f); m = a[:, :, 3] > 24
    px = (a[:, :, :3][m] // 43).astype(int)
    idx = px[:, 0] * 36 + px[:, 1] * 6 + px[:, 2]
    h = np.bincount(idx, minlength=216).astype(float)
    return h / max(1.0, h.sum())


def hd(a, b): return float(np.abs(a - b).sum() / 2.0)


def bbox_h(f):
    a = np.asarray(f)[:, :, 3] > 24; ys = np.where(a.any(axis=1))[0]
    return int(ys.max() - ys.min()) if len(ys) else 0


def main():
    ap = argparse.ArgumentParser(); ap.add_argument('--repo', required=True); ap.add_argument('--approved', required=True); ap.add_argument('--out')
    a = ap.parse_args(); repo = Path(a.repo); ap_root = Path(a.approved)
    man = json.loads((repo / 'assets/art08/MANIFEST.json').read_text())
    idle = frames(ap_root / 'assets/kaze/cleaned/kaze_idle_strip.png', 8); run = frames(ap_root / 'assets/kaze/cleaned/kaze_run_strip.png', 8)
    ref = hist(idle[0]); spread = [hd(hist(r), ref) for r in run] + [hd(hist(i), ref) for i in idle]
    key = Image.open(ap_root / 'assets/art04/kaze/stair_up_key.png').convert('RGBA'); key_h = bbox_h(key)
    out = dict(approved_internal_color_spread=dict(mean=round(float(np.mean(spread)), 3), max=round(float(np.max(spread)), 3)), art04_stair_key_height_px=key_h, clips=[])
    for c in man['clips']:
        p = repo / (c.get('strip') or '')
        if not c.get('strip') or not p.exists():
            out['clips'].append(dict(name=c['name'], status='no strip')); continue
        n = int(c['hframes']); root = [tuple(r) for r in (c.get('root_motion_px_per_frame') or [[0, 0]] * n)]
        fr = frames(p, n)
        d = [hd(hist(f), ref) for f in fr]; hs = [bbox_h(f) for f in fr]
        row = dict(name=c['name'], frames=n, color_dist_to_approved_idle=dict(mean=round(float(np.mean(d)), 3), max=round(float(np.max(d)), 3)),
                   within_clip_color_drift=round(max(hd(hist(f), hist(fr[0])) for f in fr), 3),
                   height_vs_art04_key=dict(min=round(min(hs) / key_h, 3), max=round(max(hs) / key_h, 3)))
        for conv in ('enter', 'leave'):
            s = slide(p, n, root, conv)
            row['foot_slide_' + conv] = dict(stance_pairs=len(s), mean=round(float(np.mean(s)), 2) if s else None, max=round(float(np.max(s)), 2) if s else None)
        out['clips'].append(row)
    print(json.dumps(out, indent=1))
    if a.out: Path(a.out).write_text(json.dumps(out, indent=1))


if __name__ == '__main__':
    main()
