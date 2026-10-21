# LD-07 ground negative-space audit - 2026-10-21

This resumes draft PR #63, branch `feature/ld05-intentional-world-boundaries`, at `fa299cff0afe5172d5e37fad7d8378209425db56`. The inherited fixes are retained; LD-07 adds verification and dispositions rather than reimplementing them. All coordinates below are room-local pixels, y down, Kaze origin at feet (28 x 60 collision capsule).

## Baselines and scope

| Reference | Exact SHA | Use |
|---|---|---|
| PR #37 | b950373efb5c4621d7da7e0be1506db048e3043a | Bellroof service route and original-room preservation |
| PR #39 | 5dfc4c4f077c5408ecbe49f1cafafea1dcb1003c | Automatic passage and reciprocal arrival contract |
| PR #58 | 0656766d8fe13c702a4808b1d25ddd0855d8922c | Canal gatehouse contract, unchanged |
| PR #63 base | 49ae3efe21dea6a9eba556ce2fbc8299b00412b9 | Integration foundation of this branch |
| Pre-ground pass | 658ed34c2d182dd650c1d22b8fa6b3a6c43ca837 | R6 and water before/after reproduction |
| Recovered work | fa299cff0afe5172d5e37fad7d8378209425db56 | Existing runtime verified by this assignment |
| Latest Wave 3 candidate, PR #74 | c2c3d958abe8c1eb77e2851d29c00544bef63e80 | Read-only integration reference; not modified or tested as a combined candidate |

The active scene is `scenes/main.tscn` (CanalRoute), driven by `scripts/world.gd`. Rooms are built at runtime from `world.gd`, `world_expansion.gd`, `level_geometry.gd`, `bellroof_walk.gd` and `room_boundary.gd`; inspecting only the .tscn would miss their actual collision. `evidence/room_inventory.json` records 42 builds (all 21 rooms, both roof modes), actual RectangleShape2D/CollisionPolygon2D data, one-way flags, endpoints and anchors. `captures/rooms/` shows every actual room with a collision overlay. Cyan = solid, yellow = one-way, magenta = additional boundary shapes; red = endpoint.

No LD-07 runtime edit was necessary: the recovered ground repairs satisfy the targeted physical checks. Every runtime script, asset, scene, map, project setting and roof switch remains byte-identical to the recovered head. The old roof audit's word "fixed" means its comparison mode contains a roof; it does **not** signify creator approval. Roof-on and `--ld05-open-top` both remain available, unchanged. Open-top escapes remain pending the creator's design decision.

## Confirmed defects and coordinate-specific dispositions

| ID / severity | Location | Reproduction and actual behavior before repair | Expected behavior / minimum correction | Disposition and evidence |
|---|---|---|---|---|
| LD07-G1 / HIGH (GN-01) | R6 Tide Warden -> R7; endpoint (2440,1090), original shelf (2020,1110,580,40) | Start feet (2250,1108), hold D without jumping. Feet settle at y1110, outside trigger band y1000..1098; walking reaches x2586 without leaving. Reproduced on pinned 658ed34. | Walking on the exit support must enter the automatic passage. Existing visible sill polygon rises from (2390,1110), through (2412,1094), to (2440,1090), then continues to x2600. | Retained from 4c8ba17. 38/39 walking passages before; 39/39 after. Stop, reverse, walk, sprint and reciprocal arrival tested. One dash timing still misses arming, tracked separately below. [Before](captures/before-ground/R6_sill.png), [after](captures/after/R6_sill.png). |
| LD07-G2 / MED (GN-02) | R2 x640..930,1350..1680,2200..2380; R4 x450..1000,1280..2050; R5 x500..780,1500..1850; floor lip y1300 | Approach a pit on foot. Water formerly started at y1260 (crest about y1252), above the floor lip, visually suggesting a solid raised edge despite no support. | Keep the intentional pits and recovery; lower drawn water below the lip. Existing visual-only water rectangle starts at y1372 (crest about y1364). | Retained from 4c8ba17. Three actual pit falls verified to cost 1HP and recover onto ground; all seven floor gaps preserved. [R4 before](captures/before-ground/R4_pit.png), [after](captures/after/R4_pit.png). R2/R5 historical comparisons also remain in `../ld05/captures_ground/`. |
| LD07-G3 / MED | R8 Relay Undercroft -> R18 depth door at (1090,920); door span x1042..1138, old shelf ends x1110 | On pre-boundary 49ae3efe, stand near x1128 at y920 or land there: door art overhangs its landing by 28px. | Continue the landing's collision and visible material over its missing end. Existing separate solid Rect(1110,920,40,40) seats the full door without changing its endpoint or original shelf. | Retained. 96/96 door pixels supported; real drop onto (1130,920), stop/reverse across x1110 and jump/landing pass in both roof modes. [Before](captures/before-boundaries/R8_landing.png), [after](captures/after/R8_landing.png). |
| LD07-G4 / MED | R13 Mooring Loft / Canal-left quay, pocket x0..360,y1240..1300 | Walk left on the y1300 quay underneath the one-way hallway pad (top1200,bottom1240). A 60px nook exactly matches capsule height and permits unintended under-environment access. | Close only the under-pad pocket with matching visible solid Rect(0,1240,360,60). Retain pad top, gatehouse, mouth and doorway trigger. | Retained. Kaze stops at feet x374 on plinth face, can reverse and jump over it to the automatic exit. Uninterrupted Stride pickup -> shelf descent -> exit passes in both roof modes. [Before](captures/before-boundaries/R13_plinth.png), [after](captures/after/R13_plinth.png). |

The two earlier support repairs and the later ground pass were recovered, not discarded. Source fixes are already in PR #63. No player physics, automatic trigger logic, save schema, endpoint, art or narrative placement was edited by LD-07.

## Residuals, intended spaces and approval boundaries

| ID | Location / reproduction | Expected vs actual / severity | Disposition |
|---|---|---|---|
| GN-03 | Seven pit intervals in G2; walk off the y1300 lip | A miss loses 1HP and returns to the room's left-entry recovery pose. Pacing may be costly, especially R4's 770px second pit. | Intentional hazard, not a missing floor. No catch shelf or new route added; pacing change needs creator direction. |
| GN-04 | Bare catch floors: R9/R10/R13/R16/R20 at y1300, R17 at y2020 | Recoverable floors below retained vertical routes, rather than authored side routes. | Keep approved spaces. No evidence of a new floor hole; no redesign commissioned. |
| GN-05 | Ordinary wall-side thresholds, generally x120 or2440; 58/98px between drawn door edge and wall | Jumping/dashing over a door may leave a strip behind it; walking ordinarily transitions first. | Retain. Door-side piers would affect Transition choreography; route through PM before any change. Endpoint-specific coordinates are in each room below and the recovered `../ld05/ROOM_AUDIT.md`. |
| GN-06 / LOW, Transition handoff | R6 feet start (2300,1108); hold D, press Shift at tick8 for1tick | Expected automatic traversal; dash can skip the narrow sill/corridor arming window and stay in R6. Walk back inward, then approach again to recover. Reproduced: other dash starts2060,2200,2384 succeed,2300 misses. | **Unresolved; no waiver.** Trigger ownership is Transition. PM must coordinate the remedy and include it in the next combined candidate. No edit to #64 or its implementation. |
| GN-07 / LOW | R14 Rect(240,1200,240,40), overlapping Rect(200,1200,300,40) | Duplicate standing top, harmless overlap. | Keep LD-03 service-walk data. No confirmed gap or trap. |
| GN-08 / latent | R13 computed fall-recovery (230,1198); R17 (1790,1298) | Rectangle-based analyzer flags overlap with nearby ledge/wall. These rooms have continuous floors, so normal fall recovery is not reached from inside them. | Retain save/recovery implementation. Actual supported Canal save/respawn at (184,1198) tested. Do not generalize this result to arbitrary imported/out-of-bounds saves. |
| GN-09 / LOW | Water intervals in G2 | Flat water presentation has no splash animation. | Art polish outside this repair assignment. |
| LD07-TOP / creator decision | Open-top R13 upper shelves (e.g. starts(500,438),(541,458)); R17 upper shelf (e.g.(1425,418)) | Double-jump/dash can clear room sides at/above y0. Roof-off sweep recorded12 lateral exits (R13:8,R17:4). | **Open and explicitly unapproved.** Not repaired by selecting a roof. Existing roof-on/off comparison and collision are untouched. Broader recovered wall-chain escape evidence remains in `../ld05/raw/probe_open_top.json`. |
| LD07-ANALYZER / evidence limitation | R13 pier top (0,1020,72,180), footing top (0,1240,360,60), mass top y0 | Generic probes start on every rectangle, including buried/nonstandable tops. Analyzer flags the mass top as "trapped" because it skips starting outgoing probes at y<=8. | Not proof of an ordinary ground trap. The pier is inside the mass; the footing is covered by the pad; the mass top belongs to the open-top decision. Raw flags retained, not deleted. Targeted live-input plinth, landing and item-return tests cover the reachable ground case. |

Additional non-colliding scenery has its recovered dim/dashed presentation in R13/R14/R17 (trusses) and R15/R19 (arcs); it is not promoted to new collision. Background artwork is scenery, not a promise of standable surfaces.

## All 21 rooms

For each room, the full inventory includes every platform coordinate, actual collision rectangle/polygon, one-way status, gate, anchor and doorway. The table gives the ground span, endpoint coordinates and finite traversal-sample coverage. "No new confirmed ground defect" is limited to these probes and visual inspection, not an exhaustive human campaign certification.

### R0 CANAL HAVEN

Spawn at the Haven shrine (220,1300). East walk-through (2440,1300) to R1. Depth door (590,780) to R13 (needs Windstep).

- Ground: x0..2600 @y1300.
- Endpoints: R1 (2440,1300); R13 (590,780).
- Evidence: 348 roof-off movement samples; [actual room collision capture](captures/rooms/R00_overview.png).
- Disposition: No new confirmed ground defect in sampled traversal. Existing route and intentional vertical spaces retained.

### R1 LANTERN MARKET

West door back to R0. Windstep pickup (1580,1300) after the market guard. East walk-through (2440,1300) to R2 (needs Windstep).

- Ground: x0..2600 @y1300.
- Endpoints: R0 (120,1300); R2 (2440,1300).
- Evidence: 348 roof-off movement samples; [actual room collision capture](captures/rooms/R01_overview.png).
- Disposition: No new confirmed ground defect in sampled traversal. Existing route and intentional vertical spaces retained.

### R2 FLOODED CISTERN

West door to R1. Pit-and-ledge ascent east. Wind kunai gate (2150,850) opens the cistern cache. East walk-through (2440,850) to R3. Depth door (470,1120) to R15 (needs the cache and Wind kunai).

- Ground: x0..640 @y1300; x930..1350 @y1300; x1680..2200 @y1300; x2380..2600 @y1300.
- Endpoints: R1 (120,1300); R3 (2440,850); R15 (470,1120).
- Evidence: 360 roof-off movement samples; [actual room collision capture](captures/rooms/R02_overview.png).
- Disposition: G2 water readability repaired; the three listed pits remain intentional.

### R3 ECHO SHRINE

West door (120,850) to R2. Wind Tether pickup (1320,1300). East walk-through (2440,1300) to R4 (needs Tether). Depth door (2250,790) to R9 return seal.

- Ground: x0..2600 @y1300.
- Endpoints: R2 (120,850); R4 (2440,1300); R9 (2250,790).
- Evidence: 384 roof-off movement samples; [actual room collision capture](captures/rooms/R03_overview.png).
- Disposition: No new confirmed ground defect in sampled traversal. Existing route and intentional vertical spaces retained.

### R4 BROKEN SPAN

West door to R3. Fire kunai (1080,980). Span fire cache gate (1990,1080). East walk-through (2440,1080) to R5.

- Ground: x0..450 @y1300; x1000..1280 @y1300; x2050..2600 @y1300.
- Endpoints: R3 (120,1300); R5 (2440,1080).
- Evidence: 282 roof-off movement samples; [actual room collision capture](captures/rooms/R04_overview.png).
- Disposition: G2 water readability repaired; both listed pits remain intentional.

### R5 ASCENT TOWER

West door (120,1080). Gale Dash (1320,1300), Electric kunai (1510,930). East walk-through (2440,1300) to R6 (needs Dash). Depth door (2240,930) to R17 (needs Tether and Dash).

- Ground: x0..500 @y1300; x780..1500 @y1300; x1850..2600 @y1300.
- Endpoints: R4 (120,1080); R6 (2440,1300); R17 (2240,930).
- Evidence: 394 roof-off movement samples; [actual room collision capture](captures/rooms/R05_overview.png).
- Disposition: G2 water readability repaired; both listed pits remain intentional.

### R6 TIDE WARDEN

Boss arena. East walk-through (2440,1090) to R7 (needs the Tide Warden defeated).

- Ground: x0..2600 @y1300.
- Endpoints: R5 (120,1300); R7 (2440,1090).
- Evidence: 348 roof-off movement samples; [actual room collision capture](captures/rooms/R06_overview.png).
- Disposition: G1 sill retained; walking/sprint verified; GN-06 dash timing remains with PM/Transition.

### R7 RELAY ARCHIVE

Relay Archive: electric seal gate (2000,1300), control (2200,1190). East walk-through (2440,1300) to R8 (needs Archive restored).

- Ground: x0..2600 @y1300.
- Endpoints: R6 (120,1090); R8 (2440,1300).
- Evidence: 378 roof-off movement samples; [actual room collision capture](captures/rooms/R07_overview.png).
- Disposition: No new confirmed ground defect in sampled traversal. Existing route and intentional vertical spaces retained.

### R8 RELAY UNDERCROFT

Undercroft shrine (2060,1300), sigil (1470,690). West to R7, east (2440,830) to R9. Depth doors to R16 (550,1110), R18 (1090,920), R12 return (1470,740).

- Ground: x0..2600 @y1300.
- Endpoints: R7 (120,1090); R9 (2440,830); R16 (550,1110); R18 (1090,920); R12 (1470,740).
- Evidence: 480 roof-off movement samples; [actual room collision capture](captures/rooms/R08_overview.png).
- Disposition: G3 landing extension retained at (1110,920,40,40); depth door supported.

### R9 SIGNAL TERRACE

Three relay sigils: west (1490,600), fire cache (2240,770, behind gate 2110,810). East walk-through (2440,830) to R10 (needs all sigils). Depth doors to R14 (1100,1040) and R3 return (160,620).

- Ground: x0..2600 @y1300.
- Endpoints: R8 (120,830); R10 (2440,830); R14 (1100,1040); R3 (160,620).
- Evidence: 432 roof-off movement samples; [actual room collision capture](captures/rooms/R09_overview.png).
- Disposition: Door to R10 is drawn at shelf top y810 while logical endpoint remains(2440,830); trigger remains in range. Bare catch floor retained.

### R10 SKYWORKS APPROACH

Skyworks approach. Wind intake gate (2110,810) must be opened to enter R11. East walk-through (2440,760).

- Ground: x0..2600 @y1300.
- Endpoints: R9 (120,830); R11 (2440,760).
- Evidence: 442 roof-off movement samples; [actual room collision capture](captures/rooms/R10_overview.png).
- Disposition: No new confirmed ground defect in sampled traversal. Existing route and intentional vertical spaces retained.

### R11 STORM FOUNDRY

Foundry refuge (1720,1300). Electric relay gate (2370,760) must be opened to enter R12. Depth door (890,980) to R19.

- Ground: x0..2600 @y1300.
- Endpoints: R10 (120,760); R12 (2440,1300); R19 (890,980).
- Evidence: 434 roof-off movement samples; [actual room collision capture](captures/rooms/R11_overview.png).
- Disposition: No new confirmed ground defect in sampled traversal. Existing route and intentional vertical spaces retained.

### R12 KEEPER RELAY

Storm Keeper arena (boss 1320,1300), relay (2220,1300). Depth door (220,830) back to R8 after the Keeper.

- Ground: x0..2600 @y1300.
- Endpoints: R11 (120,1300); R8 (220,830).
- Evidence: 388 roof-off movement samples; [actual room collision capture](captures/rooms/R12_overview.png).
- Disposition: No new confirmed ground defect in sampled traversal. Existing route and intentional vertical spaces retained.

### R13 MOORING LOFT

Canal Haven door (120,1200) at the foot of the gatehouse hallway, stepped shelves climb right to the R14 walk-through (1680,560). Stride I (450,440), wind-fold door (900,400) to R20.

- Ground: x0..1800 @y1300.
- Endpoints: R0 (120,1200); R14 (1680,560); R20 (900,400).
- Evidence: 724 roof-off movement samples; [actual room collision capture](captures/rooms/R13_overview.png).
- Disposition: G4 plinth retained; Canal aperture(72,1068,96,132), threshold x120 and ceiling y1020 unchanged. Open-top escape/latent recovery/analyzer flags explicitly separated above.

### R14 BELLROOF WALK

Bellroof Walk: west door (120,1100) from R13, long roof walk east to R9 walk-through (2440,830). Local stair (1450,480) up to R17.

- Ground: x0..2600 @y1300.
- Endpoints: R13 (120,1100); R9 (2440,830); R17 (1450,480).
- Evidence: 1342 roof-off movement samples; [actual room collision capture](captures/rooms/R14_overview.png).
- Disposition: PR37 lower service walk and optional log placement retained; GN-07 duplicate top left intact.

### R15 LOWER SLUICE

Lower Sluice: from the R2 door (120,500) a dry descent east to the R16 walk-through (2080,1120). Optional wind gate (500,500).

- Ground: x0..2200 @y1300.
- Endpoints: R2 (120,500); R16 (2080,1120).
- Evidence: 524 roof-off movement samples; [actual room collision capture](captures/rooms/R15_overview.png).
- Disposition: No new confirmed ground defect in sampled traversal. Existing route and intentional vertical spaces retained.

### R16 ROOT SHRINE

Root Shrine (420,1120) save. West door R15, east (1880,760) to R8, depth door (1000,430) to R18.

- Ground: x0..2000 @y1300.
- Endpoints: R15 (120,1120); R8 (1880,760); R18 (1000,430).
- Evidence: 504 roof-off movement samples; [actual room collision capture](captures/rooms/R16_overview.png).
- Disposition: No new confirmed ground defect in sampled traversal. Existing route and intentional vertical spaces retained.

### R17 COUNTERWEIGHT SPIRE

Counterweight Spire: climb from the R5 door (120,1900) by landings to the top. Stair down (1680,1300) to R14, depth door (1500,420) to R20 behind the spire wind shutter.

- Ground: x0..1800 @y2020.
- Endpoints: R14 (1680,1300); R5 (120,1900); R20 (1500,420).
- Evidence: 754 roof-off movement samples; [actual room collision capture](captures/rooms/R17_overview.png).
- Disposition: Legitimate vertical spire route retained; open-top escape and latent recovery flag documented above.

### R18 PUMP GALLERY

Pump Gallery: from R16 door (120,1000) east along the pump walk to the R19 walk-through (2440,760) behind the electric isolator. Depth door (1200,1180) to R8.

- Ground: x0..2600 @y1300.
- Endpoints: R16 (120,1000); R8 (1200,1180); R19 (2440,760).
- Evidence: 812 roof-off movement samples; [actual room collision capture](captures/rooms/R18_overview.png).
- Disposition: No new confirmed ground defect in sampled traversal. Existing route and intentional vertical spaces retained.

### R19 COIL SERVICE HALL

Coil Service Hall: from R18 (120,760) across service bays; east walk-through (2280,980) to R11; depth door (1800,480) to R20 behind the coil fire gate.

- Ground: x0..2400 @y1300.
- Endpoints: R18 (120,760); R11 (2280,980); R20 (1800,480).
- Evidence: 982 roof-off movement samples; [actual room collision capture](captures/rooms/R19_overview.png).
- Disposition: No new confirmed ground defect in sampled traversal. Existing route and intentional vertical spaces retained.

### R20 RELAY JUNCTION

Relay Junction: from R17 (120,760) up to the wind-fold (600,520) to R13; east walk-through (2080,1120) to R19.

- Ground: x0..2200 @y1300.
- Endpoints: R17 (120,760); R19 (2080,1120); R13 (600,520).
- Evidence: 556 roof-off movement samples; [actual room collision capture](captures/rooms/R20_overview.png).
- Disposition: No new confirmed ground defect in sampled traversal. Existing route and intentional vertical spaces retained.

## Evidence limits

The roof-off sweep contains 11,216 samples over all 21 rooms. It is a finite bot with fixture starts and all traversal abilities available; it does not prove every jump timing, an unseeded campaign, physical gamepad operation or human design acceptance. The 12 above-top exits (10 with gates closed) are preserved evidence, not omitted failures. Fall samples are only in the seven intentional pit intervals; this statement does not erase the above-top exits. Four story-gated interact doors are locked in the fixture (R3<->R9,R8<->R12), so the door-walk inventory has 54 observed arrivals out of 58 endpoints; all 39 ordinary walk-through endpoints open.

The closed-gate pass repeats 11,216 movement samples across all 21 rooms with the existing Kunai gate flags cleared; gate bypassability is the inherited progression concern and no gate geometry was changed. See QA_REPORT.md for exact completed counts and limitations.

The latest combined Wave 3 runtime is not substituted for this PR's base: #63 does not contain #64's later hang fix. PM must test the combination after choosing integration, not treat this branch's tests as proof of the combined candidate.
