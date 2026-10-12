**LD-01 / 2026-10-12. Status: design proposal pending creator approval.**

Baseline: `codex/kaze-boundary-sprite-integration` at `0bf37e19ef3498386b133ed5d41e32788c2609d6`. Static source audit; no new engine playthrough or measured MV-01 values claimed. Coordinates are world pixels, origin top-left, y increases down.

## LD-01 proposal - NOT APPROVED BY MV-01

No MV-01 measurements, recommendations or sign-off are present. This document records baseline observations and requests; it is not an instruction to replace the controller. LD owns layouts, supports, recovery and gated route intent. MV-01 owns mechanical recommendations and implementation within its authorization. Godot developer owns transition/geometry integration; QA owns recorded live acceptance. Creator approves the design checkpoint and any movement change.

| Item | Verified baseline | Pending decision / evidence from MV-01 |
|---|---|---|
| Ground speed | walk400, run600 world px/s | permanent tier values, acceleration/braking and maximum combined speed |
| Jump | impulse -900, gravity1800; variable release cut; wall jump (�480,-880) | measured tap/full/double/wall trajectories, air control and max envelopes at all tiers |
| Dash | facing horizontal920, duration0.18, cooldown0.58 | approved max/chain behavior, interaction with temporary bonus and swing release |
| Attach | airborne; origin (0,-55); length80..400; facing x -100..400; y�-35 | longer range recommendation, minimum, selection, obstruction and retry rules |
| Feedback | drawn proximity <520 from feet vs eligibility from origin | single truthful eligibility presentation, blocked/selected state |
| Swing | gravity1800, pump130 in integrator; collision releases; attachment resets air_used | measured arc/clearance, released velocity and chaining behavior; rope LOS/wrapping decision |
| Transitions | E portals reset velocity and tether | whether bonuses survive transitions; safe arrival/stopping envelope; no assumed cross-room carry |
| Water | visual only, fall y>1510 costs HP | aquatic work is separate future approval; dry expansion main routes now |
| Permanent upgrades | proposed, absent in baseline | IDs, acquisition/stacking, persistence and migration owner |
| Temporary momentum | proposed, absent in baseline | earn/decay/caps/reset, reward thresholds, feedback and paused/room/death handling |

### Requested measurement handoff

For each baseline/permanent tier/temporary max/combined max, record engine/version, build SHA, collider dimensions, input sequence, displacement/velocity traces, full/tap/double/wall jump envelopes, stopping distances, dash reach, attachment eligibility, swing samples, pumping release envelope and landing margin. Test with enemies/hitstop and varying supported frame rate while targeting 60 FPS. Provide a reproducible test room/script and captured results. No percentages or thresholds are approved by LD.

### Level invariants proposed for agreement

- Ordinary progression is achievable without temporary bonuses and without optional speed upgrades; those upgrades offer exploration convenience/mastery opportunities.
- Closed mandatory element gates reject rewards/transitions regardless of speed, jumping, grapple or alternate entrance. Possessing a movement upgrade never opens an elemental lock.
- Optional momentum lanes reconnect to a safe main route; misses do not strand players without an anchor or required ability.
- Geometry is sized to measured envelope and stopping distance, not an invented bonus percentage. Decorative supports do not obstruct rope/player paths.
- Gate unlock and progression checks are enforced at named route/reward endpoints; directional graph expansion cannot skip the established story chain.
- Keep original art, movement feel, save identity and baseline eight-room geometry until explicit approved change.

### Open questions / sign-off

1. How much longer should attach range be, and should feedback follow valid selection rather than a larger proximity halo?
2. Does rope need LOS blocking or wrapping? How is selection disambiguated near multiple anchors?
3. What are movement tiers and total cap, and which rewards persist? Which agent owns migration?
4. Are momentum chains reset at portal, pause, injury, death, checkpoint or water? Current portals clear velocity.
5. What minimum ledge widths, swept clearances and rest spacing pass at every supported configuration?
6. Which optional speed reward sources can be untimed alternatives so progression never depends on mastery?

| Owner | Status | Evidence |
|---|---|---|
| LD-01 | Proposal supplied | eight-room network and gate audit |
| MV-01 | Pending | no measured response received |
| Godot developer / QA | Pending | no new levels implemented/tested |
| Creator | Pending design checkpoint | major level changes intentionally not started |

