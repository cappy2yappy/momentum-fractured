# Kaze Model Sheet and Runtime Sprite Specification

**Status:** Production specification
**Character:** Kaze
**Authority:** `docs/ART_BIBLE.md`, then the canonical notes in `GDD.md`
**Purpose:** Lock Kaze's identity, proportions, costume, registration, and export rules before new runtime animation is produced.

## Reference Art Is Not Runtime Art

The canonical identity references are:

- `rebuild/assets/idle.png`
- `rebuild/assets/run.png`
- `rebuild/assets/combat.png` — pose study only
- `rebuild/assets/traversal.png` — pose study only

These files establish Kaze's identity and movement attitude, but they are **not runtime-ready sprite sheets**. They contain baked checkerboard backgrounds, composite layouts, variable frame boxes, inconsistent baselines, and occasional generated-detail drift. Do not slice them directly into Godot animations.

The red-scarf character under `assets/sprites/kaze/` is a deprecated implementation placeholder. Do not use it as a costume, proportion, color, portrait, or animation reference.

Production workflow:

1. Approve the model sheet defined here.
2. Draw clean key poses from that approved model.
3. Build animation frames on registered transparent canvases.
4. Export runtime strips/atlases.
5. Validate silhouette, registration, collision alignment, and playback in Godot.

## Canonical Identity

Kaze is a dark-skinned, athletic adult woman with a confident, forward-driving silhouette. Her design combines a recognizable purple-and-green uniform with the physical clarity required by a fast movement game.

Identity invariants:

- Dark skin.
- Long dark-purple hair.
- Large vivid-green ribbon tied high at the back of the head.
- Fitted purple jacket with white collar and cuffs.
- Bright green chest bow.
- Dark pleated skirt.
- Purple thigh-high stockings.
- Purple ankle boots.
- Adult, athletic proportions; never chibi or childlike.
- Strong readable hands, feet, head angle, and center of mass at gameplay scale.

Hair and ribbon are major motion indicators. They may overlap the body in anticipation poses, but their trailing direction must reinforce Kaze's velocity rather than obscure her limbs.

## Required Model-Sheet Views

All neutral turnaround views use the same head height, foot baseline, body proportions, lighting direction, and orthographic presentation.

1. **Front** — relaxed neutral stance, arms slightly separated from torso.
2. **Front three-quarter** — face, jacket closure, bow, skirt construction, and boot profile visible.
3. **Side/profile** — the primary gameplay-facing direction; establishes runtime silhouette.
4. **Back three-quarter** — ribbon knot, hair origin, jacket back, skirt pleats, and boot backs visible.
5. **Back** — hair/ribbon attachment and costume seams unobstructed.
6. **Gameplay profile, ready stance** — slightly lowered center of mass; the basis for idle and transition poses.

Additional callout panels:

- Face and hairline.
- Ribbon knot, loop count, and tail lengths.
- White collar and green bow construction.
- Jacket cuff and sleeve termination.
- Skirt waistband and pleat direction.
- Stocking-to-thigh break.
- Boot shape, sole, heel, and ankle height.
- Hand and fist simplification at runtime scale.

## Fixed Proportions and Landmarks

Use the head height measured from chin to crown, excluding hair volume and ribbon, as one unit (`H`). The approved model should remain within these working targets:

| Landmark | Target |
|---|---:|
| Total body height | `7.25H` |
| Shoulder line | `1.35H` below crown |
| Natural waist | `2.75H` below crown |
| Hip/crotch line | `3.45H` below crown |
| Knee center | `5.35H` below crown |
| Ankle | `6.90H` below crown |
| Shoulder width | `1.75H` |
| Hip width | `1.45H` |
| Hand length | `0.72H` |
| Foot length | `1.02H` |

These numbers are a consistency grid, not a mandate for anatomical stiffness. Foreshortening may change apparent lengths in action poses, but the underlying landmarks must remain stable.

### Registration landmarks

Mark these on the working animation template:

- Crown.
- Chin.
- Sternum.
- Pelvis/center of mass.
- Left and right shoulder pivots.
- Left and right hip pivots.
- Knee centers.
- Ankle centers.
- Supporting foot contact point.
- Weapon/kunai grip point.
- Tether emission hand.

The pelvis and supporting-foot contact are the primary animation registration guides. Hair, ribbon, hands, and effects do not determine frame registration.

## Costume Construction

The costume must be drawn as one reproducible design rather than reinterpreted per pose.

### Hair and ribbon

- Hair color is dark purple, not black, blue, or brown.
- Hair originates from one approved scalp/hairline design.
- Long hair mass separates into a limited number of large readable locks; avoid noisy individual strands.
- The green ribbon uses one knot, two loops, and two tails unless the approved turnaround explicitly changes that construction.
- Ribbon tails remain visibly separate from the purple hair mass.

### Jacket, collar, and bow

- Jacket is fitted and ends at the approved waist position.
- White collar remains visible from profile and three-quarter views.
- White cuffs have a fixed width and do not expand into gloves.
- Green chest bow has a fixed knot and two symmetrical primary loops in neutral poses.
- The jacket must not become a school blazer, cropped athletic top, armor shell, or hoodie between animations.

### Skirt and stockings

- Skirt length, waistband height, and pleat count remain fixed.
- Pleats follow hip rotation and momentum but return to the approved neutral construction.
- Stockings end at one approved thigh height with a clean, consistent boundary.
- Preserve clear value separation among skirt, stockings, jacket, and skin.

### Boots

- Boots end at the approved ankle height.
- Toe, sole, and heel shapes must remain stable in side view.
- Keep the foot silhouette broad enough to show ground contact at gameplay scale.

## Character Palette Slots

These are working production slots. Final sampled values must be approved on the master model sheet before animation begins.

| Slot | Working value | Notes |
|---|---:|---|
| `SKIN_BASE` | `#8A4F39` | Primary lit skin |
| `SKIN_SHADOW` | `#563022` | Form shadow; do not gray out skin |
| `HAIR_BASE` | `#302343` | Dark purple hair mass |
| `HAIR_LIGHT` | `#594276` | Controlled rim and form accents |
| `JACKET_BASE` | `#56318B` | Primary costume purple |
| `JACKET_SHADOW` | `#2B174C` | Jacket folds and occlusion |
| `COLLAR_CUFF` | `#EEEAF5` | Warm near-white, not pure white |
| `BOW_RIBBON` | `#39E866` | Canonical identity green |
| `BOW_SHADOW` | `#188F45` | Green fold and overlap |
| `SKIRT_BASE` | `#25202F` | Dark neutral purple-black |
| `STOCKING_BASE` | `#4B2876` | Separable from jacket and skirt |
| `BOOT_BASE` | `#5A348B` | Match costume family without merging into stocking |
| `OUTLINE_DARK` | `#120E1D` | Colored near-black; avoid hard pure-black halos |
| `WIND_RIM` | `#59DFF3` | Effects/rim response only, not costume fill |

Rules:

- Use colored shadows instead of neutral gray.
- Do not allow the green accent to migrate to unrelated costume areas.
- Preserve skin tone under violet ambient light; lighting may shift temperature, not identity.
- Effects and temporary state tints must not overwrite costume color relationships.

## Runtime Canvas, Baseline, and Registration

### Master canvas

- Default production canvas: **256 × 256 px per body frame**.
- Neutral standing body height: approximately **160 px**, excluding the highest ribbon/hair overshoot.
- Default origin/registration point: **(128, 216)**.
- Ground baseline: **Y = 216**.
- Facing-right is the authored direction. Godot may mirror the body for left-facing movement unless asymmetric action or costume detail requires a dedicated left frame.
- Maintain at least 12 px clearance from body/hair/ribbon to canvas edges in all ordinary poses.

If an action cannot fit without clipping, preserve the body registration and use a documented extended canvas. Do not shrink Kaze within individual frames to make an effect fit. Wide weapon trails and VFX should normally be separate assets.

### Registration rules

- Idle, crouch, jump, fall, land, attack, throw, hurt, and death register primarily to the pelvis/origin.
- Grounded cycles must keep the supporting foot on the shared baseline except during intentional airborne frames.
- Run-cycle vertical movement comes from body mechanics, not accidental canvas drift.
- Dash uses the same origin as run; afterimages inherit that exact registration.
- Wall poses use an additional wall-contact guide while retaining the body origin.
- Swim poses use the pelvis origin with a documented waterline guide.
- Root motion is implemented by gameplay code. Do not bake uncontrolled world translation into frame placement.

### Rendering requirements

- Transparent RGBA background.
- No baked checkerboard, labels, frame numbers, guides, shadows, or VFX in body exports.
- Consistent outline/edge treatment across every animation.
- Author at the master scale; validate downscaled appearance at the actual Godot gameplay size.
- Use texture filtering appropriate to the approved painterly style; do not apply pixel-art nearest-neighbor treatment by default.

## Required Key Poses

Key poses must be approved before in-betweens are produced.

### Idle

- Neutral gameplay profile.
- Subtle ready posture with weight distributed over both feet.
- Hair and ribbon secondary motion must not look like running wind.
- Minimum keys: contact/rest, breath rise, settle, secondary-motion recovery.

### Run

- Clear forward lean and athletic acceleration.
- Minimum keys: left contact, left passing, flight/high point, right contact, right passing, flight/high point.
- Hands, knees, and feet must remain separable from the torso at gameplay scale.
- Hair and ribbon lag behind acceleration and cross over only when silhouette remains readable.

### Crouch and slide

- Crouch compresses through hips and knees without changing apparent body scale.
- Slide establishes one leading boot, protected head/torso, and a low continuous silhouette.
- Minimum slide keys: entry compression, travel, braking/recovery.

### Jump and fall

- Distinct anticipation, launch, rise, apex, fall, and landing silhouettes.
- Rise and fall must be readable without relying on hair direction alone.
- Landing compresses into the ground and returns cleanly to movement.

### Dash

- Narrow, forceful silhouette aligned with travel.
- Leading shoulder/head protected; limbs do not resemble a normal run frame.
- Keep body separate from dash trail and afterimage assets.

### Tether

- Separate keys for fire/extension, confirmed attachment, swing tension, pump forward, pump back, and release.
- Tether must visibly originate from the same approved hand/gauntlet point.
- Shoulder, spine, hips, and legs react to rope tension.
- Hair and ribbon describe the swing arc and release velocity.

### Attack combo

- Three attacks with distinct silhouettes, directions, and recovery shapes.
- Minimum keys per attack: anticipation, active contact, follow-through, recovery.
- Hit timing must correspond to the authored active pose, not a generic animation interval.
- Weapon/limb path remains readable without baked hit sparks.

### Kunai throw

- Draw, aim, release, and recovery keys.
- The grip/release point must match the runtime projectile spawn marker.
- Wind, Fire, and Electric use one body animation unless an elemental state materially changes the pose; element identity belongs primarily to projectile/VFX art.

### Swim

- Surface entry, submerged neutral, stroke, glide, upward stroke, and water exit.
- Hair, ribbon, jacket, and skirt respond to water drag consistently.
- Preserve modest, action-oriented posing and the approved costume construction.

### Hurt and death

- Hurt has a clear directional recoil and retains facial/costume identity.
- Death sequence needs impact, collapse, grounded hold, and transition-ready final pose.
- Do not use costume disappearance, arbitrary dismemberment, or full-body color replacement as the primary readability device.

## Naming and Export Rules

### Source files

Use this pattern:

`kaze_<animation>_source_v###.<source-extension>`

Examples:

- `kaze_idle_source_v001.kra`
- `kaze_tether_swing_source_v003.psd`

Layered sources should include, where applicable:

- Guides — non-exporting.
- Body/skin.
- Hair.
- Ribbon.
- Jacket/collar/cuffs/bow.
- Skirt.
- Stockings/boots.
- Cleanup/outline.
- Lighting.

### Runtime frames

Individual-frame pattern:

`kaze_<animation>_<direction>_<frame-number>.png`

Examples:

- `kaze_run_r_000.png`
- `kaze_run_r_001.png`
- `kaze_tether_attach_r_000.png`

Use zero-based, three-digit frame numbers. Do not encode timing in filenames; timing belongs in animation metadata.

### Runtime strips

Horizontal-strip pattern:

`kaze_<animation>_<direction>_strip.png`

Every frame in a strip must have the same canvas size and registration. Include a machine-readable manifest containing:

- Frame width and height.
- Frame count.
- FPS or per-frame duration.
- Loop setting.
- Origin.
- Ground baseline.
- Event frames such as footstep, tether release, kunai release, attack active, and landing.

### Export constraints

- PNG, RGBA, lossless.
- sRGB color space.
- No embedded color-profile surprise that shifts the approved palette in Godot.
- No baked background or global shadow.
- No frame labels or crop marks.
- Body and VFX exported separately unless the effect is inseparable from the character silhouette.
- Preserve one layered source master and one clean runtime export set.

## Approval Checklist

### Identity

- [ ] Matches the purple-and-green canonical Kaze rather than the red-scarf legacy design.
- [ ] Dark skin, dark-purple hair, green ribbon, jacket, bow, skirt, stockings, and boots are all present and correctly constructed.
- [ ] Reads as an athletic adult and not chibi or childlike.
- [ ] Front, side, and back views clearly depict the same person and costume.

### Proportion and construction

- [ ] Head/body ratio and all major landmarks stay within the approved model grid.
- [ ] Hairline, ribbon knot, bow, collar, cuffs, pleats, stocking height, and boots remain consistent.
- [ ] Hands and feet are readable at gameplay scale.
- [ ] No action pose changes Kaze's apparent height, limb length, or costume design without intentional foreshortening.

### Registration and animation

- [ ] Frames use the approved canvas, origin, and baseline.
- [ ] Grounded feet do not drift unintentionally.
- [ ] Pelvis registration remains stable through transitions.
- [ ] Run, jump, dash, tether, attack, and swim silhouettes remain readable when viewed as solid black shapes.
- [ ] Hair and ribbon support motion direction without hiding gameplay-critical limbs.
- [ ] Gameplay events align with the correct authored frames.

### Technical delivery

- [ ] Runtime files are transparent RGBA PNGs.
- [ ] No checkerboard, guide, label, number, or background is baked into exports.
- [ ] Frame dimensions and counts match the manifest.
- [ ] Naming follows this specification.
- [ ] Body and VFX are separated where required.
- [ ] The animation has been viewed at native master scale and actual in-game scale.
- [ ] Godot import shows no unexpected filtering, edge halos, clipping, or color shift.

### Final approval gates

- [ ] Creative approval: identity and costume.
- [ ] Art-direction approval: silhouette, palette, lighting, and continuity.
- [ ] Gameplay approval: readability and event timing.
- [ ] Technical approval: canvas, registration, export, import, and memory use.

No animation set should replace the current placeholder in `scenes/kaze.tscn` until its minimum locomotion group—idle, run, jump, fall, dash, and wall slide—passes all four final approval gates together.
