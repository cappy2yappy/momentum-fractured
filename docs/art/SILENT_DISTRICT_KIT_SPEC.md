# Silent District Modular Art Kit Specification

**Status:** Production specification
**Scope:** Minimum environment kit for the five-room web-parity slice
**Authority:** `docs/ART_BIBLE.md`, then the canonical web-parity notes in `GDD.md`
**Target:** Godot 4.6.1 at 1280 × 720 gameplay resolution

## Purpose

This kit must support one cohesive five-room route:

1. Compact Silent District surface approach.
2. Purposeful vertical Wind Relay climb.
3. Surface-to-undercroft transition.
4. Flooded canal/underground traversal room.
5. Ability-gated Fire return path with a checkpoint or reliquary landmark.

The kit is painterly anime Tokyo noir. It must not drift into pixel art, generic neon cyberpunk, untextured rectangles, or collage-style stretching of full concept images. Collision may remain simple, but finished art must make that collision believable and readable.

## Visual Target

The Silent District combines old timber houses, plaster, roof tile, canal stone, iron bridgework, utility infrastructure, shrines, warm windows, damp masonry, and reclaimed vegetation under violet dusk.

Primary contrast:

- Cool indigo/violet world mass.
- Near-black structural silhouettes.
- Warm amber remnants of habitation.
- Cyan wind traversal language.
- Muted green ecology.
- Fire orange reserved for the return gate and related interactions.

Every room must use three depth bands:

- **Background:** Soft, atmospheric, non-collidable city and landscape.
- **Gameplay plane:** Crisp, readable surfaces aligned to collision.
- **Foreground:** Dark framing architecture, roots, rails, or cables with controlled occlusion.

## Scale and Grid

### World grid

- Base layout grid: **32 world pixels**.
- Primary art module: **64 × 64 px** at runtime.
- Half-module: **32 × 32 px** for transitions and collision fitting.
- Standard gameplay floor thickness: **64 px** including cap and face.
- Minimum narrow platform thickness: **32 px**, used only when visually supported.
- Standard wall width: multiples of **64 px**.
- Standard door opening: **96 px wide × 160 px high**.
- Major exit/teleport frame: **128 px wide × 192 px high**.

Kaze's collision and final runtime scale must be validated against this grid before the kit is locked. A standard doorway should give clear headroom without making Kaze look miniature.

### Source and runtime resolution

- Author modular foreground/gameplay pieces at **2× runtime dimensions** when the painting workflow benefits from it.
- Downsample once with the approved filter and retain layered 2× masters.
- Export runtime art at the dimensions listed in this specification.
- Do not mix 1× pixel art, nearest-neighbor scaling, and painterly filtered art.

### Camera coverage

- Gameplay camera: 1280 × 720.
- Full-room background plates should cover at least **1536 × 864 px** to allow restrained camera offset or parallax without revealing edges.
- Repeating parallax strips should be at least **1536 px wide** and horizontally tileable.
- Tall-shaft background strips should be at least **768 px wide × 1536 px high** and vertically tileable or segmentable.

## Collision-Safe Construction Rules

1. The visible walkable top edge aligns exactly with the collision top.
2. Decorative lip overhang may extend no more than **4 px** beyond collision unless it is clearly non-walkable.
3. A solid wall may not contain a painted opening, deep recess, doorway, or gap that suggests passage.
4. A traversable opening must not be covered by opaque foreground art at Kaze's depth.
5. Platform undersides must read darker than walkable caps.
6. Slopes, one-way platforms, breakable surfaces, and hazards each require distinct edge treatment.
7. Collision shapes must not be derived from background silhouettes.
8. Moss, roots, signs, cables, and decals cannot obscure a platform edge or enemy attack lane.
9. Doors and gates must communicate open, closed, locked, and ability-blocked states without relying on text.
10. Water surface height must match the gameplay transition plane exactly.

## Palette

| Function | Working color | Application |
|---|---:|---|
| Night void | `#07101F` | Deep cavities, foreground framing |
| Indigo structure | `#171A35` | Primary gameplay-plane mass |
| Violet shadow | `#332650` | Ambient shadow and room unity |
| Muted purple | `#594275` | Secondary stone, plaster, and trim |
| Wind cyan | `#59DFF3` | Anchors, wind channels, traversal response |
| Wind hot core | `#D2FDFF` | Contact flare and energy center |
| Window amber | `#F0A34A` | Habitation, safe focus, historic detail |
| Moss green | `#536F45` | Reclaimed ecology and damp stone |
| Water surface | `#28729B` | Base water color before lighting |
| Water highlight | `#76C9DD` | Ripples, caustics, entry response |
| Fire orange | `#F05A2A` | Fire gate, ember, heat response |
| Damage red | `#DC3D4F` | Universal danger only |

Bright cyan, green, orange, and red are semantic colors. Do not apply them as arbitrary decorative edge lights.

## Modular Kit Inventory

## A. Surface Architecture

The surface kit must build dense, intimate street/canal structures without depending on one flattened background image.

### Gameplay-plane modules

- Timber/plaster wall: 64 × 64 seamless tile.
- Timber beam vertical: 32 × 128 and 32 × 256.
- Timber beam horizontal: 128 × 32 and 256 × 32.
- Stone foundation wall: 64 × 64 seamless tile.
- Walkable stone/timber cap: 64 × 16 tile.
- Platform face: 64 × 48 tile.
- Left/right outer platform corners: 64 × 64.
- Inner concave corners: 64 × 64.
- Platform end caps: left and right, 32 × 64.
- Roof/eave underside: 128 × 64.
- Iron catwalk: 128 × 32 with matching 32 × 64 end caps.
- Railing set: 64 × 64 repeat, left/right ends, damaged variant.
- Stair or ladder visual set where gameplay permits traversal.
- Bridge support pier: 128 × 256 stackable.
- Canal retaining wall: 128 × 128 seamless vertical stack.

### Architecture dressing

- Warm window: closed, dark, lit, damaged; 64 × 96.
- Small lantern: unlit and lit; 32 × 64.
- Utility box: 64 × 64.
- Drain pipe kit: 32 × 64 straight, elbow, outlet, clamp.
- Cable kit: short, medium, long sag variants; separate transparent sprites.
- Sign brackets and weathered signs without dominant neon.
- Cloth/banner strips that reinforce wind direction.
- Moss, vine, crack, damp-stain, and plaster-damage decals.

## B. Vertical-Shaft Pieces

The Wind Relay room needs authored height, intermediate landmarks, and clear ascent rhythm rather than empty vertical space.

- Shaft wall tile: 128 × 128, vertically seamless.
- Structural column: 64 × 256 stackable.
- Crossbeam: 256 × 64 with 128 × 64 variation.
- Recessed maintenance alcove: 192 × 160.
- Narrow ledge: 128 × 32 and 192 × 32.
- Wall-mounted platform bracket: 64 × 96.
- Broken bridge section: 256 × 64 with readable collision edge.
- Vertical cable bundle: 32 × 256 tile.
- Relay conduit: 64 × 256 with inactive and wind-charged states.
- Tall parallax window/opening: 256 × 384.
- Top, middle, and bottom shaft transition caps.
- Height-marker dressing: banners, lamps, junction boxes, roots, or windows at deliberate intervals.

Vertical pieces must support exits at low, middle, and upper elevations. Door art cannot assume floor-level placement.

## C. Undercroft and Underground Transition

The transition must visibly move from inhabited surface construction into older damp infrastructure.

- Surface foundation-to-stone transition tile: 128 × 128.
- Arched canal opening: 256 × 256 with separate foreground rim.
- Descending tunnel frame: 192 × 256.
- Damp blue-black masonry: 64 × 64 seamless tile.
- Large stone block wall: 128 × 128 seamless tile.
- Stone floor cap: 64 × 16.
- Stone platform face: 64 × 48.
- Pipe wall run: 128 × 64 tile plus elbows and valves.
- Drain grate: 64 × 64.
- Root penetration variants: 128 × 128 transparent overlays.
- Wet-edge and mineral-stain decals.
- Ceiling arch and support columns for intimate corridor framing.
- Surface-light spill overlay for the entrance threshold.

Avoid hard visual cuts between surface and underground plates. At least one screen section should mix both material families.

## D. Canal and Traversable Water

Water is a traversable environment, not a death-plane texture.

### Base assets

- Water body fill: vertically tileable 128 × 128 translucent texture.
- Surface strip: 256 × 32 horizontally tileable.
- Surface highlight mask: 256 × 16 horizontally tileable.
- Near-bank wet edge: 64 × 32 tile with corners.
- Submerged wall/floor overlay: 128 × 128.
- Underwater depth gradient: full-width shader or gradient asset.
- Caustic pattern: 256 × 256 seamless animated/moving overlay.
- Suspended particle textures: small low-contrast set.
- Reflection breakup/noise mask: 256 × 256 seamless.

### Water VFX

- Entry splash: small and large.
- Exit splash.
- Surface ripple: idle, landing, swim stroke, projectile impact.
- Underwater bubble trail.
- Kunai impact: Wind, Fire, and Electric variants.
- Kaze waterline intersection mask or effect.

The surface strip, collision transition, and shader waterline must share the exact same Y coordinate. The body fill may tint the environment, but Kaze and enemies must retain readable local contrast.

## E. Fire-Return Gate

The Fire gate is an in-world lock, not an orange rectangle.

### Required components

- Architectural frame: 128 × 256.
- Central seal/barrier: 64 × 192.
- Fire-element glyph or socket.
- Conduit or brazier that explains where the kunai energy is received.
- Closed/inactive state.
- Fire-targetable/readied state.
- Hit-response state.
- Breaking/burning sequence.
- Cleared/open remains.
- Small map icon and loadout icon.

The lock should communicate “Fire required” through flame geometry, ember color, heat-scarred material, and a consistent glyph. Do not use text as the primary instruction. Wind and Electric effects may produce a readable rejection response without opening it.

## F. Doors and Teleport Exits

Exits must work at multiple elevations and remain readable against every room family.

### Door kit

- Standard framed door: 128 × 192.
- Narrow service exit: 96 × 160.
- Upper-wall/bridge exit frame: 128 × 192 with platform-compatible sill.
- Undercroft arch exit: 160 × 192.
- Closed, opening, open, combat-locked, ability-locked, and disabled states.
- Left- and right-facing threshold light masks.
- Interaction glyph/prompt backing plate.

### Teleport-transition language

- Interior darkness or fog should mask scene loading.
- Transition particles remain restrained and inherit the room palette.
- Combat lock should use desaturated red and mechanical bracing rather than a generic red block.
- Cleared exits use warm interior light or cool route light according to destination—not universal green.

Doors may be positioned at floor, mid-wall, or upper platform height. Their sills must align to collision and never imply a lower-right-only route.

## G. Platform Trims and Collision Covers

These are the minimum pieces required to cover simple Godot collision rectangles cleanly:

- 64 × 16 repeating top cap per primary material.
- 64 × 48 repeating face per primary material.
- 32 × 64 left and right end caps.
- 64 × 64 outer corners.
- 64 × 64 inner corners.
- 64 × 32 underside shadow.
- 64 × 64 cracked/damaged variation.
- 128 × 64 non-repeating hero variation.
- One-way platform variant with a thinner, visibly penetrable underside.

Materials required for P0:

1. Surface timber/stone composite.
2. Iron/bridge structure.
3. Damp undercroft stone.

Do not scale these pieces non-uniformly. Extend geometry by tiling center pieces and preserving end-cap proportions.

## H. Wind Anchors

Anchors must be authored fixtures that visibly belong to the Silent District.

- Wall bracket anchor.
- Ceiling/hanging anchor.
- Relay-machine anchor.
- Active idle animation or pulse.
- In-range highlight.
- Targeted/selected state.
- Tether-contact flare.
- Disabled/dormant state.
- Small map/tutorial icon.

All anchor variants share one cyan core shape so players identify function immediately. Outer housings may change by material family. The anchor center point in the texture must match the grapple coordinate exactly.

Recommended runtime footprint: **64 × 64 px**, with the functional center at **(32, 32)** and optional VFX extending beyond the base sprite.

## I. Checkpoint and Reliquary

### Checkpoint

- Architectural base: approximately 128 × 160.
- Dormant state.
- Available state.
- Activation sequence.
- Active/saved state.
- Respawn pulse.
- Local light mask and map icon.

Checkpoint language combines warm shelter light with a restrained cyan system accent. It should feel embedded in the district rather than like a floating pickup block.

### Reliquary

- Pedestal/base: approximately 160 × 192.
- Closed/sealed state.
- Available/opening state.
- Reward-present state.
- Empty/claimed state.
- Fire or ability-specific insert.
- Light rays, particles, and local environment response exported separately.

Reliquaries frame progression rewards as authored world objects. A reward must never appear as an unframed colored cube.

## J. Background, Foreground, and Parallax

### Background layers

1. Violet sky/cloud plate.
2. Distant mountains and pagoda silhouettes.
3. Far modern skyline and communications structures.
4. Mid-distance old district roofs and bridges.
5. Near-background canal buildings, arches, and utility lines.

Each layer should have enough lateral bleed for parallax and avoid high-contrast edges behind active gameplay.

### Underground layers

1. Deep cavity/void gradient.
2. Far masonry and arches.
3. Mid pipes, supports, roots, and water reflections.
4. Near gameplay plane.
5. Foreground columns, hanging roots, railings, and dark arch rims.

### Foreground rules

- Keep the central movement corridor below 20% opacity if foreground detail crosses it.
- Large opaque shapes should frame screen edges, not cover enemies or exits.
- Foreground masks must be testable independently and removable for accessibility if needed.
- Use foreground motion sparingly; it should not compete with attack telegraphs.

## K. Required P0 VFX

- Wind-anchor idle pulse, targeting highlight, contact flare.
- Tether strand support textures and release burst.
- Dash afterimage edge mask/trail.
- Water surface movement, entry/exit splash, ripple, bubbles, and caustics.
- Fire-gate impact, rejection, ignition, breakup, ember, and cleared-state smoke.
- Door lock/unlock and teleport threshold.
- Checkpoint activation and saved pulse.
- Reliquary opening and reward presentation.
- Neutral hit spark and environment dust/debris.

Effects use additive glow selectively. The readable core shape must remain visible without bloom.

## Nine-Slice and Tiling Rules

### Nine-slice assets

Use nine-slice only for geometrically scalable frames whose corners must remain fixed:

- Door backing plates.
- Gate energy-field frames.
- Prompt and map panels.
- Checkpoint/reliquary inset panels.

For a 128 × 192 frame, begin with **32 px borders** on all sides. Record final patch margins in the asset manifest and Godot resource. Never nine-slice painterly masonry, wood grain, cracks, windows, symbols, or hero decoration when stretching would be obvious.

### Tiling assets

- Tiling textures must be tested at 2×2 and 4×4 repetition.
- Remove visible seams and obvious repeating hero marks.
- Provide at least three visual variants for common wall/floor faces.
- Random variation may change stains and damage but not collision-edge location.
- Corners and caps are dedicated sprites, not cropped from center tiles at runtime.
- Do not non-uniformly scale detailed modules.

## Naming and Folder Rules

Recommended runtime structure:

```text
assets/environment/silent_district/
  backgrounds/
  surface/
  shaft/
  undercroft/
  water/
  doors/
  gates/
  anchors/
  checkpoint/
  reliquary/
  decals/
  foreground/
  vfx/
```

Runtime naming pattern:

`sd_<family>_<object>_<variant>_<state>.<extension>`

Examples:

- `sd_surface_platform_cap_stone_a.png`
- `sd_shaft_relay_conduit_a_active.png`
- `sd_undercroft_arch_large_a.png`
- `sd_water_surface_calm_a.png`
- `sd_gate_fire_a_closed.png`
- `sd_anchor_wall_a_targeted.png`
- `sd_checkpoint_a_saved.png`

Use lowercase snake case. Omit a segment only when it truly does not apply. Animation frames use zero-based, three-digit suffixes:

`sd_gate_fire_a_break_000.png`

Layered source pattern:

`sd_<family>_<object>_source_v###.<source-extension>`

## Export and Godot Import Rules

- PNG, RGBA, lossless for sprites, overlays, decals, and VFX.
- PNG, RGB or RGBA for opaque background plates as appropriate.
- sRGB color space.
- Transparent pixels must not contain bright matte halos.
- No baked checkerboards, labels, guides, crop marks, or debug collision.
- Painterly art uses linear filtering and mipmaps only when the final camera behavior benefits from them.
- Disable nearest-neighbor filtering unless a specific approved asset requires it.
- Use texture atlases for repeated small modules and animation frames where practical.
- Keep large background plates separate from gameplay atlases.
- Import repeatable textures with the correct repeat mode; verify seams in-engine.
- Record nine-patch margins, pivots, anchor centers, baselines, animation timing, and event frames in an asset manifest.
- Preserve layered source masters outside runtime import folders when possible.
- Record source, artist/generator, license, modifications, and approval status for every asset family.

## P0 Checklist — Playable Parity Slice

- [ ] One approved surface modular material set.
- [ ] One approved iron/bridge material set.
- [ ] One approved damp-undercroft material set.
- [ ] Collision-safe platform caps, faces, corners, ends, and undersides for all three materials.
- [ ] Surface architecture dressing sufficient to prevent repeated-room appearance.
- [ ] Vertical-shaft columns, beams, ledges, relay conduits, and transition caps.
- [ ] Authored surface-to-undercroft transition.
- [ ] Traversable water fill, surface, wet edge, caustic, ripple, splash, and underwater treatment.
- [ ] Fire-return gate with closed, response, breaking, and cleared states.
- [ ] Door/exit kit supporting low, middle, and upper placements.
- [ ] Wind anchor with idle, range, target, and contact states.
- [ ] Checkpoint or reliquary with authored states and local lighting.
- [ ] Background and parallax layers for surface, shaft, and underground rooms.
- [ ] Foreground framing kit with gameplay-safe opacity and placement.
- [ ] Required P0 VFX set.
- [ ] Asset manifest with dimensions, pivots, tiling, import, and licensing data.
- [ ] Five-room screenshot pass with debug collision hidden.
- [ ] Five-room collision-overlay pass confirming art/collision alignment.

## P1 Checklist — Vertical-Slice Polish

- [ ] Additional surface wall, platform, window, roof, and bridge variants.
- [ ] Alternate shaft machinery, damaged relay, and wind-reactive props.
- [ ] More undercroft arches, pipes, roots, drains, and submerged variants.
- [ ] Water current, waterfall/drain, projectile-water, and stronger depth effects.
- [ ] Electric-gate counterpart built from the same semantic system.
- [ ] Combat-lock and boss-lock door variants.
- [ ] Additional anchor housings for surface, shaft, and underground materials.
- [ ] Full checkpoint and reliquary animation polish.
- [ ] Environmental response to Fire, Electric, and Wind kunai.
- [ ] Accessibility variants for reduced bloom, reduced foreground occlusion, and high-contrast interactables.
- [ ] Performance pass on background plates, atlases, particles, shaders, and overdraw.
- [ ] Final consistency pass for scale, palette, lighting direction, saturation, and material repetition.

## Acceptance Standard

The kit passes when all five rooms look like parts of one authored district while retaining distinct spatial identities. No screenshot may depend on flat color blocks, pixel-art enemies or props, stretched concept textures, arbitrary neon edge strips, default debug symbols, or text labels to explain traversal. The route must remain readable when UI prompts are hidden and when collision shapes are not visible.
