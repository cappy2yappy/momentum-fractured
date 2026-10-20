#!/usr/bin/env python3
"""ART-08 rear rig parts. Donors: approved ART-04 enter_depth_key (rear body, arms, hair, boots) and turn_depth_key (long straight stocking leg)."""
import json, os, sys
import numpy as np, cv2
from PIL import Image
from scipy import ndimage as ndi
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from profile_parts import mask_of, edge_outline, drop_specks, tube_strip, ROOT
OUT = os.path.join(ROOT, "source_art/art08/rear")
EN = os.path.join(ROOT, "assets/art04/kaze/enter_depth_key.png")
TU = os.path.join(ROOT, "assets/art04/kaze/turn_depth_key.png")

ARM_R = [(188,335),(203,335),(214,362),(226,396),(224,408),(226,430),(230,447),(222,455),(212,452),(207,434),(203,426),(196,408),(192,380),(187,352)]
ARM_L = [(100,396),(119,396),(121,422),(121,436),(118,464),(102,468),(97,440),(101,420)]
LEG_L_TU = [(124,452),(158,452),(156,490),(131,545),(98,548),(104,545),(118,500),(122,470)]   # turn key left leg
BOOT_FLAT = (164,518,196,568)    # enter key right boot (planted, rear view), x0,y0,x1,y1
BOOT_LIFT = (124,520,166,602)    # enter key left boot (toe-off, sole visible)
SH_R = (194.0, 342.0); SH_L = (113.0, 392.0)
NAPE = (160.0, 330.0)

def save(a, name, spec=True):
    os.makedirs(OUT, exist_ok=True)
    a = drop_specks(a) if spec else a
    a = a.copy(); a[a[..., 3] == 0] = 0
    Image.fromarray(a).save(os.path.join(OUT, name))

def crop_opaque(a):
    ys, xs = np.nonzero(a[..., 3] > 0)
    box = (int(xs.min()), int(ys.min()), int(xs.max()) + 1, int(ys.max()) + 1)
    return a[box[1]:box[3], box[0]:box[2]], box[:2]

def main():
    en = np.array(Image.open(EN).convert("RGBA")); tu = np.array(Image.open(TU).convert("RGBA"))
    H, W = en.shape[:2]; a = en[..., 3] > 0; rgb = en[..., :3].astype(int)
    meta = {}
    armr = mask_of((H, W), ARM_R) & a; arml = mask_of((H, W), ARM_L) & a
    legs_zone = np.zeros((H, W), bool); legs_zone[452:] = True
    # hair+head+ribbon: dark/green pixels above the skirt, plus anything not jacket/arm/skirt
    yy, xx = np.mgrid[0:H, 0:W]
    green = (rgb[..., 1] > rgb[..., 0] + 30) & (rgb[..., 1] > rgb[..., 2] + 20)
    dark = (rgb[..., 0] < 90) & (rgb[..., 2] < 135)
    skirt_zone = (yy >= 402) & (yy < 452) & (xx > 108) & (xx < 210)
    upper = a & (yy < 452) & ~armr & ~arml
    hair = upper & ~skirt_zone & (green | dark | (xx < 150)) & (yy < 425)
    jacket_poly = mask_of((H, W), [(150,336),(192,336),(198,352),(200,392),(206,404),(206,420),(204,440),(190,446),(150,448),(120,444),(114,430),(118,408),(130,404),(150,392)])
    torso = upper & ~hair & (jacket_poly | skirt_zone)
    # fill the jacket back under the hair so the hair can sway: paint jacket colour on the polygon
    jac = np.array([108, 44, 158], np.uint8)
    fillreg = mask_of((H, W), [(124,372),(152,340),(162,336),(162,404),(122,404)]) & ~torso & ~armr & ~arml
    tor = en.copy(); tor[fillreg, :3] = jac
    tor[..., 3] = np.where(torso | fillreg, 255, 0)
    hr = en.copy(); hr[..., 3] = np.where(hair, 255, 0)
    for name, arr in (("torso", tor), ("hair", hr)):
        c, o = crop_opaque(drop_specks(arr) if name else arr); save(c, name + ".png", False); meta[name] = dict(origin=list(o))
    for name, m in (("arm_r", armr), ("arm_l", arml)):
        arr = en.copy(); arr[..., 3] = np.where(m, 255, 0)
        c, o = crop_opaque(arr); save(c, name + ".png"); meta[name] = dict(origin=list(o))
    # boots
    for name, (x0, y0, x1, y1) in (("boot_flat", BOOT_FLAT), ("boot_lift", BOOT_LIFT)):
        c = en[y0:y1, x0:x1].copy()
        # keep only the connected boot blob (drop neighbouring leg stocking above the ankle line)
        save(c, name + ".png", False); meta[name] = dict(origin=[x0, y0])
    # leg tube from the turn key: left leg, hip->ankle axis
    m = mask_of(tu.shape[:2], LEG_L_TU) & (tu[..., 3] > 0)
    m = ndi.binary_dilation(m, iterations=2) & (tu[..., 3] > 0); m[:446] = False; m[552:] = False
    p0 = (141.0, 446.0); p1 = (112.0, 546.0)
    strip, mt = tube_strip(tu, m, p0, p1, -4, 110, 24)
    save(strip, "leg_tube.png", False); meta["leg_tube"] = mt
    meta["landmarks"] = dict(sh_r=SH_R, sh_l=SH_L, nape=NAPE, hip_l=[141, 446], hip_r=[177, 446])
    json.dump(meta, open(os.path.join(OUT, "parts.json"), "w"), indent=1)
    dbg = Image.new("RGBA", (320, 724), (120, 140, 150, 255))
    for k in ("hair", "torso", "arm_r", "arm_l"):
        dbg.alpha_composite(Image.open(os.path.join(OUT, k + ".png")), tuple(meta[k]["origin"]))
    dbg.convert("RGB").crop((60, 275, 260, 470)).resize((800, 780), Image.NEAREST).save("/tmp/claude-0/s/rear_rest.png")
    for k in ("boot_flat", "boot_lift", "leg_tube"):
        im = Image.open(os.path.join(OUT, k + ".png")); b = Image.new("RGBA", im.size, (120, 140, 150, 255)); b.alpha_composite(im)
        b.convert("RGB").resize((im.width * 4, im.height * 4), Image.NEAREST).save(f"/tmp/claude-0/s/rear_{k}.png")
if __name__ == "__main__":
    main()
