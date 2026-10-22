# Shared technical contracts v1 (PROPOSED, pending PM sign-off at gate A0)

Goal: one lightweight path from "something happened in the world" to "state changed and persisted", without a second event manager, second save format or cinematic-owned progression.

## 1. One director, no competing managers

A single `StoryDirector` (RefCounted, new file `scripts/story/story_director.gd`, owned by `world` as `world.story`) is the only place story events are reported. INT-01 owns it. EN-01, HAZ-01 and ST-05 consume it; they must not create their own bus, autoload, signal hub or flag store. Existing modules (`world_expansion`, `route_extension`, `skyworks_region`, TR-08) keep working untouched and may adopt it later by explicit work order.

API (exact names are binding for v1):

```
story.report(event_id: String, context: Dictionary = {}) -> void   # discovery, defeat, interact, enter, etc.
story.has(flag_id: String) -> bool                                  # read-only flag query
story.set_flag(flag_id: String) -> bool                             # idempotent; true only on first set; saves once
story.objective_override() -> String                                # "" when none; see section 5
story.room_loaded(world, room: int) -> void                         # called from build_room
story.interact(world) -> bool                                       # called from interact(), after existing handlers
story.update(world, dt) -> void                                     # per physics tick, after expansion.update
```

`report` evaluates a data table of rules (`data/story/rules.json`, section 6). Rules are the only way an event causes an effect. Effects are a closed set: `set_flag`, `announce`, `objective`, `spawn_encounter`, `arm_hazard`, `request_cutin`. New effect kinds need a contract bump.

## 2. Event and flag identifiers

- Lowercase ASCII `snake_case` segments separated by `/`, max 48 chars, never reused, never renamed after a build has shipped it (rename = new id plus a documented alias read).
- Prefixes: `disc/<room>_<slug>` discovery, `evt/<slug>` narrative event, `trap/<slug>` trap state, `enc/<slug>` encounter, `obj/<slug>` objective step. Example: `disc/r14_old_route_marks`.
- Existing ids are untouched and keep their own prefixes: `lore_<room>`, `junction_return`, `skyworks_wind_intake`, `silent_district/*`, encounter ids such as `intake_sentinel`. The director may READ these (so a rule can depend on "storm_keeper cleared") but never writes them.

## 3. Persistence: no new save format, no guard change

- Story flags persist in the **existing** `expansion_flags` Dictionary under the prefixes above. Encounters persist in the existing `cleared_encounters` via the existing `persistent_id` meta. Opened gates persist in `opened_kunai_gates`.
- Rationale: `save_progress` and `load_progress` are byte-locked against PR37 by `tools/verify_tr05_preservation.py`. Using the existing dictionaries means **no edit to those functions, save version stays 8, old saves load unchanged, new saves load in old builds** (unknown keys are ignored harmlessly).
- Limits to design around: `saved_flags` keeps only String to bool pairs. Counters and timers are not persistable; represent progress as separate boolean flags (for example `disc/r14_a`, `disc/r14_b`). Hazard phase is never saved; trap state that must persist is a boolean flag.
- `story.set_flag` writes into `world.expansion_flags` and calls `world.save_progress()` at most once per call, and never in `test_mode` (existing behavior). It must not save during a cinematic transition (`world.transition > 0`) to avoid the hang class of bug; it queues the save for the next tick.
- Any proposal that needs a new save key requires a PM-approved contract bump, a deliberate and narrow guard exception (as done for ST-04), save-migration tests with old fixture saves, and a rollback note.

## 4. Interactable story objects (INT-01)

- Data record: `{id, room, at: [x,y], radius (default 65), prompt, kind: "examine"|"activate"|"collect", once: bool, requires: [flag_ids], sets: [flag_ids], text_id}`.
- Reuse the existing proximity pattern. E-key objects register in `story.interact`; passive "walk-over" discoveries (like current lore notes) use `story.update`.
- Priority and separation: E handlers run in this order: existing checkpoints, expansion, extension, **story objects**, doorway requests. A story object is invalid if its radius circle intersects any door trigger, checkpoint circle (R0 95, R3 115, R7 140, R16 85, R20 85, R11 100), or `cinematic_transitions.automatic` trigger band. A unit test enumerates all records and fails on overlap. Objects must not sit on a platform edge where a wall jump needs the space.
- Prompt drawing: one shared prompt style, drawn in the world `_draw` path through `story.draw_room(world)`. No per-object scripts.
- Text surface: v1 is the existing `announce(text, seconds)`. The director adds a minimal FIFO of at most 3 pending lines so two discoveries cannot erase each other, and an announcement never replaces a higher-priority one (objective, checkpoint, save failure). No dialogue box or speaker UI is built without ST-05 plus creator approval.

## 5. Narrative events and objectives (ST-05)

- Beats are data rows, never code: `{id, trigger: event_id, requires, effects}`.
- Objectives: `current_objective()` gains exactly one new line, inserted **after all existing early-game lines and before the final "restored" line pattern as the PM approves**, which asks the director for an override string. The director returns "" unless a creator-approved `obj/*` rule is armed. ST-04 strings (opening, Windstep, Foundry Rest Station) cannot be overridden; a test pins them. Adding that hook is a two-line change to a non-guarded function, flagged for PM review.
- No new canonical text ships without an APPROVED row in ROOM_MATRIX.md. Placeholder text in demos is prefixed `[TEST FIXTURE]` and a build gate scans shipped data for that prefix.

## 6. Data files

- `data/story/rules.json` (events to effects), `data/story/objects.json` (interactables), `data/encounters/*.json` (EN-01), `data/hazards/*.json` (HAZ-01). All JSON, versioned with `"contract": 1`, validated by one headless script `tools/story/validate_data.gd` (unknown ids, unknown effect kinds, overlapping interactables, flags referenced but never settable, orphan encounters).
- Data lives outside `scripts/` so creator-approved content can change without code review of mechanics. Export filter: `data/story/*`, `data/encounters/*`, `data/hazards/*` must be added by the same narrow `include_filter` change in the same PR that adds the first data file (the build pack check must list them).

## 7. Encounters triggered by discoveries (EN-01)

- Encounter definition: `{id (= persistent_id), room, spawns: [{at, script, hp?, behavior_params}], trigger: "room_enter"|event_id, one_shot: bool, required: bool, clears_flag}`.
- All spawns go through `world.spawn_enemy` so patrol bounds, `defeated` signal and `cleared_encounters` persistence are unchanged. New behaviors are new scripts extending `guard.gd` (as `storm_keeper.gd` does), never edits to `guard.gd`.
- A discovery-triggered encounter spawns only when the player is on the ground and at least 400 px from the spawn point and not within a transition; it gets a 0.6 s warning (visual and announce-free) so it cannot hit on spawn. `required` encounters never gate progression in v1 (no new hard gates); `required` stays reserved for existing Windstep and boss logic.
- Hit points, damage and speed follow a budget table in WORK_ORDERS.md; no hp inflation to pad time.

## 8. Hazards activated by world state (HAZ-01)

- Spec: `{id, kind: "vent"|"pulse"|"drip"|"swing"|..., rect, cycle, telegraph, active, damage:1, enabled_when: [flag_ids], disabled_when: [flag_ids], room}`.
- Reuse `player.damage(from)`; no new damage path, no change to invulnerability (1.2 s) or hurt handling. Telegraph at least 0.6 s with distinct visuals and, when audio exists, a distinct cue. Cycle phase derives from `player.age` like existing vents for determinism in tests.
- State gating reads flags at `room_loaded` and again when the director reports a flag change in the current room (`story.on_flag(flag_id)`). A hazard never changes while the player stands inside its rect.
- Placement rules (validated by a probe): never on a recovery floor, never on the only route without a bypass or timing window, never in a door approach (200 px), never overlapping an interactable or checkpoint, always inside existing platform geometry (no new colliders; hazards are damage volumes, not walls).

## 9. Cinematics without owning progression (TR-08 boundary)

- Story code may only `request_cutin(id)`; the request is fire-and-forget. The progression effect (flag, objective, spawn) is applied by the director **before** the request is made, and is independent of whether the cinematic plays, is skipped, is aborted by pause, or fails. A cinematic never calls `set_flag`, `report`, `spawn_enemy` or saves.
- Until a cut-in system is approved and built, `request_cutin` is a no-op that logs. TR-08 doorway and stair transitions are unchanged and are not extended to carry story. Reduced-motion (F6) and `--tr08-off` must produce identical gameplay state.
- Regression rule: any story effect that fires during a transition is deferred until `world.transition == 0` and control is restored, mirroring the hang fix.

## 10. Ownership and change control

| Item | Owner | Change needs |
| --- | --- | --- |
| StoryDirector, rules schema, flag naming | INT-01 | PM contract bump |
| Encounter schema, enemy scripts | EN-01 | PM review; guard.gd untouched |
| Hazard schema | HAZ-01 | PM review |
| Rules rows and text | ST-05 | Creator approval per row |
| Sprites and effects | ART-09 | Creator approval; manifest hashes |
| world.gd hook lines (5 call sites) | INT-01 only, one PR | PM review of the diff; guard exceptions only if a guarded function is touched (it must not be) |

Hook call sites in `world.gd` (all outside the guarded functions): `build_room` after `expansion.build_room(self, room)`; `interact` after `extension.interact`; `_physics_process` after `expansion.update`; `_draw` after expansion draw; `current_objective` one override line. Anything beyond these is a contract bump.
