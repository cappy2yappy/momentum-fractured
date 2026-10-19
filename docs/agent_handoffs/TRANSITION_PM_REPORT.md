# TRANSITION PM report (TRANSITION MASTA, ORDER 1)

- Branch: `feature/pm-pilot-transitions`. Draft PR [#57](https://github.com/cappy2yappy/momentum-fractured/pull/57), base `fix/tr06-automatic-passage`.
- Base: PR51 head `baedd6786ad4bee2123ea872b437bbb98e6d2721` (TR06 #42 fix, carried forward unchanged, not duplicated).
- Implementation commit: `65328a2896b8e85339aab9764afa089e6ae94af2`; logs commit `319ef3032f95dc048db13a0f356fa92899d4681e`. This report and the final evidence come in a later commit; the coordinator reply and `gh api .../commits/feature/pm-pilot-transitions` give the exact final head.
- Model: Claude Opus 5.5 (`claude-opus-5-5`). Environment: Linux cloud container, official Godot `4.6.1.stable.official.14d19694e` Linux x86_64. Graphics: xvfb with Mesa llvmpipe (software GL), `gl_compatibility` / `opengl3`. Headless otherwise. No Windows, macOS, GPU, gamepad or human run.

## PR51 verification (before any edit)

| Check at baedd678 | Result |
| --- | --- |
| `tools/run_tr06_qa.py` headless | 305 pass / 0 fail, exit 0 |
| `tools/run_tr06_qa.py --rendered` under xvfb | timed out at the runner's 300 s limit (exit 124, 55 pass / 0 fail so far); software GL is too slow for that limit |
| Same rendered suite run directly, 3000 s limit | 305 pass / 0 fail, exit 0 (`evidence/pr51_rendered_xvfb_automatic_passage_reliability.log.txt`) |
| `tools/run_tr05_qa.py` | 25 suites / 1,607 passes, 0 fail, 0 script errors |
| `tools/verify_baseline.py`, `tools/verify_tr05_preservation.py` | 0 failures each |

The older verifiers (`verify_tr04_preservation` with 3, `verify_ld03_preservation` with 5, `verify_art04_integration` with 1) already fail at PR51 because they pin superseded bases. `verify_tr03_preservation` cannot resolve its base commit. These are recorded, not caused by this work.

## Delivered

Runtime (presentation only):
- `scripts/transition_pilot_data.gd` (new): the ONE data block. `CANAL_LEFT` holds the CANAL_CONTRACT v1 numbers. `CANAL_ART`, `CANAL_FRONT` and `WIPE_ART` are Art Mane paths bound per ART_INTEGRATION.md. `STAGED_STAIR` holds the pair, timings, measured treads, zoom, flag and watchdog.
- `scripts/staged_stair_cinematic.gd` (new): the R14 to R17 staged sequence and its CanvasLayer composition.
- `scripts/cinematic_transitions.gd`:
  - hooks: `intercept`, `staged.tick` in `present`, `room_loaded`, `cancel`, `arrived`, F6 and the camera capture guard
  - `draw_canal_door` on the contract rectangles
  - L4 corbel `_draw`
  - `update()`, `endpoints()`, `supported_exit()`, `arrival_position()`, `passage_allowed()` and `policy()` unchanged
- `scripts/world.gd`: one line in `request_room`. All TR05-protected functions, `transition = 0.65` and the hidden swap are byte-identical. `hud.gd`, `player.gd`, saves, graph, gates and movement are untouched.

Tests and tools (new; no existing test edited):
- `tests/pm_staged_stair_cinematic.gd`
- `tests/pm_canal_left_passage.gd`
- `tests/capture_pm_transition.gd`
- `tools/run_pm_transition_qa.py`

Docs:
- `docs/pm_pilot/transition/README.md`
- `docs/pm_pilot/transition/DEMO_ARGS.md`, also copied to `/home/claude/pilot_shared/TRANSITION_DEMO_ARGS.md`
- `docs/pm_pilot/transition/fixtures/*.json`
- `docs/pm_pilot/transition/captures/`
- `docs/pm_pilot/transition/evidence/`

Assets: none added or modified. Approved assets used: the active `assets/kaze/cleaned` idle and run strips, the existing ART-04 `stair_up_key` and `stair_flight_right.png` (tread heights measured from it). No LEVEL or ART file is committed here.

## Inputs consumed

- `CANAL_CONTRACT.md` v1 (LEVEL, published 00:24): adopted unchanged. No threshold change was requested.
- `ART_INTEGRATION.md`: layer order and positions bound by path. The files sit uncommitted in the ART worktree, so they appear only after the coordinator combines branches.
- `STORY_GUIDANCE.md`: chose the R14 to R17 stair. The R13/R14 doorway stays lateral. No altitude cues.
- Combination needed: LEVEL `scripts/canal_gatehouse.gd` with its `world.gd` and `world_expansion.gd` hooks, plus ART `assets/pm_pilot/canal/*` and `assets/pm_pilot/wipe/*`.
  - On a local scratch copy, LEVEL's `world.gd` diff (in `_draw`) applied cleanly beside the `request_room` line.
  - Inputs hashed in `captures/combination_preview/INPUTS.sha256`.

## Tests actually executed (final code, Linux headless unless stated)

| Suite | Result |
| --- | --- |
| `pm_staged_stair_cinematic` (`--test --pm-staged-stair`) | 50 / 0. Normal 2.35 s (2.38 s from the E key frame), reduced 0.95 s, F6 mid-enter completes in under 1.4 s (asserted). Pause, death and rebuild were each tried in enter, load and arrive; all 9 restore control. |
| `pm_canal_left_passage`, contract stub geometry | 55 / 0 |
| `pm_canal_left_passage`, local scratch combination with LEVEL `canal_gatehouse.gd` | 56 / 0 (adds the constants-equality check) |
| `automatic_passage_reliability` (issue #42), this branch | 305 / 0, same counts as PR51 |
| Same, on the scratch combination | 305 / 0 |
| Same, rendered under xvfb at this branch | see "Rendered" below |
| `run_tr05_qa.py` stock suites, no pilot flag | 25 suites / 1,607 / 0 / 0 script errors, identical to PR51 |
| `verify_baseline.py`, `verify_tr05_preservation.py` | 0 / 0 |
| Diagnostic: stock `cinematic_transitions.gd` WITH `--pm-staged-stair` | 368 checks, 9 failures. All 9 are the R14 to R17 stair timing assertions written for the 0.65 s presentation (E sets `transition==0.65` at once; camera and zoom checked by tick 43). This is why the pilot is opt-in. Making it default needs creator acceptance and a reviewed update of those 9 assertions. |

Rendered: `automatic_passage_reliability.gd` at implementation commit 65328a2 under xvfb (Mesa llvmpipe, opengl3, 1280x720, run directly with a 3500 s limit because the runner 300 s limit is too short for software GL): 305 / 0, exit 0, same as the PR51 rendered run (`evidence/head_rendered_xvfb_automatic_passage_reliability.log.txt`). The staged stair cinematic and Canal-left suites were run headless; the rendered evidence for them is the capture set.

Logs: `docs/pm_pilot/transition/evidence/` (`*.log.txt` and `results.json`).

Canal-left jump note: real-key jumps with offsets 10 to 40 px clear the airborne corridor, stop against the LEVEL back pier at feet x 86 (inside the aperture, past the trigger line), land on the pad, and then fire through the PR51 supported recovery. That is still inside the visible opening.

## Captures

`docs/pm_pilot/transition/captures/branch/` (this branch: procedural door, LEVEL solids stubbed by the capture script, procedural wipe) and `captures/combination_preview/` (local scratch combination with the uncommitted LEVEL diff and ART files). Each set has 26 frames plus contact sheets and `captures.json` (room, feet, phase, timeline, zoom).

They are JPEG derivatives of 1280x720 PNGs from Mesa llvmpipe software GL via `tests/capture_pm_transition.gd`. Seeded fixtures and real key events, not human footage.

I inspected every frame:
- Kaze stays on the measured treads.
- The wipe covers the screen at the hidden swap.
- The plate and labels are legible.
- At the trigger, Kaze is inside the aperture.
- The hallway arrival is under the lintel.
- The locked label shows.

Known visual nits:
- The reduced-mode plate overlaps the inherited embodied "STAIR · ASCEND" box.
- The destination plate covers the "LOCAL STAIR · E" cue during enter.
- The R13 "CANAL HAVEN - WALK THROUGH" label is drawn by `world_expansion.gd` over the gatehouse face.

## Demo entry

`DEMO_ARGS.md`. Canal-left: `-- "--tr05-save=<abs>/PM-Canal-Left.json"`. Stair: `-- --pm-staged-stair "--tr05-save=<abs>/PM-Stair-Cinematic.json"`, plus optional `--tr05-reduced-motion`.

Both were launched from source under xvfb with `--write-movie` (30 frames) and started in the right room and position. The Canal fixture was then moved onto the shelf top (330,1158), because (330,1198) lies inside the one-way shelf. No exported build was made.

## Limitations

- Creator visual acceptance is pending.
- No Windows or macOS native run, GPU, gamepad, human playtest or performance measurement.
- Full gait, arrival and outward cycles are still missing. The held key is labelled, not animated.
- Pause during the enter phase aborts in place rather than resuming.
- The reverse R17 to R14 stair keeps TR05 staging.
- The Canal-left door art in this branch is a procedural stand-in.
- The tests stub LEVEL geometry when it is not combined; the log says so.

## Blockers

None for this branch. The coordinator needs to combine LEVEL `feature/pm-pilot-canal-geometry` and the ART branch onto a candidate branch to see the final art in game. LEVEL and ART were still uncommitted when I read them.

## Next action

1. Coordinator: build a combination candidate, then rerun `tools/run_pm_transition_qa.py` and `tools/run_tr05_qa.py` on it.
2. Build Shogun: wrap the DEMO_ARGS launchers.
3. Creator: review the stair pilot. If accepted, make it default and update the 9 stock stair timing assertions in a reviewed change.
