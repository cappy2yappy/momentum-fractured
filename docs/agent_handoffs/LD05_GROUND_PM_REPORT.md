# LD05 ground negative space report (Priority 3, LEVEL MASTA)

Historical report. LD-07 resumed this branch at `fa299cff` on 2026-10-21. See [current audit](../ld07/ROOM_AUDIT.md) and [current QA](../ld07/QA_REPORT.md) for independently re-run Mac results, explicit unresolved GN-06 evidence, and the unapproved roof disposition. Earlier results below are retained as provenance.

Author: LEVEL MASTA. Model: Claude Sonnet 5.5 (claude-sonnet-5-5). Environment: Linux cloud container, Godot 4.6.1 stable, headless real-key probes and tests, xvfb + llvmpipe software GL for captures. No GPU, macOS, Windows or human playtest.

Branch `feature/ld05-intentional-world-boundaries` (draft PR #63, base `candidate/pm-pilot-combined`). Starting head `658ed34c2d182dd650c1d22b8fa6b3a6c43ca837`. Work commit SHA: see section 8 (filled from `gh api .../commits/<branch>` after the push). No merge, no main update.

## 1. Outcome in four lines

- Audited all 21 rooms at ground level with real-key probes: 11,180 ground probes (gates open), 5,400 more with Kunai gates closed, 58 door passes. No escape, no fall outside the 7 legacy pits, no trapped or stranded surface, no blocked doorway approach.
- Two confirmed defects fixed: GN-01 the R6 to R7 walk-through never opened on foot (HIGH, also at 49ae3efe); GN-02 pit water drawn 40 px above the floor lip it cuts (MED, art only).
- Everything else is judgement, not defect: pit cost, bare catch floors, past-door strips. Listed in `docs/ld05/GROUND_NEGATIVE_SPACE.md` with coordinates; nothing changed for them.
- Roof stays switchable and unassumed: `ROOF_ENABLED`, `ORIGINAL_ROOMS_ENABLED`, `--ld05-open-top`. Roof off: 69 of 91 wall chains and 4 of 46 fly probes escape; roof on: 0 and 0 (a6e3de25 baseline: 0).

## 2. Defect list (full table with coordinates: `docs/ld05/GROUND_NEGATIVE_SPACE.md` section 3)

| Id | Sev | Where | Status |
|---|---|---|---|
| GN-01 | HIGH | R6 to R7 exit (2440,1090) over a shelf whose top is 1110; trigger band is feet y 1000..1098 | fixed, sill |
| GN-02 | MED | R2 pits 640..930, 1350..1680, 2200..2380; R4 450..1000, 1280..2050; R5 500..780, 1500..1850: water drawn from y 1260, lip at 1300 | fixed, art only |
| GN-03 | JUDGE | same 7 pits: a miss costs 1 HP and returns to room entry | open |
| GN-04 | JUDGE | bare catch floors R9, R10, R13 quay, R16, R17, R20 | open |
| GN-05 | JUDGE | 38 past-door strips (58 or 98 px) | open |
| GN-06 | LOW | R6 dash begun 160..200 px before the sill can skip the 17 px arming window | residual |
| GN-07 to 09 | LOW | R14 duplicate collider (240,1200,240,40); unreachable recovery poses R13 (230,1198), R17 (1790,1298); flat pit water | open, harmless |

## 3. Fixes (no invisible barrier, no Kaze movement change, doorways not blocked)

- **LD05-G1 sill** (`scripts/room_boundary.gd` `SILLS`, `world.boundary_polys`): visible stone sill at R6 x 2390..2600, top 1090, steep first 22 px so the walk-through arming window is 17 px. `w.platforms` identical to 49ae3efe, endpoint (2440,1090) unchanged, the R7 to R6 arrival (2376) stays clear of the ramp, `player.gd` and `cinematic_transitions.gd` untouched. Switch: `SILLS_ENABLED`, `--ld05-no-sill`.
- **LD05-G2 pit water** (`RoomBoundary.pit_rect`, three call sites in `world.gd _draw`): drawn from y 1372. Colliders, recovery and endpoints unchanged. Switch: `PIT_WATER_ALIGNED`, `--ld05-legacy-water`.
- Probe tools added: `tools/ld05/ground_probe.gd`, `ground_audit.py`, `door_walk_probe.gd`; overlay now draws polygons.

## 4. Before and after (automated, exact)

| Measure | 49ae3efe | 658ed34 (before) | after |
|---|---|---|---|
| Walk-through exits that open for a walking Kaze | 38 / 39 | 38 / 39 | **39 / 39** |
| Door arrivals grounded and not inside a solid | not measured | 54 / 54 | 54 / 54 |
| Wall chains escaping the room (roof on) | 68 / 91 | 0 / 91 | 0 / 91 |
| Fly and grapple probes escaping (roof on) | 4 / 46 | 0 / 46 | 0 / 46 |
| Ground probes escaping | not run | 0 / 11,180 | 0 (R6 re-run after the sill: 0 of 348) |
| Falls outside the 7 pits | not run | 0 | 0 |

Raw data: `docs/ld05/raw/` (`door_walk_*.json`, `ground_probe_gates_*.json.gz`, `ground_findings.json`, `probe_ground_after.json`, `probe_open_top.json`).

## 5. Tests really run (numbers)

- `tests/ld05_boundaries.gd`: **171 checks, 0 failures** (was 156). New: 39 of 39 walk exits open on foot; R6 sill solid and platforms unchanged; walk and run opens in 8 of 8 trials from four starts; R7 to R6 arrival clear of the ramp; three pit drops cost 1 HP and recover on solid ground; pit water rectangle and switches. Dash from four starts is printed as information: 3 of 4 open (GN-06).
- Stock suites run on 658ed34 and on this change under identical conditions (headless, 60 fps), no difference in any count: approved_baseline 30 pass 2 fail, audit_intentional_space 21 / 0, automatic_passage_reliability 296 / 9, canal_geometry 172 / 1, pm_canal_left_passage 56 / 0, world_expansion 191 / 2, annex_traversal 6 / 0, annex_expansion 6 failures both when run alone (one run showed 4 under CPU load: flaky, not a regression), movement_momentum 46 / 11. `approved_combat_swing` times out and `storm_keeper` errors at script line 15 on both. These are pre-existing and are not caused by this change.
- PR59 harness `run_qa.py --expect-canal` at head 4c8ba174: harness 488 pass / 0 fail (start 10, issue42 49, matrix 136, endpoints 157, canal containment 25), author TR06 issue #42 suite **305 / 0**, stock TR05 suites 1607 / 0, Canal hooks 25 / 0. Its overall verdict is FAIL only because of two failures that exist identically at 658ed34 and 49ae3efe: `automatic_passage_reliability` 9 failures and `verify_tr05_preservation.py` 'expansion build_room PR37 function exact' (the Canal gatehouse hook). Software-GL graphical subset not re-run at this head (it was 67 / 0 at a6e3de25; the only rendering changes are the R6 sill and pit water, captured above).

## 6. Captures (software GL, llvmpipe; before = 658ed34, after = this change)

`docs/ld05/captures_ground/`: `R6_door_sill_before_after.jpg`, `R6_door_sill_ov_before_after.jpg` (collider overlay, sill in magenta), `R4_pit_edge_before_after.jpg`, `R4_pit_edge_ov_before_after.jpg`, `R2_pit_edge_before_after.jpg`, `R5_pit_edge_before_after.jpg`. I opened and inspected each. SHA256 in `MANIFEST.sha256`; re-download verification result in section 8.

## 7. Remaining defects and creator decisions

1. GN-03: pit pacing. Keep return-to-entry (current), or add a mid-room catch or rest ledge in R4 (second pit 770 px)? These are creator-approved rooms, so nothing was changed.
2. GN-04: should bare catch floors (R9, R10, R13, R16, R17, R20) get a Bellroof-style lower service route, or stay plain recovery floors? Recoverability is proven (1 to 4 moves back up everywhere); purpose is a design call.
3. GN-05: 38 past-door strips stay unless the creator wants door-side piers (needs Transition sign-off).
4. GN-06 and the "WALK THROUGH" label sitting on the sill masonry belong to Transition (`cinematic_transitions.gd`): a per-endpoint `corridor_below` tolerance would remove the need for the sill and the dash miss.
5. Whether the universal roof stays is still the creator's call; this change does not depend on it.
6. Kunai gates are jump-bypassable in all 10 gate rooms (closed-gate probes). Progression is enforced by flags, not collision. Unchanged, as in LD05_PM_REPORT.md.
7. No creative acceptance is claimed; no human saw these captures.

## 8. SHAs and verification

Filled after push, see the delivery message and `gh api repos/cappy2yappy/momentum-fractured/commits/feature/ld05-intentional-world-boundaries`.
