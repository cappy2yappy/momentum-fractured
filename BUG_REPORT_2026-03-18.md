# BUG REPORT - 2026-03-18

Project: `MOMENTUM: FRACTURED`  
Scope: Full pre-Phase-4 bug sweep (derived 15-test checklist)

## Summary

- Critical bugs: **0**
- High bugs: **0 open** (**2 fixed**)
- Medium bugs: **0 open** (**1 fixed**)
- Low bugs: **2 open** (non-blocking)

---

## Fixed Bugs

### B-2026-03-18-001
- Severity: **High**
- Title: Damage number feedback called invalid `Camera2D` API
- Symptom:
  - Repeated runtime errors on hits:
  - `Invalid call. Nonexistent function 'unproject_position' in base 'Camera2D'`
- Root cause:
  - `scripts/systems/combat_feedback.gd` used `camera.unproject_position(...)` (3D API pattern, invalid on `Camera2D`).
- Fix:
  - Replaced with viewport canvas transform conversion for world->screen positioning.
- Files:
  - [`scripts/systems/combat_feedback.gd`](/Users/tonysantiago/Documents/Playground/momentum-fractured/scripts/systems/combat_feedback.gd)
- Status: **Fixed**

### B-2026-03-18-002
- Severity: **High**
- Title: Hard autoload globals caused compile/runtime failures in tool/non-scene contexts
- Symptom:
  - Tool/script runs failed with compile errors such as:
  - `Identifier not found: GameState`
  - `Identifier not found: AudioManager`
- Root cause:
  - Multiple scripts referenced autoload names directly at compile time.
  - Initial fix using `/root/...` still caused tree-access errors for nodes not yet in active tree.
- Fix:
  - Replaced direct singleton access with guarded helper lookups:
  - `if not is_inside_tree(): return null`
  - `get_tree().root.get_node_or_null("SingletonName")`
- Files (major):
  - [`scripts/player/kaze_base.gd`](/Users/tonysantiago/Documents/Playground/momentum-fractured/scripts/player/kaze_base.gd)
  - [`scripts/combat/hurtbox.gd`](/Users/tonysantiago/Documents/Playground/momentum-fractured/scripts/combat/hurtbox.gd)
  - [`scripts/rooms/room_controller.gd`](/Users/tonysantiago/Documents/Playground/momentum-fractured/scripts/rooms/room_controller.gd)
  - [`scripts/rooms/checkpoint.gd`](/Users/tonysantiago/Documents/Playground/momentum-fractured/scripts/rooms/checkpoint.gd)
  - [`scripts/ui/hud.gd`](/Users/tonysantiago/Documents/Playground/momentum-fractured/scripts/ui/hud.gd)
  - plus supporting enemy/UI/system scripts updated to same safe pattern
- Status: **Fixed**

### B-2026-03-18-003
- Severity: **Medium**
- Title: Room 04 forward door label state mismatch
- Symptom:
  - Door text showed `"(locked)"` while the door was configured as open.
- Root cause:
  - Scene label text out of sync with door config.
- Fix:
  - Updated label text to `"(open)"`.
- Files:
  - [`scenes/rooms/room_04_checkpoint.tscn`](/Users/tonysantiago/Documents/Playground/momentum-fractured/scenes/rooms/room_04_checkpoint.tscn)
- Status: **Fixed**

---

## Open Non-Blocking Issues

### B-2026-03-18-004
- Severity: **Low**
- Title: Nested duplicate project directory warning during editor scan
- Symptom:
  - `Detected another project.godot at res://momentum-fractured. The folder will be ignored.`
- Root cause:
  - Untracked nested project folder exists under top-level repo.
- Status: **Open** (workspace hygiene, not gameplay-blocking)

### B-2026-03-18-005
- Severity: **Low**
- Title: Headless exit leak warning
- Symptom:
  - `ObjectDB instances leaked at exit` in headless runs.
- Root cause:
  - Likely shutdown/lifecycle cleanup issue in current runtime flow; no in-session gameplay break observed.
- Status: **Open** (non-blocking)

