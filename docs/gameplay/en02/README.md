# EN-02 isolated combat behavior review

Creator-review candidate, 24 October 2026. Source pin: PR87 `5172db6898f3efc35b74f3c134293049165b9bf7`. Owner task `/root/en02`; reserved branch `prototype/en02-behaviors`. This is an additive experiment, not an approved production enemy or placement.

Run either `scenes/en02/skirmisher.tscn` or `scenes/en02/slime.tscn` with Godot 4.6.1. Example:

```powershell
& 'PATH\Godot_v4.6.1-stable_win64_console.exe' --path . --scene res://scenes/en02/skirmisher.tscn
```

Use A/D, Space, Shift, J attack, F parry, R kunai, T element. F6 restarts the laboratory. The actual approved controller and existing sprite bytes are reused. All abilities are enabled only inside this optional lab. The interactive lab never loads or writes campaign saves. Completion persists for the current lab session; replay resets it. The automated fixture separately exercises the actual v8 serializer/loader in disposable storage.

Two candidates are available:

- **Reactive skirmisher:** existing patrol/pursuit/committed strike, plus one 60px retreat when an approaching player dashes. Repositioning happens only before the windup, has a 2s cooldown and cannot cross its extra edge clearance. Unsafe retreats become recovery. The inherited guard artwork is a temporary behavior proxy, not a new faction.
- **Compressed ground lunge:** a labelled vector/debug silhouette compresses for 0.70s, moves up to 120px on the same validated horizontal platform, strikes once through the existing melee code, lands without damage and recovers for 1.10s. This is deliberately a ground lunge. PR87 has no vertical navigation/physical hop contract; no hidden jump or moving hurtbox exception was invented. Dedicated slime anticipation/attack/hurt/death drawings remain missing.

Yellow marks show territory and additional retreat margin. The pale circle is a 42px radius reference, **not** a physical collider or exact melee hit shape. The unchanged world uses its existing reach, height and facing conditions. State names and geometric cues make warnings understandable without relying on color alone.

## Source and ownership

Only `scripts/en02/`, `scenes/en02/`, `tests/en02/`, `docs/gameplay/en02/` are added. PR87's config, Encounter, enemy, guard, world, player, save and hazard modules stay byte-identical. No PR82 hazard import. EN01 and HAZ01 ownership remains with their existing specialists. GP09 is read-only reference, not copied or replaced.

The demo world's `spawn_enemy` override substitutes the candidate only when the unchanged Encounter requests its enemy class and the isolated lab has finished startup. It then delegates to the real `world.spawn_enemy`. Encounter still validates the complete batch, initializes members, registers defeat, queues completion during lost control, serializes existing keys and disposes members. Enemy strikes delegate to the real inherited `Enemy._physics_process` strike branch: its LOS/facing/parry/player.damage behavior is the only damage source.

The literal saved key is `en01/en02/<behavior>` because EN01 owns its existing prefix. No new save field or story flag is added. PR87 alone does not contain the full INT01 production composition. Its documented no-StoryDirector fallback is tested here; current INT01/GP09 combined-tree acceptance remains separate.

**Inherited source divergence:** PR87's world opening differs from Candidate3 `c2170032` and the approved survivor-search text. The laboratory banner is noncanonical, and this work does not fix or replace shared world.gd. Integration must reconcile exact approved copy in the owner's combined source. WD01's 21-room/29-link graph, all gates and creator map decisions are untouched.

See [balance and ecology](BALANCE_AND_ECOLOGY.md), [validation](QA.md), and [review handoff](HANDOFF.md). Native recordings are private local review evidence; no new art, screenshots, packs or binary files are uploaded by this change. No merge, release or production placement is authorized.
