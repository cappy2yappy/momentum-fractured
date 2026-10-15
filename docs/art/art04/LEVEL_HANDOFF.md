# Level Masta Masta — ART-04 asset contract

This is the coordination payload for PR #27's render adapter. Art derives from approved ART-03 #28 at `fc998f9b22f3e778cc51ee2c81668ad73ac7902e`; implementation reference is PR #27 at `c2c002267c58e991966c0eebf7e098c6e7fff769`. Live acceptance of these new assets is pending. Publication pointers are recorded in the PM return after the first art checkpoint.

Consume **only explicitly reviewed paths** from `assets/art04/` at the pinned art commit. Do not merge this art branch's older gameplay foundation or use its main scene as the TR-03 build. `tools/art04_review/` is optional, isolated fixture code; it is not a replacement production adapter. No acknowledgment from a live Level session is claimed.

## Kaze keys

| ID / PNG basename | Authored facing and action | Status |
| --- | --- | --- |
| turn_depth_key | Right-facing quarter-back turn, trailing heel lifting | One usable key, not four turn frames |
| enter_depth_key | Rear/inward step; farther boot higher in depth | One usable key, not entry/exit cycle |
| stair_up_key | Right-up, bent leading knee, planted upper boot and lower trailing toe | One contact key, not ascent cycle |
| stair_down_key | Left-down, lower leading landing and flexed upper trailing knee | Distinct authored descent key, not reversed ascent |

All frame canvases **320 × 724 RGBA**, pivot **(160,600)**, scale **0.303125**, centered offset **(0,-238)**, linear filtering, lossless texture import, no mipmaps. Visible keys occupy roughly94–97 world pixels at zoom1. Bounds include at least12px transparent margin. Original idle/run clips retain their existing source/pivots/scales. No runtime alpha-bound centering, cropping, sheet-count assumptions or squeeze-to-fake-turn.

`ART04_ASSETS.json` records manually selected, fixed source-space root transforms and contact coordinates. `ART04_key_poses.tres` has four one-key animations, explicitly nonlooping. `key_pose_atlas.png` cell order: turn, enter, up, down. Do not wire it as a four-frame walk or loop it as stairs. Opposite-facing versions and the asymmetrical ribbon/accessory read require review; do not silently mirror rear entry into forward exit.

## Environment anchors and order

| Asset | Placement / envelope at native scale | Order |
| --- | --- | --- |
| r14_roof_support.png | Texture488 ×186 at (706,922); visible472 ×170 envelope starts (714,930), beneath existing shelf(750,900,400,40) | Rear dressing, before collision lips/actors |
| r15_masonry_support.png | Texture456 ×338 at(1292,970); visible440 ×322 envelope starts(1300,978), piers reach floor y1300 | Rear dressing, before collision lips/actors |
| r14_door_interior/back/front | Shared208 ×224 canvas, root(120,208), at existing R14 depth-demo endpoint(120,1100); draw top-left at endpoint minus root | Interior → rear frame → proxy → front jamb/threshold → interaction cues |
| stair_flight_right / stair_front_lip |384 ×112 export. Fixture draws at(1330,431.8) with size384 ×89.6 (vertical0.8), actor root(1450,478), existing R14 endpoint(1450,480) | Flight behind actor; matching front lip above toes; both visual-only |

The common door canvas means front/rear layers use **the same root**, not independent alpha-box centering. The interior is cropped from an unoccupied portion of the approved doorway painting; frame/roof/stairs/masonry are newly authored derived pieces. Door opening is truly transparent in the frame. Foreground jamb and narrow stair lip must not conceal the full figure, interaction prompts, hazards or pickups.

Native fixture stair closeups were inspected: leading ascent boot rests at upper contact, trailing toe at lower; descent leading boot reaches lower tread while upper trailing foot releases. The stair vertical0.8 staging factor belongs to this environmental flight, not to the character. This fixture positions a **render proxy** on local contacts above an existing flat collision shelf; it does not create a traversable physical staircase or alter the player's capsule/root. Any different endpoint or destination needs explicit contact-anchor mapping rather than reusing these coordinates blindly. R17 destination/arrival masking remains untested.

## Remaining production integration work

Replace the scoped placeholder dressing drawing at the correct point in the room canvas. Current procedural roof masses and large canal arcs still overdraw portions of these assets in the deliberately conservative comparison; remove/reorder only the relevant placeholder decorations during Level's integration, retaining collision lips and gameplay readability. Retain strong references to custom-draw textures: temporary inline loads were released before rendering in the first fixture pass, then corrected with cached texture resources.

Bind reviewed key textures to the existing proxy and loader events; retain 0.65s/39 ticks, actual swap event, cancellation/death/rebuild cleanup and original/refined/art-preview/reduced/plain fallbacks. A single held key is acceptable only as clearly labeled staging, not a final animated cycle. Continue existing approved run for R15/R16; no new walk art exists.

New source production still needed: remaining turn/entry keys, outward/front-quarter exit/reorientation, six-frame ascent/descent cycles and walk. Keep the existing30-frame plan; four keys do not certify the remaining26 frames or automatic inclusion as final cycle indices. After creator review, assign each key's actual source-frame index with Level before expanding the sheet.

## Evidence boundaries

Native macOS Apple M4 / Godot4.6.1, 1280 ×720 zoom1, eight scripted static captures. R14 colliders23→23; R15 15→15. SpriteFrames and both prefabs load/instantiate. These are production preparation fixtures, not a shipped ART04 build, a live transition test, Windows validation or sustained60FPS certification. Existing world/player/save/graph/input files and all approved images remain unchanged on this art branch.
