# Hybrid speed progression prototype

Implementation is deliberately reversible: zero upgrades and disabled/zero momentum retain the approved movement targets. Temporary behavior is opt-in via `-- --momentum-prototype` after Godot/project arguments; regular runs keep it disabled. A small HUD meter appears only when enabled. No new controls replace existing actions.

## Permanent first upgrade

Explicit API: `player.unlock_speed_upgrade("stride_1") -> bool`; rejects unknown IDs and repeated acquisition. One tier only, walk target 400→420 px/s, run 600→630 px/s (+5%). Ground/air acceleration, braking, jump, wall movement, dash, cooldowns, collision and swing remain unchanged. `has_traversal_requirement` provides fail-closed checks for double_jump, tether, dash, stride_1 and the three kunai elements.

Save schema 7 adds `speed_upgrade_level` (0 or 1); exact known saved numeric 1 restores tier 1, all other values restore zero. Missing keys in old saves default to zero. Same save directory/name; schemas 4/5/6 remain readable. The upgrade is not automatically awarded: LD-01/creator must choose an exploration pickup and wire the API followed by `world.save_progress()`. A debug/test can call the same API independently. A full tree, acceleration upgrade and retention upgrade are deferred.

Balance alternatives awaiting playtest: sprint-only +5% would leave precision walk at 400; +3% both targets would be less noticeable. Current +5% both is a prototype choice. Meter multiplier affects sprint only, preserving upgraded walk for precision work.

## Temporary meter rules

`momentum_profile.gd` owns configurable meter parameters. Distances are world pixels, speeds px/s, rates normalized points/s, durations seconds. Meter clamps 0–1. Maximum temporary fraction is bounded 0–0.06 even if a debug caller sets a larger value.

| Rule | Prototype value / behavior |
| --- | --- |
| Sustained gain | +0.12/s while double-tap run is active, actual horizontal travel ≥360 px/s, travel agrees with input, no attack/invulnerability interruption |
| Moving decay | -0.18/s outside qualifying run when actual speed ≥360 |
| Idle/interrupted decay | -0.45/s; includes pressing against a wall, combat/invulnerability and slow motion |
| Chain reward | +0.08 at traveled dash completion or tether release |
| Chain safeguards | net technique travel ≥96 px; useful horizontal exit speed ≥360; directional travel since last reward ≥150 px; ≥0.8 s between rewards; consecutive rewarded technique must differ |
| Damage | subtract 0.5 and suppress gain/rewards 1.2 s; rejected invulnerable hits do not penalize again |
| Death, fall recovery, room rebuild, load | reset all temporary state; permanent tier persists |
| Pause / transition / hitstop | freezes with the controller; destination rebuild resets meter |
| Maximum sprint target | 636 baseline + full meter; 667.8 with stride_1 + full meter |
| Walk / dash / swing | meter does not change their speed target, impulse or integrator |

Actual collision displacement drives gain: stationary key presses, wall-blocked running and animation changes cannot farm it. Dash and tether consume/decay time through their existing update paths and reward only a traveled transition. Wall traversal earns no separate transition bonus in this MVP; successful return to purposeful running can resume sustained gain. There are no repeated-input bonuses.

Caps are **driven target caps**, not global velocity clamps. The approved controller intentionally preserves overspeed from dash and swing. Meter loss does not suddenly brake incoming momentum or change release velocity; ground braking remains 2600 px/s². An absolute cap would change approved physics and requires a separate creator decision. The feature may widen lateral reach while active, so geometry must be tested at 667.8 targets plus inherited swing/dash momentum.

Preservation manifest controller/physics hashes intentionally change for target selection, configurable range and meter hooks. Artwork entries remain unchanged. The verifier additionally checks unchanged animation and swing functions against the immutable restored-size rollback controller; behavioral differential tests protect base movement. This is a movement experiment, not a new approved release checksum.

Run `godot --path . -- --momentum-prototype` for manual testing. Debug award `world.player.unlock_speed_upgrade("stride_1")`; set `world.player.momentum.enabled`/`meter` independently in a debugger or test. Do not ship debug state as a pickup or overwrite a personal save while testing.
