# Automated QA — CIN-TOOLS-01

Executed 2026-10-21 on macOS / Apple M4, Godot **4.6.1.stable.official.14d19694e**. Rendered tests used OpenGL compatibility (`OpenGL API 4.1 Metal`). Full per-suite commands, exit codes and counts are in [qa/results.json](qa/results.json); corresponding raw logs are under [qa/](qa/).

| Run | Suites | PASS | FAIL | Script errors |
| --- | ---: | ---: | ---: | ---: |
| Headless, new tools plus existing regressions | 33 | 2,444 | 0 | 0 |
| Rendered, targeted tools and transition regressions | 7 | 777 | 0 | 0 |
| Real-time playable capture, real key events | 1 | 3 | 0 | 0 |
| Approved asset/controller baseline verification | verifier | passed | 0 | — |

These are assertion counts, not unique gameplay scenarios. Headless and rendered runs intentionally repeat assertions. New suites: authoring **27/0**, runtime **103/0** in both modes. Existing rendered suites: TR-08 **226/0**, Canal hang **53/0**, stage labels **9/0**, automatic passage **305/0**, native cinematics **54/0**. The older staged pilot headless suite passes **50/0** with its required `--pm-staged-stair` flag.

## Coverage

- E trigger accepts a trip and suspends ordinary player physics. Normal and reduced native timelines transfer to the existing TR-08 adapter, release the unchanged loader once, arrive and restore visible Kaze and control.
- Skip at intro opening/middle/closing, and TR-08 opening/climb/closing. Repeated skip and overlapping E cannot duplicate a request.
- Focus-loss notification and pause before handoff, before TR-08 release and during loader playback. Pending loader survives pause and resumes under existing HUD behavior.
- Reduced preview contains fixed composition and zero shake; F6 changes an active cut-in to its reduced timeline.
- Missing preset, missing AnimationPlayer and missing character texture. Missing textures become an explicitly labelled approved idle stand-in; missing sequence delegates immediately. Bounded watchdog prevents infinite playback waits.
- Repeated reciprocal stair entry, external room rebuild and respawn. Superseded requests do not override checkpoint authority.
- Camera zoom/position/offset/smoothing remain unchanged; checkpoint, earned abilities, gates and progression remain unchanged. Existing save bytes remain untouched. Existing save-compatibility and expansion save regressions also pass.
- Native scene save/reload after moving the handoff key, property-track scrubbing, sprite binding, read-only preview play/pause/step and reduced toggle.
- Existing default game path, original player controller, original TR-08 files and assets remain byte-identical to the base. Baseline verifier reports zero failures.

## Harness corrections and observed limits

The first new runtime pass caught an adapter re-entry bug; fixed before final evidence. The first rendered fallback pass exposed a missing-presentation property access; the fallback now validates the scene and native player before touching presentation fields. The first broad regression invocation omitted two existing harness prerequisites: the staged pilot needs its opt-in flag, and normal-save/Canal fixture tests must run without `--test` with a disposable `--tr05-save` path. The checked-in runner supplies those correctly. Final logs replace these failed development runs; no assertion or existing regression source was weakened.

The runner copies harness scripts into ignored build directories only to redirect direct `user://` regression file paths to disposable per-suite locations. Production scripts and original tests remain unchanged. All commands have bounded timeouts, and script errors fail a suite even when Godot returns exit zero. Sandbox headless runs print a macOS system-certificate lookup warning; assertions do not use network access. No script errors remain in the final logs.

## Captured evidence

[captures/playback.mp4](captures/playback.mp4) is real-time rendered playback, captured from post-draw viewport frames with wall-clock timestamps; it is not a fixed-fps Godot movie export. [Timing metadata](captures/timing.json) records 153 captured frames across 6.554 seconds. Encoding preserves those timestamps. Capture sampling is about 24 frames/sec; rendering and capture can drop samples without speeding up the animation. Audio is intentionally silent because cue streams are placeholders.

Screenshots: [preview](captures/authoring_preview.png), [reduced preview](captures/reduced_preview.png), [before trigger](captures/01_before_trigger.png), [authored reveal](captures/02_native_timeline.png), [TR-08 staircase](captures/03_tr08_staircase.png), [control restored](captures/04_control_restored.png).

## Creator validation still required

- macOS: creator interaction with the native Animation panel, artwork replacement/registration, preferred easing and cinematic pacing, audible cues once approved streams are assigned, and visual acceptance of existing ART-08 candidate strips.
- Windows: Godot 4.6.1 editor workflow, focus-loss/resume behavior with real OS focus changes, keyboard/controller feel, render/pixel framing and reduced-motion comfort. Automated focus testing sends the same notification consumed by the runtime/HUD; it does not replace this OS-level creator pass.
- No Windows binary export or claim of creator visual approval is included.
