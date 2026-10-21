# Recovered interfaces — inspected before implementation

Baseline: PR #64 `ed1875307e21f057add025ebebdec1e3f371e90f`. This branch is stacked directly on that read-only dependency, isolated from Wave 3 / PR #74. PR #62 head `98d639f3` supplies the ascent settle already copied into #64; no asset copying is needed. PR #57 is the earlier opt-in staged pilot; #41 is the native animation testbed / turn candidate lineage; #30 supplies the preserved ART-04 keys; #72 approved narrative copy and #74 combined integration are references only, not merged dependencies.

## Existing ownership

- `world.request_room(target, arrival)` rejects invalid/busy/locked requests, then calls `cinematic_transitions.intercept`. A true result means presentation accepted ownership of the deferred request. Routing and gate checks remain world-owned.
- `CinematicTransitions` derives endpoint intent (`endpoint`, `policy`, `automatic`), arming/cooldown, carries horizontal velocity, and counts loader requests in `begin`. Automatic side passage semantics must remain untouched.
- `tr08.intercept` owns only the staged R14↔R17 stair and grounded Canal doorway. Its `stair.releasing` / `canal.releasing` flags bypass interception when releasing the deferred request through `world.request_room`.
- `stair.begin` freezes the live body, clears touch input, plans the flight from ART-08 root motion and measured soles, and opens its CanvasLayer. `stair.release` calls the authorized world request at cover (0.30 s standard). The inherited loader remains 0.65 s; its hidden swap occurs below 0.32 s remaining.
- `world._physics_process` owns room building, pending-room clearing, arrival position and camera reset. `cinematic_transitions.arrived` and `embodied_transitions.arrived` own arrival presentation. The loader re-enables player physics at clock expiry; TR-08 holds it again until stage close.
- `tr08.stair.restore` / `canal.restore` remove proxies and restore physics when the loader is no longer active. `cancel` before TR-08 release aborts presentation; it does not promise to finish that deferred request. The new adapter must explicitly release an accepted request on skip/focus loss rather than assuming cancel does so.
- `CinematicTransitions.present` delegates TR-08 ticks and avoids a second camera owner. TR-08 uses a stage transform, not a competing gameplay Camera2D. Other stair presentation snapshots and restores gameplay zoom, position, offset and smoothing.
- `tr08_clip_library.build` resolves manifest rows to registered strips or labelled stand-ins. `tr08_clip_player.play/advance` applies pivots, facing, frame durations and signed source-pixel root motion. ART-08 cell 480×724 / pivot (240,600) / world scale 0.303125; cinematic scaling is presentation only. Candidate is not creator-approved animation.
- `F6` toggles reduced motion. TR-08 freezes its stage camera and shortens remaining clips; it never restarts a room request. `--tr05-reduced-motion` selects it initially.
- Pause/focus loss, death and unrelated room rebuilds cancel TR-08. World owns respawn/checkpoint policy. Save and progression live in world/player; presentations never write them. Tests must use disposable saves and compare persisted bytes/checkpoint fields.

## Additive adapter contract

Only the isolated demo substitutes a subclass of `CinematicTransitions`, after world `_ready`, before the fixture starts. Normal main scene and all existing TR-08 files remain byte-identical. The subclass intercepts only the pilot stair pair. Native AnimationPlayer owns presentation tracks; a boolean property track marks the handoff. Scrubbing a preset cannot request a room: it has no world reference.

Adapter states: idle → authoring presentation (owns input lease) → TR-08 presentation (TR-08 owns input) → inherited loader / arrival → idle. Transfer the input lease before calling the existing TR-08 interception. A guarded `world.request_room` re-entry delegates to the existing implementation. Skip, pause/focus loss and watchdog complete the accepted request once: hand off if necessary, explicitly release TR-08 if not yet released, then restore its presentation. Loader remains responsible for its pending request. No writes to room, pending-room, progression, checkpoint, player position or gameplay camera.

Death/respawn or an external room rebuild supersedes the accepted request: abandon stale source/target and release only the adapter's input lease; never resurrect a request into a different room or dead body. The demo has a disposable save identity assigned after world `_ready`, before the fixture starts and runs as a separate process, so its global MetSys state cannot alter a running gameplay session.
