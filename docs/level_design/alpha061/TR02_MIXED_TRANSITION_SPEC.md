# TR-02-0061 — mixed transition specification

Authoritative work order read at `0b9470b71ebd32eaa0d4987cbd23bcde082242bf`. Verified TR-01 baseline `c26cb7fa23131c2fd9c8deae288f7d0d468a6b52`. Feature branch `feature/alpha-0.6.1-mixed-transitions`; review base TR-01. This pilot selection was recorded before runtime edits.

| Mode | Existing edge / feet coordinates | Reciprocal arrival | Prerequisite / rationale |
|---|---|---|---|
| Walk-through | R15 Lower Sluice (2080,1120) ↔ R16 Root Shrine (120,1120) | existing destination feet minus (0,2) | Archive restored in both directions; matching-height dry culvert and shrine approach |
| Interactive control | R14 Bellroof (1450,480) ↔ R17 Spire (1680,1300) | existing destination feet minus (0,2) | Tether + Dash; retain creator-liked R14 service stairwell, E radius85 and exact artwork |
| Special E wind-fold | R20 Junction (600,520) ↔ R13 Loft (900,400) | existing destination feet minus (0,2) | regional Archive/named-sigil/Wind-intake flags + junction return switch; existing shortcut, no new travel power |

Graph remains21 rooms/29 edges. No platform, collision, map cell, checkpoint or save-schema changes. Existing actual request_room/can_enter guards remain authoritative. Converted walk-edge suppresses only its former E activation; all other E edges stay unchanged.

## Walk-through state machine

Exit plane is original endpoint x. Outward direction is +1 in R15, -1 in R16. Must first occupy the approach at least96px inward, then cross the plane outward with signed velocity >20px/s, feet within90px above/8px below its landing height, and no attached tether. Both previous/current samples must be in that corridor. No proximity-only activation. A rejection requires a new inward approach to rearm. A broad visibly locked grille with named requirement appears when closed; threshold cannot set flags.

Room load invalidates position samples, disarms and starts0.75s arrival cooldown; respawn also cancels pending carry. Reverse requires moving inward96px before returning. Frozen/paused/transition intervals invalidate samples. The world request retains0.65s clock and original destination; horizontal velocity is captured at actual crossing and restored at arrival, while vertical velocity is zeroed for the existing dry landing. Tether/dash transient state continues to reset exactly as the loader already does. This is horizontal momentum continuity through a discrete room load, not seamless streaming or unchanged air-state continuity.

## Presentation

Default graphic mode uses Kaze-original angled indigo/rose wind-cloth panels, pale thread lines and a brief destination badge below top HUD. No borrowed Persona artwork, font, logo, music or animation sequence. The presentation uses the existing triangular fade and clock; the graphic moves directionally during a0.44s interior window. No camera shake or strobe. Pilot framing adjusts camera offset horizontally by at most20px during departure and returns it on arrival/abort, constrained by existing camera bounds. Zoom remains1.0.

`--tr02-plain` selects ordinary fade. `--tr02-reduced-motion` or existing `--tr01-reduced-motion` selects static directional badge plus fade, with no moving panels/camera offset. Stairwell keeps TR-01's modest treatment and is not globally restyled. Special portal gets stable concentric wind-thread artwork and explicit E/requirement cue. Wind-fold requires the existing junction switch to be activated; no lore or ability is invented.

## QA / comparison

Dedicated tests cover directional sample crossings, walking/run/dash velocities, approach hysteresis, invalid height/corner/tether contacts, both directions, restored horizontal velocity, gate flags, save reload, load/respawn cancellation, held E, unchanged stairwell radius/destination, normal exits and map graph. Existing suites are rerun with narrowly updated expectations for the converted edge. Preserve raw output and actual counts; no blanket softlock/FPS claim.

Comparison fixture/profile launchers must explicitly identify seeded progress, create only disposable save directories and expose three presentation modes. Capture normal1280×720/zoom1.0 actual departures/arrivals plus native draw-frame timings; report spikes. No reliance on unmerged CI workflows.

Packaged comparison launchers additionally pass `--tr02-save=<absolute file>` before load_progress. This QA-only explicit save target is needed because environment-only profile redirection was not reliable in the Windows release template. Normal launches without that flag retain the original default path/API/version8. Fixtures are not earned progression. Launchers wait for the actual game process and write BOM-free UTF-8 JSON compatible with both Windows PowerShell5 and PowerShell7. External --script inspection is unavailable in the release template; native movie frames verify the actual seeded room instead.
