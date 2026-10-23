# Direct FK joint authoring on Mac

This continues the existing PR #100 at `7b162dd`, including its resizable layout, atomic saves, fresh-process reload and native AnimationPlayer workflow. It adds canvas manipulation to that same Studio. It does not change campaign cinematics or production character art.

[Native-speed creator demo](captures/fk-native-speed.mp4) · [Move preview](captures/fk/01_drag_preview.png) · [Rotation preview](captures/fk/02_rotate_preview.png) · [Two-shot reuse](captures/fk/04_two_shot_reuse.png)

## Try the controls

Launch `tools/cin_tools_03/launch.command` with Godot 4.6.1, as described in [MAC_GUIDE.md](MAC_GUIDE.md). Leave Reduced motion off and scrub to **1.9 seconds**, after the sprite-to-rig handover. Alternatively choose Rig only in the inspector. An intact sprite sheet has no FK deformation; Studio does not pretend that moving a hidden rig edits the flat sprite.

- **Select:** click a cyan joint dot. Hover displays its name; the selected dot and rotation grip are gold. All 18 existing FK pivots are exposed, including both arms, forearms, hands, legs, shins, boots, head, hair, ribbon, torso and roots. Only joint nodes are selectable, never the Art sprites.
- **Move:** drag a dot. Child transforms remain local to their parent and follow the FK hierarchy.
- **Rotate:** drag the small gold grip. Alt-drag also rotates; at the exact pivot, drag horizontally to avoid an undefined starting angle. Rotation and position fields remain available for precise numeric adjustment.
- **Coincident joints:** Head/Hair and Rig/Torso have separate offset dots with leader lines to the real pivots. Rotation grips avoid every other dot. The selection menu remains an exact alternative.
- **View:** Canvas Fit / 150% / 200% changes only the inspection view. Director framing stays authored independently. Markers/hit targets keep the same size in viewport pixels; cropped joints can be brought back with Fit or selected numerically.
- **Confirm:** release to finish an **unkeyed** preview, then press **Key pose**. Save refuses unkeyed changes. Several joint drags can be confirmed together; the button displays the number of pending joint poses. Joint and shot-framing previews cannot silently mix.
- **Undo/cancel:** Undo reverts a whole completed drag. After keying, Undo restores the prior clip. Escape or right-click cancels an active drag. Window focus loss, a canvas view change/resize, hidden handles or lost button state also cancel safely. A release outside the canvas ends the gesture; it does not press an inspector button.
- **Transport:** scrub/restart discard unkeyed previews. Play discards an unkeyed preview before starting the native 1.0× timeline. Canvas input never owns the slider or transport controls. Reduced motion remains static and disables pose editing.

Changing a joint position moves its FK pivot; it does not create or repaint hidden surfaces. Rig seams, overlap, foot contact, anatomical fidelity and sprite/rig handover remain candidate-art limitations. See [LIMITATIONS.md](LIMITATIONS.md).

## Save and reuse

Use the existing **Save clip + shots** / **Reload** workflow. The atomic `studio_session.tres` snapshot and standalone exports remain unchanged in format. New Hand/Boot position or rotation tracks are allowed native property tracks. A saved pose is sampled from the same Animation object in both Director shots.

The demo's actual saved output is committed separately at `presets/cutins/studio/pointer_example/`; the previous `authoring_example` remains unchanged. To inspect the new example without writing into it:

```sh
mkdir -p build/cin_tools_03/pointer_review
cp presets/cutins/studio/pointer_example/*.tres build/cin_tools_03/pointer_review/
CIN_STUDIO_SAVE_DIR="$PWD/build/cin_tools_03/pointer_review" zsh tools/cin_tools_03/launch.command
```

Press Reload, scrub to 1.9 s, select Head, then compare Shot 1 at 1.9 and Shot 2 at 6.1. Head position is `(23,-121)`, the result of the recorded `(12,-8)` local drag. The same saved clip appears in both independently framed shots. The existing numeric Torso example remains available in `authoring_example/`.

## Evidence and limits

The new pointer suite injects real `InputEventMouseMotion`, mouse buttons and Escape through `Input.parse_input_event`, normal GUI hit testing and pointer capture. It does not call the gesture callbacks to fake a drag. Selection, hover, parent-space movement, grip and Alt rotation, undo, keying, mixed-domain protection, release outside, transport and reduced preview are exercised. It tests every pivot, all 18 selection/rotation-grip layouts, 1024×640 and 1440×900, fit/150%/200%, rotated/panned/zoomed Director framing and a non-uniform FK ancestor.

The fresh-process writer additionally authors a Hand child through normal mouse events; a separate reader verifies its exported key and both shot uses. Another fresh process reloads the exact persisted output of the native recording. Focus cancellation is tested by emitting the Window focus-loss signal; this is not an OS hot-unplug/focus-switch certification. Desktop automation bound the separate Godot Project Manager rather than the CLI Studio instance, so no physical OS-pointer certification is claimed. The native demo visibly records Godot input-event dispatch and a cursor overlay.

QA-10 #101 is still a separate diagnosed harness correction awaiting PM acceptance. Its original pinned comparison is not certification for this new head. No merges, releases, generation, external media-service transfer or spending were performed. Scoped results, reproduction and retained history are in [QA.md](QA.md).
