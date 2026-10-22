# INT-01 interaction recovery

The unfinished local feature branch was recovered read-only from the creator's prior `Implement interactable object system` chat, source base `c2170032d08ea55268313e0020676c743251deab`. Its original working directory was preserved. This branch contains the recovered files and completion work; it does not change the Candidate 3 branch.

One world-owned StoryDirector handles all reports and persistent state. Production `data/story` arrays remain empty. The four-object neutral laboratory uses `[TEST FIXTURE]` text and is unreachable from normal launch. Five shared kinds are examine, read, investigate, activate and memorial. The prior creator order explicitly authorized the inspection panel, expanding the announcement-only PR80 proposal.

## Authoring and ownership

`objects.json` is contract 1 with `objects` array: stable prefixed ID, room 0..20, at [x,y], positive radius <=200, kind, optional title/prompt/description/pages, requires, once, persistent and event. Missing content has readable fallback; art/audio are optional metadata. Cinematic/objective metadata does not mutate state; effects are authored in rules. IDs use lowercase segments separated by `/`, max 48 characters. Legacy flags may be read but cannot be written by set_flag. Object placement rejects checkpoint circles and door approach bands. The JSON numeric-room normalization is explicit so float-decoded room IDs do not bypass integer checkpoint keys.

Rules have trigger, requires and effects. Flag/objective/announcement effects run before optional presentation. Objective flags must use `obj/`. The announcement FIFO has at most three pending lines and waits until the current message expires. Unknown effects and undeclared encounter/hazard IDs are rejected before load. Register consumers through `story.register_effect_consumer(kind, id, callable)` before loading their rules; handlers receive event context. Supported consumer kinds are `spawn_encounter` and `arm_hazard`. These callbacks own their existing system behavior, never a new event bus or save format.

The optional presentation node is assigned to `story.cutin_presenter`; it implements request_cutin(id), update(world, dt), and cancel(reason). Same-room rebuild cancels it too. All state changes precede presentation. Cinematics own no state. Reports and deferred saves wait for transition <=0, living player, unpaused tree and restored player physics.

## Narrow contract deltas for PM review

The existing five world call sites are retained, plus one approved persistence branch in on_enemy_defeated: only enemies marked `story_managed_encounter=true` use story.record_encounter(persistent_id). The director queues only IDs, so enemy deletion is safe, then writes existing cleared_encounters and flushes its one save queue. Ordinary enemies keep their direct persistence behavior. No guarded gameplay function, save function, schema, version, existing room geometry or approved sprite changes.

Both export presets receive the exact contract-required JSON include extension. The original TR05 guard therefore reports one intentional export-filter failure. The guard remains unchanged. tools/story/verify_int01_preservation.py proves that normalizing only those two exact filter lines recovers the original export bytes and that guarded functions and existing gameplay files remain identical.

## Mac launch

Godot 4.6.1: open this branch's project.godot, then run tests/story_demo/demo.tscn with F6. The isolated demo uses its own int01_demo_only.json save, separate from the campaign. Move with A/D; E or gamepad X inspects, E/X/A continues, Esc/B closes, directional UI inputs scroll/select. Physical gamepad hardware has not been verified. Keyboard gameplay is unchanged. The new X binding adds inspection support only, not a complete new controller mapping for movement/combat.

From Terminal: `/Applications/Godot.app/Contents/MacOS/Godot --path "$PWD" --scene res://tests/story_demo/demo.tscn --log-file /tmp/int01-demo.log -- --test`. `--test` suppresses disk writes. Omit it only to test the separate laboratory save.

Tests: tests/story_demo/smoke.gd, contracts.gd; tools/story/validate_data.gd; existing gameplay suites. Native capture.gd writes actual OpenGL before-interaction/inspection/activation states. Those state captures are not a claim of a historical implementation before/after comparison. The panel is static and reduced-motion safe. New story content and production placement require separate creator approval.
