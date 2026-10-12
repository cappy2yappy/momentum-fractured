**LD-01 / 2026-10-12. Status: design proposal pending creator approval.**

Baseline: `codex/kaze-boundary-sprite-integration` at `0bf37e19ef3498386b133ed5d41e32788c2609d6`. Static source audit; no new engine playthrough or measured MV-01 values claimed. Coordinates are world pixels, origin top-left, y increases down.

## Source authority and provenance

Remote refs were inspected using git ls-remote and a full clone. `main` remains `1a33d283a3781ba7068f86b43d4197f28f063939`, an older foundation. Approved baseline branch tip is `7fd454a5f800da1fdf59fd0df84de23e79f6c455`; its descendant sprite integration is `8a25a9b`, then the required size restoration `0bf37e1`. Foundation `215e9bce3b234cb268e9426b52817f5ca844031e` is documented Alpha 0.5.2. AGENTS.md, CANONICAL_BASELINE.md, BASELINE_PROVENANCE.md, ALPHA_0_5_2_REVIEW.md, REPOSITORY_GUIDE.md and SPRITE_INTEGRATION_2026-10-12.md were reviewed. Project version is 0.5.2-dev; Godot target is 4.6.1.

Current approved branch has no current GDD, roadmap or parity matrix. Historical main GDD.md / DESIGN_UPDATE.md describe a six-biome 120-140-room plan with different unlocks; these are not Alpha 0.6 authority. Alternative branch `codex/web-parity-restoration` at `398c772` contains docs/DEVELOPMENT_ROADMAP.md, GAMEPLAY_PARITY_MATRIX.md and DOCUMENT_STATUS.md. Their authored five-room slice, water, controller and room-graph claims belong to that alternative foundation. Their design lessons inform this proposal; their implementation status does not apply here. This assignment and the approved baseline take precedence. Wider five-keeper campaign scope is not delivered merely by reaching 21 rooms.

## Verified structure

Exactly 13 runtime room IDs (0-12), four regions and 13 map cells. There are no individual active room scenes: `scenes/main.tscn` binds `scripts/world.gd`; IDs 0-7 are authored in build_room, 8-9 in route_extension.gd and 10-12 in skyworks_region.gd. Every room is 2600 x 1440; camera limits are fixed to this rectangle. World/map positions are symbolic cells, not contiguous pixel coordinates. Base walls are (-40,0,40,1440) and (2600,0,40,1440). Floors are y=1300, h=140, full width except IDs 2,4,5. No moving platforms or dedicated trap scripts are implemented. Existing water is drawn, without swimming or contact damage; falling beyond y=1510 costs one HP and rebuilds the room, returning to its left exit + (110,-2), or checkpoint on death. These are recovery teleports, not connected lower screens.

All backgrounds use assets/web/district-fidelity.png stretched across the same bounds plus room color tint. Terrain uses the same drawn rectangles. Environmental labels and colors differ, but architectural differentiation is limited. All ordinary enemies share guard.gd; enemy x pursuit clamps home �350 without collision/ledge probes, and y remains fixed. Upper platform guards can appear suspended off their platforms. Treat this as a source-supported risk, not a witnessed playtest failure.

### Exact per-room inventory

Rectangles below are `(x,y,width,height)`. Anchors are `(x,y)`. Ordinary exits are E interaction points within radius 105; source uses x=120 west and x=2440 east. No directional top/bottom transitions exist. Departures and arrivals differ: forward arrives west+(110,-2), backward east+(-140,-2), unless shortcut overrides.

#### R00 - CANAL HAVEN

- Builder: `scripts/world.gd:build_room`; scene `scenes/main.tscn`; bounds 2600 x 1440. Region CANAL WARD. Intended purpose (inferred): Safe introduction and canal landmark.
- West: none; east: R01 at (2440,1300). Additional links: none.
- Floor: (0,1300,2600,140). Platforms: (480, 1110, 300, 40); (860, 780, 420, 48); (260, 780, 390, 48); (1400, 1080, 300, 40); (1850, 900, 300, 40).
- Anchors: none. No structural anchor artwork/support metadata exists.
- Gates: none. See ABILITY_GATE_AUDIT.md for semantic versus physical protection.
- Enemies: None. Pacing: safe/exploration.
- Rewards/checkpoints: E shrine (220,1300), checkpoint (220,1298).
- Vertical route: elevated platform ladder/branches as listed; falls land on full lower floor; no lower-room fall connection. Moving platforms/traps: none.
- Deficiency: Use stone quay, mooring posts and distant sluice silhouettes. Mark upper ledge as an optional future return overlook. Keep the starting shrine lane safe. (proposed response to shared visual/route limitations). Empty upper space above highest geometry contains background/title rather than traversal. No additional hidden rewards found beyond those listed.

#### R01 - LANTERN MARKET

- Builder: `scripts/world.gd:build_room`; scene `scenes/main.tscn`; bounds 2600 x 1440. Region CANAL WARD. Intended purpose (inferred): First combat and Windstep claim.
- West: R00 at (120,1300); east: R02 at (2440,1300). Additional links: none.
- Floor: (0,1300,2600,140). Platforms: (370, 1120, 280, 40); (790, 950, 330, 40); (1450, 1080, 300, 40); (1800, 900, 270, 40); (2140, 720, 320, 40).
- Anchors: none. No structural anchor artwork/support metadata exists.
- Gates: none. See ABILITY_GATE_AUDIT.md for semantic versus physical protection.
- Enemies: Required guard (1100,1300); guards (520,1120),(1900,900), all suppressed after guard_defeated. Pacing: single archetype pressure; exact enjoyment/difficulty needs live testing.
- Rewards/checkpoints: Windstep + Wind Kunai near (1580,1260), requires guard defeat.
- Vertical route: elevated platform ladder/branches as listed; falls land on full lower floor; no lower-room fall connection. Moving platforms/traps: none.
- Deficiency: Differentiate awnings and lantern beams from platform lips; stage the required guard before reward visibility, with side guards on bounded balcony lanes. (proposed response to shared visual/route limitations). Empty upper space above highest geometry contains background/title rather than traversal. No additional hidden rewards found beyond those listed.

#### R02 - FLOODED CISTERN

- Builder: `scripts/world.gd:build_room`; scene `scenes/main.tscn`; bounds 2600 x 1440. Region CANAL WARD. Intended purpose (inferred): Water-gap traversal and hidden letter.
- West: R01 at (120,1300); east: R03 at (2440,850). Additional links: none.
- Floor: (0,1300,640,140); (930,1300,420,140); (1680,1300,520,140); (2380,1300,220,140). Platforms: (330, 1120, 260, 40); (710, 940, 280, 40); (1090, 1100, 300, 40); (1510, 870, 300, 40); (1980, 1050, 250, 40); (2220, 850, 260, 40).
- Anchors: none. No structural anchor artwork/support metadata exists.
- Gates: "cistern_wind_cache", "wind", Vector2(2150, 850), 250. See ABILITY_GATE_AUDIT.md for semantic versus physical protection.
- Enemies: Guard (1190,1100). Pacing: single archetype pressure; exact enjoyment/difficulty needs live testing.
- Rewards/checkpoints: Hidden letter at (2300,830), heals; collection lacks Wind gate check.
- Vertical route: elevated platform ladder/branches as listed; falls through floor gaps invoke HP-loss left-entry recovery. Moving platforms/traps: none.
- Deficiency: Use depth marks and spillway arches. Enclose Wind letter alcove with ceiling and side walls; check its gate flag at reward collection. (proposed response to shared visual/route limitations). Empty upper space above highest geometry contains background/title rather than traversal. No additional hidden rewards found beyond those listed.

#### R03 - ECHO SHRINE

- Builder: `scripts/world.gd:build_room`; scene `scenes/main.tscn`; bounds 2600 x 1440. Region ECHO WORKS. Intended purpose (inferred): Tether lesson, shrine and return hub.
- West: R02 at (120,850); east: R04 at (2440,1300). Additional links: R09 Electric return (2250,790).
- Floor: (0,1300,2600,140). Platforms: (0, 850, 300, 40); (420, 1060, 330, 40); (920, 830, 360, 40); (1480, 1030, 340, 40); (2000, 790, 340, 40).
- Anchors: (1090, 650); (2170, 610). No structural anchor artwork/support metadata exists.
- Gates: none. See ABILITY_GATE_AUDIT.md for semantic versus physical protection.
- Enemies: None. Pacing: safe/exploration.
- Rewards/checkpoints: Wind Tether near (1320,1260); E shrine (1320,1300).
- Vertical route: elevated platform ladder/branches as listed; falls land on full lower floor; no lower-room fall connection. Moving platforms/traps: none.
- Deficiency: Introduce a supported wind bell over the practice route and a quiet landing at the shrine. Explain held Q and airborne attachment. (proposed response to shared visual/route limitations). Empty upper space above highest geometry contains background/title rather than traversal. No additional hidden rewards found beyond those listed.

#### R04 - BROKEN SPAN

- Builder: `scripts/world.gd:build_room`; scene `scenes/main.tscn`; bounds 2600 x 1440. Region ECHO WORKS. Intended purpose (inferred): Swing crossing and Fire acquisition.
- West: R03 at (120,1300); east: R05 at (2440,1080). Additional links: none.
- Floor: (0,1300,450,140); (1000,1300,280,140); (2050,1300,550,140). Platforms: (300, 1110, 310, 40); (930, 1030, 270, 40); (1530, 890, 270, 40); (2130, 1080, 270, 40).
- Anchors: (780, 720); (1370, 610); (1940, 650). No structural anchor artwork/support metadata exists.
- Gates: "span_fire_cache", "fire", Vector2(1990, 1080), 270. See ABILITY_GATE_AUDIT.md for semantic versus physical protection.
- Enemies: Guards (1080,1030),(1660,890). Pacing: single archetype pressure; exact enjoyment/difficulty needs live testing.
- Rewards/checkpoints: Fire Kunai near (1080,990).
- Vertical route: elevated platform ladder/branches as listed; falls through floor gaps invoke HP-loss left-entry recovery. Moving platforms/traps: none.
- Deficiency: Use broken structural beams supporting rings; move pressure guards away from initial attachment and landing regions. (proposed response to shared visual/route limitations). Empty upper space above highest geometry contains background/title rather than traversal. No additional hidden rewards found beyond those listed.

#### R05 - ASCENT TOWER

- Builder: `scripts/world.gd:build_room`; scene `scenes/main.tscn`; bounds 2600 x 1440. Region ECHO WORKS. Intended purpose (inferred): Ascent, Gale Dash and Electric acquisition.
- West: R04 at (120,1080); east: R06 at (2440,1300). Additional links: none.
- Floor: (0,1300,500,140); (780,1300,720,140); (1850,1300,750,140). Platforms: (0, 1080, 280, 40); (300, 1110, 280, 40); (680, 900, 280, 40); (1030, 680, 280, 40); (1390, 930, 280, 40); (1760, 700, 280, 40); (2130, 930, 470, 40).
- Anchors: (820, 650); (1900, 520). No structural anchor artwork/support metadata exists.
- Gates: none. See ABILITY_GATE_AUDIT.md for semantic versus physical protection.
- Enemies: Guards (820,900),(1510,930). Pacing: single archetype pressure; exact enjoyment/difficulty needs live testing.
- Rewards/checkpoints: Gale Dash near (1320,1260); Electric near (1510,890).
- Vertical route: elevated platform ladder/branches as listed; falls through floor gaps invoke HP-loss left-entry recovery. Moving platforms/traps: none.
- Deficiency: Add stacked masonry windows, cable risers and floor numbers; provide readable rest landings before each anchor. (proposed response to shared visual/route limitations). Empty upper space above highest geometry contains background/title rather than traversal. No additional hidden rewards found beyond those listed.

#### R06 - TIDE WARDEN

- Builder: `scripts/world.gd:build_room`; scene `scenes/main.tscn`; bounds 2600 x 1440. Region STORM KEEP. Intended purpose (inferred): Tide Warden encounter.
- West: R05 at (120,1300); east: R07 at (2440,1090). Additional links: none.
- Floor: (0,1300,2600,140). Platforms: (300, 1110, 280, 40); (760, 1000, 310, 40); (1510, 1000, 310, 40); (2020, 1110, 580, 40).
- Anchors: none. No structural anchor artwork/support metadata exists.
- Gates: none. See ABILITY_GATE_AUDIT.md for semantic versus physical protection.
- Enemies: Tide Warden (1320,1300), absent after victory. Pacing: single archetype pressure; exact enjoyment/difficulty needs live testing.
- Rewards/checkpoints: Boss flag opens Archive.
- Vertical route: elevated platform ladder/branches as listed; falls land on full lower floor; no lower-room fall connection. Moving platforms/traps: none.
- Deficiency: Separate arena silhouette from decorative battlements; preserve readable attack floor and retreat space. (proposed response to shared visual/route limitations). Empty upper space above highest geometry contains background/title rather than traversal. No additional hidden rewards found beyond those listed.

#### R07 - RELAY ARCHIVE

- Builder: `scripts/world.gd:build_room`; scene `scenes/main.tscn`; bounds 2600 x 1440. Region STORM KEEP. Intended purpose (inferred): Relay restoration and annex threshold.
- West: R06 at (120,1090); east: R08 at (2440,1300). Additional links: none.
- Floor: (0,1300,2600,140). Platforms: (0, 1090, 300, 40); (390, 1090, 300, 40); (820, 870, 340, 40); (1300, 650, 380, 40); (1830, 880, 320, 40).
- Anchors: (990, 650); (1480, 430). No structural anchor artwork/support metadata exists.
- Gates: "relay_electric_seal", "electric", Vector2(2000, 1300), 300. See ABILITY_GATE_AUDIT.md for semantic versus physical protection.
- Enemies: None. Pacing: safe/exploration.
- Rewards/checkpoints: E relay at (2200,1300), checkpoint (2200,1298); interaction lacks Electric seal check.
- Vertical route: elevated platform ladder/branches as listed; falls land on full lower floor; no lower-room fall connection. Moving platforms/traps: none.
- Deficiency: Make relay console, closed Electric seal and cable routing visibly causal. (proposed response to shared visual/route limitations). Empty upper space above highest geometry contains background/title rather than traversal. No additional hidden rewards found beyond those listed.

#### R08 - RELAY UNDERCROFT

- Builder: `scripts/route_extension.gd:build_room`; scene `scenes/main.tscn`; bounds 2600 x 1440. Region ECHO WORKS. Intended purpose (inferred): Sigil exploration and checkpoint.
- West: R07 at (120,1090); east: R09 at (2440,830). Additional links: R12 attuned return (1470,740).
- Floor: (0,1300,2600,140). Platforms: .
- Anchors: (750,660); (1220,500); (1800,570); (2250,530). No structural anchor artwork/support metadata exists.
- Gates: none. See ABILITY_GATE_AUDIT.md for semantic versus physical protection.
- Enemies: Persistent intake_sentinel (1810,1300). Pacing: single archetype pressure; exact enjoyment/difficulty needs live testing.
- Rewards/checkpoints: Sigil (1470,690); E shrine (2060,1300), checkpoint (2060,1298).
- Vertical route: elevated platform ladder/branches as listed; falls land on full lower floor; no lower-room fall connection. Moving platforms/traps: none.
- Deficiency: Use pipes, repair markings and shrine niche; keep sentinel on the wide lower floor. (proposed response to shared visual/route limitations). Empty upper space above highest geometry contains background/title rather than traversal. No additional hidden rewards found beyond those listed.

#### R09 - SIGNAL TERRACE

- Builder: `scripts/route_extension.gd:build_room`; scene `scenes/main.tscn`; bounds 2600 x 1440. Region STORM KEEP. Intended purpose (inferred): Two-sigil terrace and Electric return.
- West: R08 at (120,830); east: R10 at (2440,830). Additional links: R03 Electric return (160,620).
- Floor: (0,1300,2600,140). Platforms: .
- Anchors: (670,480); (1250,400); (1850,430). No structural anchor artwork/support metadata exists.
- Gates: "terrace_fire_cache", "fire", Vector2(2110, 810), 280; RETURN_GATE, "electric", Vector2(360, 620), 280. See ABILITY_GATE_AUDIT.md for semantic versus physical protection.
- Enemies: Persistent terrace_sentinel (800,1040). Pacing: single archetype pressure; exact enjoyment/difficulty needs live testing.
- Rewards/checkpoints: Sigils (1490,600),(2240,770); second requires terrace_fire_cache flag.
- Vertical route: elevated platform ladder/branches as listed; falls land on full lower floor; no lower-room fall connection. Moving platforms/traps: none.
- Deficiency: Use antenna silhouettes and wind-facing cloth, with railings visibly decorative where appropriate. (proposed response to shared visual/route limitations). Empty upper space above highest geometry contains background/title rather than traversal. No additional hidden rewards found beyond those listed.

#### R10 - SKYWORKS APPROACH

- Builder: `scripts/skyworks_region.gd:build_room`; scene `scenes/main.tscn`; bounds 2600 x 1440. Region SKYWORKS. Intended purpose (inferred): Wind intake traversal.
- West: R09 at (120,830); east: R11 at (2440,760). Additional links: none.
- Floor: (0,1300,2600,140). Platforms: (0, 830, 300, 40); (350, 1040, 800, 40); (920, 830, 300, 40); (1400, 620, 360, 40); (1780, 810, 360, 40); (2240, 760, 360, 40).
- Anchors: (620, 560); (1220, 460); (1880, 480); (2320, 420). No structural anchor artwork/support metadata exists.
- Gates: "skyworks_wind_intake", "wind", Vector2(2110, 810), 280. See ABILITY_GATE_AUDIT.md for semantic versus physical protection.
- Enemies: Persistent skyworks_sentinel (800,1040). Pacing: single archetype pressure; exact enjoyment/difficulty needs live testing.
- Rewards/checkpoints: Wind seal controls outgoing transition.
- Vertical route: elevated platform ladder/branches as listed; falls land on full lower floor; no lower-room fall connection. Moving platforms/traps: none.
- Deficiency: Introduce turbine housings and distinct intake shutters; wind seal operates machinery visibly. (proposed response to shared visual/route limitations). Empty upper space above highest geometry contains background/title rather than traversal. No additional hidden rewards found beyond those listed.

#### R11 - STORM FOUNDRY

- Builder: `scripts/skyworks_region.gd:build_room`; scene `scenes/main.tscn`; bounds 2600 x 1440. Region SKYWORKS. Intended purpose (inferred): Electric relay and pre-boss refuge.
- West: R10 at (120,760); east: R12 at (2440,1300). Additional links: none.
- Floor: (0,1300,2600,140). Platforms: (0, 760, 310, 40); (420, 980, 600, 40); (1100, 780, 380, 40); (1500, 560, 400, 40); (2010, 760, 590, 40); (920, 560, 240, 40).
- Anchors: (700, 560); (1300, 460); (1940, 460). No structural anchor artwork/support metadata exists.
- Gates: "foundry_electric_relay", "electric", Vector2(2370, 760), 300. See ABILITY_GATE_AUDIT.md for semantic versus physical protection.
- Enemies: Persistent foundry_sentinel (1100,1300). Pacing: single archetype pressure; exact enjoyment/difficulty needs live testing.
- Rewards/checkpoints: E refuge (1720,1300), checkpoint (1720,1298).
- Vertical route: elevated platform ladder/branches as listed; falls land on full lower floor; no lower-room fall connection. Moving platforms/traps: none.
- Deficiency: Use dormant coils, insulated masonry and refuge shield canopy; isolate safe shrine from enemy lane. (proposed response to shared visual/route limitations). Empty upper space above highest geometry contains background/title rather than traversal. No additional hidden rewards found beyond those listed.

#### R12 - KEEPER RELAY

- Builder: `scripts/skyworks_region.gd:build_room`; scene `scenes/main.tscn`; bounds 2600 x 1440. Region SKYWORKS. Intended purpose (inferred): Storm Keeper and final attunement.
- West: R11 at (120,1300); east: none. Additional links: R08 attuned return (220,830).
- Floor: (0,1300,2600,140). Platforms: (80, 830, 480, 40); (580, 1070, 320, 40); (1040, 850, 350, 40); (1700, 1030, 340, 40); (2180, 880, 300, 40).
- Anchors: (760, 790); (1230, 590); (1870, 730). No structural anchor artwork/support metadata exists.
- Gates: none. See ABILITY_GATE_AUDIT.md for semantic versus physical protection.
- Enemies: Persistent Storm Keeper (1320,1300). Pacing: single archetype pressure; exact enjoyment/difficulty needs live testing.
- Rewards/checkpoints: E attunement (2220,1300), requires keeper defeat; checkpoint (2220,1298).
- Vertical route: elevated platform ladder/branches as listed; falls land on full lower floor; no lower-room fall connection. Moving platforms/traps: none.
- Deficiency: Use central relay mast and noninteractive cable crown; preserve unobstructed pulse floor. (proposed response to shared visual/route limitations). Empty upper space above highest geometry contains background/title rather than traversal. No additional hidden rewards found beyond those listed.

## Audit limits and acceptance evidence

Existing tests reviewed: approved_baseline, annex_expansion, annex_traversal, skyworks_progression, save_compatibility and sprite integration documentation. Historical seven-suite results are recorded in the baseline review; LD-01 does not claim rerunning them. annex_traversal proves six selected platform jumps in its recorded run, not every anchor route or gate bypass. Static geometry predicts risks; runtime exploit demonstrations remain QA work. No current MV-01 response is present in this checkout. No active scenes, collision or gameplay scripts changed by this assignment.

