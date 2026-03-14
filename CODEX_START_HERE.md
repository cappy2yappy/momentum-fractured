# 🎮 CODEX START HERE - MOMENTUM: FRACTURED

**Welcome back!** This document tells you exactly where the project is and what to work on next.

---

## 📊 Current Status (2026-03-14)

### ✅ Phase 3 Complete
- Combat system working (hitbox/hurtbox/health)
- 4 test rooms built and functional
- 2 enemy types (Echo, Drone)
- All core systems implemented
- Save/load working
- HUD complete

### 🎯 Phase 4 Goal
**Build Shibuya Crossing vertical slice**
- 12 total rooms (need 8 more)
- 3 enemy types (need Guardian)
- Mini-boss fight (Echo Amalgam)
- Audio (music + SFX)
- Visual polish (sprite upgrades)
- Tutorial system
- Ability unlock framework

---

## 📂 Key Documents (Read These)

### MUST READ (in order):
1. **`GDD.md`** - Full game design document (vision, mechanics, all 6 biomes)
2. **`PHASE_4_TASKS.md`** - Your work queue (10 tasks, prioritized)
3. **`OVERNIGHT_REPORT.md`** - What was completed last session
4. **`PLAYTEST_REPORT_2026-03-12.md`** - Known issues to fix

### Reference Docs:
- `DESIGN_UPDATE.md` - Metroidvania structure explanation
- `ENEMY_ASSETS.md` - Where to find sprites
- `ASSET_GUIDE.md` - Asset sourcing guide

---

## 🚀 What To Do Next

### Immediate Priority: TASK 1 (Guardian Enemy)
**File:** `PHASE_4_TASKS.md` → Task 1  
**Effort:** 2-4 hours  
**Why:** Need enemy variety for interesting encounters

**Implementation:**
1. Create `scripts/enemies/guardian.gd`
2. Create `scenes/enemies/guardian.tscn`
3. Implement shield blocking (frontal attacks = 0 damage)
4. Add to Room 03 for testing

**Success:** Guardian blocks frontal attacks, vulnerable from behind

---

## 🗺️ Project Structure

```
momentum-fractured/
├── GDD.md                    ← Full game design
├── PHASE_4_TASKS.md          ← Your work queue
├── OVERNIGHT_REPORT.md       ← Last session summary
├── assets/
│   ├── sprites/
│   │   ├── kaze/             ← Player sprites (from M0M3NTUM)
│   │   └── enemies/          ← Enemy placeholders (upgrade later)
│   └── audio/                ← Empty (Task 6)
├── scenes/
│   ├── kaze.tscn             ← Player character
│   ├── enemies/
│   │   ├── echo.tscn         ✅ Basic melee enemy
│   │   └── drone.tscn        ✅ Flying ranged enemy
│   ├── hazards/              ✅ Saw, laser, crusher, fire
│   ├── rooms/
│   │   ├── room_01_combat.tscn       ✅
│   │   ├── room_02_platforming.tscn  ✅
│   │   ├── room_03_mixed.tscn        ✅
│   │   └── room_04_checkpoint.tscn   ✅
│   └── ui/                   ✅ HUD, pause menu
├── scripts/
│   ├── player/
│   │   └── kaze_base.gd      ← Player movement + combat
│   ├── enemies/
│   │   ├── echo.gd           ← Patrol/chase/attack AI
│   │   └── drone.gd          ← Flying + projectile AI
│   ├── combat/
│   │   ├── health.gd         ← HP tracking
│   │   ├── hitbox.gd         ← Damage dealing
│   │   └── hurtbox.gd        ← Damage receiving
│   ├── rooms/
│   │   ├── room_controller.gd   ← Door lock/unlock logic
│   │   ├── checkpoint.gd        ← Save point
│   │   ├── door_exit.gd         ← Room transitions
│   │   └── hazard_zone.gd       ← Instant death zones
│   ├── systems/
│   │   ├── game_state.gd        ← Save/load (AutoLoad)
│   │   ├── audio_manager.gd     ← Sound system (AutoLoad)
│   │   ├── scene_navigator.gd   ← Transitions (AutoLoad)
│   │   └── debug_commands.gd    ← F5-F9 hotkeys
│   └── ui/
│       ├── hud.gd            ← Health/cells/combo display
│       └── pause_menu.gd     ← Save/resume/quit
└── tools/
    └── (room editor lives on web)
```

---

## 🎮 How To Test

### Launch Game:
```bash
cd ~/Documents/Playground/momentum-fractured
godot project.godot
```

### Play Test Sequence:
1. Open `scenes/rooms/room_01_combat.tscn` in Godot
2. Press **F6** (Run Current Scene)
3. Controls:
   - **WASD** - Move
   - **Space** - Jump
   - **Shift** - Dash
   - **Left Click** - Attack
   - **Esc** - Pause menu
4. Kill all 3 Echoes → doors unlock → walk to exit
5. Continue through Room 02 → 03 → 04

### Debug Hotkeys (F5-F9):
- **F5** - Reset all progress, restart
- **F6** - Respawn at checkpoint
- **F7** - Add +50 cells (testing)
- **F8** - Set checkpoint here
- **F9** - Print debug state to console

---

## ✅ Testing Checklist (Before Committing)

Run these checks after every change:

- [ ] Game launches without errors
- [ ] Player can move, jump, attack
- [ ] Enemies appear and can be damaged
- [ ] Doors unlock after killing all enemies
- [ ] Room transitions work (fade in/out)
- [ ] Checkpoints save correctly
- [ ] Death respawns at checkpoint
- [ ] HUD updates (health, cells, combo)
- [ ] No console errors (check Godot output panel)

---

## 📝 Git Workflow

### Standard workflow:
```bash
# Pull latest
git pull

# Make changes, test thoroughly

# Stage and commit
git add .
git commit -m "Add: [what you added]"
# Examples:
#   "Add: Guardian enemy with shield blocking"
#   "Fix: Cell pickup SFX (was using checkpoint sound)"
#   "Polish: Enemy hit flash + damage numbers"

# Push
git push
```

### For larger features (optional):
```bash
# Create feature branch
git checkout -b task-1-guardian

# Work, commit, test

# Merge back to main
git checkout main
git merge task-1-guardian
git push

# Delete branch
git branch -d task-1-guardian
```

---

## 🐛 Known Issues (From Playtest)

### Low Priority:
1. **Cell pickup uses wrong SFX**
   - Location: `scripts/pickups/cell_pickup.gd`
   - Issue: Calls `AudioManager.play_sfx("checkpoint")` instead of `"cell_pickup"`
   - Fix: Change to correct SFX name (after adding audio files)

2. **Door unlock sound replays on re-entry**
   - Location: `scripts/rooms/room_controller.gd`
   - Issue: `_unlock_doors()` always plays sound, even for already-cleared rooms
   - Fix: Add check to only play sound on first unlock

---

## 💡 Design Principles (Keep These In Mind)

From GDD.md:

1. **Precision movement** - Tight controls, responsive
2. **Room-to-room combat** - Each room = self-contained encounter
3. **Fair difficulty** - Telegraphed attacks, clear hazards
4. **Metroidvania progression** - Abilities unlock new areas
5. **Tokyo Noir aesthetic** - Dark, neon, cyberpunk

**Every decision should support these pillars.**

---

## 📞 When To Ask Questions

Post in Discord thread if:
- Design decision not covered in GDD.md
- Unsure about priority (what to work on next)
- Technical blocker (can't figure out how to implement something)
- Need approval for scope change

**Before asking:** Check GDD.md, PHASE_4_TASKS.md, OVERNIGHT_REPORT.md

---

## 🎯 Success Criteria (Phase 4 Complete)

Phase 4 is DONE when:
- [ ] 12 rooms built (Shibuya Crossing complete)
- [ ] 3 enemy types functional (Echo, Drone, Guardian)
- [ ] Echo Amalgam boss fight working
- [ ] Tutorial system guides new players
- [ ] Music and SFX play correctly
- [ ] Sprites upgraded (less placeholder art)
- [ ] Full playthrough possible (Room 01 → Room 12)
- [ ] Game feels satisfying to play

**Timeline:** 2-3 weeks (35-50 hours)

---

## 📚 Quick Reference

**Combat damage:**
- Player attack: 15 damage
- Echo HP: 50 (4 hits to kill)
- Drone HP: 30 (2 hits to kill)
- Guardian HP: 100 (7 hits to kill)

**Player stats:**
- HP: 100
- Speed: (current value, feel-based)
- Jump height: (current value)

**Hazards:**
- Spikes/Fire/Crushers: Instant death → respawn
- Lasers: 10 damage/sec

**Checkpoints:**
- Room 04 (after 3 rooms)
- Room 09 (before boss)

---

## 🚀 Ready To Start?

1. **Read `PHASE_4_TASKS.md`** (full task list)
2. **Start with Task 1** (Guardian enemy)
3. **Test frequently** (after every change)
4. **Commit often** (clear messages)
5. **Work through tasks in order** (1 → 10)

**You've got this!** The foundation is solid. Now we're building content.

---

**Last updated:** 2026-03-14  
**Phase:** 4 (Shibuya Vertical Slice)  
**Next Task:** Guardian Enemy (Task 1)
