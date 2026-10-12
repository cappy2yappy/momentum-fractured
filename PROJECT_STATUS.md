# Momentum Fractured / Kaze — Project Status

Updated: 2026-10-11 (America/New_York)
Engine: Godot 4.6.1.stable.official.14d19694e
Development branch: `codex/alpha-0.5-completion-2026-10-11`
Baseline: `origin/codex/parity-validation-2026-09-30` at `2ec0a1d`.
Milestone: development candidate; Alpha 0.5 acceptance is NOT declared complete.

## Baseline and branch audit

| Remote branch | Tip inspected | Finding |
| --- | --- | --- |
| main | 1a33d28 | Legacy four-room project/status; not the newest development baseline |
| codex/phase-sweep-2026-03-23 | 1d062bb | Earlier bug sweep |
| godot-recovery | fc6acea | Recovery/export work |
| codex/alpha-0.5-baseline | fc6acea | Same recovery tip; superseded by later parity work |
| codex/web-parity-restoration | 398c772 | Authored surface, shaft, threshold/reliquary |
| codex/parity-validation-2026-09-30 | 2ec0a1d | Latest tip, adds authored canal and controlled swimming; selected |

The selected branch already calls itself Alpha 0.8.0. No separate, current Alpha 0.5 acceptance specification was found. The request is treated as closing missing core gameplay requirements, preserving existing systems and version metadata. Current direction is GDD + docs/GAMEPLAY_PARITY_MATRIX.md and docs/DEVELOPMENT_ROADMAP.md. Legacy root phase reports are historical.

Before changes, Godot imported and all four existing test suites passed. Existing shutdown leak warnings and a sandbox certificate-store diagnostic were present.

## Changes this session

- Preserve horizontal momentum while swinging; air movement no longer pulls an active swing toward run speed. Release uses gentle overspeed drag with explicit reverse-input braking.
- Dash releases an existing tether. Attaching during a dash is rejected, eliminating the unconstrained rope interaction in both directions.
- Melee, projectiles and hazards share player-owned 0.5-second damage protection; dash and Guard Veil reject damage consistently. Accepted melee applies knockback.
- Death disables attacks/dash/tether. Respawn clears combat and dash buffers. Attack animation timing no longer leaves an awaiting coroutine across scene deletion.
- Replace only prototype Room 9 with authored Fire Return Intake: dry recovery, ascent platforms, three deliberate anchors, two enemies, independent deeper-route exit, optional Fire shortcut.
- Persistent Fire seal, real kunai collision, wrong-element text, shared state at both shortcut ends, save migration defaults, and reset behavior.
- Reciprocal Room 9 ↔ Room 5 graph/doors/spawns. The Fire return does not gate the mandatory deeper route. Door also checks seal state, preventing a physical traversal exploit from activating the portal.
- Survey map/minimap show discovered closed/open shortcut state; return link is routed around Room 8. One-way campaign edge has an arrow.
- Scene navigator waits for `scene_changed` rather than a frame boundary before consuming a spawn marker. Real transition tests exposed and verified the former default-spawn regression.
- Generated Rooms 10–12 now connect player death to checkpoint recovery. Authored rooms and generated routes recover out-of-bounds falls.
- HUD owns map/loadout/pause state exclusively. Closing one overlay cannot resume gameplay behind another. Locked Guard Veil is labeled honestly.
- CI covers the new development branch and four additional regression suites.

## Verification

Run with official Godot 4.6.1. Tests use an isolated workspace APPDATA and portable editor data; no personal save was used.

| Check | Result |
| --- | --- |
| Import | Pass; no script/resource parse errors |
| alpha_08_smoke | Pass, 0 failures, all 12 rooms; anchors, combat windows, abilities, reciprocal graph/spawns |
| echo_territory_regression | Pass, 0 failures |
| swimming_regression | Pass, 0 failures |
| canal_chamber_regression | Pass, 0 failures; live water/input collisions |
| movement_combat_regression | Pass, 0 failures; 30/60/120 Hz momentum checks, real melee collision, damage immunity, knockback, death/respawn |
| fire_return_regression | Pass, 0 failures; physical blocker, real wrong/correct kunai collisions, save/reload, shared surface state |
| pause_overlay_regression | Pass, 0 failures; mixed map/loadout/Escape/resume sequences |
| traversal_stability_regression | Pass, 0 failures; real scene changes, locked portal, reciprocal arrivals, generated-route death, out-of-bounds recovery |
| Rendered source capture | Pass; OpenGL Compatibility on RTX 4070 Laptop GPU; Room 5, Room 9 and survey map visually inspected |
| Windows x86_64 export | Pass; official matching release template, embedded PCK |
| Packaged executable boot | Pass; 180-frame headless run and 180-frame Vulkan Forward+ run on RTX 4070 Laptop GPU, exit 0 |

Reproduction: import using `godot --headless --path . --import --quit`, then `godot --headless --path . --script res://tests/<suite>.gd`. Windows export: `godot --headless --path . --export-release "Windows Desktop" <output.exe>`, with official 4.6.1 templates installed. Tests reset progression: use a disposable user-data environment.

## Blockers and limits

- https://rush-line.thacap.chatgpt.site opens to “Log in to access” through ChatGPT. No live benchmark gameplay or matched captures were available. Automated controller checks do not establish subjective movement/combat parity.
- Legacy Kaze art, Drone placeholder, provisional geometry/lighting and synthesized audio remain. Five authored rooms exist, but their gameplay feel, density and art require direct acceptance testing.
- Enemy roster remains two real archetypes. Later campaign rooms and boss milestones are prototypes; dodge/parry/heavy/aerial combat and production loadout UI remain design backlog, not finished features.
- Godot emits `Failed to read the root certificate store` under this Windows sandbox, including before changes. This offline game/test/export succeeds despite it. Some test invocations without isolated APPDATA native-crashed before startup; isolated runs are reproducible.
- Smoke/canal/movement suites still report AudioStreamGeneratorPlayback leaks at shutdown. The attack SceneTreeTimer leak was eliminated; remaining audio teardown needs a focused follow-up. Do not claim a warning-free run.
- Windows build is unsigned. No full human campaign playthrough, benchmark feel acceptance, performance certification, or remote CI run is claimed.

## Next development task

Sign into the benchmark, then record a matched web/Godot playtest of Rooms 5→6→7→8→9→5. Measure short/full jumps, reversal, swing pumping/release, dash/tether changes, collision combat, Fire gate readability, swimming/shore exits and checkpoint recovery. Adjust only demonstrated discrepancies. Follow with the audio-generator shutdown regression and canonical Kaze/Drone assets; expand campaign content only after the authored loop is accepted.
