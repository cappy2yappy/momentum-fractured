# QA PM report: Gameplay / independent QA, ORDER 4, Phase A

Branch `test/pm-pilot-regressions`. Base (PR51 head) `baedd6786ad4bee2123ea872b437bbb98e6d2721`, which is one commit on PR39 head `5dfc4c4f077c5408ecbe49f1cafafea1dcb1003c`. Head SHA of this work: see the push verification line at the end of the PR description and the coordinator reply (a report cannot contain its own commit hash). Draft PR base `fix/tr06-automatic-passage`.

Status: **Phase A complete. Phase B (candidate verification) complete for the four pinned candidates; see the Phase B section at the end.**

## Delivered (test-only; nothing under `scripts/` or any asset changed)

| File | Purpose |
| --- | --- |
| `tests/pm_pilot_qa.gd` | Independent harness. Self-contained, so it also runs on PR39, which lacks the PR51 test. Real `InputEventKey` input, real physics, no position or velocity writes during approaches, fresh disposable profile and deletion of the default save before every scene. |
| `tests/fixtures/pm_pilot_qa_hud.gd` | HUD stand-in that only suppresses the focus-loss pause for windowed/xvfb runs. |
| `tools/pm_pilot_qa/run_qa.py` | One-command runner (repo path or commit) writing `result.json`. |
| `tools/pm_pilot_qa/hooks/README.md` | Interface and Phase B needs for the pending hooks. |
| `docs/pm_pilot/qa/RUNBOOK.md` | Coordinator runbook. Same command is in `/home/claude/pilot_shared/QA_RUN.md`. |
| `docs/pm_pilot/qa/runs/pr39-5dfc4c4/`, `.../pr51-baedd67/` | `result.json` and all raw logs for the two baseline runs. |

Harness sections: `start` (fresh approved starting abilities, controller checksum, real-key R0 to R1), `issue42` (fresh save, jump offsets 0..40 step 5, plus a walk control), `matrix` (R13-R0, R13-R14, R14-R13, R1-R2, R1-R0 by walk, double-tap sprint, dash, and jumps at offsets 0/10/20/30/40; R0 to R13 depth door by E with and without Windstep; R13 left exit feet checked at (120,1200); control restoration and real-key responsiveness after arrival), `controls` (stop, reverse, held direction through arrival, arrival cooldown, immediate reverse, missed-aperture release and reapproach), `hints` (wrong height, tether, backward velocity, 8 authored gate hints each checked for the specific text and for not being overwritten by "PASSAGE LOCKED", repeated identical hint, 23 gated automatic endpoints, real-key locked R1 to R2 then unlocked pass), `endpoints` (live-physics jump approach for all 39 automatic endpoints, arrival no-loop, restored state), `save` (round trip, new instance, corrupt file, default profile untouched), `combat` (reach, behind, parry, missed parry, combo queue, real J key), `graph` (21 rooms, 29 links, 58 endpoints = 39 automatic + 19 explicit, both directions for every edge, reachability, gate open/close, original eight-room geometry), `reduced` (real F6, camera never zooms, control restored, toggles back), `reduced_cli` (separate processes, with and without `--tr05-reduced-motion`).

Pending hooks (SKIP, never pass): `hook_cinematic_completion`, `hook_canal_containment`. A runner verdict of `PASS_WITH_SKIPS` means exactly that.

## Results actually executed (Godot 4.6.1.stable.official.14d19694e, Linux cloud, 2 shared cores)

Harness SHA-256 `f3f3754e69f5e26b0b1298e77dbca224299a604de76814343016aa9755c0ae5d`. Logs and `result.json` per run are in `docs/pm_pilot/qa/runs/<label>/`.

### Automated, headless

| Check | PR39 `5dfc4c4` (unchanged, temporary detached worktree, removed afterwards) | PR51 `baedd67` |
| --- | --- | --- |
| QA harness (headless) | **332 pass / 128 fail / 2 skip, exit 1**, 0 script errors | **460 pass / 0 fail / 2 skip, exit 0**, 0 script errors |
| Author's issue #42 test (`tests/automatic_passage_reliability.gd` via `tools/run_tr06_qa.py`, SHA-256 `1280d391...cd9f`; borrowed into the PR39 worktree, native in PR51) | **211 pass / 94 fail, exit 1**, 0 script errors | **305 pass / 0 fail, exit 0**, 0 script errors |
| Stock `tools/run_tr05_qa.py` (25 suites) | 25 suites, 1,607 assertions, 0 failed, exit 0 | 25 suites, 1,607 assertions, 0 failed, exit 0 |
| `tools/verify_baseline.py` | exit 0, 0 failures | exit 0, 0 failures |
| `tools/verify_tr05_preservation.py` | 59 PASS, 0 failures | 59 PASS, 0 failures |
| `--tr05-reduced-motion` absent / present | 1/1 pass, 1/1 pass | 1/1 pass, 1/1 pass |

My independent harness reproduces BUILD-06's author numbers exactly (211/94 on PR39, 305/0 on PR51), and the stock-suite count matches the TR-05 claim of 25 suites / 1,607 assertions. These were run by me, not copied.

PR39 harness failures by section: `issue42` 18, `matrix` 65, `controls` 1, `hints` 41, `endpoints` 3. Substance:

* Issue #42 reproduced independently: fresh save, R0 to R1 by real walking, then walk left and jump. Offsets 0, 5, 10 transit; offsets 15 through 40 end with Kaze at x of about 14, velocity 0, grounded and wall-stopped, no transition (`TRACE issue42` lines in `harness_headless.log`). Walking without jumping works.
* The same wall stall appears in the staged matrix for all five pairs (R13 to R0, R13 to R14, R14 to R13, R1 to R2, R1 to R0) at jump offsets 10, 20, 30 and 40 (offset 0 passes; walk, sprint and dash pass), and the controls case "outward reapproach recovers missed wall exit" fails.
* K-02 reproduced: on PR39 every authored gate hint is replaced by `PASSAGE LOCKED - CHECK THE ATLAS.` (R1 to R2 Windstep, R3 to R4 Tether, R5 to R6 Dash among the 8 authored hints, and all 23 gated automatic endpoints, including expansion need ids: 41 hint failures in total).
* One more PR39 failure I did not expect from the author summary: the live-physics jump approach at `[9,10]` (SkyWorks lift side passage) fails on PR39 and passes on PR51.
* Everything else (start, save, combat, graph, reduced motion, abilities, checksum) passes on PR39 as well, so the regression harness is not simply failing everything there.

PR51 passes all 460 harness checks including the three items I wanted to see directly: the specific gate hint survives for all 8 authored gates and 23 gated automatic endpoints, grounded reapproach works at multiple jump timings with no softlock, and the 39-endpoint sweep lands supported with no arrival loop.

### Graphical (software GL, Linux cloud only; separate from the above)

PR51 only: `xvfb-run`, Godot `--rendering-method gl_compatibility --rendering-driver opengl3`, adapter `llvmpipe (LLVM 20.1.2, 256 bits)`, X11. Sections `start,issue42,reduced`: **67 pass / 0 fail / 0 skip, exit 0**, about 274 s. The full suite under software GL runs in real time (over an hour on this box), so it was not run; the default graphical subset is the issue #42 case plus reduced motion. No screenshots were captured or committed; this is a behavioural run under a rendering driver, not visual review.

### Human

None. No human playtest, no creator acceptance.

### Platform

Linux cloud only. Windows and macOS builds/launch belong to Build and the creator. Gamepad, sustained performance, and a full unseeded campaign playthrough are untested.

### Untested / limits

* Cinematic completion and control restoration for the future staged ~2-3 s sequence, and Canal containment: hooks present as SKIP, nothing was verified. The existing 0.65 s transition's restoration (physics running, sprite visible, camera zoom and position reset, `transition` 0, not paused, key response) is checked in `matrix` and `endpoints` and passes on PR51.
* Staged cases establish the starting room and abilities by fixture and then use real keys; only `start` and `issue42` begin from a genuinely fresh unseeded save. The 39-endpoint sweep and gate coverage are not a campaign playthrough.
* Engine ERROR lines (`Parse JSON failed` from the deliberate corrupt-save case, RID/ObjectDB shutdown leaks) are inherited or intentional, not failures.
* Observation, not a defect claim: after bumping a locked gate, a player must step back at least 16 px inward to re-arm the passage (existing design); the harness accounts for it.

## Phase A note: what Phase B needed (now supplied)

1. Candidate head SHAs or worktree paths for Transition, Level/Canal and Art (and Build if its packaging touches gameplay).
2. `/home/claude/pilot_shared/CANAL_CONTRACT.md` (to write `hook_canal_containment`: wall-jump ceiling above the R13 left exit at feet (120,1200), intentional vertical routes preserved, door art coincident with threshold).
3. Transition candidate's staged-sequence contract (duration, the field or signal that marks completion, reduced-motion behaviour) to write `hook_cinematic_completion`.
4. Then: `python3 tools/pm_pilot_qa/run_qa.py --repo <path> --label <name> [--rendered]` per candidate and per integration branch, and compare against the two baseline `result.json` files here.

## Environment

Godot 4.6.1.stable.official.14d19694e (`/home/claude/godot_bin`), Linux 6.18 cloud VM, 2 cores shared with other agents, Python 3 for runners, Xvfb for the graphical subset. Model: Claude Sonnet 5.5. `.import` files and `.uid` files regenerated by the editor import were not committed except the two `.uid` files for the new scripts. Nothing merged, no release, main untouched, ART-07 untouched.


---

# Phase B: candidate verification (final harness)

Harness: `tests/pm_pilot_qa.gd` plus hooks in `tools/pm_pilot_qa/hooks/` at the commit that produced the runs (recorded per run as `qa_harness_sha256`). Evidence: `docs/pm_pilot/qa/runs_final/<label>/` (result.json, every raw log, `captures/` JPEGs). Phase A runs remain in `docs/pm_pilot/qa/runs/` as history, produced by the Phase A harness (SHA-256 `f3f3754e...`, commit 455f352). Each candidate was checked out fresh at its exact SHA in a temporary detached worktree (removed afterwards), imported, and run with a disposable profile. Godot 4.6.1.stable.official.14d19694e, Linux cloud, 2 shared cores.

The two placeholder hooks are now real checks: `hook_cinematic_completion` (real E/F6/D keys; duration measured by my own frame counter, cross-checked against the controller's marker) and `hook_canal_containment` (real-key wall-jump probes, platform diff against PR51, aperture and enclosure checks, repeated R0<->R13 round trips, real-key route climb to the R14 exit).

## Exact tested SHAs and numbers

All counts are pass / fail (skip). Harness = my 20-odd-section real-input suite. Author = PR51 `automatic_passage_reliability` (issue #42 matrix). Stock = `run_tr05_qa.py` 25 suites.

| Target | SHA | Harness (headless) | Author issue #42 test | Stock 25 suites | verify_baseline / verify_tr05_preservation | Staged-stair hook (`--pm-staged-stair`) | Own suites | Software-GL subset |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Combined | `49ae3efe21dea6a9eba556ce2fbc8299b00412b9` | 488 / 0 (1 skip) | 305 / 0 | 1,607 / 0 | 0 failures / **1 failure** (see known item 5) | 32 / 0; reduced-launch process 6 / 0 | stair 50/0, canal-left 56/0, canal_geometry 173/0 | 67 / 0 plus 14 captures |
| Transitions only | `903634afa51237e29fd306ae815c880415230f17` | 463 / 0 (2 skip) | 305 / 0 | 1,607 / 0 | 0 / 0 | 32 / 0; reduced 6 / 0 | stair 50/0, canal-left 55/0 (stub geometry) | 67 / 0 plus 14 captures |
| Geometry only | `0656766d8fe13c702a4808b1d25ddd0855d8922c` | 485 / 0 (1 skip) | 305 / 0 | 1,607 / 0 | 0 / **1 failure** (same item) | not applicable (no stair code) | canal_geometry 173/0 | 67 / 0 plus 6 captures |
| Art only | `dfab1cf2efcacb2a792fb578b72be2434b9e4411` | 460 / 0 (2 skip) | 305 / 0 | 1,607 / 0 | 0 / 0 | not applicable | none | 67 / 0 plus 6 captures |
| PR51 control | `baedd6786ad4bee2123ea872b437bbb98e6d2721` | 460 / 0 (2 skip) | 305 / 0 | 1,607 / 0 | 0 / 0 | not applicable | none | (Phase A run: 67 / 0) |
| PR39 control | `5dfc4c4f077c5408ecbe49f1cafafea1dcb1003c` | 332 / 128 (2 skip), exit 1 | 211 / 94 (borrowed test), exit 1 | 1,607 / 0 | 0 / 0 | not applicable | none | not run |

Runner verdicts: combined FAIL and geometry FAIL only because of the one explained preservation failure; transitions PASS_WITH_SKIPS (Canal hook skipped, geometry absent); art PASS_WITH_SKIPS; PR51 PASS_WITH_SKIPS; PR39 FAIL (issue #42). Skips are the hooks that cannot apply to that checkout, never passes.

Regression axes, repeated on every row above through the harness: issue #42 fresh-input matrix (offsets 0..40, walk/sprint/dash/jump, 39 endpoints), save/reload round trip, combat basics, progression gates, 21 rooms / 29 links / 58 endpoints, reduced motion (F6 and launch flag), approved starting abilities, controller checksum, original eight-room geometry. No candidate regressed any of them against PR51 (identical failure counts: 0).

## Cinematic completion and control restoration (combined and transitions-only)

Real keys, flag `--pm-staged-stair`, R14 to R17: E-to-control **2.38 s** by my counter (contract 2.35 s; controller marker 2.35 s), phases enter, load, arrive, one request, arrival feet (1680,1298), camera/sprite/proxy/physics restored, E and D held through and 100 ticks after causes no bounce. Reduced via F6 **0.98 s** (contract 0.95), reduced via `--tr05-reduced-motion` launch inside 0.85 to 1.1 s, no zoom in either. F6 mid-enter finishes early (1.15 s). E mashing produces one sequence. Respawn mid-enter returns control. The longest sequence in any run was 2.38 s, under the 4 s ceiling (the 4 s watchdog itself was not triggered, so its firing path is not exercised by me). Locked stair starts nothing and keeps the authored hint. R17 to R14 and the R13 to R14 doorway keep the inherited presentation. With the flag off the stair is the PR51 0.65 s loader.

Behaviour to know: pausing mid-enter aborts the sequence (marker `paused`) and leaves Kaze in R14; the player presses E again. Pausing during the arrival phase and resuming returns control in R17. This is safe (control always returns) but not a resume.

## Canal containment (combined and geometry-only)

PR51 control, same probes: Kaze reaches feet y between -30 and -180 above the exit and out of the world (x as low as -1482) by wall jumps against the old left wall. Geometry candidates: inside the hall every probe stays at or below feet y 1080.07 (the lintel head-bump limit is 1080), never inside the mass or pier, never left of x 86 (pier face plus radius). R13 platform diff against PR51: nothing removed or moved; exactly two colliders added (mass (0,0,296,1020), pier (0,1020,72,180)); aperture clear; pad (0,1200,360,40) retained; endpoint (120,1200) horizontal_walk heading -1 unchanged; entrance (590,780) depth door unchanged. Two R0 to R13 E arrivals land at (184,1198) and two real-A walks return to R0 once each. Other R13 routes: a real-key climb from the arrival point over shelves 500/720/1010/1220/1400 reaches the R14 exit and the automatic R13 to R14 passage fires. Limit: I did not search for every upper-cluster route (shelves around (300,440), the wind fold at (900,400), the grapple anchor); those are covered only by the platform diff (identical to PR51 outside the two enclosure colliders) and Level's own canal_geometry suite (173 / 0), not by my own real-input play.

## Known items, kept distinct

1. **Nine flagged stair-timing failures, by design.** Stock `cinematic_transitions.gd` run with `--pm-staged-stair` gives 359 pass / 9 fail on both combined and transitions-only (`candidate_test_cinematic_transitions_flag.log`). All 9 are the R14 to R17 stair assertions written for the 0.65 s presentation. Without the flag the stock suites are 1,607 / 0. They are not hidden and need a reviewed update before the flag could become default.
2. **Exterior-face wall-jump residual (Level's known item), verified.** From the shelf at x 330, 400 and 520, chained wall jumps up the outside of the gatehouse at x=296 reach feet y -177, -177 and -125 and leave the world on both geometry-only and combined. Kaze came back through the existing fall recovery (position returned inside the room), and in my probes then walked out the door because left was held, so no soft lock was observed. It is an unintended space, not a regression: PR51 allows the same escape from the old wall.
3. **R13 right-wall boundary (pre-existing, not Canal).** A probe from the hall heading right and chaining wall jumps up the right boundary of R13 left the world (min feet y -180, x about 2680) on PR51 as well as every candidate. Same cause as Level's EXIT_AUDIT finding 3 (rooms have no top). Not changed by any candidate.
4. **Committed bytecode.** `tools/pm_pilot_art/__pycache__/common.cpython-313.pyc` and `scene.cpython-313.pyc` are tracked in the art-only branch (and so in the combined candidate). They should be removed before merge; repo policy is no stray binaries.
5. **One preservation-script failure, explained.** `verify_tr05_preservation.py` reports `FAIL: expansion build_room PR37 function exact` on geometry-only and combined (58 pass / 1 fail). Level's 3-line hook in `scripts/world_expansion.gd` `build_room` is what makes the gatehouse load; the script pins that function to PR37 byte for byte. I did not try to judge intent; the script, or the hook, needs an explicit reviewed exception. All other protected files (player.gd, hud.gd, guard.gd, project.godot, kaze/web/art04 assets, APPROVED_GEOMETRY.json) are unchanged against PR51 on every candidate.
6. **Art-only has no visible effect alone.** In its captures the Canal door is still the procedural stand-in; the new layers appear only where the Transition/combined code loads them.

## Captures (graphical, software GL llvmpipe, seeded fixtures with real key input, not human footage)

14 JPEGs for combined and transitions-only (Canal-left six frames, stair eight frames); six for geometry-only and art-only. I opened the combined frames and the Canal frame from each candidate. Findings: Kaze starts inside the walled hallway on the shelf, the door and its arrow sit inside the aperture, and she is inside the opening at the trigger (frame 3); the wipe and "CANAL HAVEN" plate cover the screen during the swap; arrival in R0 is clean. In the stair set Kaze climbs the treads in the close-up, the wipe sweeps in from the left, the loader frame is a full wipe with the plate and an honest "TEMPORARY STAGING ... LOADER 0.65 S (INHERITED)" label, and the arrival frame shows Kaze on the R17 stair with control returning. Labels read "FULL GAIT PENDING" and "ARRIVAL KEY PENDING": the character poses are held ART-04 key poses, not animation. Combined shows the real masonry layers; geometry-only shows the procedural masonry; transitions-only shows the procedural door. Not inspected frame by frame: every early/late stair frame of the other candidates. Creator visual acceptance remains pending and is not claimed.

## Readiness recommendation

**Combined candidate `49ae3efe`: ready for creator playtest and for build packaging, with conditions; not ready to merge.**

* Behaviour is sound: no regression versus PR51 on any axis I can test (issue #42 matrix 305/0, stock 1,607/0, my harness 488/0), the Canal enclosure works under real input, the staged stair completes in the stated time and always returns control. Each candidate also passes alone, so they can be accepted separately.
* Before merge, in order: (a) remove the two committed `.pyc` files; (b) give `verify_tr05_preservation.py` or the `world_expansion.build_room` hook an explicit reviewed exception; (c) decide whether to leave the staged stair opt-in (as built) or make it default, which requires updating the 9 stair-timing assertions; (d) creator decision on the exterior-face and room-top wall-jump residuals (game-wide, not Canal-specific); (e) creator acceptance of the transition presentation and the Canal art.
* Still untested by me: Windows and macOS, physical gamepad, sustained performance, full unseeded campaign, the 4 s watchdog firing path, and human visual review.

## Phase B environment

Godot 4.6.1.stable.official.14d19694e, Linux 6.18 cloud VM, Xvfb with Mesa llvmpipe (LLVM 20.1.2) for the graphical subset, Python 3, Pillow for JPEG derivatives. Model: Claude Sonnet 5.5. No merges, no main, ART-07 untouched, no worktree under /home/claude/wt-* modified apart from my own. Temporary worktrees in /tmp were removed.
