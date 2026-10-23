# Mac Studio launch freeze — 2026-10-23

The creator report, “launches but kinda freezes,” was reproduced on PR #100 at `971aa408a9081db7992e8efcc5dda7c10095ebe1`. Removing the launcher’s `--test` argument restores native Mac input. Continue the same draft PR and branch; the existing Studio owner confirmed source/PR edits were on hold during diagnosis.

## Cause and evidence

The original launcher executes `studio.tscn -- --test`. Godot 4.6.1’s [Mac startup argument scan](https://github.com/godotengine/godot/blob/4.6.1-stable/platform/macos/godot_main_macos.mm#L59-L103) scans all arguments without stopping at `--`. Its [headless-argument list](https://github.com/godotengine/godot/blob/4.6.1-stable/platform/macos/os_macos.h#L75-L91) includes `--test`. That chooses `OS_MacOS_Headless`, whose [loop](https://github.com/godotengine/godot/blob/4.6.1-stable/platform/macos/os_macos.mm#L1121-L1166) advances the engine without the normal NSApplication native event loop.

The creator process (PID 17366, launched at 17:08 EDT) remained alive, used about 29–30% CPU and rendered via Apple M4 native OpenGL. Its three-second sample showed `main → OS_MacOS_Headless::run → Main::iteration → RenderingServerDefault::_draw`; native window inspection timed out. Its log contained only the clean engine/renderer header. This was an input-starved application, not a deadlocked renderer.

A separate launch of the same scene, binary and renderer without `--test` (PID 17720) sampled as `main → NSApplication run → NSEventRouting → CFRunLoop → Main::iteration`. Native window inspection then worked. Only the original noninteractive launch was terminated, after preserving its log and stack. The separate comparison instance was closed after undoing its temporary gesture.

Environment: Godot `4.6.1.stable.official.14d19694e`, Apple M4, macOS 27.0.1, OpenGL 4.1 Metal compatibility renderer. No renderer, driver, project setting or production script was changed.

| Possible explanation | Observed result |
| --- | --- |
| Hung process / renderer deadlock | Repeated engine iterations and rendering in the sample; process remained active. |
| Paused or quarter-speed preview | Studio intentionally starts paused at 0 s. The old OS loop prevented Play from receiving native clicks. Corrected Play advanced to 1.78 s and, on a separate launcher run, 1.92 s during normal screenshot acquisition. No speed override was present; the existing 1.0× transport was unchanged. |
| Joint pointer capture | Corrected native move showed an unkeyed forearm edit; Undo restored X=0/Y=46, and transport/scrub still received clicks after release. |
| Resize / focus slowdown | Native window zoom and restore laid out correctly; returning focus and clicking controls remained responsive. Automated layout/input checks cover 1024×640, 1280×720 and 1440×900. This is not a benchmark of every display scale or live edge-resize gesture. |
| Mac startup crash | Older reports included LaunchServices registration aborts and a 15:21 `RotatedFileLogger` failure. They predated the 17:08 creator process and do not explain its live input failure. A sandboxed diagnostic launch also aborted before scene loading; the same native diagnostics passed outside the shell sandbox. |

## Precise creator check

1. Close the old Studio window, then double-click `tools/cin_tools_03/launch.command` in Finder, or run the command below. Do not append `--test`.
2. It opens Animator paused at 0 s. Click **Play**. The timeline should advance to 4.2 s, then stop. Click **Restart** to return to 0.
3. Click **Pause**, then scrub the timeline to **1.9 s**. Click/drag a cyan joint dot. Its position fields and unkeyed notice should update. Click **Undo**; the joint should return to its previous position.
4. Resize or zoom the window, return it to its previous size, and repeat Play/Pause/scrub. These controls should still respond. **Reload** opens a previously saved creator session; launch starts from a detached seed.

```sh
zsh "/Users/tonysantiago/.codex/.chatgpt-projects/g-p-6aa9b0443c20819186909618bb6be970/work/cin-tools-03/tools/cin_tools_03/launch.command"
```

The corrected launcher was run from `/private/tmp` with `--resolution 1024x640` and a new disposable save override. Native desktop pointer actions confirmed Play reaching 1.92 s, Pause and scrub to 1.90 s. At 1280×720, Play, Pause, scrub, forearm move, Undo, native zoom/restore and focus return were exercised through the desktop UI tool. These are actual OS pointer actions, separate from `Input.parse_input_event` assertions. They do not constitute physical hardware, controller, Windows, campaign or creator fidelity acceptance.

## Fix and QA

The runtime change is solely `studio_args=()` in the existing launcher. Studio does not instantiate a gameplay World and needs no gameplay `--test` save guard. The Studio QA cases also omit `--test` when rendered. Legacy Cut-In Maker fixtures retain their existing save guard and synthetic input scope; QA-10 #101 remains separate and pending PM acceptance.

- **333 headless assertions passed.**
- **333 renderer assertions passed:** 203 Studio assertions in the normal Mac application loop, plus 130 legacy assertions retaining `--test`.
- **Launcher argument/preservation regression passed:** invoked from outside the checkout, forwards resolution and paths with spaces, preserves a pre-existing snapshot, and rejects reintroducing headless flags in its actual generated arguments.
- Baseline and all four Studio preservation checks passed. Zero final suite failures, script errors or nonzero exits.
- Current commands/results and stack excerpts: [qa/mac_launch](qa/mac_launch/). Full stack samples remain locally under `build/cin_tools_03/freeze_diagnosis/`.

The previous 333 native-rendered assertions at 971aa408 established rendering and injected Godot input. They did **not** certify Mac event delivery: injected input bypasses the OS loop, which is why those assertions could pass while the creator window ignored clicks. Historical recordings/logs remain intact and are not treated as native pointer certification.

All existing repository examples and staged authoring/review resources, including `authoring_example`, `pointer_example`, and `build/cin_tools_03/fk_creator_profile`, are byte-preserved. The ordinary creator save folder did not exist at diagnosis. One initial invocation of the legacy QA runner reset its own disposable `minimum_usable/rendered/fresh_process_profile` before a sandbox abort. Its two exports were recovered byte-identically; only that disposable QA snapshot was regenerated with equivalent tested content. The corrected runner now allocates fresh per-run folders and redirects hardcoded Studio QA output paths, retaining earlier profiles. See [preservation record](qa/mac_launch/preservation.json).

No approved art, gameplay, save schema, shared preview, project settings or generated media changed. No merge, release or production activation.
