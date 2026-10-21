#!/usr/bin/env python3
"""ART-08 descent upper body: cut the approved ART-04 stair_down_key (upright, arms in contra-swing) into
rigid layers. The donor faces left, so it is mirrored to face right (the strip contract). When Transition
mirrors the strip for the leftward R17->R14 descent, the ribbon and hair fall on their drawn side.
Legs and boots are NOT taken from this donor; the existing profile leg tube and boot (same drawing style) are reused.
Outputs: source_art/art08/down/{upper_rest,hair_tips}.png and down.json (origins, landmarks)."""
import json, os
import numpy as np, cv2
from PIL import Image
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DONOR = os.path.join(ROOT, "assets/art04/kaze/stair_down_key.png")
OUT = os.path.join(ROOT, "source_art/art08/down")

# landmarks in MIRRORED donor px (x' = 319 - x)
HIP = (172.0, 442.0)        # pelvis point under the skirt (leg tubes hang from here)
NAPE = (172.0, 340.0)
HEM = [(100,426),(112,430),(122,438),(136,448),(150,453),(165,452),(180,448),(196,445),(204,442)]  # skirt hem polyline (keep above)
BACK_ARM = [(147,350),(172,354),(162,386),(131,414),(123,426),(104,419),(111,408),(134,384),(146,368)]
TIP_X = 150           # hair/ribbon pixels left of this wave
# forearm pieces (rotate about the elbow): polygon, elbow
FORE_FRONT = dict(poly=[(183,394),(197,384),(252,414),(252,444),(214,442),(198,426)], elbow=(190.0, 397.0))
SKIRT_KEEP = {"forearm_front": [(186,430),(208,430),(208,450),(186,450)], "forearm_back": [(108,430),(134,424),(152,440),(152,458),(108,446)]}
FORE_BACK = dict(poly=[(150,392),(126,382),(88,418),(84,458),(126,450),(142,418)], elbow=(138.0, 391.0))

def poly_mask(shape, pts):
    m = np.zeros(shape, np.uint8); cv2.fillPoly(m, [np.array(pts, np.int32)], 255); return m > 0

def main():
    os.makedirs(OUT, exist_ok=True)
    d = np.array(Image.open(DONOR).convert("RGBA"))[:, ::-1].copy()      # mirror to face right
    H, W = d.shape[:2]; a = d[..., 3] > 0
    yy, xx = np.mgrid[0:H, 0:W]
    rgb = d[..., :3].astype(int)
    # remove legs: below the hem polyline, inside the leg zone x 106..216 ; also everything y>=458
    hem_y = np.interp(xx, [p[0] for p in HEM], [p[1] for p in HEM], left=HEM[0][1], right=HEM[-1][1])
    below = (yy > hem_y + 1) & (xx >= 106) & (xx <= 216)
    keep = a & ~below & (yy < 458)
    # the donor thighs/stockings on the far side of x 216 are removed too (front boot, legs): y > 446
    keep &= ~((xx > 216) & (yy > 446)); keep &= ~((xx < 106) & (yy > 452))
    up = d.copy(); up[..., 3] = np.where(keep, 255, 0)
    # hair/ribbon tips: everything at x<TIP_X, y<405 that is not the back sleeve or skin (hand)
    arm = cv2.dilate(poly_mask((H, W), BACK_ARM).astype(np.uint8), np.ones((3, 3), np.uint8)) > 0
    skin = (rgb[..., 0] > rgb[..., 2] + 25) & (rgb[..., 0] > 110)
    white = rgb.sum(-1) > 600
    tips = keep & (xx < TIP_X) & (yy < 410) & ~arm & ~skin & ~white
    rest = keep & ~tips
    lum = rgb.sum(-1)
    pieces = {}
    for nm, fa in (("forearm_front", FORE_FRONT), ("forearm_back", FORE_BACK)):
        pm = poly_mask((H, W), fa["poly"]) & rest & ~poly_mask((H, W), SKIRT_KEEP[nm])
        # beyond the elbow line (axis = elbow -> centroid of the piece)
        ys0, xs0 = np.nonzero(pm); c = np.array([xs0.mean(), ys0.mean()]); e = np.array(fa["elbow"]); ax = (c - e) / np.linalg.norm(c - e)
        dot = (xx - e[0]) * ax[0] + (yy - e[1]) * ax[1]
        piece = pm & (dot >= -3); cut = pm & (dot >= 0)
        pieces[nm] = piece; rest = rest & ~cut
    r = d.copy(); r[..., 3] = np.where(rest, 255, 0)
    t = d.copy(); t[..., 3] = np.where(tips, 255, 0)
    meta = dict(landmarks=dict(hip=HIP, nape=NAPE), tip_x=TIP_X, size=[W, H])
    ims = [("upper_rest", r), ("hair_tips", t)]
    for nm, pmk in pieces.items():
        p = d.copy(); p[..., 3] = np.where(pmk, 255, 0); ims.append((nm, p))
    meta["forearm_front"] = dict(elbow=FORE_FRONT["elbow"]); meta["forearm_back"] = dict(elbow=FORE_BACK["elbow"])
    for name, im in ims:
        ys, xs = np.nonzero(im[..., 3] > 0); box = (int(xs.min()), int(ys.min()), int(xs.max()) + 1, int(ys.max()) + 1)
        sub = im[box[1]:box[3], box[0]:box[2]].copy(); sub[sub[..., 3] == 0] = 0
        Image.fromarray(sub).save(os.path.join(OUT, name + ".png"), optimize=True)
        meta.setdefault(name, {}); meta[name]["origin"] = [box[0], box[1]]
    json.dump(meta, open(os.path.join(OUT, "down.json"), "w"), indent=1)
    dbg = Image.new("RGBA", (W, H), (100, 112, 122, 255)); dbg.alpha_composite(Image.fromarray(r)); dbg.alpha_composite(Image.fromarray(t))
    for nm, pmk in pieces.items():
        p = d.copy(); p[..., 3] = np.where(pmk, 255, 0); dbg.alpha_composite(Image.fromarray(p))
    dbg.convert("RGB").crop((40, 280, 260, 480)).resize((880, 800), Image.NEAREST).save(os.path.join(OUT, "_debug_rest.png"))
    print(meta)

if __name__ == "__main__":
    main()
