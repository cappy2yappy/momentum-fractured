# INT-01 implementation handoff

Status: incomplete feature checkpoint, transferred to Alpha 0.7 coordinating Codex. Do not merge. Preserve and continue this implementation, do not restart it.

Branch: `feature/int01-story-director`.
Base: `c2170032d08ea55268313e0020676c743251deab` (`candidate/wave3-targeted-3`). The PR targets that branch solely to isolate the diff. The candidate is unchanged; PM must retarget before integration. Base selection and event reservations have not received PM confirmation; two PM messaging attempts failed (approval-service usage limit, then conversation rate limit).

Local checkout: `/Users/tonysantiago/.codex/.chatgpt-projects/g-p-6aa9b0443c20819186909618bb6be970/work/int01-interactables`.

## Completed implementation

- Shared object validator accepts examine, read, investigate, activate and memorial definitions. Stable IDs, room, position, radius, prerequisite flags, once/persistent fields, page content and optional references are represented.
- StoryDirector integrates at six additive world lines: construction, room load, interaction, update, draw and objective override. Player controller, existing save/load functions and transition implementations are unchanged.
- Inspection panel displays title, pages, continue/close controls and temporarily owns tree pause plus HUD input suspension. No animated presentation. Close, focus loss and room change paths exist.
- Isolated four-object laboratory includes abandoned note, damaged machine, memorial and activation switch. All prose is TEST FIXTURE, not canonical or ST-05 approved. Normal production object/rule lists are empty.
- Deterministic nearest-object selection and conservative doorway/checkpoint exclusion. Existing expansion/extension handlers retain precedence.

## Verified

Godot 4.6.1 official, macOS, headless. `tests/story_demo/smoke.gd`: 11 PASS, zero failed assertions. Raw output in SMOKE.log. Covers four records, opening, pause, paging, close/input restoration, repeat read, activation flag, once-only behavior, in-memory room re-entry persistence and yielding at a checkpoint. This is a smoke test, not complete acceptance. It directly calls methods rather than exercising real input.

Command from project root:

```
/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file /tmp/int01-engine.log --path . --script res://tests/story_demo/smoke.gd -- --test
```

`git diff --check` passed. Engine emitted a macOS certificate diagnostic. An earlier invocation without explicit log path crashed in Godot's log rotation due to user-directory access. Use a writable explicit log path and disposable save location. Import also emitted exit resource diagnostics. Warning-free execution is not claimed.

## StoryDirector interface and ownership

`world.story` is a RefCounted director. `configure(world)` binds it, creates its panel and loads JSON. `room_loaded(world, room)` configures on first use and closes the panel. `interact(world) -> bool` consumes an eligible inspection; `update(world, dt)` drains deferred events/saves/announcements; `draw_room(world)` draws provisional markers and prompt.

`report(event_id: String, context: Dictionary = {}) -> void` evaluates rules immediately unless `world.transition > 0`, when it queues them. Context is retained in the queue but not interpreted. Rules currently implement `set_flag`, `objective`, `announce`; `request_cutin` is a no-op. Encounter and hazard dispatch are NOT implemented.

`has(flag_id: String) -> bool` reads existing `world.expansion_flags`. `set_flag(flag_id: String) -> bool` validates the new namespace, returns false if already set, writes a boolean into that same dictionary, marks dirty and attempts existing `world.save_progress()` only outside transitions and test mode. A failed save remains dirty for retry. Save version stays 8; no second save store. `objective_override() -> String` derives the first armed objective text from rules and persisted flags. Existing early objectives retain precedence.

Writable ID syntax currently accepts a single slash: `(disc|evt|trap|enc|obj)/[a-z][a-z0-9_]*`, max 48 characters. Existing legacy flags can be read as prerequisites but not written by set_flag.

Objects: contract-1 JSON with `objects` array, `id`, `room`, `at:[x,y]`, `kind`; optional `radius` (65), `requires`, `persistent` (true), `once` (false), `title`, `description`, `pages`, `prompt`, `event`. Rules: contract-1 JSON with `rules` array, `trigger`, `requires`, `effects` containing `kind`, `id` or `text`. See laboratory JSON for actual examples.

Fixture IDs: `disc/r0_int01_note`, `disc/r0_int01_machine`, `disc/r0_int01_memorial`, `disc/r0_int01_switch`; events `evt/int01_inspect`, `evt/int01_machine`, `evt/int01_activate`; activation sets `trap/int01_power`. These are proposals, not confirmed reservations.

## Remaining work and known limitations

1. Harden rules validation: malformed rule/effect rows currently can fail at runtime; unknown effects silently do nothing. Object validator accepts some unused metadata; unknown fields are not rejected. No cross-reference, full placement or Room Creator validator command exists yet.
2. Optional object `cinematic`, `objective`, `text_id`, `art`, `audio` are validated but not consumed. Rule-based objective works; machine discovery currently has no corresponding objective rule. Asset fallback is a procedural rectangle with no audio playback.
3. Gamepad opening binding is missing; panel uses built-in UI actions but controller flow is unverified. Raw E release can advance the newly opened panel immediately; test and fix opening-release suppression. Input ownership, focus loss, HUD conflicts and paused/transition cancellation require real-input tests.
4. `report` queues only while transition > 0, not every cinematic ownership phase. `set_flag` mutates flags during a transition while deferring only the save. Align with PM's full deferral contract. Bound event queue and failed-save retry cadence. No hazard on_flag or encounter dispatch exists.
5. Discovery events replay on repeat inspection; determine desired first-discovery versus repeated-interaction semantics. Persistent flag is currently set when opening rather than completing reading.
6. Production draw hook runs before the inherited world drawing and may be overpainted. Demo overrides drawing and avoids that issue. Placement exclusion uses endpoint circles, not the full automatic trigger-band geometry; validate full bounds, edges and object overlaps.
7. Demo replaces room geometry after inherited construction and borrows room 0 identity. It is only an isolated fixture, not a production room. Its separate demo save path is not a new save format, but production disk persistence/death/reload have not been tested.
8. Export include filters have NOT been updated for data/story JSON. Pack inclusion verification is pending. Tests/demo remain excluded by existing export rules.
9. Run full existing E-interaction, automatic passage, cinematic hang, death/reload, old-save and cross-process persistence suites; baseline/preservation guards; malformed/missing-content tests; real keyboard/gamepad checks; native rendered captures. No captures or full regression results are delivered yet.
10. User-requested inspection UI and five kinds expand PR80's proposed announcement-only contract. PM reconciliation, ST-05 creator approval and Alpha 0.7 integration-base selection remain pending.

## Changed-file inventory

- scripts/world.gd: six additive hooks.
- scripts/story/object_definition.gd: object data validator.
- scripts/story/inspection_panel.gd: inspection UI.
- scripts/story/story_director.gd: runtime coordinator and persistence adapter.
- data/story/objects.json, data/story/rules.json: empty production collections.
- tests/story_demo/demo.gd, demo.tscn: isolated laboratory.
- tests/story_demo/objects.json, rules.json: provisional fixtures.
- tests/story_demo/smoke.gd: eleven-check smoke suite.
- docs/int01/PM_HANDOFF.md, SMOKE.log: handoff and evidence.

Generated untracked .uid and .import files in the local checkout are deliberately not committed. No inherited tracked assets, movement files, save functions or approved dialogue changed. Next owner: Alpha 0.7 coordinating Codex; first action is inspect this commit and fix/expand the identified input and validation gaps before integration.
