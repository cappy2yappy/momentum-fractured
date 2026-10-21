#!/usr/bin/env python3
"""LD-05 ground-level audit: turns tools/ld05/ground_probe.gd JSON into graph findings.
usage: ground_audit.py ground_a.json [ground_b.json ...] --out docs/ld05/raw/ground_findings.json
Findings (all coordinates are room pixels, y down):
  unreachable : a standing surface no probe from any door/recovery surface reached
  trapped     : reachable surface with no probed path to any door surface
  pit         : floor gaps and what a miss costs (fall edges)
  recovery    : where the fall recovery places Kaze and whether that spot is solid/supported
  pocket      : static under-ledge and narrow-channel pockets
"""
import json, sys, collections

CAPSULE_W, CAPSULE_H = 28.0, 60.0


def load(paths):
    rooms = {}
    for p in paths:
        for r in json.load(open(p))["rooms"]:
            rooms[r["index"]] = r
    return rooms


def door_nodes(room):
    out = {}
    surf = room["surfaces"]
    for ep in room["endpoints"]:
        ax, ay = ep["at"]
        for s in surf:
            x, y, w, h = s["rect"]
            if abs(y - ay) <= 20 and x - 1 <= ax <= x + w + 1:
                out.setdefault(s["i"], []).append(ep["target"])
                break
    return out


def graph(room):
    edges = collections.defaultdict(lambda: collections.Counter())
    falls = collections.defaultdict(list)
    rec = room["recovery"]["support"]
    for e in room["edges"]:
        f = e["from"]
        if e["fell"]:
            falls[f].append(e)
            if rec is not None and rec >= 0:
                edges[f][("fall", rec)] += 1
        elif e["landed"] >= 0 and e["landed"] != f:
            edges[f][("move", e["landed"])] += 1
    return edges, falls


def reach(edges, seeds, with_falls):
    seen = set(seeds)
    stack = list(seeds)
    while stack:
        n = stack.pop()
        for (kind, m) in edges.get(n, {}):
            if kind == "fall" and not with_falls:
                continue
            if m not in seen:
                seen.add(m)
                stack.append(m)
    return seen


def pits(room):
    size = room["size"]
    floors = sorted([s["rect"] for s in room["surfaces"] if s["rect"][1] >= size[1] - 160 and s["rect"][3] >= 100], key=lambda r: r[0])
    gaps = []
    x = 0.0
    for r in floors:
        if r[0] > x + 1:
            gaps.append([x, r[0]])
        x = max(x, r[0] + r[2])
    if x < size[0] - 1:
        gaps.append([x, size[0]])
    return gaps


def analyse(room):
    idx = room["index"]
    size = room["size"]
    surf = {s["i"]: s["rect"] for s in room["surfaces"]}
    doors = door_nodes(room)
    edges, falls = graph(room)
    rec = room["recovery"]["support"]
    seeds = set(doors) | ({rec} if rec is not None and rec >= 0 else set())
    reached = reach(edges, seeds, True)
    out = {"room": idx, "name": room["name"], "size": size, "doors": {str(k): v for k, v in doors.items()}, "findings": []}
    # unreachable (never landed on by any probe that started at a door/recovery surface chain)
    def twin(i, r):
        # a collider that duplicates the standing top of a reached one (same y, overlapping x) is the same surface to Kaze
        for j, q in surf.items():
            if j in reached and j != i and abs(q[1] - r[1]) < 1 and q[0] < r[0] + r[2] and r[0] < q[0] + q[2]:
                return True
        return False
    for i, r in surf.items():
        if i not in reached and r[1] > 8 and not twin(i, r):
            out["findings"].append({"kind": "unreachable", "surface": r, "note": "no probe chain from a door or the recovery pose lands here"})
    # trapped: reachable but cannot reach any door node (moves only)
    rev = collections.defaultdict(set)
    for n, es in edges.items():
        for (kind, m) in es:
            rev[m].add(n)
    can_exit = set(doors)
    stack = list(doors)
    while stack:
        n = stack.pop()
        for p in rev.get(n, ()):
            if p not in can_exit:
                can_exit.add(p)
                stack.append(p)
    for i in reached:
        if i not in can_exit:
            out["findings"].append({"kind": "trapped", "surface": surf[i], "note": "reachable, but no probed move chain leads to any door surface"})
    # pits
    gaps = pits(room)
    for g in gaps:
        miss = [e for es in falls.values() for e in es if g[0] - 40 <= e["fell_x"] <= g[1] + 40]
        out["findings"].append({"kind": "pit", "x0": g[0], "x1": g[1], "width": g[1] - g[0], "fall_probes": len(miss),
                                "note": "no catch floor: a miss costs 1 HP and re-enters at the recovery pose"})
    rp = room["recovery"]
    if rp["inside_solid"] or rp["support"] is None or rp["support"] < 0 or (rp["support_gap"] is not None and abs(rp["support_gap"]) > 4):
        out["findings"].append({"kind": "recovery", "pos": rp["pos"], "inside_solid": rp["inside_solid"], "support_gap": rp["support_gap"], "note": "fall recovery pose is not on solid ground"})
    # static pockets
    out["findings"] += pockets(room)
    return out


def pockets(room):
    """Under-ledge crawl pockets (headroom 60..95 over a standable top) and narrow channels (28.5..60 wide, >= 120 deep)."""
    size = room["size"]
    rects = [s["rect"] for s in room["surfaces"]] + [[-40, 0, 40, size[1]], [size[0], 0, 40, size[1]]]
    res = []
    # headroom pockets: under each ledge, the gap to the next solid below it
    tops = [r for r in rects if r[1] > 8 and r[0] >= 0 and r[0] < size[0]]
    one_way = lambda r: room["index"] >= 13 and r[3] == 40  # 40 px ledges in rooms 13..20 are one-way: no ceiling
    for a in tops:
        if one_way(a):
            continue
        for b in tops:
            if a is b:
                continue
            ax0, ay0, aw, ah = a
            bx0, by0, bw, bh = b
            ox0 = max(ax0, bx0)
            ox1 = min(ax0 + aw, bx0 + bw)
            if ox1 - ox0 < 30:
                continue
            gap = by0 - (ay0 + ah)
            slot = [ox0, ay0 + ah, ox1 - ox0, gap]
            filled = any(c is not a and c is not b and c[0] < slot[0] + slot[2] and slot[0] < c[0] + c[2] and c[1] < slot[1] + slot[3] and slot[1] < c[1] + c[3] for c in rects)
            if 0 < gap < 95 and ay0 + ah <= by0 and not filled:
                res.append({"kind": "pocket", "sub": "headroom", "x0": ox0, "x1": ox1, "y0": ay0 + ah, "y1": by0, "gap": gap,
                            "note": "slot between the underside of one solid and the top of the next (%d px)" % gap})
    # narrow vertical channels between neighbouring solids
    cols = sorted([r for r in tops if r[3] >= 100], key=lambda r: r[0])
    for a, b in zip(cols, cols[1:]):
        gapx = b[0] - (a[0] + a[2])
        if 28.5 < gapx < 60:
            y0 = max(a[1], b[1])
            y1 = min(a[1] + a[3], b[1] + b[3])
            if y1 - y0 >= 120:
                res.append({"kind": "pocket", "sub": "channel", "x0": a[0] + a[2], "x1": b[0], "y0": y0, "y1": y1, "gap": gapx,
                            "note": "%d px channel, %d px deep between two solids" % (gapx, y1 - y0)})
    return res


def main():
    args = sys.argv[1:]
    out = "docs/ld05/raw/ground_findings.json"
    paths = []
    i = 0
    while i < len(args):
        if args[i] == "--out":
            out = args[i + 1]
            i += 2
        else:
            paths.append(args[i])
            i += 1
    rooms = load(paths)
    result = [analyse(rooms[k]) for k in sorted(rooms)]
    json.dump(result, open(out, "w"), indent=1)
    for r in result:
        kinds = collections.Counter(f["kind"] for f in r["findings"])
        print("R%-2d %-22s %s" % (r["room"], r["name"], dict(kinds)))


main()
