# TR08 PM report (TRANSITION MASTA, ORDER 1 / TR-08)

## Summary

TR-08 replaces the two transitions the creator rejected:
- **Staircase, R14 <-> R17, both directions:** now a dedicated full-screen cinematic.
- **Canal doorway, R13 left exit <-> R0:** now an embodied passage, in place of the screen wipe.

Both are the default; no flag is needed.

Real ART-08 strips are bound for 11 of the 13 clips. The other two are labelled stand-ins:
- `door_turn_to_rear` is an ART-08 stand-in.
- `door_turn_to_side` is a TR-08 stand-in, because no file exists.

**Creator visual acceptance is pending.** The captures are Linux software GL only.

## Branch, PR, commits

| Item | Value |
| --- | --- |
| Branch | `feature/tr08-fullscreen-embodied-cinematics` |
| Draft PR | #64, base `candidate/pm-pilot-combined` |
| Base commit | `49ae3efe21dea6a9eba556ce2fbc8299b00412b9` |
| Commit 1 | `775ef9ff`: engine side with labelled stand-ins |
| Commit 2 | `afef44ab09ba0af13c260088292ae45a40479a65`: real ART-08 binding |
| Commit 3 | `d41202f8fa62df3be43f099cbf333b4ce95a5423`: captures, README, demo args |
| Final head | This report and the rendered #42 log are in a later commit; see the coordinator reply or `gh api repos/cappy2yappy/momentum-fractured/commits/feature/tr08-fullscreen-embodied-cinematics`. |

**Environment.**
- Model: Claude Opus 5.5 (`claude-opus-5-5`).
- Linux cloud container with official Godot 4.6.1 stable.
- Headless for the suites.
- Captures under xvfb with Mesa llvmpipe, `gl_compatibility` / `opengl3`, 1280x720.
- No Windows, macOS, GPU, gamepad or human run.

## Files

**New runtime scripts:**
- `scripts/tr08_embodied_cinematics.gd`: the controller and flags.
- `scripts/tr08_stair_stage.gd`: the full-screen stage.
- `scripts/tr08_canal_doorway.gd`: the doorway sequence.
- `scripts/tr08_clip_library.gd`: the manifest-driven clip table and stand-ins.
- `scripts/tr08_clip_player.gd`: `play(clip, heading, start_frame)`, root motion and flip.

**Edited runtime scripts:**
- `scripts/cinematic_transitions.gd`: hooks in `intercept`, `present`, `room_loaded`, `cancel`, F6 and `begin` (camera guard), plus `last_dt`. `update()`, `endpoints()`, `supported_exit()`, `arrival_position()` and `passage_allowed()` are unchanged.
- `scripts/transition_pilot_data.gd`: `TR08` data block.
- `world.gd`, `player.gd`, `hud.gd`, the graph, gates, saves and the Canal or Level files are **not** edited.

**Assets.** `assets/art08/MANIFEST.json` plus the 11 strips and their `.import` files. They were copied byte-exact by allowlist from Art head `61b321944f44df573a0d9d5d231d3d358823ef0d`. Hashes are in `docs/tr08/ART08_BINDING.json`:
- 11 of 11 match the manifest SHA256 and bytes.
- I re-downloaded them from GitHub at `afef44ab`: 12 of 12 match locally, including the manifest.
- `door_turn_to_side` was not copied (status unfinished, no PNG).

**Tests and tools:**
- New: `tests/tr08_embodied_cinematics.gd`, `tests/capture_tr08.gd`, `tools/tr08_contact_sheet.py`.
- Reviewed edits: `tests/cinematic_transitions.gd`, `tests/world_expansion.gd`, `tests/level_geometry.gd`, `tests/pm_canal_left_passage.gd`. Old versus new is in `docs/tr08/TEST_CHANGES.md`.
- The issue #42 suite was not touched.

**Docs:**
- `docs/tr08/README.md`
- `docs/tr08/DEMO_ARGS.md` (also copied to `/home/claude/wave3_shared/TR08_DEMO_ARGS.md`)
- `docs/tr08/TEST_CHANGES.md`
- `docs/tr08/ART08_BINDING.json`
- `docs/tr08/fixtures/*.json` (4 isolated-save fixtures)
- `docs/tr08/captures/`

**Interface.** I added a v2.1 changelog line to `/home/claude/wave3_shared/ANIMATION_INTERFACE.md`. It is additive, describes how the engine consumes the clips, and asks Art to change nothing.

## Clip binding state (honest)

| Clip | State |
| --- | --- |
| stair_ascend_enter / loop / exit | **ART-08 candidate, bound.** Multi-frame cut-out rig with real limb change. |
| stair_descend_enter / loop / exit | **ART-08 candidate, bound.** Played mirrored for the leftward R17 to R14 descent. Mirroring flips the ribbon side, which is a creator decision. |
| stair_arrive_idle_settle | **ART-08 candidate, bound.** |
| door_approach_walk | **ART-08 candidate, bound.** |
| door_walk_out | **ART-08 candidate, bound.** Alias: same file as door_approach_walk. |
| door_cross | **ART-08 candidate, bound** (rear rig). |
| door_emerge | **ART-08 candidate, bound** (front rig; arms nearly static, per Art). |
| door_turn_to_rear | **ART-08 STAND-IN, bound and labelled `STAND-IN, ANIMATION PENDING`.** PR #41 turn_depth frames, drawn right-to-rear and mirrored for the left exit. |
| door_turn_to_side | **TR-08 STAND-IN, labelled.** Approved idle frames 6,7,0,1. It is not a turn: no ART-08 strip exists. |

"Candidate" means Art's own status: real animation, creator acceptance pending. None of these clips is a single held pose.

**What is staging, not animation:**
- the wipe panels, letterbox and destination plate
- the stage camera pan and its 1.0 to 1.08 zoom
- the stair architecture
- door depth shade and the 0.86 scale
- the aperture clipping
- the doorway layer fading with the loader

## Tests actually run (final code, headless unless stated)

| Suite | Result |
| --- | --- |
| `tr08_embodied_cinematics` (TR-08 on, real ART-08 bound) | **223 / 0.** 226 / 0 with stand-ins only, before binding; the difference is the stand-in-only label checks. |
| `tr08_embodied_cinematics --tr08-off` | **5 / 0.** PR61 behaviour reachable. |
| `automatic_passage_reliability` (issue #42), headless | **305 / 0.** Unchanged file. |
| `automatic_passage_reliability`, rendered under xvfb | See the appendix: added when it finished, or reported as not finished. |
| `pm_staged_stair_cinematic --pm-staged-stair` | **50 / 0.** Unchanged file. |
| `pm_canal_left_passage` | **56 / 0**, after 2 reviewed bounded waits. |
| `tools/run_tr05_qa.py`, 25 stock suites | **1,617 / 0 / 0 script errors.** Baseline was 1,607; `cinematic_transitions` went from 368 to 378 with the replacement stair checks. Every other suite count is identical to the baseline. |
| `canal_geometry` | **173 / 0**, same as the baseline. |

Measured with the real ART-08 clips:
- **Stair, cinematic:** 2.87 s on the stage clock and 2.9 s from the E press, in both directions.
- **Stair, reduced motion:** 1.33 to 1.37 s.
- **Canal R13 to R0:** 1.92 s. **Reduced:** 1.45 s.
- **Canal R0 to R13:** 3.0 to 3.5 s, including the walk to the R0 door and the walk out. **Reduced:** 2.5 s.

Interruptions return control in a valid, supported room every time:
- **Stair:** pause, death and rebuild, each during open, climb before the swap, climb after the swap, and close.
- **Canal:** pause, death and rebuild, each during turn, cross, emerge and turn-out.
- **Watchdog:** fires for both sequences.

Locked gates keep their hints and never start a sequence:
- stair climb, both directions: `Route sealed: CLIMB. Consult the atlas.`
- Canal Windstep, both sides: `Route sealed: WINDSTEP. Consult the atlas.`

Also covered:
- Wrong direction, and stopping short then reversing, never trigger the passage.
- Stopping and reversing back through the opening triggers exactly once.
- Held E or a held direction never loops.
- An airborne crossing keeps the inherited passage.
- The R13 to R14 side passage stays automatic and immediate.
- The R20 wind-fold and plain mode are unchanged.

**Pre-existing failures, not caused by TR-08:**
- `playtest_level_geometry`: 3 / 8 at the baseline, 4 / 7 now.
- `mixed_profile`, `integration_profile` and `art04_profile_options` fail at the baseline. They need launcher flags.
- `native_cinematic_transitions` times out headless at the baseline (it is a rendered suite). I did not run it rendered. Its stair and Canal checks use fixed tick waits and would need the same reviewed bounded-wait update; that is not done.

## Captures (inspected by me)

`docs/tr08/captures/` holds:
- contact sheets `SHEET_*.jpg`
- key-frame JPEGs (every 4th frame, plus the first and last)
- `captures.json` (room, phase, clip, feet, loader time per frame, and the binding table)

The source is `tests/capture_tr08.gd`: real key events, Mesa llvmpipe, 1280x720 PNGs, converted to JPEG.

Sequences: `stair_14-17`, `stair_17-14`, `stair_14-17_reduced`, `canal_13-0`, `canal_0-13`, `canal_13-0_reduced`.

What I saw:
- **Stair.** The wipe covers. The stage shows Kaze, about 60 percent of the screen height, climbing up-right with the real ART-08 stride. The planted feet sit on the treads (after the sole-seating fix). On the descent she steps down-left. The camera follows. The bottom plate sits inside the letterbox bar. The closing wipe reveals R17 or R14 with Kaze at the arrival point.
- **Canal R13 to R0.** She turns at the door (labelled stand-in) and walks away into the lit aperture behind the ajar leaf, darkening. The room fades while the doorway stays visible, then fades too. In R0 she emerges from the door and turns (labelled stand-in).
- **Canal R0 to R13.** She walks to the R0 door and turns. In R13 she emerges from the Canal aperture, turns, and walks right to (184,1198).
- **Labels.** The yellow `STAND-IN, ANIMATION PENDING · <clip>` label is legible above the door, and in the top bar on the stage.

## Known limits

1. **Creator acceptance.** No creator acceptance of anything here.
2. **Mirrored clips.** The stair descent and the left-exit door turn play mirrored clips, which flips the ribbon side. Whether that is acceptable is a creator decision. Art supplies right-facing clips only.
3. **Stand-ins.** `door_turn_to_rear` (ART-08 stand-in) and `door_turn_to_side` (no file) are still stand-ins, and both are labelled on screen.
4. **Stair proportions.** Art reports that the ART-08 stairs are out of scale with Kaze, with a 188 px tread pitch, so the climb reads as long bounding strides. The stage treads follow the clips.
5. **Upscaling.** Cinematic scale is an upscale of a Kaze about 308 px tall, so it is softer than native art.
6. **R0 door.** The R0 end uses the existing small legacy door. Kaze emerges in front of it without aperture clipping, because that door is about as tall as she is. Whether R0 needs its own door art is a creator, Level or Art question.
7. **Pause.** Pause aborts the visual sequence. Before the swap, control stays in the source room. After it, the inherited loader finishes.
8. **Speed after the Canal passage.** Velocity is zero after the passage: she has walked through a door, so the side-passage momentum carry no longer applies there.
9. **Exported builds.** Nothing was tested on an export, Windows or macOS.

## Inputs consumed

- `/home/claude/wave3_shared/COMMON.md`
- `ANIMATION_INTERFACE.md` v1, then v2
- `ART08_MANIFEST_SKELETON.json`
- `ART08_INTEGRATION.md`
- `LEVEL_CINEMATIC_IMPACT.md`: no impact. LD-05 adds an R13 footing under the pad, a roof course above y 56, and R8, R6 and R9 door fixes. None of them touches the Canal rectangles or the stair endpoints.
- `/home/claude/pilot_shared/CANAL_CONTRACT.md` v1: adopted unchanged.

## Next actions

1. **Creator:** review the stair and Canal captures, or the four launchers. Decide on mirroring and on the R0 door.
2. **Art:** `door_turn_to_side`, plus a newly authored left-facing `door_turn_to_rear`. Both bind by path with no code change.
3. **Coordinator / QA:** run the W3 hooks on the head SHA. The stage is a visible CanvasLayer at layer 6, and the doorway layer is layer 2 (follows the viewport). Then update `native_cinematic_transitions` waits if that suite is kept.
4. **Build Shogun:** use `TR08_DEMO_ARGS.md`.

## Appendix: rendered issue #42 run

`tests/automatic_passage_reliability.gd` was run at head `416b0f52` under xvfb with Mesa llvmpipe (`gl_compatibility` / `opengl3`, 1280x720, `--fixed-fps 60`), run directly with a 3500 s limit.

Result: **305 / 0, exit 0**, identical to the headless run and to the PR51 rendered baseline.

Log: `docs/tr08/evidence/rendered_xvfb_automatic_passage_reliability.log.txt`.

## Appendix: native_cinematic_transitions (test-only follow-up)

Build's exported-pack run reported `tests/native_cinematic_transitions.gd` failing on TR-08. On the source tree the original file gives 7 failures out of 54. All 7 come from fixed tick waits that observe while the TR-08 doorway or stair sequence is still running, so they are stale timing, not a regression.

I updated the file with bounded waits, the reduced flag, and a headless skip in `shot()`. Details are in `docs/tr08/TEST_CHANGES.md`. Results:
- Headless: **54 / 0.**
- Rendered under xvfb: **54 / 0.**

No product file changed in this follow-up.

Visual nit seen in the rendered native shots, not fixed under this test-only order: in reduced motion the fixed stage framing centres on the whole flight. At the very start of the R17 to R14 descent, Kaze is partly cut off at the right edge. A later product change should clamp the reduced framing to keep the figure on screen.
