# Momentum: Fractured — Art Bible

**Status:** Foundation for the web-parity restoration line
**Visual target:** Painted anime metroidvania; drowned Tokyo noir at violet dusk
**Authority:** Use this document with `GDD.md`. When older art notes conflict, the canonical web-parity section of the GDD and this Art Bible take precedence.

## Visual Identity

Momentum: Fractured takes place in a drowned, fractured Tokyo where old timber neighborhoods, modern infrastructure, submerged masonry, and reclaimed nature overlap. The presentation is moody and painterly rather than generic neon cyberpunk or pixel art.

The visual hierarchy is:

1. Dark, readable gameplay silhouettes.
2. Authored, painterly architecture and atmosphere.
3. Sparse luminous accents with mechanical meaning.
4. Warm traces of human life—windows, lanterns, shrines—against cool indigo environments.

Every finished room must clearly separate the gameplay plane from background and foreground depth. Atmosphere may reduce detail, but it must never hide Kaze, enemy attack anticipation, hazards, exits, anchors, gates, or traversable water boundaries.

## Reference Order

When references disagree, use this order:

1. The playable web benchmark and the current canonical notes in `GDD.md`.
2. `rebuild/assets/district.png` for world mood, architecture, light, and depth.
3. `rebuild/assets/idle.png` and `rebuild/assets/run.png` for Kaze's canonical identity.
4. `rebuild/assets/combat.png` and `rebuild/assets/traversal.png` as pose studies only.
5. `rebuild/assets/terrain.png` as a material reference, not a finished modular tileset.
6. Legacy Godot art only as temporary mechanical placeholders.

This resolves the older contradiction between broad “neon cyberpunk” language and the later warm, atmospheric Tokyo-noir direction. Technology may glow, but the world should not read as a field of equally saturated neon signs.

## Canonical Kaze

The active Kaze design is the purple-and-green character shown in the web benchmark and the reference sheets under `rebuild/assets/`.

### Identity invariants

- Dark skin.
- Long dark-purple hair.
- Large vivid-green hair ribbon.
- Fitted purple jacket with white collar and cuffs.
- Bright green chest bow.
- Dark pleated skirt.
- Purple thigh-high stockings.
- Purple ankle boots.
- Athletic adult proportions; never chibi.
- A strong forward-leaning movement silhouette.

The red-scarf, cropped-top, loose-pants character under `assets/sprites/kaze/` is deprecated. `scenes/kaze.tscn` currently uses that legacy set only as an implementation placeholder. It must not guide new character art, promotional art, portraits, or UI icons.

### Canonical-source limitations

The canonical reference sheets are not production-ready sprites:

- The checkerboard is baked into RGB images rather than supplied as transparency.
- Poses are arranged as composite sheets rather than normalized horizontal strips.
- Frame boxes, scale, foot baselines, spacing, and crop margins vary.
- Generated pose studies occasionally vary costume details and proportions.

Before integration, create one approved model sheet and rebuild every frame on a consistent transparent canvas. Maintain stable proportions, costume construction, palette, lighting direction, and silhouette across all animations.

### Required animation coverage

- Idle.
- Run, start, stop, and turn.
- Crouch and slide.
- Jump anticipation, rise, apex, fall, and land.
- Wall slide and wall jump.
- Dash.
- Tether fire, attach, swing, and release.
- Three-hit attack sequence.
- Kunai throw.
- Swim and water transition.
- Hurt, defeat, and respawn.
- Guard Veil activation.

## Working Palette

| Function | Working color | Use |
|---|---:|---|
| Night void | `#07101F` | Deep negative space and foreground framing |
| Indigo structure | `#171A35` | Primary dark architecture |
| Violet shadow | `#332650` | Ambient shadow and atmospheric unity |
| Muted purple material | `#594275` | Secondary surfaces and character harmony |
| Wind energy | `#59DFF3` | Tether, wind kunai, anchors, traversal guidance |
| Wind highlight | `#D2FDFF` | Hot energy cores and contact flashes |
| Window/lantern warmth | `#F0A34A` | Human presence, shelter, and historic detail |
| Reclaimed moss | `#536F45` | Vegetation and damp reclaimed spaces |
| Fire element | `#F05A2A` | Fire kunai, seals, embers, and heat damage |
| Electric element | `#F4D83D` | Electric kunai, conductors, and charged gates |
| Damage/danger | `#DC3D4F` | Damage confirmation and universal danger |
| Kaze ribbon/bow | `#39E866` | Character identity accent |

### Palette rules

- Indigo and violet establish the world.
- Amber indicates inhabited memory, safety, history, or a focal architectural detail.
- Cyan is reserved for wind, tethering, authored traversal guidance, and selected interactables.
- Green belongs primarily to Kaze's identity and reclaimed vegetation. Do not use it as arbitrary platform trim.
- Fire and electric colors must remain distinct across projectiles, gates, impacts, and UI.
- Bright colors should occupy a small portion of the screen so important objects retain visual priority.

## Materials, Depth, and Lighting

### Depth bands

- **Background:** Lower contrast, softened detail, atmospheric violet, minimal gameplay-significant edges.
- **Gameplay plane:** Sharp silhouettes, legible material breaks, controlled highlights, and reliable collision readability.
- **Foreground:** Near-black framing shapes such as roots, beams, masonry, railings, cables, or architecture.

### Material rules

Gameplay collision must be covered by believable authored material. Narrow platforms need modular top caps, wall faces, corners, seams, damage variants, and shadow undersides. Do not stretch an entire terrain panel across a platform.

Surface architecture should favor timber, plaster, tile, stone, canal walls, iron railings, and utility infrastructure. Underground spaces use damp masonry, mineral staining, roots, pipes, and reflective water. Industrial spaces may introduce worn metal, rust, and controlled magenta accents.

### Lighting rules

- Cool violet-blue ambient dusk or subterranean fill.
- Warm localized windows, lanterns, shrines, and inhabited remnants.
- Cyan wind effects light only their immediate surroundings.
- Doors, anchors, elemental gates, hazards, and water transitions require silhouette separation.
- Avoid full-screen color washes that recolor Kaze or erase material distinctions.

## Environment Families

### Silent District Surface

Layered timber homes, dense canal infrastructure, utility poles, bridgework, and distant modern structures under a violet sky. Warm windows create pockets of memory and shelter. Rooms should feel intimate and authored rather than like empty panoramic stages.

### Broken Span and Wind Relay

Rooftop and bridge fragments, exposed cables, shrine hardware, weather vanes, cloth strips, and damaged transit infrastructure. Cyan wind channels and authored anchor fixtures provide traversal rhythm.

### Canal Undercroft and Rootwell

Blue-black masonry, arches, drains, pipes, roots, and submerged structures. Traversable water requires a clear reflective surface, entry ripples, wet edges, caustics, suspended particles, and a readable underwater value shift. A translucent blue rectangle is never final water art.

### Conservatory and Reclaimed Ruins

Broken glass, moss, vines, roots, damp stone, and decaying architecture. Green enters through ecology and the character identity palette, not arbitrary level outlines.

### Borrowed Face Sanctum

Ritual architecture fused with fractured technology: masks, reflective surfaces, memory echoes, repeated silhouettes, and controlled visual distortion. Muted magenta may support this family, but a scaled standard enemy is not an acceptable boss identity.

## VFX Language

### Wind and tether

- Cyan-white filament core with a soft blue outer glow.
- Directional pulses, wisps, spirals, and tapering trails.
- Clear contact flare at the authored anchor.
- Motion should communicate tension, direction, and release momentum.

The tether colors in `scripts/player/kaze_base.gd::_draw()` are directionally correct, but the final effect should integrate with Kaze's firing pose and the anchor fixture.

### Dash

- Two to four short-lived silhouettes.
- Cyan edge separation with reduced interior opacity.
- Afterimages follow the motion arc and never obscure hazards or resemble active characters.

### Fire kunai

- Orange-white core, red-orange wake, ember breakup, and heat distortion at stronger impacts.
- Fire seals should burn, melt, rupture, or consume—not merely disappear.

### Electric kunai

- Yellow-white core with angular violet secondary arcs.
- Electric seals should conduct through visible nodes before failing.

### Damage and combat

- Directional slash or impact shapes aligned with the source of force.
- Brief value flash, restrained particles, and readable knockback.
- Attack anticipation, active danger, and hit confirmation must use distinct timing and shapes.

### Guard Veil

- Thin wind-ring, shell, or rotating sigil around Kaze.
- Do not represent the final effect by tinting the entire character green.

## Production Asset Rules

1. Concept sheets and generated pose studies are references, not automatically shippable assets.
2. Character assets require transparent backgrounds, consistent canvas dimensions, stable baselines, and registered body landmarks.
3. Never mix pixel-art enemies with painterly high-resolution characters in a parity-ready build.
4. Character and enemy silhouettes must read at gameplay scale before interior detail is added.
5. Every enemy attack needs anticipation, active, recovery, hurt, and defeat readability.
6. Environment art must be modular enough to fit collision geometry without destructive stretching.
7. Decorative detail may overlap collision only when it does not misrepresent where Kaze can stand or move.
8. Ability colors communicate meaning consistently in the world, HUD, map, loadout, gates, and effects.
9. Export source files and runtime files separately; preserve layered masters when available.
10. Record creator, source, license, generation method, and modification history in the asset manifest.

## Current Gap Audit

- `scenes/kaze.tscn` uses deprecated red-scarf Kaze artwork.
- Canonical Kaze sheets under `rebuild/assets/` are not production-ready or transparent.
- Rooms 1–4 rely heavily on flat `ColorRect` geometry, while later route rooms use painterly backgrounds; the campaign visibly changes art styles.
- `scripts/rooms/route_room.gd` repeats one background and stretches terrain regions across platforms, producing collage-like rather than authored rooms.
- Platform edge color changes from cyan to green based on room number rather than gameplay or material meaning.
- Enemy assets under `assets/sprites/enemies/` are explicit pixel-art placeholders and clash with canonical Kaze and the painted world.
- Echo uses a cropped pose from `rebuild/assets/guards.png`; Drone remains a purple square.
- Storm Reliquary and Borrowed Face are scaled standard enemies rather than unique bosses.
- Elemental gates in `scripts/rooms/kunai_gate.gd` are colored rectangles with lines and do not depict an in-world mechanism.
- Grapple anchors are readable but generic cyan hexagons rather than Silent District fixtures.
- HUD, map, loadout, and pause screens use mostly default Godot controls and typography.
- UI lacks an approved Kaze portrait, ability icons, elemental icons, map symbols, and cohesive panel framing.
- Hazards, pickups, checkpoints, refill stations, doors, and reliquaries remain primitive or placeholder objects.
- Water is currently represented by a translucent rectangle without surface, depth, wet-edge, entry, or underwater effects.

## Prioritized Art Backlog

### P0 — Next parity slice

1. Approve one canonical Kaze model sheet with fixed proportions, costume callouts, and palette.
2. Produce clean transparent standing and running reference exports for mockups.
3. Build production-ready idle, run, jump, fall, dash, and wall-slide animation strips before replacing the legacy runtime sprite.
4. Create one modular Silent District kit: ground caps, wall faces, corners, beams, bridge pieces, doors, undercrofts, and collision-safe overlays.
5. Complete one authored surface-to-underground-to-water art slice before distributing partial art across the campaign.
6. Replace Echo and Drone with style-consistent production prototypes including attack telegraph, hurt, and defeat states.
7. Create final wind-anchor, water, fire-gate, and electric-gate visual designs.
8. Establish the first authored UI theme: font, panels, health, map cells, loadout frame, ability icons, and elemental state colors.

### P1 — Vertical-slice completeness

1. Finish Kaze combat, kunai, tether, swimming, hurt, defeat, and Guard Veil animations.
2. Create Guardian/ground-mech and ranged-enemy families with a shared silhouette language.
3. Give Storm Reliquary and Borrowed Face unique silhouettes, attack telegraphs, rewards, and arena motifs.
4. Build environment decal families: cables, signs, windows, roots, moss, pipes, shrine objects, cracks, and water damage.
5. Produce dedicated VFX for wind, fire, electric, Guard Veil, impacts, enemy deaths, pickups, checkpoints, and door unlocks.
6. Create foreground occluders and parallax layers that add depth without compromising visibility.
7. Replace checkpoints, refill stations, pickups, doors, reliquaries, and hazards with authored objects.

### P2 — Campaign production

1. Extend the modular environment language into Temple, Metro, Rooftop Garden, Docks, and Fractured Core families.
2. Build full enemy animation sets and visually coherent elite variants.
3. Create boss-specific arena art and phase-transition effects.
4. Add cinematic portraits, story panels, lore objects, menu illustrations, and accessibility variants.
5. Perform a campaign-wide consistency pass for scale, silhouette, outlines, lighting direction, saturation, animation timing, VFX intensity, and UI iconography.

## Acceptance Check

A screenshot is not parity-ready if it contains the legacy Kaze design, obvious primitive geometry, stretched terrain panels, pixel placeholder enemies, default Godot UI, or effects whose color does not communicate their gameplay function. The finished slice should read as one authored world even when all UI text is hidden.
