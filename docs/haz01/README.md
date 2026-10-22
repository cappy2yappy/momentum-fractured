# HAZ-01 — Environmental Trap and Hazard Toolkit

Level Masta · Alpha 0.7 prototype · Godot 4.6.1

Three reusable prototypes: a contact-triggered collapsing platform, timed steam vent, and timed electrical conduit. The electrical conduit uses the requested timed-danger alternative; elemental disabling and the mechanical crusher are deferred. All work is isolated from the campaign.

Base: `feature/ld05-intentional-world-boundaries` at `30155f5`. Feature: `feature/haz01-toolkit`. The creator explicitly selected this base. No production rooms, roof configuration, exits, progression, player physics, or approved art are edited.

## Native demonstration

Open `scenes/haz01/course.tscn` in Godot 4.6.1 and run the current scene (F6), or:

```sh
godot --path . res://scenes/haz01/course.tscn
```

A/D walks, double-tap sprints, Space jumps, Shift dashes, and hold Q grapples. The course grants only existing dash/tether abilities locally. Backspace re-enters, F2 toggles hazards, F5 saves, F9 loads, Escape closes. The final clear floor is a turnaround/exit staging area, not a campaign doorway. A permanent floor below the collapse gives a nonlethal escape. The course save is `user://haz01_course_only.json`; campaign saves are never read or written.

The prototype art uses labeled bounds, static hatch marks and a timer bar. Warning/active/recovery cues do not require flashing, shaking, particles, or camera motion. These cues are always reduced-motion compatible; no additional accessibility toggle is necessary. Player visuals remain unchanged.

Native macOS OpenGL captures: [safe](evidence/course_1.png), [warning](evidence/course_2.png), [active](evidence/course_3.png). These are engine captures of the standalone scene, not an exported release or a human acceptance playthrough.

## Audit and design decisions

| Existing implementation | Finding and use |
| --- | --- |
| `scripts/world_expansion.gd`, `update` / `draw_room` | R15/R18/R19 use rectangles with a four-second cycle based on player age and point-based contact. Left intact. New instances use independent physics clocks and actual capsule overlaps. |
| `scripts/player.gd`, `damage` | One HP per accepted hit, 1.2-second immunity, knockback and hurt signal. Reused directly; no parallel health system. Dash grants its existing immunity. |
| `scripts/world.gd`, `respawn` / `recover_from_fall` | Rebuilds rooms and restores checkpoint/entry poses with immunity. New integration must reset hazards before enabling player control. The course demonstrates this separately. |
| `scripts/world.gd`, `add_platform` | Layer-1 static rectangular surfaces; some expansion ledges are one-way. Collapse uses a full solid layer-1 surface with deferred collision removal. |
| `scripts/player.gd`, `has_traversal_requirement` | Existing requirement identifiers reused. Missing requirements suppress the hazard; they do not grant abilities or lock a route. |
| `scripts/world.gd`, save/load | Existing progression dictionaries and checkpoint restoration. New toolkit snapshots persist only disabled state when configured; active phase is never restored. Campaign save schema unchanged. |
| `scripts/grapple_anchor.gd` and player tether | Existing eligibility, range and clearance used by course. No movement additions. |
| `scripts/room_boundary.gd`, room generation | Current roof decision and 21 room geometries inherited unchanged. No hazards are injected into production generation. |

## Placement contract v1

Attach `scripts/hazards/environmental_hazard.gd` or instantiate `scenes/haz01/hazard.tscn`. Assign a `hazard_placement.gd` resource in the inspector, bind `hazard.player` to Kaze before adding it to the tree, then call `reset_room(saved_state)` after spawn placement. See the three `.tres` examples under `scenes/haz01`.

| Field | Meaning |
| --- | --- |
| `placement_id` | Nonempty unique identifier within the room; namespace with room ID when stored globally. |
| `kind` | `collapse`, `steam`, or `electric`. |
| `at` | Top-left coordinates in parent-local pixels. |
| `dimensions` | Exact rectangle dimensions; finite, at least 32 × 16 pixels. Use dimensions rather than node scale. |
| `idle_seconds` | Safe period for periodic types, default 2.0. Collapse instead waits for a real landing. |
| `warning_seconds` | Predictable warning, default 1.0, minimum 0.3. Leaving a triggered platform does not cancel it. |
| `active_seconds` | Damage window or absent platform period, default 1.0. |
| `recovery_seconds` | Harmless recovery, default 1.0, minimum 0.3. Collapse stays absent until recovery ends and its volume is clear. |
| `initially_enabled` | Default enable state. |
| `prerequisite` | Empty or existing double_jump/tether/dash/stride_1/wind/fire/electric identifier. |
| `reset_rule` | `room_entry` restores defaults; `persist_disabled` honors a matching snapshot. Both discard phase/time. |

Use unrotated, unit-scale parents/instances. Runtime placement changes require rebuilding the instance so geometry and data stay aligned. These are inspector-readable resources, not a Room Creator plugin or live gizmo tool. `validation_errors()` rejects invalid dimensions, timing, kinds and requirement names before creating collision; the future importer must also enforce unique IDs and safe placement.

`set_enabled(bool)` is the event input. `enabled_changed(bool)` and `phase_changed(String)` are outputs. Re-enabling starts safely; disabling a collapse while occupied leaves it absent until clear, rather than rebuilding inside a body. A disabled or gated collapse may remain a harmless solid support when clear.

`snapshot()` returns `{version: 1, id: placement_id, disabled: bool}`. The room owner stores this by stable placement ID. `reset_room(Dictionary)` accepts only matching version/ID and boolean disabled state. Room entry, respawn and load must call reset after moving Kaze to a validated safe spawn. The course shows actual JSON disk round-trip and restart. Do not store elapsed hazard time, player position inside a danger zone, or runtime collision objects.

Steam and conduit areas monitor layer 2 and call damage only on the bound player during active phase. Collapse collision is layer 1; the reset query also checks layer 2 with a small clearance margin. Timers carry fractional remainder through transitions; contact damage uses fixed physics steps. Default project physics rate remains unchanged.

## Integration recommendations

Wait for creator-marked blueprints. R15/R18/R19 are candidates for replacing their existing periodic rectangle hazards with resource placements after review; do not silently layer both systems over the same bounds. Start with one vent and a visible safe observation area, then introduce the conduit as a timing challenge. Put collapse above reachable recovery ground with at least one permanent return route.

Reserve checkpoint, arrival, doorway trigger and landing volumes plus the player's full capsule clearance. Do not place damage zones on forced arrival paths or moving reset surfaces at a checkpoint. Keep a safe waiting pocket on both sides; assess warning length against approach speed and camera visibility. Avoid overlapping active volumes that consume an entire route or create consecutive unavoidable hits. The demo's geometry and dimensions are test fixtures, not approved campaign placements.

Before any production placement, repeat traversal checks with only legitimately earned abilities and inspect the creator's roof/exits unchanged. Difficulty balance, final art/audio, combat-with-enemies combinations, and human accessibility acceptance remain future placement-level work.

## Validation

```sh
python3 tools/haz01/run_qa.py --godot /path/to/Godot
python3 tools/verify_baseline.py
godot --path . res://scenes/haz01/course.tscn -- --haz01-capture
```

The runner bounds each suite and redirects explicit test save literals in temporary copies into disposable directories. It passes `--test` to prevent campaign loading. Tracked regression source stays unchanged. Results are under `evidence/`. Focused tests cover cycle partitions at 30/60/120/144 Hz, phase boundaries, damage capsule edges and immunity, real walk/sprint/jump/dash crossings, grapple attachment/swing, collapse landing/fall/reset occupancy, enable/disable, requirements, save/load, room restart and clear exit floor. Timing partitions are not four full rendered playthroughs. No exhaustive guarantee is made for arbitrary future placements.
