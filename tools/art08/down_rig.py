#!/usr/bin/env python3
"""ART-08 descent rig: upright upper body from the approved stair_down_key (rigid, from down_parts.py) on the
existing foot-planted leg rig (leg tube + boot sprites, same drawing style). Right-facing, cell 480x724, pivot (240,600)."""
import json, os, math
import numpy as np, cv2
from PIL import Image
import rig as R0
from rig import CELL, SS, ROOT

DOWN = os.path.join(ROOT, "source_art/art08/down")

class DownRig(R0.Rig):
    def __init__(self):
        super().__init__()
        self.dm = json.load(open(os.path.join(DOWN, "down.json")))
        for k in ("upper_rest", "hair_tips", "forearm_front", "forearm_back"):
            self.img[k] = np.array(Image.open(os.path.join(DOWN, k + ".png")).convert("RGBA"))
        self.HIP_U = np.array(self.dm["landmarks"]["hip"]); self.NAPE_U = np.array(self.dm["landmarks"]["nape"])

    def _warp_up(self, name, M):
        return self._warp_rigid(name, self.dm[name]["origin"], M)

    def _tips_wave(self, layer, Mup, amp, phase):
        """sine displacement growing with distance behind the tip line (hair and ribbon tails)"""
        H, W = layer.shape[:2]
        ys, xs = np.mgrid[0:H, 0:W].astype(np.float32)
        tipx = (Mup[:, :2] @ np.array([self.dm["tip_x"], 400.0]) + Mup[:, 2])[0]
        dist = np.clip((tipx * SS - xs) / SS, 0, 200)
        dy = amp * np.sin(phase - dist * 0.05) * (dist / 100.0) ** 1.3 * SS
        return cv2.remap(layer, xs, ys - dy.astype(np.float32), cv2.INTER_LINEAR, borderMode=cv2.BORDER_CONSTANT, borderValue=0)

    def render(self, pose, supersample_out=False):
        pel = np.array(pose["pelvis"], float)
        Mup = self.affine(pose.get("lean", 0.0), self.HIP_U, pel)
        layers = []
        tips = self._warp_up("hair_tips", Mup)
        tips = self._tips_wave(tips, Mup, pose.get("hair_wave", 0.0), pose.get("hair_phase", 0.0))
        layers.append(tips)
        layers.append(self._leg(pose["far_leg"], pel, tint=0.84))
        layers.append(self._leg(pose["near_leg"], pel, tint=1.0))
        # forearms rotate about the elbow (donor space), then ride the upper body
        def fore(name, ang):
            e = np.array(self.dm[name]["elbow"])
            Mf = self.compose(Mup, self.affine(ang, e, e))
            return self._warp_up(name, Mf)
        layers.append(fore("forearm_back", pose.get("fore_back", 0.0)))
        layers.append(self._warp_up("upper_rest", Mup))
        layers.append(fore("forearm_front", pose.get("fore_front", 0.0)))
        out = np.zeros_like(layers[0])
        for L in layers: out = self._over(out, L)
        return self._finish(out)
