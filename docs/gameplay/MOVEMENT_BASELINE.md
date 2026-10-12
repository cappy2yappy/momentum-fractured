# MV-01 measured movement baseline

Audited 2026-10-12. Branch `codex/kaze-boundary-sprite-integration`, commit `0bf37e19ef3498386b133ed5d41e32788c2609d6`; approved Alpha 0.5.2 foundation `215e9bce3b234cb268e9426b52817f5ca844031e`. Remote refs fetched before branching. Isolated worktree and branch: `feature/alpha-0.6-momentum`. Do not start LD-01 from historical main.

Read AGENTS.md, CANONICAL_BASELINE, REPOSITORY_GUIDE, PROJECT_STATUS, ALPHA_0_5_2_REVIEW, existing tests, player/world/HUD/route-extension/SkyWorks code. Historical main GDD and parity-branch GAMEPLAY_PARITY_MATRIX / DEVELOPMENT_ROADMAP were reviewed as references: they describe other controllers and are not this branch's measured specification. Web benchmark could not be retrieved by the web tool in this run; no new web parity claim.

| Parameter | Actual source value / unit |
| --- | --- |
| Walk / double-tap run | 400 / 600 px/s |
| Double-tap window | same direction within 0.25 s; no direction ends run |
| Ground acceleration / braking | 2600 px/s² |
| Air acceleration | 1200 px/s²; no passive air braking |
| Incoming overspeed | retained while input agrees; no global horizontal clamp |
| Gravity | 1800 px/s² |
| Jump / double jump | -900 px/s; double jump gated by `double_jump` and one `air_used` |
| Jump release cutoff | upward velocity capped to -360 px/s |
| Coyote / jump buffer | 0.12 / 0.16 s |
| Wall jump | normal.x * 480, -880 px/s; available without an unlock |
| Wall slide | downward velocity capped to 100 px/s while pressing into wall |
| Dash | facing * 920 px/s, 0.18 s, cooldown 0.58 s, invulnerability minimum 0.24 s |
| Dash afterimages | every 0.03 s during dash |
| Tether origin | player feet position + (0,-55) px |
| Original acquisition | radial 80–400 px; facing projection -100–400 px; anchor at least 35 px above origin; airborne only |
| Original selection | nearest eligible anchor, first wins equal-distance tie; world cutoff 401 px |
| Original indicator | feet-distance <520 px, unlike actual targeting |
| Rope integration | gravity 1800; directional pump 130 px/s²; angular velocity Verlet step; slack-to-taut radial projection removes only outward velocity |
| Release | exact existing velocity; cooldown 0.2 s; no added impulse |
| Attachment | preserves incoming velocity; initializes slack rope; resets air_used |
| Collision shape | capsule radius 14 px, height 60 px, center 30 px above feet |
| Damage | 1 HP; 1.2 s invulnerability; horizontal knockback 280, vertical -240 px/s |

Godot 4.6.1 at 60 physics ticks/s: walk reaches 400; run reaches 600; held jump rise 232.5643 px in existing regression; scripted double-jump second-apex rise 464.5643 px; dash 168.6667 px in a 12-physics-frame sampling window. Nominal continuous dash distance 165.6 px, but the timer moves on its final tick. These are script-conditioned measurements, not a universal reach guarantee. Single continuous jump formula gives 225 px, whereas discrete source ordering produces the measured larger rise.

Wall jumps and repeated tethers (which restore double jump) mean there is no finite world-wide maximum reachable height. Incoming swing/dash momentum also means 600 px/s is a run target, not an absolute velocity cap. LD-01 must test paths, not rely on speed numbers to seal a room.

Animation mapping, frame timing, sprite scales/pivots, dash pose and the full swing integrator remain byte-identical to the retained rollback fixture. Combat timings and shapes are untouched. There is no crouch, slide or swimming controller in this approved source.

Save baseline: same application identity and `user://silent_district_alpha_v3.json`, schema 6, schemas 4/5 covered by existing migration tests. Abilities, opened gates, encounters, sigils, checkpoint position, visited rooms and MetSys state persist. Build-room resets actions; earned kit survives death. Prototype schema 7 adds only optional permanent speed level; meter is never saved.

Before edits: preservation verifier and all eight executable regression suites passed. See MOVEMENT_REGRESSION_RESULTS for final evidence. Rollback gameplay is preserved at the baseline commit and `tests/fixtures/player_alpha052.gd`, which is actively used in differential tests.
