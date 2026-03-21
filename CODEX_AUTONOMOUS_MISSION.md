# CODEX AUTONOMOUS MISSION - MOMENTUM: FRACTURED

**Mission:** Fix broken build → Full bug sweep → Complete Phase 4 vertical slice  
**Mode:** Fully autonomous (no human intervention required)  
**Timeline:** Work until complete, commit progress regularly  
**Location:** ~/Documents/Playground/momentum-fractured

---

## Mission Overview

### Current Situation:
- Build is broken/unplayable (crashes reported)
- Last tested: March 12 (headless only)
- Phase 3 complete but untested in editor
- Phase 4 content work blocked until stable

### Your Objectives:
1. **CRITICAL:** Fix whatever is blocking game launch
2. **HIGH:** Complete full bug sweep (15 tests)
3. **MEDIUM:** Fix all Critical/High bugs found
4. **LOW:** Begin Phase 4 content (if time permits)

### Success Criteria:
- Game launches without errors
- Full playthrough possible (Room 01 → 04)
- 0 critical bugs
- All progress documented and committed

---

## PHASE 1: EMERGENCY STABILIZATION (1-2 hours)

### Objective: Get the game running

### Step 1.1: Fresh Clone & Setup
```bash
cd ~/Documents/Playground
# Backup existing if it exists
if [ -d "momentum-fractured" ]; then
  mv momentum-fractured momentum-fractured-backup-$(date +%Y%m%d-%H%M%S)
fi

# Fresh clone
git clone https://github.com/cappy2yappy/momentum-fractured.git
cd momentum-fractured

# Verify git remote
git remote -v
```

### Step 1.2: Launch Godot & Identify Crash
```bash
# Open Godot (will import assets on first launch)
godot project.godot
```

**In Godot:**
1. Wait for asset import to complete
2. Open **Output panel** (View → Output, or bottom panel)
3. Try to run project (F5) OR run Room 01 scene (F6)
4. **Document the error:**
   - Screenshot the error in Output panel
   - Copy full error text
   - Note which script/line is failing

### Step 1.3: Common Crash Causes & Fixes

#### Error Type A: "Invalid call" or "Nonexistent function"
**Cause:** Calling wrong function for node type (Camera2D vs Camera3D, etc.)

**Fix:**
1. Find the script mentioned in error
2. Locate the problematic line
3. Check node type in error message
4. Replace with correct function for that node type
5. Example: `unproject_position()` → `get_canvas_transform() *` for Camera2D

#### Error Type B: "Cannot find node" or "Null reference"
**Cause:** Scene structure changed, paths are wrong

**Fix:**
1. Open the scene file mentioned in error
2. Check Scene panel (left side)
3. Verify node paths match what script expects
4. Update NodePaths in script or fix scene structure

#### Error Type C: Script parsing error
**Cause:** GDScript syntax error

**Fix:**
1. Open script mentioned in error
2. Check the line number
3. Look for:
   - Missing colons `:`
   - Wrong indentation
   - Typos in keywords
   - Type mismatches
4. Fix syntax error

#### Error Type D: Missing resource/scene
**Cause:** File deleted or moved

**Fix:**
1. Check if file exists in path mentioned
2. If missing, find where it moved to
3. Update references OR recreate the file

### Step 1.4: Fix The Blocker

**Systematic approach:**
1. Read error message carefully
2. Open the script/scene mentioned
3. Navigate to line number
4. Identify the problem type (A/B/C/D above)
5. Apply appropriate fix
6. Save files
7. Test again (F6 on Room 01)
8. Repeat until Room 01 launches

**Document your fix:**
```markdown
## EMERGENCY FIX: [Brief Description]

**Error:** [Copy exact error message]
**File:** [Path to file]
**Line:** [Line number if applicable]

**Cause:** [What was wrong]
**Fix:** [What you changed]

**Tested:** Room 01 now launches? Yes/No
```

### Step 1.5: Commit Emergency Fix
```bash
git add .
git commit -m "Emergency fix: [brief description]

- Error: [one-line summary]
- Fix: [what was changed]
- Status: Game now launches"

git push
```

### Step 1.6: Basic Smoke Test
Before moving to Phase 2, verify basics work:

**Test:**
1. Launch Room 01 (F6)
2. Move with WASD
3. Jump with Space
4. Attack with Left Click
5. Kill one Echo enemy
6. Check if it dies

**If ANY of these fail:**
- Document the issue
- Fix it
- Commit the fix
- Test again

**Don't proceed to Phase 2 until all basics work.**

---

## PHASE 2: FULL BUG SWEEP (2-3 hours)

### Objective: Find and document all bugs

### Step 2.1: Read Test Plan
Open: **`BUG_TEST_CHECKLIST.md`**

This contains 15 test categories. You will execute ALL of them.

### Step 2.2: Create Bug Report File
```bash
touch BUG_REPORT_AUTONOMOUS_$(date +%Y%m%d).md
```

**Template:**
```markdown
# Bug Report - Autonomous Test Run

**Date:** [Current date]
**Tester:** Codex (Autonomous)
**Build:** Phase 3 Complete + Emergency Fixes

---

## Summary
- Tests Completed: 0 / 15
- Bugs Found: 0
  - Critical: 0
  - High: 0
  - Medium: 0
  - Low: 0

---

## Bugs

[Bugs will be added below as found]
```

### Step 2.3: Execute All 15 Tests

Work through `BUG_TEST_CHECKLIST.md` **in order:**

#### For Each Test:
1. Read test instructions
2. Follow steps exactly
3. Check each checkbox (pass/fail)
4. If test FAILS:
   - Document bug in Bug Report
   - Assign severity (Critical/High/Medium/Low)
   - Note reproduction steps
   - Take screenshot if helpful (save to `bugs/` folder)
5. Move to next test

#### Bug Documentation Format:
```markdown
## BUG #[number]: [Short Title]

**Severity:** Critical / High / Medium / Low
**Test Category:** [Which test from checklist]
**Scene:** [Room/scene where found]

**Reproduction:**
1. Step one
2. Step two
3. Bug occurs

**Expected:** [What should happen]
**Actual:** [What actually happens]

**Error Message:** [If any, from Output panel]

**Fix Priority:** Immediate / This Phase / Next Phase / Backlog
**Status:** Open / Fixed / Deferred
```

### Step 2.4: Severity Guidelines

**CRITICAL (Fix immediately):**
- Game crashes
- Cannot complete a room
- Save file corruption
- Infinite loop/softlock
- Physics explosions

**HIGH (Fix before Phase 4):**
- Combat doesn't work right
- Enemy AI broken
- Major visual glitch
- Checkpoint/save issues
- Progression blocker

**MEDIUM (Fix this phase):**
- Polish issue
- Minor mechanic problem
- UI inconsistency
- Audio bug

**LOW (Backlog):**
- Cosmetic issue
- Edge case exploit
- Nice-to-have improvement

### Step 2.5: Test Progress Commits

Every 3-5 tests completed, commit progress:
```bash
git add BUG_REPORT_AUTONOMOUS_*.md
git commit -m "Bug sweep progress: Tests 1-5 complete, [X] bugs found"
git push
```

### Step 2.6: Full Playthrough (Test 15)

After all tests, do complete run:
1. Delete save file:
   ```bash
   rm ~/Library/Application\ Support/Godot/app_userdata/MOMENTUM\ FRACTURED/save_game.dat
   ```
2. Launch Room 01
3. Complete sequence: Room 01 → 02 → 03 → 04
4. Time the run (use stopwatch)
5. Count deaths
6. Note difficulty feel
7. Document experience:

```markdown
## Full Playthrough Test

**Start Time:** [timestamp]
**End Time:** [timestamp]
**Duration:** [minutes]
**Deaths:** [count]

**Progression:**
- Room 01: [Clear/Stuck/Died]
- Room 02: [Clear/Stuck/Died]
- Room 03: [Clear/Stuck/Died]  
- Room 04: [Clear/Stuck/Died]

**Difficulty Assessment:**
- Too Easy / Just Right / Too Hard / Inconsistent

**Pain Points:**
1. [Anything frustrating]
2. [Anything confusing]

**Highlights:**
1. [Anything that felt good]
2. [Anything satisfying]

**Playthrough Successful:** Yes / No
```

### Step 2.7: Write Test Summary
Create: `TEST_RESULTS_AUTONOMOUS_[date].md`

```markdown
# Autonomous Test Results

**Date:** [Current date]
**Tester:** Codex
**Build:** Phase 3 + Fixes

---

## Test Execution

**Tests Completed:** 15 / 15
**Tests Passed:** [X] / 15
**Tests Failed:** [Y] / 15

---

## Bugs Summary

**Total Bugs Found:** [X]

**By Severity:**
- Critical: [X] ([all fixed / X remaining])
- High: [X] ([all fixed / X remaining])
- Medium: [X] (deferred)
- Low: [X] (backlog)

**By Category:**
- Movement: [X]
- Combat: [X]
- AI: [X]
- Hazards: [X]
- Transitions: [X]
- Save/Load: [X]
- UI: [X]
- Audio: [X]
- Performance: [X]
- Other: [X]

---

## Critical Bugs (Must Fix)

[List each critical bug with one-line summary]
[All should be FIXED before Phase 4]

---

## High Priority Bugs

[List each high priority bug]
[All should be FIXED before Phase 4]

---

## Medium/Low Priority

[List for tracking, defer to later]

---

## Full Playthrough Results

**Completion:** Success / Failed
**Time:** [X] minutes
**Deaths:** [X]
**Feel:** [Too Easy / Just Right / Too Hard]

**Blocking Issues:** [Any issues preventing completion]

---

## Recommendation

**Phase 4 Readiness:**
- [ ] Ready to proceed (0 critical, 0-2 high bugs)
- [ ] Needs more work (list blockers)

**Next Steps:**
1. [What needs to happen next]
2. [Priority order]

---

## Notes

[Any additional observations, patterns, suggestions]
```

### Step 2.8: Commit Test Results
```bash
git add TEST_RESULTS_AUTONOMOUS_*.md BUG_REPORT_AUTONOMOUS_*.md
git commit -m "Complete autonomous bug sweep

Tests: 15/15
Bugs found: [X]
Playthrough: [Success/Failed]
See TEST_RESULTS for details"

git push
```

---

## PHASE 3: BUG FIXES (2-4 hours)

### Objective: Fix all Critical and High priority bugs

### Step 3.1: Prioritize Bugs

From your Bug Report, create fix queue:

**Critical bugs FIRST:**
1. [List in order of impact]

**High priority bugs SECOND:**
1. [List in order]

**Medium/Low:** Skip for now (defer to backlog)

### Step 3.2: Fix Each Bug Systematically

For each bug in queue:

#### A. Understand the Bug
- Re-read bug description
- Reproduce the bug in Godot
- Confirm expected vs actual behavior
- Identify root cause

#### B. Plan the Fix
- What file(s) need to change?
- What's the correct behavior?
- Will this break anything else?

#### C. Implement Fix
- Make code changes
- Add comments explaining fix
- Consider edge cases

#### D. Test the Fix
- Reproduce original bug scenario
- Verify bug is gone
- Test related features (make sure nothing else broke)
- Run full playthrough if fix touches core systems

#### E. Document & Commit
```bash
git add [files changed]
git commit -m "Fix: [Bug title]

- Bug: [One-line description]
- Cause: [Root cause]
- Fix: [What was changed]
- Tested: [How verified]

Severity: [Critical/High]
Closes: Bug #[number]"

git push
```

#### F. Update Bug Report
Mark bug as FIXED in your Bug Report file:
```markdown
## BUG #X: [Title]
...
**Status:** ✅ FIXED
**Fix Commit:** [commit hash]
**Verified:** [date]
```

### Step 3.3: Re-Test After Fixes

After fixing all Critical/High bugs:
1. Run full playthrough again
2. Verify all fixes work
3. Check for regressions (new bugs from fixes)
4. Document re-test results

### Step 3.4: Final Stability Commit
```bash
git add .
git commit -m "Stabilization complete: All critical/high bugs fixed

Critical bugs fixed: [X]
High bugs fixed: [Y]
Full playthrough: Success
Ready for Phase 4"

git push
```

---

## PHASE 4: CONTENT CREATION (8-12 hours)

### Objective: Build Phase 4 vertical slice content

**ONLY START THIS IF:**
- [x] All Critical bugs fixed
- [x] All High bugs fixed
- [x] Full playthrough successful
- [x] Game feels stable

### Step 4.1: Read Phase 4 Task List
Open: **`PHASE_4_TASKS.md`**

This contains 10 prioritized tasks for Shibuya vertical slice.

### Step 4.2: Work Through Tasks In Order

#### Task 1: Guardian Enemy
**Estimated Time:** 2-4 hours

**Implementation:**
1. Create `scripts/enemies/guardian.gd`
2. Create `scenes/enemies/guardian.tscn`
3. Implement behavior:
   ```gdscript
   extends CharacterBody2D
   
   # Stats
   var max_health: float = 100.0
   var move_speed: float = 60.0  # 40% of player speed
   var shield_active: bool = true
   
   # Attacks
   var bash_damage: float = 8.0
   var slash_damage: float = 15.0
   
   # Behavior
   func _ready():
       # Set up health, hurtbox, hitbox
       pass
   
   func _physics_process(delta):
       # AI state machine
       match state:
           State.IDLE:
               _patrol()
           State.ALERT:
               _approach_player()
           State.ATTACK:
               _execute_attack()
   
   func _on_hurtbox_hit(hitbox):
       # Check attack direction
       var attack_direction = (hitbox.global_position - global_position).normalized()
       var facing_direction = Vector2(1, 0).rotated(rotation)
       var dot = attack_direction.dot(facing_direction)
       
       if shield_active and dot > 0.5:  # Frontal attack
           # Block (0 damage)
           play_shield_block_effect()
       else:
           # Take damage (from behind/side)
           take_damage(hitbox.damage)
   
   func take_damage(amount):
       health -= amount
       if health < max_health * 0.3:
           # Drop shield, enrage
           shield_active = false
           move_speed *= 1.5
   ```

4. Create placeholder sprite (48×56, orange/gold)
5. Add to Room 03 (replace 1 Echo with 1 Guardian)
6. Test:
   - Frontal attacks blocked
   - Side/rear attacks damage normally
   - Shield drops at 30% HP
   - Dies in ~7 hits from behind

**Commit:**
```bash
git add scripts/enemies/guardian.gd scenes/enemies/guardian.tscn scenes/rooms/room_03_mixed.tscn
git commit -m "Add Guardian enemy (armored tank)

- Shield blocks frontal attacks
- Vulnerable from behind/sides
- HP: 100, Speed: slow
- Enrages at 30% HP (drops shield, faster)
- Added to Room 03 for testing

Phase 4 Task 1 complete"

git push
```

#### Task 2: Six New Rooms
**Estimated Time:** 6-10 hours

**For EACH room:**

##### Room 05: Vertical Combat Arena
```gdscript
# Room design specs:
# - 3 platform levels (ground, mid, high)
# - 2 Echoes (ground)
# - 2 Drones (flying)
# - Vertical combat focus
# - Exit at top
```

**Implementation:**
1. Duplicate `room_01_combat.tscn` → `room_05_vertical.tscn`
2. Edit scene:
   - Add platforms at Y positions: 0, -200, -400
   - Place 2 Echoes on ground platform
   - Place 2 Drones at mid/high levels
   - Move exit door to top platform
3. Update room_controller:
   - Set enemy count to 4
   - Wire exit to Room 06
4. Test:
   - All enemies spawn
   - Doors lock/unlock correctly
   - Exit transitions to Room 06

##### Room 06: Hazard Gauntlet
```gdscript
# Room design specs:
# - Horizontal layout
# - Spike pit (bottom)
# - 3 saw blades (rotating)
# - 2 laser grids (vertical)
# - Moving platforms (3)
# - No enemies
```

**Implementation:**
1. Create `room_06_hazard.tscn`
2. Add hazards from prefabs:
   - `scenes/hazards/saw.tscn` × 3
   - `scenes/hazards/laser.tscn` × 2
   - Spike zones (HazardZone nodes)
3. Add moving platforms
4. NO RoomController (no enemies)
5. Direct exit to Room 07

##### Room 07: Guardian Introduction
```gdscript
# Room design specs:
# - Tutorial for Guardian
# - 1 Guardian + 1 Echo
# - Two-level arena
# - First Guardian encounter
```

**Implementation:**
1. Create `room_07_guardian_intro.tscn`
2. Add enemies:
   - 1 Guardian (center)
   - 1 Echo (side)
3. Add RoomController (2 enemies)
4. Test Guardian blocking

##### Room 08: Mixed Mayhem
```gdscript
# Room design specs:
# - Platforms over fire pits
# - 3 Echoes + 1 Drone
# - 1 Crusher hazard
# - Combat + hazard navigation
```

##### Room 09: Breather (Checkpoint)
```gdscript
# Room design specs:
# - Small, safe room
# - Checkpoint node
# - Health refill station
# - No enemies/hazards
# - 2 exits (back to 08, forward to 10)
```

##### Room 10: Pre-Boss Arena
```gdscript
# Room design specs:
# - Large circular room
# - 4 Echoes (warmup)
# - Prepares for boss fight
# - Exit locks until boss door opens
```

**After all 6 rooms built:**
```bash
git add scenes/rooms/room_*.tscn
git commit -m "Add 6 new rooms (05-10) for Shibuya biome

Room 05: Vertical combat (2 Echo, 2 Drone, platforms)
Room 06: Hazard gauntlet (no enemies, pure platforming)
Room 07: Guardian intro (1 Guardian, 1 Echo)
Room 08: Mixed combat (3 Echo, 1 Drone, fire pits, crusher)
Room 09: Checkpoint safe room (save point, heal station)
Room 10: Pre-boss arena (4 Echoes, warmup fight)

Phase 4 Task 2 complete"

git push
```

#### Task 3: Echo Amalgam Boss
**Estimated Time:** 6-8 hours

**Implementation:**
1. Create `scripts/enemies/echo_amalgam.gd`
2. Create `scenes/enemies/echo_amalgam.tscn`
3. Create `scenes/rooms/room_11_boss.tscn`

**Boss Behavior:**
```gdscript
extends CharacterBody2D

var max_health: float = 300.0
var health: float = 300.0

enum Phase { ONE, TWO, THREE }
var current_phase: Phase = Phase.ONE

func _process(delta):
    # Phase transitions
    if health > 100:
        current_phase = Phase.ONE
    elif health > 50:
        if current_phase == Phase.ONE:
            _transition_to_phase_two()
        current_phase = Phase.TWO
    else:
        if current_phase == Phase.TWO:
            _transition_to_phase_three()
        current_phase = Phase.THREE
    
    match current_phase:
        Phase.ONE:
            _phase_one_behavior()
        Phase.TWO:
            _phase_two_behavior()
        Phase.THREE:
            _phase_three_behavior()

func _phase_one_behavior():
    # Spawn 2 Echo minions
    # Stay in center
    # Minions attack player
    pass

func _phase_two_behavior():
    # Fuse minions into main body
    # Dash attacks across room
    # Faster movement
    pass

func _phase_three_behavior():
    # Enrage mode
    # Ground slam attacks (AoE)
    # Very fast dashes
    pass

func _on_death():
    # Drop 100 cells
    # Unlock door to Room 12
    # Play victory animation
    emit_signal("boss_defeated")
```

4. Wire boss room:
   - Large circular arena
   - Boss spawns in center
   - Door locked until boss dies
   - Exit to Room 12 unlocks on death

**Test boss fight:**
- All 3 phases trigger
- Difficulty feels fair
- Victory unlocks exit
- Cell drop works

**Commit:**
```bash
git add scripts/enemies/echo_amalgam.gd scenes/enemies/echo_amalgam.tscn scenes/rooms/room_11_boss.tscn
git commit -m "Add Echo Amalgam mini-boss (3-phase fight)

Phase 1 (300-100 HP): Spawns 2 Echo minions
Phase 2 (100-50 HP): Fuses, dash attacks
Phase 3 (<50 HP): Enrage, ground slams, fast

Drops 100 cells on death
Unlocks exit to Room 12

Phase 4 Task 3 complete"

git push
```

#### Task 4: Tutorial System
**Estimated Time:** 3-4 hours

**Implementation:**
1. Create `scripts/ui/tutorial_popup.gd`
2. Create `scenes/ui/tutorial_popup.tscn`

**Tutorial Popup Scene:**
```
CanvasLayer (tutorial_popup)
├── ColorRect (background: semi-transparent black)
└── Label (white text, center-bottom)
```

**Tutorial Script:**
```gdscript
extends CanvasLayer

var shown_tutorials: Array[String] = []

func show_tutorial(id: String, text: String, duration: float = 5.0):
    if id in shown_tutorials:
        return  # Don't repeat
    
    shown_tutorials.append(id)
    GameState.tutorials_shown = shown_tutorials
    
    $Label.text = text
    visible = true
    
    # Auto-dismiss after duration
    await get_tree().create_timer(duration).timeout
    visible = false
```

3. Add tutorial triggers to rooms:

**Room 01 triggers:**
```gdscript
# On player spawn
TutorialPopup.show_tutorial("movement", "WASD to move, SPACE to jump")

# Near first enemy
if player_near_enemy and not tutorial_shown("attack"):
    TutorialPopup.show_tutorial("attack", "Left Click to attack")

# After first kill
if enemy_count < 3 and not tutorial_shown("clear"):
    TutorialPopup.show_tutorial("clear", "Defeat all enemies to unlock doors")

# At exit door
if doors_unlocked and not tutorial_shown("exit"):
    TutorialPopup.show_tutorial("exit", "Walk into the door to continue")
```

**Room 02 triggers:**
```gdscript
# Near hazard
TutorialPopup.show_tutorial("hazards", "Avoid hazards or respawn at checkpoint")
```

**Room 04 triggers:**
```gdscript
# At checkpoint
TutorialPopup.show_tutorial("checkpoint", "Checkpoints save your progress")
```

**Room 07 triggers:**
```gdscript
# Near Guardian
TutorialPopup.show_tutorial("guardian", "Attack from behind - shield blocks frontal hits")
```

4. Wire up to GameState (save shown tutorials)

**Commit:**
```bash
git add scripts/ui/tutorial_popup.gd scenes/ui/tutorial_popup.tscn scenes/rooms/*.tscn
git commit -m "Add tutorial popup system

Contextual tutorials appear once:
- Movement (Room 01 start)
- Attack (Room 01 near enemy)
- Clear objective (Room 01 after first kill)
- Exit (Room 01 at door)
- Hazards (Room 02)
- Checkpoint (Room 04)
- Guardian tactics (Room 07)

Tutorials saved to GameState (won't repeat)

Phase 4 Task 4 complete"

git push
```

#### Task 5: Ability Unlock Framework
**Estimated Time:** 3-5 hours

**Implementation:**
1. Create `scripts/systems/ability_manager.gd` (AutoLoad)

```gdscript
extends Node

signal ability_unlocked(ability_name: String)

var unlocked_abilities = {
    "grapple": false,
    "dash": false,  # Already unlocked (base ability)
    "double_jump": false,
    "slide": false
}

func unlock_ability(ability_name: String):
    if ability_name not in unlocked_abilities:
        push_error("Unknown ability: " + ability_name)
        return
    
    if unlocked_abilities[ability_name]:
        return  # Already unlocked
    
    unlocked_abilities[ability_name] = true
    emit_signal("ability_unlocked", ability_name)
    
    # Show notification
    HUD.show_notification("New Ability: " + ability_name.capitalize())
    
    # Save to GameState
    GameState.abilities_unlocked = unlocked_abilities
    GameState.save_to_disk()

func has_ability(ability_name: String) -> bool:
    return unlocked_abilities.get(ability_name, false)

func reset_abilities():
    for key in unlocked_abilities.keys():
        unlocked_abilities[key] = false
    unlocked_abilities["dash"] = true  # Dash is always available
```

2. Add to AutoLoad in project.godot:
```
[autoload]
AbilityManager="*res://scripts/systems/ability_manager.gd"
```

3. Create `scripts/rooms/ability_unlock_trigger.gd`

```gdscript
extends Area2D

@export var ability_name: String = "grapple"

var unlocked: bool = false

func _ready():
    body_entered.connect(_on_body_entered)

func _on_body_entered(body):
    if unlocked:
        return
    
    if body.name == "Kaze":  # Player
        unlock_ability()

func unlock_ability():
    unlocked = true
    AbilityManager.unlock_ability(ability_name)
    
    # Visual feedback
    # Play particle effect
    # Play sound
    
    # Hide/remove pickup
    queue_free()
```

4. Create Room 12 (Victory Room):
```gdscript
# Room design:
# - Small bright room
# - Grapple ability pickup in center
# - Victory message
# - Exit (placeholder for future)
```

5. Add ability check to player script (placeholder):
```gdscript
# In kaze_base.gd
func _process(delta):
    # Example: grapple hook
    if Input.is_action_just_pressed("grapple"):
        if AbilityManager.has_ability("grapple"):
            _use_grapple()
        else:
            # Can't use yet (ability locked)
            pass
```

**Commit:**
```bash
git add scripts/systems/ability_manager.gd scripts/rooms/ability_unlock_trigger.gd scenes/rooms/room_12_victory.tscn project.godot
git commit -m "Add ability unlock framework

AbilityManager singleton tracks unlocks:
- grapple (unlocked in Room 12)
- dash (already available)
- double_jump (future)
- slide (future)

Ability unlock trigger spawns in Room 12
Shows notification on unlock
Persists to save file

Phase 4 Task 5 complete"

git push
```

#### Tasks 6-10: Continue Similarly

For each remaining task (Audio, Visual Polish, Room Map, Balance, Victory Screen):
- Follow PHASE_4_TASKS.md specifications
- Implement completely
- Test thoroughly
- Commit with clear message
- Push to GitHub

**Track progress by updating PHASE_4_TASKS.md:**
```markdown
## PRIORITY 1: Guardian Enemy
- [x] COMPLETE - Commit: abc1234

## PRIORITY 2: Six New Rooms
- [x] COMPLETE - Commit: def5678

...
```

### Step 4.3: Phase 4 Complete Checklist

After all 10 tasks done, verify:

- [ ] 12 rooms exist (Room 01-12)
- [ ] 3 enemy types functional (Echo, Drone, Guardian)
- [ ] Boss fight playable (Echo Amalgam)
- [ ] Tutorial system guides new players
- [ ] Ability unlock framework working
- [ ] Music and SFX playing
- [ ] Sprites upgraded (less placeholders)
- [ ] Full playthrough possible (01 → 12)
- [ ] Balance feels fair
- [ ] Victory screen appears

### Step 4.4: Final Phase 4 Commit
```bash
git add .
git commit -m "Phase 4 COMPLETE: Shibuya Crossing vertical slice

Content:
- 12 rooms (full Shibuya biome)
- 3 enemy types (Echo, Drone, Guardian)
- Echo Amalgam boss fight
- Tutorial system
- Ability unlock framework
- Audio system (music + SFX)
- Visual polish (sprite upgrades)
- Balance pass

Playthrough: Room 01 → 12 fully playable
Duration: ~15-20 minutes
Ready for external playtesting"

git push
```

---

## PROGRESS REPORTING

### Every 2-3 Hours:
Commit a progress report:

```bash
echo "## Progress Update - $(date)

Current Phase: [1/2/3/4]
Hours Worked: ~[X]

Completed:
- [List what's done]

In Progress:
- [What you're working on now]

Next Up:
- [What's coming next]

Blockers:
- [Any issues encountered]

Status: On Track / Ahead / Behind

" >> PROGRESS_LOG.md

git add PROGRESS_LOG.md
git commit -m "Progress update: [brief status]"
git push
```

### At End of Session:
Create: `SESSION_REPORT_[date].md`

```markdown
# Autonomous Session Report

**Date:** [date]
**Duration:** [X hours]
**Phases Completed:** [1/2/3/4]

---

## What Was Accomplished

### Phase 1: Emergency Stabilization
- [x] Game launch fixed
- Issue: [Brief description]
- Fix: [What was done]
- Status: Stable

### Phase 2: Bug Sweep
- [x] 15 tests executed
- Bugs found: [X]
- Bugs fixed: [Y]
- See: BUG_REPORT_AUTONOMOUS_[date].md

### Phase 3: Bug Fixes
- Critical bugs: [X] (all fixed)
- High bugs: [Y] (all fixed)
- Full playthrough: Success

### Phase 4: Content Creation
- Tasks completed: [X] / 10
- Rooms built: [X] / 12
- Enemies added: [Guardian/other]
- Boss: [Done/In Progress/Not Started]

---

## Metrics

**Code Changes:**
- Files modified: [X]
- Lines added: ~[X]
- Lines removed: ~[X]
- Commits made: [X]

**Testing:**
- Full playthroughs: [X]
- Bugs found: [X]
- Bugs fixed: [X]

**Time Breakdown:**
- Emergency fixes: [X] hours
- Bug testing: [X] hours
- Bug fixing: [X] hours
- Content creation: [X] hours

---

## Current State

**Game Status:** [Broken / Playable / Stable / Polished]
**Playthrough:** [Blocked / Partial / Complete]
**Next Priority:** [What comes next]

---

## Recommendations

[Any observations, suggestions, or decisions needed]

---

**Session Complete**
```

---

## ERROR HANDLING

### If You Get Stuck:

1. **Document the blocker:**
   ```markdown
   ## BLOCKER: [Issue title]
   
   **Context:** [What you were trying to do]
   **Problem:** [What's not working]
   **Attempted:** [What you tried]
   **Error:** [Any error messages]
   **Need:** [What would help]
   ```

2. **Commit what you have:**
   ```bash
   git add .
   git commit -m "WIP: [what was being worked on] - BLOCKED

   Issue: [brief description]
   See BLOCKER section in [file]"
   git push
   ```

3. **Try workarounds:**
   - Skip the stuck task, move to next
   - Implement minimal version
   - Document for human follow-up

4. **Leave clear notes:**
   Update relevant task file with:
   - What's incomplete
   - Why it's stuck
   - What was tried
   - What's needed to continue

---

## FINAL DELIVERABLES

By end of autonomous session, repo should have:

1. **Bug Report:** `BUG_REPORT_AUTONOMOUS_[date].md`
2. **Test Results:** `TEST_RESULTS_AUTONOMOUS_[date].md`
3. **Progress Log:** `PROGRESS_LOG.md`
4. **Session Report:** `SESSION_REPORT_[date].md`
5. **All code changes committed and pushed**
6. **Updated PHASE_4_TASKS.md** with completion status

---

## SUCCESS METRICS

**Mission SUCCESS if:**
- Game is playable (no critical bugs)
- Full playthrough works (Room 01 → 04 minimum)
- All emergency fixes committed
- Bug sweep completed
- Progress documented

**BONUS SUCCESS if:**
- Phase 4 content started/completed
- Shibuya vertical slice playable
- 12 rooms functional

---

## START CHECKLIST

Before beginning:

- [ ] Fresh clone of repo
- [ ] Godot 4.3+ installed
- [ ] Git configured (can commit/push)
- [ ] Read this file completely
- [ ] Understand all 4 phases
- [ ] Ready to work autonomously

---

**BEGIN MISSION**

Start with Phase 1, Step 1.1 (Fresh Clone & Setup).

Work systematically through each phase.

Document everything.

Commit often.

Good luck, Codex. Build something great.
