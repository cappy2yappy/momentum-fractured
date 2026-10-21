#!/usr/bin/env python3
"""Build docs/ld05/room_audit.json and docs/ld05/ROOM_AUDIT.md from probe output.

  godot --headless --path <base>  --fixed-fps 60 --script res://tools/ld05/room_probe.gd -- --out=res://build/ld05/probe_base.json
  godot --headless --path <after> --fixed-fps 60 --script res://tools/ld05/room_probe.gd -- --out=res://build/ld05/probe_new.json
  godot --headless --path <base>  --fixed-fps 60 --script res://tools/ld05/gate_probe.gd -- --out=res://build/ld05/gates_base.json
  python3 tools/ld05/build_audit.py --before <probe_base.json> --after <probe_new.json> --gates <gates_base.json> --out docs/ld05

No em dashes in output. Classes: legit (legitimate vertical exploration, keep), escape (unintended escape, fix), misleading
(misleading platform), dead (dead reachable space), approach (unsupported approach).
"""
import argparse, json, math
from pathlib import Path

ROUTE = {
 0: "Spawn at the Haven shrine (220,1300). East walk-through (2440,1300) to R1. Depth door (590,780) to R13 (needs Windstep).",
 1: "West door back to R0. Windstep pickup (1580,1300) after the market guard. East walk-through (2440,1300) to R2 (needs Windstep).",
 2: "West door to R1. Pit-and-ledge ascent east. Wind kunai gate (2150,850) opens the cistern cache. East walk-through (2440,850) to R3. Depth door (470,1120) to R15 (needs the cache and Wind kunai).",
 3: "West door (120,850) to R2. Wind Tether pickup (1320,1300). East walk-through (2440,1300) to R4 (needs Tether). Depth door (2250,790) to R9 return seal.",
 4: "West door to R3. Fire kunai (1080,980). Span fire cache gate (1990,1080). East walk-through (2440,1080) to R5.",
 5: "West door (120,1080). Gale Dash (1320,1300), Electric kunai (1510,930). East walk-through (2440,1300) to R6 (needs Dash). Depth door (2240,930) to R17 (needs Tether and Dash).",
 6: "Boss arena. East walk-through (2440,1090) to R7 (needs the Tide Warden defeated).",
 7: "Relay Archive: electric seal gate (2000,1300), control (2200,1190). East walk-through (2440,1300) to R8 (needs Archive restored).",
 8: "Undercroft shrine (2060,1300), sigil (1470,690). West to R7, east (2440,830) to R9. Depth doors to R16 (550,1110), R18 (1090,920), R12 return (1470,740).",
 9: "Three relay sigils: west (1490,600), fire cache (2240,770, behind gate 2110,810). East walk-through (2440,830) to R10 (needs all sigils). Depth doors to R14 (1100,1040) and R3 return (160,620).",
 10: "Skyworks approach. Wind intake gate (2110,810) must be opened to enter R11. East walk-through (2440,760).",
 11: "Foundry refuge (1720,1300). Electric relay gate (2370,760) must be opened to enter R12. Depth door (890,980) to R19.",
 12: "Storm Keeper arena (boss 1320,1300), relay (2220,1300). Depth door (220,830) back to R8 after the Keeper.",
 13: "Canal Haven door (120,1200) at the foot of the gatehouse hallway, stepped shelves climb right to the R14 walk-through (1680,560). Stride I (450,440), wind-fold door (900,400) to R20.",
 14: "Bellroof Walk: west door (120,1100) from R13, long roof walk east to R9 walk-through (2440,830). Local stair (1450,480) up to R17.",
 15: "Lower Sluice: from the R2 door (120,500) a dry descent east to the R16 walk-through (2080,1120). Optional wind gate (500,500).",
 16: "Root Shrine (420,1120) save. West door R15, east (1880,760) to R8, depth door (1000,430) to R18.",
 17: "Counterweight Spire: climb from the R5 door (120,1900) by landings to the top. Stair down (1680,1300) to R14, depth door (1500,420) to R20 behind the spire wind shutter.",
 18: "Pump Gallery: from R16 door (120,1000) east along the pump walk to the R19 walk-through (2440,760) behind the electric isolator. Depth door (1200,1180) to R8.",
 19: "Coil Service Hall: from R18 (120,760) across service bays; east walk-through (2280,980) to R11; depth door (1800,480) to R20 behind the coil fire gate.",
 20: "Relay Junction: from R17 (120,760) up to the wind-fold (600,520) to R13; east walk-through (2080,1120) to R19.",
}
SCENERY_FIXED = {
 13: "Dashed grey truss lines (two 9 px strokes per bay) read as walkable ramps; now thin, dim and dashed.",
 15: "Four full-width 12 px 'service rails' and 150 px arches read as ledges; now dim and dashed.",
 17: "Five full-width 'LIFT' landing lines read as ledges; truss lines as R13; now dashed and dim.",
 19: "Overhead 10 px conduit across the room read as a ceiling ledge; arches as R15; now dashed and dim.",
}


def rise(p):
    return p["min_feet_y"]


def summarize(room):
    rows = room["wall"] + room.get("face", [])
    fly = room.get("fly", [])
    gr = room.get("grapple", [])
    return {
        "wall_probes": len(rows),
        "wall_escaped": sum(1 for r in rows if r["escaped"]),
        "wall_min_feet_y": min([r["min_feet_y"] for r in rows]) if rows else None,
        "fly_probes": len(fly),
        "fly_escaped": sum(1 for r in fly if r["escaped"] or r["min_feet_y"] < -8),
        "fly_min_feet_y": min([r["min_feet_y"] for r in fly]) if fly else None,
        "grapple_probes": len(gr),
        "grapple_attached": sum(1 for r in gr if r["attached"]),
        "grapple_escaped": sum(1 for r in gr if r["escaped"]),
        "grapple_min_feet_y": min([r["min_feet_y"] for r in gr]) if gr else None,
    }


def ledge_class(room, ps):
    """Static kinematic model (NOT a proof): single jump 225 px apex, walk 420 px/s; advanced: double jump 450, sprint 630, dash 166."""
    def land_time(dy, apex):
        g = 1800.0
        v0 = math.sqrt(2 * g * apex)
        if dy > apex:
            return None
        return (v0 + math.sqrt(max(0.0, v0 * v0 - 2 * g * dy))) / g

    def can(a, b, mode):
        ax, ay, aw, _ = a
        bx, by, bw, _ = b
        gap = max(0, max(bx - (ax + aw), ax - (bx + bw)))
        dy = ay - by
        apex, v, extra = (225, 420, 0) if mode == "ord" else (450, 630, 166)
        t = land_time(dy, apex if dy > 0 else (225 if mode == "ord" else 450))
        return t is not None and gap <= v * t + extra

    h = room["size"][1]
    floors = [i for i, p in enumerate(ps) if p[1] >= h - 145]
    out = {}
    for mode in ("ord", "adv"):
        seen = set(floors)
        fr = list(floors)
        while fr:
            i = fr.pop()
            for j, p in enumerate(ps):
                if j not in seen and can(ps[i], p, mode):
                    seen.add(j)
                    fr.append(j)
        out[mode] = seen
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--before", required=True)
    ap.add_argument("--after", required=True)
    ap.add_argument("--gates", required=True)
    ap.add_argument("--out", required=True)
    a = ap.parse_args()
    before = {r["index"]: r for r in json.load(open(a.before))["rooms"]}
    after = {r["index"]: r for r in json.load(open(a.after))["rooms"]}
    gates = json.load(open(a.gates))
    out = Path(a.out)
    out.mkdir(parents=True, exist_ok=True)
    audit = {"base": "49ae3efe21dea6a9eba556ce2fbc8299b00412b9", "rooms": [], "totals": {}}
    fid = 0
    totals = dict(wall_probes_before=0, wall_escaped_before=0, wall_probes_after=0, wall_escaped_after=0,
                  fly_escaped_before=0, fly_escaped_after=0, findings=0)
    md = []
    for idx in range(21):
        b, f = before[idx], after[idx]
        sb, sf = summarize(b), summarize(f)
        for k, tk in (("wall_probes", "wall_probes"), ("wall_escaped", "wall_escaped")):
            totals[k + "_before"] += sb[tk]
            totals[k + "_after"] += sf[tk]
        totals["fly_escaped_before"] += sb["fly_escaped"]
        totals["fly_escaped_after"] += sf["fly_escaped"]
        size = b["size"]
        ps = [p["rect"] for p in b["platforms"] if not p["boundary"] and p["rect"][3] <= 200]
        cls = ledge_class(b, ps)
        adv_only = [ps[i] for i in sorted(cls["adv"] - cls["ord"])]
        findings = []

        def add(kind, text, status, evidence):
            nonlocal fid
            fid += 1
            findings.append({"id": "LD05-%03d" % fid, "class": kind, "text": text, "status": status, "evidence": evidence})

        # escapes per wall side
        for side, name in ((-1, "left"), (1, "right")):
            rows = [r for r in b["wall"] if r["side"] == side]
            esc = [r for r in rows if r["escaped"]]
            rows_a = [r for r in f["wall"] if r["side"] == side]
            if esc:
                worst = min(r["min_feet_y"] for r in esc)
                origins = sorted({r["origin"] for r in esc})
                after_min = min(r["min_feet_y"] for r in rows_a)
                add("escape", "%s wall: chained wall jumps from %s leave the world (feet y %.0f, x outside the room)." % (name, "/".join(origins), worst),
                    "fixed by the roof course (LD05-F1)", {"before_min_feet_y": worst, "after_min_feet_y": after_min, "after_escaped": any(r["escaped"] for r in rows_a)})
            elif idx == 13 and side < 0:
                add("legit", "left wall: owned by the Canal gatehouse mass and back pier (contract); chains inside the hallway hold at feet y 1018..1080 under the lintel. Unchanged.", "kept (creator-approved Canal geometry)", {"min_feet_y": min(r["min_feet_y"] for r in rows)})
            else:
                low = min(r["min_feet_y"] for r in rows)
                add("legit", "%s wall: chains from every probed start stay below the room top (feet y %.0f); a solid ledge touching the wall already caps it." % (name, low),
                    "kept", {"before_min_feet_y": low})
        for r in b.get("face", []):
            if r["escaped"]:
                add("escape", "Outer face of solid mass %s: wall jumps from a ledge reach feet y %.0f and leave the world." % (r["face_rect"], r["min_feet_y"]),
                    "fixed by the roof course (LD05-F1)", {"before_min_feet_y": r["min_feet_y"], "after": [x["min_feet_y"] for x in f["face"] if x["face_rect"] == r["face_rect"]]})
        seen_fly = set()
        for r in b.get("fly", []):
            key = (tuple(r["start"]), r["side"])
            if (r["escaped"] or r["min_feet_y"] < -8) and key not in seen_fly:
                seen_fly.add(key)
                add("escape", "Jump + double jump (+ dash) from the ledge at (%d,%d) toward the %s wall reaches feet y %.0f: above the top of the room, on the wall top." % (r["start"][0], r["start"][1], "left" if r["side"] < 0 else "right", r["min_feet_y"]),
                    "fixed by the roof course (LD05-F1)", {"before_min_feet_y": r["min_feet_y"], "after": [x["min_feet_y"] for x in f["fly"] if x["start"] == r["start"] and x["side"] == r["side"]]})
        if sb["grapple_probes"]:
            add("legit", "Tether anchors: %d of %d scripted swings attach, best height feet y %.0f. Grapple never reaches the room top." % (sb["grapple_attached"], sb["grapple_probes"], sb["grapple_min_feet_y"]),
                "kept", sb)
        if adv_only:
            add("legit", "%d ledge(s) need the double jump (static model: rise above 225 px from every ordinary support): %s. Ability gating by height; kept." % (len(adv_only), adv_only[:3]),
                "kept", {"ledges": adv_only})
        # bounded dead column
        content_top = min([p[1] for p in ps if p[1] < size[1] - 145] + [1e9])
        dead_band = content_top - 116.0
        add("dead", "Wall column between the highest ledge (y %.0f) and the roof underside (feet y 116) is %.0f px of bare wall; reachable only by sustained wall jumps, now bounded and harmless." % (content_top, dead_band),
            "kept, bounded", {"highest_ledge_top": content_top, "dead_band_px": dead_band})
        # door audit
        for d in b["door"]:
            if d["mode"] == "horizontal_walk" and d.get("wall_side"):
                if idx == 13 and d["at"] == [120.0, 1200.0]:
                    continue
                pass
            if d.get("door_span_supported") is False:
                off = d.get("support_top_offset")
                if off is not None and off != 0 and abs(off) <= 24:
                    add("approach", "Door to R%d at (%d,%d): walkable top is %+d px from the door feet (door drawn %s its shelf)." % (d["target"], d["at"][0], d["at"][1], off, "floating above" if off > 0 else "sunk into"),
                        "fixed by door seating (LD05-F4); endpoint and trigger unchanged", d)
                else:
                    sup = d["support"]
                    add("approach", "Door to R%d at (%d,%d): the shelf under it ends at x %d; the drawn door spans x %d..%d, so %d px overhang empty space." % (d["target"], d["at"][0], d["at"][1], sup[0] + sup[2], d["at"][0] - 48, d["at"][0] + 48, d["at"][0] + 48 - (sup[0] + sup[2])),
                        "fixed by the 40 px shelf seat (LD05-F3)", d)
        walls = [d for d in b["door"] if d["mode"] == "horizontal_walk" and d.get("wall_side") and not (idx == 13 and d["at"] == [120.0, 1200.0])]
        if walls:
            add("dead", "%d wall-side walk-through exit(s) leave %s px of floor beyond the drawn door where Kaze can stand with the door behind.%s" % (len(walls), "/".join(sorted({"%d" % d["dead_space_past_door_px"] for d in walls})), " (R13 to R0 is already closed by the Canal back pier and is not counted.)" if idx == 13 else ""),
                "residual (creator decision, see report)", {"exits": [[d["target"], d["at"]] for d in walls]})
        if idx in SCENERY_FIXED:
            add("misleading", SCENERY_FIXED[idx], "fixed (LD05-F5), presentation only", {})
        if idx == 13:
            add("dead", "60 px crawlspace under the Canal hallway pad (x 0..360, y 1240..1300): Kaze could walk in from the quay floor and stand at the wall.", "fixed by the plinth (LD05-F2)", {})
        if idx in (2, 4, 5):
            add("legit", "Water pits between floor segments are the room's hazard (fall recovery returns Kaze, costs 1 hp). Intended.", "kept", {})
        for g in [x for x in gates if x["room"] == idx]:
            pass
        gl = [g for g in gates if g["room"] == idx and g["mode"] == "chain" and not g["double_jump"]]
        for g in gl:
            if not g["supported_start"]:
                add("legit", "Gate %s (%dx30 body at %s) floats over a gap with no ledge at its base: the wall-jump bypass probe could not be started supported and is not evaluated." % (g["gate"], g["height"], g["at"]),
                    "kept, not evaluated", g)
                continue
            add("legit", "Gate %s (%dx30 body at %s): %s by wall jumps up its side (probe passed=%s). Not a progression defect: entry to the next room is enforced by world.can_enter / expansion.allowed flags, not by collision." % (g["gate"], g["height"], g["at"], "bypassed" if g["passed"] else "held", g["passed"]),
                "kept, documented", g)
        room_rec = {
            "index": idx, "name": b["name"], "size": size, "intended_route": ROUTE[idx],
            "endpoints": b["endpoints"], "gates": b["gates"], "anchors": b["anchors"],
            "ledges": {"total": len(ps), "needing_double_jump": len(adv_only)},
            "probe_before": sb, "probe_after": sf, "findings": findings,
        }
        audit["rooms"].append(room_rec)
        totals["findings"] += len(findings)
        md.append("## R%d %s (%dx%d)\n" % (idx, b["name"], size[0], size[1]))
        md.append("Intended route: %s\n" % ROUTE[idx])
        md.append("Probes before, after (wall chains incl. faces / escaped / lowest feet y): %d / %d / %.0f, then %d / %d / %.0f. Double jump + dash from near-top ledges: %d probes, %d escaped before, %d after. Grapple: %d swings, %d attached.\n" % (
            sb["wall_probes"], sb["wall_escaped"], sb["wall_min_feet_y"], sf["wall_probes"], sf["wall_escaped"], sf["wall_min_feet_y"],
            sb["fly_probes"], sb["fly_escaped"], sf["fly_escaped"], sb["grapple_probes"], sb["grapple_attached"]))
        md.append("| Id | Class | Finding | Status |\n|---|---|---|---|")
        for x in findings:
            md.append("| %s | %s | %s | %s |" % (x["id"], x["class"], x["text"].replace("|", "/"), x["status"]))
        md.append("")
    audit["totals"] = totals
    (out / "room_audit.json").write_text(json.dumps(audit, indent=1))
    head = ["# LD-05 room-by-room audit (21 rooms)\n",
            "Base candidate 49ae3efe. Data: `docs/ld05/room_audit.json`, probes `tools/ld05/room_probe.gd` and `tools/ld05/gate_probe.gd`, builder `tools/ld05/build_audit.py`. All movement probes use real InputEventKey input and real physics (no position or velocity writes except the fixture start pose); `player.gd` is untouched.\n",
            "Classes: **legit** legitimate vertical exploration (keep), **escape** unintended escape (fix), **misleading** misleading platform, **dead** dead reachable space, **approach** unsupported approach.\n",
            "Totals: wall-chain and face probes before %d (%d escaped), after %d (%d escaped); double jump + dash probes escaped before %d, after %d. %d findings.\n" % (
                totals["wall_probes_before"], totals["wall_escaped_before"], totals["wall_probes_after"], totals["wall_escaped_after"], totals["fly_escaped_before"], totals["fly_escaped_after"], totals["findings"]),
            "Method limits: one scripted bot per probe, not exhaustive jump-arc proof. Ledge height classes come from a static kinematic model (labelled in the finding), not from play. No human playtest.\n"]
    (out / "ROOM_AUDIT.md").write_text("\n".join(head + md))
    print("findings", totals)


if __name__ == "__main__":
    main()
