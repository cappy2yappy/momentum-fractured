# PHASE 4 TASKS - Shibuya Biome Vertical Slice

**Goal:** Complete the Shibuya Crossing biome (first playable zone)  
**Target:** 10-15 connected rooms, 2-3 enemy types, mini-boss fight  
**Timeline:** 2-3 weeks  
**Reference:** GDD.md Section 6.1 (Shibuya Crossing)

---

## Current Status (Phase 3 Complete ✅)

### ✅ What Works
- Combat system (hitbox/hurtbox/health)
- 4 test rooms (combat → platforming → mixed → checkpoint)
- 2 enemy types (Echo, Drone)
- Hazards (saw, laser, crusher, fire)
- Room transitions with fade
- Checkpoint save/load system
- HUD (health bar, cell counter, combo display)
- Pause menu (save, resume, new game)
- Cell pickups and drops
- Audio system foundation (no sounds yet)
- Performance optimization (pooling, AI culling)

### ❌ What's Missing for Vertical Slice
- **6-11 more rooms** (need 10-15 total for Shibuya)
- **1 more basic enemy type** (Guardian or Ninja)
- **Mini-boss fight** (Echo Amalgam)
- **Ability unlock system** (framework, even if no abilities yet)
- **Real sprites** (currently using placeholders)
- **Music and SFX** (silent right now)
- **Tutorial messaging** (teach controls to new players)
- **Room variety** (different layouts, encounter types)

---

## Priority Tasks (In Order)

### TASK 1: Guardian Enemy (Armored Tank)
**Why:** Need enemy variety for interesting combat encounters  
**Effort:** Medium (2-4 hours)

**Implementation:**
1. Create `scripts/enemies/guardian.gd`
2. Create `scenes/enemies/guardian.tscn`
3. Stats:
   - HP: 100 (2× Echo's 50)
   - Speed: 40% of Kaze (very slow)
   - Damage: 8 (shield bash) + 15 (heavy slash)
4. Behavior:
   - **Idle:** Holds shield forward (blocks frontal attacks)
   - **Alert:** Slowly approaches player
   - **Attack:** Shield bash (close range) or heavy slash (wind-up)
   - **Defense:** Takes 0 damage from frontal attacks (must hit from behind)
   - **Enrage:** Drops shield at 30% HP, faster attacks
5. Visual:
   - Use placeholder sprite (48×56, orange/gold color)
   - Add shield indicator (simple rectangle in front)
6. Integration:
   - Add 1 Guardian to Room 03 (mixed combat)
   - Test: Player must circle behind to damage

**Success Criteria:**
- Guardian blocks frontal attacks
- Player can damage from behind or sides
- Dies in ~7-8 hits from behind (100 HP ÷ 15 damage)

**Reference:** GDD.md Section 6.2 (Guardian)

---

### TASK 2: Room Design Batch (Rooms 5-10)
**Why:** Need more content for Shibuya biome  
**Effort:** High (6-10 hours)

**Build 6 new rooms:**

#### Room 05: Vertical Combat Arena
- **Type:** Combat
- **Layout:** Tall room (3 platforms at different heights)
- **Enemies:** 2 Echoes (ground level) + 2 Drones (flying)
- **Challenge:** Must jump between platforms while fighting
- **Exit:** Top platform door to Room 06

#### Room 06: Hazard Gauntlet
- **Type:** Platforming
- **Layout:** Horizontal spike pit with moving platforms
- **Hazards:** 3 saw blades, 2 laser grids
- **No enemies**
- **Challenge:** Precise jump timing
- **Exit:** Right side to Room 07

#### Room 07: Guardian Introduction
- **Type:** Combat (tutorial for Guardian)
- **Layout:** Medium arena, two levels
- **Enemies:** 1 Guardian + 1 Echo
- **Challenge:** Learn to attack from behind
- **Note:** First Guardian encounter (should feel difficult)
- **Exit:** Left side to Room 08

#### Room 08: Mixed Mayhem
- **Type:** Mixed Combat + Platforming
- **Layout:** Platforms over fire pits
- **Enemies:** 3 Echoes + 1 Drone
- **Hazards:** Fire pits, one crusher
- **Challenge:** Fight while avoiding hazards
- **Exit:** Top exit to Room 09

#### Room 09: Breather Room
- **Type:** Safe Room (checkpoint)
- **Layout:** Small, peaceful
- **Features:** Checkpoint node, health refill station
- **No enemies, no hazards**
- **Exits:** Back to Room 08, forward to Room 10
- **Note:** Last checkpoint before mini-boss

#### Room 10: Boss Arena (Pre-Boss)
- **Type:** Combat Arena
- **Layout:** Large circular room, flat floor
- **Enemies:** 4 Echoes (warmup fight)
- **Note:** Prepares player for Echo Amalgam boss
- **Exit:** Locked door to Room 11 (boss room) - requires key item OR all enemies cleared

**Deliverable:** 6 new .tscn files in `scenes/rooms/`

**Success Criteria:**
- All rooms loadable without errors
- Room transitions work (doors trigger scene change)
- Enemy spawns work
- Hazards kill player → respawn at checkpoint

**Reference:** GDD.md Section 6.1 (Shibuya structure), Section 9 (Room Types)

---

### TASK 3: Echo Amalgam Mini-Boss
**Why:** Shibuya needs a climax encounter  
**Effort:** High (6-8 hours)

**Design:**
- **Concept:** Multiple Echoes fused into one larger entity
- **Arena:** Room 11 (boss room) - large, flat, no hazards
- **HP:** 300 (6× Echo HP)
- **Phases:**
  - **Phase 1 (100-300 HP):** Spawns 2 Echoes, they attack normally
  - **Phase 2 (50-100 HP):** Fuses into single entity, faster attacks
  - **Phase 3 (<50 HP):** Enraged, dashes around room, harder to hit

**Attacks:**
- **Swarm Dash:** Amalgam dashes across room (telegraphed, 20 damage)
- **Echo Spawn:** Spawns 1-2 Echoes that fight independently
- **Ground Slam:** AoE attack (player must jump to avoid, 25 damage)

**Visual:**
- Larger Echo sprite (2× size, glitchy/distorted)
- Particle effects (optional, keep simple)

**Implementation:**
1. Create `scripts/enemies/echo_amalgam.gd`
2. Create `scenes/enemies/echo_amalgam.tscn`
3. Create `scenes/rooms/room_11_boss.tscn`
4. Boss behavior state machine:
   - `PHASE_1` → spawn adds
   - `PHASE_2` → fuse, dash attacks
   - `PHASE_3` → enrage, faster movement
5. On death:
   - Drop 100 cells
   - Unlock door to Room 12 (exit)
   - Trigger victory message (HUD notification)

**Success Criteria:**
- Boss fight feels challenging but fair
- All 3 phases work
- Victory unlocks exit
- Player respawns at Room 09 checkpoint if they die

**Reference:** GDD.md Section 6.1.4 (Echo Amalgam boss)

---

### TASK 4: Tutorial Messaging System
**Why:** New players need to learn controls  
**Effort:** Medium (3-4 hours)

**Implementation:**
1. Create `scripts/ui/tutorial_popup.gd`
2. Create `scenes/ui/tutorial_popup.tscn`
   - Simple text box (center-bottom of screen)
   - Background: semi-transparent black
   - Text: white, readable font
   - Auto-dismisses after 5 seconds OR on player action
3. Tutorial triggers in Room 01:
   - **On spawn:** "WASD to move, SPACE to jump"
   - **Near first enemy:** "Left Click to attack"
   - **After first kill:** "Defeat all enemies to unlock doors"
   - **After room clear:** "Walk into the door to continue"
4. Tutorial triggers in Room 02:
   - **Near first hazard:** "Avoid hazards or respawn at checkpoint"
5. Tutorial triggers in Room 04:
   - **Near checkpoint:** "Checkpoints save your progress"
6. Tutorial triggers in Room 07:
   - **Near Guardian:** "Some enemies block frontal attacks - attack from behind"

**Storage:**
- Save which tutorials have been shown in GameState
- Don't repeat tutorials on respawn/reload

**Success Criteria:**
- Tutorials appear at correct moments
- Text is readable
- Player can dismiss early (optional)
- Tutorials don't show again after first time

**Reference:** GDD.md Section 6.1.1 (Tutorial features)

---

### TASK 5: Ability Unlock Framework
**Why:** Needed for Metroidvania progression (even if no abilities active yet)  
**Effort:** Medium (3-5 hours)

**Implementation:**
1. Create `scripts/systems/ability_manager.gd` (AutoLoad singleton)
   ```gdscript
   var unlocked_abilities = {
       "grapple": false,
       "dash": false,
       "double_jump": false,
       "slide": false
   }
   
   func unlock_ability(ability_name: String):
       unlocked_abilities[ability_name] = true
       emit_signal("ability_unlocked", ability_name)
       # Show HUD notification
   
   func has_ability(ability_name: String) -> bool:
       return unlocked_abilities.get(ability_name, false)
   ```

2. Create `scripts/rooms/ability_unlock_trigger.gd`
   - Area2D node that triggers on player overlap
   - Plays unlock animation/sound
   - Calls `AbilityManager.unlock_ability("grapple")`
   - Disables itself after activation

3. Create `scenes/rooms/ability_unlock_trigger.tscn`
   - Visual: Glowing pickup icon (placeholder sprite)
   - Collision shape for detection

4. Place ability unlock in Room 12 (after boss):
   - **Grapple Hook unlock** (even though grapple isn't implemented yet)
   - Shows notification: "Grapple Hook unlocked!"
   - Player can't use it yet (placeholder for future)

5. Update `GameState` to save/load unlocked abilities

**Success Criteria:**
- Ability unlock trigger works
- Notification appears on unlock
- Unlocked state persists across save/load
- Can check `has_ability()` from other scripts

**Reference:** GDD.md Section 7 (Progression System)

---

### TASK 6: Real Audio (Music + SFX)
**Why:** Game feels lifeless without sound  
**Effort:** Medium (4-6 hours)

**Implementation:**

#### Part A: Find Free Audio Assets
**Sources:**
- **Music:** freemusicarchive.org, incompetech.com (Kevin MacLeod), opengameart.org
- **SFX:** freesound.org, kenney.nl/assets/impact-sounds

**What to get:**
- **Music tracks:**
  - `combat_theme.ogg` - Synthwave/electronic, 120-140 BPM, looping
  - `exploration_theme.ogg` - Ambient, calm, looping
  - `boss_theme.ogg` - Intense, fast-paced, looping
- **SFX:**
  - `attack_swing.wav` - Whoosh sound
  - `hit_impact.wav` - Punch/thud
  - `enemy_death.wav` - Explosion or fade-out
  - `door_unlock.wav` - Mechanical click
  - `checkpoint.wav` - Soft chime
  - `cell_pickup.wav` - Coin pickup sound
  - `damage_taken.wav` - Player hurt sound

#### Part B: Integrate into AudioManager
1. Add audio files to `assets/audio/music/` and `assets/audio/sfx/`
2. Update `scripts/systems/audio_manager.gd`:
   - Map SFX names to file paths
   - Add `play_music(track_name)` function
3. Wire up SFX calls:
   - Player attack → `play_sfx("attack_swing")`
   - Hit enemy → `play_sfx("hit_impact")`
   - Enemy dies → `play_sfx("enemy_death")`
   - Door unlocks → `play_sfx("door_unlock")`
   - Checkpoint → `play_sfx("checkpoint")`
   - Cell pickup → `play_sfx("cell_pickup")` (NOT checkpoint sound)
   - Player damaged → `play_sfx("damage_taken")`
4. Add music zones:
   - Rooms 1-10 → `play_music("combat_theme")` when enemies alive, `exploration_theme` when cleared
   - Room 11 (boss) → `play_music("boss_theme")`
   - Room 4, 9 (safe rooms) → `play_music("exploration_theme")`

**Success Criteria:**
- Music plays and loops correctly
- SFX trigger at correct moments
- Audio doesn't overlap/clip
- Volume is balanced (SFX not louder than music)

**Reference:** GDD.md Section 3.5 (Audio), PLAYTEST_REPORT (cell pickup SFX issue)

---

### TASK 7: Visual Polish Pass
**Why:** Game looks too bare with placeholder art  
**Effort:** Medium-High (5-8 hours)

**Implementation:**

#### Part A: Enemy Sprite Upgrades
**Option 1: Buy Ninja Adventure Pack ($0, FREE on itch.io)**
- Download from https://pixel-boy.itch.io/ninja-adventure-asset-pack
- Extract sprites for Echo replacement
- Import 4-frame idle, 6-frame walk, 4-frame attack animations
- Update `scenes/enemies/echo.tscn` AnimatedSprite2D

**Option 2: Use Kenney assets (FREE)**
- Download from kenney.nl
- Use for Guardian placeholder upgrade

**Tasks:**
1. Download and extract sprite packs
2. Copy relevant sprites to `assets/sprites/enemies/`
3. Update AnimatedSprite2D nodes in enemy scenes
4. Adjust collision shapes to match new sprite sizes
5. Test combat with new sprites

#### Part B: Kaze Animation Improvements
**Current state:** Kaze has basic animations  
**Add:**
- Hurt animation (damage reaction)
- Death animation (fall and fade)
- Land animation (landing from jump, brief squat)
- Crouch animation (for future slide ability)

**Tasks:**
1. Extract frames from existing M0M3NTUM assets
2. Add to `assets/sprites/kaze/`
3. Wire up in `scenes/kaze.tscn`
4. Connect to player script triggers (on_damage, on_death, on_land)

#### Part C: Environment Tilesets
**Current state:** Rooms use solid color rectangles for walls/floors  
**Add:**
- Basic tileset (8×8 or 16×16 tiles)
- Wall tiles, floor tiles, background tiles
- Neon aesthetic (dark with colored accents)

**Sources:**
- Kenney.nl tileset packs (FREE)
- OpenGameArt cyberpunk tilesets (CC-BY)
- Create simple tiles in Aseprite if needed

**Tasks:**
1. Download/create tileset
2. Import to Godot as TileSet resource
3. Update Room 01-11 to use TileSet instead of ColorRect
4. Add background layer (parallax optional, keep simple)

**Success Criteria:**
- Enemies no longer look like colored rectangles
- Kaze has smooth animations for all actions
- Rooms have visual depth (walls, floors, background)

**Reference:** GDD.md Section 2.5 (Aesthetic), ENEMY_ASSETS.md

---

### TASK 8: Room Interconnection Map
**Why:** Need to verify room flow makes sense  
**Effort:** Low (1-2 hours)

**Implementation:**
1. Create `ROOM_MAP.md` documenting room layout:
   ```
   Shibuya Crossing - Room Layout

   Room 01 (Combat) → Room 02 (Platforming)
   Room 02 → Room 03 (Mixed)
   Room 03 → Room 04 (Checkpoint)
   Room 04 → Room 05 (Vertical Combat)
   Room 05 → Room 06 (Hazard Gauntlet)
   Room 06 → Room 07 (Guardian Intro)
   Room 07 → Room 08 (Mixed Mayhem)
   Room 08 → Room 09 (Checkpoint)
   Room 09 → Room 10 (Pre-Boss)
   Room 10 → Room 11 (Boss Fight)
   Room 11 → Room 12 (Victory / Ability Unlock)
   ```

2. Add room descriptions (enemy count, hazards, exits)
3. Verify all doors are correctly wired:
   - Check `door_exit.gd` target_scene paths
   - Test each transition manually
   - Ensure no dead ends or circular loops (unless intended)

**Success Criteria:**
- Complete playthrough from Room 01 → Room 12 without breaks
- All doors lead to correct next room
- Checkpoints are placed sensibly (every 3-5 rooms)

---

### TASK 9: Balance Pass
**Why:** Game might be too easy or too hard  
**Effort:** Medium (3-5 hours of playtesting + tuning)

**Metrics to tune:**

#### Player Stats:
- **Starting HP:** 100 (enough? too much?)
- **Attack damage:** 15 (how many hits to kill Echo? Guardian?)
- **Movement speed:** Current value (feels good?)
- **Jump height:** Current value (can reach platforms?)

#### Enemy Stats:
- **Echo HP:** 50 (dies in ~4 hits, good?)
- **Echo damage:** 10 (how many hits before player dies?)
- **Guardian HP:** 100 (dies in ~7 hits, feels tanky enough?)
- **Guardian damage:** 8 bash / 15 slash (fair?)
- **Drone HP:** 30 (too fragile?)
- **Drone damage:** 5 per shot (chip damage, annoying but not deadly?)

#### Hazards:
- **Instant death:** Spikes, fire pits, crushers (too punishing?)
- **Damage over time:** Lasers (10 damage/sec, feels fair?)

#### Checkpoints:
- **Frequency:** Every 3-5 rooms (Room 04, Room 09 currently)
- **Too sparse?** Add checkpoint in Room 07 after Guardian intro?

**Tasks:**
1. Playtest full Shibuya biome (Room 01 → Room 12)
2. Track:
   - How many times you die
   - Which rooms feel too hard/easy
   - How long each room takes
3. Adjust stats based on feel:
   - If dying too much → increase player HP or reduce enemy damage
   - If too easy → add more enemies or increase their HP
   - If rooms feel empty → add more enemy variety
4. Test again after changes
5. Document final values in `BALANCE_NOTES.md`

**Success Criteria:**
- Average player can complete Shibuya in 15-20 minutes
- Deaths feel fair (not cheap or frustrating)
- Boss fight is challenging but beatable after 2-3 attempts

**Reference:** GDD.md Section 8 (Combat System balance)

---

### TASK 10: Build Victory/Ending for Vertical Slice
**Why:** Need a satisfying endpoint for demo  
**Effort:** Low-Medium (2-3 hours)

**Implementation:**

#### Room 12: Victory Room
- **Type:** Safe Room
- **Layout:** Small, peaceful, lit differently (lighter/brighter than rest)
- **Features:**
  - Ability unlock pedestal (Grapple Hook icon)
  - Victory message ("Shibuya Crossing Complete!")
  - Stats display (rooms cleared, cells collected, deaths, time)
  - Exit door (leads to Hub - not built yet, shows "To be continued...")

**Create:**
1. `scenes/rooms/room_12_victory.tscn`
2. `scripts/ui/victory_screen.gd`
   - Shows stats from GameState
   - "Continue" button → returns to main menu OR Room 01 (for now)
   - "Quit" button → exit game

**Success Criteria:**
- Beating Echo Amalgam unlocks Room 12
- Victory screen shows correctly
- Stats are accurate (track in GameState during playthrough)

---

## Testing Checklist (Phase 4 Complete)

After all tasks done, verify:

- [ ] Game launches without errors
- [ ] Full playthrough possible (Room 01 → Room 12)
- [ ] All enemy types appear and function (Echo, Drone, Guardian, Boss)
- [ ] All hazards work (spikes, saws, lasers, crushers, fire)
- [ ] Checkpoints save/load correctly
- [ ] Death respawns at correct checkpoint
- [ ] HUD updates correctly (health, cells, combo)
- [ ] Doors unlock/lock as expected
- [ ] Tutorials appear for new players
- [ ] Audio plays (music + SFX)
- [ ] Sprites are upgraded (not all placeholders)
- [ ] Boss fight is beatable
- [ ] Victory screen appears after boss
- [ ] Game feels satisfying to play

---

## Deliverables Summary

**By end of Phase 4:**
1. ✅ 12 total rooms (Shibuya Crossing complete)
2. ✅ 3 enemy types (Echo, Drone, Guardian)
3. ✅ 1 boss fight (Echo Amalgam)
4. ✅ Tutorial system
5. ✅ Ability unlock framework
6. ✅ Music and SFX
7. ✅ Improved visuals (sprite upgrades)
8. ✅ Balance pass (tuned difficulty)
9. ✅ Victory screen

**Result:** Playable vertical slice ready for external playtesting

---

## Workflow

**How to work on these tasks:**

1. **Read this entire document first**
2. **Prioritize in order** (Task 1 → Task 10)
3. **Work in feature branches** (optional but recommended):
   ```bash
   git checkout -b task-1-guardian
   # work on Task 1
   git add .
   git commit -m "Add Guardian enemy with shield blocking"
   git push -u origin task-1-guardian
   # merge when done
   git checkout main
   git merge task-1-guardian
   git push
   ```
4. **Test frequently** (after every major change)
5. **Commit often** with clear messages
6. **Update this file** as you complete tasks (check boxes, add notes)

**Questions?**
- Check `GDD.md` first
- Post in Discord thread if stuck
- Document decisions in `DESIGN_NOTES.md`

---

## Time Estimate

**Total effort:** 35-50 hours  
**Timeline:** 2-3 weeks (15-20 hours/week)

**Breakdown:**
- Task 1 (Guardian): 3 hours
- Task 2 (6 rooms): 8 hours
- Task 3 (Boss): 7 hours
- Task 4 (Tutorial): 3 hours
- Task 5 (Abilities): 4 hours
- Task 6 (Audio): 5 hours
- Task 7 (Visuals): 6 hours
- Task 8 (Map): 2 hours
- Task 9 (Balance): 4 hours
- Task 10 (Victory): 3 hours

**Contingency:** +10 hours for bugs, polish, iteration

---

## Success Metrics

**Phase 4 is COMPLETE when:**
- Someone who has never played can pick it up and complete Shibuya biome
- Combat feels satisfying
- Difficulty feels fair
- Audio/visuals are polished enough for public demo
- No major bugs or crashes
- Playthrough takes 15-25 minutes

**Next Phase (Phase 5):**
- Build Temple District biome (15-20 rooms)
- Add Guardian improvements
- Implement Grapple Hook ability
- Add Kitsune Matriarch boss
- More enemy types (Ninja?)

---

**Document created:** 2026-03-14  
**Phase:** 4 (Vertical Slice)  
**Status:** Ready to start

Read `GDD.md` for design context.  
Read `OVERNIGHT_REPORT.md` for what's already done.  
Read `PLAYTEST_REPORT_2026-03-12.md` for known issues.
