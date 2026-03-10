# CODEX TODO - MOMENTUM: FRACTURED

**Project:** Metroidvania combat platformer  
**Phase:** Combat prototype (Phase 2 complete, Phase 3 in progress)  
**Current Status:** Compile error blocking playtest  
**Reference:** See `GDD.md` for full game design

---

## PRIORITY 1: Fix Compile Error (BLOCKING)

**Issue:** Godot compile error preventing launch  
**Error:** `Invalid operands "Node" and "int" for ">" operator` at line 105, column 33

**Tasks:**
1. Open project in Godot 4.6+
2. Check Godot editor output panel for exact file path
3. Fix the type error (likely in `scripts/rooms/room_controller.gd` or `scripts/systems/*.gd`)
4. Common causes:
   - Comparing NodePath to int
   - Missing null check before comparison
   - Type mismatch in conditional
5. Test both scenes:
   - `scenes/combat_test.tscn` (3 enemies, simple room)
   - `scenes/rooms/room_01_combat.tscn` (full room flow)
6. Commit fix: `git commit -m "Fix: [describe the error and solution]"`
7. Push: `git push`

**Success criteria:** Game launches, player can move/attack, enemies take damage

---

## PRIORITY 2: Combat Polish (AFTER FIX)

**Goal:** Make combat feel good (referenced in GDD.md Section 5)

### Tasks:
- [ ] Tune attack damage (currently 15, enemies 50 HP = 4 hits)
- [ ] Adjust knockback strength (test feel)
- [ ] Add hit pause (0.05s freeze on hit for impact)
- [ ] Visual feedback:
  - [ ] Enemy flash white on hit
  - [ ] Damage numbers pop up
  - [ ] Screen shake on heavy hits
- [ ] Audio:
  - [ ] Attack swing sound
  - [ ] Hit impact sound
  - [ ] Enemy death sound
  - [ ] Door unlock sound

**Reference:** GDD.md Section 5.3 (Combat Feel)

**Test:** Defeat Echo enemy - does it feel satisfying?

---

## PRIORITY 3: Enemy AI Improvements

**Goal:** Echo enemy behavior (see GDD.md Section 6.1)

### Current State:
- Echo has patrol, alert, charge, attack states
- Basic melee attack
- 50 HP, dies in 4 hits

### Tasks:
- [ ] Test patrol behavior (walks between points)
- [ ] Implement player detection (200px range)
- [ ] Charge toward player when alerted
- [ ] Attack animation plays at 40px range
- [ ] Hitbox spawns during attack (deal 10 damage to player)
- [ ] Death animation (fade out, drop cells)
- [ ] Test hitstun (enemy pauses when hit)

**Reference:** GDD.md Section 6.1 (Echo - Basic Humanoid)

**Test:** Enemy should chase and attack, not just stand there

---

## PRIORITY 4: Room Creator Tool + 4 Base Rooms

**Goal:** Build room design workflow + 4 playable rooms

### Part A: Room Creator Tool

**Web-based editor exists:** https://laibyrinth.com/fractured-room-editor.html

**Tasks:**
- [ ] Test web room editor
  - Opens in browser
  - Can place platforms, enemies, hazards
  - Export to JSON works
- [ ] Create Godot import script
  - `tools/import_room_json.gd`
  - Reads JSON from web editor
  - Generates .tscn file automatically
  - Places platforms, spawn points, enemies, hazards
- [ ] OR: Create Godot editor plugin
  - Room design tool inside Godot editor
  - Drag-drop prefabs (platforms, enemies, hazards)
  - Snap to grid (10px)
  - Auto-generate collision shapes

**Deliverable:** Cap can design rooms in <5 minutes each

---

### Part B: Build 4 Rooms (REQUIRED)

**Room 1: Combat Arena** (already exists)
- [x] `room_01_combat.tscn`
- [x] 3 Echo enemies
- [x] Flat floor, basic walls
- [x] Door unlocks when cleared

**Room 2: Platforming Challenge** (NEW)
- [ ] `room_02_platforming.tscn`
- [ ] No enemies
- [ ] Hazards: Spikes (2 pits), Saws (1 rotating)
- [ ] Moving platforms (3 platforms, horizontal movement)
- [ ] Requires jump timing, no combat
- [ ] Exit to Room 3

**Room 3: Mixed Combat + Platforming** (NEW)
- [ ] `room_03_mixed.tscn`
- [ ] 2 Echo enemies on platforms
- [ ] 1 moving platform over spike pit
- [ ] Player must fight while platforming
- [ ] Exit to Room 4

**Room 4: Checkpoint Safe Room** (NEW)
- [ ] `room_04_checkpoint.tscn`
- [ ] No enemies, no hazards
- [ ] Checkpoint node (saves progress)
- [ ] Health refill station (optional)
- [ ] 2 exits:
  - Back to Room 1 (backtrack)
  - Forward to future Room 5 (locked for now)

**Reference:** GDD.md Section 3 (Room Structure)

**Test:** Complete all 4 rooms in sequence without dying

---

## PRIORITY 5: Checkpoint System

**Goal:** Save/load player progress

### Current State:
- `GameState` singleton exists
- `checkpoint.gd` script exists
- Not fully tested

### Tasks:
- [ ] Test checkpoint trigger (walk over Checkpoint node)
- [ ] Verify save location stored in GameState
- [ ] Die in Room 2 → respawn at last checkpoint
- [ ] Health/cells persist across rooms
- [ ] Player position restored correctly

**Reference:** GDD.md Section 8.1 (Save System)

**Test:** Die after checkpoint → respawn there, not at start

---

## PRIORITY 6: UI/HUD Improvements

**Goal:** Show player health, cells, combo counter

### Current State:
- Enemy counter exists (shows "3 enemies remaining")
- No health bar
- No cell counter

### Tasks:
- [ ] Add health bar (top-left)
  - Red fill, shows current/max HP
  - Updates on damage
- [ ] Add cell counter (top-right)
  - Shows total cells collected
  - Animates on pickup (+5)
- [ ] Add combo counter (center-top)
  - Shows hit streak
  - Fades out after 2 seconds
- [ ] Mini-map placeholder (bottom-right)
  - Just a static room icon for now

**Reference:** GDD.md Section 9 (UI/UX)

**Test:** Take damage → health bar updates. Kill enemy → cells increment.

---

## PRIORITY 7: More Enemy Types

**Goal:** Add 2nd enemy type (see GDD.md Section 6)

### Candidates (pick one):
- **Drone** (flying, ranged) - easier
- **Guardian** (armored, shield) - medium
- **Ninja** (fast, teleport) - harder

### Tasks (for chosen enemy):
- [ ] Create `scripts/enemies/[name].gd`
- [ ] Create `scenes/enemies/[name].tscn`
- [ ] Implement unique behavior (flying/blocking/dashing)
- [ ] Add to Room 1 (test 2 Echo + 1 new enemy)
- [ ] Balance HP/damage/speed

**Reference:** GDD.md Section 6 (Enemy Types)

**Recommendation:** Start with Drone (simpler AI)

**Test:** Mix of enemy types in one room, both killable

---

## PRIORITY 8: Ability Unlocks (Future)

**Goal:** Grapple Hook ability (see GDD.md Section 4)

### Tasks (NOT YET - after combat is solid):
- [ ] Design grapple mechanic
- [ ] Create grapple point nodes
- [ ] Add ability unlock trigger
- [ ] Test in platforming room
- [ ] Gate progression (can't reach Room X without grapple)

**Reference:** GDD.md Section 4 (Abilities)

**Note:** Save this for after core combat + room flow work

---

## WORKFLOW RULES

1. **Always test before committing**
   - Run the game, test changes
   - Check for errors in Godot output
   
2. **Commit often with clear messages**
   ```
   git add .
   git commit -m "Add: [what you added]"
   git push
   ```

3. **If stuck, check GDD.md**
   - Section numbers reference specific features
   - Design rationale explained there

4. **Playtest checklist:**
   - [ ] Game launches without errors
   - [ ] Player can move (WASD)
   - [ ] Player can jump (Space)
   - [ ] Player can attack (Left Click)
   - [ ] Enemies take damage and die
   - [ ] Doors unlock when room clears
   - [ ] Room transitions work

5. **Ask before major changes**
   - New systems not in GDD.md
   - Large refactors
   - Changing core mechanics

---

## CURRENT BLOCKERS

**Right now:** Compile error preventing launch  
**Fix this first** - everything else depends on a working game

---

## QUESTIONS FOR CAP

Post in Discord thread when you need:
- Design decisions not covered in GDD.md
- Asset choices (sprites, sounds)
- Clarification on priorities
- Approval for scope changes

---

## SUCCESS METRICS

**Phase 3 Complete (Current Goal):**
- [x] Combat system working
- [ ] Compile errors fixed
- [ ] **4 rooms built and playable**
- [ ] **Room creator tool functional**
- [ ] Checkpoint system functional
- [ ] Combat feels satisfying

**Phase 4 (Next):**
- More enemy types (Drone, Guardian)
- Better visuals (sprite replacements, animations)
- First boss fight (Echo Amalgam)
- Ability unlock (grapple hook)

---

**Last Updated:** 2026-03-10  
**Read GDD.md for full context**
