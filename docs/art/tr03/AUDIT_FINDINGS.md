# TR-03 character and architecture audit findings

## Verified existing character source

All four active strips are RGBA PNG, with eight equal cells. Source alpha>0.1 does not touch any cell border. Minimum strong-alpha margins measured across frames: idle25px,run13px,combat24px,traversal24px. See QA_RESULTS.json for per-frame bounds, source pivots and scales. Those margins prove cell containment at that threshold, **not complete artwork or halo quality**.

Rendered contact sheet shows some detached combat/traversal fragments inside cells. The previous boundary pass explicitly could not reconstruct already clipped/missing artwork. These source limitations remain preserved, not silently corrected or relabeled final animation QA. Transparent edges were visually checked on black, white, gray and indigo; no new painted transition frame exists to certify.

Current movement uses the run clip even at low speed. There is no accepted walk, rear turn, depth entry or stair cycle. Current run can continue into/out of the horizontal pilot, but new walk and direction-specific depth/stair art are needed for final embodiment. The diagrams use schematic figures; the actual identity anchor is CONTACT_existing_kaze.png and the approved source assets.

## Verified architecture constraints

TR-02 source keeps the directional R15/R16 pilot, R14/R17 stair control and R20/R13 wind-fold. Current portal art uses supports, door/stair housings and decorative backgrounds; no new transition graph or endpoint is required by this art kit. Static room y coordinates do not establish geographic stair direction. A depth-facing demo needs an explicit eligible endpoint from Level.

Existing ART-01 R14/R15 baseline images and LD R14/R15/R17/R19 comparisons guide support priority, not new collision. Roof shelves need brackets only where a visible wall/beam can receive them; otherwise use a reviewed stringer/pier/terrain backing. A support that ends in empty space does not solve floating architecture. Structural dressing must be coordinated with the actual current Level geometry before placement.
