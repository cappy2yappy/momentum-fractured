import json, os, sys, math
import numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import front_rig, rig, gait
from rear_clips import foot_state
sm = gait.sm
def pose_at(R, phi, dx, dy, lift=20.0, shift=(240 - 131 * 0.832, 0)):
    K = R.meta["scale"]; zl, sl, ul = foot_state(phi % 1.0); zr, sr, ur = foot_state((phi + 0.5) % 1.0)
    # donor hips (scaled) -> cell: x offset so the pelvis centre sits at cell x 240+dx; y: hips at 448 in cell
    hipy = 436 * K; ox = 240 - R.meta["landmarks"]["hip_c"][0]; oy = 448 - hipy
    bob = -2.5 * math.cos(4 * math.pi * phi); sway = 3.0 * math.cos(2 * math.pi * phi)
    base_ank = 540 * K + oy + 0   # ankle row at rest (standing foot)
    def foot(z, s, hx, side):
        d = z * 19.0   # toward camera -> lower
        l = lift * math.sin(math.pi * s) if s is not None else 0.0
        ank = (hx + ox + sway + (-4 if side == "l" else 4), base_ank + d - l + bob * 0.0)
        return dict(hip=(hx + ox + sway, hipy + oy + bob), ankle=ank, boot="boot_a" if side == "l" else "boot_b", rot=(8 * math.sin(math.pi * s) if s is not None else 0.0), scale=1.0 + 0.05 * z)
    lm = R.meta["landmarks"]
    ang = 2.5 * math.cos(2 * math.pi * phi)
    return dict(pelvis=(lm["hip_c"][0] + ox + sway + dx, hipy + oy + bob + dy), tilt=1.2 * math.sin(2 * math.pi * phi),
        leg_l=foot(zl, sl, lm["hip_l"][0], "l"), leg_r=foot(zr, sr, lm["hip_r"][0], "r"),
        arm_l=dict(rot=-ang, dy=-2 * math.cos(2 * math.pi * phi)), arm_r=dict(rot=ang * 0.8, dy=2 * math.cos(2 * math.pi * phi)),
        hair_rot=-2.0 * math.sin(2 * math.pi * phi + 0.8), hair_wave=4.0, hair_phase=2 * math.pi * phi)
if __name__ == "__main__":
    import preview_util
    R = front_rig.FrontRig(); fr = []
    for k in range(6): fr.append(R.render(pose_at(R, k / 8 + 0.0, 0, 0)))
    preview_util.sheet(fr, "/tmp/claude-0/s/emerge.png", cols=3, scale=1.0, crop=(60, 250, 420, 640))

def build_emerge():
    R = front_rig.FrontRig(); fr, po = [], []
    for k in range(6):
        P = pose_at(R, 0.0 + k / 8 + 0.0, 0, 0); fr.append(R.render(P)); po.append(P)
    return fr, po
def save_emerge():
    from clips_build import save_strip
    fr, po = build_emerge(); FR = os.path.join(rig.ROOT, "source_art/art08/frames")
    save_strip(fr, os.path.join(FR, "door_emerge_strip.png"))
    ser = lambda v: v.tolist() if isinstance(v, np.ndarray) else (tuple(v) if isinstance(v, tuple) else v)
    json.dump(dict(times=list(range(6)), root_motion=[[0.0, 9.5]] * 6, poses=json.loads(json.dumps(po, default=ser))), open(os.path.join(FR, "door_emerge.json"), "w"))
if __name__ == "__main__" and len(sys.argv) > 1: save_emerge()
