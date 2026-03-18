# BUG TEST CHECKLIST - MOMENTUM: FRACTURED

**Date:** 2026-03-18  
**Build:** Phase 3 Complete + Camera2D fix  
**Tester:** Codex

---

## Purpose

Comprehensive bug sweep before starting Phase 4 content creation.

**Goal:** Find and fix all blocking bugs, document minor issues for later.

---

## Testing Environment

### Setup:
```bash
cd ~/Documents/Playground/momentum-fractured
godot project.godot
```

### Test Scenes (in order):
1. `scenes/rooms/room_01_combat.tscn`
2. `scenes/rooms/room_02_platforming.tscn`
3. `scenes/rooms/room_03_mixed.tscn`
4. `scenes/rooms/room_04_checkpoint.tscn`
5. `scenes/combat_test.tscn` (legacy test scene)

---

## Test 1: Game Launch & Scene Loading

### Steps:
1. Launch Godot
2. Open each scene (File → Open Scene)
3. Run each scene (F6)
4. Check Godot Output panel for errors

### Expected Results:
- [ ] All scenes load without errors
- [ ] No script parse errors
- [ ] No "Invalid call" errors
- [ ] No "Cannot find node" warnings

### Known Issues:
- ~~Camera2D unproject_position error~~ ✅ FIXED (2026-03-18)

### If Failed:
- Screenshot error in Output panel
- Note which scene failed
- Note exact error message
- Fix before continuing

---

## Test 2: Player Movement & Controls

### Scene: `room_01_combat.tscn`

### Steps:
1. Run scene (F6)
2. Test all movement:
   - **WASD** - Move in 8 directions
   - **Space** - Jump (tap vs hold for variable height)
   - **Shift** - Dash (8 directions)
   - **Wall approach** - Wall slide triggers
   - **Jump while on wall** - Wall jump works

### Expected Results:
- [ ] Player moves smoothly in all directions
- [ ] Jump height varies with hold duration
- [ ] Dash has cooldown (~1 sec)
- [ ] Wall slide activates automatically
- [ ] Wall jump maintains momentum
- [ ] No stuttering or jittering
- [ ] Player sprite faces correct direction
- [ ] Animations play correctly (idle, run, jump, fall, dash, wall_slide)

### If Failed:
- Note which movement feels wrong
- Check if it's a control issue or animation issue
- Test on different room layouts

---

## Test 3: Combat System (Player Attacks)

### Scene: `room_01_combat.tscn`

### Steps:
1. Run scene
2. **Left Click** near enemy (without touching)
3. **Left Click** while touching enemy
4. Try 3-hit combo (click-click-click quickly)
5. Try attacks while jumping
6. Try attacks while dashing

### Expected Results:
- [ ] Attack animation plays on click
- [ ] Hitbox activates for ~0.15 sec
- [ ] Enemies take damage when hit (damage number appears)
- [ ] Attack cooldown prevents spam (~0.3 sec)
- [ ] 3-hit combo chains correctly
- [ ] Aerial attacks work
- [ ] Dash-attack works (dash + attack)
- [ ] Player can move while attacking

### Damage Check:
- [ ] Player attack = 15 damage
- [ ] Echo HP = 50 (dies in 4 hits)
- [ ] Drone HP = 30 (dies in 2 hits)
- [ ] Damage numbers appear above enemy
- [ ] Numbers fade out correctly

### If Failed:
- Check if hitbox is spawning
- Check if hurtbox is detecting hitbox
- Verify damage values in scripts

---

## Test 4: Enemy AI & Behavior

### Scene: `room_01_combat.tscn` (3 Echoes)

### Steps:
1. Run scene
2. Observe Echo behavior without attacking:
   - Do they patrol?
   - Do they detect player?
   - Do they chase player?
3. Attack one Echo, observe:
   - Hitstun (freeze on damage)
   - Health reduction
   - Death animation
   - Cell drop
4. Test multiple enemies:
   - Do all 3 Echoes behave independently?
   - Do they all attack?

### Expected Results:
- [ ] Echo patrols when idle
- [ ] Echo detects player in ~200px range
- [ ] Echo chases player when alerted
- [ ] Echo attacks when close (~40px)
- [ ] Echo enters hitstun when hit (0.3s freeze)
- [ ] Echo dies at 0 HP
- [ ] Echo plays death animation
- [ ] Echo drops cells on death
- [ ] All 3 Echoes work independently
- [ ] No AI gets stuck

### If Failed:
- Note specific AI state that's broken
- Check echo.gd state machine
- Check if collision shapes are correct

---

## Test 5: Drone Enemy (Ranged)

### Scene: `room_03_mixed.tscn` (has Drones)

### Steps:
1. Run scene
2. Observe Drone behavior:
   - Does it fly/hover?
   - Does it maintain distance from player?
   - Does it shoot projectiles?
3. Test projectile behavior:
   - Does projectile spawn?
   - Does it travel toward player?
   - Does it damage player on hit?
4. Kill Drone:
   - Can it be hit?
   - Does it die correctly?

### Expected Results:
- [ ] Drone hovers in air
- [ ] Drone maintains 6-8 tile distance
- [ ] Drone shoots when player is grounded
- [ ] Projectiles spawn correctly
- [ ] Projectiles travel toward player
- [ ] Projectiles damage player (5 damage)
- [ ] Projectiles despawn after missing
- [ ] Drone flees when player gets close
- [ ] Drone dies in 2 hits (30 HP)
- [ ] No projectile spam (cooldown works)

### If Failed:
- Check drone.gd AI
- Check drone_projectile.gd script
- Verify collision layers

---

## Test 6: Hazards & Environmental Damage

### Scene: `room_02_platforming.tscn` (hazards)

### Test Each Hazard Type:

#### 6a. Saws
- [ ] Saw blades rotate
- [ ] Contact with saw kills player instantly
- [ ] Player respawns at checkpoint after saw death

#### 6b. Lasers
- [ ] Laser beams visible
- [ ] Contact with laser damages player (10 dmg/sec)
- [ ] Player can pass through quickly without dying

#### 6c. Crushers
- [ ] Crusher moves up/down
- [ ] Crusher kills player when crushed
- [ ] Player can pass underneath safely when crusher is up

#### 6d. Fire Pits
- [ ] Fire pit flames animate
- [ ] Falling into fire kills player
- [ ] Player respawns at checkpoint

### If Failed:
- Check hazard_zone.gd script
- Verify collision shapes
- Check damage values

---

## Test 7: Moving Platforms

### Scene: `room_02_platforming.tscn`

### Steps:
1. Jump onto moving platform
2. Ride platform full path
3. Jump off platform mid-movement
4. Test all platform types (horizontal, vertical, circular)

### Expected Results:
- [ ] Platform moves smoothly
- [ ] Player sticks to platform (moves with it)
- [ ] Player can jump off at any time
- [ ] Platform doesn't push player through walls
- [ ] All platform patterns work (horizontal, vertical, circular)
- [ ] Path indicators visible (arrows)

### If Failed:
- Check platform script
- Verify CharacterBody2D platform interaction
- Check collision layers

---

## Test 8: Room Transitions & Door System

### Full Sequence Test:

#### Steps:
1. Start in Room 01
2. Kill all 3 Echoes
3. Observe door unlock
4. Walk into door
5. Verify fade transition
6. Verify Room 02 loads
7. Complete Room 02 (navigate hazards)
8. Exit to Room 03
9. Complete Room 03 (combat + hazards)
10. Exit to Room 04

### Expected Results:
- [ ] Doors lock when room starts (red barrier visible)
- [ ] Enemy counter shows "3 enemies remaining"
- [ ] Counter decrements when enemy dies
- [ ] Doors unlock when all enemies dead
- [ ] Unlock sound plays (door_unlock SFX)
- [ ] Walking into door triggers transition
- [ ] Screen fades out → fades in
- [ ] Next room loads correctly
- [ ] Player spawns at correct position
- [ ] No infinite load screens
- [ ] No crash during transition

### If Failed:
- Check room_controller.gd
- Check door_exit.gd
- Check scene_navigator.gd
- Verify target_scene paths are correct

---

## Test 9: Checkpoint & Save System

### Scene: `room_04_checkpoint.tscn`

### Steps:
1. Complete Rooms 01-03 to reach Room 04
2. Walk over checkpoint marker
3. Observe checkpoint activation:
   - Visual feedback (glow pulse)
   - Sound effect
   - HUD notification
4. Note current HP and cells
5. Press **F5** (reset) OR walk into hazard (die)
6. Verify respawn:
   - Player respawns at Room 04 checkpoint
   - HP restored
   - Cells retained
   - Cleared rooms still cleared

### Expected Results:
- [ ] Checkpoint triggers on overlap
- [ ] Checkpoint glow pulses
- [ ] Checkpoint sound plays
- [ ] HUD shows "Checkpoint saved"
- [ ] Health refill station works (free heal)
- [ ] Save persists across death
- [ ] Respawn puts player at checkpoint
- [ ] Cleared rooms don't respawn enemies
- [ ] Cell count preserved

### Persistence Test:
1. Save at checkpoint
2. Close Godot completely
3. Reopen project
4. Run Room 04 scene
5. Verify save loaded

### Expected:
- [ ] Save file exists (user://save_game.dat)
- [ ] Checkpoint location loaded
- [ ] Stats loaded (HP, cells, combo)
- [ ] Cleared rooms remembered

### If Failed:
- Check checkpoint.gd
- Check game_state.gd save/load functions
- Check save file path

---

## Test 10: HUD & UI

### Scene: Any room

### Steps:
1. Run scene
2. Check HUD elements:
   - Health bar (top-left)
   - Cell counter (top-right)
   - Combo display (center-top)
   - Enemy counter (top-center)

### Test Updates:
- [ ] Health bar shows correct HP (100 max)
- [ ] Health bar decreases when damaged
- [ ] Health bar increases when healed
- [ ] Cell counter shows 0 at start
- [ ] Cell counter increments when cell picked up
- [ ] Combo counter shows hit streak
- [ ] Combo counter resets after 2 sec
- [ ] Enemy counter shows correct count
- [ ] Enemy counter decrements on kill
- [ ] All text readable

### Pause Menu Test:
1. Press **Esc** during gameplay
2. Check pause menu options:
   - Resume
   - Save Game
   - New Game
   - Quit

### Expected:
- [ ] Game pauses (enemies freeze)
- [ ] Pause menu appears
- [ ] Resume works (unpause)
- [ ] Save Game works (manual save)
- [ ] New Game resets progress
- [ ] Quit exits to project manager

### If Failed:
- Check hud.gd
- Check pause_menu.gd
- Verify signal connections

---

## Test 11: Audio System

### Steps:
1. Run any combat room
2. Listen for SFX:
   - Attack swing
   - Hit impact
   - Enemy death
   - Door unlock
   - Checkpoint save
   - Cell pickup
   - Player damage

### Expected Results:
- [ ] Attack swing plays on click
- [ ] Hit impact plays when enemy hit
- [ ] Enemy death sound plays on death
- [ ] Door unlock sound plays when doors open
- [ ] Checkpoint sound plays on checkpoint
- [ ] Cell pickup sound plays on collect (NOT checkpoint sound)
- [ ] Player damage sound plays when hit
- [ ] No sound overlap/clipping
- [ ] Volume balanced (not too loud)

### Known Issues:
- Cell pickup uses wrong SFX (checkpoint sound) - **LOW PRIORITY**
- Door unlock replays on re-entry - **LOW PRIORITY**

### If No Sound:
- Check if AudioManager is loaded (AutoLoad)
- Check if placeholder SFX files exist
- Verify play_sfx() calls in scripts

---

## Test 12: Performance & Stability

### Stress Test:

#### Steps:
1. Run Room 03 (mixed enemies)
2. Spawn damage numbers (hit enemies repeatedly)
3. Trigger multiple hazards
4. Let game run for 5 minutes
5. Monitor Godot debugger (Debugger → Monitor tab)

### Check:
- [ ] FPS stays above 60
- [ ] Memory usage stable (no leaks)
- [ ] No gradual slowdown
- [ ] No random crashes
- [ ] Projectile pooling works (max 20 active)
- [ ] Damage number pooling works (max 12)
- [ ] Enemy AI culling works (enemies sleep when far)

### If Performance Issues:
- Check pooling systems
- Check for memory leaks (nodes not freed)
- Reduce particle effects
- Optimize enemy AI

---

## Test 13: Debug Commands (F5-F9)

### Test Each Hotkey:

#### F5 - Reset Progress
- [ ] Clears all save data
- [ ] Restarts at Room 01
- [ ] All rooms marked uncleared
- [ ] HP/cells reset to default

#### F6 - Respawn at Checkpoint
- [ ] Player respawns at saved checkpoint
- [ ] HP restored
- [ ] Works even without dying

#### F7 - Add Test Cells
- [ ] Adds +50 cells to counter
- [ ] Cell counter updates
- [ ] Can spam for testing

#### F8 - Set Checkpoint Here
- [ ] Sets checkpoint to current room
- [ ] Shows confirmation
- [ ] Respawn works after setting

#### F9 - Print Debug State
- [ ] Prints to Godot Output panel
- [ ] Shows current HP, cells, checkpoint
- [ ] Shows cleared rooms

### If Failed:
- Check debug_commands.gd
- Verify AutoLoad setup
- Check if hotkeys conflict with Godot defaults

---

## Test 14: Edge Cases & Exploits

### Test Weird Scenarios:

#### Attack Spam:
- [ ] Can't attack faster than cooldown
- [ ] No double-hit bugs

#### Movement Exploits:
- [ ] Can't dash through walls
- [ ] Can't clip out of room bounds
- [ ] Can't infinite wall jump

#### Enemy Bugs:
- [ ] Enemies don't get stuck in walls
- [ ] Dead enemies don't respawn
- [ ] Can't kill same enemy twice

#### Room Transitions:
- [ ] Can't enter door before unlock
- [ ] Can't spam door to duplicate scenes
- [ ] Can't leave room during combat

#### Save Exploits:
- [ ] Can't save during death animation
- [ ] Can't corrupt save file by closing mid-save

### If Found:
- Document exploit clearly
- Note reproduction steps
- Fix or add to backlog

---

## Test 15: Full Playthrough

### End-to-End Test:

#### Steps:
1. Close Godot, delete save file (user://save_game.dat)
2. Launch fresh
3. Start Room 01
4. Complete all 4 rooms in sequence
5. Time the playthrough
6. Count deaths
7. Note difficulty pain points

### Expected:
- [ ] Complete playthrough possible (no blocks)
- [ ] Average completion time: 5-10 minutes
- [ ] Deaths feel fair (not cheap)
- [ ] Difficulty curve smooth (gets harder gradually)
- [ ] No confusion about where to go
- [ ] Combat feels satisfying
- [ ] Movement feels responsive

### Difficulty Check:
- [ ] Echo enemies balanced (not too easy/hard)
- [ ] Drone enemies annoying but beatable
- [ ] Hazards telegraphed clearly
- [ ] Checkpoints placed well
- [ ] Not too punishing on death

---

## Bug Report Format

### For Each Bug Found:

```markdown
## BUG: [Short Description]

**Severity:** Critical / High / Medium / Low
**Scene:** [Which scene/room]
**Reproduction Steps:**
1. Step one
2. Step two
3. Bug occurs

**Expected:** [What should happen]
**Actual:** [What actually happens]
**Error Message:** [Copy from Output panel if any]

**Fix Priority:** Blocker / High / Medium / Low / Backlog
```

---

## Deliverables

After completing all tests:

### 1. Bug Report Document
Create `BUG_REPORT_2026-03-18.md`:
- List all bugs found
- Severity ratings
- Reproduction steps
- Suggested fixes (if known)

### 2. Test Results Summary
Create `TEST_RESULTS_2026-03-18.md`:
- Tests passed: X / 15
- Bugs found: X
- Critical bugs: X
- Playthrough time: X minutes
- Recommendation: Ready for Phase 4? Yes/No

### 3. Fixed Bugs (if any)
- Commit fixes with clear messages
- Push to GitHub
- Update bug report with "FIXED" status

---

## Success Criteria

**All tests PASS:**
- No critical bugs blocking gameplay
- Full playthrough possible
- Combat feels good
- Movement feels responsive
- Save/load works
- No crashes

**Phase 4 READY when:**
- 0 critical bugs
- 0-2 high-priority bugs (documented for later)
- Average playthrough successful
- Game feels satisfying to play

---

**Estimated Time:** 2-3 hours for full test sweep

**Start Testing!**
