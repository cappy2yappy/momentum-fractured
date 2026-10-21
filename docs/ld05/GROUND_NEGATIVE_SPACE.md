# LD-05 ground-level negative space audit

Head audited: 658ed34 (PR #63). Scope: all 21 rooms at ground level. Evidence kinds are labelled: **automated** (headless real-key probes, exact numbers), **software GL** (xvfb llvmpipe captures with collider overlay), **human** (none; the creator has not played this change). Nothing here claims creative acceptance.

## 1. Method

| Tool | What it does | Output |
|---|---|---|
| `tools/ld05/ground_probe.gd` | From sample points on every standing surface (floors every 200 px, ledges at both ends and the middle) plays seven real-key moves in both directions (hop, jump, jump + double jump, + dash, double-tap run, walk off, grapple) and records the surface landed on, or the pit fallen into. `--gates=closed` rebuilds each gate room with its Kunai gates solid. | `raw/ground_probe_gates_open.json.gz`, `raw/ground_probe_gates_closed.json.gz` |
| `tools/ld05/ground_audit.py` | Turns the probes into a surface graph and reports unreachable surfaces, trapped surfaces (reachable, no way back to a door), pits, fall-recovery pose, and static pockets (solid-ceiling slots, narrow channels). | `raw/ground_findings.json` |
| `tools/ld05/door_walk_probe.gd` | Stands on the support 220 px before every door, holds the key toward it (or presses E for depth doors and wind folds), and records whether the passage opens and where Kaze arrives. | `raw/door_walk_after.json`, `raw/door_walk_base_49ae3efe.json` |
| `tools/ld05/capture.gd` + `overlay.gd` | Software-GL captures with the live collider set drawn (teal solid, gold one-way, magenta LD-05 solids and polygons). | `captures_ground/` |

Sizes: 11,180 real-key ground probes with gates open (21 rooms), 5,400 with gates closed (the 10 gate rooms), 58 door passes (39 walk-through, 19 interact), 91 wall chains and 46 fly or grapple probes for the escape count.

## 2. Results

| Question | Result |
|---|---|
| Escapes (probe ends outside the room or above its top) | **0** of 11,180 ground probes; **0** of 91 wall chains and **0** of 46 fly or grapple probes (baseline a6e3de25 had 0). With the roof switched off (`--ld05-open-top`, `raw/probe_open_top.json`) the same probe set escapes in 69 of 91 wall chains and 4 of 46 fly or grapple probes, so the switch comparison is live. The ground findings below do not depend on the roof. |
| Falls out of the world through a non-intentional gap | **0.** Every probe that fell did so inside one of the 7 legacy pits (R2 x3, R4 x2, R5 x2). |
| Stranded or trapped surfaces (reachable, no probed way back to a door) | **0** in 21 rooms, gates open and closed. |
| Unreachable standing surfaces | **0** real. Two reports are not defects: R14 (240,1200,240,40) is a second collider on the same top as (200,1200,300,40); R13 (0,1020,72,180) is the Canal back pier whose top is inside the gatehouse mass. |
| Exit access | **38 of 39** walk-through exits opened for a walking Kaze at 49ae3efe and at 658ed34. **GN-01** was the one that did not. After the fix: **39 of 39**. Interact doors: 15 of 19 open; the other four (R3 to R9, R9 to R3, R8 to R12, R12 to R8) are gated returns that need story flags the fixture does not set. |
| Arrival after a pass | 54 of 54 observed arrivals end grounded, none inside a solid. |
| Floor to route recovery | Every room's floor reaches every door in 1 to 4 probed moves (R17 floor to the R20 depth door is the longest at 4). |
| Blocked doorway approaches (solid in the 28x60 capsule path 0 to 200 px before a door) | **0.** Seven overhead one-way ledges were flagged and are not obstacles. |
| Closed Kunai gates | In all 10 gate rooms every door stays reachable with the gate solid: jump or double jump clears a 30 px wide gate. This is the known progression residual (LD05 report 6), not a pocket. |

## 3. Prioritised defect list

Severity: HIGH breaks a route, MED misleads at ground level, LOW cosmetic or latent, JUDGE needs a creator decision (no change made).

| Id | Sev | Room and coordinates | Finding | Status |
|---|---|---|---|---|
| GN-01 | HIGH | R6 to R7 walk-through, endpoint (2440,1090), shelf (2020,1110,580,40) | The shelf top is 20 px below the endpoint. The walk-through only arms and fires for feet y between endpoint y minus 90 and endpoint y plus 8 (1000..1098); a walking Kaze has feet y 1110, so the exit never opened (probe: 240 ticks, reached the wall at x 2586, no pass). Same at 49ae3efe. LD-05 had only redrawn the door onto the shelf, which made the door look usable while it was dead on foot. | **Fixed (LD05-G1)**: visible stone sill, see 4 |
| GN-02 | MED | R2 pits x 640..930, 1350..1680, 2200..2380; R4 x 450..1000, 1280..2050; R5 x 500..780, 1500..1850 | The pit water is drawn from y 1260, 40 px above the 1300 floor lip it cuts. The pit reads as a raised blue wall and the drop reads as a step up. Collider unchanged: Kaze falls through the drawn water. | **Fixed (LD05-G2)**: water surface drawn from y 1372, art only, see 4 |
| GN-03 | JUDGE | same 7 pits | A miss costs 1 HP and returns Kaze to the room entry (x 230) wherever the miss happened. In R4 a miss on the second pit (width 770) costs the whole first crossing. Whether a mid-room rest ledge or catch shelf should exist is a pacing call on creator-approved rooms. | Not changed |
| GN-04 | JUDGE | catch floors with no content: R9, R10, R13 quay, R16, R17, R20 (all of y 1300 or R17 y 2020) | The floor is a recoverable catch plane under the stair route (graph: 1 to 4 moves back up, nothing trapped). It has no pickup, enemy, hazard or cue. Rooms where the floor has a job (seen in the captures): R0 and R8 (shrines), R1, R3, R5 (pickups), R6 and R12 (boss), R7 (relay control), R11 (refuge), R14 (Bellroof service route, the reference design), R15, R18, R19 (vents). Whether bare catch floors should get a service route like Bellroof is a design decision. | Not changed |
| GN-05 | JUDGE | 38 past-door strips of 58 or 98 px (listed in `ROOM_AUDIT.md` LD05-005, -009, ...) | Standable only by jumping or dashing over a door line (a walker is passed through first). Closing them needs piers beside every door that the door cinematics walk through. | Not changed, see LEVEL_CINEMATIC_IMPACT.md |
| GN-06 | LOW | R6 sill, dash only | A dash begun 160 to 200 px before the sill (probe start x 2300, 8 ticks in) crosses the 17 px arming window in one tick and lands past the door without opening it; walk back 16 px and cross again. Dashes from 2060, 2200 and 2384 opened it. Root cause is the arming rule in `cinematic_transitions.gd`, which is not a Level file. | Residual; recommendation for Transition: give an endpoint an optional `corridor_below` tolerance |
| GN-07 | LOW | R14 (240,1200,240,40) | Duplicate collider on the top of (200,1200,300,40). Harmless, drawn twice. | Not changed (LD-03 service route data) |
| GN-08 | LOW | R13 recovery pose (230,1198), R17 (1790,1298) | `recover_from_fall` would place Kaze here, but it only runs for y > room height + 70 and both rooms have full floors. Latent, not reachable. | Not changed |
| GN-09 | LOW | R2/R4/R5 water | Water is flat-coloured and unlabelled; no ripple or splash on entry. Visual polish, outside Level scope. | Not changed |

## 4. Fixes made (only GN-01 and GN-02)

**G1 sill (GN-01).** `scripts/room_boundary.gd` `SILLS[6]` adds a visible masonry sill: a solid polygon rising 16 px in 22 px and then 4 px more to the endpoint line, flat to the wall, seated on the shelf. Collider and art share the polygon (`world.boundary_polys`, bounding rect `(2390,1090,210,26)` in `boundary_rects`). The first 22 px are steep on purpose: the walk-through arms only when feet are within 8 px below the endpoint and at least 16 px before it, so the arming window is 17 px wide at run speed (a gentle 50 px ramp gave 4 px and missed). The sill starts at x 2390, 14 px right of the R7 to R6 arrival capsule (2376), so the arrival pose and `arrival_position` are untouched. Door and label are now seated on the sill, so the R6 door draw offset is 0. `w.platforms` is byte-identical, the endpoint stays (2440,1090), `player.gd` and `cinematic_transitions.gd` are untouched. Switch: `RoomBoundary.SILLS_ENABLED` or `--ld05-no-sill`.

**G2 pit water (GN-02).** `RoomBoundary.pit_rect` moves the three pit rooms' drawn water surface from y 1260 to 1372 (8 px of crest included). Colliders and recovery are unchanged. Switch: `RoomBoundary.PIT_WATER_ALIGNED` or `--ld05-legacy-water`.

Roof-on versus roof-off remains available (`ROOF_ENABLED`, `ORIGINAL_ROOMS_ENABLED`, `--ld05-open-top`). Neither fix depends on the roof.

## 5. Captures (software GL, llvmpipe, left before at 658ed34, right after)

`captures_ground/R6_door_sill_before_after.jpg` and `_ov_` (collider overlay), `R4_pit_edge_before_after.jpg` and `_ov_`, `R2_pit_edge_before_after.jpg`, `R5_pit_edge_before_after.jpg`. SHA256 in `captures_ground/MANIFEST.sha256`.

## 6. Tests

`tests/ld05_boundaries.gd`: 171 checks, 0 failures. New ground checks: all 39 walk-through exits open on foot; R6 sill solid, platforms unchanged, endpoint unchanged; R6 exit opens in 8 of 8 walk and run trials; R7 to R6 arrival stands clear of the ramp; three pits drop through the drawn water, cost 1 HP and recover on solid ground; switches restore the old state. A dash trial set is printed as information (3 of 4 open).
