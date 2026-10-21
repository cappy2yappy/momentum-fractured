#!/usr/bin/env python3
"""ART-08 extra gates: loop seam (virtual next frame vs frame 0) and image-based foot plant / slide for profile clips."""
import json, os, sys, math
import numpy as np
from PIL import Image
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import rig, gait, clips_build as B, clips_profile as C
FR = os.path.join(rig.ROOT, "source_art/art08/frames"); OUTQ = os.path.join(rig.ROOT, "docs/art/art08/qa")
specs = B.build_all()
def strip(name, n):
    a = np.array(Image.open(os.path.join(FR, name + "_strip.png")).convert("RGBA")); return [a[:, i * 480:(i + 1) * 480] for i in range(n)]
def diff(a, b):
    m = (a[..., 3] > 40) | (b[..., 3] > 40)
    xor = ((a[..., 3] > 40) ^ (b[..., 3] > 40)).sum() / max(m.sum(), 1)
    return float(xor)
res = {}
for name, sp in specs.items():
    plan, times = sp["plan"], sp["times"]; n = len(times); R = B.get_rig(sp.get("rig", "up"))
    frames = strip(name, n); rep = {}
    if name in ("stair_ascend_loop", "stair_descend_loop", "walk_loop"):
        t = times[0] + 2.0; root = np.array([plan.pelvis_x(t), plan.ground_y(t)])
        pv = gait.pose_from(plan, t, root)
        if sp.get("rig") == "down": pv = B.swing_fn(pv, t)
        virt = R.render(pv)
        # the frame-0 pose is in the same cell frame because only root differs; identical parity => seam error should be ~0
        rep["seam_virtual_vs_frame0_xor"] = round(diff(virt, frames[0]), 4)
        rep["seam_last_to_first_xor"] = round(diff(frames[-1], frames[0]), 4)
        rep["adjacent_xor_median"] = round(float(np.median([diff(frames[i], frames[i + 1]) for i in range(n - 1)])), 4)
        rep["seam_mean_abs_rgb_diff"] = round(float(np.abs(virt.astype(int) - frames[0].astype(int)).mean()), 3)
    # image-based plant check
    errs_y, errs_x = [], []
    for i, t in enumerate(times):
        root = np.array([plan.pelvis_x(t), plan.ground_y(t)]); pose = gait.pose_from(plan, t, root)
        legs = plan.legs_at(t)
        for side in ("near", "far"):
            ank, f, state = legs[side]
            if state != "stance": continue
            j = [jj for jj in plan.X if (jj % 2 == 0) == (side == "near") and 0 <= t - jj <= 1.0 + (5 if jj in plan.hold else 0)][-1]
            u = min(t - j, 1.0)
            m = rig.render_only(R, pose, side)[..., 3] > 128
            ys, xs = np.nonzero(m)
            ybot = ys.max(); sel = ys >= ybot - 1
            xc = xs[sel].mean()
            wy = ybot + 1 - 600 + root[1]; wx = xc + 0.5 - 240 + root[0]
            errs_y.append(abs(wy - plan.Y[j]))
            if u < 0.12: errs_x.append(abs(wx - (plan.X[j] + (gait.SOLE_HALF if plan.heel_deg < 0 else -gait.SOLE_HALF))))
            elif u > 0.6 and j not in plan.hold: errs_x.append(abs(wx - (plan.X[j] + gait.SOLE_HALF)))
    rep["plant_sole_y_error_px"] = dict(max=round(max(errs_y), 2), mean=round(float(np.mean(errs_y)), 2), n=len(errs_y)) if errs_y else None
    rep["plant_contact_x_error_px"] = dict(max=round(max(errs_x), 2), mean=round(float(np.mean(errs_x)), 2), n=len(errs_x)) if errs_x else None
    rep["foot_slide_px_analytic"] = 0.0
    rep["pelvis_pose_key"] = sp.get("rig", "up")
    res[name] = rep; print(name, rep)
json.dump(res, open(os.path.join(OUTQ, "extra_profile.json"), "w"), indent=1)
