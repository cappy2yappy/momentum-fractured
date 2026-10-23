# CIN-TOOLS-03 — direct FK authoring handoff

**Existing draft PR #100, unmerged.** Continue branch `tools/cin-tools-03-studio` in `work/cin-tools-03`; this extends the minimum-usable authoring head `7b162dd` and preserves all its changes. The PR remains stacked on Cut-In Maker #78 at `af184380fb690f2c19bac69960b7aacce50f9ff2`.

## Mac launch correction

Creator freeze at 971aa408 was traced to the launcher’s `--test` flag selecting Godot 4.6.1’s headless Mac OS loop despite a visible OpenGL window. Removed that flag; verified the normal NSApplication loop, desktop-pointer Play/Pause/scrub, FK move/Undo, focus return, window zoom/restore, and the actual launcher at 1024×640. Studio native QA now omits the flag; legacy gameplay fixtures retain their save guard and injected-input scope. 333 headless and 333 renderer assertions pass (203 Studio assertions use the corrected native app loop). Launcher regression and baseline/preservation pass. [Full diagnosis](MAC_LAUNCH_DIAGNOSIS.md), raw [qa/mac_launch](qa/mac_launch/). Existing authored/staged review saves are byte-preserved. The old disposable QA runner reset its own fresh-process fixture once during diagnosis; its exports were recovered and its equivalent snapshot regenerated. QA now uses a fresh folder per run. Keep this same PR draft and unmerged.

## Delivered

- Clickable, fixed-size viewport handles for all 18 existing FK pivots, including both Hands/Boots and near/far limbs. Coincident pivots get distinct dots and leader lines. Hover and selected/grip states are visible.
- Direct mouse move, gold-grip rotation and Alt-drag rotation. Full inverse parent/canvas transforms account for fit, inspection zoom, Director pan/rotation/zoom and FK ancestors. Fit/150%/200% is inspection-only.
- A drag is one unkeyed undo unit; Key pose explicitly commits pending joint poses. Batch counts are visible. Escape/right-click/focus loss/view changes/hidden handles cancel safely; release outside ends capture. Numeric precision controls remain.
- Guarded joint-versus-shot preview domains, deterministic scrub discard and per-instance Director libraries. Opening another Studio or seed never inherits previous instance edits.
- Existing atomic snapshot/standalone exports, explicit reload, fresh-process writer/reader, independent Director shots, native transport, reduced motion and original presets are retained.
- Mac launcher, readable fixed controls, 1.0× native creator demo, saved pointer example, source preservation, scoped input-dispatch QA and documentation.

## Verification

**333 headless + 333 native-rendered passing assertions**, eight serial processes per mode, zero failures/script errors/nonzero exits. Pointer coverage: 107 checks, including all pivots/grip layouts, transforms, undo before/after Key, release/cancel, mixed preview domains and transport. A separate process verifies mouse-authored Hand persistence and both shot uses. Another reader reloads the actual saved native-demo output. Baseline and four preservation checks pass. The Mac launcher is tested from outside the checkout.

See [QA.md](QA.md) and `qa/direct_fk/` for exact commands, raw logs, capture metrics and limits. The previous 212/212 authoring evidence and earlier prototype/failure logs are preserved. Native event dispatch and focus-loss signal tests are not physical OS-pointer/hot-unplug certification. No Windows/controller/export/campaign or production-animation acceptance is claimed.

## Review / launch

- Run `tools/cin_tools_03/launch.command` with Godot 4.6.1. [MAC_GUIDE.md](MAC_GUIDE.md) remains the complete Mac launch/persistence workflow.
- Follow [DIRECT_FK.md](DIRECT_FK.md): scrub to 1.9 s, click/drag a cyan dot, rotate with gold grip, Undo, Key pose, Save, close/reopen/Reload, then compare 1.9 / 6.1 s in Director.
- [Native FK creator demo](captures/fk-native-speed.mp4), screenshots/timing under `captures/fk/`. The previous minimum-usable recording remains at `captures/native-speed.mp4`.
- The actual saved pointer demo is under `presets/cutins/studio/pointer_example/`. The previous `authoring_example/` is byte-unchanged. Ordinary saves retain the atomic `studio_session.tres` plus `sprint_stop.tres` / `director_shots.tres` exports in `user://cin_tools_03/`. QA writes only disposable profiles.

## Ownership and scope

The prior authoring chat was verified idle after finishing approved PR metadata; this continuation retained sole source edit ownership. The coordinator performed read-only code/capture review and made no source edits. No parallel source editor or competing branch was used.

Every new/changed continuation file stays under `tools/cin_tools_03`, `tests/cin_tools_03`, `presets/cutins/studio` or `docs/cin_tools_03`. Shared preview, CIN-04, ART-10, production gameplay, TR-08 Canal Doorway, movement, original/approved sprites, save schema, canon and project settings are unchanged. Pre-existing untracked Godot UID/import metadata is retained and excluded from this commit.

**QA-10 #101** remains a separate diagnosed test-harness correction awaiting PM acceptance, pinned to original Studio head `d227b03`. Its capture lesson is used here (bounded synchronous native draws); its branch was not imported, merged or treated as acceptance of this updated head. PM should reconcile/retest that separate draft against the selected acceptance head.

## Pending / next owner

Creator/PM reviews usability and fidelity. Visible flat-art cutout seams, limb overlap, unvalidated foot contact and candidate braking remain; direct manipulation does not supply missing drawings or hidden surfaces. The two-shot fixed-duration contract remains. Animation and story owners retain production drawing, gait, shot/canon and eventual integration responsibility. Keep PR #100 draft and unmerged. No release, generation, spending or external media-service transfer was performed.

Environment: Godot 4.6.1 at `/Applications/Godot.app` or the documented launcher override. No seed rebuild or plugin install is needed. Existing Swift/AVFoundation is only used for local review-video packaging. The ordinary isolated Git worktree is intentionally retained; it is not an app-managed worktree.
