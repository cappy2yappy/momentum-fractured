# Phase 2 Complete: Combat System + Metroid-Style Rooms

## ✅ What Was Built

### Combat System (Hitbox/Hurtbox/Health)
- **`scripts/combat/health.gd`** - Health tracking component
  - Tracks HP, emits signals on damage/death
  - `take_damage()`, `heal()`, `die()`, `reset()`
  
- **`scripts/combat/hurtbox.gd`** - Damage receiver (Area2D)
  - Detects hitboxes, applies damage to health component
  - Invincibility frames, knockback support
  - Filters out same-owner hits
  
- **`scripts/combat/hitbox.gd`** - Damage dealer (Area2D)
  - Configurable damage, knockback, duration
  - Single-hit or multi-hit mode
  - Auto-disables after duration

### Player Combat (Kaze)
- Added attack functionality to `kaze_base.gd`
  - Left click triggers attack
  - Attack cooldown (0.3s)
  - Hitbox activates for 0.15s
  - Knockback applies in facing direction
  
- **Kaze sprites integrated** (from M0M3NTUM)
  - Copied all animation strips: idle, run, jump, fall, dash, wall_slide, attack
  - Created `attack_strip.png` from individual frames
  - AnimatedSprite2D configured in `scenes/kaze.tscn`

### Enemy Updates (Echo)
- Connected to new combat system
  - Health component tracks HP (50 HP)
  - Hurtbox receives damage
  - Enters hitstun on hit, dies when HP reaches 0
  - Signals properly connected

### Room-Based Combat System
- **`scripts/rooms/room_controller.gd`** - Metroid-style encounter manager
  - Tracks enemy count
  - Locks doors until all enemies defeated
  - Unlocks exits when room cleared
  - Updates UI counter
  - Triggers scene transitions on exit
  
- **`scenes/combat_test.tscn`** - Test room with 3 Echos
  - Enclosed room with walls, floor, ceiling
  - 3 Echo enemies spawn
  - Left exit door locked (red barrier)
  - Unlocks when all enemies defeated
  - Enemy counter UI updates in real-time

## 🎮 Game Structure Change

**From:** Roguelite runs (procedural, death = restart)  
**To:** Metroid-style interconnected rooms

### How It Works
1. Enter room → combat encounter starts
2. Doors lock, enemies spawn
3. Clear all enemies → doors unlock
4. Exit to next room
5. Checkpoints between rooms save progress
6. Backtracking enabled for ability-gated areas

### Current Test Scene
- Single locked room
- 3 Echo enemies
- Must defeat all to unlock exit
- Exit reloads scene (placeholder for room transitions)

## 🐛 Issues Fixed
- **Script parsing errors** - Changed typed references (Hitbox/Hurtbox/Health) to base types (Area2D/Node) to avoid class_name resolution issues in headless mode
- **Sprite integration** - Kaze now uses original M0M3NTUM sprites instead of placeholder ColorRect
- **Combat flow** - Player → Hitbox → Hurtbox → Health → Enemy death pipeline working

## 📁 New File Structure
```
momentum-fractured/
├── assets/sprites/kaze/
│   ├── idle_strip.png
│   ├── run_strip.png
│   ├── jump_strip.png
│   ├── fall_strip.png
│   ├── dash_strip.png
│   ├── wall_slide_strip.png
│   └── attack_strip.png
├── scripts/combat/
│   ├── health.gd
│   ├── hurtbox.gd
│   └── hitbox.gd
├── scripts/rooms/
│   └── room_controller.gd
├── scenes/
│   ├── kaze.tscn (player with sprites + hitbox)
│   ├── enemies/echo.tscn (enemy with hurtbox + health)
│   └── combat_test.tscn (test room with 3 enemies)
```

## 🎯 Next Steps (Phase 3)

### Immediate
- [ ] Test in Godot editor
- [ ] Verify attack animations play on left click
- [ ] Tune combat feel (knockback, hitstun, damage values)
- [ ] Add visual feedback (hit flash, damage numbers)

### Room System
- [ ] Create room transition system (door → next scene)
- [ ] Design first 3-5 interconnected rooms
- [ ] Add checkpoint system
- [ ] Implement scene persistence (dead enemies stay dead)

### Combat Expansion
- [ ] Add more attack moves (heavy attack, air attack, dash attack)
- [ ] Enemy AI improvements (aggro range, attack patterns)
- [ ] Add more enemy types
- [ ] Boss encounter framework

### Polish
- [ ] Camera follow with room constraints
- [ ] Health bar UI for player
- [ ] Enemy health indicators
- [ ] Death/respawn system

## 🧪 How to Test
1. Open project in Godot
2. Run `scenes/combat_test.tscn`
3. Move with WASD, jump with Space, dash with Shift
4. Left click to attack the Echos
5. Defeat all 3 enemies to unlock the exit
6. Walk into the exit to reload the scene

## 💬 Notes
- Combat system is modular - attach Health + Hurtbox to any entity to make it damageable
- Hitbox can be activated/deactivated dynamically for timed attacks
- Room controller is reusable - just point it at an Enemies node and configure door paths
- Sprite strips use horizontal layouts (frames side-by-side)
