# Survey of existing systems (read at `c2170032`)

Read before assigning architecture. File and line references are to that SHA. Everything below is observed in code, not assumed.

## 1. Progression and persistence

- `scripts/world.gd` owns all progression state: `guard_defeated`, `boss_defeated`, `completed`, `skyworks_restored`, `secret`, `checkpoint_room`, `checkpoint_position`, and four Dictionaries that already persist as String to bool maps: `expansion_flags`, `relay_fragments`, `cleared_encounters`, `opened_kunai_gates`.
- `save_progress()` writes one JSON file (`user://silent_district_alpha_v3.json`, `"version": 8`). `load_progress()` reads every dictionary through `saved_flags()`, which keeps only String keys with bool true/false values. Values that are numbers or strings are dropped silently.
- A second persistence layer, MetSys, stores map discovery and a "stored object" map under `"metsys"` inside the same JSON, plus `silent_district/<id>` tokens for the main progress flags.
- `tools/verify_tr05_preservation.py` compares `save_progress`, `load_progress`, `configure_input`, `can_enter`, `world_edges`, `room_size`, `left_exit_position`, `right_exit_position`, `recover_from_fall`, `add_platform` byte-for-byte against PR37. **Any edit to those functions fails the guard.** This is the strongest constraint on the event and save design.
- `expansion_flags` is already used for stable string ids: `junction_return`, `lore_<room>`.

## 2. Interactions

- `interact()` in world.gd (E key) is a chain: checkpoint distance checks for R0, R3, R7 with hardcoded coordinates, then `expansion.interact`, `extension.interact`, then plain doorway requests when the player is within 105 px of an exit unless `cinematic_transitions.automatic` owns that exit.
- Lore notes (`LORE` and `NOTES` in world_expansion.gd) are proximity triggers in `update()` (65 px), set `expansion_flags["lore_<room>"]`, save, and call `announce(text, 8)`. These are the only existing "discovery" objects. No prompt is drawn; a small paper rect is drawn until read.
- Relay sigils (`route_extension.gd`) set `relay_fragments[id]` and announce "Relay sigil recovered".
- Kunai gates (`create_kunai_gate(id, element, at, height)`) persist in `opened_kunai_gates`.

## 3. Text and objectives

- `announce(text, seconds)` stores a single string and time. A new announcement overwrites the previous one. There is no queue, no dialogue box, no speaker, no history.
- `current_objective()` is a fixed priority chain of `if` statements returning strings; it is displayed in HUD and map. ST-04 approved strings occupy the opening state and the R11 state. Wherever a new objective is added it must keep that chain and its existing order.

## 4. Enemies and encounters

- `Guard` (scripts/guard.gd, 74 lines) is a Node2D with `hp`, `state` (patrol, windup, strike, stunned, recover), patrol bounds derived from the surface it stands on, `defeated` signal, sprite from `assets/web/sentinels_strip.png`. `StormKeeper` extends it with phases and attack kinds.
- `world.spawn_enemy(at, is_boss, is_required, enemy_script)` is the single spawn path. Encounter persistence uses `enemy.set_meta("persistent_id", id)`; `on_enemy_defeated` writes `cleared_encounters[id]` and saves. Rooms re-check `cleared_encounters` when they are built. This is the reusable encounter contract.
- Existing encounters: R1 three guards (one required, gating Windstep), R2 one, R4 two, R5 two, R6 Tide Warden (boss, required), R8 Intake Sentinel, R9 Terrace Sentinel, R12 Storm Keeper, expansion rooms one lane guard each (`expansion_guard_<room>`).
- There is one sentinel sprite sheet and one boss sheet. New enemy visuals are an ART-09 dependency.

## 5. Hazards and traps

- Water pits in R2, R4, R5: falling costs 1 HP and returns Kaze to the room entry (`recover_from_fall`). LD-05 only changed the water drawing.
- Steam/vent rects (`hazards` in world_expansion.gd): in R15, R18, R19 a rect (80 x 90) at x 650 near the floor; active on a fixed 4 s cycle (`fmod(age, 4.0) >= 3.0`), damage through `player.damage(from)` which respects 1.2 s invulnerability. The telegraph is drawn but has no state flag.
- No hazard reads world state today. No moving traps, no spikes, no timed doors.

## 6. Presentation and TR-08 hooks

- `cinematic_transitions.gd` owns automatic doorway and stair transitions; `automatic(w, from, to)` tells the E-key chain to skip those exits. TR-08 (`tr08_*.gd`) plays embodied clips for Canal and stair and calls the standard room request, so it already does not own progression. Hang fix `eb3cc0fa` established the rule: an aborted cinematic must leave gameplay in a recoverable, re-armed state.
- There is no general cinematic API for story beats. PR #78 (Cut-In Maker) is an unmerged tooling pilot for short cut-ins built on TR-08.

## 7. Reusable versus missing

| Need | Reusable now | Missing |
| --- | --- | --- |
| Discovery persistence | `expansion_flags` bool map | Naming convention, reporting API |
| Objective update | `current_objective()` chain | A single append-only hook |
| Encounter persistence | `persistent_id` meta plus `cleared_encounters` | Encounter definitions as data, trigger-on-discovery |
| Enemy behavior | Guard base class, `spawn_enemy` | Additional behavior scripts, sprites |
| Hazards | `hazards` rect list, `player.damage` | Spec with telegraph/state gate |
| Text | `announce` single line | Queue (a minimal one) and any dialogue UI (not approved) |
| Cinematic | TR-08 transitions | Story cut-in API (not approved to build) |
| Interactables | Proximity pattern in world_expansion.gd | Shared base with prompt, priority and door/checkpoint separation |
