# ART_INTEGRATION: Canal left exit (R13 to R0) architecture and wipe kit

For engineering. Base PR51 `baedd678`. Numbers come from `CANAL_CONTRACT.md` v1 (LEVEL). Art is noninteractive: add no colliders, change no endpoint data, trigger or corridor logic. Status of everything here: technical candidate, creator visual acceptance pending.

## Assets (all 1 px = 1 room px, zoom 1.0, no scaling, lossless import, mipmaps off)

Manifest with SHA256, sizes and labels: `assets/pm_pilot/MANIFEST.json`. Check script: `godot --headless --path . --script res://tools/pm_pilot_art/godot_check.gd` (12 of 12 pass).

| Order back to front | File (`res://assets/pm_pilot/canal/`) | Top-left in room 13 | Size | Notes |
|---|---|---|---|---|
| 0 | `canal_L0_hall_back_wall.png` | (72,1020) | 224x180 | rear plane, tiles horizontally |
| 1 | `canal_L1_door_interior.png` | (72,1068) | 96x132 | fills the aperture; warm far-end glow |
| 2 | `canal_L1_door_frame.png` | (40,1032) | 160x168 | aperture rect (72,1068,96,132) is transparent |
| 3 | `canal_L1_door_leaf.png` | (72,1068) | 96x132 | optional; ajar on the left, about 30 percent of the opening |
| 4 | `canal_L2_gatehouse_face.png` | (0,0) | 296x1020 | y 660..1020 matters on screen |
| 5 | `canal_L2_lintel_course.png` | (72,960) | 224x60 | bottom edge y1020 is the physical ceiling |
| 6 | `canal_L3_back_pier.png` | (0,1020) | 72x180 | |
| Kaze | world child, unchanged | feet (x,y) | | |
| 8 (front) | `canal_L4_mouth_corbel.png` | (284,1004) | 40x40 | in front of Kaze, above her head |

Anchor for the door is the existing `at = Vector2(120,1200)`. In local terms from `at`: aperture top-left `at + (-48,-132)`, frame top-left `at + (-80,-168)`.

## How to bind

1. In `RoomPresentation.draw_exit` / `CinematicTransitions.draw_exit` for `w.room == 13 and at == Vector2(120,1200)`, replace the 96x132 rect and jambs with `w.draw_texture(tex, Vector2(x,y))` for orders 0 to 6 in that sequence, using the room positions in the table (they are absolute, not relative to `at`). Keep the "WALK THROUGH" / "LOCKED" label and arrow cue if wanted, drawn after the art.
2. Draw L4 from a node that is above the player. `cinematic_transitions.gd` has `z_index = 3`; its `_draw` can draw L4 when `world.room == 13`. Do not draw L4 in the world canvas.
3. LEVEL's stand-in `scripts/canal_gatehouse.gd` should stop drawing the same silhouettes once these draw calls exist. The art matches its rectangles exactly (contract section 5).
4. Locked state: tint the interior and leaf, for example `modulate = Color("c48e78")` on L1 draws, or draw a translucent `c48e78` rect over the aperture. No art is shipped for a locked grille.
5. Texture keep-alive: load the 8 textures once as `preload` constants. (In the capture tool a texture created inside `_draw` rendered white because nothing kept it referenced; that is a tool pitfall, not an asset problem.)

## Staged presentation (proposal, matches the preview GIF)

The contract allows presentation proxies only. The 0.65 s world load clock is unchanged; a 2.7 s sequence needs a held fade or a proxy timeline, which is engineering's call.

| t (s) | Beat | Material |
|---|---|---|
| 0.00 to 0.25 | stand at x 330 | approved idle strip, frame by clock at 0.16 s |
| 0.25 to 0.78 | run left to trigger x 120 | approved run strip, 0.08 s per frame, speed 400 px/s |
| 0.78 to 1.13 | continue to x 88 (leftmost reachable foot x is 86) | run strip, proxy `modulate` lerp to (0.15,0.15,0.20) as x goes 120 to 88; this is a tint, not a pose |
| 1.15 to 2.05 | wipe sweeps left | `wipe_panel_a/b/c` in 5 rows |
| 1.80 to 2.05 | destination badge fades in | `wipe_badge_plate.png` at (410,480), draw text over it |
| 2.35 to 2.70 | fade to navy (20,20,43) | |

Kaze registration, copied from `scripts/player.gd`: centered sprite, `offset.y = texture_height/2 - baseline`, `flip_h = facing < 0`. Idle: 8 frames, scale 0.2649908807267889, baseline 591. Run: 8 frames, scale 0.3825780535911868, baseline 491.

Wipe kit (screen space 1280x720 on a CanvasLayer above the cinematic node): panel textures are 1822x488, tilted 6 degrees, travel toward -x. Rows at y = -230, -60, 110, 280, 450 using panels a, b, c, a, b with x offsets 0, -90, 50, -60, 30. Leading edge x goes from 1500 to -300 with ease-out `1-(1-u)^2` over 0.9 s. For rightward exits mirror (`scale.x = -1`). Reduced motion or plain: skip the panels, show only the badge plate with a plain fade. Original Kaze indigo/rose wind-cloth direction from TR-02; no Persona assets.

## Not available (do not fake)

Entry, traversal and departure poses beyond the approved run and idle strips. See `MISSING_ANIMATION.md`. Do not squeeze, stretch or mirror a held key (`assets/art04/kaze/*_key.png`) to make a door entry. Keep any `placeholder` label honest.

## Verification actually run

- Pillow composition of the exit and sequence: `tools/pm_pilot_art/build_previews.py` (not an engine capture).
- Godot 4.6.1 headless size check of all manifest assets: 12 of 12.
- Godot 4.6.1 OpenGL compatibility (Mesa llvmpipe, Linux, xvfb) draw-order capture of the layers plus Kaze idle frame: `docs/pm_pilot/art/previews/canal_exit_godot_capture.png`. It is a purpose-built canvas, not the game scene; the world loader and the real `draw_exit` were not run.
- No game playthrough, no test suite rerun (no runtime scripts changed), no human visual acceptance.
