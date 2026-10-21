# QA_W3 PM report: independent QA, ORDER 4, Wave 3 (Phase A plus candidate evaluation)

Branch `test/wave3-independent-qa`, based on PR59 head `c44f2b8163867e211f7d2297d6dcfad26c36abe7` (draft PR base `test/pm-pilot-regressions`). The head SHA of this increment is in the push verification line of the PR description (a report cannot contain its own hash). Test-only: nothing under `scripts/`, `assets/` or `project.godot` changed, and no implementation worktree was touched.

## Delivered

| File | Purpose |
| --- | --- |
| `tools/pm_pilot_qa/run_w3.py` | One command to evaluate any pushed SHA (exact-SHA detached worktree, headless plus software GL, JSON, captures). |
| `tools/pm_pilot_qa/true_animation.py` | Translation and scale invariant pose analyzer for strips and in-engine playback logs, with built-in known-good and known-bad controls. |
| `tools/pm_pilot_qa/art08_check.py` | ART-08 manifest and strip verification (SKIPs until a manifest exists). |
| `tools/pm_pilot_qa/hooks/hook_w3_stair.gd`, `hook_w3_doorway.gd`, `hook_w3_reach.gd`, `hook_w3_selftest.gd`, `w3_lib.gd` | Candidate-agnostic observer hooks (real key input; observe tree, camera, physics, pixels). |
| `tools/pm_pilot_qa/hooks/w3_ground_truth.json`, `w3_reach_truth_pr51.json`, `w3_reach_truth_c49.json` | Arrival ground truth and reach truth from the controls. |
| `tools/pm_pilot_qa/poll_w3_candidates.sh` | Polls origin for candidate pushes. |
| `tests/pm_pilot_qa.gd` | Test-only: registers the new hook sections (run only when named). |
| `docs/wave3/QA_RUNBOOK.md` | Method, check ids, limits, staging protocol. |
| `docs/wave3/qa/baselines/*.json`, `docs/wave3/qa/runs/*` | Control results, logs, 6 JPEG captures per control. |

The command is also in `/home/claude/wave3_shared/QA_W3_RUN.md`.

## Control results (same command, `--rendered`; Godot 4.6.1, Linux, 2 shared cores)

| | PR51 `baedd678` | PR61 `49ae3efe` | PR57 `903634af` |
| --- | --- | --- | --- |
| Core harness (10 sections) | 460 pass / 0 fail | 460 / 0 | 460 / 0 |
| Issue #42 author suite | 305 / 0 | 305 / 0 | 305 / 0 |
| Stock TR05 | 25 suites, 1,607 assertions, 0 failed | same | same |
| Wave 3 checks | 76 pass / 27 fail / 4 skip | 78 / 25 / 4 | 78 / 25 / 4 |
| Acceptance items failing | 9 of 15 | 8 of 15 | 8 of 15 |

PR61 and PR57 give identical Wave 3 outcomes (0 differences), as expected since PR61 contains the PR57 stair. PR61 improves two PR51 checks (Canal geometry present, Canal containment hook 25/25). `verify_tr05_preservation.py` exits 1 on PR61 (`expansion build_room PR37 function exact`), because Level #58 edits `build_room`; recorded as a note, not a gameplay regression.

Defects the controls show (the creator verdict, now measured):
* True animation: the staged stair fails (`W3-STAIR-ASCEND-TRUE-ANIM`: held ART-04 key translating, only 57% of moving windows show a changed pose; descent uses the inherited 0.62 s loader and shows 3 distinct poses). The Canal doorway fails (`TRUE-ANIM`, `POSES`: 1 distinct frame before the swap on R0 to R13). The held-pose control PR57 fails as required.
* Full-screen: the PR61 stair adds 6.7% letterbox bars, stage-only coverage reaches 95% on only 38% of grabs, Kaze reaches 34% of viewport height (need 45%). Descent has no stage at all.
* Escapes: 126 of 928 real-input probes on PR51 and 131 of 928 on PR61 leave the room rectangle (wall-jump chains reach up to about 440 px above R13's top). Level's goal is to drive this to zero without losing endpoint pairs.
* Durations: Canal walk-through 1.17 s, Canal door 0.67 s, descent 0.62 s (all below the 1.5 s floor of the "about 2 to 4 s" contract).

Measurement validity (rendered self-test): a synthetic textured full-viewport stage with an animated run-strip Kaze passes all three presentation measures; a letterboxed half-window stage with a small Kaze fails all three; held, scaled and bobbed copies of an approved frame fail the animation metric while the approved `kaze_run_strip.png` passes (max leg difference 1.38 against 0.05 for the scaled copy).

## Categories
* Automated headless: everything above except the presentation measures.
* Software GL (llvmpipe, 1280x720): presentation measures, flatness at the room swap, captures.
* Human: none. Platform: Linux cloud only. Untested: Windows and macOS, gamepad, performance, unseeded campaign, label pixel placement, candidate watchdog timeout (cannot be forced from outside; only the 6 s ceiling is asserted), creative acceptance of any kind.

## Limits found while building
* Pixel metrics are heuristics (bars are near-uniform edge bands of 20 px or more that do not span the frame; a flat-colour stage looks like bars, so the self-test uses a textured stage).
* Reach probes find escapes that scripted patterns find; a pass means none found by those patterns.
* Stage 1 candidates with stand-in frames can legitimately fail `TRUE-ANIM`; QA reports which.

Environment: Godot 4.6.1.stable, Linux 6.18 cloud VM, Python 3 with Pillow and numpy, xvfb. Model: Claude Sonnet 5.5. Nothing merged; main untouched; ART-07 untouched.


# Candidate evaluation (final pins)

Tested SHAs: Transition TR-08 `308bbf105dc6ea0eaaa14f7aadaa626abf4ca13a` (supersedes `775ef9ff`), Level LD-05 `a6e3de25`, Art ART-08 `61b32194`, combined `candidate/wave3-combined` `cb1a59c4395584c08f6fb4cb45ae8a57fdfcd5f8`. No newer heads were on origin at the last check. Same command, `--rendered`, detached worktree at each exact SHA. Run folders: `docs/wave3/qa/runs/<label>/`.

## Readiness recommendation: NOT READY

Both the combined candidate and TR-08 end in ACCEPTANCE_FAILURES. There are no hard regressions (core, #42 suite and stock suites are green), but the automated acceptance gates are not met and no creator review has happened. QA does not claim creative acceptance of any kind.

## Results

| | TR-08 `308bbf10` | Combined `cb1a59c4` |
| --- | --- | --- |
| Core harness | 460 / 0 | 460 / 0 |
| Issue #42 author suite | 305 / 0 | 305 / 0 |
| Stock suites | 25 suites, 1,617 assertions, 0 failed | same |
| Wave 3 checks | 93 pass / 10 fail / 5 skip | 104 / 9 / 6 |
| Acceptance items | 4 failing of 15 | 4 failing of 15 |

Passing items on both: true multi-frame door movement (10/0), staircase ascent and descent, Canal IN and OUT, destination labels, reduced motion (30/0), correct arrivals, doorway reliability (369/0), save and progression, graph integrity. Control restoration and cancel pass with 4 skips. Durations pass: stair 2.88 s, Canal OUT 2.18 s, Canal IN 2.38 s; reduced motion 1.35 s (stair) and 1.72 s (Canal). Both stair directions and both Canal directions complete with one request and one room swap.

## Defects (reproducible)

Repro: `python3 tools/pm_pilot_qa/run_w3.py --sha <sha> --label x --rendered`, then read `result.json` and the named hook log.

1. Stair true animation fails narrowly (both TR-08 and combined). `W3-STAIR-ASCEND-TRUE-ANIM`: 88% of 8 moving windows show a pose change (need 90%), 21 distinct poses; descent 89% of 9, 22 poses. The single held-while-moving window is the `kaze_stair_arrive_idle_settle` strip frame 3 at about t=2.1 s. Fix candidate: add motion to that settle frame or stop actor travel during it.
2. Stair letterbox: `W3-STAIR-*-NO-LETTERBOX` 3.9% bars added (limit 2%). The stage fills the viewport and Kaze reaches about 65% of height; the bars are the top debug label strip and bottom destination bar. A human should judge whether those are acceptable HUD, since the metric cannot tell.
3. `ART08:true_animation`: `door_turn_to_side` has no PNG (150 of 151 art08_check checks pass). All shipped clips are true animation (70 frames, no adjacent identical frames). Loop seam distances 0.454 / 0.444 / 0.245.
4. Vertical routes (combined, Level LD-05): escapes drop from 131 to 0 of 928 probes, but the ROUTES comparison loses pairs against PR61: R13 2>0 full, R15 0>1 base, R16 2>0 full. See the directed result below. `W3-REACH-NO-ESCAPE` and one ROUTES check are flagged in the TR-08 run, where Level's roof is not present, as expected for that tree.
5. Canal doorway presentation (informational, not an acceptance item): the Canal sequences are a world-camera presentation. Kaze reaches 34% (OUT) and 23% (IN) of viewport height, bars 14.8% and 5.2%, so the doorway full-screen, no-letterbox and scale checks fail. Raise with the creator whether Canal should match the stair presentation.
6. Art interface gaps (measured, heuristic): Kaze is about 308 px tall in the 480x724 cell, so the 560 to 720 px cinematic height is a 1.8 to 2.3x upscale; foot slide outliers (stair_descend_loop up to 14 px, door_cross up to 19 px, stair_arrive_idle_settle 29 to 102 px by convention, Art claims 1.5 px); colour distance to the approved idle strip about 0.31, versus 0.32 to 0.37 for the approved ART-04 keys these derive from (inherited, not new drift).

## Directed checks

* Level R15 inconclusive pair (base kit 0>1): directed probes with walk, hop, jump and wall patterns for 900 to 2400 ticks found a jump-chain route to endpoint 1 only with the full kit. The base-kit pair stays inconclusive. Level should confirm R15 is not entered without Windstep, since a lost base-kit pair could be a real gate change.
* R13 2>0 existed on PR61 only through an escape (x to -2322, y to 1528); not a legitimate route. R16 lost pair disappears with longer probes.
* Level claims 19 ledges bump the roof on a full double jump and 87 wall chains stop at the roof. QA did not separately verify that none is a required route.
* Level's own residuals (38 past-door strips, 664 px bare wall columns, kunai gate bodies bypassable by wall jump, R6 and R9 shelves 20 px off) were not re-measured.

## Combined interaction (roof course against cinematics)

Hook `hook_w3_combined.gd`: no boundary or roof solid overlaps Kaze at any endpoint or during any sequence; arrival points stay valid (arrivals 20/0 on the combined tree). The roof band is inside the camera view on 36 of 180 (ascend) and 144 of 180 (descend) stair ticks, but the opaque stair stage layer covers it; Canal sequences have 0 roof-in-view ticks. The roof-visible checks are SKIP and need a human capture review.

## Runner changes made while evaluating

TR-08 uses an off flag, so `--pm-staged-stair` is passed only to checkouts lacking `scripts/tr08_embodied_cinematics.gd`; the first TR-08 run was invalid for that reason and was rerun. The actor filter initially excluded paths containing "door", which hid the art08 door clips and caused false `DOOR-CANAL-*-VISIBLE` failures; files with a `kaze_` basename now bypass it. The R0 to R13 E-door wait in the core harness now waits for control to return. `verify_tr05_preservation.py` exiting 1 on trees with Level's `build_room` edit is reported as a note.

## Categories and limits

Automated headless and software-GL (llvmpipe) are separate in the runbook. Human review: none done; roof visibility over cinematics, label placement and all creative qualities are for the creator. Platform: Linux only. Untested: Windows, macOS, gamepad, performance, unseeded campaign, watchdog timeout. Heuristics: foot slide, identity drift and bar detection are heuristic; reach probes find only what scripted patterns find. Captures were pruned to a few JPEGs per run. Nothing merged, main untouched, ART-07 untouched, implementation worktrees untouched.
