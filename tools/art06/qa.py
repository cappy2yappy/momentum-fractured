#!/usr/bin/env python3
"""ART-06 QA: registration invariants, near-duplicate detection and review boards.
Writes <out>/QA.json and board PNGs. Technical checks cannot prove artistic acceptance."""
import argparse, json, os
import numpy as np
from PIL import Image, ImageDraw

A = 8


def load_frames(root, clip, cell):
    sheet = Image.open(os.path.join(root, clip["path"])).convert("RGBA")
    n = sheet.width // cell[0]
    return [sheet.crop((i * cell[0], 0, (i + 1) * cell[0], cell[1])) for i in range(n)]


def iou(a, b):
    ma, mb = np.array(a)[:, :, 3] > A, np.array(b)[:, :, 3] > A
    return float((ma & mb).sum() / max((ma | mb).sum(), 1))


def rgb_diff(a, b):
    aa, bb = np.array(a).astype(np.int16), np.array(b).astype(np.int16)
    u = (aa[:, :, 3] > A) | (bb[:, :, 3] > A)
    return float(np.abs(aa[:, :, :3] - bb[:, :, :3])[u].mean()) if u.any() else 0.0


def board(frames, cols, scale, label_prefix, bg=(128, 128, 128), baseline=None):
    w, h = frames[0].size
    tw, th = int(w * scale), int(h * scale)
    rows = (len(frames) + cols - 1) // cols
    # crop the empty top of each cell for readable boards
    top = 150
    th2 = int((h - top) * scale)
    b = Image.new("RGB", (cols * tw, rows * th2), bg)
    d = ImageDraw.Draw(b)
    for i, f in enumerate(frames):
        x, y = (i % cols) * tw, (i // cols) * th2
        im = f.crop((0, top, w, h)).resize((tw, th2), Image.LANCZOS)
        b.paste(im, (x, y), im)
        if baseline is not None:
            by = y + int((baseline - top) * scale)
            d.line([(x, by), (x + tw, by)], fill=(255, 200, 0), width=1)
        d.text((x + 6, y + 4), f"{label_prefix}{i}", fill=(255, 255, 255))
    return b


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=".")
    ap.add_argument("--dir", default="assets/art06/kaze/lateral")
    ap.add_argument("--thr", type=float, default=0.94, help="alpha IoU above which two frames count as near-duplicates")
    a = ap.parse_args()
    man = json.load(open(os.path.join(a.root, a.dir, "MANIFEST.json")))
    cell = man["contract"]["cell_size"]
    base = man["contract"]["baseline_y"]
    report = {"thr_near_duplicate_iou": a.thr, "clips": {}, "problems": []}
    allframes = []
    for clip in man["clips"]:
        fr = load_frames(a.root, clip, cell)
        allframes += fr
        inv = []
        for i, f in enumerate(fr):
            arr = np.array(f)
            ys, xs = np.where(arr[:, :, 3] > A)
            bottom = int(ys.max()) + 1
            hidden = int(((arr[:, :, 3] == 0) & (arr[:, :, :3].sum(axis=2) != 0)).sum())
            margin = int(min(xs.min(), ys.min(), cell[0] - 1 - xs.max(), cell[1] - 1 - ys.max()))
            row = {"index": i, "bottom_row": bottom, "baseline_ok": bottom == base, "hidden_rgb_px": hidden, "margin_px": margin}
            inv.append(row)
            if bottom != base: report["problems"].append(f"{clip['id']}[{i}] baseline {bottom}!={base}")
            if hidden: report["problems"].append(f"{clip['id']}[{i}] hidden RGB")
            if margin < 12: report["problems"].append(f"{clip['id']}[{i}] margin {margin}<12")
        pairs, n = [], len(fr)
        for i in range(n):
            for j in range(i + 1, n):
                p = {"a": i, "b": j, "alpha_iou": round(iou(fr[i], fr[j]), 3), "rgb_diff": round(rgb_diff(fr[i], fr[j]), 2)}
                pairs.append(p)
        dup = [p for p in pairs if p["alpha_iou"] >= a.thr]
        # consecutive-frame motion: how much each step changes the silhouette
        steps = [round(1 - iou(fr[i], fr[(i + 1) % n if clip["loop"] else min(i + 1, n - 1)]), 3) for i in range(n)]
        hashes = {x["sha256_rgba"] for x in clip["frames"]}
        report["clips"][clip["id"]] = {"frames": n, "unique_hashes": len(hashes), "invariants": inv,
                                       "near_duplicate_pairs": dup, "max_iou_pair": max(pairs, key=lambda p: p["alpha_iou"]) if pairs else None,
                                       "step_change_1_minus_iou": steps, "pairs": pairs}
        for p in dup: report["problems"].append(f"{clip['id']} frames {p['a']}&{p['b']} near-duplicate (IoU {p['alpha_iou']})")
        cols = 3 if n <= 6 else 4
        board(fr, cols, 0.5, clip["id"] + ":", baseline=base).save(os.path.join(a.root, a.dir, f"board_{clip['id']}.png"))
    board(allframes, 5, 0.3, "f", baseline=base).save(os.path.join(a.root, a.dir, "board_all13.png"))
    json.dump(report, open(os.path.join(a.root, a.dir, "QA.json"), "w"), indent=1)
    for k, v in report["clips"].items():
        print(k, "unique", v["unique_hashes"], "/", v["frames"], "| max-IoU pair", v["max_iou_pair"], "| near-dups", [(p["a"], p["b"], p["alpha_iou"]) for p in v["near_duplicate_pairs"]], "| steps", v["step_change_1_minus_iou"])
    print("PROBLEMS:", report["problems"] or "none")


if __name__ == "__main__":
    main()
