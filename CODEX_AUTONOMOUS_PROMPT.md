# CODEX AUTONOMOUS OVERNIGHT RUN

**Paste this single prompt into Codex, then go to sleep.**

---

## Master Prompt (Copy Everything Below)

```
Work through CODEX_NIGHT_TASKS.md overnight in autonomous mode.

Repo: https://github.com/cappy2yappy/momentum-fractured
Location: ~/Documents/Playground/momentum-fractured

=== BLANKET PERMISSIONS (NO NEED TO ASK) ===

You have permission to:
✅ Read/write ANY file in this project
✅ Create new files and directories
✅ Modify scripts, scenes, assets
✅ Install Godot plugins if needed
✅ Run git commands (add, commit, push)
✅ Run Godot CLI commands (test scenes)
✅ Download/generate placeholder assets (sprites, audio)
✅ Make design decisions within GDD.md scope
✅ Debug and fix errors
✅ Refactor code for clarity

DO NOT ask permission for:
❌ File modifications
❌ New file creation
❌ Git commits/pushes
❌ Running tests
❌ Installing dependencies
❌ Code refactors

=== WORKFLOW ===

For each task in CODEX_NIGHT_TASKS.md:
1. Read the task fully
2. Implement all sub-tasks
3. Test in Godot (run the scene)
4. Fix any errors
5. Commit: git add . && git commit -m "Task X: description" && git push
6. Move to next task

=== GIT CREDENTIALS ===

Already configured. Just run:
git push

If it fails, skip the push and continue. Document in commit message.

=== TASK LIST ===

Work through these in order:
1. Checkpoint system (save/load + visual feedback)
2. UI/HUD (health bar, cell counter, combo)
3. Drone enemy (flying, ranged attack)
4. Visual polish (hit flash, damage numbers, screen shake)
5. Audio system + placeholder sounds
6. Enemy AI improvements
7. Moving platform patterns
8. Hazard expansion (saw, laser, crusher, fire)
9. Save/load persistence
10. Performance optimization

Reference: GDD.md for design details

=== AUTONOMOUS RULES ===

- Work continuously, don't wait for approval
- If stuck on a task >30 min, document blocker in code comment and move to next task
- Commit after each completed task (10-15 commits expected)
- Test every change before committing
- Keep commits focused (one task per commit)
- If Godot crashes, restart and continue
- Assume answer is "yes" for design decisions within GDD scope

=== ERROR HANDLING ===

If you encounter:
- Compile errors → fix them, don't skip
- Missing dependencies → install or create placeholder
- Test failures → debug until working
- Git conflicts → resolve automatically (favor your changes)
- Permission errors → retry once, then skip and document

=== SUCCESS CRITERIA ===

By completion:
✅ All 10 tasks done
✅ 10-15 commits pushed to GitHub
✅ Game runs without errors
✅ All 4 rooms playable
✅ Combat feels polished
✅ Save/load works

=== OUTPUT ===

When finished, create a file:
OVERNIGHT_REPORT.md

Include:
- Tasks completed (X/10)
- Commits made (list)
- Blockers encountered
- Next priorities
- How to test your changes

=== START NOW ===

Begin with Task 1. Work autonomously. Do not ask for permission.

Good night! 🌙
```

---

## HOW TO USE

1. Open Codex on work Mac
2. Copy the entire Master Prompt section above (from "Work through..." to "Good night!")
3. Paste into Codex
4. Go to sleep
5. Check GitHub commits in the morning

Done! 🛌
