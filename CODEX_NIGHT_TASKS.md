# CODEX OVERNIGHT TASKS

**Start time:** 2026-03-11 ~2am EST  
**Expected duration:** 6-8 hours  
**Goal:** Implement Priorities 5-7 from CODEX_TODO.md + GDD expansions

---

## TASK 1: Checkpoint System (Priority 5)

**Status:** Checkpoint script exists, needs testing + polish

### Sub-tasks:
- [ ] Test checkpoint in room_04_checkpoint.tscn
  - Walk over checkpoint
  - Verify GameState.set_checkpoint() called
  - Check console output
- [ ] Die in Room 2 → should respawn at Room 4 checkpoint
- [ ] Add visual feedback:
  - Checkpoint glow effect (AnimatedSprite2D)
  - "Checkpoint saved" UI notification (fade in/out)
  - Audio cue (short ping sound)
- [ ] Test persistence:
  - Reach checkpoint
  - Close game
  - Reopen → should spawn at checkpoint
- [ ] Add health refill station in Room 4
  - Separate Area2D node
  - On trigger: restore player to max HP
  - Visual feedback (healing particles)
  - One-time use per room visit

**Reference:** GDD.md Section 8.1

**Test:** Die in any room after checkpoint → respawn there with full health

**Commit:** "Implement checkpoint save/load with visual feedback"

---

## TASK 2: UI/HUD System (Priority 6)

**Status:** Enemy counter exists, needs health bar + cell counter

### Sub-tasks:

#### Health Bar (Top-Left)
- [ ] Create `scenes/ui/health_bar.tscn`
  - Progress bar or custom TextureRect
  - Red fill, gray background
  - Shows current/max HP (e.g., "75/100")
- [ ] Connect to player Health component
  - Listen to health_changed signal
  - Update bar fill in real-time
- [ ] Add to HUD scene
  - Position: (20, 20)
  - Size: 200×30 pixels
- [ ] Test: Take damage → bar decreases

#### Cell Counter (Top-Right)
- [ ] Create `scenes/ui/cell_counter.tscn`
  - Label showing total cells
  - Icon (yellow coin sprite or emoji)
- [ ] Connect to GameState.cells_changed signal
- [ ] Animate on pickup:
  - +5 floats up and fades
  - Counter flashes briefly
- [ ] Add to HUD
  - Position: (1060, 20)
  - Right-aligned
- [ ] Test: Kill enemy → +5 cells, counter updates

#### Combo Counter (Center-Top)
- [ ] Track consecutive hits without taking damage
- [ ] Display when combo ≥ 2
  - "2 HIT COMBO!"
  - "5 HIT COMBO!"
  - "10 HIT COMBO!" (different color)
- [ ] Fade out after 2 seconds of no hits
- [ ] Reset on player damage
- [ ] Bonus: Combo multiplier for cell drops
  - 2x at 5 combo
  - 3x at 10 combo

#### Mini-Map Placeholder
- [ ] Static room icon (bottom-right)
- [ ] Shows current room name
- [ ] Position: (1050, 650)
- [ ] Just a placeholder for now (no actual map)

**Reference:** GDD.md Section 9

**Test:** Full UI visible, all elements update correctly

**Commit:** "Add health bar, cell counter, combo system UI"

---

## TASK 3: Enemy Type #2 - Drone (Priority 7)

**Status:** Placeholder exists, needs full implementation

**Goal:** Add flying ranged enemy

### Sub-tasks:

#### Create Drone Scene
- [ ] `scenes/enemies/drone.tscn`
  - Base: CharacterBody2D (flying, ignores gravity)
  - Sprite: Purple circle placeholder (24×24)
  - CollisionShape2D: CircleShape2D radius 12
  - Hurtbox + Health (30 HP)
  - Projectile spawn point (Marker2D)

#### Drone AI Script
- [ ] `scripts/enemies/drone.gd`
  - States: IDLE, PATROL, ALERT, SHOOT, RETREAT, DEAD
  - Hover movement (gentle up/down float)
  - Player detection: 250px range
  - Attack pattern:
    - Stop movement
    - Aim at player
    - Fire laser projectile
    - Cooldown 2 seconds
    - Retreat if player gets within 80px
- [ ] Patrol behavior:
  - Fly between 2 points
  - Maintain altitude (don't land)
  - Smooth movement (lerp position)

#### Projectile System
- [ ] `scripts/enemies/projectile.gd`
  - Area2D with small collision
  - Moves in straight line
  - 5 damage to player
  - Despawns on hit or after 3 seconds
  - Visual: Red circle trail
- [ ] Spawn from Drone on shoot
  - Direction: toward player position
  - Speed: 300 px/s

#### Integration
- [ ] Add 2 Drones to room_03_mixed.tscn
  - Position above platforms
  - Forces player to dodge while fighting Echo
- [ ] Test difficulty:
  - Can player dodge projectiles?
  - Is 2-second cooldown fair?
  - 30 HP = 2 hits to kill (good?)

**Reference:** GDD.md Section 6.2 (Drone)

**Test:** Drones fly, shoot, die. Projectiles hit player. Room is challenging but fair.

**Commit:** "Add Drone enemy (flying, ranged)"

---

## TASK 4: Visual Polish - Hit Effects

**Goal:** Make combat more satisfying (GDD Section 5.3)

### Sub-tasks:

#### Hit Flash
- [ ] When enemy takes damage:
  - Sprite flashes white for 0.1 seconds
  - Use Sprite2D modulate property
  - Tween: Color(1,1,1,1) → back to normal
- [ ] Implement in Hurtbox script
  - On hit_received signal
  - Get parent's Sprite2D node
  - Apply flash tween

#### Damage Numbers
- [ ] Spawn floating number on hit
  - Label node with damage value ("15")
  - Floats upward (+30 pixels)
  - Fades out over 0.5 seconds
  - Color: white for normal, yellow for crits
- [ ] Pool damage number nodes (reuse 10 labels)
- [ ] Attach to combat system

#### Hit Pause (Frame Freeze)
- [ ] On heavy hit (damage ≥ 20):
  - Freeze game for 0.05 seconds
  - Use `get_tree().paused = true`
  - Timer resumes after delay
- [ ] Add to player attack hitbox
  - Only on final combo hit
  - Makes impact feel strong

#### Screen Shake
- [ ] When player takes damage:
  - Camera shakes (±5 pixels random offset)
  - Duration: 0.2 seconds
  - Frequency: 30 Hz (fast jitter)
- [ ] Implement in room_camera.gd
  - Add shake() function
  - Call from player Hurtbox

**Reference:** GDD.md Section 5.3

**Test:** Combat feels punchy and responsive

**Commit:** "Add hit flash, damage numbers, screen shake"

---

## TASK 5: Audio System Foundation

**Status:** No audio implemented yet

**Goal:** Add placeholder sounds (use simple tones for now)

### Sub-tasks:

#### Audio Manager
- [ ] `scripts/systems/audio_manager.gd` (Autoload singleton)
  - play_sfx(sound_name: String)
  - play_music(track_name: String)
  - set_sfx_volume(volume: float)
  - set_music_volume(volume: float)

#### Placeholder SFX (Synthesized Tones)
- [ ] Use AudioStreamGenerator or simple .wav files
  - attack_swing.wav (whoosh, 440 Hz tone)
  - hit_impact.wav (thud, 220 Hz tone)
  - enemy_death.wav (descending tone)
  - door_unlock.wav (chime, rising tone)
  - checkpoint.wav (ping, 880 Hz)
  - jump.wav (pop, 660 Hz)
- [ ] Store in `assets/audio/sfx/`
- [ ] Generate programmatically if needed:
  ```gdscript
  var stream = AudioStreamGenerator.new()
  # Configure frequency, duration
  ```

#### Hook Up Events
- [ ] Player attack → attack_swing.wav
- [ ] Hitbox connects → hit_impact.wav
- [ ] Enemy dies → enemy_death.wav
- [ ] Door unlocks → door_unlock.wav
- [ ] Checkpoint → checkpoint.wav
- [ ] Jump → jump.wav

**Reference:** GDD.md Section 10

**Note:** These are placeholders. Real audio comes later.

**Test:** Every action has a sound (even if basic)

**Commit:** "Add audio system + placeholder SFX"

---

## TASK 6: Enemy AI Improvements (Priority 3)

**Status:** Echo AI works, needs polish

### Sub-tasks:

#### Echo Improvements
- [ ] Better patrol:
  - Turn around at patrol points (face direction)
  - Pause 1 second at each point
  - Smooth acceleration/deceleration
- [ ] Smarter attack:
  - Don't attack if player is behind
  - Attack animation plays fully (no interrupt)
  - Hitbox spawns at correct frame
- [ ] Death animation:
  - Fade out over 0.5 seconds
  - Drop cells (spawn cell pickup node)
  - Don't despawn instantly
- [ ] Hitstun visual:
  - Pause movement for 0.3s when hit
  - Flash red briefly

#### General Enemy Polish
- [ ] All enemies face player when alerted
- [ ] Death plays before queue_free()
- [ ] Smooth state transitions (no jank)

**Reference:** GDD.md Section 6.1

**Test:** Enemies feel responsive and intentional

**Commit:** "Polish enemy AI behavior and transitions"

---

## TASK 7: Moving Platform System

**Status:** moving_platform.gd exists, needs testing

### Sub-tasks:
- [ ] Test in room_02_platforming.tscn
  - Platforms move smoothly
  - Player can stand on them
  - Player moves with platform (not sliding off)
- [ ] Add different movement patterns:
  - Horizontal (left-right)
  - Vertical (up-down)
  - Circular (orbit around point)
- [ ] Configurable via exports:
  - move_distance: Vector2
  - move_speed: float
  - pattern: enum (HORIZONTAL, VERTICAL, CIRCULAR)
- [ ] Visual indicator:
  - Show movement path (dotted line)
  - Arrow on platform showing direction

**Reference:** GDD.md Section 3.4

**Test:** Can complete platforming sections using moving platforms

**Commit:** "Improve moving platform system with patterns"

---

## TASK 8: Hazard System Expansion

**Status:** hazard_zone.gd exists for spikes

**Goal:** Add more hazard types

### Sub-tasks:

#### Saw Blades (Rotating)
- [ ] `scenes/hazards/saw.tscn`
  - AnimatableBody2D (can rotate)
  - Sprite: Red circle with teeth (placeholder)
  - Rotates continuously (180 deg/s)
  - Deals 15 damage on contact
  - Can be static or moving along path

#### Lasers (Toggle On/Off)
- [ ] `scenes/hazards/laser.tscn`
  - Line2D visual (red beam)
  - Area2D collision (thin rectangle)
  - Toggles every 2 seconds (on → off → on)
  - Warning flash before activating
  - Instant kill (100 damage)

#### Crushers (Vertical)
- [ ] `scenes/hazards/crusher.tscn`
  - AnimatableBody2D (heavy block)
  - Slams down when player enters trigger zone
  - Waits 2 seconds at top
  - Deals 50 damage if caught
  - Resets to top position

#### Fire Pits
- [ ] Same as spikes, different visual
  - Orange/red particle effect
  - 20 damage continuous (0.5s intervals)
  - Applies knockback upward

**Add to Rooms:**
- [ ] Room 2: Add saw + laser
- [ ] Room 3: Add crusher above combat area

**Reference:** GDD.md Section 3.5

**Test:** Hazards are clear, fair, and challenging

**Commit:** "Add saw, laser, crusher, fire hazards"

---

## TASK 9: Save/Load System Polish

**Status:** Basic persistence exists

### Sub-tasks:
- [ ] Save file location: `user://fractured_save.dat`
- [ ] Save data includes:
  - Player HP
  - Cells collected
  - Rooms cleared (array of IDs)
  - Current checkpoint (scene path + spawn marker)
  - Abilities unlocked (array)
- [ ] Save triggers:
  - Checkpoint activation
  - Room clear
  - Manual save (pause menu button)
- [ ] Load on game start:
  - Check if save file exists
  - Restore player state
  - Spawn at checkpoint
  - Mark cleared rooms
- [ ] New Game option:
  - Deletes save file
  - Starts at room_01, spawn_default

**Reference:** GDD.md Section 8.1

**Test:** Save → close game → reopen → state preserved

**Commit:** "Implement full save/load system"

---

## TASK 10: Performance Optimization

**Goal:** Keep 60 FPS with multiple enemies

### Sub-tasks:
- [ ] Profile current FPS (use Godot debugger)
- [ ] Optimize combat:
  - Disable hitbox monitoring when not attacking
  - Limit active projectiles (max 20)
  - Reuse enemy instances (object pooling)
- [ ] Optimize rendering:
  - Cull offscreen enemies (pause AI when far)
  - Reduce particle counts if FPS drops
- [ ] Test with 10 enemies on screen
  - Should maintain 60 FPS

**Commit:** "Optimize combat performance"

---

## WORKFLOW

**For each task:**
1. Complete all sub-tasks
2. Test thoroughly (run the game)
3. Commit with clear message
4. Push to GitHub
5. Move to next task

**Git commands:**
```bash
git add .
git commit -m "Task description"
git push
```

**If stuck:**
- Check GDD.md for design clarification
- Leave a TODO comment in code
- Move to next task
- Document blockers in commit message

**Expected commits:** 10-15 overnight

**End goal:** Priorities 5-7 complete + major GDD features implemented

---

## SUCCESS CRITERIA

By morning:
- [ ] Checkpoint system working (save/load)
- [ ] Full UI (health, cells, combo)
- [ ] Drone enemy implemented
- [ ] Visual feedback (hit flash, damage numbers)
- [ ] Audio system + placeholder sounds
- [ ] All 4 rooms polished and playable
- [ ] Moving platforms working correctly
- [ ] 4+ hazard types
- [ ] Save/load persistent across sessions
- [ ] 60 FPS maintained

**If all complete:** Move to TASK 11+ (create more enemies, abilities, etc.)

---

**Last updated:** 2026-03-11 2am EST
