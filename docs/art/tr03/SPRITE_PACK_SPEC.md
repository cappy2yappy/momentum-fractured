# TR-03 minimal sprite pack and pivot/import contract

**Draft specification; new character art is not production-approved.** Existing PNGs remain byte-for-byte unchanged. Current cleaned idle/run have eight 272×724 cells; combat/traversal have eight 320×724 cells. Current per-clip source baselines differ (idle591,run491,combat498,traversal510), with scales0.264990881/0.382578054/0.378751572/0.339192793. Visual occupied heights, not canvas heights, preserve Kaze's approximately97px upright presentation at camera zoom1. New contact-sheet diagrams must not normalize existing files and silently replace them.

## New standardized action source

Proposed new canvas **320×724** per frame, RGBA8/sRGB, centered-X registration, ground-foot baseline **(160,600)**, visible upright target **320 source pixels ≈97 world pixels**, initial proposed scale **97/320=0.303125**. This is a *new animation authoring contract*, not an instruction to resize current clips. Canvas room above/below protects hair and feet; at least12px clear alpha margin on every edge. Hair trails may not extend beyond the cell. If approval requires more width, widen all frames of that clip without scaling the character and update the manifest before import.

At Sprite2D centered=true, offset=(0,724/2−600)=(0,−238), scale=(0.303125,0.303125), local foot anchor=(0,0). That equation places the source foot anchor at the local origin. Do not use alpha-box auto-centering or per-frame scale to hide drift. For a lifted foot, the planted foot or pelvis/root guide owns registration; never alternate the root between toes. Include contact/root/occluder guides in separate hidden authoring layers.

| Clip ID / proposed filename | Frames | Nominal preview rate | Foot/contact events | Direction variants |
| --- | --- | --- | --- | --- |
| walk_continuation / kaze_tr03_walk.png | 6 | 10fps, loop | contacts0,3; low arm/leg amplitude, upright torso | Right master; left mirror only after silhouette/accessory review |
| turn_depth / kaze_tr03_turn_depth.png | 4 | 20fps, nonloop | profile→quarter-back→back-quarter→rear, pivot held | Enter from left and right; authored facing-specific variant if headband/accessory asymmetry requires |
| enter_depth / kaze_tr03_enter_depth.png | 3 | 20fps, nonloop | rear steps0,2; occluder takes last frame | Rear axis; do not make entry by mirroring x |
| leave_depth / kaze_tr03_leave_depth.png | 3 | 20fps, nonloop | forward steps; reorients to prescribed arrival heading | Front-quarter silhouettes need actual new art |
| return_profile / kaze_tr03_return_profile.png | 2 | 20fps, nonloop | quarter-facing→profile, same root | Left/right reviewed variants |
| stair_up / kaze_tr03_stair_up.png | 6 | 20fps, loopable step fragment | plant0,3; swing knee leads and pelvis rises | Right-up master; left-up mirror if compatible |
| stair_down / kaze_tr03_stair_down.png | 6 | 20fps, loopable step fragment | landing1,4; knee compresses on contact | Right-down master; left-down mirror if compatible; **not reverse playback of ascent** |
| run_continuation | reuse current8 | current0.08s/frame cadence | preserve current run phase where supported | Current facing flip and scale/pivot exactly retained |

New minimal master pack is30 proposed frames (6+4+3+3+2+6+6), excluding mirrored variants and reused run. Each six-frame strip1920×724, four-frame1280×724, three-frame960×724 and two-frame640×724. Logical forward/rear angles need not become separate gameplay facings or new controls.

## Playback vs loader cues

Nominal preview rates are authoring references. Art staging follows source/cover/swap/arrival/resume cues in the existing39-tick envelope. The4 turn keys and3 entry keys describe the required silhouettes; the last entry frame can already be occluded when room swap fires. Do not add clip durations end-to-end to lengthen0.65s. Stair loops show only the local entry/arrival step fragment; a full staircase performance is later scoped work. Ordinary run should not restart its stride merely because the destination loaded.

## Palette / transparency / authoring

Preserve existing purple clothing, dark skin, dark hair mass and green headband/tails; audit the approved reference PNGs, not a generic anime description. Sample actual working colors from current source in the production session; do not declare a newly invented palette canonical. Keep light direction and line weight consistent with current Kaze. Avoid introducing weapons, symbols, anatomy/outfit changes, extra limbs or a scarf redesign.

RGBA PNG export, no white matte, no nearest-color fringe, zero hidden RGB where alpha=0. Production layers: body_line, body_color, hair, headband, contact_guide(hidden), root_guide(hidden), occluder_guide(hidden). Editable .aseprite source is proposed for final hand-pose work; an installed executable is not proof of successful use. Tags use clip IDs above; each starts at0 in exported JSON. Keep frame parity including holds; no automatic deduplication/trim/packed rotation. Named holds may repeat content only when deliberately documented.

Godot4.6.1 proposal: SpriteFrames with horizontal cells or AtlasTexture regions; linear filter for current anime art; no mipmaps at zoom1 initially; lossless alpha export. hframes equals the real clip count rather than the current controller's global8 assumption. A render-only animation adapter must own these new counts; do not alter player.gd's global animation assumptions in this assignment. Save/playback code is not delivered here.

Per-frame JSON: clip_id,frame_index,region,source_size,pivot_px,contact_foot,contact_phase,nominal_duration_ms,direction_variant,alpha_margin_px,source_hash,status. Export metadata is specified, not claimed to have been imported as final gameplay clips.

## Art acceptance gate

Check identical frame dimensions/count and alpha mode; consistent root overlay; no border alpha above the agreed threshold; edge inspection on black/white/indigo/gray;12px margin, limb/hair integrity; left/right accessories; grounded contact drift<=1world px on nominal planted frames; gameplay-scale turn/stair comprehension; source and destination facing. No new-frame clipping/alpha/registration result can be called passed until final painted frames exist. Storyboard review and runtime animation acceptance are separate gates.
