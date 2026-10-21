#!/usr/bin/env python3
"""ART-08: build profile clips (stairs, settle, flat walk) from the rig. Writes strips + a per-clip report json."""
import json, os, sys, math, hashlib
import numpy as np
from PIL import Image
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import rig, gait
import clips_profile as C

ROOT = rig.ROOT
OUT = os.path.join(ROOT, "assets/art08")
WORK = os.path.join(ROOT, "source_art/art08/frames")

STAIR_UP = dict(h_mid=158, h_ex=128, clearance=30, lean=-4, arm_amp=34)
STAIR_DOWN = dict(h_mid=162, h_ex=140, clearance=22, lean=-14, arm_amp=22)       # v1 descent (stair_up donor, forward-hunched): kept for the before/after comparison only
# v2 descent: upright upper body from the approved stair_down_key (down_rig.DownRig), toe-first landings, natural stride
STAIR_DOWN2 = dict(h_mid=168, h_ex=152, clearance=14, lean=-5.0, lean_bob=1.0, arm_amp=0, heel_deg=-10)
DOWN_GEOM = dict(pitch=100.0, rise=30.0, first=95.0, floor=95.0, after=95.0)
WALK = dict(h_mid=168, h_ex=150, clearance=13, lean=-12, arm_amp=22, lean_bob=0.8)

_RIGS = {}
def get_rig(kind="up"):
    if kind not in _RIGS:
        if kind == "down":
            import down_rig; _RIGS[kind] = down_rig.DownRig()
        else: _RIGS[kind] = rig.Rig()
    return _RIGS[kind]

def sample(plan, times, extra_fn=None, kind="up"):
    R = get_rig(kind)
    frames, poses, roots = [], [], []
    for t in times:
        root = np.array([plan.pelvis_x(t), plan.ground_y(t)])
        pose = gait.pose_from(plan, t, root)
        if extra_fn: pose = extra_fn(pose, t)
        frames.append(R.render(pose)); poses.append(pose); roots.append(root)
    return frames, poses, roots

def root_motion(plan, times, dt):
    nxt = [t + dt for t in times]
    return [[float(plan.pelvis_x(b) - plan.pelvis_x(a)), float(plan.ground_y(b) - plan.ground_y(a))] for a, b in zip(times, nxt)]

CLIPS = {}
def settle_fn(pose, t):
    s = min(max((t - 4.25) / 0.75, 0.0), 1.0); e = gait.sm(s)
    for arm in ("near_arm", "far_arm"):
        a = pose[arm]
        up = a["upper"] + (98.0 - a["upper"]) * e; fo = a["fore"] + ((98.0 - 16.0) - a["fore"]) * e
        pose[arm] = dict(upper=up, fore=fo, curl=0.0)
    pose["lean"] = pose["lean"] + (-13.0 - pose["lean"]) * e
    pose["hair_wave"] = 7.0 * (1 - 0.6 * e)
    return pose

ARM_SWING = 16.0   # forearm rotation about the elbow, degrees (negative = forward)
def swing_fn(pose, t):
    s = -math.cos(math.pi * t)      # +1 at odd t (far foot lands), -1 at even t
    pose["fore_front"] = -ARM_SWING * s
    pose["fore_back"] = ARM_SWING * s
    return pose

def settle_fn_down(pose, t):
    s = min(max((t - 4.25) / 0.75, 0.0), 1.0); e = gait.sm(s)
    pose["lean"] = pose["lean"] * (1 - e)
    pose["hair_wave"] = 7.0 * (1 - 0.6 * e)
    pose = swing_fn(pose, t)
    k = 1 - e; pose["fore_front"] *= k; pose["fore_back"] *= k      # arms come to rest with the settle
    return pose

def build_all():
    out = {}
    up = C.stair_plan(+1, **STAIR_UP); dn = C.stair_plan(-1, **DOWN_GEOM, **STAIR_DOWN2)
    for kind in ("enter", "loop", "exit"):
        ts = C.clip_times(kind)
        out[f"stair_ascend_{kind}"] = dict(plan=up, times=ts)
        out[f"stair_descend_{kind}"] = dict(plan=dn, times=ts, rig="down")
    # arrival settle: continuation of the ascent after the exit clip (foot 4 = first top-level foot, held planted)
    st = C.stair_plan(+1, hold=(4,), flat_land=(5,), h_fn=lambda t, h: h + (166 - h) * gait.sm((t - 4.25) / 0.75), **STAIR_UP)
    st.X[5] = st.X[4] + 62.0; st.Y[5] = st.Y[4]
    out["stair_arrive_idle_settle"] = dict(plan=st, times=[4.25 + 0.75 * (1 - (1 - k / 3.0) ** 2) for k in range(4)], settle=True)
    # descent arrival settle (new clip, direction specific): foot 4 = first bottom-level foot held planted, foot 5 closes in
    sd = C.stair_plan(-1, hold=(4,), flat_land=(5,), h_fn=lambda t, h: h + (170 - h) * gait.sm((t - 4.25) / 0.75), **DOWN_GEOM, **STAIR_DOWN2)
    sd.X[5] = sd.X[4] + 52.0; sd.Y[5] = sd.Y[4]
    out["stair_descend_arrive_settle"] = dict(plan=sd, times=[4.25 + 0.75 * (1 - (1 - k / 3.0) ** 2) for k in range(4)], settle=True, rig="down", settle_kind="down")
    wk = C.flat_walk_plan(100.0, **WALK)
    out["walk_loop"] = dict(plan=wk, times=[2.0 + 0.25 * k for k in range(8)])
    return out

def save_strip(frames, path):
    W = rig.CELL[0]; H = rig.CELL[1]
    strip = np.zeros((H, W * len(frames), 4), np.uint8)
    for i, f in enumerate(frames): strip[:, i * W:(i + 1) * W] = f
    strip[strip[..., 3] == 0] = 0
    Image.fromarray(strip).save(path, optimize=True)

if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True); os.makedirs(WORK, exist_ok=True)
    only = sys.argv[1:]
    for name, spec in build_all().items():
        if only and name not in only: continue
        fn = (settle_fn_down if spec.get("settle_kind") == "down" else settle_fn) if spec.get("settle") else (swing_fn if spec.get("rig") == "down" else None)
        frames, poses, roots = sample(spec["plan"], spec["times"], fn, spec.get("rig", "up"))
        rm = root_motion(spec["plan"], spec["times"], 0.25) if not spec.get("settle") else [[float(spec["plan"].pelvis_x(b) - spec["plan"].pelvis_x(a)), float(spec["plan"].ground_y(b) - spec["plan"].ground_y(a))] for a, b in zip(spec["times"], spec["times"][1:] + [spec["times"][-1]])]
        save_strip(frames, os.path.join(WORK, f"{name}_strip.png"))
        json.dump(dict(times=spec["times"], root_motion=rm,
                       poses=[{k: (v.tolist() if isinstance(v, np.ndarray) else ({kk: (vv.tolist() if isinstance(vv, np.ndarray) else vv) for kk, vv in v.items()} if isinstance(v, dict) else v)) for k, v in p.items()} for p in poses]),
                  open(os.path.join(WORK, f"{name}.json"), "w"))
        print(name, len(frames))
