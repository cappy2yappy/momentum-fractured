# TR08 Canal Doorway hang: PM report (TRANSITION MASTA)

## Summary

The Play-Canal-Doorway hang (R13 feet (330,1158), hold A, no E) is reproduced and fixed. It had two causes:
1. A pause before the room request left the automatic trigger disarmed.
2. Holding A from the fixture crossed the trigger while still falling, so the embodied passage was skipped.

A third stall (a jump into the back pier) is pre-existing PR61 behaviour and is not changed here.

Play-Canal-Return is unchanged: its full timeline is identical before and after (diffed).

## Branch, PR, commits

| Item | Value |
| --- | --- |
| Branch | `feature/tr08-fullscreen-embodied-cinematics` |
| Draft PR | #64, base `candidate/pm-pilot-combined`. Draft only, no merge. |
| Before (reproduced on) | `079d9b28` |
| Fix commit | `2439d05e618872f60049be4da4cb28fb15ad814e` |
| Final head | This report is in a later commit: see the coordinator reply or `gh api repos/cappy2yappy/momentum-fractured/commits/feature/tr08-fullscreen-embodied-cinematics`. |

**Environment.**
- Model: Claude Opus 5.5 (`claude-opus-5-5`).
- Linux cloud container with official Godot 4.6.1 stable.
- Headless for the suites, plus xvfb with Mesa llvmpipe for the real-time rendered probe.
- No macOS, Windows, GPU or human run.

## Reproduction method

`tests/tr08_canal_hang_probe.gd`:
- Loads the real fixture `docs/tr08/fixtures/TR08-Canal-Exit.json` through the normal save path for every run (`--tr05-save`).
- Drives only real `InputEventKey` presses and `NOTIFICATION_APPLICATION_FOCUS_OUT`. No teleports, no velocity writes.
- Logs per state change: room, TR-08 phase, loader time, pending room, physics on/off, floor contact, position, velocity, clip and frame, trigger armed and cooldown, and keys held.

**111 runs per pass** across 15 families:
- hold A from rest (8 start delays)
- pulsed A (6 gaps)
- release at 9 different ticks
- sprint (3)
- dash (5 timings)
- jumps (10 points x 2 hold lengths)
- stop and reverse at 5 x positions
- E mashing
- idle in the doorway, then A (3)
- focus loss, Esc pause and map toggle at 8 times each
- grounded approach with focus, Esc or map at 9 offsets from the sequence start

**Timing variants:** `--fixed-fps 60`, 30, 144, and real-time rendered (xvfb). I also ran the combined candidate tree `869a3aa`, which includes LD-05: identical tally.

## Causes found

### Cause 1, the hang (TR-08 regression)

- When the automatic trigger in `cinematic_transitions.update()` fires, it disarms itself (`armed[0]=false`), then makes the request that TR-08 owns.
- TR-08 aborts its sequence on pause. Before the room request has been released, that abort leaves the trigger disarmed with Kaze inside the aperture (x 86 to 120).
- Pause happens without the player meaning it:
  - the HUD auto-pauses on `NOTIFICATION_APPLICATION_FOCUS_OUT` (for example the macOS Terminal `.command` launcher or a notification taking focus)
  - Esc
  - M (map)
  - I (kit)
- The supported recovery path requires `armed`, so holding A does nothing. Pressing A again also does nothing; Kaze has to walk back past x=136 and return. The Return direction recovers simply by pressing E again, which is consistent with the creator's verdict.
- The old instant request could not be interrupted before the loader, so this was introduced by TR-08.

### Cause 2, the embodied passage skipped

- Walking off the hallway shelf (x 200, top y 1160), Kaze crosses x=120 about 1 px above the pad. Feet y was 1198.9 in every hold-from-rest run.
- TR-08 accepted only grounded crossings, so the inherited PR61 passage ran instead: Kaze frozen mid-fall plus the wipe.
- At 60 fps this happened in 60 of 60 hold-from-rest runs. Whether she lands before or after x=120 varies with timing.

### Cause 3, pre-existing and not changed

- A jump into the back pier above the trigger corridor (y < 1110) wall-slides Kaze down the pier at the approved 100 px/s, pressed into the doorway with A held. The trigger fires about 1.2 s later, on landing.
- This is identical with `--tr08-off`, the PR61 behaviour (probe `jump_at24_h4`: ticks 42 to 112).
- It comes from approved wall-slide physics and the trigger corridor, which belongs to the CANAL_CONTRACT. Changing it needs Level and creator sign-off, so I have not changed it.

## Fix (product scripts; physics, trigger logic, Return path and ART-08 assets untouched)

1. **Re-arm** (`scripts/tr08_canal_doorway.gd`, `restore()`). If the automatic R13 to R0 sequence ends without completing, before its request reached the loader, and Kaze is still in R13, the trigger's armed state is restored. That covers paused, cancelled and watchdog endings. The crossing then counts as not having happened, and the unchanged supported-recovery path re-fires when A is held.
2. **Land first** (`can_land()`, `begin_landing()`, `tick_landing()`).
   - **When it applies:** only the automatic R13 exit, crossed while airborne within 0.5 s (30 ticks) of being grounded.
   - **What happens:** the request is owned while the live body finishes its fall under unchanged physics and real input. The sprite stays live and nothing is drawn. Once it is grounded inside the aperture, the normal grounded sequence plays.
   - **Fallback:** if the body leaves the aperture, tethers, is frozen externally, or has not landed within 1.5 s, the inherited request is released at once. That is exactly the PR61 behaviour, so a crossing is never lost.
   - **Ground history:** recorded every world tick (`tr08_embodied_cinematics.gd` `observe()`, called from `cinematic_transitions.present()`) and reset on every room build. Fixture loads and test rebuilds never inherit it.

Data block: `transition_pilot_data.gd` TR08.canal `land_recent_ticks: 30`, `land_timeout: 1.5`.

## Reproduction rate, before and after (honest numbers)

| Probe (111 runs each) | Stuck in R13 holding A | Embodied passage played |
| --- | --- | --- |
| Before, `079d9b28`, 60 fps | **15 of 111.** All 15 of the 15 interruptions that landed before the request: 5 focus, 5 Esc, 5 map. | 37 of 111 (hold from rest: 0 of 8) |
| After, `2439d05e`, 60 fps | **0 of 111** | 110 of 111 |
| After, 30 fps / 144 fps | 0 of 111 / 0 of 111 | |
| After, real-time rendered (xvfb) | see the appendix | |

In every pass, the one run that is neither stuck nor completed is `release_at20`: A is released before the shelf edge and Kaze correctly stops on the shelf.

**Before, at 30 / 144 fps / real-time:** those first probe passes did not yet contain the grounded-interruption family. They gave 0 stuck runs, with every hold-from-rest run taking the inherited mid-fall wipe.

## Tests actually run (after the fix, headless unless stated)

| Suite | Result |
| --- | --- |
| New `tests/tr08_canal_hang_regression.gd` (deterministic, real keys, real fixture) | **53 / 0.** On the pre-fix tree `079d9b28`: **53 checks, 26 failures.** |
| `tests/tr08_embodied_cinematics.gd` | **224 / 0.** The airborne case was updated: it now asserts the land-then-embodied behaviour. |
| same with `--tr08-off` | **5 / 0** |
| `tests/automatic_passage_reliability.gd` (issue #42), headless | **305 / 0.** Unchanged file. Rendered run: see the appendix. |
| `tests/native_cinematic_transitions.gd`, headless | **54 / 0** |
| `pm_staged_stair_cinematic` | **50 / 0** |
| `pm_canal_left_passage` | **56 / 0** |
| `tools/run_tr05_qa.py`, 25 stock suites | **1,617 / 0 / 0** script errors |
| `canal_geometry` | **173 / 0** |

The regression suite's 26 pre-fix failures are:
- 4 x hold A from rest skipping the embodied doorway
- 18 x interruption before the request leaving Kaze stuck
- 2 x interruption while landing
- 1 x double interruption retry
- 1 x pressing A again after an abort

**Return preserved.** I diffed the `TR08 CANAL 0->13` timeline lines from `tr08_embodied_cinematics` before and after the fix: identical. That covers duration, clip order and per-clip start times, normal and reduced.

## Limits

- Not tested on macOS. Focus loss is simulated with the real notification the engine delivers. The creator's actual trigger (focus loss, Esc or map) is inferred, not observed.
- I can't rule out a cause that only appears on the creator's hardware or in its export. I checked the exported pack: `assets/art08/MANIFEST.json` and the strips are included, and the clips bind inside the pack (`--export-pack` plus a `--main-pack` check).
- The pier wall-slide stall (cause 3) remains, as in PR61.
- `door_turn_to_side` (the TR-08 stand-in) plays in the R0 arrival as before. It is not involved in the hang.
- ART-08's revised descent (asset commit `750e194f`, new `stair_descend_arrive_settle`) is not bound yet. That stair change is separate from this fix.

## Appendix A: rendered results for the fix

- **Real-time rendered probe** (xvfb, Mesa llvmpipe, no `--fixed-fps`), at `2439d05e`: 111 runs, **0 stuck.** 110 completed; the one other run is `release_at20`, an expected stop on the shelf. Log: `docs/tr08/evidence/hang/probe_after_realtime_rendered.log.txt`.
- **Issue #42 `automatic_passage_reliability`, rendered** under xvfb at `2439d05e`: **305 / 0, exit 0.** Log: `docs/tr08/evidence/hang/rendered_xvfb_automatic_passage_reliability_2439d05.log.txt`.

## Appendix B: ART-08 revised descent bound (separate commit, after the hang fix)

Applied the coordinator-requested patch `/home/claude/w3-art/docs/art/art08/descent/transition_settle_patch.diff`. It applied cleanly to `tr08_clip_library.gd` and `tr08_stair_stage.gd`:
- adds the new clip `stair_descend_arrive_settle`, with a labelled stand-in row
- the settle name checks
- the descent now ends on `stair_descend_arrive_settle`, the ascent on `stair_arrive_idle_settle`

Assets were copied byte-exact by allowlist from ART-08 head `81679650bcd0ff8ca6f4b6373b6554027264038a` (interface v3). All 12 strips match the manifest SHA256 and bytes (`docs/tr08/ART08_BINDING.json`):
- **Changed:** `stair_descend_enter`, `stair_descend_loop` and `stair_descend_exit`.
- **New:** `stair_descend_arrive_settle`.
- **Byte-identical:** all door clips, so Canal Return is unaffected.

How the combination binds:
- 12 clips are ART-08 and bound: the 3 descent clips (v2 rig), the new descent settle, the ascent clips, `door_approach_walk` / `door_walk_out`, `door_cross` and `door_emerge`.
- `door_turn_to_rear` is an ART-08 stand-in, labelled.
- `door_turn_to_side` is a TR-08 stand-in, labelled, because no file exists.

Descent order is now enter, loop, loop, exit, `stair_descend_arrive_settle`. Ascent is unchanged. The stage builds the new, shorter descent flight from the v3 root motion; I captured and inspected it in `docs/tr08/captures/SHEET_stair_17-14.jpg`.

Tests with this binding:

| Suite | Result |
| --- | --- |
| `tr08_embodied_cinematics` | 226 / 0 |
| `tr08_canal_hang_regression` | 53 / 0 |
| issue #42, headless | 305 / 0 |
| `native_cinematic_transitions` | 54 / 0 |
| `pm_staged_stair_cinematic` | 50 / 0 |
| `pm_canal_left_passage` | 56 / 0 |
| `run_tr05_qa.py` | 25 suites, 0 failures |

The Canal Return timeline is identical before and after (diffed).

## Appendix C: B1, QA duration difference (Canal OUT/IN, stair about 0.12 s shorter)

**Verdict: the Return timeline did not change. Nothing on the Return path, the Canal OUT path or the stair was restored, because nothing changed.**

**Method.** `tests/tr08_timeline_dump.gd` drives real keys and records every physics tick from the key press until control returns: room, TR-08 phase, clip, frame index, stage/doorway feet, live feet, loader time and physics state. I ran it with `--fixed-fps` 30, 60 and 144 on:
- the combined candidate tree `869a3aa`, extracted by `git archive` into a scratch directory;
- `eb3cc0fa`;
- the B3b head (this commit).

The JSON is in `docs/tr08/evidence/timeline/` (`comb_*`, `cur_*`, `new_*`).

**Result** (all at 30, 60 and 144 fps):

| Sequence | `869a3aa` vs `eb3cc0fa` |
| --- | --- |
| Canal Return R0 -> R13 (E) | 182 ticks vs 182 ticks, **0 differing rows** |
| Canal OUT R13 -> R0 (grounded) | 115 vs 115, 0 differing rows |
| Stair R14 -> R17 | 173 vs 173, 0 differing rows |
| Stair R17 -> R14 | 173 vs 173. 153 rows differ in stage feet positions only: ART-08's revised descent root motion, intended. Same ticks, phases and clip order apart from the new final settle clip. |

The B3b head is identical to `eb3cc0fa` in all four sequences at all three rates.

**Why QA saw 0.12 s.** QA's own logs report two numbers for **every** SHA, including `775ef9ff`, `308bbf10`, `cb1a59c` and `c2c3d95`:

| Sequence | Headless | Software GL |
| --- | --- | --- |
| Canal OUT | 2.18 s | 2.07 s |
| Canal IN | 2.38 s | 2.25 s |
| Stair | 2.88 s | 2.75 s |

The difference is headless versus rendered measurement within the same SHA, not a change between SHAs.

Mechanism in `tools/pm_pilot_qa/hooks/w3_lib.gd` `drive()`:
- the duration is the loop's own iteration count (`end/60`);
- in rendered mode, every grab tick also awaits `process_frame` and `frame_post_draw`;
- physics ticks keep advancing during those awaits but are not counted, so rendered durations come out short.

A fix for QA would be to measure with `Engine.get_physics_frames()` deltas.

## Appendix D: B3b, stair letterbox (3.9 percent vs the 2 percent gate)

**Cause.** The stair stage drew a developer clip-status line (for example `ART-08 · stair_descend_arrive_settle`) inside the top letterbox bar. The reduced-motion note sat in the bottom bar. QA's detector counts uniform rows from each edge, so the text broke the top band.

**Change** (`scripts/tr08_stair_stage.gd` `top_label()`, `plate_alpha()`; flag `--tr08-debug-labels` in `transition_pilot_data.gd`; `tr08_embodied_cinematics.gd` `debug_labels`):

| Text | Shown when |
| --- | --- |
| Top-bar clip line for a **bound ART-08 clip** | Only with `--tr08-debug-labels` |
| Top-bar line for a **true stand-in** (TR-08 stand-in, or an ART-08 clip with status `stand_in`) | Always, `STAND-IN, ANIMATION PENDING ...`, as the interface requires. No stair clip is a stand-in now, so normally nothing is shown. |
| Reduced-motion note | Only with the flag |
| Bottom destination plate (`ASCEND > ...` / `DESCEND > ...`) | Unchanged |

The Canal doorway (both directions, including the creator-rated Return) is untouched. Its in-world stand-in tags for `door_turn_to_rear` and `door_turn_to_side` still show, because those clips are stand-ins.

**New test `tests/tr08_stage_labels.gd`:**
- Headless: **7 / 0.** No top line for bound clips in either direction (120 samples each). The plate is shown. A forced stand-in is labelled without the flag. The flag shows the ART-08 clip names.
- Rendered (xvfb): **9 / 0.** Adds a pixel check: the top band is 56 uniform rows in every mid-climb sample.
- Before the change, captures of the same frames measured 25 to 27 uniform rows (text at y about 30).

**Tests at the B3b head:**

| Suite | Result |
| --- | --- |
| `tr08_embodied_cinematics` | 226 / 0 |
| `tr08_canal_hang_regression` | 53 / 0 |
| issue #42, headless | 305 / 0 |
| `native_cinematic_transitions` | 54 / 0 |
| `pm_staged_stair_cinematic` | 50 / 0 |
| `pm_canal_left_passage` | 56 / 0 |
| `run_tr05_qa.py` | 1,617 / 0 / 0 |
