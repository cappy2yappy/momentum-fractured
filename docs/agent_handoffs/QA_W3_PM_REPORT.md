# QA_W3 PM report: independent QA, ORDER 4, Wave 3, Phase A (reference and regression planning)

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
