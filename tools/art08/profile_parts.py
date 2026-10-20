#!/usr/bin/env python3
"""ART-08 profile rig: cut approved ART-04 stair_up_key into rigid parts + bendable tube textures.
Donor: assets/art04/kaze/stair_up_key.png (320x724, scale 0.303125). One donor only, so every part
shares the same drawing style. Output: source_art/art08/profile/*.png and parts.json.
Pure numpy/cv2/PIL; deterministic."""
import json, os, sys
import numpy as np, cv2
from PIL import Image
from scipy import ndimage as ndi

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DONOR = os.path.join(ROOT, "assets/art04/kaze/stair_up_key.png")
OUT = os.path.join(ROOT, "source_art/art08/profile")
OUTLINE = (30, 14, 48)

def poly(pts): return np.array(pts, np.int32)
def mask_of(shape, *polys):
    m = np.zeros(shape, np.uint8)
    for p in polys: cv2.fillPoly(m, [poly(p)], 255)
    return m > 0

# ---- landmarks in donor pixel coordinates (read off the 4x-7x grid views)
HIP = (177.0, 448.0)        # hip joint (under the skirt) on the rear-leg axis
ANKLE = (95.0, 550.0)       # rear-leg ankle on the same axis
SHOULDER = (171.0, 358.0)   # near-arm shoulder centre (puff)
WRIST = (125.5, 438.5)      # cuff bottom centre
NAPE = (188.0, 335.0)       # hair stream pivot
KNOT = (183.0, 305.0)       # ribbon knot
BOOT_ANKLE = (248.0, 517.0) # on the flat front boot donor, where the shin enters

HEAD_POLY = [(192,296),(215,292),(246,299),(266,318),(271,340),(262,358),(244,356),(228,353),(213,357),(197,357),(190,346),(184,330),(182,314)]
TORSO_POLY = [(168,349),(188,349),(200,351),(212,365),(225,366),(229,382),(223,400),(206,404),(198,408),(199,421),(194,434),(218,428),(201,446),(186,453),(168,459),(148,460),(130,458),(116,454),(110,446),(112,438),(118,440),(129,420),(140,395),(150,380),(160,365)]
ARM_POLY = [(160,347),(168,346),(184,348),(193,362),(191,381),(179,393),(162,410),(148,425),(141,437),(132,446),(117,441),(115,428),(123,420),(130,418),(141,394),(151,378),(158,366)]
FIST_POLY = [(243,394),(272,394),(272,416),(246,416)]
BOOT_POLY = [(222,511),(262,511),(284,534),(286,568),(222,568)]
REAR_LEG_POLY = [(139,457),(173,456),(179,463),(173,476),(168,483),(150,498),(128,517),(105,543),(97,556),(82,556),(86,543),(98,520),(112,500),(130,487),(135,478),(137,467)]

def load():
    return np.array(Image.open(DONOR).convert("RGBA"))

def drop_specks(arr, min_px=14):
    a = arr.copy(); m = (a[..., 3] > 0).astype(np.uint8)
    n, lab, st, _ = cv2.connectedComponentsWithStats(m, connectivity=8)
    for i in range(1, n):
        if st[i, cv2.CC_STAT_AREA] < min_px: a[lab == i] = 0
    return a

def save_rgba(arr, name):
    os.makedirs(OUT, exist_ok=True)
    a = drop_specks(arr) if name in ('torso.png', 'hair.png', 'head.png', 'ribbon.png') else arr.copy(); a[a[..., 3] == 0] = 0
    Image.fromarray(a).save(os.path.join(OUT, name), optimize=True)

def edge_outline(rgba, thresh=70):
    """Repaint bright boundary pixels so a cut piece keeps a dark outline."""
    a = rgba[..., 3] > 0
    er = ndi.binary_erosion(a, structure=np.array([[0,1,0],[1,1,1],[0,1,0]]))
    edge = a & ~er
    lum = rgba[..., :3].astype(int).sum(-1) / 3
    sel = edge & (lum > thresh)
    out = rgba.copy(); out[sel, :3] = OUTLINE
    return out

def tube_strip(donor, mask, p0, p1, u0, u1, half, fill_top=True):
    """Sample the donor along axis p0->p1 into a straight strip. Returns (rgba[u,v], dict)."""
    p0 = np.array(p0, float); p1 = np.array(p1, float)
    d = p1 - p0; L = np.linalg.norm(d); d /= L; n = np.array([-d[1], d[0]])
    us = np.arange(u0, u1 + 1); vs = np.arange(-half, half + 1)
    U, V = np.meshgrid(us, vs, indexing="ij")
    X = (p0[0] + U * d[0] + V * n[0]).astype(np.float32); Y = (p0[1] + U * d[1] + V * n[1]).astype(np.float32)
    src = donor.astype(np.float32).copy(); src[..., 3] *= (mask > 0)
    pm = src.copy(); pm[..., :3] *= pm[..., 3:4] / 255
    s = cv2.remap(pm, X, Y, cv2.INTER_LINEAR, borderMode=cv2.BORDER_CONSTANT, borderValue=0)
    a = s[..., 3:4] / 255
    rgb = np.where(a > 0.01, s[..., :3] / np.maximum(a, 1e-6), 0)
    out = np.concatenate([rgb, s[..., 3:4]], -1)
    out[..., 3] = np.where(out[..., 3] > 127, 255, 0)
    out = out.clip(0, 255).astype(np.uint8)
    if fill_top:  # replicate the first valid texel per column upward (hidden under the skirt)
        for j in range(out.shape[1]):
            col = out[:, j, 3] > 0
            if col.any():
                i = int(np.argmax(col)); out[:i, j] = out[i, j]
    return out, dict(p0=list(p0), p1=list(p1), length=float(L), u0=int(u0), u1=int(u1), half=int(half))

def extract():
    don = load(); a = don[..., 3] > 0; H, W = a.shape
    parts = {}; meta = {}
    # ---- legs: rear leg tube (straight donor) ------------------------------------------------
    m = mask_of((H, W), REAR_LEG_POLY); m = cv2.dilate(m.astype(np.uint8), np.ones((7, 7), np.uint8)) > 0
    lm = a & m; lm[:472, :136] = False; lm[:, 184:] = False; lm[:459, :] = False
    _, lab = cv2.connectedComponents(lm.astype(np.uint8), connectivity=4); lm = lab == lab[520, 120]
    strip, mt = tube_strip(don, lm, HIP, ANKLE, -8, 140, 24)
    # the tube ends at the ankle (u=131); anything past it is boot shaft and gets replaced by the boot piece
    strip[int(mt["length"]) + 4 - mt["u0"]:] = 0
    parts["leg_tube"] = strip; meta["leg_tube"] = mt
    # ---- boot: flat donor (front boot) ------------------------------------------------------
    bm = mask_of((H, W), BOOT_POLY) & a
    x0, y0 = 220, 509
    boot = don[y0:572, x0:290].copy(); boot[..., 3] *= bm[y0:572, x0:290]
    boot = edge_outline(boot)
    parts["boot"] = boot; meta["boot"] = dict(origin=[x0, y0], ankle=[BOOT_ANKLE[0]-x0, BOOT_ANKLE[1]-y0])
    # ---- fist ---------------------------------------------------------------------------------
    fm = mask_of((H, W), FIST_POLY) & a
    fy0, fx0 = 394, 243
    fist = don[fy0:418, fx0:274].copy(); fist[..., 3] *= fm[fy0:418, fx0:274]
    # keep only skin-ish pixels of the fist (drop cuff white / sleeve purple)
    rgb = fist[..., :3].astype(int)
    skin = (rgb[..., 0] > rgb[..., 2] + 20) | (rgb.sum(-1) < 150)
    fist[..., 3] = np.where(skin & (fist[..., 3] > 0), 255, 0).astype(np.uint8)
    parts["fist"] = fist; meta["fist"] = dict(origin=[fx0, fy0])
    # ---- arm tube (near sleeve) ----------------------------------------------------------------
    arm_m = mask_of((H, W), ARM_POLY) & a
    astrip, am = tube_strip(don, arm_m, SHOULDER, WRIST, -22, 100, 26, fill_top=False)
    parts["arm_tube"] = astrip; meta["arm_tube"] = am
    # ---- head -----------------------------------------------------------------------------------
    rgb = don[..., :3].astype(int)
    g = (rgb[..., 1] > rgb[..., 0] + 30) & (rgb[..., 1] > rgb[..., 2] + 20) & a
    gd = cv2.dilate(g.astype(np.uint8), np.ones((3, 3), np.uint8)) > 0
    ribbon_m = (g | (gd & (rgb.sum(-1) < 120) & a)); ribbon_m[:, 200:] = False; ribbon_m[352:] = False
    head_m = mask_of((H, W), HEAD_POLY) & a & ~ribbon_m
    torso_m = mask_of((H, W), TORSO_POLY) & a & ~head_m & ~ribbon_m
    arm_in_torso = mask_of((H, W), ARM_POLY)
    # ---- torso: arm region refilled (jacket above the hem line, skirt below) ---------------------
    skin = (rgb[..., 0] > rgb[..., 2] + 18) & (rgb[..., 0] > 80)
    torso_m &= ~(skin & (np.arange(H)[:, None] > 424))
    torso_m[438:, :120] = False
    yy, xx = np.mgrid[0:H, 0:W]
    hem = 423 + (xx - 128) * 0.19
    region = mask_of((H, W), TORSO_POLY) & arm_in_torso
    purple = (rgb[..., 2] > 125) & (rgb[..., 0] > 80) & (rgb[..., 0] < 150) & (rgb[..., 1] < 75)
    jac_src = torso_m & ~arm_in_torso & purple & (yy < hem)
    sk_src = torso_m & ~arm_in_torso & (rgb.sum(-1) <= 215) & (rgb.sum(-1) > 90) & (yy >= hem - 6) & ~skin
    tor = don.copy()
    for src, sel in ((jac_src, region & (yy < hem)), (sk_src, region & (yy >= hem))):
        idx = ndi.distance_transform_edt(~src, return_distances=False, return_indices=True)
        fl = don[idx[0], idx[1], :3].astype(np.float32)
        fl = cv2.GaussianBlur(fl, (0, 0), 1.2)
        tor[sel, :3] = fl[sel].astype(np.uint8)
    tor[..., 3] = np.where(torso_m | region, 255, 0)
    torso = edge_outline(tor)
    parts["torso"] = torso
    # ---- head -----------------------------------------------------------------------------------
    hd = don.copy(); hd[..., 3] = np.where(head_m, 255, 0); parts["head"] = hd
    # ---- ribbon ----------------------------------------------------------------------------------
    rb = don.copy(); rb[..., 3] = np.where(ribbon_m, 255, 0); parts["ribbon"] = rb
    # ---- hair stream: everything else above the hip not claimed above, plus a back fill under the torso
    HAND = mask_of((H, W), [(100, 436), (138, 440), (136, 476), (100, 476)]) | mask_of((H, W), [(104, 416), (130, 416), (130, 444), (104, 444)])
    claimed = head_m | torso_m | ribbon_m | arm_in_torso
    hair_m = a & ~claimed & ~HAND
    hair_m[455:] = False; hair_m[:, 192:] = False
    hair_dark = hair_m & (rgb.sum(-1) < 330)
    under = (mask_of((H, W), TORSO_POLY) | arm_in_torso | ribbon_m) & ~mask_of((H, W), [(150, 400), (260, 400), (260, 470), (150, 470)])
    under &= (xx < 200)
    # fill the ribbon-over-hair holes and the strip behind the torso with nearest hair texels
    idx = ndi.distance_transform_edt(~hair_dark, return_distances=False, return_indices=True)
    fl = don[idx[0], idx[1], :3]
    hs = don.copy()
    near_hair = ndi.binary_dilation(hair_dark, iterations=9)
    back = under & near_hair & ~hair_m & (xx < 188)
    # ribbon pixels that lie over empty background stay empty
    hs[back, :3] = fl[back]
    hs[..., 3] = np.where(hair_m | back, 255, 0)
    parts["hair"] = hs
    meta["masks"] = {}
    return don, parts, meta, dict(head=head_m, torso=torso_m, ribbon=ribbon_m, hair=hair_m, arm=arm_m)

def main():
    don, parts, meta, masks = extract()
    os.makedirs(OUT, exist_ok=True)
    for k, v in parts.items():
        if k in ("head", "ribbon", "hair", "torso"):
            ys, xs = np.nonzero(v[..., 3] > 0); box = (int(xs.min()), int(ys.min()), int(xs.max()) + 1, int(ys.max()) + 1)
            meta[k] = dict(origin=[box[0], box[1]])
            save_rgba(v[box[1]:box[3], box[0]:box[2]], f"{k}.png")
        else:
            save_rgba(v, f"{k}.png")
    meta["landmarks"] = dict(hip=HIP, ankle=ANKLE, shoulder=SHOULDER, wrist=WRIST, nape=NAPE, knot=KNOT, boot_ankle=BOOT_ANKLE)
    json.dump(meta, open(os.path.join(OUT, "parts.json"), "w"), indent=1)
    # rest-pose recomposite debug
    dbg = Image.new("RGBA", (320, 724), (120, 140, 150, 255))
    for k in ("hair", "torso", "head", "ribbon"):
        o = meta[k]["origin"]; im = Image.open(os.path.join(OUT, f"{k}.png")); dbg.alpha_composite(im, tuple(o))
    dbg.convert("RGB").crop((20, 280, 300, 480)).resize((1120, 800), Image.NEAREST).save("/tmp/claude-0/s/rest_upper.png")

if __name__ == "__main__":
    main()
