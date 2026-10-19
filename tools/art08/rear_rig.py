#!/usr/bin/env python3
"""ART-08 rear-view walk rig (walking away from camera). Straight compressed stocking tubes + boot sprites."""
import json, os, sys, math
import numpy as np, cv2
from PIL import Image
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import rig
from rig import Rig, SS, CELL
PARTS = os.path.join(rig.ROOT, "source_art/art08/rear")
SX = 80   # donor (320 cell, pivot 160) -> 480 cell (pivot 240)

class RearRig(Rig):
    def __init__(self):
        self.meta = json.load(open(os.path.join(PARTS, "parts.json")))
        self.img = {k: np.array(Image.open(os.path.join(PARTS, k + ".png")).convert("RGBA")) for k in
                    ("hair", "torso", "arm_r", "arm_l", "boot_flat", "boot_lift", "leg_tube")}
        self.NAPE = np.array(self.meta["landmarks"]["nape"])
        self.leg_rest = self.meta["leg_tube"]["length"]

    def _leg(self, hip, ankle, boot, boot_rot, tint, boot_scale=1.0, flip=False):
        p0 = np.array(hip, float); p1 = np.array(ankle, float)
        d = p1 - p0; L = np.linalg.norm(d)
        # compress/stretch texture to the projected length (foreshortening); 3 colinear points
        mid = (p0 + p1) / 2
        tube = self._tube("leg_tube", [p0, mid, p1], self.meta["leg_tube"]["u0"], self.meta["leg_tube"]["half"], e=0.1, rest=self.leg_rest)
        if tint != 1.0: tube[..., :3] *= tint
        bm = self.meta[boot]; ox, oy = bm["origin"]
        # ankle anchor in boot donor: flat boot ankle (180,524) ; lift boot ankle (145,527)
        anc = np.array((180.0, 524.0) if boot == "boot_flat" else (145.0, 527.0)) - np.array([ox, oy])
        M = self.affine(boot_rot, anc, p1, boot_scale)
        if flip:
            M = M.copy(); M[0, 0] *= -1; M[1, 0] *= -1
            M[0, 2] = p1[0] + anc[0] * boot_scale * 1.0 - 0.0 if False else M[0, 2]
            M = self.affine(boot_rot, anc * np.array([-1, 1]) + np.array([0, 0]), p1, boot_scale); M[:, 0] *= -1
        b = self._warp_rigid_local(boot, M)
        if tint != 1.0: b[..., :3] *= tint
        return self._over(tube, b)

    def render(self, pose):
        W, H = CELL[0] * SS, CELL[1] * SS
        c = np.array(pose["pelvis"], float)           # hip centre in cell
        tilt = pose.get("tilt", 0.0)
        pivot_donor = np.array([161.0, 446.0])        # donor hip centre
        Mup = self.affine(tilt, pivot_donor, c)
        layers = []
        # torso then arms-behind? arms are in front of jacket/skirt sides
        layers.append(self._warp_rigid("torso", self.meta["torso"]["origin"], Mup))
        for k in ("far", "near"):
            pass
        for nm, sh, key in (("arm_l", self.meta["landmarks"]["sh_l"], "arm_l"), ("arm_r", self.meta["landmarks"]["sh_r"], "arm_r")):
            a = pose[key]; sh = np.array(sh)
            Ma = self.compose(Mup, self.affine(a["rot"], sh, sh + np.array([0.0, a.get("dy", 0.0)])))
            layers.append(self._warp_rigid(nm, self.meta[nm]["origin"], Ma))
        Mh = self.compose(Mup, self.affine(pose.get("hair_rot", 0.0), self.NAPE, self.NAPE))
        hair = self._warp_rigid("hair", self.meta["hair"]["origin"], Mh)
        if pose.get("hair_wave", 0):
            hair = self._wave(hair, Mup[:, :2] @ self.NAPE + Mup[:, 2], pose["hair_wave"], pose.get("hair_phase", 0.0), Mup)
        layers.append(hair)
        legs = []
        for side, key in (("l", "leg_l"), ("r", "leg_r")):
            L = pose[key]
            legs.append(self._leg(L["hip"], L["ankle"], L["boot"], L.get("boot_rot", 0.0), L.get("tint", 1.0), L.get("boot_scale", 1.0), L.get("flip", False)))
        out = np.zeros((H, W, 4), np.float32)
        order = sorted(range(2), key=lambda i: pose[("leg_l", "leg_r")[i]]["ankle"][1])   # farther (higher on screen) first
        for i in order: out = self._over(out, legs[i])
        for l in layers: out = self._over(out, l)
        return self._finish(out)
