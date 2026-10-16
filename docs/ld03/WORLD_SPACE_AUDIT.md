# LD03 — reachable-space purpose audit

All21 room constructions were inspected against PR33, including their lower bands, destinations, combat footprints, intentional drops and return paths. The automated audit verifies that the other20 rooms retain the same ordered collision rectangles to0.001px, allowing only JSON rounding of generated float32 thirds. Source preservation checks independently guard unchanged room construction, gate, map and progression code. Bellroof retains every old platform and adds exactly12 authored masses/steps.

This is an authored-space audit with targeted physics tests, not an exhaustive navigation-volume proof or full human campaign. Open air used for jumping, tether arcs, combat or braking is deliberate clearance and must not be filled merely to remove empty pixels. A recovery floor needs a return path; it is not automatically good design because it catches falls.

| ID / room | Reachable-space purpose | Lower-space / return assessment | Disposition |
|---|---|---|---|
| 0 Canal Haven | Checkpoint, ordinary progression, upper exploration link | Grounded shrine route; roof drops return to a continuous approach floor. | Retain mobility/launch space. |
| 1 Lantern Market | Guard encounter, Windstep pickup, progression | Lower floor contains required combat and unlock; upper enemies/shelves add challenge. | Retain encounter footprint. |
| 2 Flooded Cistern | Water-gap challenge, Wind cache and subterranean branch | Finite dry floor islands are intentional landing/recovery areas; water stays hazardous. | Retain intentional gaps and seal. |
| 3 Echo Shrine | Checkpoint/tether milestone, Terrace return | Lower shrine is a progression destination, not filler; upper air provides tether clearance. | Retain shrine access. |
| 4 Broken Span | Gap traversal and Fire pickup | Dry islands provide recoverable challenge; high exit repaired by PR33. | Retain water/launch lanes. |
| 5 Ascent Tower | Dash/Electric progression and vertical exploration | Lower bands contain pickups and water recovery; ascent shelves form the route. | Retain real vertical lanes. |
| 6 Tide Warden | Required boss/arena challenge | Whole lower arena serves spacing, pursuit and recovery. | Do not insert cover or shrink arena. |
| 7 Relay Archive | Required Electric seal and restoration | Grounded console is a lower destination; shelves form approach and return. | Retain mandatory encounter/progression. |
| 8 Relay Undercroft | Checkpoint, intake encounter, sigil/junction | Lower area contains shrine and combat; high shelves branch to routes. | Retain combat and checkpoint approach. |
| 9 Signal Terrace | Named sigils, Fire cache, gated return | Bottom band is a fallback with return via lower1040 shelf and earned jump kit; long east catch lane is weakly signposted. | P2: improve return landmark; no speculative pickup. |
| 10 Skyworks Approach | Intake gate and traversal challenge | Bottom catch floor returns via1040 shelf/owned movement. Long east fallback is legible mainly from the map. | P2: service-route landmark before adding geometry. |
| 11 Storm Foundry | Encounter, checkpoint, Electric relay | Ground floor has real refuge/combat destinations; upper space provides relay challenge. | Retain refuge and telegraphs. |
| 12 Keeper Relay | Required boss and attunement | Lower arena is combat space; alternate elevated return is gated. | Preserve boss footprint and milestones. |
| 13 Mooring Loft | Overlook, optional Stride, roof/junction exploration | Floor is recovery with a low west return; east falls require a walk back. | P2: shorten/readably mark recovery in a future focused pass. |
| 14 Bellroof Walk | Roof progression, grapple challenge; now lower exploration and recovery | New service walk, existing log destination, grounded supports and three returns. | LD03 implemented and physics-tested. |
| 15 Lower Sluice | Dry descent, Wind gate, optional ledger and passage | Lower band is descent recovery with vent warning and east landing return; long west-to-east catch walk merits review. | P2: return pacing; preserve dry route and vent conventions. |
| 16 Root Shrine | Checkpoint, underground junction and exploration | Floor catches misses;1120 west shelf leads back to the checkpoint. Overhead route remains open. | Retain junction clearance; improve root-wall identity later. |
| 17 Counterweight Spire | Multi-screen climb and two regional connections | Bottom recovery leads to1900 landing; intermediate landings prevent a single empty shaft. | Retain vertical recovery and tether arcs. |
| 18 Pump Gallery | Electric service route, encounter and optional machinery lore | Lower catch returns via1180 terminal shelf; east fallback is comparatively long. | P2: a future local return/readability pilot; do not weaken Electric gate. |
| 19 Coil Service Hall | Regional/Fire route, encounter and optional service lore | Generated low return leads into the980 shelf sequence; far-west recovery is long and visually repetitive. | P2: service architecture and return pacing. |
| 20 Relay Junction | Persistent shortcut and loop closure | Bottom band recovers to1120 right shelf; upper garden/shortcut is a meaningful destination. | P2: clearer west-to-return cue; retain unlock conditions. |

## Prioritized findings

P1 resolved in this pilot: Bellroof lower space lacked a destination, readable re-entry structure and believable support/collision agreement. It now has all three.

No new P0 softlock is established by this audit. That is not a softlock certification. P2 candidates remain in9/10/13/15/18/19/20: the catch space has a valid recovery role but often weak visual guidance or a long walk. They are explicitly identified for later targeted room passes; this delivery does not pretend those rooms were redesigned. Keep their legitimate drops and owned movement routes while improving the actual return architecture.

No new story pickups were scattered into empty areas to manufacture purpose. No canon, boss, save schema or graph changes were made. The Bellroof log is the existing optional item, relocated with its original persistence key.

Acceptance questions for creator playtest: does the lower loop invite exploration rather than feel like a penalty; are the three returns readable at normal zoom; does the log court justify the detour; do grounded obstacles remain enjoyable with Kaze's existing speed? Record any remaining band with no useful action or understandable return as a concrete room/coordinate defect.
