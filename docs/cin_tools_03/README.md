# CIN-TOOLS-03 — Cinematic Studio 2.0

Draft creator prototype, stacked on Cut-In Maker PR #78 at `af184380fb690f2c19bac69960b7aacce50f9ff2`. This extends that tool's preview, transport, native timelines and presentation hierarchy. Normal gameplay still starts at the unchanged main scene.

## Try it

Use Godot **4.6.1**. On macOS, double-click `tools/cin_tools_03/launch.command`. Else open the root project and run `tools/cin_tools_03/studio.tscn` as the current scene.

1. In **Animator**, scrub the existing slider to about 1.9 seconds. Choose Torso, Hair, a limb or its child joint. Change position/rotation, then **Key pose**. Unkeyed adjustments are previews and disappear when you scrub. Undo retains up to 32 edits.
2. **Hybrid** follows the clip's native mode keys: intact approved run-sheet frames until 1.5 seconds, then ART-08 candidate cutout braking and settle. Rig only / Sprite only are inspection overrides, not saved mode edits. Show joint handles helps inspect the hierarchy.
3. **Save** writes `sprint_stop.tres` and `director_shots.tres` into the engine's `user://cin_tools_03` subfolder. Hover over the save confirmation to see the absolute folder path. **Reload** restores the saved resources. It does not load, overwrite or migrate game saves.
4. Choose **Director** in the same workspace menu. Its 8.4-second native timeline uses the same 4.2-second clip twice, with a second-shot framing change. Edits to a joint appear in both shots.
5. In Director, choose **Shot framing**, change position/rotation/zoom, then **Key pose**. Save and reload preserve these native shot tracks too. Camera framing transforms the presentation canvas, never the gameplay camera. The prototype has two fixed shots; edit shot order, duration and clip-time keys in Godot's Animation panel.
6. The three original Cut-In Maker presets remain in the same menu. They retain their original authoring and guarded TR-08 integration. Playing or scrubbing Studio's Director does not request a room.

Reduced motion holds the final actor pose with fixed framing for the same timeline duration. It is a deliberately static alternative, not a promise that arbitrary future creator-authored clips automatically meet a motion standard.

## Native authoring and reuse

- `presets/cutins/studio/actor.tscn`: ordinary Node2D FK joints, Sprite2D cutouts, an intact sprite-sheet node, and AnimationPlayer. Edit the native hierarchy to change rest pivots, joint parenting, source regions or art assignment. This is a seeded rig, not an automatic flat-image rigging system.
- `sprint_stop.tres`: reusable Animation resource with joint transforms, root motion, discrete sprite frames and sprite/rig visibility selection. Both saved seed workspaces reference this external resource. Session edits are detached from repository seed files; persistence uses separate creator resources.
- `animator.tscn` / `director.tscn`: Cut-In Maker stage instances reconstructed from its existing preset. Outer AnimationPlayer keys `clip_time`; the actor's manual AnimationPlayer seeks the shared clip at that local time. A clip reset at 4.2 seconds supplies the second use. Seeking is deterministic and presentation-only.
- `tools/cin_tools_03/studio.gd` extends `cin_tools_01/preview.gd`. The shared file's only change is an overridable `preset_path(choice)` function with unchanged default behavior.
- Save uses native `.tres` resources. To publish a reviewed creator edit, explicitly copy its saved resource into a new reviewed development change and update references. This prototype does not auto-write repository assets or replace live animations.

The seed builder `tools/cin_tools_03/build.gd` reproduces the initial resources. It overwrites the four seed resources: do not run it over authored repository changes. Normal launch never invokes it.

## Review evidence

[Native-speed playback](captures/native-speed.mp4), [Animator](captures/01_animator.png), [keyed pose](captures/02_keyed_pose.png), [Director reuse](captures/03_director_reuse.png), [reduced motion](captures/04_reduced.png). Recordings are silent, actual post-draw wall-clock samples without fixed-FPS/movie flags. They show a candidate timing study, not completed gait or braking art.

[QA and reproduction](QA.md), [fidelity limitations](LIMITATIONS.md), [PR/ownership inspection](INTERFACES.md), [handoff](HANDOFF.md).
