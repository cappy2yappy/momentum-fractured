# ART-01-0061 — Environment asset matrix

All rows are proposals. No room is geographically reassigned and no collision is altered. Room sizes are inspected at integration commit `34be30436996284ec2f783269c40269d321ed427`; LD refinements are inspected on `a4926e9f0667168f390ab99279efe3243055aa3f` and are not silently merged.

| Priority | Room / real world size | Modules requested | Navigational constraints | Prototype / state |
| --- | --- | --- | --- | --- |
| P0 | R14 Bellroof Walk / 2600×1440 | City sky, skyline, bell shelter silhouette, roofs, tanks, civic mast | Three portals and anchors; west-to-east roofs and upper branch; no bright windows behind anchor circles or thin false ledges | CITY-ROOF-01 layered SVG composition prototype; authoring sample width2560 uses repeat/chunking, not stretched whole-room image |
| P0 | R15 Lower Sluice / 2200×1440 | Culvert wall, retaining arches, dry pipes, inspection niches, low canal band | Wind seal near west entry, stepped descent, dry route, vents/recovery floor; avoid reflective water over actual hazard bounds | UNDER-ARCH-01 layered SVG prototype; B1-B civil-infrastructure motif, **not chosen narrative ruins location** |
| P1 | R17 Counterweight Spire / 1800×2160 | Shaft wall panels, two rails, cable bundles, counterweight silhouettes, level marks | Three portals, staggered rests, tall climb; depth stripes must not resemble one-way platforms | Specification only; vertical modular repeat after LD geometry approval |
| P1 | R19 Coil Service Hall / 2400×1440 | Coil bay panel, insulator silhouette, service conduit, isolated maintenance lamp | Upper Fire seal, lower combat lane, vent telegraph, two portal routes; machinery supports stay behind actual collision | Specification only; avoid red coils mistaken for Fire targets |
| P0 concept | B0 Hidden Village / no approved room size | Mountains, tree belt, housing, fields, irrigation, daily-life props | No room number assignment; maintain ~97 px Kaze visible height at current zoom in later blockout | B0 identity sheet and concept board; production scene pending PM/Story/LD |
| P0 concept | B1 Ruins / no approved room size | A shrine roots / B canal remains / C shelter | Neither wake-up event nor exact travel route is selected | Three concept variants and B1 identity sheet; creator/Story selection required |

## Modular asset requests

| ID | Draft export target | Layers / pivot | Production acceptance |
| --- | --- | --- | --- |
| CITY-ROOF-01 | sky2560×1440; skyline2560×1440; silhouettes2560×1440 | Layered source with opacity-preserving groups; top-left module origin; scenic rooftop silhouettes remain background | Palette approval; seamless edge test; unlit route corridor; no false platforms |
| UNDER-ARCH-01 | base2560×1440; arches2560×1440; pipes2560×1440 | Shared origin; repeat with 640px arch period and y-local alignment; dry service language | Interior should read without outdoor skyline; no hazard/portal obstruction |
| SHAFT-RAIL-01 | 512×1024 RGBA panel | Rails repeat vertically at compatible edge; top-left pivot | 2160-high-room coverage without stretched circles/counterweights |
| COIL-BAY-01 | 640×720 RGBA chunk | Dark housing, muted coil rings, separate service light | Clear separation from Fire gate/vent cues; 2 variants reduce repetition |
| VILLAGE-HOME-01 | 512×512 RGBA chunk | Slate roof, warm plaster, timber, separate prop layer | Daylight mood approval and coherent character-scale reference |
| ROOT-ARCH-01 | 640×720 RGBA chunk | Stone backdrop and sparse root overlay | Canon selection; roots cannot cross active route lips |

These are **proposed targets**, chosen for reusable chunks against the inspected 1280×720 view and actual room dimensions, not an existing tile grid. No canonical 16/32/64-pixel tile system exists in the active world implementation. Draft SVGs are not final painted tilesets.
