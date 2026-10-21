#!/usr/bin/env python3
"""True-animation analyzer (test-only). Decides whether a sequence of Kaze frames is genuine multi-pose
animation or a held / scaled / bobbed single pose.

Method (translation and uniform-scale invariant, so a bob or a zoom of one drawing scores ZERO):
  1. alpha mask of each frame, cropped to its alpha bounding box;
  2. uniform scale to a fixed height, bottom-centred on the horizontal alpha centroid, on a 96 x 128 canvas;
  3. pose difference between two frames = L1 distance of the masks / max(mask area)  (0 = identical silhouette);
     'leg' difference uses only the lower 45 percent of the canvas (hips down) where a gait lives;
  4. distinct poses = greedy clustering with threshold POSE_T; step pairs = consecutive frames whose leg difference
     reaches STEP_T.
Calibrated on shipped controls (see QA_RUNBOOK): approved run strip passes, idle breathing and held keys do not.

CLI:
  true_animation.py --strip kaze_run_strip.png --hframes 8 [--loop] [--min-frames 4]
  true_animation.py --samples samples.json   (in-engine playback log written by the w3 hooks; see analyze_playback)
  true_animation.py --controls <repo>        (self-test on the controls in a checkout; exit 1 if a control is misjudged)
"""
import argparse, json, sys, math
from pathlib import Path
import numpy as np
from PIL import Image

CANVAS_W, CANVAS_H, BODY_H = 96, 128, 118
POSE_T = 0.10     # silhouette difference that counts as a different pose
STEP_T = 0.06     # leg difference between consecutive frames that counts as limb motion
MIN_DISTINCT_FRAC = 0.5   # a clip of N frames needs at least N*frac distinct poses (and >= 3)
MIN_STEP_FRAC = 0.6
GAIT_T = 0.30     # leg difference a translating actor must show inside a window (idle breathing peaks near 0.26, run cycle 1.38)


def norm_mask(img_rgba):
    a = np.asarray(img_rgba.convert('RGBA'))[:, :, 3] > 24
    ys, xs = np.where(a)
    if len(ys) < 20:
        return None
    y0, y1, x0, x1 = ys.min(), ys.max() + 1, xs.min(), xs.max() + 1
    crop = a[y0:y1, x0:x1].astype(np.uint8) * 255
    h = y1 - y0
    s = BODY_H / h
    cx = xs.mean() - x0
    im = Image.fromarray(crop).resize((max(1, int(round((x1 - x0) * s))), BODY_H), Image.BILINEAR)
    canvas = np.zeros((CANVAS_H, CANVAS_W), np.float32)
    ox = int(round(CANVAS_W / 2 - cx * s))
    arr = np.asarray(im, np.float32) / 255.0
    oy = CANVAS_H - 5 - BODY_H
    for yy in range(arr.shape[0]):
        ty = oy + yy
        if not 0 <= ty < CANVAS_H:
            continue
        for_x0 = max(0, ox); for_x1 = min(CANVAS_W, ox + arr.shape[1])
        if for_x1 > for_x0:
            canvas[ty, for_x0:for_x1] = arr[yy, for_x0 - ox:for_x1 - ox]
    return canvas


def diff(a, b, legs=False):
    if legs:
        r = int(CANVAS_H * 0.55)
        a, b = a[r:], b[r:]
    den = max(a.sum(), b.sum(), 1.0)
    return float(np.abs(a - b).sum() / den)


def analyze_masks(masks, loop=False, label=''):
    masks = [m for m in masks if m is not None]
    n = len(masks)
    if n < 2:
        return dict(label=label, frames=n, distinct=n, verdict='HELD_OR_TOO_SHORT', reason='fewer than 2 usable frames')
    pairs = list(zip(masks[:-1], masks[1:])) + ([(masks[-1], masks[0])] if loop else [])
    full = [diff(a, b) for a, b in pairs]
    legs = [diff(a, b, True) for a, b in pairs]
    distinct = []
    for m in masks:
        if all(diff(m, d) >= POSE_T for d in distinct):
            distinct.append(m)
    maxleg = max(diff(a, b, True) for i, a in enumerate(masks) for b in masks[i + 1:])
    step_frac = sum(1 for v in legs if v >= STEP_T) / len(legs)
    need = max(3, math.ceil(n * MIN_DISTINCT_FRAC)) if n >= 6 else max(2, math.ceil(n * 0.5))
    ok = len(distinct) >= need and step_frac >= MIN_STEP_FRAC and maxleg >= POSE_T
    reason = '' if ok else 'distinct=%d need>=%d, stepfrac=%.2f need>=%.2f, maxleg=%.3f need>=%.3f' % (len(distinct), need, step_frac, MIN_STEP_FRAC, maxleg, POSE_T)
    return dict(label=label, frames=n, distinct=len(distinct), distinct_needed=need, step_fraction=round(step_frac, 3),
                max_leg_diff=round(maxleg, 4), mean_frame_diff=round(float(np.mean(full)), 4), mean_leg_diff=round(float(np.mean(legs)), 4),
                verdict='TRUE_ANIMATION' if ok else 'NOT_ANIMATION', reason=reason)


def strip_frames(path, hframes, vframes=1):
    im = Image.open(path).convert('RGBA')
    w, h = im.size
    cw, ch = w // hframes, h // vframes
    return [im.crop((i * cw, 0, (i + 1) * cw, ch)) for i in range(hframes)]


def analyze_strip(path, hframes, loop=False, label=None):
    return analyze_masks([norm_mask(f) for f in strip_frames(path, hframes)], loop, label or Path(path).name)


# ---- synthetic negative controls built from a real approved frame: held, scaled, bobbed, sheared by sway
def synthetic_negatives(strip, hframes, n=8):
    f = strip_frames(strip, hframes)[0]
    outs = {}
    outs['held_single_pose'] = [f] * n
    sc = []
    for i in range(n):
        s = 1.0 + 0.08 * math.sin(i / n * 2 * math.pi)
        im = f.resize((max(1, int(f.width * s)), max(1, int(f.height * s))), Image.BILINEAR)
        c = Image.new('RGBA', f.size, (0, 0, 0, 0)); c.paste(im, ((f.width - im.width) // 2, f.height - im.height), im); sc.append(c)
    outs['scaled_zoom_pulse'] = sc
    bob = []
    for i in range(n):
        dy = int(round(12 * math.sin(i / n * 2 * math.pi)))
        c = Image.new('RGBA', f.size, (0, 0, 0, 0)); c.paste(f, (0, -dy), f); bob.append(c)
    outs['bobbed_still'] = bob
    return outs


def analyze_playback(samples, strips_root, fps=60, min_move_px=14.0, window_s=0.30):
    """samples: list of dict(t, key, tex, frame, hframes, vframes, region(optional), flip, scale, pos[x,y], visible, abs_h)
    from the in-engine sampler. For every window in which the actor travels at least min_move_px (screen/world px) the pose
    must change (>= 3 distinct poses OR step fraction). Held pose translating = NOT animation."""
    cache, masks = {}, []
    for s in samples:
        if not s.get('visible', True) or not s.get('tex'):
            masks.append(None); continue
        k = (s['tex'], s.get('frame', 0), s.get('hframes', 1), s.get('vframes', 1), tuple(s.get('region') or ()))
        if k not in cache:
            p = Path(strips_root) / s['tex'].replace('res://', '')
            if not p.exists():
                cache[k] = None
            else:
                im = Image.open(p).convert('RGBA')
                if s.get('region'):
                    x, y, w, h = [int(v) for v in s['region']]
                    fr = im.crop((x, y, x + w, y + h))
                else:
                    hf, vf = s.get('hframes', 1), s.get('vframes', 1)
                    cw, ch = im.width // hf, im.height // vf
                    fi = s.get('frame', 0)
                    cx, cy = (fi % hf) * cw, (fi // hf) * ch
                    fr = im.crop((cx, cy, cx + cw, cy + ch))
                cache[k] = norm_mask(fr)
        masks.append(cache[k])
    n = len(samples)
    wlen = max(2, int(window_s * fps))
    moving = static_moving = 0
    bad_windows = []
    for i in range(0, n - wlen, max(1, wlen // 2)):
        seg = samples[i:i + wlen]
        if not all(s.get('visible', True) for s in seg):
            continue
        p0, p1 = seg[0]['pos'], seg[-1]['pos']
        if math.hypot(p1[0] - p0[0], p1[1] - p0[1]) < min_move_px:
            continue
        moving += 1
        ms = [m for m in masks[i:i + wlen] if m is not None]
        # distinct poses inside the window, and leg motion
        distinct = []
        for m in ms:
            if all(diff(m, d) >= POSE_T for d in distinct):
                distinct.append(m)
        legmax = max([diff(a, b, True) for j, a in enumerate(ms) for b in ms[j + 1:]] or [0.0])
        ok = len(distinct) >= 2 and legmax >= GAIT_T
        if not ok:
            static_moving += 1
            bad_windows.append(dict(t=round(seg[0]['t'], 3), tex=seg[0].get('tex'), frame=seg[0].get('frame'), distinct=len(distinct), leg=round(legmax, 3)))
    all_distinct = []
    for m in masks:
        if m is not None and all(diff(m, d) >= POSE_T for d in all_distinct):
            all_distinct.append(m)
    frac = 0.0 if moving == 0 else 1.0 - static_moving / moving
    legmax_all = max([diff(a, b, True) for i, a in enumerate(all_distinct) for b in all_distinct[i + 1:]] or [0.0])
    if moving == 0:
        # Actor never travelled (stage treadmill or a held pose): judge the poses themselves.
        inplace = len(all_distinct) >= 4 and legmax_all >= GAIT_T
        return dict(samples=n, moving_windows=0, held_while_moving=0, true_motion_fraction=0.0, distinct_poses_total=len(all_distinct),
                    max_leg_diff_all=round(legmax_all, 3), bad_windows=[],
                    verdict='TRUE_ANIMATION_IN_PLACE' if inplace else ('NOT_ANIMATION' if len(all_distinct) <= 3 else 'NO_MOVEMENT_OBSERVED'),
                    reason='' if inplace else 'actor never travelled and showed %d distinct pose(s), max leg diff %.3f' % (len(all_distinct), legmax_all))
    return dict(samples=n, moving_windows=moving, held_while_moving=static_moving, true_motion_fraction=round(frac, 3),
                distinct_poses_total=len(all_distinct), max_leg_diff_all=round(legmax_all, 3), bad_windows=bad_windows[:12],
                verdict=('TRUE_ANIMATION' if (frac >= 0.9 and len(all_distinct) >= 4) else 'NOT_ANIMATION'))


def controls(repo):
    repo = Path(repo)
    rows, ok = [], True
    run = repo / 'assets/kaze/cleaned/kaze_run_strip.png'
    idle = repo / 'assets/kaze/cleaned/kaze_idle_strip.png'
    r = analyze_strip(run, 8, loop=True, label='approved run strip (must PASS)'); rows.append(r); ok &= r['verdict'] == 'TRUE_ANIMATION'
    for name, frames in synthetic_negatives(run, 8).items():
        r = analyze_masks([norm_mask(f) for f in frames], True, 'synthetic control %s (must FAIL)' % name); rows.append(r); ok &= r['verdict'] != 'TRUE_ANIMATION'
    keys = [repo / 'assets/art04/kaze/stair_up_key.png', repo / 'assets/art04/kaze/stair_down_key.png']
    for k in keys:
        if k.exists():
            r = analyze_masks([norm_mask(Image.open(k))] * 8, True, 'ART-04 %s held as a stair clip (must FAIL)' % k.name); rows.append(r); ok &= r['verdict'] != 'TRUE_ANIMATION'
    r = analyze_strip(idle, 8, loop=True, label='approved idle strip (breathing; informational, not a gait)'); rows.append(r)
    return ok, rows


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--strip'); ap.add_argument('--hframes', type=int); ap.add_argument('--loop', action='store_true')
    ap.add_argument('--samples'); ap.add_argument('--root', default='.')
    ap.add_argument('--controls'); ap.add_argument('--json', action='store_true')
    a = ap.parse_args()
    if a.controls:
        ok, rows = controls(a.controls)
        print(json.dumps(dict(controls_ok=ok, rows=rows), indent=2)); sys.exit(0 if ok else 1)
    if a.strip:
        r = analyze_strip(a.strip, a.hframes, a.loop); print(json.dumps(r, indent=2)); sys.exit(0 if r['verdict'] == 'TRUE_ANIMATION' else 1)
    if a.samples:
        d = json.loads(Path(a.samples).read_text()); r = analyze_playback(d['samples'] if isinstance(d, dict) else d, a.root, d.get('fps', 60) if isinstance(d, dict) else 60)
        print(json.dumps(r, indent=2)); sys.exit(0 if r['verdict'].startswith('TRUE_ANIMATION') else 1)
    ap.print_help()


if __name__ == '__main__':
    main()
