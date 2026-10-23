# CIN-TOOLS-03 QA — 2026-10-23

Godot **4.6.1.stable.official.14d19694e**, macOS Apple M4, OpenGL compatibility renderer. The isolated workspace and Cut-In Maker checks pass. Broader native gameplay input validation is **not green** on this host; this draft is not production certification.

## Passing final runs

| Mode / suite | Passing assertions | Failures |
| --- | ---: | ---: |
| Headless Studio workspace | 29 | 0 |
| Headless Cut-In Maker authoring | 27 | 0 |
| Headless Cut-In Maker runtime | 103 | 0 |
| Headless TR-08 embodied cinematics | 226 | 0 |
| Headless Canal hang regression | 53 | 0 |
| Headless TR-08 stage labels | 7 | 0 |
| Headless automatic passage reliability | 305 | 0 |
| Headless save compatibility | 11 | 0 |
| Headless movement momentum | 53 | 0 |
| Headless sprite integration | 43 | 0 |
| **Headless total, 10 suites** | **857** | **0** |
| Native rendered Studio workspace | 29 | 0 |
| Native rendered Cut-In Maker authoring | 27 | 0 |
| Native rendered Cut-In Maker runtime | 103 | 0 |
| **Rendered scoped total, 3 suites** | **159** | **0** |

These final runs have zero script errors. The headless platform emits a system-CA lookup error in this sandbox; it is retained in the raw logs, not counted as a GDScript error. Final Studio/capture runs have no leaked-node/resource warnings. Baseline verifier: zero failures. Preservation verifier: three passing boundary/provenance checks, including exact equality of nine reused source files.

The Studio suite covers native sprite keys, rig selection, keying, disk round-trip, shared resource identity, the same pose in two shots, undo/removal, constant final root, reduced framing/pose, step/play/pause, original presets, finite values and rejection of executable tracks. Director pan/zoom keys, undo, disk persistence and workspace switching are exercised. Pose key positions and constant root do not prove anatomy or planted feet.

## Unresolved extended rendered runs

The optional native `tr08_canal_hang_regression` and `automatic_passage_reliability` attempts did not progress normally: fixtures stayed stationary with zero velocity / unsupported floor state. The first complete bounded attempt recorded **28 and 57 failed assertions**, respectively, and both hit the 100-second limit. Its metadata and raw logs are retained in `qa/rendered-attempt/`. The earlier capture overlapped part of that attempt, so a later serial run was attempted; it also showed stationary fixtures. A test-only initial focus warmup did not resolve it and was removed. Its partial log is preserved; the superseded run was terminated rather than represented as a completed suite.

A separate unchanged-PR78 native probe progressed through the initial doorway and interruption cases before its deliberately bounded 23-second stop. That partial comparison is retained, but does **not** establish full baseline parity or identify the root cause. Window activation / pause state remains a hypothesis, not a proven explanation. No production HUD, player, world, doorway or legacy test body was changed to force green results. The same two suites pass headlessly (53 and 305 assertions). Full native gameplay input validation remains an acceptance gap.

## Reproduce

From repository root, with disposable QA profiles generated under ignored `build/`:

```sh
python3 tools/cin_tools_03/run_qa.py --godot /Applications/Godot.app/Contents/MacOS/Godot
python3 tools/cin_tools_03/run_qa.py --godot /Applications/Godot.app/Contents/MacOS/Godot --rendered
python3 tools/cin_tools_03/run_qa.py --godot /Applications/Godot.app/Contents/MacOS/Godot --rendered --gameplay-rendered
python3 tools/verify_baseline.py
python3 tools/cin_tools_03/verify_preservation.py
```

The first command delegates to the existing bounded headless runner. Rendered cases launch serially from the main Python thread. `--gameplay-rendered` adds the two unresolved extended input suites; it is deliberately opt-in and must not be described as passing. Headless and rendered raw logs/commands are committed separately. World checks use `--test` or explicit disposable normal-save paths. Studio save tests use an ignored `build/cin_tools_03/test_profile` resource folder, not the user's animation or game-save data.

## Capture

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path . --log-file /tmp/cin03-capture.log --script res://tests/cin_tools_03/capture.gd -- --test
swift tools/cin_tools_01/encode_capture.swift build/cin_tools_03/capture/timing.json docs/cin_tools_03/captures/native-speed.mp4
```

Capture uses real `Time.get_ticks_usec` and actual `frame_post_draw` samples. There are no fixed-FPS/movie flags. Its assertion checks the completed 8.4-second timeline, sufficient samples and at most 0.3-second wall-clock drift. The final timing metadata and capture log are committed with the screenshots/video: **190 samples over 8.806 wall-clock seconds**, maximum measured timeline drift **0.132 seconds**. The encoded 1280×720 video contains 190 samples and has an 8.822-second container duration; its SHA-256 and container inspection are recorded in `captures/video-check.json`. Raw JPEG paths remain local/ignored and are omitted from the published timing copy. The reused encoder writes the sampled wall-clock timestamps directly; it does not speed up or slow down the animation. Playback is silent and contains two uses of the same candidate clip. The warmup/pose-edit screenshots precede the recorded playback.

Creator visual acceptance, remote specialist clearance, Windows, controllers, standalone exports and a combined campaign playthrough remain unverified. No new production animation or cutscene placement is approved by these checks.
