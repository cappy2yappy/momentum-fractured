#!/usr/bin/env python3
"""ART-08: copy generated strips into assets/art08 and write MANIFEST.json (sha256, bytes, root motion, contacts).
Clip registry below is the single source of truth for names / fps / provenance."""
import json, os, sys, hashlib, shutil, math
import numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import rig
ROOT = rig.ROOT
FR = os.path.join(ROOT, "source_art/art08/frames")
ASSETS = os.path.join(ROOT, "assets/art08")
VERSION = "v2"

PROFILE_PROV = "cut-out rig + skeletal pose solve (authored by script from approved ART-04 stair_up_key; limbs re-posed, joints repainted by tube warp)"
REG = [
 # name, source frames name, fps, loop, facing, status, provenance, note
 ("stair_ascend_enter", "stair_ascend_enter", 16, False, "right", "candidate", PROFILE_PROV, "floor foot to first tread; last frame is the heel strike on tread 1"),
 ("stair_ascend_loop", "stair_ascend_loop", 14, True, "right", "candidate", PROFILE_PROV, "one stride pair = 2 treads; plays from the phase right after enter"),
 ("stair_ascend_exit", "stair_ascend_exit", 16, False, "right", "candidate", PROFILE_PROV, "last tread to level floor; last frame is the heel strike on the level top"),
 ("stair_descend_enter", "stair_descend_enter", 16, False, "right", "candidate", PROFILE_PROV, "floor foot to first tread down"),
 ("stair_descend_loop", "stair_descend_loop", 14, True, "right", "candidate", PROFILE_PROV, "heel-first, upright counter-lean"),
 ("stair_descend_exit", "stair_descend_exit", 16, False, "right", "candidate", PROFILE_PROV, "last tread down to level floor"),
 ("stair_arrive_idle_settle", "stair_arrive_idle_settle", 12, False, "right", "candidate", PROFILE_PROV, "short closing step then standing; ends in a standing profile pose"),
 ("door_approach_walk", "walk_loop", 12, True, "right (flip_h for left)", "candidate", PROFILE_PROV, "slow flat walk, 100 px step; drawn facing right, ribbon trails left"),
 ("door_walk_out", "walk_loop", 12, True, "right (flip_h for left)", "candidate", PROFILE_PROV, "alias of door_approach_walk: identical drawn frames, same strip file"),
]
EXTRA = {}   # filled by door builders (rear/front/reuse clips) via extra_registry.json
def sha(p): return hashlib.sha256(open(p, "rb").read()).hexdigest()

def contacts(meta):
    t = meta["times"]; near, far, heel = [], [], []
    for i, (tt, p) in enumerate(zip(t, meta["poses"])):
        if p["near_leg"]["state"] == "stance": near.append(i)
        if p["far_leg"]["state"] == "stance": far.append(i)
        if abs(tt - round(tt)) < 0.01: heel.append(i)
    return near, far, heel

def main():
    man = json.load(open(os.path.join(ASSETS, "MANIFEST.json"))) if os.path.exists(os.path.join(ASSETS, "MANIFEST.json")) else {"clips": []}
    cur = {c["name"]: c for c in man["clips"]}
    out = dict(schema="art08/1", interface_version=VERSION, cell=[480, 724], pivot=[240, 600], engine_scale_world=0.303125,
               source_scale_note="Kaze is about 308 px tall in the 724 px cell (approved ART-04 density); in-world playback scale 0.303125; cinematic playback is an upscale of this density (see INTEGRATION.md)",
               status_legend=dict(candidate="real multi-frame animation, creator visual acceptance pending", stand_in="usable but not final art, see note", unfinished="no frames shipped"),
               clips=[])
    seen = set()
    for name, src, fps, loop, facing, status, prov, note in REG:
        sp = os.path.join(FR, f"{src}_strip.png"); mp = os.path.join(FR, f"{src}.json")
        if not os.path.exists(sp): continue
        meta = json.load(open(mp))
        dst_name = "door_approach_walk" if name == "door_walk_out" else name
        dst = os.path.join(ASSETS, f"kaze_{dst_name}_strip.png")
        shutil.copyfile(sp, dst)
        near, far, heel = contacts(meta)
        out["clips"].append(dict(name=name, strip=f"assets/art08/kaze_{dst_name}_strip.png", hframes=len(meta["times"]), vframes=1,
            cell=[480, 724], pivot=[240, 600], fps=fps, loop=loop, facing=facing,
            root_motion_px_per_frame=[[round(a, 2), round(b, 2)] for a, b in meta["root_motion"]],
            contact_frames=heel, plant_frames=dict(near_foot=near, far_foot=far),
            provenance=prov, status=status, note=note, alias_of=("door_approach_walk" if name == "door_walk_out" else None),
            sha256=sha(dst), bytes=os.path.getsize(dst)))
        seen.add(name)
    # clips from other builders (door rear/front/reuse)
    ex = os.path.join(FR, "extra_registry.json")
    if os.path.exists(ex):
        for c in json.load(open(ex)):
            dst = os.path.join(ROOT, c["strip"])
            c["sha256"] = sha(dst); c["bytes"] = os.path.getsize(dst); out["clips"].append(c); seen.add(c["name"])
    for name, c in cur.items():
        if name not in seen:
            c2 = dict(c); c2["provenance"] = "unfinished"; c2["status"] = "unfinished"; out["clips"].append(c2)
    order = ["stair_ascend_enter","stair_ascend_loop","stair_ascend_exit","stair_descend_enter","stair_descend_loop","stair_descend_exit","stair_arrive_idle_settle","door_approach_walk","door_turn_to_rear","door_cross","door_emerge","door_turn_to_side","door_walk_out"]
    out["clips"].sort(key=lambda c: order.index(c["name"]))
    json.dump(out, open(os.path.join(ASSETS, "MANIFEST.json"), "w"), indent=1)
    print("clips", [(c["name"], c["status"]) for c in out["clips"]])

if __name__ == "__main__":
    main()
