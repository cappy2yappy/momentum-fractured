# TR-08 reviewed test changes

TR-08 makes two presentations the default: the R14/R17 staircase is now a full-screen cinematic, and the Canal doorway (R13 left exit and R0) is now an embodied passage. Each one runs for a short time before it releases the existing room request. The loader itself is unchanged: 0.65 s, with the hidden swap at 0.33 s.

Some existing assertions assumed the old presentations. They expected the request to start the instant E was pressed or the crossing happened, or they waited a fixed number of ticks before checking. This file lists every existing assertion TR-08 touched.

Every replacement keeps the property the original asserted:
- exactly one request
- the unchanged loader clock
- an unchanged arrival point
- the live character restored
- the camera restored
- the body never driven

They replace only the timing or the observation point. No assertion was deleted without a replacement, and no threshold was loosened. New coverage lives in `tests/tr08_embodied_cinematics.gd`.

## tests/cinematic_transitions.gd (stock TR05 suite): staircase block

This is the change the coordinator asked for: the old suite encoded the 0.65 s stair. Without the change, 12 checks failed, at 4 assertion sites per direction and mode. The PR57 report counted 9 for its own one-direction pilot.

| Old assertion | Why it no longer holds | Replacement (same property) |
| --- | --- | --- |
| `Stair %s uses E and existing clock`: `transition==0.65` right after E | E now opens the stage first. The loader starts when the stage covers the world, after 0.30 s (0.15 s in reduced motion). | Two checks. `Stair %s E opens the TR-08 full-screen stage`: the stage phase is open and `transition==0`. `Stair %s releases the existing loader clock under the cover`: within 40 ticks, `transition>0.6` and `pending_room==target`, so the same 0.65 s loader is used. |
| `Cinematic stair visibly moves Kaze along correct rise`: embodied proxy displacement over 12 ticks | Kaze is now drawn on the stage, not by the embodied proxy. | `Stair %s stage visibly moves Kaze along correct rise`: stage root displacement over 12 ticks is more than 25 px, and its sign matches the authored rise. This now also runs in reduced motion, where true frames are still shown. |
| `Cinematic stair gets close-up framing`: world `camera.zoom>1.3` | The world camera is no longer zoomed. The full-screen stage replaces the close-up. | `Cinematic stair is full-screen with Kaze at cinematic scale`: the stage layer is visible and Kaze is drawn at least 360 px tall (50 percent of 720). |
| `Reduced staircase keeps camera and pose stationary`: proxy position equal across 12 ticks, zoom 1 | Reduced motion now shows true frames moving on a fixed stage, instead of a frozen pose. | `Reduced staircase keeps fixed framing and world camera`: stage zoom is 1.0 and world zoom is 1. The fixed stage pan is checked in the TR-08 suite. |
| `Cinematic never drives collision-body root motion`: checked after 15 ticks | By tick 15 the hidden swap has already moved the body to the arrival point, which is expected. | The same check, run at the release tick, before the swap. A new check, `Stair %s arrival feet are the unchanged reciprocal endpoint`, covers the position after the swap. |
| `Stair %s arrives and restores live Kaze`: after a fixed 28 more ticks | The sequence lasts about 2.9 s (1.3 s reduced). | The check runs once the stage reports completion, with a 400-tick bound. The duration is asserted: 2.5 to 4.0 s cinematic, at most 1.6 s reduced. |
| `Camera fully restored after stair %s` | unchanged | unchanged |

Result: 368 checks before, 378 after, 0 failures.

## tests/world_expansion.gd: `Transition exact safe arrival 13 -> 0`, `Arrival settles on safe floor 13 -> 0`

The old version ran a fixed 45 ticks after the crossing. The embodied doorway's turn and cross come before the request, so 45 ticks is too early. The replacement keeps ticking until TR-08 hands back control and the loader has finished: at least 45 ticks, at most 300. The arrival assertions are unchanged. 193 / 0, identical to the baseline count.

## tests/level_geometry.gd: Canal reapproach and the following terrace check

- `Canal left exit reapproach activates with its current passage policy` was `pending_room==0` immediately. It now accepts `pending_room==0` or the TR-08 Canal sequence owning a request for target 0. That is the activation under the current policy, which is what the assertion's own name says.
- The following fixed 41 ticks becomes a bounded wait: at least 41 ticks, at most 300, until control returns. `Canal reciprocal arrival remains supported` is unchanged.
- `Terrace legacy arrival settles above solid shelf` failed only as a knock-on, because the Canal sequence was still running when the next fixture started. It passes again without any change to it.

78 / 0, identical to the baseline count.

## tests/pm_canal_left_passage.gd (PR57 pilot suite)

- `Walking into the opening from just inside activates once`: the fixed 60-tick hold becomes a hold until the room swaps, with a 150-tick bound. The assertion is unchanged.
- `R0 -> R13 arrives in the hallway at the contract arrival`: the fixed 45-tick wait becomes a wait until control returns, with a 300-tick bound. The same contract arrival point (184,1198), within 3 px, is asserted.

56 / 0, identical to the PR61 count.

## tests/native_cinematic_transitions.gd (TR05 native suite)

Build's exported-pack run found this suite failing on TR-08. I reproduced the failure on the source tree: the original file, with only the headless capture guard added, gives 54 checks with 7 failures. All 7 are fixed-time observations that land while a TR-08 sequence is still running:
- `Native physical input crosses [13, 0] without E and lands`: 1 failure. The observation point is 74 ticks after the key press, while the embodied doorway is still playing.
- `Native [13, 0] visible live Kaze restored`: 2 failures. Same cause: the doorway layer is still drawing Kaze.
- `Native E stair_<pair>_<mode> staircase completes safely`: 4 failures. The check runs 56 ticks after E, but the cinematic lasts about 2.9 s (1.3 s reduced).

With the bounded waits below, the same assertions pass. That confirms stale timing, not a regression.

| Change | Old | New (same assertions) |
| --- | --- | --- |
| Passage observation | Hold the key 22 ticks, then a fixed 52 ticks | The same hold and 52 ticks, then wait until TR-08 hands back control and the loader has finished (at most 300 more ticks) |
| Stair observation | A fixed 44 ticks after the `_close` shot | The same 44 ticks, then wait until TR-08 hands back control (at most 300 ticks), plus 3 ticks to settle |
| Stair reduced flag | `c.reduced=still` | Also sets `c.tr08.reduced=still`, so the reduced pass really runs the reduced TR-08 cinematic |
| `shot()` | Always awaits `RenderingServer.frame_post_draw` | Skipped on the headless display server, which never posts a drawn frame. That is why this suite hung at the baseline (exit 124, 0 checks). Rendered runs capture exactly as before. |

Results at this branch: headless **54 / 0**; rendered under xvfb (Mesa llvmpipe, `gl_compatibility`, 1280x720) **54 / 0**, with 37 captures in `build/tr05/native`. Logs are in `docs/tr08/evidence/*native_cinematic_transitions.log.txt`.

## Unchanged and still passing

- `tests/automatic_passage_reliability.gd` (issue #42): 305 / 0, not edited.
- `tests/pm_staged_stair_cinematic.gd`: 50 / 0, not edited. It runs with `--pm-staged-stair`, which turns TR-08 off and restores the PR57 opt-in pilot.
- All other `tools/run_tr05_qa.py` suites: counts identical to the baseline.
