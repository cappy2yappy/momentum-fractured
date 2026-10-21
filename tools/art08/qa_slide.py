#!/usr/bin/env python3
"""ART-08 descent QA: foot slide measured from rendered boot pixels.
For every stance foot, the flat-foot samples (0.16 <= u <= 0.52 of its stance) must sit at one world x. World x = cell x + root x, where
root = pelvis x (the cell pivot). Reports the max-min spread per foot (px, source px, multiply by 0.303125 for world px).
v1 = original descent (stair_up donor, STAIR_DOWN), v2 = revised descent. Also reports pelvis vertical travel per frame."""
import json, os, sys
import numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import rig, gait, clips_profile as C, clips_build as B

def run(label, plan, R, times, extra_fn=None):
    per = {}; ys = []
    for t in times:
        root = np.array([plan.pelvis_x(t), plan.ground_y(t)])
        pose = gait.pose_from(plan, t, root)
        if extra_fn: pose = extra_fn(pose, t)
        legs = plan.legs_at(t)
        for side in ("near", "far"):
            ank, f, state = legs[side]
            if state != "stance": continue
            j = [jj for jj in plan.X if (jj % 2 == 0) == (side == "near") and 0 <= t - jj <= 1.0][-1]
            u = t - j
            if not (0.16 <= u <= 0.52): continue
            m = rig.render_only(R, pose, side)[..., 3] > 128
            yy, xx = np.nonzero(m); sel = yy >= yy.max() - 1
            wx = xx[sel].mean() + 0.5 - 240 + root[0]; wy = yy.max() + 1 - 600 + root[1]
            per.setdefault(j, []).append((round(float(wx), 2), round(float(wy), 2)))
    spread = {j: dict(n=len(v), x_spread=round(max(a for a, b in v) - min(a for a, b in v), 2), y_spread=round(max(b for a, b in v) - min(b for a, b in v), 2)) for j, v in per.items() if len(v) > 1}
    return dict(label=label, flat_feet=spread, max_x_spread_px=max([s["x_spread"] for s in spread.values()] or [0]))

if __name__ == "__main__":
    out = {}
    ts = [0.25 + 0.0625 * k for k in range(0, 60)]       # 4x denser than the clips, so the flat window is sampled
    v1 = C.stair_plan(-1, **B.STAIR_DOWN); out["v1_descent"] = run("v1 (stair_up donor)", v1, rig.Rig(), ts)
    v2 = C.stair_plan(-1, **B.DOWN_GEOM, **B.STAIR_DOWN2); out["v2_descent"] = run("v2 (stair_down donor)", v2, B.get_rig("down"), ts, B.swing_fn)
    json.dump(out, open(os.path.join(rig.ROOT, "docs/art/art08/qa/descent_foot_slide.json"), "w"), indent=1)
    print(json.dumps({k: v["max_x_spread_px"] for k, v in out.items()}))
