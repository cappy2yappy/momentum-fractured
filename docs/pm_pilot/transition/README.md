# TRANSITION pilot: Canal-left passage and staged stair cinematic

Branch `feature/pm-pilot-transitions`, base PR51 `baedd6786ad4bee2123ea872b437bbb98e6d2721` (TR06 doorway reliability fix, carried forward unchanged). Draft only. Creator visual acceptance pending.

## A. Canal-left automatic passage (R13 (120,1200) to R0)

- Still an ordinary automatic side passage: no E, same TR05/TR06 crossing, arming, corridor, recovery, cooldown, gate and tether logic. `update()`, `endpoints()`, `supported_exit()` and `arrival_position()` are untouched (contract section 7).
- All Canal numbers live in ONE data block: `scripts/transition_pilot_data.gd` `CANAL_LEFT`, set from `/home/claude/pilot_shared/CANAL_CONTRACT.md` v1 (aperture 72,1068,96,132; frame 40,1032,160,168; trigger x 120; corridor 1110..1208; arm x 136; arrival 184,1198; LEVEL pier/mass for test stubs only).
- `draw_canal_door()` draws exactly those rectangles, with a tick at the real trigger line. Kaze's 28x60 capsule at the trigger is fully inside the visible opening (tested).
- Art Mane layers (`ART_INTEGRATION.md`, `assets/pm_pilot/canal/*.png`, orders 0..6 plus the L4 corbel above Kaze from the z 3 cinematic node) are bound by path and drawn only when present. In this branch they are absent, so the procedural stand-in on the same rectangles is drawn. Locked state tints interior and leaf `c48e78`. The hall back wall is drawn after the world platforms, so the overlapped R13 shelf (200,1160) is repainted on top.
- Geometry and art arrive by a later combination commit; nothing from the LEVEL or ART branches is committed here.

## B. Staged stair cinematic, R14 Bellroof Walk to R17 Counterweight Spire

Chosen per `STORY_GUIDANCE.md` (both ends have canon; existing PILOTS 14:17). Opt-in with `--pm-staged-stair` so stock suites and default play are unchanged.

| Phase | Time | What happens |
| --- | --- | --- |
| enter | 0.85 s | E press (unchanged expansion E path and gate). Physics frozen, body not moved. Render proxy: approved run strip to the stair contact (0.25 s), then the approved held ART-04 `stair_up_key` placed on three treads measured from `stair_flight_right.png`. Camera eases to 1.35x. Letterbox bars, destination plate, wipe enters. |
| load | 0.65 s | The inherited world loader, clock and hidden swap untouched (`transition = 0.65`, swap below 0.32). Wipe covers the screen at the swap. |
| arrive | 0.85 s | Physics held after the loader; approved idle cycle at the unchanged reciprocal arrival (1680,1298); camera eases back; wipe exits. Then control returns. |

Total 2.35 s (tested range 2 to 3 s). Reduced motion (`--tr05-reduced-motion` or F6): 0.15 + 0.65 + 0.15 = 0.95 s, no zoom, no proxy travel, one static plate. F6 mid-sequence shortens what remains and restores framing at once. `--tr05-plain` and `--tr05-legacy` bypass staging.

Wipe and composition follow the established TR02 direction (Kaze-original angled indigo/rose wind-cloth panels, pale thread lines, destination plate; no Persona assets). It uses the Art Mane wipe kit (`assets/pm_pilot/wipe/`) when combined, else procedural bands on the same rows and timing, mirrored so the wipe travels with Kaze.

Honest labels in the lower bar: `APPROACH · APPROVED RUN CYCLE`, `ASCENT · HELD ART-04 KEY ON 3 TREADS · FULL GAIT PENDING`, `ARRIVAL KEY PENDING · APPROVED IDLE CYCLE`. The held key is not presented as finished animation.

Control always returns: completion; pause (enter: abort in place, load: inherited loader outcome, arrive: immediate); death/respawn; any room rebuild; F6; a 4.0 s watchdog; a rejected request. Repeated E during the sequence is swallowed (no double trigger); E held through arrival does not bounce. R17 to R14 (reverse) keeps the inherited TR05 0.65 s presentation.

Code: `scripts/staged_stair_cinematic.gd` (new), hooks in `scripts/cinematic_transitions.gd`, one line in `world.request_room` (`cinematic_transitions.intercept`). `hud.gd`, `player.gd`, saves, graph, gates and all TR05-protected functions are byte-identical.

## Tests

`python3 tools/run_pm_transition_qa.py --godot <godot>` runs the new suites and the unchanged TR06 #42 suite; `python3 tools/run_tr05_qa.py --godot <godot>` runs stock suites. Results are in the PM report.

- `tests/pm_staged_stair_cinematic.gd` (needs `-- --test --pm-staged-stair`): 2 to 3 s completion, phase order, single request, body never driven, camera/sprite restore, held and repeated E, reduced motion, F6, pause/death/rebuild in each phase, watchdog, unstaged entrances unchanged.
- `tests/pm_canal_left_passage.gd`: contract and runtime agreement (endpoint, arrival, trigger x, corridor top/bottom, arming), real-key walk/sprint/dash/jump x5, idle with E held inside the opening, inward walk, vertical jump under the ceiling, stop and reverse, released airborne approach then outward reapproach, R0 to R13 hallway arrival capsule clearance and no loop. When `scripts/canal_gatehouse.gd` is absent the LEVEL pier and mass are stubbed from the contract rectangles via `world.add_platform`; the log prints which geometry was used.
- `tests/capture_pm_transition.gd`: rendered frame capture (xvfb, gl_compatibility).

## Captures

`captures/branch/`: this branch as committed (procedural door stand-in, LEVEL geometry stubbed by the capture script, procedural wipe). `captures/combination_preview/`: a LOCAL scratch combination of this branch plus the uncommitted LEVEL worktree diff and the uncommitted ART files (hashes in `INPUTS.sha256`), never committed anywhere. JPEG derivatives of 1280x720 PNGs rendered with Mesa llvmpipe software GL on Linux. Seeded fixtures and real key events; not human gameplay footage. `SHEET_*.jpg` are contact sheets.

Demo arguments: [DEMO_ARGS.md](DEMO_ARGS.md).
