# QA_W5 PM report: independent QA gate on candidate/wave3-targeted-2 (candidate 2)

Tested SHA: `b680d66c4fbb3047532aee74832091c37fb81308` (tree `bdf931a8`, branch `candidate/wave3-targeted-2`, draft PR #76). Fresh detached worktree, disposable profiles. Command: `python3 tools/pm_pilot_qa/run_w3.py --sha b680d66c4fbb3047532aee74832091c37fb81308 --label w5-targeted2-b680d66 --rendered`. Run folder: `docs/wave3/qa/runs/w5-targeted2-b680d66/`. Thresholds unchanged. No creative acceptance is claimed. This candidate was superseded by candidate 3 (see QA_W6_PM_REPORT.md) before the report was finished, so it is a complete record of the candidate 2 run but not a recommendation.

## Result: ACCEPTANCE_FAILURES, no hard regressions

| | c2c3d958 run | b680d66c (candidate 2) | delta |
| --- | --- | --- | --- |
| Wave 3 checks pass / fail / skip | 104 / 9 / 6 | 162 / 8 / 6 | harness now has 57 more passing stress checks; one fewer failure |
| Core harness | 460 / 0 | 460 / 0 | none |
| Issue #42 author suite | 305 / 0 | 305 / 0 | none |
| Stock suites | 25 suites, 1,617, 0 failed | same | none |
| Preservation guard (`verify_tr05_preservation.py`) | exit 1 (build_room) | exit 0, 0 failures | fixed |
| `verify_baseline.py` | 0 failures | 0 failures | none |
| Ascent true animation | FAIL 88% (gate 90%) | PASS 100% of 8 windows, 21 poses | fixed |
| Descent true animation | PASS 100% | PASS 100% | none |
| Stair letterbox (gate 2% added) | FAIL 3.9% | FAIL 7.8% | worse by the metric, see below |
| 928 escape probes | 0 escapes | 0 escapes | none |
| Route pairs lost vs PR51 / PR61 | 5 / 3 | 5 / 3 | same pairs |
| ART-08 strip checks | 162 of 163 | 162 of 163 | same one failure (`door_turn_to_side` has no PNG) |

## Durations (Engine.get_physics_frames, headless, same hook on three SHAs)

| Sequence | 869a3aa | c2c3d958 | b680d66c |
| --- | --- | --- | --- |
| Canal OUT (R13 to R0) | 132 | 132 | 132 |
| Canal IN (R0 to R13) | 144 | 144 | 144 |
| Stair ascent | 174 | 174 | 195 |
| Stair descent | 174 | 174 | 174 |

Physics-frame counts (to control back, measured from the key press) are identical on 869a3aa, c2c3d958 and b680d66c for Canal OUT, IN and the descent, so the Canal Return/OUT timeline is unchanged. The 0.12 s gap I reported on the c2c3d958 run is REFUTED as a candidate difference: it compared a rendered (software GL) run against a headless run, and my "seconds" value counted loop ticks, which differ by about 0.1 s between the two modes. In the rendered run of this candidate the physics frames agree with headless (stair 195 and 174, Canal 133 and 144; one frame of jitter on Canal OUT). The ascent is now 195 frames, about 3.25 s (expected 194 by Transition; my count includes the press tick), deliberate per the candidate notes. `physics_frames` is now printed by the stair and doorway hooks.

## Stair letterbox: still fails, and why the number rose

`W3-STAIR-ASCEND-NO-LETTERBOX` and `...DESCEND...`: 7.8% added bars (gate 2%). The top developer clip label is gone from the captures (confirmed in `STAIR-ASCEND_t064.jpg`: the top strip is empty), but the top and bottom bars are still there at the same geometry. My detector had not counted the top strip as a bar before, because the label text broke its uniform run; now the empty strip counts. So the bar area did not grow; the earlier 3.9% understated it. The stage fills the viewport (stage-only coverage 100%) and Kaze reaches 65% of viewport height. Whether bars of this kind are acceptable is a creator decision. The gate was not lowered.

## Candidate-owned suites (clean, empty profile per suite family)

| Suite | Result |
| --- | --- |
| native_cinematic_transitions (blocking) | 54 / 0 |
| tr08_embodied_cinematics | 226 / 0 |
| tr08_canal_hang_regression | 53 / 0 |
| tr08_canal_hang_probe | 111 runs: 110 completed, 1 "in_r13" (release_at20: A released before the x=120 trigger; control and trigger intact, so not a hang; identical on c2c3d958) |
| ld05_boundaries | 172 / 0 (expected 172), runtime about 25 minutes |
| ld07_ground (recovered LD-07) | 154 / 0 |
| ld07_dash_regression | 1 failure of 2: "GN-06 dash across R6 sill should request R7 automatically". The test header says it is a known GN-06 reproducer, expected RED; QA does not waive it. This is the open defect that candidate 3 targets. |
| st04_approved_copy | 0 failures in a fresh empty profile (9 failures when run after other suites in a shared profile: environment effect, not a candidate defect) |
| movement_momentum (checksum) | 0 failures |

## Canal Doorway stress (QA hook, 57 checks)

0 failures: both directions, three offsets, walk and run, three repeats, key mashing, pause at 5, 20, 45, 70 and 100 ticks, three round trips, R6 to R7 and R7 to R6 walk-throughs.

## Remaining failures on this candidate

1. Stair letterbox 7.8% vs 2% (both directions).
2. Route comparisons vs PR51 and PR61 (R13 2>0 full is a former escape; R16 2>0 disappears with longer probes; R15 base-kit 0>1 still inconclusive, Level to confirm).
3. `door_turn_to_side` PNG missing.
4. GN-06 known-red reproducer (dash across the R6 exit).
5. Canal doorway full-screen, bars and scale checks (informational, world-camera presentation).

## Categories

Automated headless, software GL and creator review are separate. Creator review is still needed for the bars, the label and art, and roof visibility over the cinematics (those checks are SKIP). Untested: Windows, macOS, gamepad, performance, watchdog timeout.

Environment: Godot 4.6.1.stable, Linux cloud VM, xvfb software GL. Model: Claude Sonnet 5.5.
