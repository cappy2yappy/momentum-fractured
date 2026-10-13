# Kaze Alpha 0.6 — LD-01 completion report for project management

**Date:** October 12, 2026  
**Owner:** LD-01 — Level Design / World Architecture  
**Status:** Audit and design deliverables complete; design approval pending. No level implementation performed.  
**Milestone:** Alpha 0.6 — World Expansion & Momentum

## Executive assessment

LD-01 verified the approved restored-size Alpha 0.5.2 foundation, audited all 13 runtime rooms, documented their connectivity and progression, and published an eight-room expansion proposal targeting 21 connected rooms. The proposal adds rooftop and underground loops, a fifth-region concept, meaningful backtracking, supported grapple objects and optional momentum routes.

This completes the initial LD-01 assignment. It does not complete playable Alpha 0.6. New rooms, gate fixes, hazards, speed progression and anchor artwork remain unimplemented. The shared movement contract is an LD proposal, not an approved MV-01 specification.

## Verified source and publication

| Item | Verified identity |
|---|---|
| Repository | https://github.com/cappy2yappy/momentum-fractured |
| Approved gameplay foundation | `215e9bce3b234cb268e9426b52817f5ca844031e` — Alpha 0.5.2 |
| Starting branch | `codex/kaze-boundary-sprite-integration` |
| Starting commit | `0bf37e19ef3498386b133ed5d41e32788c2609d6` — restored-size character integration |
| Design branch | `design/alpha-0.6-world-expansion` |
| Published design commit | `1ba5bdd4cd8bfb0e000a11492d9e6269ab480ab2` |
| Engine / active entry | Godot 4.6.1 / root `project.godot`, `scenes/main.tscn` |
| Baseline verification | `python tools/verify_baseline.py`: zero failures |

[Review the design documents](https://github.com/cappy2yappy/momentum-fractured/tree/design/alpha-0.6-world-expansion/docs/level_design). The published design commit above precedes this report's own publication.

The selected source descends from the approved gameplay foundation and contains the required sprite-size restoration. Outdated `main` was not used as the starting point. Repository guidance, baseline provenance/review and sprite integration documentation were inspected. Historical GDD/roadmap/parity documents were examined on other branches and explicitly separated from current implementation claims. Current approved source has no current GDD/roadmap/parity matrix; PM should reconcile these documents during milestone planning.

## Deliverables completed

| File | Review purpose |
|---|---|
| [ALPHA_0_6_WORLD_AUDIT.md](ALPHA_0_6_WORLD_AUDIT.md) | Baseline evidence and all 13 rooms: dimensions, geometry, anchors, enemies, rewards and routes |
| [ROOM_CONNECTIVITY.md](ROOM_CONNECTIVITY.md) | Verified Mermaid world graph, exact shortcut arrivals and proposed expansion network |
| [EXISTING_ROOM_IMPROVEMENTS.md](EXISTING_ROOM_IMPROVEMENTS.md) | Room-specific visual, traversal, encounter and progression improvements |
| [EIGHT_ROOM_EXPANSION.md](EIGHT_ROOM_EXPANSION.md) | Eight room specifications with platform diagrams, dimensions, portals, anchors, hazards, rewards and dependencies |
| [GRAPPLE_ANCHOR_DESIGN.md](GRAPPLE_ANCHOR_DESIGN.md) | Existing anchor-section audit, support concepts, clearance risks and recovery intent |
| [ABILITY_GATE_AUDIT.md](ABILITY_GATE_AUDIT.md) | Physical versus semantic gate protection, vulnerabilities and QA matrix |
| [LEVEL_IMPLEMENTATION_BACKLOG.md](LEVEL_IMPLEMENTATION_BACKLOG.md) | Priorities, implementation owners, dependencies and measurable acceptance |
| [SHARED_MOVEMENT_CONTRACT.md](../alpha_0_6/SHARED_MOVEMENT_CONTRACT.md) | Baseline mechanics and outstanding MV-01 questions; explicitly unapproved proposal |

## Existing world findings

Source confirms 13 rooms across Canal Ward, Echo Works, Storm Keep and SkyWorks. Rooms are constructed dynamically in `world.gd`, `route_extension.gd` and `skyworks_region.gd`; there are no separate active room scenes. All current bounds are 2600 × 1440.

The main reciprocal chain is Canal Haven → Lantern Market → Flooded Cistern → Echo Shrine → Broken Span → Ascent Tower → Tide Warden → Relay Archive → Relay Undercroft → Signal Terrace → SkyWorks Approach → Storm Foundry → Keeper Relay. Forward edges enforce movement/story requirements at designated points. Two reciprocal shortcuts connect Echo Shrine–Signal Terrace and Relay Undercroft–Keeper Relay, subject to their unlock flags. The full graph is in ROOM_CONNECTIVITY.md.

| Finding | Evidence and impact | Proposed response |
|---|---|---|
| Limited branching | Main world is a chain plus two shortcuts | Add interconnected roof/underground loops while retaining original chain |
| Repeated environments | One stretched background and common drawn terrain treatment | Room-specific architecture, layers and landmarks |
| Water/fall gap | Water is drawn; falling beyond y1510 costs HP and returns to an entrance | Dry lower recovery routes in new designs; swimming is separate future work |
| Grapple feedback mismatch | Visual proximity uses <520 from player position; actual eligibility is 80–400 from tether origin with direction/height constraints | MV-01 to reconcile feedback with valid attachment and measure longer reach |
| Rope obstruction uncertainty | Approved controller has no explicit rope LOS check; player collision releases tether | MV-01 decision and measured swept-clearance tests before layout implementation |
| Enemy lane risk | Guards clamp x to home ±350 without platform collision/ledge probes | Developer/combat ownership must bound lanes before placing guards near edges |
| Sparse upper-space purpose | Similar elevated platforms with much upper background-only space | Rest landings, routes and landmarks; prototype genuine multi-screen climb |

## Ability-gate findings and proposed remedies

1. **Cistern Wind cache:** letter collection does not check `cistern_wind_cache`. A short freestanding wall presents a geometric bypass risk. Add enclosed cache geometry and a collection flag guard.
2. **Archive Electric seal:** relay console sets completion without checking `relay_electric_seal`. Guard activation with the seal flag and make machinery/door causality visible.
3. **Broken Span Fire cache:** physical seal exists, but no bound reward was found. Define a meaningful optional reward or route before implementing geometry changes.
4. **Later progression protection:** terrace Fire fragment, Electric shortcut, SkyWorks Wind transition, Foundry Electric transition and Keeper attunement already use flag checks. Preserve these on every new alternate approach.
5. **Future sigil counting:** existing SkyWorks access checks a fragment count. Expansion should check the three named required sigils so unrelated new pickups cannot open it accidentally.

These are static source findings and conceptual bypass risks. No new live exploit demonstration was performed. QA cases cover normal/double/wall jumps, dash, grapple, all permanent tiers, maximum momentum, alternate arrivals, wrong/correct elements and persistence. Never remove movement abilities to conceal a gate defect.

## Eight-room expansion proposal

| ID | Room | Distinct experience / connection intent |
|---|---|---|
| 13 | Mooring Loft | Optional Haven overlook and surface return destination |
| 14 | Bellroof Walk | Roof loop to Signal Terrace; ordinary stairs and optional bell-swing lane |
| 15 | Lower Sluice | Dry subterranean maintenance descent from Cistern; flooded visual context |
| 16 | Root Shrine | Overgrown checkpoint and underground exploration junction |
| 17 | Counterweight Spire | Multi-screen vertical route joining Tower, roofs and upper junction |
| 18 | Pump Gallery | Root-reclaimed machinery loop and Electric-gated service connection |
| 19 | Coil Service Hall | Industrial alternate route with explicit regional and elemental locks |
| 20 | Relay Junction | Upper/lower loop closure and persistent shortcut back toward Haven |

Root Conservatory is a proposed fifth region. Proposed IDs and map cells need integration confirmation. Dimensions and anchor coordinates are preliminary blockout values, not measured movement guarantees. Explicit edge prerequisites prevent new links from skipping relay completion, named sigils, Wind intake or boss/attunement requirements.

Ordinary routes require no temporary momentum bonus or optional speed upgrade. Mastery routes offer quicker traversal and optional rewards, with recovery to the ordinary route. This proposal does not add bosses or deliver the wider five-keeper campaign.

## Grapple-object direction

Use suspended wind bells on roof/shrine beams, tether rings on ruins or industrial brackets, and ancient wind relics in special shrine challenges. All share a stable attachment core and recognizable pale-green ring/contrast language. Decorative sway must not move the mechanical point. Support artwork must remain separate from collision and outside tested rope/player trajectories.

Existing section specifications identify anchor coordinates, approaches, likely platform interference, intended landings and recovery. Final attachment distances and momentum thresholds remain pending MV-01.

## Coordination requests for MV-01

PM should provide MV-01 the design branch and shared contract and request:

- Baseline and maximum combined movement traces: jump/wall/double-jump, dash, braking, swing release and collider clearance.
- Recommended longer grapple reach, minimum distance, target selection, obstruction rules and truthful eligibility feedback.
- Permanent speed tiers, temporary momentum earn/decay/caps, reset rules and transition behavior.
- Safe landing widths, stopping margins and anchor spacing at each supported configuration.
- Ownership for upgrade IDs, persistence and save migration.

LD-01 did not contact, spawn or approve MV-01. No MV-01 measurements were received during this assignment. PM must reconcile the independently produced contracts before integration.

## Verification and boundaries

- Baseline asset/preservation verification passed with zero failures.
- Published files were fetched back and compared with the local design tree; contents matched.
- Design changes were confined to documentation; player, combat, save, active scene, world geometry and artwork files remained unchanged.
- Existing regression tests were inspected; historical recorded passes were not presented as newly rerun results.
- No new engine playthrough, performance measurement or full unseeded completion was performed.
- No merge into `main`, force push or overwrite of another agent branch occurred.
- Shell push initially failed because its authentication helper could not launch; publication succeeded through connected GitHub access. No publication blocker remains.

## PM decisions and implementation sequence

1. Review and approve the room network, fifth-region concept, dry underground scope and anchor-object direction.
2. Reconcile MV-01 measurements and contract; approve any movement changes separately.
3. Assign bounded fixes for the Cistern collection and Archive activation checks.
4. Establish named graph edges, reciprocal arrivals, map updates and compatible progression persistence.
5. Implement roof loop N13–N14, then underground loop N15–N16, then vertical N17.
6. Implement machinery loop N18–N19 and junction N20 with protected regional entries.
7. Add approved environmental artwork, lane-safe encounters, warned hazards and optional speed rewards.
8. Run complete gate/transition/save/recovery tests and an unseeded 21-room playthrough; measure the 60 FPS requirement on agreed hardware.

**Checkpoint:** LD-01 has stopped at the requested design approval stage. No major level changes should begin based solely on this report. Mark the audit/design task complete and playable-world implementation pending; do not mark Alpha 0.6 complete or shared movement values approved.
