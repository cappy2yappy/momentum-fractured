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
