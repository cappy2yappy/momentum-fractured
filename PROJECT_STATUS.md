# MOMENTUM: FRACTURED - Project Status

**Last Updated:** March 25, 2026  
**Phase:** 3 Complete, Phase 4 In Progress  
**Playable:** Yes (4 rooms + combat prototype)

---

## Quick Summary

**What is it?**  
Metroidvania action-platformer. Metroid Dread meets Tokyo at midnight. Room-to-room combat with ability-gated progression.

**What works?**  
- ✅ Player movement (run, jump, wall-jump, dash)
- ✅ Combat system (3-hit combo, dodge, attacks)
- ✅ 2 enemy types (Echo melee, Drone ranged)
- ✅ 4 playable rooms (combat, platforming, mixed, checkpoint)
- ✅ Save/load system
- ✅ UI/HUD (health, cells, combo counter)
- ✅ Hazards (spikes, saws, lasers, crushers, fire)
- ✅ Moving platforms
- ✅ Visual polish (hit flash, damage numbers, screen shake)
- ✅ Audio framework (placeholder sounds)

**What's next?**  
- 🔄 More enemy types (Guardian, Ninja, Golem, Sentry)
- 🔄 Boss fights
- 🔄 Ability unlocks (grapple hook, double jump, slide)
- 🔄 More biomes (Temple, Metro, Rooftops, Docks, Core)
- 🔄 Real art assets (replace placeholders)

---

## Project Links

**GitHub Repo:**  
https://github.com/cappy2yappy/momentum-fractured

**Full GDD (23KB):**  
[GDD.md](https://github.com/cappy2yappy/momentum-fractured/blob/main/GDD.md)

**Design Docs:**
- [DESIGN_UPDATE.md](https://github.com/cappy2yappy/momentum-fractured/blob/main/DESIGN_UPDATE.md) - Metroidvania structure
- [ENEMY_ASSETS.md](https://github.com/cappy2yappy/momentum-fractured/blob/main/ENEMY_ASSETS.md) - Asset sourcing
- [PHASE_4_TASKS.md](https://github.com/cappy2yappy/momentum-fractured/blob/main/PHASE_4_TASKS.md) - Next priorities

**Development Logs:**
- [OVERNIGHT_REPORT.md](https://github.com/cappy2yappy/momentum-fractured/blob/main/OVERNIGHT_REPORT.md) - Tasks 1-10 complete
- [PLAYTEST_REPORT_2026-03-12.md](https://github.com/cappy2yappy/momentum-fractured/blob/main/PLAYTEST_REPORT_2026-03-12.md) - Playtest findings

---

## Current State (Phase 3 Complete)

### ✅ What's Built

**Player Character: Kaze**
- Movement: WASD, Space (jump), Shift (dash)
- Combat: Left Click (3-hit combo), Right Click (dodge roll)
- Wall mechanics: Wall jump, wall slide
- Stats: 100 HP, upgradeable
- Animations: Idle, run, jump, fall, dash, attack

**Enemy Types (2/6)**
1. **Echo** (Melee)
   - Patrols, chases player
   - Melee attack (10 damage)
   - 50 HP, dies in 4 hits
   - Drops 5 cells on death

2. **Drone** (Ranged)
   - Flies, hovers above platforms
   - Shoots projectiles (5 damage)
   - 30 HP, dies in 2 hits
   - Retreats if player gets too close

**4 Rooms Built**
1. **Room 01: Combat Arena**
   - 3 Echo enemies
   - Flat layout
   - Door unlocks when cleared

2. **Room 02: Platforming Challenge**
   - No enemies
   - Hazards: Spikes, saws, moving platforms
   - Tests jump timing

3. **Room 03: Mixed Combat + Platforming**
   - 2 Echo + 1 Drone enemy
   - Elevated platforms
   - Moving platform over spike pit
   - Fight while platforming

4. **Room 04: Checkpoint Safe Room**
   - No combat
   - Checkpoint (saves progress)
   - Health refill station
   - 2 exits (backtrack or forward)

**Combat System**
- 3-hit combo (light attack)
- Dodge roll (i-frames)
- Hit detection (Hitbox/Hurtbox)
- Knockback on hit
- Hitstun (enemy pauses when hit)
- Death animation + cell drops

**Visual Polish**
- Hit flash (enemy flashes white)
- Damage numbers (float up, fade out)
- Screen shake (on player damage)
- Hit pause (0.05s freeze on heavy hits)

**UI/HUD**
- Health bar (top-left, red fill)
- Cell counter (top-right, shows total)
- Combo counter (center-top, fades after 2s)
- Enemy counter ("3 enemies remaining")
- Mini-map placeholder (bottom-right)

**Hazards (6 types)**
- Spikes (instant kill zones)
- Saws (rotating, 15 damage)
- Lasers (toggle on/off, instant kill)
- Crushers (slam down, 50 damage)
- Fire pits (continuous 20 damage)
- Moving platforms (horizontal/vertical/circular)

**Systems**
- Save/load (checkpoint, HP, cells, rooms cleared)
- Room controller (locks doors, tracks enemies)
- Scene navigation (room transitions)
- Camera system (follows player, room bounds)
- Audio manager (placeholder sounds)
- Damage numbers (pooled, reusable)
- Projectile system (Drone attacks)

**Performance**
- 60 FPS target maintained
- Enemy AI culling (sleep when far from player)
- Projectile pooling (max 20 active)
- Optimized hitbox detection

---

### 🔄 Phase 4 In Progress

**Next Priorities:**
1. Add 4 more enemy types (Guardian, Ninja, Golem, Sentry)
2. First boss fight (Echo Amalgam)
3. Grapple hook ability
4. 5 more rooms (expand Shibuya biome to 10 rooms)
5. Replace placeholder sprites with real art
6. Add music tracks
7. Upgrade system (HP, damage, speed)

**Full Phase 4 breakdown:** See [PHASE_4_TASKS.md](https://github.com/cappy2yappy/momentum-fractured/blob/main/PHASE_4_TASKS.md)

---

## How to Play (Current Build)

### Controls
- **WASD** - Move
- **Space** - Jump
- **Shift** - Dash
- **Left Click** - Attack (3-hit combo)
- **Right Click** - Dodge roll
- **ESC** - Pause menu

### Progression
1. Start in Room 01 (Combat Arena)
2. Defeat 3 Echo enemies
3. Door unlocks → proceed to Room 02
4. Navigate platforming hazards
5. Room 03: Mixed combat + platforming
6. Room 04: Checkpoint (saves progress)
7. Die anywhere → respawn at last checkpoint

### Goals
- Clear all 4 rooms without dying
- Collect cells from defeated enemies
- Master movement + combat timing
- Find optimal combat strategies

---

## Technical Details

**Engine:** Godot 4.6.1  
**Language:** GDScript  
**Resolution:** 1280×720 (16:9)  
**Target FPS:** 60  
**Platform:** PC (Windows/Mac/Linux)

**Project Structure:**
```
momentum-fractured/
├── assets/
│   ├── sprites/
│   │   ├── kaze/ (player animations)
│   │   ├── enemies/ (Echo, Drone)
│   │   └── hazards/
│   └── audio/
│       └── sfx/ (placeholder sounds)
├── scenes/
│   ├── rooms/ (4 room .tscn files)
│   ├── enemies/ (Echo, Drone)
│   ├── ui/ (HUD, health bar, cell counter)
│   └── hazards/ (saw, laser, crusher, fire)
├── scripts/
│   ├── player/ (kaze_base.gd)
│   ├── enemies/ (echo.gd, drone.gd)
│   ├── combat/ (hitbox, hurtbox, health)
│   ├── rooms/ (room_controller.gd)
│   └── systems/ (game_state, audio_manager)
└── tools/
    ├── import_room_json.gd (web editor import)
    └── README.md (room creation guide)
```

---

## Development Stats

**Start Date:** March 7, 2026  
**Days Active:** 18 days  
**Commits:** 30+  
**Lines of Code:** ~5,000  
**Scenes:** 15+  
**Scripts:** 25+

**Phase Timeline:**
- **Phase 1** (Mar 7-9): Project setup, physics, combat prototype
- **Phase 2** (Mar 9-10): Combat system, Kaze sprites, room system
- **Phase 3** (Mar 10-12): 4 rooms, UI/HUD, hazards, save/load
- **Phase 4** (Mar 12-present): Enemy variety, bosses, abilities, biomes

---

## Design Philosophy

**Core Pillars:**
1. **Tight movement** - Wall jumps, dashes feel responsive
2. **Room-to-room combat** - Metroid-style locked encounters
3. **Ability-gated exploration** - New powers unlock shortcuts
4. **Interconnected world** - Backtracking rewards curiosity

**Inspiration:**
- **Metroid Dread** - Room structure, movement feel
- **Hollow Knight** - Interconnected world, boss design
- **Dead Cells** - Combat feel, weapon variety

**Aesthetic:**
- Tokyo Noir (NOT neon cyberpunk)
- Warm amber/red tones
- Traditional Japanese + modern mix
- Metroid Dread anime art style

---

## Testing & Feedback

**Last Playtest:** March 12, 2026  
**Key Findings:**
- Combat feels good, responsive
- Enemy AI needs more variety
- Room 2 platforming too easy
- Checkpoint system works well
- Visual polish makes impact

**Known Issues:**
- Some object leaks on scene exit (non-blocking)
- No audio (placeholders only)
- Placeholder sprites (colored rectangles)
- Limited enemy variety (2 types)

**Full bug list:** See [BUG_TEST_CHECKLIST.md](https://github.com/cappy2yappy/momentum-fractured/blob/main/BUG_TEST_CHECKLIST.md)

---

## Team & Tools

**Team:**
- Cap (Tony) - Design, direction
- Cappy (AI) - Implementation, documentation
- Codex (AI) - Autonomous development

**Tools:**
- Godot 4.6.1 (game engine)
- Aseprite (sprite work - planned)
- Git/GitHub (version control)
- Web room editor (level design tool)

---

## Roadmap (Q2-Q4 2026)

**Q2 2026 (April-June):**
- ✅ Phase 3 complete (4 rooms, combat, systems)
- 🔄 Phase 4: Enemy variety + first boss
- 🔄 Shibuya biome complete (10 rooms)
- 🔄 Ability unlocks (grapple, double jump)

**Q3 2026 (July-September):**
- Temple District biome (15 rooms)
- Metro biome (15 rooms)
- 2 more bosses
- Real art assets (replace placeholders)

**Q4 2026 (October-December):**
- Rooftops biome (20 rooms)
- Docks biome (20 rooms)
- Final biome (Fractured Core)
- Polish, balance, playtesting
- **Early Access Launch**

---

## How to Get Started

**Clone the repo:**
```bash
git clone https://github.com/cappy2yappy/momentum-fractured.git
cd momentum-fractured
```

**Open in Godot:**
```bash
godot project.godot
```

**Play test scene:**
- Open `scenes/rooms/room_01_combat.tscn`
- Press F6 (run scene)

**Read the docs:**
- Start with [GDD.md](https://github.com/cappy2yappy/momentum-fractured/blob/main/GDD.md)
- Check [PHASE_4_TASKS.md](https://github.com/cappy2yappy/momentum-fractured/blob/main/PHASE_4_TASKS.md) for next steps
- See [tools/README.md](https://github.com/cappy2yappy/momentum-fractured/blob/main/tools/README.md) for level design

---

## Questions?

Ask in Discord thread: `#FRACTURED Combat Prototype`  
Check GitHub issues: https://github.com/cappy2yappy/momentum-fractured/issues  
Read the full GDD: [GDD.md](https://github.com/cappy2yappy/momentum-fractured/blob/main/GDD.md)

---

**Status:** Ready for Phase 4 expansion 🎮
