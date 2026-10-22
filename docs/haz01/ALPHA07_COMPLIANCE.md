# Alpha 0.7 enemy/hazard compliance handoff — 2026-10-22

Draft PR #87: https://github.com/cappy2yappy/momentum-fractured/pull/87
Owner: CODEX-ALPHA07 Agent D. Branch: `codex/alpha07-compliance`.
Recovered EN-01 exact head `5265e6c6182d883432215f4e9beab50255e48b5e`; recovered HAZ-01 exact `33e70874cd938200f47bcabc1283c7581f17696b` as additive local commit `e7a9418`. Gameplay fix commit `125c6db1598aacebf2f9f96055631e35cdd801ce`.

## Changes

- EN metadata restricts HP to 4–8 and windup to >=0.5 seconds. Story activation additionally requires grounded player, >=400 px distance, transition ended and player physics restored. Existing >=0.8 second awakening warning remains.
- All members now use `world.spawn_enemy`, then initialize validated configuration. Original patrol/combat/player/guard code remains intact. Production members carry `story_managed_encounter` metadata and existing `en01/<id>` persistence IDs. INT-01 owns the extra world seam and queues IDs safely; this PR never edits shared world or save functions.
- Completion waits for transition/control restoration. An isolated no-StoryDirector harness retains its original existing-map persistence fallback; production with StoryDirector never writes or saves from this fallback. Defeats pending at room exit stay alive as data until controls restore, with enemy/projectile processing disabled immediately.
- `story_consumers.gd` registers explicit consumers on INT-01's sole director before `load_data`: `register_encounter(story,id,entries)` and `register_hazard(story,id,hazard,enabled_when,disabled_when)`. Composition owner calls `update()` each tick and `dispose()` when unloading consumer ownership. Completed events report back through the single director. Hazard effects read flags set by their rules; they do not own progression.
- HAZ warnings require >=0.6 seconds. Flag consumer reads existing expansion_flags only and defers both enabling/disabling while occupied. Production placement probe rejects collapse, door approaches, checkpoints, interactables, recovery floors, unsupported geometry and unproven bypass/timing. Caller must supply creator-surveyed exclusion geometry; no placements were added.
- Collapse and its separate prototype snapshot format remain isolated course-only prototypes. Production placement rejects collider-producing collapse; prototype snapshots never enter campaign save data. No creator canon, room geometry, artwork or progression changes.
- Toolkit save tests use disposable cross-platform temp paths. Native capture helper records actual rendered scenes with bounded 300-frame launch.

## Validation

Godot `4.6.1.stable.official.14d19694e`, Apple M4, macOS. Independent headless checks: EN framework52, EN disk persistence5, HAZ toolkit56, HAZ production contracts17, movement53, save compatibility11, gameplay stabilization16: **210 pass, 0 fail**. Approved baseline verification: 0 failures. Existing gameplay suites execute temporary copies with all `user://` paths redirected to disposable directories; campaign profile never opened for writes. macOS certificate lookup emits an environment warning at exit; no script parse/runtime errors in final passing suites.

Actual native OpenGL 4.1 captures: exact recovered pre-fix tree `e7a9418` and post-fix tree `125c6db`; combined enemy arena and isolated hazard course, 1/2/3 seconds. These show native rendered launch/state timing, not proof of combat acceptance or physical-controller coverage. Initial stock capture helper stalled awaiting draw; it was terminated, replaced by the bounded process-frame helper. Initial sandboxed toolkit run failed two save-path checks; portable fix passed all56. Preserve these initial failure logs separately from accepted results.

Combined INT-01/narrative compatibility requires Agent E's actual runtime tests. A clean Git merge is not a runtime result. New effect consumers require INT-01's registration API and managed defeat seam; base PR83 alone does not provide those production hooks. Controller synthesis in existing suites is not a physical-controller test. Windows and creator gameplay-feel review remain pending.

## Mac launch

From this worktree, Godot4.6.1:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path . --rendering-method gl_compatibility --rendering-driver opengl3 --audio-driver Dummy --log-file /tmp/kaze-en01.log res://scenes/encounters/combined.tscn -- --test
/Applications/Godot.app/Contents/MacOS/Godot --path . --rendering-method gl_compatibility --rendering-driver opengl3 --audio-driver Dummy --log-file /tmp/kaze-haz01.log res://scenes/haz01/course.tscn -- --test
```

Enemy arena: A/D move, double tap sprint, Space jump, Shift dash, J attack, F parry, R kunai, T cycle. Hazard course: A/D, Space, Shift, hold Q tether; Backspace reset, F2 toggle, F5/F9 isolated prototype save/load, Esc exit. Demos never load campaign saves. Do not integrate course snapshot storage into production.

No PR merged; Candidate3 unchanged. Future room data waits for creator markup and approved story placements.
