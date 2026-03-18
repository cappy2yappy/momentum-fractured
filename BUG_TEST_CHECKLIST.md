# BUG TEST CHECKLIST (2026-03-18)

Derived from current project docs (`README.md`, `CODEX_TODO.md`, `PHASE_4_TASKS.md`) for the urgent pre-Phase-4 bug sweep.

- [x] **Test 1 - Game launch & import path**
  - Command: `Godot --headless --path ... --import`
  - Result: PASS (non-blocking warnings only)

- [x] **Test 2 - Editor/script compile scan**
  - Command: `Godot --headless --editor --path ... --quit-after 3`
  - Result: PASS (no compile errors)

- [x] **Test 3 - Main scene boot**
  - Command: `Godot --headless --path ... --quit`
  - Result: PASS

- [x] **Test 4 - Room 01 combat runtime**
  - Command: `--scene res://scenes/rooms/room_01_combat.tscn --quit-after 180`
  - Result: PASS

- [x] **Test 5 - Room 02 platforming runtime**
  - Command: `--scene res://scenes/rooms/room_02_platforming.tscn --quit-after 180`
  - Result: PASS

- [x] **Test 6 - Room 03 mixed runtime**
  - Command: `--scene res://scenes/rooms/room_03_mixed.tscn --quit-after 180`
  - Result: PASS

- [x] **Test 7 - Room 04 checkpoint runtime**
  - Command: `--scene res://scenes/rooms/room_04_checkpoint.tscn --quit-after 180`
  - Result: PASS

- [x] **Test 8 - Combat test scene runtime**
  - Command: `--scene res://scenes/combat_test.tscn --quit-after 180`
  - Result: PASS

- [x] **Test 9 - Hazard scenes smoke test**
  - Scenes: `saw`, `laser`, `crusher`, `fire_pit`
  - Result: PASS

- [x] **Test 10 - Enemy scenes smoke test**
  - Scenes: `echo`, `drone`, `guardian`, `echo_amalgam`
  - Result: PASS

- [x] **Test 11 - UI flow scenes smoke test**
  - Scenes: `ui/hud.tscn`, `rooms/room_12_victory.tscn`
  - Result: PASS

- [x] **Test 12 - Full Room 01 -> 04 flow simulation**
  - Tool: `res://tools/tests/room_flow_smoke.tscn`
  - Result: PASS (door lock/unlock + transitions validated)

- [x] **Test 13 - Room door/spawn wiring audit**
  - Verified door targets and entry markers across Rooms 01-04
  - Result: PASS

- [x] **Test 14 - Save/load persistence field audit**
  - Verified checkpoint + progression fields in `GameState` save/load payload
  - Result: PASS

- [x] **Test 15 - Tooling compile resilience check**
  - Command: `Godot --headless --path ... --script res://tools/import_room_json.gd --quit`
  - Result: PASS for compile; expected runtime limitation remains: `EditorScript` requires editor context

