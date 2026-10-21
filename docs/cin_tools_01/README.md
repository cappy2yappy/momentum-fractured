# CIN-TOOLS-01 — Cut-In Maker

A Godot 4.6.1 native timeline prototype. Open a preset, edit its AnimationPlayer tracks, save the scene, preview, then run the isolated staircase demo. Normal `scenes/main.tscn` never installs this tool.

## Start here

1. Open the root Godot project. Duplicate `presets/cutins/special_transition.tscn` to your own scene. Open the duplicate, select `AnimationPlayer`, and choose `standard` in Godot's Animation panel.
2. Drag the `Framing:position` / `Framing:scale` keys to change pan, focus and zoom timing. Framing is the presentation canvas: moving it left focuses farther right; scaling around the origin zooms the composition. Adjust both tracks to keep the subject at the desired screen location. Key transitions support Godot's native easing. `Framing/Shake:position` is the additive shake layer driven by root `sample_time` / `shake_strength` tracks.
3. Replace the `Background` or `Foreground` texture on that node in the Inspector. Character textures are keyed: replace the `Character:texture` key value in the Animation panel, together with `hframes`, `offset` and `frame` keys to match the registered clip. Preserve the clip's manifest pivot and scale. For another clip, add texture/hframes/offset/frame keys at its start, then its frame keys. No timing code changes are needed. Keep candidate/stand-in labels honest.
4. Move the root `handoff` boolean's **true key** to change when the adapter transfers to TR-08. Keep false at time zero, true inside the animation, and both animations shorter than the 12-second watchdog. Do not add world method calls to presentation timelines.
5. Preview with the native Animation panel's play, pause and scrub controls. Choose `reduced` and edit that separate short static-fade timeline too; no pan/zoom/shake/speed lines in it. Save the scene with Cmd/Ctrl+S. This `.tscn` is the saved cinematic configuration.
6. Open `tools/cin_tools_01/preview.tscn`. Assign your saved scene to the root `preset` Inspector field; F6 (**Run Current Scene**) launches it. The preview offers play, pause, restart, a 60 Hz step, scrubbing and reduced-motion toggle. It cannot request rooms. The dropdown selects the three shipped presets; Inspector assignment accepts your own saved scene.
7. Open `tools/cin_tools_01/demo.tscn`. Assign your saved scene to its root `preset` field, save, and Run Current Scene. Walk right with D toward the marked stair, then E. Space completes/skips the presentation; F6 toggles reduced motion; Esc pauses/resumes. Continue exploring or use E at the reciprocal staircase to return. This is a seeded test fixture with the existing traversal prerequisites, not an earned-progress start.

Godot uses F6 for Run Current Scene in the editor; **inside the running game** F6 is the existing reduced-motion control.

## Editable presets

| Scene | Intended composition | Handoff |
| --- | --- | --- |
| `major_biome.tscn` | Environment reveal, Kaze focus, return to normal framing | 2.00 s |
| `boss_intro.tscn` | Environment and subject/title reveal; replace the explicitly generic subject artwork | 2.40 s |
| `special_transition.tscn` | Staircase title/reveal, followed by real TR-08 R14↔R17 staging | 1.60 s |

Each has a 0.40-second reduced alternative. All titles apart from the existing staircase destination are authoring labels, not new story canon. The generic boss template uses Kaze as an explicit temporary subject; it does not introduce a boss. Only the staircase is wired to a playable request in this prototype. Future encounter/revelation adapters must use their existing authorized gameplay interfaces.

## Tracks and data

Native `.tscn` scenes embed an `AnimationLibrary` containing `standard`, `reduced`, and `RESET` Animation resources. AnimationPlayer resolves relative to the presentation root. No plugin or standalone animation engine is required. `tools/cin_tools_01/build_presets.py` reproduces starting scenes only; do not rerun it over authored changes.

- Camera composition: `Framing` position and scale; native easing; additive deterministic shake strength/time. Ending keys restore presentation framing. Gameplay Camera2D is never touched.
- Character: native Sprite2D texture, frame, hframes, pivot offset, position, scale and facing keys. Animation metadata records source ART-08 clip and per-frame root motion. The intro is a registered settle/held-pose study; actual staircase root motion and tread seating remain TR-08-owned.
- Environment: replaceable background and foreground, independent parallax position tracks, alpha and renderer-compatible CanvasItem color overlays.
- Presentation: letterbox bands, title/destination Labels, speed-line Line2D layers and fade-to-cover transition.
- Audio: root music/sound cue-reference strings and native AudioStreamPlayer volume tracks. Assign a stream to `Music` / `SFX` to hear a cue. Multiple events can be keyed on the reference string (use distinct marker IDs or reset to empty between repeated events). Scrubbing/stepping is silent. Pause stops audio; Play auditions from the selected point.
- Runtime-only world handoff: root `handoff` property, observed by the isolated adapter. Native editor scrubbing and preview have no world reference and cannot activate it.

## Validation and evidence

See [QA report](QA.md), [state ownership / recovered interfaces](INTERFACES.md), [limitations](LIMITATIONS.md), and [PM handoff](../agent_handoffs/CIN_TOOLS_01_PM_REPORT.md).

Run the checks from the repository root:

```sh
python3 tools/cin_tools_01/run_qa.py --godot /path/to/godot
python3 tools/cin_tools_01/run_qa.py --godot /path/to/godot --rendered
```

The runner confines direct regression save paths to ignored per-suite directories. It uses each older suite's required flags, including normal-save fixtures without `--test`, and records script errors as failures even if Godot exits zero. Generated engine imports, caches and build outputs are excluded from the PR.

Real-time capture (no fixed-fps/movie mode):

```sh
godot --path . --log-file /tmp/cin-capture.log --script res://tests/cin_tools_01/capture.gd -- --test
# macOS packaging helper; the game itself has no Swift dependency:
swift tools/cin_tools_01/encode_capture.swift build/cin_tools_01/capture/timing.json build/cin_tools_01/playback.mp4
```

Screenshots and wall-clock video are in [captures](captures/). The video is intentionally silent until approved audio streams are assigned.
