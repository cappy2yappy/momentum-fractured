# TR-01-0061 — contextual entrance prototype specification

Verified foundation: `integration/candidate-alpha-0.6.1-gp-ld` at `afecef1922231081807a332c511de85c7941fec8`. Assignment read in full from `c1e233d6831842b45f30239d6321799368d6fe9f`; authoritative assignment branch is `docs/pm-tr01-alpha-0.6.1-room-transitions`. Review only; no migration or integration approval.

## Audit and selection

Reviewed canonical baseline/repository guide, LD-01 report and PR #9 comparison evidence, PM creator decision record, and all three combined PR #10 atlases covering 54 captures (1280×720 zoom 1.0). Original LD comparison captures were zoom 0.65; they are composition references, not evidence of ordinary-camera readability. Fresh matched before/after captures below use zoom 1.0.

The root `project.godot`/`scenes/main.tscn` is active. `world.gd.draw_door()` delegates to `RoomPresentation.draw_exit()`. Original chain exits, route-extension returns and expansion portals all reuse that drawing interface, so a global replacement would unintentionally affect all exit families. The LD housing is 64×84, its inset 48×65, its base 96×14 and its E text 12px. Kaze is visually taller than the housing at ordinary zoom. Existing world backgrounds and gate artwork are already high contrast; entrance cues should use warm ivory rather than the elemental green/red/blue seal shapes.

`world.interact()` checks checkpoints and expansion/extension interactions before original chain exits. Primary binding is physical E, also exposed as the existing touch interaction. Original chain exits use strict distance <105. Expansion portals use strict distance <85. Original extension returns have their own distances (see `route_extension.gd`); this prototype does not change any of them. Drawing size has no effect on activation.

`request_room()` rejects active transitions, invalid rooms and failed `can_enter()`, then freezes player physics and sets the existing 0.65-second transition clock. At <0.32 seconds it builds the target room, uses an explicit reciprocal expansion arrival or the original east/west offset, clears velocity and resets camera smoothing. At clock expiry physics resumes. `respawn()` clears the clock/pending target and restores physics. `save_progress()`/`load_progress()` retain version 8 and historical app/save identity. No code in those interfaces changed.

R14 **Bellroof Walk** and R15 **Lower Sluice** were selected because the existing source already establishes roof and retaining-arch identities, supported portal landings and playable conventional routes. These are existing rooms in the same connected graph, not a newly connected pair: one path is R14↔R13↔R0↔R1↔R2↔R15, subject to current abilities. No direct R14–R15 link is added. The pilot covers all three R14 exits and both R15 exits; neighboring endpoints retain their current architecture.

| Pilot | Feet position | Target | Reciprocal arrival | Existing shared requirement |
|---|---|---|---|---|
| R14 west | (120,1100) | R13 Mooring Loft | (1680,558) | Windstep |
| R14 east | (2440,830) | R9 Signal Terrace | (1100,1038) | Relay restored |
| R14 upper | (1450,480) | R17 Counterweight Spire | (1680,1298) | Tether + Gale Dash |
| R15 upper west | (120,500) | R2 Flooded Cistern | (470,1118) | Wind Kunai + Cistern Wind cache opened |
| R15 lower east | (2080,1120) | R16 Root Shrine | (120,1118) | Relay restored |

Reverse arrival is pilot feet coordinate minus (0,2); both-direction prerequisites derive from unchanged `EDGES`/`allowed()`. R15's physical Lower Sluice Wind gate remains at (500,500), distinct from the Cistern cache route prerequisite. No collision, arrival pad, platform, enemy lane, lore or gate position changed. R14's roof background and R15's dry-service background remain placeholders; Art PR #11 was not imported.

## Treatments and alternatives

**A: roof service stairwell.** 148×174 solid housing, 164×16 cap, recessed 106×145 entrance, five stair marks, handrail and warm lintel lamp. The base is 172×16 and visually follows the existing shelf without adding solids. Its stairs and cap make it read as a service route rather than a floating outline.

**B: masonry passage.** 110px dark recess, 134px arch diameter with nine stone segments and two masonry uprights, warm interior edge and the same grounded base. It reads as a tunnel/culvert on the existing canal service shelf, without declaring a final Ruins location.

Both use a 22px E/arrow marker and a separate 16px proximity caption: E · ENTER inside the strict 85px circle, APPROACH outside it, or LOCKED plus the current prerequisite with a padlock. Destination labels and route ID plaques move above the larger facade only in pilot rooms. Warm open cues avoid implying new elemental requirements.

**Affordance alternative 1:** architectural entrance with a quiet, stationary transition signature, launched with `--tr01-reduced-motion` (the package includes dedicated launchers). **Alternative 2:** the same navigable architecture accented by three concise rotating wind arcs around Kaze during the existing fade. The wind-fold is drawn in HUD canvas coordinates at the current player location on departure and arrival. It is bounded to transitions involving a pilot room; unrelated transitions retain the old outline. Neither alternative requires shaders, particles or asset generation. The inherited full-screen fade remains in both alternatives.

## Implementation and preservation

A bounded `PILOT_STYLES` map selects only R14/R15. Existing portal dictionaries supply target/need/feet positions; no new destination data is authored. `draw_legacy_exit()` preserves the old drawing body for other rooms. `hud.gd` delegates the transition accent and falls back to the old outline. The only `world_expansion.gd` change moves pilot destination text upward; all code before `draw_room()` is byte-identical.

Effects are a pure function of the existing clock and room IDs, with no timers, player modulation, new invulnerability, input lock or saved preferences. Death/reload cannot leave an independent effect state behind. A launch argument removes angular motion; E semantics, fade length and gameplay remain unchanged.

See `TR01_ALPHA061_TEST_RESULTS.json`, raw logs and preservation hashes under `docs/agent_handoffs/tr01_evidence/`. All 51 audited foundation/assets files are byte-identical, including player.gd, world.gd, momentum, grapple, original/cleaned character art, project configuration and map data. Dedicated checks cover five pilot exits and reciprocal returns, all relevant shared gates, 85px boundary rejection, actual E event, held/repeated E, exact supported arrivals, unchanged geometry, death restoration, save/reload and an original 105px exit.

## Evidence and rollout hazards

Native-resolution before/after PNGs exist for every pilot endpoint. `comparison_r14.jpg` and `comparison_r15.jpg` stack before over after. Locked-state PNGs, wind-fold stills and a real transition GIF complement them. GIF uses the actual transition code advanced at one 60Hz tick per rendered frame, sampled every three frames at 50ms; it is a seeded test visualization, not a continuous human playthrough.

The art is intentionally procedural placeholder architecture. Larger visible facade does not imply a larger interaction circle: review APPROACH/E feedback for usability. Future production art must preserve landing geometry and keep gate silhouettes distinct; route plaques might need reflow with longer localized labels. Reduced motion is currently a launch option rather than a saved menu setting. Human approval is required for scale/visual feel and any later global rollout. No new rooms, prologue/story sequence, bosses, connectivity or mandatory effect technology are introduced.
