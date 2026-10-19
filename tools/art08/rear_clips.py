#!/usr/bin/env python3
"""ART-08 rear gait: door_cross (walk away, step over the sill)."""
import json, os, sys, math
import numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import rear_rig, rig, gait
SX = 80
def sm(x): return gait.sm(x)

def foot_state(phi):
    """phi in [0,1): stance [0,.5) front->back, swing [.5,1) back->front. returns (z in [-1,1], swing s or None, stance u)"""
    if phi < 0.5:
        u = phi / 0.5; return 1 - 2 * u, None, u
    s = (phi - 0.5) / 0.5
    return -1 + 2 * sm(s), s, None

def pose_at(k, N=8, lift=(12, 12), pelvis_rise=0.0):
    phi = k / N
    zl, sl, ul = foot_state(phi % 1.0); zr, sr, ur = foot_state((phi + 0.5) % 1.0)
    R = 100.0 + 4.0  # hip->ankle at rest in cell px
    kz = 0.45; HALF = 24.0
    hipy = 448.0 - 2.5 * math.cos(4 * math.pi * phi) - pelvis_rise
    sway = -3.0 * math.cos(2 * math.pi * phi)
    cx = 161 + SX + sway
    def foot(z, s, u, hipx, lft, side):
        dy = -z * HALF * kz
        l = lft * math.sin(math.pi * s) if s is not None else 0.0
        late_stance = (u is not None and u > 0.62)
        swing_early = (s is not None and s < 0.7)
        base = 30.0 if late_stance else (30.0 * (1 - sm((s - 0.4) / 0.3)) if s is not None else 0.0)
        ank = (hipx + (3 if side == "r" else -3), hipy + R + 10 + dy - l - base)
        boot = "boot_lift" if (late_stance or swing_early) else "boot_flat"
        # donor flat boot is a right foot, lift boot is a left foot
        flip = (boot == "boot_flat" and side == "l") or (boot == "boot_lift" and side == "r")
        rot = (-14 * math.sin(math.pi * s)) if s is not None else 0.0
        return dict(hip=(hipx, hipy), ankle=ank, boot=boot, boot_rot=rot, flip=flip, tint=1.0 if side == "l" else 0.95)
    hip_l = (141 + SX + sway, hipy); hip_r = (177 + SX + sway, hipy)
    ll = foot(zl, sl, ul, 141 + SX + sway, lift[0], "l"); lr = foot(zr, sr, ur, 177 + SX + sway, lift[1], "r")
    ang = 7.0 * math.cos(2 * math.pi * phi)
    P = dict(pelvis=(cx, hipy), tilt=1.3 * math.sin(2 * math.pi * phi), leg_l=ll, leg_r=lr,
             arm_l=dict(rot=ang, dy=-3 * math.cos(2 * math.pi * phi)), arm_r=dict(rot=-ang, dy=3 * math.cos(2 * math.pi * phi)),
             hair_rot=-2.0 * math.sin(2 * math.pi * phi + 0.8), hair_wave=4.0, hair_phase=2 * math.pi * phi)
    return P

def build_cross():
    R = rear_rig.RearRig(); frames, poses = [], []
    for k in range(8):
        # step over the sill: bigger lift for the foot that swings in frames 4..7 (leg_l swings phi .5-1), plus a small rise
        big = 26.0 if k in (5, 6) else 12.0
        P = pose_at(k, 8, lift=(big, 12.0), pelvis_rise=(5.0 if k in (5, 6) else 0.0))
        frames.append(R.render(P)); poses.append(P)
    return frames, poses

if __name__ == "__main__":
    import preview_util
    fr, po = build_cross()
    preview_util.sheet(fr, "/tmp/claude-0/s/cross.png", cols=4, scale=1.0, crop=(70,260,410,640))

def save_cross():
    from clips_build import save_strip
    fr, po = build_cross()
    FR = os.path.join(rig.ROOT, "source_art/art08/frames")
    save_strip(fr, os.path.join(FR, "door_cross_strip.png"))
    ser = lambda v: v.tolist() if isinstance(v, np.ndarray) else (tuple(v) if isinstance(v, tuple) else v)
    json.dump(dict(times=list(range(8)), root_motion=[[0.0, -5.4]] * 8, poses=json.loads(json.dumps(po, default=ser))), open(os.path.join(FR, "door_cross.json"), "w"))
if __name__ == "__main__" and len(sys.argv) > 1: save_cross()
