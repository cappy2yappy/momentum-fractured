# LEVEL PM pilot report: Canal-left exit enclosure (Room 13 -> Room 0)

Role: Level Masta (ORDER 2). Branch `feature/pm-pilot-canal-geometry`, base PR51 head `baedd6786ad4bee2123ea872b437bbb98e6d2721` (fix/tr06-automatic-passage). Head SHA is reported in the PR and in the coordinator reply (a report cannot contain its own commit hash). Draft PR only, nothing merged.
Model and environment: Claude Sonnet 5.5, Godot 4.6.1 stable Linux x86_64, headless (physics) and xvfb software GL (llvmpipe, OpenGL 3, 1280x720) for captures, shared cloud container with other agents running. Not a Windows run, not a human playtest.

## Contract
`docs/pm_pilot/CANAL_CONTRACT.md` (copy in `/home/claude/pilot_shared/CANAL_CONTRACT.md`). Published early as v1. Numbers have NOT changed. Only an additive note was added later (stand-in drawing description, known residual about the exterior face).

## What changed (code)
- `scripts/canal_gatehouse.gd` (new): two solid rectangles, Rect(0,1020,72,180) back pier and Rect(0,0,296,1020) gatehouse mass whose underside is the hallway ceiling y=1020; procedural stand-in art using the approved blue masonry tile.
- `scripts/world_expansion.gd`: preload, `build()` call for room 13, legacy silhouette at x=140 suppressed where it overlaps the mass (3 lines).
- `scripts/world.gd`: draw the gatehouse before the platform surfaces and skip the generic surface draw for its two rects (2 lines).
- Not touched: player.gd, cinematic_transitions.gd, graph/EDGES, SHELVES, anchors, gates, saves, R18.
Result: door aperture (72,1068,96,132) = the drawn door (draw_exit unchanged) = where Kaze's body is when the trigger line x=120 is crossed; support pad top y=1200 spans it; leftmost reachable x is 86 (pier face); ceiling 1020 gives 180 px clearance (3x Kaze); no invisible barriers, no blanket ceiling; the mass ends at x=296 so every listed shelf (including 300,440) and the anchor (900,690) are untouched.

## Tests actually executed (Linux headless, disposable profiles)
| Suite | Baseline PR51 | This branch |
|---|---|---|
| `tools/run_tr06_qa.py` (real keys) | 305 pass / 0 fail | 305 pass / 0 fail |
| `tools/run_tr05_qa.py` (25 suites) | 1607 / 0 | 1607 / 0 |
| `tools/run_tr04_qa.py` (30) | 1059 / 68 (pre-existing legacy-mode failures, identical rows) | 1059 / 68, every suite row identical |
| `tools/run_ld03_qa.py` (31) | 1141 / 70 (pre-existing, identical rows) | 1141 / 70, every suite row identical |
| `tools/run_canal_qa.py` (new `tests/canal_geometry.gd`) | 153 pass / 20 FAIL (the 20 are the new geometry/containment assertions, as expected on the old geometry) | 173 pass / 0 fail |
Two existing tests encoded the old R13 left geometry and were updated narrowly: `tests/level_geometry.gd` (stopped-capsule probes now use the pier face, x=90, not the old wall) and `tests/audit_intentional_space.gd` (R13 must retain every PR33 rectangle and add exactly the 2 gatehouse rectangles, same pattern the file already uses for R14). Logs: `docs/pm_pilot/logs/`.

New test coverage (real InputEventKey only; fixtures set only room, abilities and the starting feet position): geometry facts; walk, double-tap sprint, dash, 8 jump timings, ceiling-bump jump, double jump, fall from the first shelf, fall from a route stair, jump up from the floor beside and under the pad; stop then resume; reversal; reverse before the door; aborted jump then re-approach; held direction through the door and beyond; 3 cycles R0 -(E)-> R13 -(walk)-> R0 with held-E and stationary-arrival checks; Stride I pickup by walking then exit with walk, sprint and sprint+dash; wall-jump containment bots inside the hall (eight start/direction combinations), from the first shelf and the pad cavity; route leg bot over the 12 ordered shelves (same bot, same result before and after: 9/12 reached, the 3 misses are bot limits far from the tower); grapple anchor tether from shelf (720,940).
Containment result: baseline wall-jump from the exit pad reaches y -138 and leaves the world (x -639); with the gatehouse nothing inside the hall gets above feet y 1080 (the lintel head bump).

## Captures (graphical, software GL, Linux; NOT creator acceptance)
`docs/pm_pilot/level/before` and `after`: arrival, door threshold, mouth, ceiling bump, wide overview, and contract overlays (yellow aperture, red trigger line, cyan ceiling). I inspected them: door, trigger line and aperture coincide, and the hall reads as a masonry gatehouse. The art is procedural stand-in using the existing approved masonry tile; it is not final art.

## Known limitations (honest)
1. **Residual exterior climb.** The gatehouse's outer face (x=296) is an ordinary wall, and every room in this game has no top, so a determined player can still chain wall jumps up that face (measured: tops out at about y -137 to -177), walk off the roof and out of the world, after which the existing fall recovery returns Kaze to (230,1198), inside the hallway. This is the same game-wide property as every boundary wall; closing it needs a whole-room top bound or a wall-jump limit (blanket ceiling or movement change, both excluded). Decision needed from the creator. It no longer starts at the mandatory exit.
2. Other 38 wall-side walk-through exits keep the old open column: see `docs/pm_pilot/EXIT_AUDIT.md` (24 of 39 reach above the room, 15 leave the world). Report only, not implemented.
3. Item collection: Stride I (450,440) is on the route; the test collects it by real walking from the shelf end and then exits, but does not climb the whole route down by input (route legs are tested separately).
4. The route-leg bot is a heuristic (9/12); it proves equality before and after, not that every leg is human-reachable.
5. Staged ~2-3 s transition presentation and Persona-style wipe are not part of this change; Transition owns `cinematic_transitions.gd`.
6. No Windows/macOS build, no human playtest, no hosted CI.

## LD-04 R18 status (read only, separate)
- Issue #43 (AUD-CLAUDE-02, open): replace generic expansion slabs with an authored R18 pilot, step 1 is a behaviour-preserving freeze of today's generated slabs; Owner Level Masta Masta.
- PR #47 (ART-06, draft, head 4b11bef0, last push 2026-10-17): R18 modular environment art registered to today's runtime colliders including the 10 generated slabs (tagged `interim_catwalk`), data-driven by `assets/art06/r18/r18_layout.json`; states "Level has not yet published an R18 redesign"; validator 432/0, native integrated 9/0; creator style acceptance, export include_filter, other platforms pending.
- PR #49 (LD-TOOLS-01, draft, head 00d74c36, last push 2026-10-18): disconnected editable R18 layout scene under `tools/ld_tools_01` (frozen 18 R18 colliders, solid/one-way/disabled, props, optional slope, ladder marker), reversible default-off migration plan, 95 pilot checks and 25 regression suites reported; creator workflow comfort, real-player route QA and adoption pending.
- This branch contains no R18 change. The audit notes one R18-adjacent item: the R8 -> R18 door at (1090,920) overhangs its shelf by 28 px.

## Next action
Creator/PM: accept or redirect the gatehouse silhouette and decide on the room-top question (limitation 1). Art Mane replaces the stand-in with the layers in contract section 6. Transition keeps the threshold fixed per section 7. If the enclosure recipe is wanted at other exits, repeat per EXIT_AUDIT.
