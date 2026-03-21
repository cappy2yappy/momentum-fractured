# MOMENTUM: FRACTURED

**Genre:** 2D Metroidvania Action-Platformer  
**Engine:** Godot 4.3  
**Status:** Phase 4 - Shibuya Biome Vertical Slice

Metroid-style room-to-room combat in a shattered Tokyo metropolis.

---

## 🎮 Current Build

**Phase 3 Complete ✅**
- Combat system working
- 4 playable rooms
- 2 enemy types (Echo, Drone)
- Checkpoint save/load
- HUD and pause menu
- Performance optimized

**Phase 4 In Progress 🚧**
- Building 12-room Shibuya biome
- Adding Guardian enemy
- Echo Amalgam boss fight
- Audio system
- Tutorial messaging

---

## 🚀 Quick Start

### Play Current Build:
```bash
godot project.godot
# In Godot: Open scenes/rooms/room_01_combat.tscn
# Press F6 to run
```

### Controls:
- **WASD** - Move
- **Space** - Jump
- **Shift** - Dash
- **Left Click** - Attack
- **Esc** - Pause menu

### Debug Hotkeys:
- **F5** - Reset progress
- **F6** - Respawn at checkpoint
- **F7** - Add +50 cells
- **F8** - Set checkpoint here
- **F9** - Print debug state

---

## 📂 Key Documents

**For Codex (Autonomous Mission):**
- **`CODEX_AUTONOMOUS_MISSION.md`** ← **START HERE** (Complete mission brief)

**For developers:**
- **`CODEX_START_HERE.md`** ← Quick onboarding
- **`PHASE_4_TASKS.md`** ← Work queue (10 tasks)
- **`GDD.md`** ← Full game design document

**Status docs:**
- **`OVERNIGHT_REPORT.md`** ← Last session summary
- **`PLAYTEST_REPORT_2026-03-12.md`** ← Known issues

**Design docs:**
- `DESIGN_UPDATE.md` - Metroidvania structure
- `ENEMY_ASSETS.md` - Sprite sourcing guide
- `ASSET_GUIDE.md` - Asset recommendations

---

## 🎯 Roadmap

### Phase 4 (Current) - Shibuya Biome Vertical Slice
**Timeline:** 2-3 weeks  
**Goal:** Playable 12-room demo

- [ ] Guardian enemy
- [ ] 8 more rooms (12 total)
- [ ] Echo Amalgam boss fight
- [ ] Tutorial system
- [ ] Audio (music + SFX)
- [ ] Visual polish (sprite upgrades)
- [ ] Balance pass

### Phase 5 - Temple District
- Second biome (15-20 rooms)
- Kitsune Matriarch boss
- Grapple Hook ability (functional)
- More enemy types

### Phase 6+ - Remaining Biomes
- Underground Metro
- Rooftop Gardens
- Industrial Docks
- The Fractured Core
- Final boss fight

**Target:** Q4 2026 Early Access

---

## 🛠️ Tech Stack

- **Engine:** Godot 4.3
- **Language:** GDScript
- **Player sprite:** Custom (from M0M3NTUM prototype)
- **Enemy sprites:** Placeholders (upgrade in Phase 4)
- **Audio:** Pending (Phase 4 Task 6)

---

## 📦 Project Structure

```
scenes/
  ├── kaze.tscn              ← Player
  ├── enemies/               ← Echo, Drone (Guardian coming)
  ├── hazards/               ← Saw, laser, crusher, fire
  ├── rooms/                 ← 4 rooms (need 8 more)
  └── ui/                    ← HUD, pause menu

scripts/
  ├── player/                ← Movement + combat
  ├── enemies/               ← AI behaviors
  ├── combat/                ← Hitbox/hurtbox/health
  ├── rooms/                 ← Door logic, checkpoints
  ├── systems/               ← GameState, AudioManager (AutoLoad)
  └── ui/                    ← HUD updates

assets/
  ├── sprites/               ← Kaze + enemy placeholders
  └── audio/                 ← Empty (coming in Task 6)
```

---

## 🧪 Testing

### Headless Validation:
```bash
# Import assets
godot --headless --path . --import

# Boot test
godot --headless --path . --quit

# Scene-specific test
godot --headless --path . --scene res://scenes/rooms/room_01_combat.tscn --quit
```

### Full Playtest:
1. Launch Godot
2. Run `room_01_combat.tscn`
3. Complete sequence: Room 01 → 02 → 03 → 04
4. Check for errors in Output panel

---

## 🐛 Known Issues

### Low Priority:
- Cell pickup uses wrong SFX (checkpoint sound)
- Door unlock sound replays on re-entry to cleared rooms

See `PLAYTEST_REPORT_2026-03-12.md` for full list.

---

## 🤝 Contributing

Currently solo dev (Cap) with AI coding assistance (Codex).

**If you're Codex:**
1. Read `CODEX_START_HERE.md`
2. Work through `PHASE_4_TASKS.md` in order
3. Test frequently, commit often
4. Check GDD.md for design questions

---

## 📜 License

TBD (project in early development)

---

## 🔗 Links

- **GitHub:** https://github.com/cappy2yappy/momentum-fractured
- **Room Editor:** https://laibyrinth.com/fractured-room-editor.html
- **Discord:** (dev thread in VIP server)

---

**Last updated:** 2026-03-14  
**Version:** Phase 4 (In Progress)
