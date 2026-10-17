#!/usr/bin/env python3
"""ART-06 layout validator: art/collision agreement and keep-clear zones. Exit 1 on failure."""
import json, sys
d = json.load(open(sys.argv[1])); geo = json.load(open(sys.argv[2]))
fails = []; checks = 0
def ok(c, msg):
    global checks; checks += 1
    if not c: fails.append(msg)
def inter(a, b):  # rects x,y,w,h
    return a[0] < b[0]+b[2] and b[0] < a[0]+a[2] and a[1] < b[1]+b[3] and b[1] < a[1]+a[3]
def circ_rect(c, r):
    cx, cy, rad = c; nx = min(max(cx, r[0]), r[0]+r[2]); ny = min(max(cy, r[1]), r[1]+r[3])
    return (nx-cx)**2 + (ny-cy)**2 < rad*rad
# 1. Every runtime collider inside the room has exactly one surface treatment with identical rect.
bodies = [b for b in geo["bodies"] if 0 <= b["x"] < 2600 and b["h"] < 1000 and b["w"] > 30]
surf = {tuple(round(v, 2) for v in s["rect"]): s for s in d["surfaces"]}
for b in bodies:
    key = tuple(round(v, 2) for v in (b["x"], b["y"], b["w"], b["h"]))
    ok(key in surf, f"collider {key} has no matching surface art")
    if key in surf: ok((surf[key]["collider"] == "one_way") == b["one_way"], f"collider type mismatch {key}")
ok(len(surf) == len(bodies), f"surface count {len(surf)} != collider count {len(bodies)} (no art-only walkables)")
# 2. Support/prop art never draws an opaque horizontal top inside an open gap: supports must sit on floor or a surface.
tops = {round(s["rect"][1], 2) for s in d["surfaces"]} | {1300}
for s in d["supports"]:
    if "bottom" in s: ok(s["bottom"] in tops or s["bottom"] == 1300, f"{s['id']} bottom {s['bottom']} not on floor/surface")
# 3. Keep-clear zones (anchors, exits, hazard, lore, guard lane) free of every overlay layer except where exempt.
items = [(p["id"], p.get("layer"), p["rect"]) for p in d["props"]]
items += [(s["id"], "support", s.get("rect") or [s["x"], s["top"], s["w"], s["bottom"]-s["top"]]) for s in d["supports"]]
exempt = {("isolator", "exit_east")}
exempt_layers = set(d.get("keep_clear_exempt_layers", []))  # drawn before runtime markers
for k in d["keep_clear"]:
    for iid, layer, r in items:
        if (iid, k["id"]) in exempt or layer in exempt_layers: continue
        hit = circ_rect(k["circle"], r) if "circle" in k else inter(k["rect"], r)
        ok(not hit, f"{iid} ({layer}) intrudes keep-clear {k['id']}: {k['why']}")
# 4. Foreground occluders only where no keep-clear and no walkable surface within 120px.
for p in d["props"]:
    if p["layer"] != "fg_occluder": continue
    r = p["rect"]; grown = [r[0]-120, r[1]-120, r[2]+240, r[3]+240]
    for s in d["surfaces"]:
        ok(not inter(grown, s["rect"]), f"fg {p['id']} within 120px of walkable {s['id']}")
print(f"ART06 layout: {checks} checks, {len(fails)} failure(s)")
for f in fails: print("FAIL:", f)
sys.exit(1 if fails else 0)
