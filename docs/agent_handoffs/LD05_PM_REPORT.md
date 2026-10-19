# LD05 report: intentional world boundaries (LEVEL MASTA, Wave 3, order 3)

Author: LEVEL MASTA. Model: Claude Sonnet 5.5 (claude-sonnet-5-5). Environment: Linux cloud container, Godot 4.6.1 stable, headless for tests, xvfb + software GL (gl_compatibility, opengl3) for captures. No Windows, macOS, GPU or human playtest.

Branch `feature/ld05-intentional-world-boundaries`, base candidate `49ae3efe21dea6a9eba556ce2fbc8299b00412b9` (PR base `candidate/pm-pilot-combined`). Draft PR: see the PR link in the delivery message (REST, draft). Merge, main and release untouched.

## 1. What was found (all 21 rooms, real input)

Full audit: `docs/ld05/ROOM_AUDIT.md` (human), `docs/ld05/room_audit.json` (machine), raw probe output `docs/ld05/raw/`. Probe tools (reproducible, `player.gd` untouched): `tools/ld05/room_probe.gd`, `gate_probe.gd`, `build_audit.py`.

Headline numbers on the base candidate (91 scripted real-key probes: held wall-jump chains from the floor and from every ledge touching a wall, tall-face chains, and jump + double jump + dash from near-top ledges):
- 68 of 91 left the world (feet y down to -165, x outside the room). Every one of the 42 wall faces was climbable to the top of the room, except where a solid ledge touching the wall happened to cap it (R0 to R12 have solid ledges, R13 to R20 have one-way ledges that never cap).
- The named residuals reproduce exactly: gatehouse outer face x=296 (feet y -164.6) and R13 right wall (-144.0).
- Two near-top shelves let a plain double jump (or double jump + dash) lift Kaze above the top of the room onto a wall top: R13 shelf (300,440) toward the gatehouse (feet y -14.6), R17 shelf (1200,420,450) at its right end (1626,418, feet y -34.6).
- Tether swings never reach the top (the best attached scripted swing reaches feet y 497; no grapple probe came near the room top).
- The audit's three door defects reproduce: R6 to R7 +20 px, R9 to R10 -20 px, R8 to R18 door overhangs its shelf by 28 px (68 of 96 px supported).
- Misleading scenery that reads as ledges, ramps or ceilings: R13 truss lines, R15 rails and arches, R17 lift lines, R19 conduit.
- Dead reachable space: a 60 px crawlspace under the Canal hallway pad (R13, x 0..360); bare wall columns above the top content in every room; 38 wall-side walk-through exits with 58 or 98 px of floor beyond the drawn door.
- Not defects (kept, documented): kunai gate bodies can be bypassed with wall jumps (7 of 8 supported gates), but entry to the next room is enforced by `world.can_enter` and `expansion.allowed` flags, not by collision. Water pits in R2, R4, R5 are the room hazard. Ledges that need the double jump from the floor are ability gating by height.

Classification totals in the JSON (122 findings): escape 44 (all fixed), approach 3 (all fixed), misleading 4 (fixed), dead 43 (1 fixed, 21 bounded and kept, 21 residual), legit 28 (kept).

## 2. What was changed (focused, visible, reversible)

| Id | Change | Why it is not a blanket barrier |
|---|---|---|
| LD05-F1 | A structural roof course along the top edge of every room: collider Rect(-40,-640,W+80,696), underside y=56, visible band y 0..56 drawn with the room's own approved masonry tile, a cap line and shadow. Source: `scripts/room_boundary.gd`. | It is visible architecture (a drawn masonry course; the collider is the drawn rectangle plus an off-screen backing so its top face cannot be reached). It does not change wall jumping, double jump, dash or grapple; it only gives the room the top it never had. No legitimate content is near it: the highest ledge top is y=400 and the highest anchor y=250 (194 px below the underside). It is one switch: `RoomBoundary.ROOF_ENABLED`, `--ld05-open-top`, and per original-room switch `ORIGINAL_ROOMS_ENABLED`. |
| LD05-F2 | R13 quay footing Rect(0,1240,360,60) under the Canal hallway pad. | Closes the crawlspace nook. Pad top y=1200, door, trigger, corridor, arrival, mass and pier are untouched; a test asserts nothing LD05 enters x 0..360, y 1020..1240. |
| LD05-F3 | R8 shelf seat Rect(1110,920,40,40) continuing the shelf under the R18 depth door. | The door span 1042..1138 is now 96 of 96 px supported. Separate solid; no platform rectangle edited (the PR33 signature test for R8 stays green). |
| LD05-F4 | Door seating: `world.draw_door` translates the drawing by `RoomBoundary.seat_offset` so R6 to R7 (+20) and R9 to R10 (-20) doors sit on the shelf Kaze stands on. | Draw only. Endpoints, triggers, saves and every platform stay; `p.at` equality used by the cinematic, embodied and mixed drawers still matches. |
| LD05-F5 | Scenery rails, arches and truss lines in R13, R15, R17, R19 are dim and dashed (`RoomBoundary.scenery_line` and `scenery_arc`). | Presentation only; nothing physical. |

Hooks in guarded files: `scripts/world.gd` (const, `boundary_rects`, two calls in `build_room`, one in `_draw`, `draw_door`), `scripts/room_presentation.gd` and `scripts/world_expansion.gd` (`draw_room` and `draw_background` only). None of the functions pinned by `tools/verify_tr05_preservation.py` changed (it still reports the single pre-existing line, "expansion build_room PR37 function exact").

Roof placement note: the roof body is created first in `build_room` (`RoomBoundary.build_roof`). Created later it reordered physics bodies and flipped the fragile tail check "Room 14 failed traversal recovers on dry floor" in `tests/expansion_traversal.gd` (the test drops Kaze inside a block); first-in-order leaves the stock suites byte-for-byte green.

PR #49 use: nothing imported. The same principle (the collider rectangle IS the drawn rectangle, authored from one data table) is used for the added shapes, which are frozen from the live builder in PR #49's `r18_frozen.json` schema (rect, layer, mask, one_way, margin plus a role) in `docs/ld05/ld05_frozen_shapes.json` by `tools/ld05/freeze_additions.gd`. `tools/ld05/overlay.gd` and `capture.gd` give the geometry-laboratory view (teal solid, gold one-way, magenta added) used in the `*_geometry_before_after.jpg` captures. Replacing the world geometry system with scene-authored rooms was not attempted.

## 3. Preservation

- `player.gd` byte-identical (test asserts the manifest controller sha256). No movement, combat, save, graph, gate or endpoint change.
- Per-room platform list identical to 49ae3efe for all 21 rooms (`docs/ld05/base_platforms_49ae3efe.json`, asserted in `tests/ld05_boundaries.gd`), so the approved eight-room signature, the R14 +12 rule and the R13 +2 Canal rule hold untouched.
- Canal doorway: aperture (72,1068,96,132), trigger x=120, corridor y 1110..1208, arrival (184,1198), mass Rect(0,0,296,1020), pier Rect(0,1020,72,180) unchanged; capture `R13_canal_door_unchanged_before_after.jpg` shows the door identical (only the new plinth below the pad differs).
- R14 stair (1450,480) and R17 stair (1680,1300): endpoints, arrival points and shelves untouched. `/home/claude/wave3_shared/LEVEL_CINEMATIC_IMPACT.md` lists every change that Transition could notice.

## 4. Tests (real numbers, Linux headless, Godot 4.6.1)

Same runner and harness as PR59 (`tools/pm_pilot_qa/run_qa.py` from the PR59 branch, run from a separate checkout against each worktree).

| Suite | Base 49ae3efe | After (aece570 code) | Note |
|---|---|---|---|
| PR59 harness | 488 / 0 (1 skip) | 488 / 0 (1 skip) | identical, sections identical |
| Issue #42 (`automatic_passage_reliability`) | 305 / 0 | 305 / 0 | the hold-at-305/0 requirement is met |
| Stock 25 suites | 1607 / 0 | 1607 / 0 | |
| `canal_geometry` | 173 / 0 | 173 / 0 | |
| `pm_canal_left_passage` | 56 / 0 | 56 / 0 | |
| `pm_staged_stair_cinematic` | 50 / 0 | 50 / 0 | |
| Staged stair harness (flag on, reduced) | 32 / 0, 6 / 0 | 32 / 0, 6 / 0 | |
| `verify_baseline.py` | 0 failures | 0 failures | |
| `cinematic_transitions` with `--pm-staged-stair` (diagnostic) | 359 / 9 | 359 / 9 | PRE-EXISTING, stock stair timing assertions written for 0.65 s |
| `verify_tr05_preservation.py` | 1 failure | 1 failure | PRE-EXISTING ("expansion build_room PR37 function exact", Level hook from PR58) |
| **`tests/ld05_boundaries.gd` (new)** | not applicable | **156 / 0** | roof present in 21 rooms; platform lists identical; 87 real-key wall chains (floor and every ledge touching a wall) all stop at feet y 116 under the roof; gatehouse face 116.1 (was -164.6); R13 right wall; three jump + double jump + dash probes and two full double jumps (R13 (324,438) bumps the roof at feet y 116.1, was -14.6 above the room; R17 (1626,418) bumps at 116.1, was -34.6); Canal constants and hallway envelope; real key A through the Canal door still triggers once; crawlspace closed; R8 door supported 96 of 96 and walkable both ways; door seating exactly R6 and R9; wall jumping still gains height; `player.gd` sha; the three switches |

Regressions versus 49ae3efe: none. Pre-existing failures are listed above and are unchanged (identical failing lines). A first run of this branch showed two regressions (R8 PR33 signature test, R14 tail check in `expansion_traversal`); both were caused by my first design (editing the R8 platform and adding the roof after the legacy bodies), fixed before the commit that is reported here, and the final numbers above are from the fixed code.

Probe totals after the change (`tools/ld05/room_probe.gd`, 21 rooms): 91 wall and face chains, 0 escaped (68 before); jump + double jump probes that end above the room top: 0 (4 probes on 2 ledges before). All 9 near-wall high ledges probed with a full double jump now bump the roof at feet y 116.

Software-GL graphical subset (`run_qa.py --rendered`, sections start, issue42, reduced): 67 / 0 on the new code (start 10, issue42 49, reduced 8), adapter llvmpipe (LLVM 20.1.2), X11 under xvfb, 688 s; log in the QA output, not committed. This is software GL on Linux, not a GPU.

## 5. Captures (software GL, opened and inspected by me)

`docs/ld05/captures/*.jpg`, each a before (left) and after (right) pair, produced by `tools/ld05/capture.gd` (areas) and `capture_chain.gd` (real-key chains, camera allowed above the room): R13 gatehouse face chain (before: Kaze above the room in the void; after: under the roof inside the room), R13 right wall, R16 left wall, R1 right wall, R13 gatehouse top, R13 footing, R13 Canal door unchanged, R8 door shelf, R6 and R9 door seating, roof course in R1, R9, R17, scenery restyle in R13, R15, R17, R19, and four geometry-overlay overviews. Binary SHA256 of the committed captures is in `docs/ld05/captures/MANIFEST.sha256`. Software GL is not a GPU and not macOS graphics. Nothing here is creative acceptance.

## 6. Remaining residuals

1. 38 wall-side walk-through exits keep 58 px (left) or 98 px (right) of floor beyond the drawn door. The Canal recipe (back pier) closes it but moves the stop-at-the-wall point and would change the #42 staging assumptions (some tests stage Kaze at x about 14), so it was not applied.
2. The bare wall column between the highest ledge and the roof (284 to 664 px depending on the room) is reachable by sustained wall jumps. It is now bounded and harmless but still has no purpose.
3. 19 ledges (R11, R13, R14, R15, R16, R17, R19, R20, all with tops above y=566) now bump the roof on a full double jump; a single jump never does. Feel difference only at the very top shelves (the R14 stair shelf (1300,480) is one of them, relevant to Transition's stair).
4. R6 and R9 shelves remain 20 px off their doors physically (the door is only drawn on the surface). Moving the shelves means editing PR37-guarded `route_extension.gd` or approved R6 geometry.
5. Kunai gate bodies are bypassable by wall jumps. Progression flags still hold; if the creator wants hard barriers the recipe is a floor-to-roof shutter now that a roof exists.
6. R9 gate (2110,810) and R10 gate (2110,810) sit where a static model finds ordinary jump routes around them (R10's gate stands on the last 15 px of its ledge). Not verified by play; likely cosmetic.
7. R14 solid blocks, R17 cable shafts and other scenery were reviewed in captures only; no change.

## 7. Creator decisions

1. Accept the roof course in every room, including the original eight (R0 to R7)? It adds a 56 px visible course at the top edge and does not edit any approved platform. To keep R0 to R7 open set `RoomBoundary.ORIGINAL_ROOMS_ENABLED = false`; to remove it everywhere set `ROOF_ENABLED = false` (or launch with `--ld05-open-top`). The alternative is local wall caps, which I rejected because a cap's outer face is itself climbable from nearby shelves (R13 shelf (300,440), R17 shelf (1200,420)).
2. Do the 38 past-door strips matter enough to move the wall-stop point (residual 1)?
3. Should the R6 and R9 shelves be edited in the guarded files so door and floor agree physically (residual 4)?
4. Should kunai gates become hard shutters (residual 5)?
5. Route guidance (lamps, markers along the main route) was not added: it would be new art direction.

## 8. Limits

One scripted bot per probe; not an exhaustive jump-arc proof. The ledge-height classes and gate-route statements use a static kinematic model and are labelled as such. No human playtest, no Windows or macOS, no gamepad. R13 upper routes were not hand played. Software GL only. The R6 to R7 trigger corridor (feet y 1000..1098) does not contain Kaze standing on the 1110 shelf; the existing supported-exit recovery covers it and #42 passes, unchanged by this work.

## 9. Files

New: `scripts/room_boundary.gd`, `tests/ld05_boundaries.gd`, `tools/ld05/` (room_probe, gate_probe, build_audit.py, capture, capture_chain, overlay, freeze_additions, content.py), `docs/ld05/` (ROOM_AUDIT.md, room_audit.json, raw probe JSON, base_platforms_49ae3efe.json, ld05_frozen_shapes.json, captures). Modified: `scripts/world.gd`, `scripts/room_presentation.gd`, `scripts/world_expansion.gd`.

## 10. Commits

- aece570e2b8efdd94a1576e4e60cbd965fd9b356: code, tests, probe tools.
- ea9d7043564cda379f4c88a5974ef229300289ec: audit, frozen shapes, chain capture tool.
- Final report and captures commit: see `gh api repos/cappy2yappy/momentum-fractured/commits/feature/ld05-intentional-world-boundaries` (the head named in the delivery message).
