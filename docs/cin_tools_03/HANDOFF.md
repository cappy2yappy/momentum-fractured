# CIN-TOOLS-03 — tonight's authoring handoff

**Draft creator review, unmerged.** This continues the existing Cinematic Studio 2.0 and PR #100 on branch `tools/cin-tools-03-studio`, stacked on Cut-In Maker #78 (`af184380fb690f2c19bac69960b7aacce50f9ff2`). The prior Studio checkpoint was `d227b038576fc5268acc4f94324fc5fbf64244a5`; tonight's delta stays entirely in the five reserved Studio namespaces.

## Delivered

- Direct Mac launcher with version/path checks; native Terminal smoke from outside the checkout passes.
- Resizable stage and readable controls; timeline, joint picker, Key pose/Undo and Save/Reload remain visible at 1024×640, 1280×720 and 1440×900. Lower inspector controls scroll.
- Existing-joint numeric posing, precise time entry, pose keys, scrub/play/step, key marks and undo using native AnimationPlayer resources.
- Atomic matched-session snapshot plus reusable standalone Animation exports. Explicit Reload after reopening; fresh writer/reader process tests pass in both headless and native modes. Invalid resources retain the current session and history.
- Exact shared clip in both Director shots, independently keyed constant shot framing, matching local-time navigation, full 8.4-second 1.0× preview and equal-duration static reduced motion.
- Short native 1.42–1.58 s sprite/rig blend. This softens the handover but does not finish braking anatomy, foot contact, seams or rig art.
- [Complete Mac guide](MAC_GUIDE.md), [native review](captures/native-speed.mp4), [QA](QA.md), source-preservation evidence and saved authoring example.

## Resources

Ordinary creator saves: `user://cin_tools_03/{sprint_stop.tres,director_shots.tres,studio_session.tres}`. Use **Open saved folder** in Studio. The snapshot contains the matched clip/shot pair; `.tres` exports remain reusable in Godot. Save replaces the previous session, so make Finder copies for named versions.

Delivered saved example: `presets/cutins/studio/authoring_example/` with the same three files. It contains Torso 12° at local 1.9 s, shot-one wide framing, and shot-two pan (-70,-35) / zoom 1.15. The review reloads this snapshot in a fresh process. SHA-256s are in `captures/timing.json`. The Mac guide explains how to inspect a disposable copy interactively.

The root seed `presets/cutins/studio/sprint_stop.tres` remains a detached starting resource. Normal launch does not rebuild seeds or write repository assets. Director remains a two-shot prototype with a fixed 4.2-second clip / 8.4-second sequence contract. Full sequencing, arbitrary durations and audio remain future native authoring work; unsupported reload data is rejected.

## Verified and pending

**Passed locally:** 212 headless and 212 native-rendered scoped assertions, baseline and four preservation checks, native launcher smoke, native layout captures, fresh-process persistence, original presets, invalid-resource and reduced-motion checks. Final native logs have no script/engine errors or leaks. Native recording: 208 samples, 8.808249 s wall time, max discrepancy 0.119381 s; MP4 1280×720 / 8.82 s / 208 samples. Packaging used the existing unchanged Swift encoder outside the shell sandbox. See QA.md for reproduction and exact limits.

**Pending:** creator follows the Mac guide and accepts usability/visual results; production animation/contact review; Windows/controller/export/campaign validation. Automated authoring invokes real widget callbacks; it is not a complete mouse/keyboard usability certification. The default user-data save folder is preserved; QA writes to disposable profiles.

**QA-10 #101:** a diagnosed test-harness correction awaiting PM acceptance, pinned to the previous Studio head. No automatic production certification, merge, or cherry-pick is inferred. Its diagnosis and prior failed attempts remain linked in QA.md. PM should reconcile/retest that separate draft against whichever head is accepted.

No CIN-04, ART-10, production gameplay or shared preview source is changed by tonight's delta. The original Studio's additive resolver remains byte-identical. Original Cut-In Maker presets and native AnimationPlayer implementation are preserved. No generation, new art transfer, spending, merge or production activation occurred.

## Ownership / next

Worktree: `/Users/tonysantiago/.codex/.chatgpt-projects/g-p-6aa9b0443c20819186909618bb6be970/work/cin-tools-03` (existing ordinary Git worktree, not app-managed). Keep it for creator review. Continue PR #100; do not create a replacement Studio. No shared-contract change needs new specialist coordination for this delta.

The source and evidence delta is committed on the existing development branch. Preexisting untracked Godot `.uid` / image `.import` metadata was left untouched and is not part of the handoff. Engine caches, raw captured JPEG frames and disposable profiles stay ignored under `.godot/` / `build/`.

Next owner: **Creator / PM**. Follow MAC_GUIDE.md, review the saved-resource recording and scoped QA, and decide acceptance. Keep draft and unmerged until explicitly authorized otherwise.
