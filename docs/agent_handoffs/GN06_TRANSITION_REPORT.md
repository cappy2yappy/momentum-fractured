# GN-06 (Transition): Gale Dash across the R6 exit misses the R7 transition

## Summary

The R6 to R7 automatic exit missed a Gale Dash across its sill. I reproduced the bug, traced it per tick, and fixed it in Transition's trigger rule. The fix touches the arming test only: one line plus one constant in `scripts/cinematic_transitions.gd`.
- Player physics, dash and the crossing rule are unchanged.
- The Canal Return, Canal OUT, ascent and descent timelines are unchanged against the previous head.

## Branch and commits

| Item | Value |
| --- | --- |
| Branch | `fix/gn06-dash-r6-r7` (no PR opened) |
| Base | PR #64 head `ed1875307e21f057add025ebebdec1e3f371e90f` |
| Merged | Level PR #63 head `30155f55d2f9593e1a0ed371fcc4149a3acbce2b`, merge commit `df78d5b`, no force push |
| Fix and tests | the commit carrying this report. The exact head is in the coordinator reply and `gh api repos/cappy2yappy/momentum-fractured/commits/fix/gn06-dash-r6-r7`. |

**Merge note.** Before merging, I moved untracked local Godot caches aside into the scratchpad: 61 `.uid` and `.import` stubs that the merge would have overwritten with Level's tracked copies. Nothing tracked was touched, and Level's files are taken as committed.

**Environment.** Claude Opus 5.5, Linux cloud container, Godot 4.6.1 stable, headless.

## Reproduction

`tests/ld07_dash_regression.gd` (Level) on `df78d5b`:
- `GN06 room=6 feet=(2585.997, 1089.998) requests=0`
- FAIL: "dash across R6 sill should request R7 automatically"

## Trace (per tick, real keys: R6 feet (2300,1108), hold D, Shift at tick 8)

- **Exit endpoint:** (2440,1090), heading +1. Its arrival point is (2376,1108) on the approach floor `Rect2(2020,1110,580,40)`, top y 1110, 20 px below the endpoint. LD-07 seated the door on that floor; the sill rises to 1090 at x about 2390 to 2440.
- **The rule:**
  - The crossing needs the feet inside the corridor y 1000 to 1098 (`at.y-90` to `at.y+8`) on two consecutive ticks.
  - It also needs the trigger to have been ARMED earlier. Arming means being at least 16 px inward of the line while inside that same corridor.
- **The dash:** 920 px/s for 0.18 s, about 15.3 px per tick. Kaze climbs the sill, as recorded by the world update each tick:
  - x 2400.96 / y 1098.64: 0.64 px below the corridor
  - x 2410.99 / y 1091.35: inside the corridor, but the previous tick was outside
  - x 2426.33 / y 1091.81: inside, but only 13.7 px inward, so the 16 px arm test fails
  - x 2441.34: crossed, but never armed
- **Result:** `armed` stays false, so neither the crossing nor the supported recovery can fire. Kaze stops against the room wall at x 2586.
- **Why walking works:** at about 6.7 px per tick, walking always gets one in-corridor tick at least 16 px inward.

Not involved:
- velocity direction: +920, correct
- grounded state: `is_on_floor` true throughout
- the sill collider: it lifts her smoothly
- cooldown: 0
- tether: none

## Fix (`scripts/cinematic_transitions.gd`, `update()`)

The **arming** test also accepts an inward position (at least 16 px, both ticks) on an approach floor up to `ARM_BELOW = 40` px below the endpoint y (one platform thickness), as well as inside the corridor. For R6 that covers the floor at 1110 under the 1090 sill.

Unchanged:
- the crossing corridor, threshold line and intent
- the supported recovery and cooldown
- arrival points
- the Canal numbers in `transition_pilot_data.gd`
- player physics, including dash

Why this is safe:
- Arming only states that Kaze has been inward of the threshold.
- Stationary, reversed and wrong-direction approaches still never fire, because the crossing itself is unchanged.
- At every automatic exit the arrival point is already inside the arm area, so arrival behaviour is the same as before (cooldown, then a crossing needs real motion outward).

## Tests (after the fix, headless)

| Suite | Result |
| --- | --- |
| `tests/ld07_dash_regression.gd` (Level reproducer) | **2 / 0** (was 1 failure) |
| New `tests/gn06_dash_offsets.gd` at `--fixed-fps` 30 / 60 / 144 | **5 / 0** at each rate, 261 dash cases each |
| Same new suite on pre-fix `df78d5b`, 60 fps | **1 failure:** 27 of 105 R6 dash cases miss |
| `automatic_passage_reliability` (issue #42) | **305 / 0** |
| `tr08_canal_hang_regression` | **53 / 0** |
| `tr08_embodied_cinematics` / `--tr08-off` | **226 / 0** and **5 / 0** |
| `tr08_stage_labels` | **7 / 0** |
| `native_cinematic_transitions` | **54 / 0** |
| `ld05_boundaries` | **172 / 0** |
| `tools/run_ld07_qa.py` | ld07_ground 154, ld05_boundaries 172, canal_geometry 173, automatic_passage_reliability 305, pm_canal_left_passage 56, audit_intentional_space 21, level_geometry 78, save_compatibility 11, expansion_gates_save 17, expansion_traversal 125, cinematic_transitions 378: **all 0 failures** |
| `pm_staged_stair_cinematic` | **50 / 0** |
| `tools/run_tr05_qa.py` | **1,617 / 0 / 0** |

What the new suite covers:
- R6: 15 start offsets (x 2140 to 2420) x 7 dash tap times = 105 cases
- every automatic exit dashed from its arrival point at 4 tap times
- a plain walk across the R6 sill
- standing on the lower floor and walking away never request

`tests/ld07_before_reproduction.gd` gives 3 failures here and identically on `df78d5b`. Its own header says to run it only against the pinned pre-repair `49ae3efe`, where PASS means "defect reproduced". It is not a regression.

The rates in the new suite affect the render frame step only: physics stays at 60 Hz, so the per-tick results are identical across them.

## Timelines (`tests/tr08_timeline_dump.gd`, `--fixed-fps` 30 / 60 / 144; JSON in `docs/tr08/evidence/timeline/gn06_*`)

| Sequence | vs `869a3aa` | vs the B3a head `ed187530` |
| --- | --- | --- |
| Canal Return R0 -> R13 | 182 vs 182 ticks, **0 differing rows** | **0 differing rows** |
| Canal OUT | 115 vs 115, **0 differing rows** | **0 differing rows** |
| Ascent | differs, known: the ART-08 B3a settle | **0 differing rows** |
| Descent | differs, known: the ART-08 revised descent (`81679650`), positions only | **0 differing rows** |

## Diff summary of the fix commit

- `scripts/cinematic_transitions.gd`: the `ARM_BELOW` constant and the arming test (+6 / -1)
- `tests/gn06_dash_offsets.gd`: new
- `docs/tr08/evidence/`: GN-06 logs and timeline JSON
- this report

No assets, no player, world or level files, and no Level-owned test files are touched.
