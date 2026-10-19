# Pending candidate hooks

These hooks are deliberately absent in Phase A. While a hook file is missing the harness prints
`SKIP: [hook_...] PENDING ...` and the runner reports `PASS_WITH_SKIPS`. A skip is never a pass.

To activate one, add `hooks/<name>.gd` (QA-owned, test-only). Interface:

```gdscript
extends RefCounted
func run(qa):   # qa is the harness SceneTree; use qa.check(ok,label), qa.key(code,pressed),
	            # await qa.wait_ticks(n), qa.stage(pair,distance), qa.w (the world), qa.skip(reason)
	pass
```

Hook names and what Phase B must put in them:

* `hook_cinematic_completion`: for each meaningful doorway or stair entry the Transition candidate stages
  (staged sequence of roughly 2 to 3 seconds): real key or E start; sequence completes exactly once; the
  world finishes in the target room; player physics processing, sprite visibility, camera zoom/offset,
  `w.transition`, `get_tree().paused`, held-key state and HUD message are restored; Kaze responds to a real key
  afterwards (use `qa.responsive`); pausing or respawning mid-sequence cleans up; reduced motion (F6 or
  `--tr05-reduced-motion`) shortens or stills the sequence and still restores control; no second request
  from held E or direction. Needs: the Transition candidate head SHA and the names of the new
  controller fields (for example a sequence-active flag and duration), plus its documented duration.
* `hook_canal_containment`: Level/Canal candidate. Needs `/home/claude/pilot_shared/CANAL_CONTRACT.md`:
  with real keys and physics, from R13 near the mandatory left exit (feet (120,1200)), the maximum reachable
  height above the exit cannot enter unintended space (jump, double jump, dash, tether if unlocked), while
  intentional vertical routes elsewhere in R13 stay reachable. Also: door art coincides with the transition
  threshold; walk-through still works from walk, sprint, dash and jump approaches (rerun `matrix` for 13->0).

Do not weaken or auto-pass these. If a candidate changes a contract, update the hook and say so in the report.
