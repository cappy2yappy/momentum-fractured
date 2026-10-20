#!/usr/bin/env python3
"""ART-08 front-three-quarter rig parts from the approved idle strip frame 0 (assets/kaze/cleaned/kaze_idle_strip.png),
resampled by 0.832 so Kaze is ~308 px tall like the ART-04 keys. Used for door_emerge / door_turn_to_side."""
import json, os, sys
import numpy as np, cv2
from PIL import Image
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from profile_parts import mask_of, drop_specks, tube_strip, ROOT
OUT = os.path.join(ROOT, "source_art/art08/front")
K = 308.0 / 370.0
SRC = os.path.join(ROOT, "assets/kaze/cleaned/kaze_idle_strip.png")
ARM_L = [(92,322),(108,318),(110,345),(100,380),(98,410),(95,425),(94,448),(74,448),(72,424),(78,395),(84,360)]
ARM_R = [(168,300),(186,302),(190,322),(188,340),(200,336),(218,335),(218,360),(200,372),(192,376),(178,380),(166,372),(164,340),(164,315)]
TORSO = [(96,295),(192,295),(190,370),(190,400),(192,425),(180,433),(120,433),(92,427),(94,380)]
def crop_opaque(a):
    ys, xs = np.nonzero(a[..., 3] > 0); box = (int(xs.min()), int(ys.min()), int(xs.max()) + 1, int(ys.max()) + 1)
    return a[box[1]:box[3], box[0]:box[2]], box[:2]
def save(a, name):
    os.makedirs(OUT, exist_ok=True); a = a.copy(); a[a[..., 3] == 0] = 0; Image.fromarray(a).save(os.path.join(OUT, name))
def main():
    im = np.array(Image.open(SRC).convert("RGBA"))[:, :272]
    # scale whole donor (premultiplied) so all coordinates below are in scaled space
    H0, W0 = im.shape[:2]
    pm = im.astype(np.float32); pm[..., :3] *= pm[..., 3:4] / 255
    sc = cv2.resize(pm, (int(W0 * K), int(H0 * K)), interpolation=cv2.INTER_AREA)
    a = sc[..., 3:4] / 255; rgb = np.where(a > 0.02, sc[..., :3] / np.maximum(a, 1e-6), 0)
    d = np.concatenate([rgb, sc[..., 3:4]], -1).clip(0, 255).astype(np.uint8); d[d[..., 3] < 24] = 0
    H, W = d.shape[:2]; al = d[..., 3] > 0
    S = lambda pts: [(int(x * K), int(y * K)) for x, y in pts]
    armL = mask_of((H, W), S(ARM_L)) & al; armR = mask_of((H, W), S(ARM_R)) & al
    tor = (mask_of((H, W), S(TORSO)) | armL | armR) & al
    legzone = np.zeros((H, W), bool); legzone[int(436 * K):] = True
    rest = al & ~armL & ~armR & ~tor & ~legzone
    meta = {}
    for name, m in (("torso", tor), ("arm_l", armL), ("arm_r", armR), ("hair", rest)):
        arr = d.copy(); arr[..., 3] = np.where(m, d[..., 3], 0); c, o = crop_opaque(drop_specks(arr)); save(c, name + ".png"); meta[name] = dict(origin=[int(o[0]), int(o[1])])
    # leg tube: left leg (viewer left, vertical)
    lm = al.copy(); lm[:int(440 * K)] = False; lm[int(538 * K):] = False; lm[:, int(134 * K):] = False; lm[:, :int(92 * K)] = False
    p0 = (112.0 * K, 436.0 * K); p1 = (113.5 * K, 540.0 * K)
    strip, mt = tube_strip(d, lm, p0, p1, -4, int(110 * K), 22)
    save(strip, "leg_tube.png"); meta["leg_tube"] = mt
    for name, (x0, y0, x1, y1), anc in (("boot_a", (96, 536, 134, 592), (114, 541)), ("boot_b", (194, 532, 252, 592), (206, 540))):
        X0, Y0, X1, Y1 = [int(v * K) for v in (x0, y0, x1, y1)]
        c = d[Y0:Y1, X0:X1].copy(); save(c, name + ".png"); meta[name] = dict(origin=[X0, Y0], ankle=[anc[0] * K - X0, anc[1] * K - Y0])
    meta["landmarks"] = dict(hip_l=[112 * K, 436 * K], hip_r=[150 * K, 436 * K], sh_l=[102 * K, 322 * K], sh_r=[178 * K, 312 * K], nape=[130 * K, 292 * K], hip_c=[131 * K, 436 * K])
    meta["scale"] = K
    json.dump(meta, open(os.path.join(OUT, "parts.json"), "w"), indent=1)
    dbg = Image.new("RGBA", (W, H), (120, 140, 150, 255))
    for k in ("hair", "torso", "arm_l", "arm_r"): dbg.alpha_composite(Image.open(os.path.join(OUT, k + ".png")), tuple(meta[k]["origin"]))
    dbg.convert("RGB").crop((20, 150, 240, 380)).resize((660, 690), Image.NEAREST).save("/tmp/claude-0/s/front_rest.png")
if __name__ == "__main__": main()
