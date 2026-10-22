# EN-01 — Enemy variety and encounter framework

Alpha 0.7 prototype delivery · Gameplay Masta · 2026-10-22

Three configurable behaviors reuse the approved guard art and combat interface: a surface-bound patrolling guard, a telegraphed ranged attacker, and a dormant ambush enemy. All names and visual treatments are temporary behavior labels. No species or faction is made canonical.

Base: `integration/candidate-alpha-0.6.1-gp-ld` at `afecef1922231081807a332c511de85c7941fec8`. Repository `main` still contains the historical four-room implementation. This branch deliberately targets the integrated 21-room approved-controller foundation. No campaign room is populated or changed.

## Run the demonstrations

Use Godot **4.6.1**. Open any scene below and run it with F6, or use:

```sh
godot --path . --scene res://scenes/encounters/guard.tscn
```

| Scene | Demonstration |
| --- | --- |
| `scenes/encounters/guard.tscn` | Patrol, proximity detection, bounded pursuit, parry, return to home |
| `scenes/encounters/ranged.tscn` | Sight-blocking cover, locked-aim projectile telegraph, jumping and dashing |
| `scenes/encounters/ambush.tscn` | Dormant silhouette, proximity awakening, anticipation before melee |
| `scenes/encounters/combined.tscn` | All three members, one completion event after the final defeat |

Controls use Kaze's actual controller: A/D move, double-tap to run, Space jump (hold for height), Shift dash, J attack, F parry, R kunai, T element, Q grapple. Demos unlock the kit locally, never read or write campaign saves, and restart on death. Restart the scene to reset enemies. The inherited HUD still says Canal Haven; the EN-01 banner identifies the test.

## Verified system audit

| Existing system | Finding and reuse |
| --- | --- |
| `scripts/player.gd` | Actual CharacterBody2D controller. Existing attack signals, 0.23s parry, dash protection, movement, wall-jump and tether calculations remain byte-identical. |
| `scripts/guard.gd` | Node2D enemies with `hp`, `hit_radius`, `receive_hit`, `defeated`; base has fixed-y surface territory but lacks normal patrol travel, occlusion and return states. EN-01 extends this interface and reuses hit/stun/death handling and art. |
| `scripts/world.gd` | `enemies` collection drives unchanged melee targeting and elemental kunai hit resolution. New members register there, but do not set `is_required` or call story-boss defeat logic. |
| `scripts/kunai.gd` | Existing swept sample resolution and elemental gate behavior remain unchanged. New targets receive the same one-point kunai damage. |
| `scripts/world_expansion.gd` | Existing authored surface clamping and stable encounter identifiers inform the new metadata contract. Existing placements remain unchanged. |
| Save/progression | Existing version-8 `cleared_encounters` stores defeat flags. `expansion_flags` provides read-only story activation. No new schema version, save identity, migration, ability grant or narrative flag is introduced. |
| Room Creator | Not present on this base. A standalone JSON metadata adapter is provided below; editor placement/UI integration belongs to the future coordinated Level Masta task. |

## Room Creator metadata contract, version 1

The canonical validator is `scripts/encounters/config.gd`. Submit a nonempty JSON array to `Encounter.configure(world, entries)` only after room surfaces and collisions exist. Entries contain data only; arbitrary scripts, resource paths and unknown fields are rejected. Invalid batches spawn nothing. Examples are in `scenes/encounters/*.json`.

Required fields: `version: 1`, stable `id`, `position: [x,y]` at the enemy's feet, and `territory: [left_x,right_x]`. Coordinates are room-local pixels. The whole territory must fit one horizontal authored surface, with 42px edge margins, at least 60px width, and no solid obstruction through the enemy's body corridor. Slopes, moving platforms and cross-platform navigation are unsupported.

| Optional field | Default | Allowed values / meaning |
| --- | --- | --- |
| `type` | `guard` | `guard`, `ranged`, `ambush` |
| `activation` | `proximity` | `immediate`, `proximity`, `story`; immediate still has grace |
| `story_flag` | empty | Required stable `expansion_flags` key for story activation |
| `activation_distance` | 500 | 80–1200px; proximity also requires clear sight |
| `aggression_distance` | 450 | 80–1200px |
| `recovery_distance` | 650 | 80–1600px, at least aggression distance |
| `lose_sight_time` | 0.8 | 0.2–5 seconds before pursuit returns home |
| `speed` | 105 | 0–240px/s; guard idle patrol uses 45% |
| `hp` | 6 | Integer 1–30 |
| `attack_range` | 88 | 40–130px; melee hit adds existing 42px hit radius |
| `windup` | 0.65 | 0.48–3 seconds; aim/facing locks at start |
| `active_time` | 0.16 | 0.05–0.25 seconds; melee checks damage once on entry |
| `recovery_time` | 1.0 | 0.7–5 seconds, no attack during recovery |
| `projectile_speed` | 330 | 100–500px/s |
| `projectile_lifetime` | 3.0 | 0.2–5 seconds |
| `spawn_grace` | 1.0 | 0.8–5 seconds; visible awakening, then full attack windup |
| `persistent` | false | Boolean; stable defeat storage when true |
| `completion_event` | empty | Stable event label; all matching members must be defeated |

Identifiers use letters, digits, underscore, hyphen or slash, up to 96 characters. Use room/encounter/member names globally unique across the campaign; changing an ID creates a new save identity. Duplicate active member IDs are rejected. Numbers must be finite; no permissive string/boolean conversion.

```gdscript
var runtime = preload("res://scripts/encounters/encounter.gd").new()
world.add_child(runtime) # Direct child, identity transform, room-local coordinates.
runtime.completed.connect(on_encounter_completed)
runtime.persistence_failed.connect(on_encounter_save_failed)
var errors = runtime.configure(world, json_entries)
if not errors.is_empty():
    runtime.queue_free()
    push_error(str(errors))
```

## Spawn, persistence and completion ownership

The runtime owns its enemies and enemy projectiles. Explicitly call `dispose()` **before** rebuilding, unloading or respawning a room, including rebuilding the same room. A room-index change or removal of a registered member also triggers defensive cleanup. Disposal immediately disables processing and unregisters members before deferred deletion; it does not count as defeat.

On defeat, persistent members set `world.cleared_encounters["en01/" + id] = true` and call the existing serializer. A failed write emits `persistence_failed`; the session flag remains and can be included in a later successful save. A fresh load skips saved members. Nonpersistent members respawn when their runtime is recreated. No production save is used by the demos.

`completed(event_id)` fires once per runtime when all members with that event are defeated. Already-cleared members count toward the group, but an already-complete load is silent. Listeners own rewards, doors and narrative changes; none are automatic. Mixed persistent/respawning groups can complete again on a later visit. Reward listeners must be idempotent if used with those groups.

## Fairness and balancing notes

Awakening and dormant states cannot deal damage. Melee has no contact damage, locks facing at windup, respects solid cover, checks damage once and permits the existing facing parry. Projectiles lock their aim at windup, use a swept ray against terrain/player, respect cover and existing invulnerability, and can be parried from the facing direction. All attacks still deal one player health point, preserving the approved damage interface. Difficulty comes from health, speed, distance and bounded timing values.

The default sequence gives 1.0s awakening plus 0.65s first-attack telegraph and 1.0s recovery. Jump near release, hold for height, dash through a hit window or retreat behind cover. No balancing sign-off is implied by automated tests. In particular, multiple enemies can overlap telegraphs; future authored encounters need escape-route and readability review by Level Masta and Story.

Known limits: horizontal fixed-y enemies; no navigation mesh, vertical pursuit or moving-surface support; common guard placeholder art; visual cues without dedicated sound; projectile collision uses its center ray rather than the full drawn radius; no projectile pooling needed for these bounded tests; no Room Creator UI integration; no Windows/controller-device/manual feel approval. Captures and tests use scripted inputs through Kaze's real controller and native macOS rendering, not a human playtest.

## Validation and evidence

```sh
python3 tools/run_en01_qa.py --godot /path/to/godot
python3 tools/run_en01_qa.py --godot /path/to/godot --rendered
godot --path . --audio-driver Dummy --script tests/en01/capture.gd -- --test --output=/absolute/capture/folder
```

The runner copies legacy test scripts to disposable storage and redirects only their `user://` fixture paths. Production code and assertions remain unchanged. See `evidence/` for retained logs, results and native gameplay PNGs. Headless logs contain the macOS system-certificate lookup warning (`get_system_ca_certificates`); no script errors or failed assertions were observed. The native run completes without that warning. The original player, world, guard, kunai, campaign geometry and artwork have no tracked changes.
