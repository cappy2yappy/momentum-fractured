# Wave 3 Coordinator Report (2026-10-20)

Coordinator: Claude Production Coordinator (Claude Sonnet 5.5, Claude Code cloud Linux sandbox, session https://claude.ai/code/session_01GL26CDpTPVQDecMuWS9nqL).
Nothing is merged. No main update, no production release. No binaries are committed. **No creative acceptance is claimed anywhere in this report.** Independent QA's automated recommendation is **NOT READY** (details in section 5).

## 1. Executive summary

The creator rejected four things in the combined pilot: the Canal passage was still a screen wipe, the staircase was not full-screen, stair motion was a held sprite, and level geometry still allowed unintended areas. Wave 3 produced a candidate for each.

- **Transition (TR-08):** both stair directions (R14 and R17) now play a dedicated full-screen stage with Kaze climbing or descending, and both Canal directions show Kaze turning into the doorway, crossing and emerging. The wipe and the bottom destination label stay as supporting effects. Issue #42 reliability is unchanged (305 pass / 0 fail).
- **Art (ART-08):** 11 real multi-frame strips (7 stair, 4 doorway), built as script-authored cut-out rigs from approved drawings. No generative model was used and no Higgsfield credit was spent. One doorway turn is a stand-in from PR #41 and one (`door_turn_to_side`) is unfinished with no PNG. All are "candidate" quality at best and none is creator-approved.
- **Level (LD-05):** a visible masonry roof course on every room removes every measured wall-jump escape (131 of 928 probes to 0), plus targeted door and shelf fixes. The roof course covers the creator-approved R0 to R7 as well; it is switchable.
- **QA:** automated gates not all met (four of 15 acceptance items fail by small margins; no hard regression).
- **Build:** all five variants built on hosted Windows x86_64 and macOS Universal (Intel host) plus an Apple Silicon launcher smoke. Package bytes were not downloaded or independently verified from this sandbox.

Recommended next step: the creator plays the combined package (and the control for comparison) and decides the items in section 9, then a short fix round addresses the QA items.

## 2. Status of every specialist

| Order | Agent and model (requested) | Branch | Head SHA (verified via GitHub API) | Draft PR | Status |
| --- | --- | --- | --- | --- | --- |
| 1 Transition TR-08 | Opus requested (not self-reported) | `feature/tr08-fullscreen-embodied-cinematics` | `45d669703349fbeafd5a28c1871980691d1a6e6f` | [#64](https://github.com/cappy2yappy/momentum-fractured/pull/64) | Delivered. Head differs from the packaged `308bbf10` only in tests and docs. |
| 2 Art ART-08 | Sonnet requested | `art/art08-embodied-cinematic-animation` | `61b321944f44df573a0d9d5d231d3d358823ef0d` | [#62](https://github.com/cappy2yappy/momentum-fractured/pull/62) | Delivered with gaps (one stand-in, one unfinished clip). |
| 3 Level LD-05 | Sonnet requested | `feature/ld05-intentional-world-boundaries` | `a6e3de254185cb76b1546c2723b707f4154e9f68` | [#63](https://github.com/cappy2yappy/momentum-fractured/pull/63) | Delivered. Residuals listed below. |
| 4 QA | Sonnet requested | `test/wave3-independent-qa` | `f0c3699b9e1ffaa1053ab03135e5e313e67383a3` | [#65](https://github.com/cappy2yappy/momentum-fractured/pull/65) | Delivered. Recommendation NOT READY (automated gates). |
| 5 Build BUILD-07 | Sonnet requested (self-reported Sonnet 5.5) | `ci/build07-wave3` | `7e5781eefd17dbba9c4e160d623cc67a3a2dfb9c` | [#69](https://github.com/cappy2yappy/momentum-fractured/pull/69) | Packages built; downloads not verified here. |
| Combined test candidate | coordinator | `candidate/wave3-combined` | `cb1a59c4395584c08f6fb4cb45ae8a57fdfcd5f8` (tree `d76d23c9e57b189d29010943cd2ffcd02b35dcaf`) | draft test PR (see section 3) | Merges Level, Art and Transition `308bbf10` onto `49ae3efe`; no conflicts; committed `.pyc` untracked. Does not contain the test-only Transition head `45d66970`. |
| Coordinator report | coordinator | `docs/wave3-coordinator-report` | this PR | see section 3 | This file. |

Models: the requested assignment (Opus for Transition, Sonnet for the rest) was passed to each sub-agent. Only Build and the Transition commit trailers (Claude Opus 5.5 on TR-08 commits) self-identified a model. A monthly spend limit interrupted Transition, QA and Build once (agents were resumed after the 10 pm reset; no work was lost).

Base commits: Transition, Art and Level start from `candidate/pm-pilot-combined` `49ae3efe21dea6a9eba556ce2fbc8299b00412b9` (the combined pilot the creator tested: PR #51 TR06 fix + PRs #55, #57, #58). QA starts from PR #59 `c44f2b81`; Build from PR #56 `34f308ef`. Reference PRs #28, #30, #37, #39, #41, #47, #49, #51, #54 to #61 were read, not modified. ART-07 (PR #53) untouched and excluded.

## 3. Shared interface and coordination

The animation interface `ANIMATION_INTERFACE.md` (v1 written by the coordinator, v2 by Art, Transition changelog) fixed cell 480x724, pivot (240,600), manifest fields and clip names before implementation diverged. Level published `LEVEL_CINEMATIC_IMPACT.md` (no impact on cinematic staging). Art's real strips were copied into the Transition branch by explicit allowlist with SHA256 recorded in `docs/tr08/ART08_BINDING.json`; all 11 PNGs and the manifest were re-downloaded from GitHub and matched.

## 4. Delivered code and artwork

**Transition TR-08** (PR #64): `tr08_stair_stage.gd`, `tr08_canal_doorway.gd`, `tr08_clip_library.gd`, `tr08_clip_player.gd`, `tr08_embodied_cinematics.gd`; old behaviour reachable through `--tr08-off`, `--pm-staged-stair`, `--tr05-plain`, `--tr05-legacy`. Stair about 2.9 s (reduced about 1.3 s); Canal about 1.9 to 3.5 s. Airborne Canal crossings keep the old passage.

**Art ART-08** (PR #62) clip inventory, labels exactly as in `assets/art08/MANIFEST.json`:
- Candidate (script-authored cut-out rig from approved drawings): `stair_ascend_enter/loop/exit`, `stair_descend_enter/loop/exit`, `stair_arrive_idle_settle`, `door_approach_walk`, `door_cross`, `door_emerge`, and `door_walk_out` (an alias of the approach walk file).
- Stand-in: `door_turn_to_rear` (PR #41 `turn_depth` frames, not newly authored).
- Unfinished: `door_turn_to_side` (no PNG; needs 4 drawn keys from layered sources or Aseprite).
- Provenance: no generative models; Higgsfield credits spent 0 of a 40 credit cap.

**Level LD-05** (PR #63): roof course on all rooms (switches `ROOF_ENABLED`, `ORIGINAL_ROOMS_ENABLED`, `--ld05-open-top`), R8 shelf fix, R13 crawlspace plinth, R6 to R7 and R9 to R10 doors redrawn on supports; 21-room audit with 122 findings (`docs/ld05/ROOM_AUDIT.md`), 22 before and after capture pairs re-downloaded and hash matched.

## 5. Native Godot and regression results

Linux, headless Godot 4.6.1, plus software-GL (xvfb, Mesa llvmpipe) subsets. Not Windows or macOS graphics.

| Check | Result |
| --- | --- |
| Issue #42 suite on TR-08 and combined | 305 pass / 0 fail (headless; rendered 305 / 0 on TR-08) |
| 25 stock suites (TR-08 and combined) | 1,617 assertions, 0 failed (baseline 1,607; the extra 10 are replacement stair checks) |
| Core harness (QA) | 460 / 0 |
| TR-08 own suite | 223 / 0 default; 5 / 0 with `--tr08-off` |
| Level `ld05_boundaries` | 156 / 0; all 87 real-key wall chains stop at the roof |
| `native_cinematic_transitions` after test-only update (PR #64 head `45d66970`) | 54 / 0 headless and rendered |
| Reach probe, escapes of 928 | PR #51: 126, PR #61: 131, Level `a6e3de25`: 0 |
| Wave 3 acceptance (QA, combined `cb1a59c4`) | 104 pass / 9 fail / 6 skip; 4 of 15 items fail |

QA defects (reproductions in `docs/agent_handoffs/QA_W3_PM_REPORT.md`):
1. **Stair true animation:** 88% (ascent) and 89% (descent) of moving windows show a pose change against a 90% gate; the one held-pose window is frame 3 of `stair_arrive_idle_settle` about 2.1 s in.
2. **Stair letterbox:** 3.9% bars against a 2% limit (top debug label strip and bottom destination bar); the stage fills the viewport and Kaze reaches 65% of viewport height. Needs human judgement.
3. **Missing art:** `door_turn_to_side` has no PNG.
4. **Routes:** three route pairs lost against PR #61: R13 (existed only through an escape, not legitimate), R16 (vanishes with longer probes), R15 base-kit pair (inconclusive; Level should confirm R15 is not entered without Windstep).
5. **Canal presentation:** world-camera, not full-screen (Kaze 34% and 23% of viewport height); informational, not an acceptance item.
6. **Art measurements (heuristic):** Kaze about 308 px tall in the cell, so cinematic height is a 1.8 to 2.3x upscale; foot slide up to 19 px, and 29 to 102 px on the settle clip against Art's claim of 1.5 px.
7. Preservation script exits 1 on Level and combined (`expansion build_room PR37 function exact`), a note because Level edits `build_room`.

Other known items: in reduced motion at the start of the R17 to R14 descent Kaze is partly cut off at the right stage edge (product-script change needed, not done). The roof band is in camera view on 36 and 144 ticks of the two stair runs but is covered by the opaque stair stage; QA never saw it clip a Canal sequence, and its roof-visibility checks need a human look at captures. Level residuals: 38 strips of space past doors still reachable, some bare wall columns, 19 ledges bump the roof on a full double jump (QA did not verify none is a required route), R6 and R9 shelves still physically offset from their doors, kunai gates can still be bypassed by wall jump.

## 6. Screenshots, previews and build links

Captures (software GL, inspected by the authors and by the coordinator for the Art sheet): `docs/tr08/captures/` (PR #64), `docs/art/art08/` previews and `godot_capture/all_clips_sprite2d_capture.png` (PR #62), `docs/ld05/` before and after pairs (PR #63), `docs/wave3/qa/runs/<label>/` (PR #65).

Playable packages: Actions run [39366130916](https://github.com/cappy2yappy/momentum-fractured/actions/runs/39366130916) (head `cb42293b`, success), artifact retention 30 days. Windows artifacts expire 2026-11-19 about 03:52 to 03:55 UTC and macOS artifacts about 04:07 to 04:14 UTC (the evening of November 18 in New York). GitHub-recorded outer SHA-256 digests (copied from the API, not recomputed):

| Variant | Source SHA | Windows artifact id and outer SHA-256 | macOS artifact id and outer SHA-256 |
| --- | --- | --- | --- |
| `w3-control` | `49ae3efe` | 12240245612 `e6ce37b834305b1ffd145d0639e4c11d8a72589c4b9de649a78834dfe2a0256d` | 12240740248 `5705548a7e34e7aae5b5ea622012da0baafb9e2b3c0e4d7568924bda9065eccc` |
| `w3-transition` | `308bbf10` | 12239328676 `6e9711bd23e8d25d49689b18c5e744d0292b1c9d098275ac5aff7c5453139bee` | 12239993580 `8bd0e953a5b2b1f6dedf98c8272506449a81d6a388babb861e91bccdbd2b13aa` |
| `w3-level` | `a6e3de25` | 12239557106 `f5b760881677156b52c477b9d68edd88a53549a6dca16e6f49ccdd516084d7a0` | 12239818632 `73573b294e4d73dafe67f8f93a68166043b75749a5dcec2d7b6b906b35f7aed2` |
| `w3-art` | `61b32194` | 12239786712 `b77244e183122c03991f95765237719f5508bb7c5e0359544b8f11f6006b0c3d` | 12240008505 `8bf6ebf3cd6ed2173997b3b56865332bdf95b406a9c84311df17feb163c8bdd4` |
| `w3-combined` | `cb1a59c4` (tree `d76d23c9`) | 12239836292 `c8ad6b55953c99869c7dfef1c2bcffb420f8129fcae9ce4f08cb5031deeb458e` | 12240491121 `3d97936571cfadb4f2cdc551c57ef396a193c84a55af5c999ae0b0620e74886e` |

Artifact URL pattern: `https://github.com/cappy2yappy/momentum-fractured/actions/runs/39366130916/artifacts/<id>` (sign in to GitHub). Inner ZIP hashes and `PMPILOT-QA-*` evidence artifacts are listed in `docs/agent_handoffs/BUILD07_PM_REPORT.md` (PR #69). The art-only package ships assets but nothing in its source draws them, so it shows no new presentation. Packages are unsigned and unnotarized, internal playtest only, not a release.

Launch (details and checklist in the Build report): extract the package fully in a writable folder; Windows run `Play-<Name>.cmd`, macOS `Play-<Name>.command` (unsigned: right-click Open). Launchers: `Play-Fresh`, `Play-Stair-Fullscreen` (press E at R14), `Play-Stair-Return` (E at R17), `Play-Canal-Doorway` (hold A, no E), `Play-Canal-Return` (E at the R0 door), `Play-Geometry-Test`, `Play-Geometry-OpenTop`, `Play-Reduced-Stair`, `Play-Reduced-Canal`. Each variant has its own isolated save and user data. Compare in order: control, transition, level, art, combined.

## 7. GitHub delivery verification

- Every branch head above was re-read through `gh api repos/.../commits/<branch>` by the coordinator at report time.
- Art re-downloaded all 11 shipped PNGs from GitHub at `61b32194` and matched its manifest SHA256; Transition's copies of those 11 strips plus the manifest were re-downloaded and matched; Level re-downloaded 22 capture pairs and matched.
- **Not verified:** package bytes. The sandbox cannot download Actions artifacts (empty file from the blob host), so `verify_download.py` was not run. Verify with: `python tools/pmpilot/verify_download.py --run 39366130916 --clone <full clone> --downloads <empty dir> --out <empty dir> --require-complete` on a machine with GitHub access.
- Build could not read any package manifest or the QA artifacts, so the per-package INVENTORY results and the in-package QA harness output are asserted by the build, not confirmed by us.
- Build incidents: `source_art/art08` had no `.gdignore` (about 80 source files went into the pack and failed the first art and combined builds); the build now adds an untracked `.gdignore` and records it in each manifest as `build_overlays`. Art should commit the real file. The exported-pack test `native_cinematic_transitions` failed on TR-08; Build made it informational for `w3-transition` and `w3-combined` only with the FAIL lines recorded in their manifests. Transition later showed the cause was stale timing in the test and fixed it test-only (54 / 0); the packaged sources therefore predate that fix. One earlier run (39364847805) is superseded.
- Hygiene: the committed `tools/pm_pilot_art/__pycache__/*.pyc` inherited from the pilot is untracked on `candidate/wave3-combined` but remains on `art/pm-pilot-passage-cinematic` and `candidate/pm-pilot-combined`.

## 8. Known defects and incomplete animation

- Stair motion is a stride cycle on stairs that are out of scale with Kaze (188 px pitch against a 131 px leg), so it reads as bounding strides; the creator must judge whether that is genuine ascending animation.
- `door_emerge` arms barely move and the clip ends in a front three-quarter pose; the engine cuts or dissolves to `door_walk_out`.
- Descent and the left-exit doorway turn play right-facing clips mirrored, which puts the asymmetric ribbon on the wrong side.
- The R0 end of the Canal uses the existing small door, so Kaze emerges in front of it without being framed by an opening.
- `door_turn_to_rear` is a PR #41 stand-in; `door_turn_to_side` is unfinished (uses a labelled stand-in made of approved idle frames, not a turn).
- Cinematic scale is an upscale of about 308 px source art, not new 560 to 720 px art.
- Not tested: Windows or macOS graphics, gamepad, sustained FPS, a full unseeded campaign, the 4 s watchdog path, a human playthrough, Apple Silicon beyond a headless launcher smoke.

## 9. Creator decisions required

1. Visual and feel acceptance of the stair cinematic and the Canal doorway sequence (full-screen, real motion, the mirrored clips, the stride length, the letterbox bars and debug label strip).
2. Whether the Level roof course stays: it is visible, but it is a ceiling over every room including the approved R0 to R7 (`ORIGINAL_ROOMS_ENABLED`, `ROOF_ENABLED` and `--ld05-open-top` switch it off). The order said no blanket ceilings; this is for you to rule on.
3. Who draws the missing animation: the 4 `door_turn_to_side` keys, a proper `door_turn_to_rear` (mirror versus new drawing) and any redraw of the stair stride (needs your layered sources or Aseprite).
4. Whether the QA gates (90% pose-change windows, 2% letterbox) should be fixed in product (a short fix round) or accepted pending your playtest.
5. Whether the remaining Level residuals (past-door strips, bare wall columns, kunai gate bypass, R6 and R9 shelf offsets, R15 Windstep question) need another round.
6. Approval to rebuild packages from the test-fixed Transition head `45d66970` with the native test gating again (cheap).
7. Review and commit of Art's `.gdignore` and removal of the committed `.pyc` files before any merge; the preservation-script exception for the `build_room` edit.

## 10. Recommended integration order (nothing merged without your approval)

1. Creator playtests the five packages (after verifying downloads) and answers section 9.
2. Short fix round: Transition (stair settle held frame, letterbox label strip, descent edge framing), Art (settle clip, committed `.gdignore`, `.pyc` removal), Level (R15 confirmation).
3. Rebuild from the fixed heads; QA reruns.
4. Integrate in this dependency order onto the chosen gameplay base: PR #51 (TR06 reliability), then LD-05 (#63, if the roof stays), then ART-08 (#62), then TR-08 (#64); PR #56 and #69 build tooling and PR #65 tests are separate lanes. Each step is a separate reviewed merge under creator approval.

Work stops when this session stops. Nothing here continues in the background.
