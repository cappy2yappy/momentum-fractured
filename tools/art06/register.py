#!/usr/bin/env python3
"""ART-06 registration: cut raw RGBA drawing sheets into frames, scale each clip uniformly,
register to the approved run-strip contract and write strips, hero strips and a manifest.

No per-frame resizing, rotation, mirroring, trimming or de-duplication. One uniform scale per
clip (calibrated against the approved run strip), x anchored on lower-body mass, y anchored on
the lowest opaque row, exactly the way the approved run strip is registered (baseline 491).
Usage: python tools/art06/register.py [--root .] [--out assets/art06/kaze/lateral]
"""
import argparse, hashlib, json, os, sys
import numpy as np
from PIL import Image

A_THR = 8  # alpha threshold for "opaque"


def bbox(a):
    ys, xs = np.where(a > A_THR)
    return int(xs.min()), int(ys.min()), int(xs.max()) + 1, int(ys.max()) + 1


def cut(img, grid):
    cols, rows = grid
    w, h = img.size
    cw, ch = w // cols, h // rows
    cells = []
    for r in range(rows):
        for c in range(cols):
            cells.append(img.crop((c * cw, r * ch, (c + 1) * cw, (r + 1) * ch)))
    return cells


def foot_mass_x(alpha, box):
    x0, y0, x1, y1 = box
    top = y0 + int((y1 - y0) * 0.55)
    sub = alpha[top:y1, x0:x1].astype(np.float64)
    if sub.sum() == 0:
        return (x0 + x1) / 2.0
    xs = np.arange(x0, x1)
    return float((sub.sum(axis=0) * xs).sum() / sub.sum())


def sha(arr):
    return hashlib.sha256(arr.tobytes()).hexdigest()


def register_clip(clip, cells, contract, ss):
    cw, ch = contract["cell_size"]
    base, rootx = contract["baseline_y"], contract["root_x"]
    boxes, alphas = [], []
    for cell in cells:
        a = np.array(cell)[:, :, 3]
        alphas.append(a)
        boxes.append(bbox(a))
    heights = [b[3] - b[1] for b in boxes]
    cal = clip["calibrate"]
    if cal["mode"] == "anchor":
        ref = heights[cal["anchor"]]
    else:
        ref = float(np.median(heights))
    scale = cal.get("scale_override") or cal["target_h"] / ref
    out, meta = [], []
    for i, cell in enumerate(cells):
        a = alphas[i]
        b = boxes[i]
        fx = foot_mass_x(a, b)
        # pad so the whole drawing survives; crop is a pure translation after scaling
        tw, th = max(1, round(cell.width * scale * ss)), max(1, round(cell.height * scale * ss))
        sc = cell.resize((tw, th), Image.LANCZOS)
        sa = np.array(sc)[:, :, 3]
        sb = bbox(sa)
        sfx = fx * scale * ss
        dx = round(rootx * ss - sfx)
        dy = round(base * ss - sb[3])
        P = max(tw, th)
        big = Image.new("RGBA", (cw * ss + 2 * P, ch * ss + 2 * P), (0, 0, 0, 0))
        big.alpha_composite(sc, (dx + P, dy + P))
        canvas = big.crop((P, P, P + cw * ss, P + ch * ss))
        cropped = int(np.array(sc)[:, :, 3].astype(np.int64).sum() - np.array(canvas)[:, :, 3].astype(np.int64).sum()) != 0
        arr = np.array(canvas)
        # clean hidden RGB (ART05 rule)
        arr[arr[:, :, 3] == 0] = 0
        fb = bbox(arr[:, :, 3])
        margin = min(fb[0], fb[1], cw * ss - fb[2], ch * ss - fb[3])
        edge_touch_src = bool(b[0] <= 1 or b[1] <= 1 or b[2] >= cell.width - 1 or b[3] >= cell.height - 1)
        out.append(Image.fromarray(arr))
        meta.append({
            "index": i,
            "phase": clip["frames"][i]["phase"],
            "alpha_bbox": list(fb),
            "bbox_h": fb[3] - fb[1],
            "margin_px": int(margin),
            "source_cell_clipped": edge_touch_src,
            "cropped_by_cell": cropped,
            "foot_mass_x": round(float(foot_mass_x(arr[:, :, 3], fb)), 1),
            "sha256_rgba": sha(arr),
        })
    return out, meta, scale


def strip(frames):
    w, h = frames[0].size
    s = Image.new("RGBA", (w * len(frames), h), (0, 0, 0, 0))
    for i, f in enumerate(frames):
        s.alpha_composite(f, (i * w, 0))
    return s


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=".")
    ap.add_argument("--raw", default="source_art/art06")
    ap.add_argument("--out", default="assets/art06/kaze/lateral")
    ap.add_argument("--frames", default="source_art/art06/frames")
    a = ap.parse_args()
    root = a.root
    auth = json.load(open(os.path.join(root, "source_art/art06/authoring.json")))
    contract = auth["contract"]
    ss = contract["hero_supersample"]
    os.makedirs(os.path.join(root, a.out, "hero"), exist_ok=True)
    os.makedirs(os.path.join(root, a.frames), exist_ok=True)
    manifest = {"schema_version": 1, "family": auth["family"], "contract": contract, "clips": []}
    for clip in auth["clips"]:
        raw = Image.open(os.path.join(root, a.raw, clip["raw"])).convert("RGBA")
        cells = cut(raw, clip["grid"])
        assert len(cells) == len(clip["frames"]), (clip["id"], len(cells))
        entry = {"id": clip["id"], "fps": contract["fps"], "loop": clip["loop"], "status": clip["status"],
                 "raw": clip["raw"], "raw_sha256": hashlib.sha256(open(os.path.join(root, a.raw, clip["raw"]), "rb").read()).hexdigest()}
        for tag, k in (("", 1), ("hero", ss)):
            frames, meta, scale = register_clip(clip, cells, contract, k)
            sp = os.path.join(root, a.out, ("hero/" if tag else "") + clip["id"] + (("_" + tag) if tag else "") + ".png")
            strip(frames).save(sp, optimize=True)
            if not tag:
                for i, f in enumerate(frames):
                    f.save(os.path.join(root, a.frames, f"{clip['id']}_{i:02d}.png"), optimize=True)
                entry["frames"] = meta
                entry["source_to_cell_scale"] = round(scale, 5)
                entry["path"] = os.path.relpath(sp, root)
                entry["sha256"] = hashlib.sha256(open(sp, "rb").read()).hexdigest()
            else:
                entry["hero_path"] = os.path.relpath(sp, root)
                entry["hero_sha256"] = hashlib.sha256(open(sp, "rb").read()).hexdigest()
        manifest["clips"].append(entry)
        print(clip["id"], "scale", entry["source_to_cell_scale"], "heights", [m["bbox_h"] for m in entry["frames"]],
              "min margin", min(m["margin_px"] for m in entry["frames"]), "clipped", [m["index"] for m in entry["frames"] if m["source_cell_clipped"]])
    json.dump(manifest, open(os.path.join(root, a.out, "MANIFEST.json"), "w"), indent=1)


if __name__ == "__main__":
    sys.exit(main())
