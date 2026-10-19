# QA PM report: Gameplay / independent QA, ORDER 4, Phase A

Branch `test/pm-pilot-regressions`. Base (PR51 head) `baedd6786ad4bee2123ea872b437bbb98e6d2721`, which is one commit on PR39 head `5dfc4c4f077c5408ecbe49f1cafafea1dcb1003c`. Head SHA of this work: see the push verification line at the end of the PR description and the coordinator reply (a report cannot contain its own commit hash). Draft PR base `fix/tr06-automatic-passage`.

Status: **Phase A complete. Phase B (candidate verification) is pending.**

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

## Phase B (candidate verification): pending, needs

1. Candidate head SHAs or worktree paths for Transition, Level/Canal and Art (and Build if its packaging touches gameplay).
2. `/home/claude/pilot_shared/CANAL_CONTRACT.md` (to write `hook_canal_containment`: wall-jump ceiling above the R13 left exit at feet (120,1200), intentional vertical routes preserved, door art coincident with threshold).
3. Transition candidate's staged-sequence contract (duration, the field or signal that marks completion, reduced-motion behaviour) to write `hook_cinematic_completion`.
4. Then: `python3 tools/pm_pilot_qa/run_qa.py --repo <path> --label <name> [--rendered]` per candidate and per integration branch, and compare against the two baseline `result.json` files here.

## Environment

Godot 4.6.1.stable.official.14d19694e (`/home/claude/godot_bin`), Linux 6.18 cloud VM, 2 cores shared with other agents, Python 3 for runners, Xvfb for the graphical subset. Model: Claude Sonnet 5.5. `.import` files and `.uid` files regenerated by the editor import were not committed except the two `.uid` files for the new scripts. Nothing merged, no release, main untouched, ART-07 untouched.
