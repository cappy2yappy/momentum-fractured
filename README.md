# MOMENTUM: FRACTURED

**Genre:** 2D Metroidvania Action-Platformer  
**Engine:** Godot 4.6.1
**Status:** Alpha 0.8 playtest candidate

Metroid-style room-to-room combat in a shattered Tokyo metropolis.

---

## 🎮 Current Build

**Alpha 0.8 Candidate**
- 12 connected playable rooms across the district, undercroft, and conservatory route
- Two boss milestones: Storm Reliquary and The Borrowed Face
- Momentum Wind Tether with visible rope and grapple anchors
- Dash afterimages, swimming physics, and vertical traversal rooms
- Wind, Fire, and Electric kunai with progression-locked elemental seals
- Guard Veil boss reward and character/loadout screen
- Checkpoint save/load, persistent room clears, combat HUD, and room transitions

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
- **Q / Middle Mouse** - Hold Wind Tether and swing
- **F** - Throw equipped kunai
- **Mouse Wheel** - Cycle unlocked kunai elements
- **C** - Guard Veil after it is unlocked
- **I** - Character/loadout screen
- **Esc** - Pause menu

### Debug Hotkeys:
- **F5** - Reset progress
- **F6** - Respawn at checkpoint
- **F7** - Add +50 cells
- **F8** - Set checkpoint here
- **F9** - Print debug state

---

## 📂 Key Documents

**Current direction:**
- **`GDD.md`** ← Canonical game design document
- **`docs/GAMEPLAY_PARITY_MATRIX.md`** ← P0/P1/P2 gaps and acceptance tests
- **`docs/ART_BIBLE.md`** ← Canonical visual language and asset backlog
- **`docs/DEVELOPMENT_ROADMAP.md`** ← Current milestones and exit criteria
- **`docs/DOCUMENT_STATUS.md`** ← Current versus historical document index
- **`AGENTS.md`** ← Lead/specialist working agreement

**Status docs:**
- **`RELEASE_NOTES_ALPHA_0.8.0.md`** ← Recovery build notes

Older root-level mission, phase, report, and asset documents are historical references; see `docs/DOCUMENT_STATUS.md` before using them.

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
- Build progression on the baseline Wind Tether and Momentum Dash
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

- **Engine:** Godot 4.6.1
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
  ├── rooms/                 ← 12-room systems prototype; authored parity slice in progress
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

**Last updated:** 2026-09-20
**Version:** Alpha 0.8 recovery / web-parity restoration
