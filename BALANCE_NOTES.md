# Balance Notes - Shibuya Vertical Slice

Date: 2026-03-14

## Pass Summary

This pass establishes a playable baseline for Rooms 01-12 with current enemy roster and boss flow.
Combat and encounter pacing were tuned around the current combo-enabled player attack profile.

## Current Combat Values

Player (`scripts/player/kaze_base.gd`)
- Attack combo damage: `14 / 17 / 22`
- Dash speed: `1600`
- Max HP: `100`

Echo (`scripts/enemies/echo.gd` + `scenes/enemies/echo.tscn`)
- HP: `50`
- Attack damage: `10`
- Attack range: `48`

Drone (`scripts/enemies/drone.gd` + `scenes/enemies/drone.tscn`)
- HP: `30`
- Projectile damage: `5` (from projectile pool spawn)
- Shoot cooldown: `2.0`

Guardian (`scripts/enemies/guardian.gd` + `scenes/enemies/guardian.tscn`)
- HP: `100`
- Shield bash damage: `8`
- Heavy slash damage: `15`
- Frontal shield block: enabled
- Enrage threshold: `30% HP`

Echo Amalgam (`scripts/enemies/echo_amalgam.gd`)
- HP: `300`
- Dash damage: `20`
- Ground slam damage: `25`
- Reward cells: `100`

## Room Pacing Baseline

- Checkpoints: Room 04 and Room 09
- Boss gate: Room 10 clear -> Room 11 boss
- Victory + unlock: Room 12

## Tuning Goals

- Full-path first clear target: `15-25 minutes`
- Expected deaths for a new player: `3-8` on full run
- Boss attempts target: `2-4` for first clear

## Manual QA Focus

1. Validate Guardian readability in Room 03 and Room 07 (front block vs rear punish).
2. Verify hazard fairness in Room 06 and Room 08 (avoid unavoidable damage loops).
3. Confirm boss phase transitions feel clear (300->100->50 HP thresholds).
4. Confirm checkpoint spacing is sufficient for new players.

## Next Balance Iteration

- If run is too punishing:
  - Lower Echo attack damage to `8`
  - Increase player combo step 1 damage to `15`
  - Increase Room 09 heal/checkpoint recovery messaging
- If run is too easy:
  - Reduce player combo step 3 damage to `20`
  - Increase Drone pressure (shoot cooldown `1.8`)
  - Increase boss dash frequency in phase 3
