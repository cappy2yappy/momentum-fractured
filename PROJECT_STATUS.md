# Kaze — approved Alpha 0.5 continuation

Updated: 2026-10-11 (America/New_York)
Engine: Godot 4.6.1.stable.official.14d19694e
Branch: `codex/alpha05-approved-continuation` (local; not pushed)
Candidate: Alpha 0.5.1 Development
Approved source baseline commit: `47ba3d3`

## Correct starting point

The creator selected Kaze-Silent-District-Alpha-0.5.0-Windows-x86_64/Kaze.exe and approved its feel/momentum. The project was recovered directly from that executable with GDRE Tools 2.7.4: 501 files verified/extracted, all 46 scripts decompiled, all 244 imported resources converted, zero failed/lossy conversions. See docs/BASELINE_PROVENANCE.md and docs/RECOVERY_REPORT.txt.

This branch continues that project. The earlier 12-room Godot branch was the wrong gameplay foundation and is retained separately. Its controller, scenes and assets were not transplanted here.

The selected baseline is an eight-room, MetSys-backed proving ground. Its original notes describe a larger web-demo goal; this candidate does not claim the full web campaign. Benchmark authentication remains unavailable.

## Preservation contract

- `scripts/player.gd` is byte-for-byte unchanged from the selected build's recovered source: SHA-256 `58a1c319183a993bde9abc6f639b4adaefe245f89de24e6f0f9338bc9519339d`.
- Original movement constants, swing integrator, release momentum, jump behavior, double-tap running, combo/parry, dash, animations and controls are preserved.
- Original eight rooms' collision geometry is automatically compared with docs/APPROVED_GEOMETRY.json. Existing exit elevations and anchor positions are retained.
- Existing game art is preserved. The kit portrait uses an original Kaze frame at its original aspect ratio.
- Original Godot application name/save directory and save filename are retained so existing Alpha 0.5 saves can load. Exported executable metadata names this Alpha 0.5.1 Development.

## New scope and features

- Ten connected rooms: Relay Undercroft and Signal Terrace extend the route after the original Relay Archive is restored.
- New elevated jump/tether routes, a safe Undercroft shrine, and two sentinel encounters using the existing combat system.
- Three persistent relay sigils provide a side objective; the Fire cache checks opened gate state so jumping around its geometry cannot collect the sealed reward.
- An Electric return from Signal Terrace to Echo Shrine works in both directions, has dedicated safe landings and persists across save/reload. The atlas/minimap show the discovered return and its seal/open state.
- The MetSys map contains the added rooms/regions; full atlas labels wrap and all ten rooms fit in its existing panel.
- I opens a travel kit with Kaze portrait, unlocked/locked traversal abilities and selectable elemental kunai. Click a slot or press T while paused. Map, pause and kit remain mutually exclusive.
- Pause screen includes manual Save Journey with honest failure feedback; touch controls now include kunai and element cycling.
- Save schema 5 preserves schema 4 progress and adds shrine positions, sigils and cleared annex encounters. Unknown selected elements are normalized before HUD drawing.
- Room rebuilds release stale ropes, attacks/dashes, projectiles and afterimages without changing the player controller. Death during transitions clears pending travel and restores the earned shrine.
- The recovered MetSys plugin manifest and UID-only editor load were corrected. Official plugin metadata/license and two missing translation files were restored from pinned upstream revision `0065ae8974291d1c4dfe72f55cfca0f37e3d6ef3`; existing runtime addon code/themes remain unchanged. See docs/METSYS_EDITOR_RECOVERY.md.

## Tests and build evidence

All checks used official Godot 4.6.1 and isolated workspace user data. Original downloaded executable and personal saves were not modified.

| Check | Result |
| --- | --- |
| Approved baseline before expansion | Pass: all eight rooms load, MetSys discovery, movement and overlay checks |
| approved_baseline | Pass: unchanged controller checksum, original room geometry, 400 walk speed and measured 232.56 held-jump height |
| approved_combat_swing | Pass: facing-aware melee, successful/missed parry, existing damage protection, swing rope length and exact release velocity, queued combo |
| annex_expansion | Pass: all ten rooms, relay gate, real elemental projectile collisions, sigils, two-way return, kit selection, touch bindings, transition/death cleanup |
| annex_traversal | Pass: four critical new platform jumps with actual controller inputs and collision landings, including Windstep jumps |
| save_compatibility | Pass: abilities, MetSys exploration, new shrine/return/sigils/encounters, schema 4 migration, invalid element and failed-save feedback |
| Clean source import | Pass: no script/parse/resource-load errors in a fresh copy without generated Godot cache |
| Rendered source QA | Pass: original appearance, both annexes, full atlas and travel kit visually inspected; capture fixtures use seeded progression |
| Windows export | Pass: x86_64 release, embedded PCK, compatibility renderer, map data explicitly included |
| Packaged fresh start | Pass: 180-frame headless boot, exit 0 |
| Packaged annex starts | Pass: seeded saved starts in Rooms 8 and 9, 180 rendered frames each, OpenGL on RTX 4070 Laptop GPU, exit 0; no runtime script errors |

Reproduce: import with `godot --headless --path . --import --quit`, then run each suite with `godot --headless --path . --script res://tests/<suite>.gd -- --test`. Use disposable user data: save_compatibility intentionally writes a regression-only save file. Windows export uses `godot --headless --path . --export-release "Windows Desktop" <output.exe>` and matching official templates. CI workflow is provided; no remote CI run is claimed.

## Limits and blockers

- A full human playthrough of the ten-room route has not been completed. New critical jumps and transitions are tested, but encounter balance/readability still need direct acceptance.
- This is an incremental development candidate, not a completed web-demo parity milestone. No 21-area/five-region/five-boss completion claim is made.
- Water remains the approved build's existing hazard/presentation behavior. Real swimming and larger regional/boss scope remain future work.
- The Windows sandbox emits `Failed to read the root certificate store` before/after changes. This is unrelated to offline gameplay and appears in the logs.
- Headless editor import/export still emit pre-existing MetSys/editor RID/ObjectDB cleanup diagnostics. Gameplay suites and packaged boots have no script errors; do not describe editor runs as warning-free.
- The runtime archive can be recovered, but original authoring history/comments are absent. Recovery and addon repair provenance are retained for traceability.

## Next development task

Playtest the annex loop after an existing Alpha 0.5 save, focusing on room purpose, sigil readability, encounter pressure and Electric return usefulness while keeping the approved controller intact. After this content pass, give Tide Warden one distinctive, telegraphed phase/attack sequence with parry and recovery tests. Keep aquatic traversal and further regional expansion as separate bounded additions.
