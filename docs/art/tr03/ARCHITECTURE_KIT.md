# TR-03 — original entry architecture and support kit

All dimensions below are **proposed visual local-space dimensions**, not approved collider edits. Keep all existing top surfaces, anchors, endpoints and arrival pads. Dimensions are anchored to current~97px upright Kaze at zoom1 and the inspected TR-02 culvert opening132×204 with side supports/lintel. A dark opening and load-bearing threshold create depth; a colored rectangle alone does not.

| Module | Proposed visual envelope / origin | Structural language and sightline | Readability / placement rule |
| --- | --- | --- | --- |
| DEPTH-DOOR-01 | Opening100×132 inside frame144×168; origin threshold center | Two jambs, recessed rear plane, angled inner reveals, lintel and sill; separate front occluder for rear entry | Show Kaze's authored quarter/back turn, cover at the reveal; never move the visible route lip or E interaction point |
| STAIR-LANDING-01 | Landing192×32; visible four-step flight treads28/rise14; rear wall/setback beyond | Stringer follows undersides; posts meet the existing landing; rail/casing recedes into occlusion | Keep step contacts legible and rail below headband; **not a new functional staircase/collision** |
| CULVERT-PIER-01 | Repeat bay160×240, threshold origin | Squat stone piers, keyed arch/lintel, service-wall buttress; old water line on back plane | Do not cross the passage opening with decorative columns or seal colors |
| ROOF-BRACE-01 | 160×128 bracket backing, top-left attachment origin | Triangulated brace fastened beneath existing shelf into an actual visible wall/beam | If no wall/beam exists in the composition, do not draw a dangling bracket; use pier/terrain alternative |
| CANAL-SUPPORT-01 | 160×256 pier/cap bay; top-cap center anchor | Stone pier into water/bed, timber or steel crossbeam, secondary rear pile | Where floor exists below, connect to it; distant water cannot justify a false safe landing |
| RUIN-BUTTRESS-01 | 192×256 stone backing bay | Broken masonry mass joins existing platform to wall/terrain with cracks/root accents | Roots are supplementary, not sole unexplained support; topology/canon unchanged |
| SUSPENDED-BEAM-01 | Variable span with two shown cables to an existing visible roof beam | Only use when both upper attachment points are in the room composition | No new tether anchor implied; gray cables differ from green supported grapple targets |

## Per-room implementation requests

- **R14 Bellroof Walk:** prioritize isolated upper/switchback ledges visible in LD audit. Use roof truss/wall-backed brackets where an actual backdrop wall intersects, bridge stringers for gaps. Stairwell casing joins existing landing; preserve all three ports. Source screenshots: ART-01 R14 normal-camera baseline and LD room_14 comparison. Exact attachment coordinates require Lane A's current geometry audit.
- **R17 Counterweight Spire:** shaft-wall brackets, paired rail supports and crossbeam bays behind rest shelves. Never paint a gray cable as an interactive grapple target. No change to the three portals or wind shutter.
- **R15 Lower Sluice:** retain the approved directional open culvert and dry passage. Use stone retaining piers beneath existing service ledges and pipe saddles along real walls. Avoid decorative steam over vents. Do not relocate the Wind seal or alter arrival height.
- **R19 Coil Service Hall:** insulated service brackets and wall-supported catwalk stringers; keep Fire seal, upper route and lower combat lane visible. Coil rings are subdued gray/blue, not false Fire-red targets.

## Backing selection rule for unsupported platforms

1. Preserve exact collision/top lip.
2. Determine whether an actual wall, roof beam, terrain or floor can visibly receive load. If yes, select bracket/strut/pier with continuous contact at both ends.
3. If no plausible attachment exists, request a Level-approved scenic foundation; do not silently grow collision or draw an unsupported bracket.
4. A supernatural support requires explicit story/PM approval and exceptional visual coding. It is not the default excuse for floating shelves.
5. Check foreground support art cannot mask hazards, grapples, pickups, doors or map/UI. Most backing sits behind actors and route surfaces; only depth-door/stair reveal occluders may cover the staged visual proxy in the agreed cue window.

## Reusable source and export contract

Original schematic SVG concept kit; top-left/world-art pivots except threshold-centered entrance modules. Proposed layer names: back_wall,jambs_or_piers,structural_members,threshold_lip,front_reveal,optional_detail. Final RGBA PNG layers exported at native world-pixel scale, not stretched to room size; varied/taller piers use repeatable center sections with separate cap/foot. These diagrams are art references, not production textures or colliders.

Palette follows ART-01: city ink/indigo with restrained rose; stone/slate/cream for service areas; village warm timber/plaster where applicable. Preserve established gate/anchor colors. Upper façade details and optional props avoid HUD corners. Static backing is preferred over animated shaders;60FPS is a target, not a measured result of these diagrams.
