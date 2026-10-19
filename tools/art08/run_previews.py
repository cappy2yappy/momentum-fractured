#!/usr/bin/env python3
import json, os, sys
import numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import rig, previews, stairdraw, clips_build as B
ROOT = rig.ROOT
man = json.load(open(os.path.join(ROOT, "assets/art08/MANIFEST.json")))
specs = B.build_all()
src_of = {"door_approach_walk": "walk_loop", "door_walk_out": "walk_loop"}
only = sys.argv[1:]
for c in man["clips"]:
    if c["status"] == "unfinished": continue
    if only and c["name"] not in only: continue
    key = src_of.get(c["name"], c["name"])
    bg = None
    if key in specs:
        sp = specs[key]
        def bg(i, sp=sp):
            t = sp["times"][i]; root = np.array([sp["plan"].pelvis_x(t), sp["plan"].ground_y(t)])
            return stairdraw.draw_background(sp["plan"], root)
    previews.make(c, bg)
    print("preview", c["name"])
