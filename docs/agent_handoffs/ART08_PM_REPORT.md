# ART08 PM report (Art Mane, order 2)

Branch art/art08-embodied-cinematic-animation, base candidate/pm-pilot-combined (49ae3efe). Creator visual acceptance is RESERVED; all clips are candidates or stand-ins.

## Inventory verification
MISSING_ANIMATION.md: 69 = A 19 + B 18 (door, 37) + C 32 (stairs). ANIMATION_INTERFACE.md list totals 76 = stairs 36 (adds 4-frame settle) + door 40 (adds 8f approach + 8f walk_out the pilot covered with approved run strip, minus differing turn/cross counts). Delivered unique frames: stairs 36, door 26 (approach 8, turn 4 stand-in, cross 8, emerge 6) plus 8 aliased walk_out; door_turn_to_side 4 unfinished. 36+26 = 62 PNG frames of 66 unique needed (+8 alias).

## Method
Cut-out part separation from one approved donor drawing per view, tube-warped limbs, 2-bone IK, foot-planted gait solver, SS=3 premultiplied render (tools/art08). No generative models used; Higgsfield ledger: 0 attempts, 0 of 40 credits.

## Gates (docs/art/art08/qa/*.json, extra_profile.json)
Frame counts match manifest; adjacent limb-band XOR >=0.128 (door_cross), unique frames all; hidden RGB 0; plant sole-y error max 1.5 px, contact-x max 2.7 px (settle clip one 15.8 px outlier on final settle contact); loop seam as stated in INTEGRATION.md; Godot 4.6.1 headless import of all PNGs OK; Sprite2D xvfb capture of all 12 clips opened and inspected (docs/art/art08/godot_capture/all_clips_sprite2d_capture.png).

## Not done / limits
door_turn_to_side unfinished; door_turn_to_rear stand-in (PR41); arm motion minimal in door_emerge; no real 560-720 px source; foot-slide estimate is analytic plus image plant check. Needs: creator's layered sources or 4 drawn keys for the turn.
See docs/art/art08/INTEGRATION.md. Interface bumped to v2.
