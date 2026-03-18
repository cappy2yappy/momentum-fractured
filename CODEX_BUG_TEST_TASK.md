# CODEX TASK: Full Bug Sweep

**Priority:** CRITICAL (before Phase 4 content work)  
**Estimated Time:** 2-3 hours  
**Deliverables:** Bug report + test results + fixes

---

## Your Mission

Run comprehensive bug test on current build (Phase 3 complete).

**Goal:** Find and fix all blocking bugs before we start building Phase 4 content.

---

## Instructions

### Step 1: Read the Test Plan
Open and read: **`BUG_TEST_CHECKLIST.md`**

This contains 15 test categories covering every system:
- Movement, combat, AI, hazards, transitions, saves, UI, audio, performance

### Step 2: Run All Tests
Work through each test in `BUG_TEST_CHECKLIST.md` **in order**.

For each test:
1. Follow the steps exactly
2. Check all checkboxes (pass/fail)
3. Document any bugs found
4. Take screenshots if needed (save to `bugs/` folder)

### Step 3: Document Bugs
Create: **`BUG_REPORT_2026-03-18.md`**

For each bug, use this format:
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

### Step 4: Fix Critical/High Bugs
For any **Critical** or **High** severity bugs:
1. Fix immediately
2. Test the fix
3. Commit with clear message
4. Mark as FIXED in bug report

**Medium/Low** bugs: Document but defer to backlog

### Step 5: Full Playthrough Test
After fixing blockers:
1. Delete save file: `rm ~/Library/Application\ Support/Godot/app_userdata/MOMENTUM\ FRACTURED/save_game.dat`
2. Run Room 01
3. Complete all 4 rooms (01 → 02 → 03 → 04)
4. Time the playthrough
5. Count deaths
6. Note any pain points

### Step 6: Write Test Summary
Create: **`TEST_RESULTS_2026-03-18.md`**

Include:
```markdown
# Test Results Summary

**Date:** 2026-03-18
**Build:** Phase 3 Complete + Camera2D fix
**Tester:** Codex

## Results
- Tests Completed: X / 15
- Tests Passed: X / 15
- Bugs Found: X
  - Critical: X
  - High: X
  - Medium: X
  - Low: X

## Critical Bugs (Blocking)
1. [List any critical bugs]

## High Priority Bugs
1. [List high priority bugs]

## Full Playthrough
- Completion Time: X minutes
- Deaths: X
- Difficulty: Too Easy / Just Right / Too Hard
- Pain Points: [List any frustrating moments]

## Recommendation
- [ ] Ready for Phase 4 content work
- [ ] Needs more fixes before proceeding

## Notes
[Any additional observations]
```

### Step 7: Commit & Push
```bash
git add BUG_REPORT_2026-03-18.md TEST_RESULTS_2026-03-18.md
git commit -m "Complete bug test sweep - [X bugs found, Y fixed]"
git push
```

---

## Testing Tips

### How to Run Tests in Godot:
```bash
cd ~/Documents/Playground/momentum-fractured
godot project.godot
```

1. File → Open Scene → select test scene
2. Press **F6** to run current scene
3. Watch **Output panel** (bottom) for errors
4. Use **Debugger → Monitor** tab for performance stats

### Debug Hotkeys (F5-F9):
- **F5** = Reset progress
- **F6** = Respawn at checkpoint
- **F7** = Add +50 cells
- **F8** = Set checkpoint here
- **F9** = Print debug info

### Common Bug Locations:
- Combat bugs → `scripts/combat/*.gd`
- AI bugs → `scripts/enemies/*.gd`
- Room bugs → `scripts/rooms/*.gd`
- Save bugs → `scripts/systems/game_state.gd`
- UI bugs → `scripts/ui/*.gd`

---

## Bug Severity Guide

### CRITICAL (Fix Immediately)
- Game won't launch
- Crashes during normal gameplay
- Cannot complete a room
- Save corruption
- Infinite loops

### HIGH (Fix Before Phase 4)
- Major gameplay issue
- Combat feels broken
- AI doesn't work
- Progression blocker in some cases

### MEDIUM (Fix This Phase)
- Polish issue
- Minor visual glitch
- Inconsistent behavior
- Quality-of-life problem

### LOW (Backlog)
- Nice-to-have improvement
- Minor cosmetic issue
- Edge case exploit
- Rare occurrence

---

## Example Bug Report

```markdown
## BUG: Player Can Dash Through Walls

**Severity:** High
**Scene:** All rooms
**Reproduction Steps:**
1. Stand facing a wall
2. Press Shift to dash
3. Player clips through wall

**Expected:** Player should collide with wall and stop
**Actual:** Player phases through wall and escapes room bounds

**Error Message:** None

**Fix Priority:** High (breaks room boundaries)

**Fix Applied:** 
- Updated kaze_base.gd line 127
- Added raycast check before dash
- Tested in all 4 rooms
- Commit: abc1234

**Status:** ✅ FIXED
```

---

## Success Criteria

**You're DONE when:**
- [x] All 15 test categories completed
- [x] All bugs documented in BUG_REPORT_2026-03-18.md
- [x] All Critical bugs fixed
- [x] All High bugs fixed (or deferred with reason)
- [x] Full playthrough successful (no blocks)
- [x] Test summary written
- [x] All changes committed and pushed

**Phase 4 is READY when:**
- 0 critical bugs
- 0-2 high bugs (documented for later)
- Full playthrough smooth
- Combat feels good
- No crashes

---

## After Testing

Post results in Discord:
```
🐛 Bug Test Complete

Tests: 15/15 ✅
Bugs Found: X
- Critical: X (all fixed)
- High: X (all fixed)
- Medium: X (backlog)
- Low: X (backlog)

Playthrough: X minutes, X deaths

Status: [Ready for Phase 4 / Needs more work]

Full report: BUG_REPORT_2026-03-18.md
```

---

## Questions?

- Check `BUG_TEST_CHECKLIST.md` for detailed test steps
- Check `GDD.md` for expected behavior
- Check Godot Output panel for error details
- Post in Discord if stuck

---

**Start testing now!** Work through BUG_TEST_CHECKLIST.md systematically.

Take your time. Thorough testing now = less pain later.
