#!/usr/bin/env python3
"""ART-08 cut-out rig renderer (profile, right-facing). Parts come from profile_parts.py.
Everything is deterministic numpy/cv2. Rendering is done at SS x supersampling and area-averaged down."""
import json, os, math
import numpy as np, cv2
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
PARTS = os.path.join(ROOT, "source_art/art08/profile")
CELL = (480, 724)
PIVOT = (240, 600)
SS = 3

def _load(name):
    return np.array(Image.open(os.path.join(PARTS, name + ".png")).convert("RGBA"))

class Rig:
    def __init__(self):
        self.meta = json.load(open(os.path.join(PARTS, "parts.json")))
        self.img = {k: _load(k) for k in ("hair", "torso", "head", "ribbon", "leg_tube", "boot", "fist", "arm_tube")}
        lm = self.meta["landmarks"]
        self.HIP = np.array(lm["hip"]); self.SHOULDER = np.array(lm["shoulder"]); self.NAPE = np.array(lm["nape"])
        self.KNOT = np.array(lm["knot"])
        lt = self.meta["leg_tube"]; self.leg_len = lt["length"]
        at = self.meta["arm_tube"]; self.arm_len = at["length"]

    # ---------------------------------------------------------------- low level
    @staticmethod
    def _premult(a):
        f = a.astype(np.float32); f[..., :3] *= f[..., 3:4] / 255.0; return f

    def _warp_rigid(self, name, origin, M_donor_to_cell):
        """M: 2x3 affine mapping donor px -> cell px (1x). Returns premultiplied float canvas (SS grid)."""
        img = self._premult(self.img[name])
        ox, oy = origin
        # part-local -> donor: + origin ; donor -> cell M ; cell -> SS grid *SS
        L = np.array([[1, 0, ox], [0, 1, oy], [0, 0, 1]], np.float64)
        M3 = np.vstack([M_donor_to_cell, [0, 0, 1]])
        S = np.diag([SS, SS, 1.0])
        T = (S @ M3 @ L)[:2]
        # pixel-centre correction: part px centre at +0.5
        return cv2.warpAffine(img, T, (CELL[0] * SS, CELL[1] * SS), flags=cv2.INTER_LINEAR,
                              borderMode=cv2.BORDER_CONSTANT, borderValue=0)

    @staticmethod
    def affine(angle_deg, pivot_src, pivot_dst, scale=1.0):
        a = math.radians(angle_deg); c, s = math.cos(a) * scale, math.sin(a) * scale
        R = np.array([[c, -s], [s, c]])
        t = np.array(pivot_dst) - R @ np.array(pivot_src)
        return np.hstack([R, t[:, None]])

    @staticmethod
    def compose(M2, M1):
        """apply M1 first then M2"""
        A = np.vstack([M2, [0, 0, 1]]) @ np.vstack([M1, [0, 0, 1]]); return A[:2]

    @staticmethod
    def _smooth_path(pts, rest_len, e=14.0, n=7):
        """round every interior vertex with a quadratic arc of 'e' px each side; returns dense path."""
        P = [np.array(p, float) for p in pts]
        out = [P[0]]
        for i in range(1, len(P) - 1):
            a, b, c = P[i - 1], P[i], P[i + 1]
            ea = min(e, np.linalg.norm(b - a) * 0.45); ec = min(e, np.linalg.norm(c - b) * 0.45)
            p0 = b - (b - a) / np.linalg.norm(b - a) * ea
            p2 = b + (c - b) / np.linalg.norm(c - b) * ec
            for k in range(n + 1):
                t = k / n
                out.append((1 - t) ** 2 * p0 + 2 * (1 - t) * t * b + t * t * p2)
        out.append(P[-1])
        return out

    def _tube(self, name, pts, u0, half, e=14.0, rest=None):
        """Draw strip `name` bent along polyline pts (cell px, 1x). u runs along the smoothed path and is
        rescaled so the path length equals the rest length (no stretch). Returns premultiplied SS canvas."""
        strip = self._premult(self.img[name])
        if rest is None: rest = float(np.linalg.norm(np.array(pts[1]) - np.array(pts[0])) + np.linalg.norm(np.array(pts[2]) - np.array(pts[1])))
        path = self._smooth_path(pts, rest, e)
        W, H = CELL[0] * SS, CELL[1] * SS
        allp = np.array(path)
        pad = half + 3
        x0 = max(int((allp[:, 0].min() - pad) * SS), 0); x1 = min(int((allp[:, 0].max() + pad) * SS) + 1, W)
        y0 = max(int((allp[:, 1].min() - pad) * SS), 0); y1 = min(int((allp[:, 1].max() + pad) * SS) + 1, H)
        out = np.zeros((H, W, 4), np.float32)
        if x1 <= x0 or y1 <= y0: return out
        ys, xs = np.mgrid[y0:y1, x0:x1]
        px = ((xs + 0.5) / SS).astype(np.float32); py = ((ys + 0.5) / SS).astype(np.float32)
        best_d = np.full(px.shape, 1e9, np.float32); best_u = np.zeros(px.shape, np.float32); best_v = np.zeros(px.shape, np.float32)
        cum = 0.0; nseg = len(path) - 1
        lens = [float(np.linalg.norm(path[i + 1] - path[i])) for i in range(nseg)]
        total = sum(lens); k = rest / total
        for i in range(nseg):
            a, b = path[i], path[i + 1]; L = lens[i]
            if L < 1e-6: continue
            dirv = (b - a) / L
            t = (px - a[0]) * dirv[0] + (py - a[1]) * dirv[1]
            lo = u0 / k if i == 0 else 0.0
            tcc = np.clip(t, lo, L)
            cx = a[0] + tcc * dirv[0]; cy = a[1] + tcc * dirv[1]
            d = np.hypot(px - cx, py - cy)
            if i == 0: d = np.where(t < lo, 1e9, d)
            if i == nseg - 1: d = np.where(t > L, 1e9, d)
            v = (px - cx) * (-dirv[1]) + (py - cy) * dirv[0]
            sel = d < best_d
            best_d = np.where(sel, d, best_d); best_u = np.where(sel, (cum + tcc) * k, best_u); best_v = np.where(sel, v, best_v)
            cum += L
        mx = (best_v + half).astype(np.float32)
        my = (best_u - u0).astype(np.float32)
        sub = cv2.remap(strip, mx, my, cv2.INTER_LINEAR, borderMode=cv2.BORDER_CONSTANT, borderValue=0)
        sub *= (best_d <= half)[..., None]
        out[y0:y1, x0:x1] = sub
        return out

    @staticmethod
    def _over(dst, src):
        a = src[..., 3:4] / 255.0
        return src + dst * (1 - a)

    # ---------------------------------------------------------------- IK
    @staticmethod
    def ik(hip, target, L1, L2, forward=1.0):
        hip = np.array(hip, float); target = np.array(target, float)
        v = target - hip; d = np.linalg.norm(v)
        dmax = (L1 + L2) * 0.999; dmin = abs(L1 - L2) + 1e-3
        dd = min(max(d, dmin), dmax)
        u = v / (d if d > 1e-6 else 1)
        target = hip + u * dd
        a = (L1 * L1 - L2 * L2 + dd * dd) / (2 * dd)
        h = math.sqrt(max(L1 * L1 - a * a, 0))
        perp = np.array([-u[1], u[0]])
        # choose side so that the knee lies forward (+x) of the hip-ankle line
        knee = hip + u * a + perp * h
        knee2 = hip + u * a - perp * h
        knee = knee if (knee[0] * forward) >= (knee2[0] * forward) else knee2
        # when the leg is nearly horizontal prefer the knee that is up (smaller y)
        if abs(u[0]) > 0.9:
            knee = knee if knee[1] <= knee2[1] else knee2
        return knee, target

    # ---------------------------------------------------------------- render a pose
    def render(self, pose, supersample_out=False):
        W, H = CELL[0] * SS, CELL[1] * SS
        canvas = np.zeros((H, W, 4), np.float32)
        # upper-body transform: donor -> cell
        lean = pose.get("lean", 0.0)
        pel = np.array(pose["pelvis"], float)
        Mup = self.affine(lean, self.HIP, pel)
        def up(p): return Mup[:, :2] @ np.array(p, float) + Mup[:, 2]
        layers = []
        # --- hair stream (swing about nape)
        hair_rot = pose.get("hair_rot", 0.0)
        Mh = self.compose(Mup, self.affine(hair_rot, self.NAPE, self.NAPE))
        hair = self._warp_rigid("hair", self.meta["hair"]["origin"], Mh)
        if pose.get("hair_wave", 0.0):
            hair = self._wave(hair, up(self.NAPE), pose["hair_wave"], pose.get("hair_phase", 0.0), Mup)
        layers.append(hair)
        # --- far arm (behind torso)
        layers.append(self._arm(pose["far_arm"], up(self.SHOULDER) + np.array(pose.get("far_shoulder_off", (4, 2))), tint=0.80))
        # --- legs
        layers.append(self._leg(pose["far_leg"], pel, tint=0.84))
        layers.append(self._leg(pose["near_leg"], pel + np.array([0.0, 0.0]), tint=1.0))
        # --- torso
        layers.append(self._warp_rigid("torso", self.meta["torso"]["origin"], Mup))
        # --- near arm
        layers.append(self._arm(pose["near_arm"], up(self.SHOULDER), tint=1.0))
        # --- head: pivot at neck
        Mhd = self.compose(Mup, self.affine(pose.get("head_rot", 0.0), (200, 350), (200, 350)))
        layers.append(self._warp_rigid("head", self.meta["head"]["origin"], Mhd))
        # --- ribbon
        rr = pose.get("ribbon_rot", 0.0)
        Mr = self.compose(Mhd, self.affine(rr, self.KNOT, self.KNOT))
        rib = self._warp_rigid("ribbon", self.meta["ribbon"]["origin"], Mr)
        if pose.get("ribbon_wave", 0.0):
            rib = self._wave(rib, self.compose(Mhd, np.array([[1, 0, 0], [0, 1, 0]], float))[:, :2] @ self.KNOT + Mhd[:, 2],
                             pose["ribbon_wave"], pose.get("ribbon_phase", 0.0), Mup)
        layers.append(rib)
        out = np.zeros_like(canvas)
        for L in layers: out = self._over(out, L)
        return self._finish(out)

    def _wave(self, layer, root, amp, phase, Mup):
        """vertical sine displacement growing with distance behind the root (secondary motion)"""
        H, W = layer.shape[:2]
        ys, xs = np.mgrid[0:H, 0:W].astype(np.float32)
        dist = np.clip((root[0] * SS - xs) / SS, 0, 200)     # behind root (to the left)
        dy = amp * np.sin(phase - dist * 0.045) * (dist / 100.0) ** 1.4 * SS
        return cv2.remap(layer, xs, ys - dy.astype(np.float32), cv2.INTER_LINEAR, borderMode=cv2.BORDER_CONSTANT, borderValue=0)

    def _leg(self, leg, hip, tint):
        L1 = L2 = self.leg_len / 2
        knee, ank = self.ik(hip, leg["ankle"], L1, L2)
        pts = [hip, knee, ank]
        u0 = self.meta["leg_tube"]["u0"]; half = self.meta["leg_tube"]["half"]
        tube = self._tube("leg_tube", pts, u0, half)
        if tint != 1.0: tube[..., :3] *= tint
        # boot rigid at ankle
        bm = self.meta["boot"]
        M = self.affine(-leg.get("foot", 0.0), bm["ankle"], ank)
        # boot donor coords are crop-local; origin shifts to donor space is handled as origin=(0,0) in local coordinates
        boot = self._warp_rigid_local("boot", M)
        if tint != 1.0: boot[..., :3] *= tint
        return self._over(tube, boot)

    def _warp_rigid_local(self, name, M_local_to_cell):
        img = self._premult(self.img[name])
        M3 = np.vstack([M_local_to_cell, [0, 0, 1]]); S = np.diag([SS, SS, 1.0])
        return cv2.warpAffine(img, (S @ M3)[:2], (CELL[0] * SS, CELL[1] * SS), flags=cv2.INTER_LINEAR,
                              borderMode=cv2.BORDER_CONSTANT, borderValue=0)

    def _arm(self, arm, shoulder, tint):
        l = self.arm_len / 2
        a1 = math.radians(arm["upper"]); a2 = math.radians(arm["fore"])
        S = np.array(shoulder, float)
        E = S + l * np.array([math.cos(a1), math.sin(a1)])
        Wr = E + l * np.array([math.cos(a2), math.sin(a2)])
        u0 = self.meta["arm_tube"]["u0"]; half = self.meta["arm_tube"]["half"]
        tube = self._tube("arm_tube", [S - 0.0, E, Wr], u0, half)
        # fist at the wrist, rotated with the forearm (donor fist points +x)
        fm = self.meta["fist"]
        M = self.affine(arm["fore"] + arm.get("curl", 0.0), (3.0, 12.0), Wr + 1.0 * np.array([math.cos(a2), math.sin(a2)]))
        fist = self._warp_rigid_local("fist", M)
        out = self._over(tube, fist)
        if tint != 1.0: out[..., :3] *= tint
        return out

    def _finish(self, premult):
        a = premult[..., 3:4]
        rgb = np.where(a > 0.5, premult[..., :3] / np.maximum(a / 255.0, 1e-6), 0)
        full = np.concatenate([rgb, a], -1).clip(0, 255).astype(np.uint8)
        # area downsample in premultiplied space
        pm = premult.copy()
        small = cv2.resize(pm, CELL, interpolation=cv2.INTER_AREA)
        a2 = small[..., 3:4]
        rgb2 = np.where(a2 > 1.0, small[..., :3] / np.maximum(a2 / 255.0, 1e-6), 0)
        out = np.concatenate([rgb2, a2], -1).clip(0, 255).astype(np.uint8)
        out[out[..., 3] < 20] = 0
        out[..., :3][out[..., 3] == 0] = 0
        return out

def save(img, path, bg=None):
    im = Image.fromarray(img)
    if bg:
        b = Image.new("RGBA", im.size, bg); b.alpha_composite(im); im = b.convert("RGB")
    im.save(path)


def render_only(R, pose, which):
    """debug: render only one boot ('near' or 'far') so the contact point can be measured from pixels."""
    L = 131.0 / 2
    leg = pose[which + "_leg"]
    knee, ank = R.ik(pose["pelvis"], leg["ankle"], L, L)
    bm = R.meta["boot"]
    M = R.affine(-leg.get("foot", 0.0), bm["ankle"], ank)
    boot = R._warp_rigid_local("boot", M)
    return R._finish(boot)
