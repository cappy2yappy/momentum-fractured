#!/usr/bin/env python3
"""ART-08 front-three-quarter walk rig (walking toward camera) from the approved idle donor."""
import json, os, sys, math
import numpy as np
from PIL import Image
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import rig
from rig import Rig, SS, CELL
PARTS = os.path.join(rig.ROOT, "source_art/art08/front")
class FrontRig(Rig):
    def __init__(self):
        self.meta = json.load(open(os.path.join(PARTS, "parts.json")))
        self.img = {k: np.array(Image.open(os.path.join(PARTS, k + ".png")).convert("RGBA")) for k in
                    ("hair", "torso", "arm_l", "arm_r", "boot_a", "boot_b", "leg_tube")}
        self.NAPE = np.array(self.meta["landmarks"]["nape"]); self.leg_rest = self.meta["leg_tube"]["length"]
        self.CEN = np.array(self.meta["landmarks"]["hip_c"])
    def _leg(self, hip, ankle, boot, rot, scale, tint=1.0):
        p0 = np.array(hip, float); p1 = np.array(ankle, float); mid = (p0 + p1) / 2
        tube = self._tube("leg_tube", [p0, mid, p1], self.meta["leg_tube"]["u0"], self.meta["leg_tube"]["half"], e=0.1, rest=self.leg_rest)
        bm = self.meta[boot]; M = self.affine(rot, bm["ankle"], p1, scale)
        b = self._warp_rigid_local(boot, M)
        out = self._over(tube, b)
        if tint != 1.0: out[..., :3] *= tint
        return out
    def render(self, pose, off=np.array([240.0, 0.0])):
        """pose coordinates are in donor space shifted by `shift` (cell = donor + shift)"""
        W, H = CELL[0] * SS, CELL[1] * SS
        c = np.array(pose["pelvis"], float); Mup = self.affine(pose.get("tilt", 0.0), self.CEN, c)
        L = self.meta["landmarks"]; layers = []
        layers.append(self._warp_rigid("torso", self.meta["torso"]["origin"], Mup))
        for nm in ("arm_l", "arm_r"):
            sh = np.array(L["sh_" + nm[-1]]); a = pose[nm]
            Ma = self.compose(Mup, self.affine(a["rot"], sh, sh + np.array([0.0, a.get("dy", 0.0)])))
            layers.append(self._warp_rigid(nm, self.meta[nm]["origin"], Ma))
        Mh = self.compose(Mup, self.affine(pose.get("hair_rot", 0.0), self.NAPE, self.NAPE))
        hair = self._warp_rigid("hair", self.meta["hair"]["origin"], Mh)
        if pose.get("hair_wave", 0): hair = self._wave(hair, Mup[:, :2] @ self.NAPE + Mup[:, 2], pose["hair_wave"], pose.get("hair_phase", 0.0), Mup)
        layers.append(hair)
        legs = [self._leg(pose[k]["hip"], pose[k]["ankle"], pose[k]["boot"], pose[k].get("rot", 0.0), pose[k].get("scale", 1.0), pose[k].get("tint", 1.0)) for k in ("leg_l", "leg_r")]
        out = np.zeros((H, W, 4), np.float32)
        order = sorted(range(2), key=lambda i: pose[("leg_l", "leg_r")[i]]["ankle"][1])   # nearer (lower) drawn last
        for i in order: out = self._over(out, legs[i])
        for l in layers: out = self._over(out, l)
        return self._finish(out)
