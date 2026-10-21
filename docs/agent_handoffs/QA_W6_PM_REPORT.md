# QA_W6 PM report: independent QA gate on candidate/wave3-targeted-3 (candidate 3)

Tested SHA: `c2170032d08ea55268313e0020676c743251deab` (tree `56219e5b`, branch `candidate/wave3-targeted-3`, draft PR #77). It is candidate 2 (`b680d66c`) plus GN-06 (dash across the R6 exit arms the R7 transition). Fresh detached worktree, every suite in its own empty disposable profile. Thresholds unchanged. No creative acceptance is claimed. Run folder: `docs/wave3/qa/runs/w6-targeted3-c217003/` (suite logs in `suites/`, open-top logs in `open_top/`). Candidate 2 results are in QA_W5_PM_REPORT.md.

Command: `python3 tools/pm_pilot_qa/run_w3.py --sha c2170032d08ea55268313e0020676c743251deab --label w6-targeted3-c217003 --rendered`

## Recommendation: NOT READY on the automated gates, narrowed to presentation and route-review items

The GN-06 defect is fixed and no new failure appeared. What still fails is the same short list as candidate 2. All of it needs a creator or level-owner decision rather than a code regression. The overall verdict is ACCEPTANCE_FAILURES with no hard regressions.

## Delta against the c2c3d958 run

| | c2c3d958 run | c2170032 (candidate 3) | delta |
| --- | --- | --- | --- |
| Wave 3 checks pass / fail / skip | 104 / 9 / 6 | 162 / 8 / 6 | +58 pass (57 new stress checks, ascent animation), one fewer failure |
| Core harness | 460 / 0 | 460 / 0 | none |
| Issue #42 author suite | 305 / 0 | 305 / 0 | none |
| Stock suites | 25 suites, 1,617, 0 failed | same | none |
| Preservation guard | exit 1 (build_room) | exit 0, 0 failures | fixed |
| `verify_baseline.py` | 0 failures | 0 failures | none |
| Ascent true animation (gate 90%) | FAIL 88% | PASS 100% | fixed |
| Descent true animation | PASS 100% | PASS 100% | none |
| Stair letterbox (gate 2% added) | FAIL 3.9% | FAIL 7.8% | see note |
| 928 escape probes | 0 | 0 | none |
| Route pairs lost vs PR51 / PR61 | 5 / 3 | 5 / 3 | same pairs |
| ART-08 strip checks | 162 of 163 | 162 of 163 | same one failure (`door_turn_to_side` PNG missing) |
| GN-06 known-red reproducer (`ld07_dash_regression`) | red, 1 of 2 failed (candidate 2) | green, 2 / 0 | fixed |

Versus candidate 2 (`b680d66c`) the QA matrix result is identical (162 / 8 / 6): GN-06 changed no Wave 3 acceptance outcome.

## GN-06 (new in this candidate)

* `gn06_dash_offsets.gd` at fixed 30, 60 and 144 fps: 5 checks, 0 failures at each rate. Dash across the R6 sill requests R7 once and lands supported (105 of 105 offsets and timings); every automatic exit opens on a dash approach (156 of 156); plain walk still requests once; standing inward of the sill or walking away never requests.
* `ld07_dash_regression.gd`, the known GN-06 reproducer, now passes 2 of 2 (it was RED on candidate 2 with "dash across R6 sill should request R7 automatically").
* The change is small and the timelines did not move (below).

## Durations (Engine.get_physics_frames, headless; same hook across SHAs)

| Sequence | 869a3aa | c2c3d958 | b680d66c | c2170032 |
| --- | --- | --- | --- | --- |
| Canal OUT (R13 to R0) | 132 | 132 | 132 | 132 |
| Canal IN (R0 to R13) | 144 | 144 | 144 | 144 |
| Stair ascent | 174 | 174 | 195 | 195 |
| Stair descent | 174 | 174 | 174 | 174 |

Canal Return/OUT, Canal IN and the descent are unchanged from 869a3aa. The ascent is 195 frames, deliberately longer than 869a3aa. The rendered run agrees with headless on physics frames (195, 174; Canal within one frame), so the 0.12 s gap in QA_W4 was a measurement artifact (rendered versus headless loop ticks), not a candidate difference.

## Stair gates (thresholds unchanged)

* True animation: ascent PASS (100% of 7 moving windows, 21 distinct poses), descent PASS (100% of 6 windows, 16 poses). Gate is 90%.
* Letterbox: FAIL, 7.8% added bars on both directions (gate 2%). The top developer label is hidden, but the dark top and bottom bars remain at the same geometry as before; the earlier 3.9% understated them because the label text broke the detector's uniform run. Stage-only coverage is 100% and Kaze reaches 65% of viewport height. Creator decision needed on whether these bars are acceptable; QA does not lower the gate.

## Geometry and level suites (clean profiles)

| Suite | Result |
| --- | --- |
| ld05_boundaries, standalone | 172 / 0 (expected 172) |
| tools/run_ld07_qa.py default list, 11 suites | all exit 0, 0 failures, 0 script errors: ld07_ground 154, ld05_boundaries 172, canal_geometry 173, automatic_passage_reliability 305, pm_canal_left_passage 56, audit_intentional_space 21, level_geometry 78, save_compatibility 11, expansion_gates_save 17, expansion_traversal 125, cinematic_transitions 378 |
| ld07_ground (recovered LD-07) | 154 / 0, runs |
| 928 real-input escape probes | 0 escapes (baselines: PR51 126, PR61 131) |
| ROUTES comparisons | FAIL, same pairs as candidate 2: vs PR51 R13 1>0 base, R13 2>0 full, R13 2>0 base, R15 0>1 base, R16 2>0 full; vs PR61 R13 2>0 full, R15 0>1 base, R16 2>0 full. R13 2>0 full existed on the controls only through an escape; R16 disappears with longer probes; R15 base-kit remains inconclusive and needs Level to confirm R15 is not entered without Windstep. |

## Transition and cinematic suites

native_cinematic_transitions (blocking) 54 / 0. tr08_embodied_cinematics 226 / 0. tr08_canal_hang_regression 53 / 0. tr08_canal_hang_probe 111 runs: 110 completed, 1 in_r13 (release_at20, A released before the x=120 trigger, control intact, identical on c2c3d958 and b680d66c, not a hang). Canal Doorway stress hook 57 / 0 (both directions, three offsets, walk and run, repeats, mashing, pause at 5, 20, 45, 70, 100 ticks, round trips, R6 to R7 and R7 to R6 walk-throughs). Issue #42 305 / 0. Reduced motion 30 / 0. ST-04 38 pass, 0 failures. Movement checksum (movement_momentum) 53 / 0.

## Roof-on and --ld05-open-top

* Roof on (default): the combined hook finds the roof solids in R14 (ROOF-PRESENT pass), all 58 endpoints and sequences clear of boundary solids, 0 overlap ticks.
* `--ld05-open-top`: the roof is gone (ROOF-PRESENT reports 0 solids, the expected failure), and the stair and doorway hooks give 48 and 50 checks with 0 failures and the same physics frames (195, 174, 132, 144).
* Neither mode changes which cinematic is selected: the same clip order, request counts and durations occur in both. Roof visibility over the cinematic is still SKIP (the roof band is in camera view on some stair ticks under the opaque stage) and needs a human to read the captures.

## Remaining failures and open items

1. Stair letterbox 7.8% vs 2% gate (both directions): creator decision.
2. Route comparisons vs PR51 and PR61 (R15 base-kit pair inconclusive; Level to confirm).
3. `door_turn_to_side` PNG missing from the art manifest (the only art check failure).
4. Canal doorway full-screen, bars and Kaze-scale checks fail in the doorway hook (informational; the Canal sequences are a world-camera presentation).
5. Roof visibility over the cinematics: human capture review.

## Categories

Automated headless: core, #42, stock, stress, reach, art strip checks, candidate and level suites above. Software GL: presentation, letterbox, scale, captures. Creator acceptance: none done and none claimed; the bars, the art quality of the stair clips and the roof overlap are creator items. Untested: Windows, macOS, gamepad, performance, watchdog timeout (cannot be forced from outside).

Environment: Godot 4.6.1.stable, Linux cloud VM, xvfb software GL. Model: Claude Sonnet 5.5.
