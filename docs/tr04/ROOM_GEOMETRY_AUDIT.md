# TR-04 / LD-02 room geometry audit

2026-10-16. Source: PR31 `c2c6b08bfb3b85ad174dcc7ef60bddf1a3a48c15`.
All 21 constructed room definitions and their exit support rectangles were recorded before/after. Native Windows overview captures were inspected together; this is a geometry/presentation audit, not proof of every jump or a fresh campaign completion. `CANAL ROUTE` is the global HUD title, so it cannot uniquely identify a room. Both Canal Ward left-exit defects in Mooring Loft and Bellroof Walk were reproduced geometrically and repaired.

## Priorities

| Priority | Defect | Disposition |
|---|---|---|
| P0 | Canal Ward left exits: walls contain the capsule but elevated landings end at x40/80/100. Stopping beyond the ledge drops Kaze below the doorway. | Extend the existing allowlisted landing to x0; retain one-way shape, height and gate. |
| P0 | Same unsupported perimeter strips at other expansion exits. | Repair both near-boundary sides across R13-20; do not extend intermediate shelves. |
| P1 | Broken Span right doorway at x2440 extends beyond its shelf ending2400. Cistern right shelf ends2480 before wall2600. | Extend their existing exit ledges to2600; water pits remain unchanged. |
| P1 | Signal Terrace right shelf ends2460; default R10 return feet828 overlap shelf810-850. | Extend shelf to2600; correct only that implicit arrival to feet808. Explicit returns and saves unchanged. |
| P2 | Exposed rectangular surfaces and repeated district backdrop dilute biome identity. | Reuse existing material atlas inside collider silhouettes now; request authored terrain/caps/backgrounds. |
| P2 | R17 ART04 stair ends cropped at wall. | Add recessed atlas wall return; retain source crop, scale, feet anchor and front-lip registration. |
| P2 | Door/stair held keys lack complete motion and outward/reorientation arrivals. | Keep truthful held-key/fallback labels; request frames. No invented cycles. |

## Room-by-room findings

| ID | Room | Geometry and boundaries | Environmental / follow-up work |
|---|---|---|---|
| 0 | Canal Haven | Continuous recovery floor; checkpoint and upper route retained. No perimeter gap found. | Canal quay masonry, dock edge caps; preserve upper route. |
| 1 | Lantern Market | Continuous floor; original elevated encounters retained. No perimeter gap found. | Stall foundations and roof brackets; authored ledge patrol audit remains useful. |
| 2 | Flooded Cistern | Right exit shelf extended120px. Three deliberate water gaps and Wind cache seal/reward guard retained. | Wet masonry, readable water lips, sealed-cache jamb. |
| 3 | Echo Shrine | Left shelf reaches wall; recovery floor retained. Upper Terrace return is intentional. | Shrine plinths and distinct return architecture. |
| 4 | Broken Span | Right shelf extended200px to wall, supporting doorway. Two water gaps remain intentional. | Broken bridge caps and piers must stop before water lanes. |
| 5 | Ascent Tower | Left exit supported; full-width right shelf and floor sections retained. Two water gaps intentional. | Tower braces and clear vertical navigation; do not infill ascent. |
| 6 | Tide Warden | Right floor is20px below doorway feet marker; safe downward settlement retained. No unsupported perimeter strip. | Align future threshold art to landing; retain boss arena. |
| 7 | Relay Archive | Left wall-side shelf and right recovery floor supported. Electric seal unchanged. | Archive retaining walls and relay plinth; no gate-covering foreground. |
| 8 | Relay Undercroft | Left/right ledges reach walls; all junction shelves retained. | Intake architecture and shrine identity. |
| 9 | Signal Terrace | Right shelf extended140px; precise implicit arrival overlap fixed. Electric return/Fire cache gates retained. | Right door art remains20px below shelf marker; authored threshold request. |
| 10 | Skyworks Approach | Both perimeter exits supported. Wind intake unchanged. | Industrial caps, suspended supports and intake frontage. |
| 11 | Storm Foundry | Left shelf and right recovery floor supported; checkpoint/relay retained. | Furnace masonry and pipe supports without hiding telegraphs. |
| 12 | Keeper Relay | Floor-supported ordinary exit; alternate elevated return supported. Boss/attunement untouched. | Relay ruin silhouette; preserve arena reads. |
| 13 | Mooring Loft | Left generated pad extended40px; right upper shelf extended40px. Safe stop/reapproach at left wall verified. | Quay wall return, overlook support; Stride pickup retained. |
| 14 | Bellroof Walk | Left landing reaches0; redundant generated pad no longer needed. Right shelf extended50px. Stair and vertical routes retained. | Roof-cap/wall-return kit; approved ART04 roof support retained. |
| 15 | Lower Sluice | Left shelf extended80px, right50px. Dry service descent and one-way recovery landings retained. | Masonry caps, retaining wall returns; approved ART04 arch retained. |
| 16 | Root Shrine | Left shelf extended80px, right50px. Checkpoint/junction and overhead route retained. | Root-bound masonry and checkpoint plinth, no false solid roots. |
| 17 | Counterweight Spire | Left shelf extended80px, right50px at stair. Intermediate landings and full vertical shaft retained. | Recessed stair wall return added; authored counterweight beams requested. |
| 18 | Pump Gallery | Left shelf extended80px, right50px. Electric service gate and lower recovery floor retained. | Pump bases, green reclaimed masonry, vent warnings. |
| 19 | Coil Service Hall | Left shelf extended80px, right50px. Fire service route and regional prerequisites retained. | Insulated brackets, industrial caps; avoid rope-path dressing. |
| 20 | Relay Junction | Left shelf extended80px, right50px. Persistent shortcut and wind-fold remain gated. | Root-bound junction foundations and shortcut landmark. |

## Evidence and limits

[Before geometry](evidence/geometry_before.json), [after geometry](evidence/geometry_after.json), [21-room overview](evidence/ROOM_OVERVIEW.jpg).
The overview uses fitted camera zoom solely for inspection; play captures use1280x720/zoom1. The overview player is a staged inspection marker, not a legitimate arrival.

Canal Ward native captures (same fixed camera/feet fixture, no simulated fall claimed):

| Room | Before | After |
|---|---|---|
| Mooring Loft | [Before](evidence/R13_left_before.png) | [After](evidence/R13_left_after.png) |
| Bellroof Walk | [Before](evidence/R14_left_before.png) | [After](evidence/R14_left_after.png) |

All interior shelves remain thin traversal ledges. Surface texturing does not establish complete structural architecture. Further authored supports must remain behind traversal, and require collision review if intended to become solid.
