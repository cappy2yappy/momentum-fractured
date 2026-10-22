# Alpha 0.7 isolated story presentation review

Based on PR78 `af184380fb690f2c19bac69960b7aacce50f9ff2`. ST05 reviewed from `origin/narrative/st05-discoveries`; PR80 contracts remain binding. No StoryDirector replacement, canonical additions, room placement or world hooks are included.

## Run on Mac

From this branch checkout:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path . --log-file /tmp/kaze-story-demo.log res://tools/story_cinematics/demo.tscn -- --test
```

Move with existing keyboard/gamepad controls. Press 1 for the approved opening review, 2 for the existing R14 record review, 3 for the **provisional B06 timing study**. Space or gamepad B dismisses. F6 toggles reduced motion; Escape pauses. All three return to playable control. Review templates use the existing Cut-In Maker's environment and ART08 animation candidate; no new artwork is represented as approved. No body/death/affiliation/identity is depicted by the third review.

## INT01 seam

`CutinPresenter` is a Node owned by the integrating scene. Call `configure(world)`, set `world.story.cutin_presenter = presenter` using INT01's untyped seam, and update it once per tick via `update(world, dt)`. Rules and progression belong solely to StoryDirector. The director must finish state effects before invoking `request_cutin(id)`; it must not wait for completion. IDs `opening_review`, `record_review`, `fallen_clan_review` are isolated review IDs, not approved production rule IDs. No shipping rule references these IDs.

The owner must call `cancel("room_rebuilt")` before any room rebuild/respawn/reset, including a rebuild of the same room, and remove the presenter before destroying world. This branch intentionally does not add shared hooks. Queue capacity is three; repeated pending IDs coalesce, unknown IDs fail closed. A request waits for loader completion, live player physics, unpaused state and no active TR08/embodied/staged/mixed presentation. Starting a cut-in temporarily holds only the player physics lease. An external transition interrupts it and retains input ownership. Watchdog completion, focus loss, pause and dismissal discard presentation without saving or altering progression.

## Validation (Godot 4.6.1 / Apple M4 native OpenGL)

- New lifecycle suite: **25/25** headless and **25/25** native rendered. Actual native screenshots before, three during, and after control restoration captured separately.
- Existing Cut-In Maker runtime suite: **103/103** headless.
- Approved baseline verifier: **0 failures**, approved sprite bytes intact.
- TR05 preservation verifier: **one inherited failure**, `world_expansion.build_room` differs from PR37 already in PR78. This branch's `world_expansion.gd`, `world.gd`, project settings, player and all approved artwork remain byte-identical to PR78.
- Save-byte sentinel and checkpoint/progression/camera state compared after every presentation and interruption. This presentation-only scope never writes a save; full INT01 save/reload verification belongs to its owner and combined QA.
- Keyboard and gamepad skip inputs are synthetically injected; physical-controller hardware validation remains pending.
- Three native previews are captured at wall-clock speed with post-draw timestamps, no fixed-fps acceleration; encoding helper is the existing CIN-TOOLS01 Swift tool.

Commands:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --log-file /tmp/story-headless.log --script res://tests/story_cinematics/runtime.gd -- --test
/Applications/Godot.app/Contents/MacOS/Godot --path . --log-file /tmp/story-native.log --script res://tests/story_cinematics/runtime.gd -- --test
/Applications/Godot.app/Contents/MacOS/Godot --path . --log-file /tmp/story-capture.log --script res://tests/story_cinematics/capture.gd -- --test
swift tools/cin_tools_01/encode_capture.swift build/story_cinematics/video/timing.json build/story_cinematics/previews.mp4
```

## Readiness

Presentation adapter is independently tested and ready for INT01 seam review. Combined runtime integration is **not verified**: attach only after recovering INT01, owner hooks and a single update path. Keep draft/unmerged and independent of Candidate 3. Existing 21 rooms, progression, routing and canonical text are unchanged. ST05's proposal to commit read state after display conflicts with PR80's progression-before-presentation boundary; this review applies PR80 and leaves no presentation completion callback to write state.
