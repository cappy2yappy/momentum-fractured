# ART-08 integration note for Transition (interface v3)

Creator visual acceptance is RESERVED. Everything below is "candidate" until the creator accepts it visually.

## Status per clip (assets/art08/MANIFEST.json is authoritative)
| clip | frames | fps | loop | status | provenance |
|---|---|---|---|---|---|
| stair_ascend_enter / loop / exit | 4 / 8 / 4 | 16 / 14 / 16 | loop only on `loop` | candidate | cut-out rig + foot-planted gait solve from one approved ART-04 profile drawing (script-authored) |
| stair_descend_enter / loop / exit (REVISED v3) | 4 / 8 / 4 | 16 / 14 / 16 | loop only on `loop` | candidate | same |
| stair_arrive_idle_settle | 4 | 12 | no | candidate | same (ASCENT settle only) |
| stair_descend_arrive_settle (NEW v3) | 4 | 12 | no | candidate | descent rig, descent-specific arrival; needs a Transition binding, see below |
| door_approach_walk | 8 | 12 | yes | candidate | same rig, flat-floor walk (not the ART-06 frames) |
| door_walk_out | 8 | 12 | yes | candidate, ALIAS of door_approach_walk | same file and sha |
| door_turn_to_rear | 4 | 16 | no | STAND-IN | PR #41 turn_depth frames re-registered, AI-derived lineage, right-to-rear only, not newly authored |
| door_cross | 8 | 12 | no | candidate | cut-out rear rig from ART-04 enter_depth/turn_depth keys |
| door_emerge | 6 | 12 | no | candidate | cut-out front rig from approved idle frame 0 |
| door_turn_to_side | 4 | - | - | UNFINISHED (no PNG) | see below |

Candidate = real limb-pose change per frame, on model, gates recorded in docs/art/art08/qa/*.json. Not "final".

## Binding
Strip `assets/art08/kaze_<clip>_strip.png`, `hframes` = frame count, vframes 1, cell 480x724, pivot (240,600), Sprite2D offset = (0, texture_height/2 - 600) = (0,-238). World scale 0.303125. Drawn facing right, use flip_h for left. The door_cross strip is a rear view and door_emerge a front three-quarter view; neither is flipped except by creator choice.
Mirroring the right-facing turn/walk for the left exit flips the asymmetric ribbon side: creator decision.

## Root motion
`root_motion_px_per_frame` per frame in source px (x,y; negative y = up), multiply by 0.303125 for world px. Root = pelvis x on the ground line = cell pivot. Stance feet are planted against this motion (image-measured sole error max 1.5 px, no slide). Stairs: sequence enter + loop + exit gives 3 treads (pitch 188 source px, rise 43, first step 165) matching transition_pilot_data.gd's 3 treads. door_cross (0,-5.4)/frame, door_emerge (0,9.5)/frame (depth motion, in cell y). door_emerge ends in a front three-quarter pose: cut or dissolve to door_walk_out.

## Known limits (honest)
- Stairs are out of scale with Kaze (pitch 188 px vs leg length 131 px), so the climb reads as bounding strides.
- No drawings exist for front-to-profile, so door_turn_to_side is unfinished; an optical-flow morph was tried and rejected (ghosting). Finishing it needs 4 drawn keys (front 3/4, 2 in-betweens, profile) from the creator's layered sources/Aseprite.
- door_emerge arms are almost static (donor arm is a bent fist).
- Cinematic scale is an upscale of ~308 px Kaze; not new 560-720 px source.
- Stair loop seam: virtual-next-frame vs frame 0 silhouette XOR 0.14/0.18 (mean RGB diff 1.8/2.8), walk loop 0.0; visible as a slight stride-pair difference. Rear boots reach up to row 613 (13 px under pivot row) in door_cross.
- Minor fringe/sliver artifacts remain on the front rig.
- No Higgsfield credits were spent (0 of 40); no generative attempt was made.

## v3 descent revision (creator: "she looks like a hunchback when going down")
Diagnosis: the v1 descent reused the forward-leaning climb drawing (stair_up_key, waist to collar 28 degrees forward in its own drawing) and rotated the whole rigid torso back 14 degrees, which left a rounded jacket back, a head thrust forward of the shoulders and a run-like bound (188 px stride). v3 cuts the upper body from the approved upright stair_down_key (mirrored to face right) and walks it down a 100 px / 30 px flight with toe-first landings and a forearm counter-swing. Measured from pixels (docs/art/art08/qa/descent_spine_v1.json and _v2.json): waist-to-collar tilt 11.8 deg forward before, 6.9 deg after; foot flat-phase slide 1.76 px before, 1.24 px after (source px); loop seam silhouette XOR 0.18 before, 0.07 after. The head-to-collar offset did not improve (10.8 px before, 12.5 px after), so the gain is in the removed back hump and stride, judged visually in docs/art/art08/descent/.
Ribbon side: the strip is drawn facing right from the mirrored key. Transition flips it for the leftward R17 to R14 descent, which returns the ribbon and hair to the side drawn in the approved stair_down_key.
Binding: stair_descend_enter/loop/exit keep their names and frame counts, so they rebind with no code change; the stage builds the new 100 px flight from the root motion by itself. The new clip stair_descend_arrive_settle needs a small Transition change because tr08_clip_library.gd closes its clip list: see docs/art/art08/descent/transition_settle_patch.diff (CLIPS, one stand-in row, the settle name checks, and `queue.append("stair_descend_arrive_settle" if rise>0 else "stair_arrive_idle_settle")`). Without that change the descent still plays but ends on the ascent settle, which is a visible posture pop and rises 8.7 px.
Limits: forearms swing about the elbow only (upper arms are part of the drawn torso); the upper body is rigid, so the spine does not flex frame to frame; hair tips are sine-warped; the 100 px pitch differs from the ascent's 188 px, so the two directions build different flights. Creator visual acceptance of the descent is reserved.
