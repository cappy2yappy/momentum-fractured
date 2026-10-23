# CIN-TOOLS-03 minimum usable milestone QA — 2026-10-23

**Passed: 212 headless + 212 native rendered assertions**, six serial processes per mode, on macOS Apple M4 / Godot **4.6.1.stable.official.14d19694e** / native OpenGL. This is scoped authoring validation. Creator acceptance and production animation certification remain pending.

## Current checks

| Suite / process | Headless | Native rendered | What it establishes |
| --- | ---: | ---: | --- |
| Studio workspace | 39 | 39 | Joint pose/key/scrub, save/reload, undo/remove, shared clip, shot persistence and isolation, original presets, transport, invalid resources, reduced motion |
| Layout | 27 | 27 | Timeline, joint selector, Key pose, Save, Reload, numeric time entry stay in bounds at 1024×640, 1280×720, 1440×900; control fonts ≥18 px; stage/storage do not overlap |
| Persistence writer | 7 | 7 | Authors Torso 12° at local 1.9 s; saves native clip/shot/snapshot; both uses and independent frames match |
| **Fresh-process** persistence reader | 9 | 9 | Previous process has exited; reloads disk files; reusable standalone export contains the key; same loaded clip object appears at sequence 1.9 and 6.1 s; first/second framing retained |
| Original Cut-In Maker authoring | 27 | 27 | Original preset/resource contracts preserved |
| Original Cut-In Maker runtime | 103 | 103 | Existing isolated native integration assertions preserved |
| **Total** | **212** | **212** | Zero assertion failures, script errors or nonzero process exits |

Raw stdout and command/result JSON are in [qa/minimum_usable](qa/minimum_usable/). The default runner now selects these scoped suites and uses disposable profiles under ignored `build/cin_tools_03/`. It never edits gameplay or the shared harness. The native cases run serially. No movie/fixed-FPS flag is used for this milestone's tests or recording. Headless macOS emits the retained system CA lookup diagnostic in this sandbox; it is not a GDScript error. The final native suite logs contain no engine errors or resource leak warnings.

Validation bounds allowed property paths and resource duration. Exercised rejection checks cover executable track types, wrong value types/duration, nonfinite transforms, missing resources, and invalid on-disk sessions. A rejected Reload retains both current resources and undo history. External/script dependencies are screened before ResourceLoader instantiation. Native shot framing edits are constant within one of the two fixed shots. A second-shot rotation does not leak into shot one or reduced motion. Resource validation intentionally rejects arbitrary clip lengths and executable editor tracks.

Save first commits an atomic AnimationLibrary snapshot containing the matched clip and shot Animation resources, then writes independent reusable exports. An export failure is reported separately; Reload uses the authoritative snapshot. Legacy pairs are read only when no snapshot exists and both files validate. Power-loss/filesystem fault injection, arbitrary hand-edited syntax fuzzing and concurrency between multiple Studio instances are not certified.

## Mac launcher and display evidence

The executable `launch.command` passes a native Terminal launch from `/private/tmp`, confirming it resolves its own checkout and opens `studio.tscn` directly with Godot 4.6.1. The bounded smoke uses `--quit-after 15`; an ordinary launch without that flag was also started successfully. A headless launcher smoke passes. See [launcher-native.log.txt](qa/minimum_usable/launcher-native.log.txt) and the complete [Mac guide](MAC_GUIDE.md). Finder double-click is the same supplied `.command` entry point; the recorded launcher smoke is the Terminal invocation, not an automated Finder-click test.

Native layout captures: [1024×640](captures/layout-1024x640.png), [1280×720](captures/layout-1280x720.png), [1440×900](captures/layout-1440x900.png). At the minimum size the inspector scrolls; Key pose, Undo, Save/Reload and timeline remain fixed. Automated authoring invokes the actual widget values/callbacks; it does not certify every mouse/keyboard interaction or macOS display scaling preference.

Preservation and baseline checks pass: nine candidate-part/provenance files remain byte-identical to the pinned ART-08 source; approved sprite sheets and production gameplay are unchanged. The continuation from `d227b038576fc5268acc4f94324fc5fbf64244a5` modifies only the five reserved namespaces. The shared Cut-In Maker resolver already in the original Studio PR is unchanged.

## Native-speed review

[Review MP4](captures/native-speed.mp4) loads `presets/cutins/studio/authoring_example/studio_session.tres` in a fresh process, then previews its exact clip twice with separate framing. It is silent, **1.0×**, with **208 native draw samples**, **8.808249 s** wall time and **0.119381 s** maximum timeline/wall-clock discrepancy. Playback reaches 8.4 s and confirms shared resource identity in both shots. The encoder uses each frame's measured timestamp; there is no retiming to fixed FPS. PNG compression and capture overhead can reduce sample density.

[Timing and saved-resource SHA-256s](captures/timing.json), [MP4 container/hash verification](captures/video-check.json), [capture log](captures/capture.log.txt), [encoder log](qa/minimum_usable/encode.log.txt). The container is 1280×720 and contains all 208 samples. The existing Swift/AVFoundation encoder was reused without changing its shared source. Native encoding ran outside the shell sandbox after sandboxed media encoding failed; deprecation warnings are retained in its log. The completed native output and container are verified, rather than inferred from process launch.

Reproduce from repository root:

```sh
python3 tools/cin_tools_03/run_qa.py --godot /Applications/Godot.app/Contents/MacOS/Godot
python3 tools/cin_tools_03/run_qa.py --godot /Applications/Godot.app/Contents/MacOS/Godot --rendered
python3 tools/cin_tools_03/verify_preservation.py
python3 tools/verify_baseline.py
/Applications/Godot.app/Contents/MacOS/Godot --path . --log-file /tmp/cin03-capture.log --script res://tests/cin_tools_03/capture.gd -- --test
swift -module-cache-path /tmp/cin03-module-cache tools/cin_tools_01/encode_capture.swift build/cin_tools_03/capture/timing.json docs/cin_tools_03/captures/native-speed.mp4
```

The committed authoring example is already present; capture only reads it. To reproduce writing and reopening it in a disposable directory, use the runner's separate persistence writer and reader processes. Creator files are untouched by QA.

## QA-10 and historical scope

[QA-10 PR #101](https://github.com/cappy2yappy/momentum-fractured/pull/101) is a **diagnosed test-harness correction awaiting PM acceptance**, pinned to original Studio head `d227b03` versus PR #78 `af18438`. Its diagnosis covers inherited focus-pause handling, pause state across world replacement, and unbounded screenshot waiting. It reported no Studio gameplay regression on those pinned comparisons. It has not been merged, imported or independently accepted here, and its results do not certify this updated head or production readiness. PM should reconcile/retest that separate draft against the chosen acceptance head.

The previous prototype's 857 headless / 159 scoped native passes and failed extended native attempts remain historical evidence under `qa/headless`, `qa/rendered`, and `qa/rendered-attempt`. The older report treated focus as an unproven hypothesis; #101 subsequently diagnosed the harness. The failed attempts are not silently deleted, relabelled as product regressions, or added to tonight's totals. Broader campaign, controller, export, Windows, production gait/contact and creator visual acceptance are outside tonight's certification.
