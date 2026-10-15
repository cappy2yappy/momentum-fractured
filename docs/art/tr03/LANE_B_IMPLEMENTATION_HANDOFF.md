# TR-03 Lane B — implementation-first art handoff

Status: **REVIEWABLE SPECIFICATIONS / NOT FINAL SPRITES**. Authoritative work order: `880718f51b761ffbe40fb028741135b58b00e5f1:docs/agent_assignments/TR03_ALPHA061_EMBODIED_TRANSITIONS.md` (read in full). Lane B owns visual specifications only. Lane A owns activation, runtime staging, metadata, collision and tests. No merge permission is granted.

Verified source: TR-02 head `e9a2d1ab0537f3f903c543b080451b3556961179`; art base `2b1ccec9e293a50ada9c11d3dc9751281db31cb1`. These are distinct feature foundations. This art branch does not import TR-02 gameplay or replace its comparison build. Existing ART-01 concepts and sprites remain intact.

## Minimum handoff Level can implement now

| Presentation | Existing art safe to reuse | Required new art / placeholder | Implementation boundary |
| --- | --- | --- | --- |
| horizontal_walk | Existing idle only for a stationary pause; current run is not an accepted walk | Low-amplitude 6-frame walk cycle; use labeled schematic or preserved TR-02 graphic meanwhile | Sample actual intent/speed; never slow simulation to make run look like walk |
| horizontal_run | Existing eight-frame run strip and current exact scale/pivot | None for phase-one continuation; pose-clock handoff spec below | Retain approach direction/frame phase where Lane A can do so safely; carry velocity only under TR-02 pilot policy |
| depth_door | Current side-view idle supplies identity reference, not a rear pose | 4 turn keys + 3 inward steps + 3 outward steps + 2 reorientation keys | No sideways translation standing in for depth; gated single demonstration needs explicit depth metadata |
| stair_up / stair_down | Current traversal frames only as explicitly labeled fallback, not a stair animation | Six ascending and six descending poses with distinct lead legs and contact events | Render-only staged proxy while frozen; endpoints, arrival and graph are unchanged |
| wind_fold | Retain liked TR-02 original wind-cloth treatment | No replacement requested; architecture kit supplies exceptional recess shape only | Keep exceptional, optional reduced motion; no universal wipe |

## Non-negotiable timing and ownership

Keep the existing 0.65-second discrete loader. At 60 Hz this is 39 ticks. Existing swap occurs when remaining clock falls below 0.32 seconds (approximately elapsed 0.33 seconds); animation must follow **actual loader events**, not assume a new fixed swap callback. No streaming claim.

Storyboard timing proposal: ticks 0–11 turn/approach; 12–18 inward stride or first visible stair contacts; 18–21 opaque architectural occlusion and swap; 21–29 destination emergence; 30–38 profile/run recovery; tick 39 physics resumes under existing loader. First production clips may be re-timed to these cues without changing gameplay clock. This is short entry/exit staging, **not an entire long staircase traversal compressed into 0.65 seconds**.

Suggested render-only adapter fields: presentation_mode, exit_heading, arrival_heading, approach_motion, depth_axis, stair_rise_direction, source/destination art anchors, mirror_safe, occluder_polygon, clip_phase. These are a schema proposal, not new runtime fields, save fields or graph IDs. Lane A chooses eligible actual endpoints. Never infer depth/stair direction from facing or incomparable per-room y coordinates.

Before requesting travel, existing progression checks must approve the endpoint. During loader freeze a render proxy may depict the action; it must not mutate velocity, capsule, world position, progression or saves. Hide the actual sprite only for the proxy window and restore it on completion, cancel, death, pause interruption and failed request. Arrival uses the existing safe spawn. Lock input through current policy; no new interaction or camera control is prescribed here.

## Exact current pilots and scope

- R15 Lower Sluice ↔ R16 Root Shrine: current automatic horizontal pilot, endpoints (2080,1120) ↔ (120,1120), Archive prerequisite. Use direction-specific run/low-speed presentation; original safe x carry and cooldown/rearm remain Lane A's authority.
- R14 Bellroof Walk ↔ R17 Counterweight Spire: current E stairwell control, (1450,480) ↔ (1680,1300), Tether + Dash. Up/down assignment needs explicit Lane A metadata; one room's y value does not establish the other's physical elevation.
- R20 Relay Junction ↔ R13 Mooring Loft: exceptional wind-fold, (600,520) ↔ (900,400), current combined prerequisites unchanged.
- Depth door: **no eligible endpoint chosen by art**. Storyboard is a gated demonstration design until Level confirms metadata; do not convert arbitrary portals or invent a connection.

## Readability and fallback

Recess/darkening should communicate depth while preserving a bright threshold lip. Rear-quarter silhouette must expose headband tails, hair mass and the same outfit. Facing changes use an authored turn; negative x scale alone is only a side-view left/right mirror. Feet lift at stair rise; do not translate a frozen upright idle diagonally and call it a finished stair animation.

Reduced motion: same architecture, distinct static facing key plus fade; no spin, zoom burst, camera shake or required moving panels. Ordinary walk/run should remain quiet. If new poses are unavailable, keep TR-02 comparison graphic/plain/reduced treatments selectable and visibly mark missing character animations. Never pass placeholders off as final art.

See [sprite contract](SPRITE_PACK_SPEC.md), [accepted-vs-new audit](ACCEPTED_VS_NEW_ASSETS.md), [architecture kit](ARCHITECTURE_KIT.md), [review schedule](PRODUCTION_PLAN.md), and `transition_art_contract.json`.
