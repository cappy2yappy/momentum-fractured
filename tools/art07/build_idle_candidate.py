#!/usr/bin/env python3
"""ART-07 Phase 1 build: generate, QA, preview and manifest the procedural idle candidate.

Run from the repo root:  python3 -I tools/art07/build_idle_candidate.py
Outputs (all deterministic):
  assets/art07/idle_procedural/        strips + individual frames
  source_art/art07/idle_procedural/    approved source frame, params, masks
  docs/art/art07/idle_procedural/      GIFs, contact sheets, QA report
  assets/art07/MANIFEST.json           hashes, contract, status
"""
import hashlib
import json
import math
import os
import sys

import numpy as np
from PIL import Image, ImageDraw

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import idle_procedural as ip  # noqa: E402

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
ASSET_DIR = "assets/art07/idle_procedural"
SRC_DIR = "source_art/art07/idle_procedural"
DOC_DIR = "docs/art/art07/idle_procedural"
ENGINE_SCALE = 0.2649908807267889
BG = (70, 70, 80)


def sha(path):
    return ip.sha256_file(path)


def rel(p):
    return os.path.relpath(p, REPO).replace(os.sep, "/")


def alpha_bbox(img, thr=8):
    a = np.array(img)[..., 3] > thr
    ys, xs = np.where(a)
    return int(xs.min()), int(ys.min()), int(xs.max()), int(ys.max())


def qa_set(name, src, frames, stats, source_strip_frames):
    """Run all technical checks for one candidate set. Returns (report, passed)."""
    n = len(frames)
    s = np.array(src).astype(np.int16)
    arrs = [np.array(f).astype(np.int16) for f in frames]
    checks = []

    def add(cid, ok, detail):
        checks.append({"id": cid, "pass": bool(ok), "detail": detail})

    add("dimensions", all(f.size == (ip.CELL_W, ip.CELL_H) for f in frames),
        f"every frame {ip.CELL_W}x{ip.CELL_H}; strip {ip.CELL_W * n}x{ip.CELL_H}")
    add("frame0_is_approved_source", bool((arrs[0] == s).all()),
        "frame 0 RGBA identical to approved idle frame 1")
    # feet pinned: rows >= 548 identical to source in every frame
    foot_diff = [int((np.abs(a[548:] - s[548:]).sum(axis=-1) > 0).sum()) for a in arrs]
    add("feet_pinned_rows_548_plus", max(foot_diff) == 0, f"differing pixels per frame: {foot_diff}")
    low = [alpha_bbox(f)[3] for f in frames]
    add("baseline_row_590", all(v == 590 for v in low), f"lowest opaque row per frame: {low} (baseline contract row 591)")
    boxes = [alpha_bbox(f) for f in frames]
    margins = [min(b[0], b[1], ip.CELL_W - 1 - b[2], ip.CELL_H - 1 - b[3]) for b in boxes]
    add("alpha_margin_ge_12px", min(margins) >= 12, f"min margin to cell edge per frame: {margins}")
    hashes = [hashlib.sha256(np.array(f).tobytes()).hexdigest() for f in frames]
    add("all_frames_unique", len(set(hashes)) == n, f"{len(set(hashes))} unique of {n}")
    # inter-frame deltas (mean abs diff over RGBA, per pixel)
    def mad(a, b):
        return float(np.abs(a - b).mean())
    adj = [mad(arrs[i], arrs[(i + 1) % n]) for i in range(n)]
    seam = adj[-1]
    med = float(np.median(adj[:-1]))
    add("loop_seam_not_a_pop", seam <= 1.5 * max(adj[:-1]), f"seam delta {seam:.4f}; other adjacent deltas median {med:.4f} max {max(adj[:-1]):.4f}")
    pair_min = min(mad(arrs[i], arrs[j]) for i in range(n) for j in range(i + 1, n))
    add("no_near_duplicate_pose", pair_min > 0.02, f"min pairwise mean abs diff {pair_min:.4f}")
    # silhouette
    area0 = int((s[..., 3] > 8).sum())
    areas = [int((a[..., 3] > 8).sum()) for a in arrs]
    dev = [abs(x - area0) / area0 * 100 for x in areas]
    add("silhouette_area_within_3pct", max(dev) <= 3.0, f"max area change {max(dev):.2f}% (source {area0} px)")
    heights = [b[3] - b[1] for b in boxes]
    add("silhouette_height_within_8px", max(abs(h - (boxes[0][3] - boxes[0][1])) for h in heights) <= 8,
        f"alpha bbox heights {heights}")
    # identity: mean colour of opaque pixels
    def mean_rgb(a):
        m = a[..., 3] > 200
        return a[..., :3][m].mean(axis=0)
    base = mean_rgb(s)
    shifts = [float(np.abs(mean_rgb(a) - base).max()) for a in arrs]
    add("identity_mean_colour_shift_le_2", max(shifts) <= 2.0, f"max per-channel mean colour shift {max(shifts):.3f} levels")
    # hidden RGB
    hidden = [int(((a[..., 3] == 0) & (a[..., :3].sum(axis=-1) > 0)).sum()) for a in arrs]
    add("no_hidden_rgb", max(hidden) == 0, f"transparent pixels with RGB per frame: {hidden}")
    # soft-edge growth from resampling
    semi0 = int(((s[..., 3] > 0) & (s[..., 3] < 255)).sum())
    semis = [int(((a[..., 3] > 0) & (a[..., 3] < 255)).sum()) for a in arrs]
    growth = [abs(x - semi0) / semi0 * 100 for x in semis]
    add("edge_softening_le_15pct", max(growth) <= 15.0, f"semi-transparent pixel count change per frame (%): {[round(g, 1) for g in growth]}")
    jac = max(f["max_jacobian"] for f in stats)
    add("no_fold_jacobian_lt_0p75", jac < 0.75, f"max displacement-field gradient {jac:.3f} (1.0 would fold)")
    # motion budget in source px and game px
    head_rise = [boxes[0][1] - b[1] for b in boxes]
    add("motion_visible_not_large", 2 <= max(abs(h) for h in head_rise) <= 8,
        f"head-top rise vs frame 0 (source px): {head_rise}; x{ENGINE_SCALE:.4f} = up to {max(abs(h) for h in head_rise) * ENGINE_SCALE:.2f} game px")
    report = {
        "set": name, "frames": n, "checks": checks,
        "max_displacement_px": max(f["max_disp_px"] for f in stats),
        "max_displacement_game_px": round(max(f["max_disp_px"] for f in stats) * ENGINE_SCALE, 3),
        "adjacent_mean_abs_diff": [round(x, 5) for x in adj],
        "passed": all(c["pass"] for c in checks),
    }
    return report


def bg_flat(img, scale=1.0, up=1):
    w = max(1, round(img.width * scale))
    h = max(1, round(img.height * scale))
    small = img.resize((w, h), Image.LANCZOS)
    bgi = Image.new("RGBA", small.size, BG + (255,))
    bgi.alpha_composite(small)
    out = bgi.convert("RGB")
    if up > 1:
        out = out.resize((out.width * up, out.height * up), Image.NEAREST)
    return out


def crop_game(img, up):
    """Game-scale render of the cell, cropped to the figure's area, upscaled nearest."""
    g = bg_flat(img, ENGINE_SCALE, 1)
    # figure occupies rows ~223..591 of the cell at scale -> 59..157 px
    g = g.crop((0, 52, g.width, 164))
    return g.resize((g.width * up, g.height * up), Image.NEAREST)


def save_gif(path, frames, durations_ms):
    pal_src = Image.new("RGB", (frames[0].width, frames[0].height * len(frames)))
    for i, f in enumerate(frames):
        pal_src.paste(f, (0, i * frames[0].height))
    pal = pal_src.quantize(colors=200, method=Image.MEDIANCUT, dither=Image.NONE)
    qs = [f.quantize(palette=pal, dither=Image.NONE) for f in frames]
    qs[0].save(path, save_all=True, append_images=qs[1:], duration=durations_ms, loop=0, disposal=1, optimize=False)


def label(img, text):
    d = ImageDraw.Draw(img)
    d.rectangle([0, 0, img.width, 12], fill=(30, 30, 38))
    d.text((3, 1), text, fill=(235, 235, 235))
    return img


def main():
    os.chdir(REPO)
    for d in (ASSET_DIR, SRC_DIR, DOC_DIR, os.path.join(ASSET_DIR, "frames_8f")):
        os.makedirs(d, exist_ok=True)
    strip_path = ip.SOURCE_STRIP
    full_strip = Image.open(strip_path).convert("RGBA")
    approved = [full_strip.crop((i * ip.CELL_W, 0, (i + 1) * ip.CELL_W, ip.CELL_H)) for i in range(8)]

    results = {}
    for n in (8, 16):
        src, frames, strip, stats, masks = ip.generate(REPO, n, "/tmp/claude-0/work/_scratch")
        results[n] = (src, frames, strip, stats, masks)

    src = results[8][0]
    # ---- assets
    p8 = os.path.join(ASSET_DIR, "kaze_idle_procedural_8f_strip.png")
    p16 = os.path.join(ASSET_DIR, "kaze_idle_procedural_16f_strip.png")
    results[8][2].save(p8)
    results[16][2].save(p16)
    frame_paths = []
    for k, f in enumerate(results[8][1]):
        fp = os.path.join(ASSET_DIR, "frames_8f", f"kaze_idle_procedural_8f_{k:02d}.png")
        f.save(fp)
        frame_paths.append(fp)
    # ---- sources
    src_path = os.path.join(SRC_DIR, "approved_idle_frame1_source.png")
    src.save(src_path)
    hair, green = results[8][4]
    Image.fromarray((hair * 255).astype(np.uint8), "L").save(os.path.join(SRC_DIR, "mask_hair_hard.png"))
    Image.fromarray((green * 255).astype(np.uint8), "L").save(os.path.join(SRC_DIR, "mask_ribbon_hard.png"))
    with open(os.path.join(SRC_DIR, "params.json"), "w") as fh:
        json.dump(ip.PARAMS, fh, indent=2, sort_keys=True)

    # ---- QA
    qa = {
        "tool": "tools/art07/build_idle_candidate.py",
        "method": "procedural displacement of one approved drawing; NOT redrawn animation",
        "source": {"file": ip.SOURCE_STRIP, "sha256": ip.SOURCE_STRIP_SHA256, "frame_index": ip.SOURCE_FRAME},
        "sets": {},
    }
    for n in (8, 16):
        qa["sets"][f"{n}f"] = qa_set(f"{n}f", src, results[n][1], results[n][3], approved)
    qa["passed_all"] = all(v["passed"] for v in qa["sets"].values())
    qa["not_run"] = ["Godot render of the candidate (no Godot binary in the authoring sandbox)",
                     "human review of motion quality", "gamepad or campaign play"]
    with open(os.path.join(DOC_DIR, "QA_REPORT.json"), "w") as fh:
        json.dump(qa, fh, indent=2, sort_keys=True)

    # ---- previews
    up = 4
    # contact sheet: approved 8 vs candidate 8, game scale x4
    cs_w = ip.CELL_W * 8
    rows = [("approved idle (8f, unchanged)", approved), ("candidate 8f (procedural)", results[8][1])]
    gw = crop_game(approved[0], up).width
    gh = crop_game(approved[0], up).height
    sheet = Image.new("RGB", (gw * 8, (gh + 14) * 2), (20, 20, 26))
    for r, (name, fr) in enumerate(rows):
        for i, f in enumerate(fr):
            tile = crop_game(f, up)
            sheet.paste(tile, (i * gw, r * (gh + 14) + 14))
        d = ImageDraw.Draw(sheet)
        d.text((4, r * (gh + 14) + 1), name, fill=(235, 235, 235))
    sheet.save(os.path.join(DOC_DIR, "contact_sheet_game_scale_x4.png"))
    # full-resolution comparison of the changing frames
    pick = [0, 2, 4, 6]
    big = Image.new("RGB", (ip.CELL_W * 4, 440), BG)
    for j, i in enumerate(pick):
        tile = bg_flat(results[8][1][i].crop((0, 190, ip.CELL_W, 630)))
        big.paste(tile, (j * ip.CELL_W, 0))
    big.save(os.path.join(DOC_DIR, "candidate_frames_0_2_4_6_native_res.png"))
    # difference heat sheet: |candidate - source| x6, frames 1..7
    heat = Image.new("RGB", (ip.CELL_W * 7, 440), (0, 0, 0))
    s = np.array(src).astype(np.int16)
    for j in range(1, 8):
        a = np.array(results[8][1][j]).astype(np.int16)
        dlt = np.clip(np.abs(a[..., :3] - s[..., :3]).max(axis=-1) * 6 + np.abs(a[..., 3] - s[..., 3]) * 3, 0, 255).astype(np.uint8)
        im = Image.fromarray(dlt, "L").crop((0, 190, ip.CELL_W, 630)).convert("RGB")
        heat.paste(im, ((j - 1) * ip.CELL_W, 0))
    heat.save(os.path.join(DOC_DIR, "difference_heat_frames_1_to_7.png"))
    # GIFs
    ticks = 16
    comp = []
    for t in range(ticks):
        a = crop_game(approved[(t // 2) % 8], up)
        c8 = crop_game(results[8][1][(t // 2) % 8], up)
        c16 = crop_game(results[16][1][t % 16], up)
        w = a.width
        im = Image.new("RGB", (w * 3, a.height + 14), (20, 20, 26))
        for k, (tt, tile) in enumerate((("approved 8f", a), ("candidate 8f", c8), ("candidate 16f", c16))):
            im.paste(tile, (k * w, 14))
            ImageDraw.Draw(im).text((k * w + 4, 1), tt, fill=(235, 235, 235))
        comp.append(im)
    save_gif(os.path.join(DOC_DIR, "compare_approved_vs_candidates_game_scale_x4.gif"), comp, [80] * ticks)
    g8 = [crop_game(f, up) for f in results[8][1]]
    save_gif(os.path.join(DOC_DIR, "candidate_8f_game_scale_x4.gif"), g8, [160] * 8)
    g16 = [crop_game(f, up) for f in results[16][1]]
    save_gif(os.path.join(DOC_DIR, "candidate_16f_game_scale_x4.gif"), g16, [80] * 16)
    g1 = [bg_flat(f, ENGINE_SCALE, 1).crop((0, 52, 72, 164)) for f in results[8][1]]
    save_gif(os.path.join(DOC_DIR, "candidate_8f_game_scale_x1.gif"), g1, [160] * 8)

    print(json.dumps({k: v["passed"] for k, v in qa["sets"].items()}), "passed_all", qa["passed_all"])
    for n, rep in qa["sets"].items():
        for c in rep["checks"]:
            if not c["pass"]:
                print("FAIL", n, c["id"], c["detail"])


if __name__ == "__main__":
    main()
