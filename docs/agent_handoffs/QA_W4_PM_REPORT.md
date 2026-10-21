# QA_W4 PM report: independent QA gate on candidate/wave3-targeted

Tested SHA: `c2c3d958abe8c1eb77e2851d29c00544bef63e80` (branch `candidate/wave3-targeted`, draft PR #74; origin tip confirmed with `git ls-remote` before the run). Fresh detached worktrees only; `/home/claude/w4-cand` was not used. QA harness: PR #65 branch `test/wave3-independent-qa`, same command and the same thresholds as the earlier evaluation (nothing lowered): `python3 tools/pm_pilot_qa/run_w3.py --sha c2c3d958abe8c1eb77e2851d29c00544bef63e80 --label w4-targeted-c2c3d95 --rendered`. Run folder: `docs/wave3/qa/runs/w4-targeted-c2c3d95/`. Test-only; no merges; nothing creative is accepted by this report.

## Recommendation: NOT READY (automated gates still fail, creator review pending)

The ART-08 descent and TR-08 hang fix work as intended on the automated checks, but the stair ascent true-animation gate (88% vs 90%) and the stair letterbox gate (3.9% vs 2%) fail exactly as before, the Level route comparison still loses the same pairs, and the candidate's own preservation guard still exits 1, and the candidate's own `ld05_boundaries` suite has one failure (R6 to R7 arrival 3.7 px off its expected x). The overall verdict is ACCEPTANCE_FAILURES with no hard regressions.

## Headline numbers and delta against the earlier evaluation (combined `cb1a59c4`)

| | cb1a59c4 (earlier) | c2c3d958 (now) | delta |
| --- | --- | --- | --- |
| Wave 3 checks (pass / fail / skip) | 104 / 9 / 6 | 104 / 9 / 6 | none in count |
| Acceptance items failing | 4 of 15 | 4 of 15 | same four |
| Core harness (10 sections) | 460 / 0 | 460 / 0 | none |
| Issue #42 author suite | 305 / 0 | 305 / 0 | none |
| Stock suites | 25 suites, 1,617 assertions, 0 failed | same | none |
| ART-08 strip checks | 150 of 151 | 162 of 163 (74 frames, 14 clips) | one failure is `door_turn_to_side` (no PNG, provenance "unfinished"), same as before |
| Reach escapes (928 real-input probes) | 0 | 0 | none |
| Stair duration (full / reduced) | 2.88 s / 1.35 s | 2.75 s / 1.27 s | about 0.13 s shorter |
| Canal OUT, IN (full / reduced) | 2.18, 2.38 s / 1.72 s | 2.07, 2.25 s / 1.60 s | about 0.12 s shorter |

The counts are identical, but the content moved: the descent true-animation check now passes, and the same total is reached because the ROUTES and Canal presentation checks still fail. The failing acceptance items are the same four as before: stair presentation (letterbox), stair true animation (ascent plus the one missing door_turn_to_side PNG in the art check), and vertical routes (two ROUTES comparisons). The Canal doorway full-screen, letterbox and scale checks also fail in the doorway hook; they are informational and not on the acceptance list.

## Results by requested area

### Stair ascent and descent true animation and clip selection

* Descent: `W3-STAIR-DESCEND-TRUE-ANIM` now PASSES (verdict TRUE_ANIMATION, 100% of 6 moving windows, 16 distinct poses). Earlier it failed at 89%.
* Descent clip order as played, per-tick actor texture from the real keys (samples in `captures`): idle, `stair_descend_enter` (tick 18), `stair_descend_loop` (tick 32, frames 0 to 7 repeated, 2 cycles, ticks 32 to 96), `stair_descend_exit` (tick 97), `stair_descend_arrive_settle` (tick 112), idle (tick 150). This is the required enter, loop, loop, exit, descend settle sequence. All four descent strips are TRUE_ANIMATION in the strip analysis (loop seam 0.419).
* Ascent is unchanged and still FAILS `W3-STAIR-ASCEND-TRUE-ANIM`: 88% of 8 moving windows show a pose change (gate 90%), 21 distinct poses. The one held-while-moving window is frame 3 of `stair_arrive_idle_settle` at t=2.1 s. Not fixed by this candidate.
* The gate was not lowered; this is recorded as a failure.

### Letterbox and full screen (software GL, rendered)

* `W3-STAIR-ASCEND-NO-LETTERBOX` and `W3-STAIR-DESCEND-NO-LETTERBOX`: 3.9% bars added, gate 2%. FAIL, same as before. Captures show these are the top strip carrying a developer label (for example "ART-08 · stair_descend_arrive_settle") and the bottom destination bar. The stage fills the viewport and Kaze reaches about 65% of viewport height. Whether the destination bar is acceptable HUD is a creator decision; the metric cannot tell. The dev label strip is something the creator should confirm is not shipped.
* Canal IN and OUT (informational, not an acceptance item): 5.2% and 15.1% bars, Kaze 23% and 34% of viewport height. These are world-camera presentations; fails vs the stair-style presentation gate, unchanged.

### Canal Doorway: real keys, speeds, pause, repeated

New QA hook `hook_w3_canal_stress.gd` (run on this SHA and on the earlier `cb1a59c4` for comparison): 55 checks, 0 fail on both. It covers both directions, three approach offsets, walk and run gaits, three repetitions each, key mashing during the sequence, pause at 5, 20, 45, 70 and 100 ticks, and three consecutive OUT then IN round trips without a reset. A pause taken early in the walk-in (5 or 20 ticks) cancels the passage in place without a room change and a fresh press then completes it (also the TR-08 design); pauses after the swap complete in one pass. The hook did not reproduce the old hang on either SHA, so it shows no regression and no proof that the hang fix changed anything; the candidate's own suites (below) are the evidence for the fix. The candidate's fixture-based `tr08_canal_hang_probe.gd` could not be run from outside (it needs a profile in a format I did not have), so that probe is not verified by QA.

Canal Return timeline: the R13 to R0 walk-through completes in 2.07 s (earlier 2.18 s), one request, arrival within tolerance of the ground truth. It is not byte-identical in duration to the earlier head (about 0.1 s shorter); the Canal arrival and ground-truth positions are unchanged (arrivals 20/0).

### R6 to R7 walk-through

QA hook: R6 to R7 arrives in R7 with control after 68 ticks, R7 to R6 after 65 ticks, one request each. Same numbers on the earlier head within 2 ticks. PASS. The candidate's own `tr08_embodied_cinematics` suite (226 checks, 0 failures) also passes.

### Ground probes and escapes

928 real-input probes: 0 left the room rectangle (baselines PR51 126, PR61 131). `W3-REACH-NO-ESCAPE` PASSES. ROUTES comparisons still FAIL:
* vs PR51: 5 pairs (R13 1>0 base, R13 2>0 full, R13 2>0 base, R15 0>1 base, R16 2>0 full)
* vs PR61: 3 pairs (R13 2>0 full, R15 0>1 base, R16 2>0 full)
Earlier analysis stands: the R13 pair existed on the controls only through an escape (not a legitimate route), the R16 pair disappears with longer probes, and the R15 base-kit pair remains inconclusive and should be confirmed by Level (is R15 entered without Windstep). `ld05_boundaries.gd` (candidate-owned, clean profile, about 25 minutes): 171 checks, 1 failure. The failure is `R6->R7 arrival in R7 ... unchanged`: the test expects feet x 227.1 within 3.0 px, and the arrival is x 223.4 (3.7 px off). The same arrival (223.39, 1089.93) was measured by QA on the earlier combined head `cb1a59c4`, so this is not new in this candidate; it looks like a stale expectation in the combined tree (the walk-through here uses the TR-08 embodied transition). Level should either update the expected x with a stated reason or confirm the 3.7 px shift is intended; QA does not decide that. The 170 other checks (wall chains stopping under the roof, sill and shelf checks, `SILLS_ENABLED=false` restore) pass.

### ST-04 copy tests, movement checksum, preservation, #42, native cinematics

* `st04_approved_copy.gd`: 0 failures with a clean, disposable profile. (A first run against a profile that held stale saves from earlier QA runs showed 12 failures; that is an environment effect and not a candidate defect, per the repository rule to use disposable user data.)
* `movement_momentum.gd` (movement checksum): 0 failures, clean profile.
* `native_cinematic_transitions.gd` (blocking): 54 checks, 0 failures. `tr08_embodied_cinematics.gd`: 226 checks, 0 failures.
* Issue #42 author suite: 305 / 0 in the harness.
* `tools/verify_baseline.py`: 0 failures. `tools/verify_tr05_preservation.py`: STILL EXITS 1, one failure: "expansion build_room PR37 function exact". The "narrowed preservation guard" in this candidate allows the ST-04 copy and the export exclusion, but not the LD-05 `build_room` change. This is the candidate's own guard failing in its own tree, so it is more than a harness note this time. Level or PM must either add the approved difference or revert the change.
* `pm_staged_stair_cinematic.gd` (18 failures): this tests the retired PR57 opt-in pilot flag, which TR-08 replaced; the failures are expected by design and the test looks obsolete. It is listed so nobody mistakes it for a regression. `automatic_passage_reliability.gd` called directly did not finish within my 280 s limit with a clean profile (0 failures before it timed out); the same suite passes as the harness's issue #42 section (305/0).

### Combined interaction

No boundary or roof solid overlaps Kaze at any endpoint or sequence (10 checks, 0 fail). The roof band is in view on 39 of 188 (ascend) and 149 of 188 (descend) ticks of the stair run but the opaque stage covers it; those two checks stay SKIP and need a human to read the captures.

## Categories

* Automated headless: core, #42, stock, stress hook, reach probes, art checks, analyzers, candidate suites listed above.
* Software GL (llvmpipe, 1280x720): presentation, letterbox, scale, captures.
* Human and creator acceptance: none performed and none claimed. Open for the creator: whether the dev label strip and destination bar are acceptable, whether the descent art reads as a convincing stair descent, roof visibility, and the Canal presentation.
* Untested: Windows, macOS, gamepad, performance, watchdog timeout (cannot be forced from outside), `tr08_canal_hang_probe` fixture run.

## Captures (15 JPEGs, `docs/wave3/qa/runs/w4-targeted-c2c3d95/captures/`)

`STAIR-ASCEND_t032/064/096/112/128.jpg`, `STAIR-DESCEND_t032/064/096/112.jpg` (labels in the frame show the clip in use), `STAIR-DESCEND-REDUCED_t048.jpg`, `DOOR-CANAL-IN_t032/064/096.jpg`, `DOOR-CANAL-OUT_t032/064/096.jpg`. Extra logs in `stress/`.

Environment: Godot 4.6.1.stable, Linux cloud VM, Python 3 with Pillow and numpy, xvfb. Model: Claude Sonnet 5.5.
