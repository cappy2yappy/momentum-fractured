#!/usr/bin/env python3
"""ART-08 gait solver: foot-planted stepping on stairs or flat floor -> per-frame rig poses.

World frame: source px, +x right (facing right), +y down. A 'plan' lists foot placements j with sole centre
(X_j, Y_j). Foot j lands (heel first) at t=j, rolls flat then to the toe, leaves at t=j+1 and swings to land at
j+2. Feet alternate near (even j) / far (odd j). The pelvis passes over each foot at t=j+0.5.
Frame k of a clip samples t = t0 + k*dt. Root = pelvis x projected on the ground line (pivot of the cell)."""
import math
import numpy as np

LEG = 131.0              # hip->ankle at full reach (rig.leg_len)
HEEL = np.array([-17.0, 43.0]); TOE = np.array([27.0, 42.0])   # sole contact points relative to the ankle (flat boot)
SOLE_HALF = 22.0
REACH = 0.972

def sm(x): x = min(max(x, 0.0), 1.0); return x * x * (3 - 2 * x)
def lerp(a, b, t): return a + (b - a) * t
def rot(v, deg):
    a = math.radians(deg); c, s = math.cos(a), math.sin(a)
    return np.array([c * v[0] - s * v[1], s * v[0] + c * v[1]])

def ankle_stance(X, Y, u, f_heel=16.0, f_toe=-34.0, u1=0.16, u2=0.52):
    """returns (ankle xy world, foot angle deg toe-up positive) for stance fraction u in [0,1]"""
    GH = np.array([X - SOLE_HALF, Y]); GT = np.array([X + SOLE_HALF, Y])
    if u < u1:
        f = lerp(f_heel, 0.0, sm(u / u1)); beta = -f
        return GH - rot(HEEL, beta), f
    if u < u2:
        return GH - HEEL, 0.0
    f = lerp(0.0, f_toe, sm((u - u2) / (1 - u2))); beta = -f
    return GT - rot(TOE, beta), f

class Plan:
    """foot placements indexed j in [jmin, jmax]; outside the range extrapolate flat using the end steps."""
    def __init__(self, X, Y, h_mid, h_ex, clearance, lean=8.0, arm_amp=34.0, stairs=False, lean_bob=1.5, counter=0.0, hold=(), flat_land=(), h_fn=None):
        self.X = dict(X); self.Y = dict(Y)
        self.hold = set(hold); self.flat_land = set(flat_land); self.h_fn = h_fn
        self.h_mid = h_mid; self.h_ex = h_ex; self.clear = clearance
        self.lean = lean; self.arm_amp = arm_amp; self.lean_bob = lean_bob
    def foot(self, j):
        return self.X[j], self.Y[j]

    def foot_state(self, j, t):
        """ankle world position + foot angle of foot j at time t (stance or swing around its own cycle)"""
        u = t - j
        if j in self.hold and u > 0.0:
            return ankle_stance(self.X[j], self.Y[j], min(u, 0.5), f_heel=0.0 if j in self.flat_land else 16.0) + ("stance",)
        if 0.0 <= u <= 1.0:
            return ankle_stance(self.X[j], self.Y[j], u, f_heel=0.0 if j in self.flat_land else 16.0) + ("stance",)
        # swing before landing: foot j is in the air during t in [j-1, j]; it left from foot j-2
        if -1.0 <= u < 0.0:
            s = (u + 1.0)
            a0, f0 = ankle_stance(self.X[j - 2], self.Y[j - 2], 1.0)
            a1, f1 = ankle_stance(self.X[j], self.Y[j], 0.0, f_heel=0.0 if j in self.flat_land else 16.0)
            ex = s - math.sin(2 * math.pi * s) / (2 * math.pi) * 0.85
            gy = sm(min(1.0, s * 1.5)) if a1[1] < a0[1] else sm(max(0.0, s * 1.5 - 0.5))
            if a1[1] > a0[1]: gy = s ** 1.2 * 0.0 + sm(min(1.0, s * 1.3))
            x = lerp(a0[0], a1[0], ex)
            y = lerp(a0[1], a1[1], gy) - self.clear * math.sin(math.pi * s) ** 1.3
            f = lerp(f0, f1, sm(s) ** 0.8)
            return np.array([x, y]), f, "swing"
        return None

    def pelvis_x(self, t):
        js = sorted(self.X)
        pts = [(j + 0.5, self.X[j] - 5.0) for j in js]
        # extend linearly past the ends using the end step lengths
        t0, x0 = pts[0]; t1, x1 = pts[1]; tn, xn = pts[-1]; tm, xm = pts[-2]
        if t <= t0: return x0 + (t - t0) * (x1 - x0) / (t1 - t0)
        if t >= tn: return xn + (t - tn) * (xn - xm) / (tn - tm)
        for (ta, xa), (tb, xb) in zip(pts, pts[1:]):
            if ta <= t <= tb: return lerp(xa, xb, (t - ta) / (tb - ta))

    def ground_y(self, t):
        js = sorted(self.X)
        pts = [(j + 0.5, self.Y[j]) for j in js]
        if t <= pts[0][0]: return pts[0][1]
        if t >= pts[-1][0]: return pts[-1][1]
        for (ta, ya), (tb, yb) in zip(pts, pts[1:]):
            if ta <= t <= tb: return lerp(ya, yb, sm((t - ta) / (tb - ta)) * 0.35 + (t - ta) / (tb - ta) * 0.65)

    def pelvis_y(self, t):
        ph = (t % 1.0)                     # 0 at exchange, 0.5 at mid stance
        h = lerp(self.h_ex, self.h_mid, math.sin(math.pi * ph) ** 1.2)
        if self.h_fn: h = self.h_fn(t, h)
        return self.ground_y(t) - h

    def legs_at(self, t):
        """dict near/far -> (ankle, foot angle) for the two feet in play (even j near, odd j far)"""
        out = {}
        for j in range(math.floor(t) - 1, math.floor(t) + 3):
            if j not in self.X: continue
            st = self.foot_state(j, t)
            if st is None: continue
            side = "near" if j % 2 == 0 else "far"
            # prefer stance state; a foot only appears once per side at a time
            if side in out and out[side][2] == "stance": continue
            out[side] = st
        return out

    def pose(self, t, hip_off=np.array([0.0, 0.0])):
        px = self.pelvis_x(t); py = self.pelvis_y(t)
        legs = self.legs_at(t)
        # reach: raise-limit the pelvis so every planted foot is reachable
        lim = py
        for side, (ank, f, state) in legs.items():
            if state != "stance": continue
            dx = ank[0] - px; r = LEG * REACH
            if abs(dx) < r:
                ymax = ank[1] - math.sqrt(r * r - dx * dx)   # smallest allowed y (highest pelvis)
                lim = max(lim, ymax)
        return np.array([px, lim]), legs

def pose_from(plan, t, root, pivot=(240.0, 600.0), phase_arm=0.0, extra=None):
    """build the rig pose dict in CELL coordinates for time t, given the root world position."""
    pel, legs = plan.pose(t)
    def cell(p): return np.array([pivot[0] + p[0] - root[0], pivot[1] + p[1] - root[1]])
    P = dict(pelvis=cell(pel))
    for side in ("near", "far"):
        ank, f, state = legs[side]
        P[side + "_leg"] = dict(ankle=cell(ank), foot=f, state=state)
    # arms: opposite to legs. near foot lands forward at t=0 (even) => near arm back at t even.
    w = math.pi * t
    amp = plan.arm_amp
    def arm(ph):
        c = math.cos(w + ph)
        upper = 92.0 + amp * c                 # 126 back .. 58 forward
        flex = 38.0 + 36.0 * (1 - c) / 2       # more bent when forward
        return dict(upper=upper, fore=upper - flex, curl=0.0)
    P["near_arm"] = arm(0.0); P["far_arm"] = arm(math.pi)
    P["lean"] = plan.lean + plan.lean_bob * math.sin(2 * math.pi * t * 2 + 0.6)
    P["hair_rot"] = -4.0 * math.sin(math.pi * t * 2 + 1.0) + 1.5 * math.sin(math.pi * t + 0.4)
    P["hair_wave"] = 7.0; P["hair_phase"] = math.pi * t * 1.0
    P["ribbon_rot"] = 5.0 * math.sin(math.pi * t * 2 + 0.3) + 2.0 * math.sin(math.pi * t + 1.1)
    P["ribbon_wave"] = 5.0; P["ribbon_phase"] = math.pi * t * 1.0 + 1.0
    P["head_rot"] = -1.5 * math.sin(2 * math.pi * t * 2 + 0.2)
    if extra: P.update(extra)
    return P
