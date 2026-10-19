# Kaze embodied-cinematic animation interface (v2, ART-08 amended; Transition Masta and Art Mane may amend by bumping the version)

Purpose: one contract so Art delivers frames that Transition can play without rework. Two sequences: (S) R14 <-> R17 staircase as a dedicated FULL-SCREEN cinematic with real ascent and descent; (D) Canal doorway (R13 left exit <-> R0) where Kaze turns into the opening, crosses the threshold and emerges. The existing wipe stays only as a supporting effect; the bottom destination-room label stays.

## Cell and registration
- New cinematic cells: 480 x 724 px, transparent PNG, premultiplied-safe (RGB zeroed where alpha 0). Pivot (feet contact point centre) at (240, 600) in the cell. Same vertical baseline as ART-04 (row 600) so ART-04 and ART-06 poses can be composed. Sprite offset in engine = (0, texture_height/2 - 600).
- Scale: cinematic playback scale is decided by Transition for the full-screen stage; Art must supply source resolution sufficient for Kaze about 560 to 720 px tall on a 1080p screen (the 724 px cell height). In-world playback of the same strips uses 0.303125 (ART-04 scale) unless Transition amends.
- Drawn facing: right (flip_h for left) EXCEPT clips where asymmetry of ribbon and hair matters: Art flags those as `drawn_both_directions` and supplies left and right.
- Strips: one PNG per clip, frames laid out horizontally, hframes = frame count, vframes = 1. File names `kaze_<clip>_strip.png`.
- Manifest: `assets/art08/MANIFEST.json` with, per clip: name, strip path, hframes, cell [480,724], pivot [240,600], fps or per-frame durations, loop (bool), facing, root_motion_px_per_frame (source px, signed x,y; 0 if in place), contact frames (foot-plant frame indices), provenance label (authored drawing / derived from approved ART-06 frames / cut-out rig / interpolated / held / unfinished), SHA256, bytes.
- Hard rule: no clip may be a single held pose, a scaled/bobbed still, or a wipe. A clip counts as animation only if its frames differ in limb pose.

## Clip list (initial request; Art may refine counts, must keep names or publish a rename table)
Staircase (side view, diagonal stairs, drawn facing right; ascent = climbing to the right):
- `stair_ascend_enter` 4 f: floor walk to first tread
- `stair_ascend_loop` 8 f loop: one full stride pair, knee lift, hand near rail, root motion up-right per frame
- `stair_ascend_exit` 4 f: last tread to level floor
- `stair_descend_enter` 4 f, `stair_descend_loop` 8 f loop (heel-first, counter-lean), `stair_descend_exit` 4 f
- `stair_arrive_idle_settle` 4 f optional: settle after arrival
Doorway (depth door, Canal):
- `door_approach_walk` 8 f loop: slow lateral walk (may reuse approved ART-06 lateral/run frames if compatible)
- `door_turn_to_rear` 4 to 6 f (left profile to rear three-quarter; mirroring a right turn is allowed only if Art states it and the asymmetric ribbon is acceptable, creator decision)
- `door_cross` 6 to 8 f: step over sill and into the opening, away from camera
- `door_emerge` 6 f: arrival on the other side stepping out toward camera/side
- `door_turn_to_side` 4 f and `door_walk_out` 8 f loop
Total is the 69 frame inventory in docs/pm_pilot/art/MISSING_ANIMATION.md re-verified by Art against this list (Art reports the verified count; delete what integration does not need).

## Playback API Transition will implement (Art needs no code)
`play(clip, heading, start_frame=0)` per clip from the manifest; sequence = ordered clip list with durations; root motion applied by Transition from the manifest; total each sequence about 2 to 4 s plus the supporting wipe and label; control restored on completion and on cancel (pause, death, room change, timeout). Reduced motion: keep the label, shorten, no camera zoom, still show true frames or cross-fade first and last frames.

## Gates
1. Art publishes `assets/art08/MANIFEST.json` skeleton (names, sizes, fps) to its branch within its first work stretch, and copies it to /home/claude/wave3_shared/ART08_MANIFEST_SKELETON.json.
2. Transition builds against the skeleton using clearly labelled stand-in frames until real strips land, then rebinds by file path.
3. Level tells Transition (via /home/claude/wave3_shared/LEVEL_CINEMATIC_IMPACT.md) of any geometry change affecting the cinematic staging (door rectangle, stair endpoints, arrival points). The Canal doorway appearance is creator-approved and must not change.

## Changelog
- v1 coordinator draft.
- v2 (ART-08): clip names, cell (480x724) and pivot (240,600) UNCHANGED. Conventions clarified: (a) root_motion_px_per_frame is per frame in source px, applied by Transition to the sprite root; root = pelvis x projected on the ground line = cell pivot x. (b) Stair sequence = enter + loop (8f = 2 treads) + exit = 3 treads; stair pitch 188 px, rise 43 px, first step 165 px (source px). (c) door_walk_out is an alias of the door_approach_walk strip (manifest alias_of; same file/sha), play with flip_h as needed. (d) door_turn_to_side is UNFINISHED (no file). (e) door_turn_to_rear is a STAND-IN (re-registered PR #41 turn_depth). (f) Kaze is ~308 px tall in the cell (ART-04 density); 560-720 px cinematic height is an upscale of that, not new source resolution. See docs/art/art08/INTEGRATION.md.
