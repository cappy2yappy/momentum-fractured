**LD-01 / 2026-10-12. Status: design proposal pending creator approval.**

Baseline: `codex/kaze-boundary-sprite-integration` at `0bf37e19ef3498386b133ed5d41e32788c2609d6`. Static source audit; no new engine playthrough or measured MV-01 values claimed. Coordinates are world pixels, origin top-left, y increases down.

## Implementation constraints

Initial pass changes documents only. Preserve approved original eight-room geometry byte for byte until the creator approves a bounded geometry revision. Cosmetic work uses independent background/foreground layers without physics bodies; all platforms, gates and hazards get separate interactive objects and readable edges. Foreground opacity must not conceal Kaze, enemy warnings, anchors or exits. Keep active character sheets and pivots intact.

For every approved room pass: load both entrances, verify arrivals settle on solid ground, traverse at baseline and maximum MV-01 configurations, check secrets/gates, then compare checkpoint/transition/map behavior. Do not use greater enemy counts as a substitute for layout quality. Future ranged/armored roles depend on combat ownership; use existing guards until approved.

## R00 CANAL HAVEN - Canal mooring haven

**Visual/geometry intent:** Use stone quay, mooring posts and distant sluice silhouettes. Mark upper ledge as an optional future return overlook. Keep the starting shrine lane safe.

**Route/reward intent:** Add a signed optional link to N13 after Windstep; do not move the approved platforms.

**Developer specification:** retain current exits and pickups at audited coordinates; stage any new branch on a separate stable landing. Add environmental support to each anchor without adding collision inside its swing volume. Keep this room free of compulsory encounters.

**Acceptance:** room identity is distinguishable without its title; both original transitions and rewards remain usable with the original kit; all new locked rewards reject collection before their flag; player can reach a safe recovery landing after missing each new swing. New route is visible on mini-map/full map with its lock state.

## R01 LANTERN MARKET - Abandoned market balconies

**Visual/geometry intent:** Differentiate awnings and lantern beams from platform lips; stage the required guard before reward visibility, with side guards on bounded balcony lanes.

**Route/reward intent:** Reserve a noninteractive upper sign pointing to N14; remove ambiguity when all guards vanish after the required guard flag.

**Developer specification:** retain current exits and pickups at audited coordinates; stage any new branch on a separate stable landing. Add environmental support to each anchor without adding collision inside its swing volume. Require bounded enemy territory or developer-approved lane implementation before moving guards toward platform ends. Keep arrival and first landing outside enemy attack ranges.

**Acceptance:** room identity is distinguishable without its title; both original transitions and rewards remain usable with the original kit; all new locked rewards reject collection before their flag; player can reach a safe recovery landing after missing each new swing. New route is visible on mini-map/full map with its lock state.

## R02 FLOODED CISTERN - Sluice reservoir

**Visual/geometry intent:** Use depth marks and spillway arches. Enclose Wind letter alcove with ceiling and side walls; check its gate flag at reward collection.

**Route/reward intent:** Propose lower N15 transition on solid ledge, never inside the existing fall plane.

**Developer specification:** retain current exits and pickups at audited coordinates; stage any new branch on a separate stable landing. Add environmental support to each anchor without adding collision inside its swing volume. Require bounded enemy territory or developer-approved lane implementation before moving guards toward platform ends. Keep arrival and first landing outside enemy attack ranges.

**Acceptance:** room identity is distinguishable without its title; both original transitions and rewards remain usable with the original kit; all new locked rewards reject collection before their flag; player can reach a safe recovery landing after missing each new swing. New route is visible on mini-map/full map with its lock state.

## R03 ECHO SHRINE - Tether reliquary

**Visual/geometry intent:** Introduce a supported wind bell over the practice route and a quiet landing at the shrine. Explain held Q and airborne attachment.

**Route/reward intent:** Keep the Electric return visually distinct from ordinary exits; upper ring lane can later connect N16.

**Developer specification:** retain current exits and pickups at audited coordinates; stage any new branch on a separate stable landing. Add environmental support to each anchor without adding collision inside its swing volume. Keep this room free of compulsory encounters.

**Acceptance:** room identity is distinguishable without its title; both original transitions and rewards remain usable with the original kit; all new locked rewards reject collection before their flag; player can reach a safe recovery landing after missing each new swing. New route is visible on mini-map/full map with its lock state.

## R04 BROKEN SPAN - Collapsed aqueduct

**Visual/geometry intent:** Use broken structural beams supporting rings; move pressure guards away from initial attachment and landing regions.

**Route/reward intent:** Seal Fire cache as a genuine alcove; keep the main crossing recoverable on a lower ledge after approval.

**Developer specification:** retain current exits and pickups at audited coordinates; stage any new branch on a separate stable landing. Add environmental support to each anchor without adding collision inside its swing volume. Require bounded enemy territory or developer-approved lane implementation before moving guards toward platform ends. Keep arrival and first landing outside enemy attack ranges.

**Acceptance:** room identity is distinguishable without its title; both original transitions and rewards remain usable with the original kit; all new locked rewards reject collection before their flag; player can reach a safe recovery landing after missing each new swing. New route is visible on mini-map/full map with its lock state.

## R05 ASCENT TOWER - Relay tower interior

**Visual/geometry intent:** Add stacked masonry windows, cable risers and floor numbers; provide readable rest landings before each anchor.

**Route/reward intent:** Connect N17 from an upper landing; no mandatory speed requirement or change to original ascent geometry yet.

**Developer specification:** retain current exits and pickups at audited coordinates; stage any new branch on a separate stable landing. Add environmental support to each anchor without adding collision inside its swing volume. Require bounded enemy territory or developer-approved lane implementation before moving guards toward platform ends. Keep arrival and first landing outside enemy attack ranges.

**Acceptance:** room identity is distinguishable without its title; both original transitions and rewards remain usable with the original kit; all new locked rewards reject collection before their flag; player can reach a safe recovery landing after missing each new swing. New route is visible on mini-map/full map with its lock state.

## R06 TIDE WARDEN - Warden forecourt

**Visual/geometry intent:** Separate arena silhouette from decorative battlements; preserve readable attack floor and retreat space.

**Route/reward intent:** No new compulsory route through the boss arena; scenery pass before encounter rebalance.

**Developer specification:** retain current exits and pickups at audited coordinates; stage any new branch on a separate stable landing. Add environmental support to each anchor without adding collision inside its swing volume. Require bounded enemy territory or developer-approved lane implementation before moving guards toward platform ends. Keep arrival and first landing outside enemy attack ranges.

**Acceptance:** room identity is distinguishable without its title; both original transitions and rewards remain usable with the original kit; all new locked rewards reject collection before their flag; player can reach a safe recovery landing after missing each new swing. New route is visible on mini-map/full map with its lock state.

## R07 RELAY ARCHIVE - Archive machinery hall

**Visual/geometry intent:** Make relay console, closed Electric seal and cable routing visibly causal.

**Route/reward intent:** Require relay_electric_seal before console activation; show locked state consistently on map and objective.

**Developer specification:** retain current exits and pickups at audited coordinates; stage any new branch on a separate stable landing. Add environmental support to each anchor without adding collision inside its swing volume. Keep this room free of compulsory encounters.

**Acceptance:** room identity is distinguishable without its title; both original transitions and rewards remain usable with the original kit; all new locked rewards reject collection before their flag; player can reach a safe recovery landing after missing each new swing. New route is visible on mini-map/full map with its lock state.

## R08 RELAY UNDERCROFT - Maintenance undercroft

**Visual/geometry intent:** Use pipes, repair markings and shrine niche; keep sentinel on the wide lower floor.

**Route/reward intent:** Add N16 garden descent link and N18 intake link; identify both existing return destinations on map.

**Developer specification:** retain current exits and pickups at audited coordinates; stage any new branch on a separate stable landing. Add environmental support to each anchor without adding collision inside its swing volume. Require bounded enemy territory or developer-approved lane implementation before moving guards toward platform ends. Keep arrival and first landing outside enemy attack ranges.

**Acceptance:** room identity is distinguishable without its title; both original transitions and rewards remain usable with the original kit; all new locked rewards reject collection before their flag; player can reach a safe recovery landing after missing each new swing. New route is visible on mini-map/full map with its lock state.

## R09 SIGNAL TERRACE - Signal roof terrace

**Visual/geometry intent:** Use antenna silhouettes and wind-facing cloth, with railings visibly decorative where appropriate.

**Route/reward intent:** Connect N14/N17 roof loop; Fire sigil remains flag guarded; place return indicator outside confusing upper beam overlap.

**Developer specification:** retain current exits and pickups at audited coordinates; stage any new branch on a separate stable landing. Add environmental support to each anchor without adding collision inside its swing volume. Require bounded enemy territory or developer-approved lane implementation before moving guards toward platform ends. Keep arrival and first landing outside enemy attack ranges.

**Acceptance:** room identity is distinguishable without its title; both original transitions and rewards remain usable with the original kit; all new locked rewards reject collection before their flag; player can reach a safe recovery landing after missing each new swing. New route is visible on mini-map/full map with its lock state.

## R10 SKYWORKS APPROACH - SkyWorks intake bridge

**Visual/geometry intent:** Introduce turbine housings and distinct intake shutters; wind seal operates machinery visibly.

**Route/reward intent:** Upper swing route rewards momentum while a stepped route reaches the same gate; no bonus-dependent main line.

**Developer specification:** retain current exits and pickups at audited coordinates; stage any new branch on a separate stable landing. Add environmental support to each anchor without adding collision inside its swing volume. Require bounded enemy territory or developer-approved lane implementation before moving guards toward platform ends. Keep arrival and first landing outside enemy attack ranges.

**Acceptance:** room identity is distinguishable without its title; both original transitions and rewards remain usable with the original kit; all new locked rewards reject collection before their flag; player can reach a safe recovery landing after missing each new swing. New route is visible on mini-map/full map with its lock state.

## R11 STORM FOUNDRY - Powered foundry refuge

**Visual/geometry intent:** Use dormant coils, insulated masonry and refuge shield canopy; isolate safe shrine from enemy lane.

**Route/reward intent:** Connect N19 from side service landing; hazards need warning plus safe wait bays; preserve refuge location.

**Developer specification:** retain current exits and pickups at audited coordinates; stage any new branch on a separate stable landing. Add environmental support to each anchor without adding collision inside its swing volume. Require bounded enemy territory or developer-approved lane implementation before moving guards toward platform ends. Keep arrival and first landing outside enemy attack ranges.

**Acceptance:** room identity is distinguishable without its title; both original transitions and rewards remain usable with the original kit; all new locked rewards reject collection before their flag; player can reach a safe recovery landing after missing each new swing. New route is visible on mini-map/full map with its lock state.

## R12 KEEPER RELAY - Keeper relay chamber

**Visual/geometry intent:** Use central relay mast and noninteractive cable crown; preserve unobstructed pulse floor.

**Route/reward intent:** Leave existing completion and return intact; optional expansion shortcuts must not allow early attunement.

**Developer specification:** retain current exits and pickups at audited coordinates; stage any new branch on a separate stable landing. Add environmental support to each anchor without adding collision inside its swing volume. Require bounded enemy territory or developer-approved lane implementation before moving guards toward platform ends. Keep arrival and first landing outside enemy attack ranges.

**Acceptance:** room identity is distinguishable without its title; both original transitions and rewards remain usable with the original kit; all new locked rewards reject collection before their flag; player can reach a safe recovery landing after missing each new swing. New route is visible on mini-map/full map with its lock state.

