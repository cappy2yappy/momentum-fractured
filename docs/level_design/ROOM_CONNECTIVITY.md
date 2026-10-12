**LD-01 / 2026-10-12. Status: design proposal pending creator approval.**

Baseline: `codex/kaze-boundary-sprite-integration` at `0bf37e19ef3498386b133ed5d41e32788c2609d6`. Static source audit; no new engine playthrough or measured MV-01 values claimed. Coordinates are world pixels, origin top-left, y increases down.

## Verified runtime graph

Solid ordinary edges are reciprocal E portals, not literal gaps between screens. Labels show forward requirements; ordinary reverse routes are open. Shortcut requirements apply in both directions. The map currently discovers index neighbors, not shortcut neighbors; drawing new connections must consume actual edge data.

```mermaid
flowchart TD
 R00["00 Canal Haven"] <--> R01["01 Lantern Market"]
 R01 <-->|"forward: Windstep"| R02["02 Flooded Cistern"]
 R02 <--> R03["03 Echo Shrine"]
 R03 <-->|"forward: Tether"| R04["04 Broken Span"]
 R04 <--> R05["05 Ascent Tower"]
 R05 <-->|"forward: Dash"| R06["06 Tide Warden"]
 R06 <-->|"forward: Warden defeated"| R07["07 Relay Archive"]
 R07 <-->|"forward: relay restored"| R08["08 Relay Undercroft"]
 R08 <--> R09["09 Signal Terrace"]
 R09 <-->|"forward: three sigils"| R10["10 SkyWorks Approach"]
 R10 <-->|"forward: Wind seal opened"| R11["11 Storm Foundry"]
 R11 <-->|"forward: Electric seal opened"| R12["12 Keeper Relay"]
 R03 <-->|"Electric return seal"| R09
 R08 <-->|"Keeper relay attuned"| R12
```

Source: world.gd interact/can_enter/request_room, route_extension.gd interact, skyworks_region.gd interact. R07 completion has an Electric physical seal but no flag guard at its console; this is a proposed fix, not an existing graph requirement. No existing direct fall transitions.

## Shortcut exact arrivals

| Edge | Departure | Destination landing | Requirement |
|---|---|---|---|
| R09  R03 | (160,620), radius 100 | (2100,788) | terrace_return_relay |
| R03  R09 | (2250,790), radius 100 | (480,618) | same |
| R08  R12 | (1470,740), radius 95 | (430,828) | skyworks_restored |
| R12  R08 | (220,830), radius 95 | (1590,738) | same |

R12 return landing is on R12 platform y=830, x=80..560. R08 landing is on y=740, x=1300..1640. These fit current static geometry; verify settling and collision live after any approved changes.

## Proposed expansion graph

All new edges below are proposals; 13 existing + 8 new = 21. IDs 13-20 are append-only suggestions, subject to integration ownership. Use reciprocal named arrivals, not target-ID comparisons for direction. Existing chain remains intact.

```mermaid
flowchart TD
 R00["R00 Haven"] <-->|"Windstep side route"| N13["13 Mooring Loft"]
 N13 <--> N14["14 Bellroof Walk"]
 N14 <--> R09["R09 Terrace"]
 N14 <--> N17["17 Counterweight Spire"]
 R05["R05 Tower"] <-->|"Dash + Tether"| N17
 N17 <-->|"Wind shutter"| N20["20 Relay Junction"]
 R02["R02 Cistern"] <-->|"Wind sluice"| N15["15 Lower Sluice"]
 N15 <--> N16["16 Root Shrine"]
 N16 <--> R08["R08 Undercroft"]
 N16 <--> N18["18 Pump Gallery"]
 R08 <--> N18
 N18 <-->|"Electric isolator"| N19["19 Coil Service Hall"]
 R11["R11 Foundry"] <--> N19
 N19 <-->|"Fire service seal"| N20
 N20 <-->|"junction switch opened from N20"| N13
```

New rooftop links to R09 require original relay completion at both entry approaches, preventing an early bypass of R07. Foundry link requires three sigils and skyworks_wind_intake even when arriving through N19. N18N19 also requires these flags, then Electric. N20N17 requires original relay completion plus its Wind seal. Shortcut N20N13 only becomes usable after those same story/sigil/Wind flags; no early surface route into later regions. Represent all gates by named flags, never a numeric fragment count that arbitrary future pickups could satisfy.

Provisional new map cells (layer 0): N13(-1,2), N14(-1,1), N15(2,3), N16(3,3), N17(4,2), N18(4,3), N19(5,3), N20(5,2). These cells are unoccupied, but shortcut lines are nonlocal and need explicit map edges/icons. They are not final geographic adjacency. Final placement is a map-authoring approval item.

