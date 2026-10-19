# Independent 21-room narrative audit
Evidence: scripts/world.gd, world_expansion.gd, route_extension.gd, skyworks_region.gd and bellroof_walk.gd at README's review base. PR47 is a separate visual pilot; PR58 a separate Canal geometry branch. P0 = motivation/identity confusion; P1 = environmental clarity opportunity. Priorities are reviewer judgments, not playtest outcomes.

Gameplay evidence is implemented. Narrative treatments and all sample copy below are **proposed, not approved or implemented**. Sample descriptions are review candidates, not authorization for a new UI or new lore pickups. Conditional descriptions (restoration, opened routes) must never display before existing state permits them.

| ID | Room | Existing role / connections | Narrative gap | Proposed environmental treatment | Proposed concise description or clue |
|---|---|---|---|---|---|
| R0 | Canal Haven | Safe start; R1, R13 return | P0: no survivor-search motive in initial message; shelter identity unresolved | Temporary foothold; worn quay fittings match R13 | A quiet quay. The canal route continues east. |
| R1 | Lantern Market | Sentinel, Windstep; R0/R2 | P1: reward objective explains action but not civilian stakes | Shuttered stalls and handcart wear outside combat lane | Shuttered stalls line the canal road. |
| R2 | Flooded Cistern | Water traversal; letter/Wind cache; R1/R3/R15 | P1: before-dawn letter reads as a live deadline without date | Water gauges and drain arch echo Lower Sluice; do not date letter | A service channel runs below the market. |
| R3 | Echo Shrine | Tether/checkpoint; R2/R4/R9 return | P1: shrine function exists; clan ownership unproven | Worn bell supports frame existing anchor; no clan crest | An old shrine stands beside the crossing. |
| R4 | Broken Span | Swing route and Fire pickup; R3/R5 | P1: damage is visible but its cause is unknown | Broken piers support surviving route ends; no attack scorch attribution | Only parts of the crossing remain. |
| R5 | Ascent Tower | Vertical ascent, Dash/Electric; R4/R6/R17 | P1: ascent risks reading as arbitrary shelves | Background cable risers link working landings; no added lift | Service landings climb through the tower. |
| R6 | Tide Warden | Boss threshold to R7 | P1: blockade readable mechanically; allegiance unknown | Archive threshold visible beyond arena; keep telegraphs clear | The Warden blocks the way to the Archive. |
| R7 | Relay Archive | Relay milestone/checkpoint; R6/R8 | P0: restoration lacks connection to search | Routing records explain access; no survivor radar | Restored access opens more of the district. |
| R8 | Relay Undercroft | Sigil/checkpoint; R7/R9/R12/R16/R18 | P1: five links need distinct civic destinations | Repeat pump/shrine/relay symbols at real branches; preserve locked states | Service routes meet beneath the Archive. |
| R9 | Signal Terrace | Sigils; R3/R8/R10/R14 | P1: roof watch and intake connection under-explained | Sightline and material continuity toward Bellroof and SkyWorks | Roof-watch paths meet the industrial approach. |
| R10 | SkyWorks Approach | Three-sigil access, Wind intake; R9/R11 | P1: seal can look arbitrary | Intake louvers frame Wind seal; preserve specific gate hint | The sealed intake guards the foundry approach. |
| R11 | Storm Foundry | Checkpoint/Electric relay; R10/R12/R19 | P0: Foundry Refuge can imply the recovered clan settlement | Approve existing Rest Station proposal; shelter bay, no inhabitants | A rest station stands inside the foundry. |
| R12 | Keeper Relay | Boss, attunement, R8 return; R11 | P1: final instruction concludes repairs, not search | Emphasize usable return as local achievement, no reunion claim | The restored return leads back to the Undercroft. |
| R13 | Mooring Loft | Stride I; R0/R14/R20 | P1: Canal opening needs place identity; upper routes remain meaningful | Covered mooring service gallery fitted to PR58; shared quay material | A covered passage leads back to the quay. |
| R14 | Bellroof Walk | Roof/bell routes; R9/R13/R17; lower recovery/log | P1: lower space now has explicit purpose; reinforce rather than redesign | Existing BELLKEEPER SERVICE WALK and return signs anchor repair niches | Bellkeepers used this roof as a quiet convoy route. |
| R15 | Lower Sluice | Wind alcove, optional hazard; R2/R16 | P1: dry-pump note may be mistaken for attack chronology | Gauge and dry service walkway; no invented evacuation date | The inspection ledger records dry pumps before an evacuation. |
| R16 | Root Shrine | Checkpoint; R8/R15/R18 | P1: tended lamps imply someone active, identity unknown | Lamp care may suggest possibility, never Mizuki or a named trainee | Someone still tends the lamps. There is no name. |
| R17 | Counterweight Spire | Climb/rests; R5/R14/R20 | P1: worker note supports purpose; moving lift not implemented | Fixed guide rails and load plaques behind real stair landing | Counterweights once carried workers above the storm line. |
| R18 | Pump Gallery | Electric isolator, optional steam, guard; R8/R16/R19 | P1: strongest civic identity in PR47 pilot, not integrated baseline | Shared-feed pipe vocabulary; readable routing plate; exact existing vent source | These pumps served both canal and conservatory. |
| R19 | Coil Service Hall | Fire service seal, optional pulsing bay; R11/R18/R20 | P1: isolation note needs visible equipment context | Insulators frame existing Fire service gate; no corporate crest | Crews isolated these coils before the Keeper arrived. |
| R20 | Relay Junction | Persistent Mooring return; R13/R17/R19 | P1: switch explains route, not the benefit of retracing | Repeat Loft landmark and watch/maintenance symbols | The roof route and maintenance paths meet here. |

## Spaces whose context needs attention
- **R14 lower floor:** no longer fairly called purposeless. bellroof_walk.gd defines west/east recovery, support bays, log court and conventional returns; it already draws service-walk and roof-access signs. Dress those functions, do not eliminate the floor or repeat LD03's redesign.
- **R18 intermediate slabs:** PR47 explains them as interim catwalks. The overview visibly shows dense stacked ledges between large pump housings. Dressing improves industrial identity but cannot establish why every small landing exists; Level owns pending geometry decisions. Do not certify them as final architecture.
- **R5/R17 climbs:** movement purpose is clear; work circulation can be reinforced with fixed rails/numbering, not a promised operable elevator.
- **R8/R20 junctions:** branch count has purpose, but matching landmarks and functional signs would make the network readable without lore collection.
- **R15/R19 optional hazard spaces:** show maintenance access and a plausible equipment source; no new rescue clue is needed to justify every challenge.

The source supports 21 named rooms. This review does not claim an exhaustive fresh visual inspection of every reachable nook. Gameplay-purpose evidence and visual narrative adequacy remain different questions.
