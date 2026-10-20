# TR-08: full-screen stair cinematic and embodied Canal doorway

Status: technical candidate. **Creator visual acceptance is pending.** Captures are Linux software-GL (Mesa llvmpipe) only.

## What changed for the player (default build, no flag)

### R14 Bellroof Walk <-> R17 Counterweight Spire stair (E, both directions)

This is now a dedicated full-screen cinematic. Code: `scripts/tr08_stair_stage.gd`.

- **0.00 to 0.30 s.** The wind-cloth wipe covers the world and the stage fades in underneath. The letterbox and the bottom destination plate (`ASCEND > COUNTERWEIGHT SPIRE` / `DESCEND > BELLROOF WALK`) appear.
- **0.30 s.** The real room request is released under the opaque stage. The inherited 0.65 s loader and its hidden swap run beneath it, unchanged.
- **0.30 to about 2.3 s.** Kaze climbs or descends at cinematic scale (430 px on 1280x720) as the wipe clears. Clips: `stair_*_enter`, `stair_*_loop` x2, `stair_*_exit`, `stair_arrive_idle_settle`. The bound clip root motion moves her along the flight, and the stage camera follows with a gentle 1.0 to 1.08 push-in.
- **Staircase construction.** The flight is built from the same root motion, so the treads match whatever clips are bound. Each tread is seated under the measured soles of the frames that cross it. The art is the approved terrain-material masonry and walkable-cap colour, with the approved district backdrop showing through bays in the stairwell wall.
- **About 2.3 to 2.9 s.** The wipe covers again and the stage is removed. The wipe then clears onto the destination room with live Kaze standing at the unchanged arrival point, and control returns.
- **Reduced motion** (F6 or `--tr05-reduced-motion`): about 1.3 s, with one loop and no settle. Fade instead of wipe panels. A fixed stage camera with no zoom or pan. The true frames play 1.25x faster. The label is kept.

### Canal doorway, R13 Mooring Loft left exit <-> R0 Canal Haven

This is now an embodied passage. Code: `scripts/tr08_canal_doorway.gd`.

- **R13 to R0.** The automatic crossing of x=120 is unchanged. Kaze turns to the rear (`door_turn_to_rear`) and walks away over the sill into the aperture (`door_cross`). She is clipped to the contract aperture (72,1068,96,132), recedes with the clip's depth root motion, shades into the interior and passes the ajar leaf. The cross is timed to end at the hidden swap. The inherited loader fade and its bottom label (`WALK THROUGH / CANAL HAVEN`) run unchanged as the supporting effect. Meanwhile the doorway and Kaze are drawn on a viewport layer above that fade, so the passage stays readable while the room around it darkens. In R0 she emerges from the Mooring Loft door (`door_emerge`) and turns to the travel side (`door_turn_to_side`).
- **R0 to R13.** E at the R0 door. Kaze walks to the door (`door_approach_walk`), turns, and crosses. In R13 she emerges from the Canal aperture, turns right, and walks out (`door_walk_out`) to the unchanged arrival point (184,1198).
- **Airborne, tethered or wall-slide crossings** keep the inherited passage, which never fakes footsteps in mid-air.
- The Canal doorway art, rectangles, trigger, corridor, arming, recovery, cooldown and arrival offsets are untouched.

### Shared behaviour

- **Control returns** on completion, pause, death, room rebuild and timeout (watchdog 6 s for the stair, 5 s for the Canal). F6 shortens the remaining sequence.
- **Repeated E** during a sequence never causes a second request.
- **Locked gates** never start a sequence and keep their specific hints.

## Clip binding

The binding is manifest-driven (`scripts/tr08_clip_library.gd`, `scripts/tr08_clip_player.gd`).

- `assets/art08/MANIFEST.json` rows bind by file path when the strip exists, has at least 2 frames, and its status/provenance counts as animation.
- Everything else falls back to a stand-in built from approved strips, labelled `STAND-IN, ANIMATION PENDING` on screen.
- The current binding, copied by allowlist from ART-08 `61b32194` with every SHA256 verified, is in `ART08_BINDING.json`.

| Clip | Bound | What it is |
| --- | --- | --- |
| stair_ascend_enter / loop / exit | ART-08 | candidate cut-out rig animation (real limb change per frame) |
| stair_descend_enter / loop / exit | ART-08 | candidate, mirrored for the leftward R17->R14 descent (ribbon side flips: creator decision) |
| stair_arrive_idle_settle | ART-08 | candidate |
| door_approach_walk, door_walk_out (alias, same file) | ART-08 | candidate |
| door_cross | ART-08 | candidate rear rig |
| door_emerge | ART-08 | candidate front rig (arms nearly static, per Art) |
| door_turn_to_rear | ART-08 **stand-in** | PR #41 turn_depth frames re-registered, right-to-rear, mirrored for the left exit; labelled STAND-IN |
| door_turn_to_side | TR-08 **stand-in** | no ART-08 file (unfinished). Approved idle frames 6,7,0,1; labelled STAND-IN, ANIMATION PENDING |

Engine staging that is not animation, and is documented as such:
- the wipe panels, letterbox and plate
- the stage camera
- depth shade and scale (0.86) inside the doorway
- the doorway layer fading with the loader

## Flags

See `DEMO_ARGS.md`: `--tr08-off`, `--pm-staged-stair`, `--tr05-plain`, `--tr05-legacy` and `--tr05-reduced-motion`.

## Tests

- `tests/tr08_embodied_cinematics.gd`: run it with `-- --test` (TR-08 on) and again with `-- --test --tr08-off`.
- `tests/capture_tr08.gd`: xvfb captures, written to `build/tr08/captures`.
- `tools/tr08_contact_sheet.py`: builds contact sheets from the captures.
- Reviewed updates to older timing assertions: `TEST_CHANGES.md`.

Capture command:

```
xvfb-run -a -s "-screen 0 1280x720x24" godot --rendering-method gl_compatibility --rendering-driver opengl3 --path . --fixed-fps 60 --script res://tests/capture_tr08.gd -- --test
python3 tools/tr08_contact_sheet.py build/tr08/captures docs/tr08/captures --jpeg
```
