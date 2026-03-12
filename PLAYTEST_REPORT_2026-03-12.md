# PLAYTEST REPORT (2026-03-12)

## Scope

- Goal: verify current `main` is ready for internal playtest.
- Method:
  - Extended headless runtime checks (`--quit-after 360`) for:
    - `res://scenes/rooms/room_01_combat.tscn`
    - `res://scenes/rooms/room_02_platforming.tscn`
    - `res://scenes/rooms/room_03_mixed.tscn`
    - `res://scenes/rooms/room_04_checkpoint.tscn`
    - `res://scenes/combat_test.tscn`
  - Static verification of scene wiring + progression scripts.

## Checklist Results

- Room 1 boots and combat room script initializes: PASS
- Room 2 boots with platform/hazard scene setup: PASS
- Room 3 boots with mixed enemy+hazard setup: PASS
- Room 4 boots with checkpoint/heal setup: PASS
- Main startup boot (`--quit-after 360`): PASS
- No blocking script/runtime errors in tested flows: PASS
- Non-blocking warning seen in some runs (`ObjectDB instances leaked at exit`): NOTE

## Findings

### [Resolved in this pass] Abilities were not persisted to save file

- Severity: High (progression data loss risk for future unlockables)
- Root cause:
  - `scripts/systems/game_state.gd` loaded `abilities_unlocked` from disk but did not write it in `save_to_disk()`.
- Action taken:
  - Added `"abilities_unlocked": abilities_unlocked` to the save payload in `save_to_disk()`.

### [Open] Cell pickup uses checkpoint SFX

- Severity: Low (audio clarity/tuning)
- Location:
  - `scripts/pickups/cell_pickup.gd` (`_collect()`)
- Detail:
  - Pickup collection calls `AudioManager.play_sfx("checkpoint")`, which makes pickups sound like checkpoint activation.

### [Open] Door unlock SFX may replay on entering already-cleared rooms

- Severity: Low (audio polish)
- Location:
  - `scripts/rooms/room_controller.gd`
- Detail:
  - `_initialize_room_state()` calls `_unlock_doors()` immediately for cleared rooms, and `_unlock_doors()` always plays `door_unlock`.

## Playtest Readiness

- Status: Ready for internal playtest.
- Reason:
  - Core room flow, transitions, persistence hooks, combat/hazard scenes, and HUD all boot/run without blocking errors.
- Remaining risk:
  - Most checks were headless/runtime + wiring validation, not full hands-on input gameplay in editor.
