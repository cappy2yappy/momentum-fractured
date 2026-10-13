# Alpha 0.6 shared movement contract ΓÇö MV-01 contribution

Status: measured baseline + tested mechanical prototype; pending LD-01 review and integration. Common starting commit **0bf37e19ef3498386b133ed5d41e32788c2609d6**, restored-size Alpha 0.5.2, not historical main. MV-01 branch `feature/alpha-0.6-momentum`. No LD-01 branch was merged and no room/anchor placement was edited.

Exchange this document and its supporting docs through the dedicated documentation commit on MV-01's branch; review the diff, then explicitly decide integration/cherry-pick. Files on a separate branch do not update automatically. LD-01 should record its chosen baseline and objections in its own reviewed contribution; neither agent silently merges the other.

| Contract item | Measured / proposed / implementation |
| --- | --- |
| Baseline speed | measured walk400, run600; ground accel/brake2600; air1200 |
| Vertical reach | measured full jump232.5643; scripted double jump464.5643; recommend ΓëÑ470 px plus collision margin for a bare double-jump clearance test, not a global lock |
| Dash | measured 168.6667 px in12 sampled ticks; source920 px/s,0.18 s,0.58 cooldown; repeated air dashes not charge-limited in this controller |
| Grapple | original80ΓÇô400; prototype80ΓÇô440 radial, configurable upper hard bound480; forward projectionΓëÑ-100, anchorΓëÑ35 above hand, airborne |
| Swing | hand offset(0,-55); pump130; gravity1800; exact release preserved; 60px body/14px radius clearance |
| Upgrade | tested explicit stride_1, walk420/run630; no autoaward or new pickup yet |
| Meter | opt-in;0ΓÇô1; run gain0.12/s above360 real travel; decay0.18/0.45; dash/tether reward0.08 with travel/time/technique guards; damage-0.5 |
| Intended sprint target cap | 600/630 atzero;636/667.8 atfull meter; inherited momentum can exceed target |
| Anchor objects | optional grapple_anchor.gd Node2D, enabled/attachment_offset/required_ability; legacy vectors remain; world gathers only descendant objects |
| Obstruction | initial layer1 ray check; body collision releases; no rope wrapping; exposed object attachment required |

## Progression and gate audit

Unlock flags: `double_jump` (Market reward), `tether_unlocked` (Echo Shrine), `dash_unlocked` (Ascent Tower), `kunai_unlocked.wind/fire/electric`, `speed_upgrade_level`. Check `player.has_traversal_requirement(id)` for capability; check `world.opened_kunai_gates.get(gate_id,false)` for an actually opened seal. Possessing an element is not equivalent to opening a gate.

| Gate | Measured protection / LD-01 follow-up |
| --- | --- |
| cistern_wind_cache, room2 | 30px wide,250px tall at(2150,850). Physical seal only; secret at(2300,830) uses proximity without opened-state check. Static audit identifies a state-protection gap and plausible over/around route. Exact live bypass route not reproduced. LD-01 should validate geometry and require opened state for sealed reward if intended. |
| span_fire_cache, room4 | 30px wide,270px tall at(1990,1080). Finite physical barrier; no dedicated guarded reward in world update. Traversal around it does not open its state. LD-01 owns intended route enclosure. |
| relay_electric_seal, room7 | 30px wide,300px tall at(2000,1300). Relay interaction at(2200,1300) checks proximity only, not opened state. Existing state-protection gap: reaching the far side can restore the relay without opening the Electric seal. Coordinate-seeded audit reproduces this; a complete live traversal bypass remains untested. |
| terrace_fire_cache, room9 | 280px tall at(2110,810); fragment explicitly checks opened-state, so jumping to its coordinates cannot collect it. |
| terrace_return_relay, room9 | Electric,280px at(360,620); portal interaction checks opened-state both directions. |
| skyworks_wind_intake, room10 | Wind,280px at(2110,810); room10ΓåÆ11 transition checks opened-state. |
| foundry_electric_relay, room11 | Electric,300px at(2370,760); room11ΓåÆ12 checks opened-state. |

Existing ability transitions separately check Windstep, tether, dash, boss defeat, restored archive and three sigils. No movement upgrade changes those flags. Wind/Fire/Electric projectile resolution accepts matching element only; wrong elements retain the barrier. Existing automated projectile/state checks were rerun.

Geometry problems differ from state problems: finite-height seals can be traveled over/around with elevated approach, double jump, wall jump, repeat dash or rope. State-guarded interactions remain locked despite physical travel. Do not disable valid double jump to repair either. Capsule top is60px above feet; account for body clearance and 30px gate width. There is no globally finite maximum ascent due to repeat wall/tether chains.

Open integration decisions: pickup location and presentation for stride_1; approve440 vs420 range; grounded anchor discoverability vs eligible indicator; exposed anchor art/scenes and arcs; whether every early secret is intended to require opened state; manual high-speed seal bypass sweep; approve opt-in meter default for a release. Absolute speed clamp, rope wrapping, wall-chain bonus and full upgrade tree are outside this MVP.

See MOVEMENT_BASELINE, GRAPPLE_RANGE_REVIEW, HYBRID_MOMENTUM_SPEC and MOVEMENT_REGRESSION_RESULTS. Headless passes do not approve movement feel, performance at60FPS, or complete campaign balance.
