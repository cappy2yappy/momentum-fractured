# Wave 3 independent QA runbook (QA_W3)

Branch `test/wave3-independent-qa` (base `test/pm-pilot-regressions`). Everything here is test-only: nothing under `scripts/`, `assets/` or `project.godot` of any candidate is edited, and candidates are only ever evaluated at an exact pushed SHA in a detached worktree.

## The one command

```bash
cd /home/claude/w3-qa
python3 tools/pm_pilot_qa/run_w3.py --sha <40-hex SHA> --label <label> --rendered
# or the current tip of a candidate branch (resolved through gh api, then pinned to that SHA):
python3 tools/pm_pilot_qa/run_w3.py --branch feature/tr08-fullscreen-embodied-cinematics --label tr08-s1 --rendered
```

It fetches exactly that commit (`git fetch --depth=1 origin <sha>`), creates a detached worktree at it, checks that `git rev-parse HEAD` equals the SHA, imports, runs everything below, writes `docs/wave3/qa/runs/<label>/result.json` plus raw logs and JPEG captures, then removes the worktree. Typical wall time on the 2-core box: headless about 6 to 8 minutes plus about 5 minutes of reach probes (`--quick` cuts reach to about 1 minute); `--rendered` adds about 4 minutes (software GL runs in real time). Options: `--quick`, `--no-stock`, `--no-reach`, `--only w3` (Wave 3 hooks and art checks only), `--expect-canal`, `--keep` (keep the worktree).

The result is categorised and never merged: `automated_headless`, `software_gl_graphical`, `human` (always none), `platform`, `untested`. `acceptance` maps every check to the Wave 3 acceptance list with PASS, PASS_WITH_SKIPS, FAIL or NOT_RUN; `vs_controls` lists every W3 check whose outcome differs from each recorded control baseline in `docs/wave3/qa/baselines/`. `readiness` can only ever say NOT READY or AUTOMATED GATES PASS (creator review still required). It never says accepted.

## What the harness measures, and how

All Wave 3 hooks are candidate-agnostic: they use real `InputEventKey` input and physics, and observe the scene tree, camera, physics tick and (rendered) pixels from outside. They do not depend on a candidate's class names, so the same hooks judge the controls and every candidate. Sections are `hook_w3_stair`, `hook_w3_doorway`, `hook_w3_reach`, `hook_w3_selftest` (run only when named in `--qa-sections`), alongside the existing sections.

| Acceptance item | Check ids / method | Headless | Software GL |
| --- | --- | --- | --- |
| Full-screen stair presentation | `W3-STAIR-*-FULLSCREEN` (hide the world and HUD canvas, paint magenta clear colour, count non-magenta pixels of the cinematic's own layers; need >=95% on >=60% of grabs, or a camera-only stage with no bars and large Kaze), `-NO-LETTERBOX` (bars added <=2% of viewport), `-KAZE-SCALE` (alpha height >=45% of viewport height on >=50% of visible ticks; spec is 560 to 720 px on 1080p, i.e. 52 to 67%) | SKIP (cannot measure) | measured |
| True multi-frame movement | `W3-*-TRUE-ANIM`: every sampled tick records the actor's texture, frame, region, flip and position; `tools/pm_pilot_qa/true_animation.py` normalises each frame silhouette for translation and uniform scale (so bobs, zooms and held poses score zero) and requires distinct leg poses (gait difference >=0.30) in >=90% of 0.30 s windows in which the actor travels >=14 px, and >=4 distinct poses overall. Shipped strips: `art08_check.py` applies the same metric per clip | measured | measured |
| Known-bad control | Held ART-04 stair key, held single pose, scaled pulse and bobbed still must FAIL; approved `kaze_run_strip.png` must PASS (`true_animation.py --controls`, also `hook_w3_selftest`). PR57 `903634af` must FAIL the playback check | yes | yes |
| Staircase ascent and descent | `W3-STAIR-ASCEND-*`, `W3-STAIR-DESCEND-*`: E starts one sequence, duration 1.5 to 6 s, one request and one swap, arrival room/feet/facing against `hooks/w3_ground_truth.json`, progression snapshot unchanged, E held 120 ticks after arrival does not bounce, real keys move Kaze afterwards | yes | yes |
| Canal doorway entry and emergence | `W3-DOOR-CANAL-OUT-*` (R13 to R0, real A walk-through) and `W3-DOOR-CANAL-IN-*` (R0 to R13, real E depth door): Kaze visible >=70% of pre-swap ticks, reaches the door, >=5 distinct frames before the swap, `-NOT-WIPE` (frames within 10 ticks of the swap not >90% flat blocks) | all but NOT-WIPE | all |
| Destination label | `W3-*-LABEL`: evidence from HUD message, visible Label nodes, controller `destination` fields or the embodied overlay target. This proves the data path, not pixel placement (human review) | yes | yes |
| Reduced motion | `W3-*-REDUCED-*` using the real F6 key: flag, completes, shorter than full, no zoom (max zoom <=1.001), label kept, >=2 distinct true frames shown | yes | yes |
| Control restoration | `Control state restored` (physics, sprite, camera zoom/position, `transition`, pause, HP), `W3-*-CANCEL-PAUSE/DEATH/ROOMCHANGE`, `W3-*-HELD-E/HELD-KEY`, `W3-*-CONTROL`. Timeout: not forceable from outside, only the 6 s ceiling is asserted (reported as untested) | yes | yes |
| Doorway reliability | existing `issue42` and `matrix` sections, `endpoints` sweep of 39 automatic endpoints, PR51 author suite `tests/automatic_passage_reliability.gd` (305/0) | yes | subset |
| Vertical routes vs escapes | `hook_w3_reach`: every endpoint of every room, full and base kit, jump / hold-jump / wall-jump chain / dash patterns both directions, real input, 360 ticks. `W3-REACH-NO-ESCAPE`: no probe leaves x -16..W+16 or goes above y -40. `W3-REACH-ROUTES-vs-pr51/c49`: endpoint pairs reached in a control must still be reached; lost or gained standing cells are listed for review (Level removes unintended areas on purpose). Plus the legacy Canal containment hook | yes | no |
| Save and progression | existing `save` section, `W3-*-PROGRESSION` snapshot around each sequence | yes | no |
| Graph integrity | existing `graph` section (21 rooms, 29 links, 58 endpoints, both directions, reachability, gates) | yes | no |

## Controls and baselines

Recorded in `docs/wave3/qa/baselines/` (the same command, `--label` matching the file) and `docs/wave3/qa/runs/<label>/`:

* `pr51-baedd67`: PR51 TR06 fix, the movement and passage reference.
* `pr61-49ae3ef`: candidate/pm-pilot-combined, the Wave 3 starting point and ground truth for arrivals and Canal.
* `pr57-903634a`: the held-pose staged stair; known-bad control for true animation.

Sanity of the tools themselves (measurement self-tests, run every time `hook_w3_selftest` and `true_animation.py --controls` are included): a synthetic full-viewport textured stage with an animated run-strip Kaze passes the three presentation measures; a letterboxed half-window stage with a small Kaze fails them all; held, scaled and bobbed copies of an approved frame fail the animation metric.

## Staging protocol for Wave 3 candidates

1. Stage 1 (stand-in engine candidate, `feature/tr08-fullscreen-embodied-cinematics`): run with `--rendered`. Expected: presentation, label, reduced motion, arrival, control and cancel checks measurable; true animation may legitimately still fail with stand-in frames (labelled). Report which checks fail and why.
2. Stage 2 (real clip binding, ART-08 strips bound by manifest path): the full set. `art08_check.py` verifies the manifest, SHA256 and size of every strip, geometry (480 x 724, pivot 240,600), RGB zeroed where transparent, no held frames, loop seams.
3. Final: rerun the exact final SHA, compare `vs_controls`, and read the captures. Level (`feature/ld05-intentional-world-boundaries`) is evaluated by `hook_w3_reach`, `matrix`, `endpoints`, the 305/0 suite and `graph`; its own documents declare the intended areas.

A QA verdict is never a creative acceptance. Visual quality, animation quality, door-as-physical-passage feel, label placement and any release decision belong to the creator.

## Known limits of the checks

* Pixel metrics (coverage, bars, flatness) are heuristics measured in software GL on Linux, 1280 x 720; they catch gross failures (letterboxes, wipes, small actors) and are not an art review. Bars are detected as near-uniform edge bands of >=20 px that do not span the frame.
* The label check proves that label data exists on the controller or HUD, not where it is drawn.
* Reach probes use scripted input patterns; they find escapes a scripted chain can find, not every escape a human could find. A pass is "none found by these patterns", reported with the probe count.
* A candidate that renames the player sprite texture out of paths containing `kaze`, `art04`, `art06` or `art08` would not be observed; the harness then reports no visible actor, which fails the checks (it cannot pass by accident).
