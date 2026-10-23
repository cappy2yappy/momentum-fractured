# CIN-TOOLS-03 handoff

Goal: extend #78 into connected Character Animator + Cinematic Director, with the smallest useful creator prototype and honest flat-art fidelity limits. Keep isolated, draft and unmerged.

## Done

- Character Animator: seeded FK hierarchy, numeric joint position/rotation, pose keys at the shared playhead, rotation-key removal, bounded undo, native resource save/reload.
- Hybrid actor: intact approved run frames plus byte-identical candidate ART-08 cutout parts; optional inspection modes.
- Director: two uses of one clip, independent native canvas framing keys, zoom/pan/rotation editing, undo and shot persistence.
- Original preview/transport and all three Cut-In Maker presets remain connected. No competing runtime, gameplay owner or new room handoff.
- Standard sprint-to-stop timing and equal-duration static reduced preview; native-speed captures and fidelity/ownership documentation.

## Files and branch

Branch: `tools/cin-tools-03-studio`, stacked on PR #78 / `tools/cin-tools-01-cutin-maker` at `af184380fb690f2c19bac69960b7aacce50f9ff2`.

Local isolated worktree: `/Users/tonysantiago/.codex/.chatgpt-projects/g-p-6aa9b0443c20819186909618bb6be970/work/cin-tools-03`.

The app's managed-worktree creation tool could not operate on the project-mirror root (`Not a git repository`), so an ordinary isolated Git worktree was created from the existing repository. Managed attachment rejected it as unmanaged. It is intentionally retained for creator review; use normal Git worktree handling for this checkout.

All new files are in the five reserved studio namespaces. The sole shared source edit adds `preset_path(choice)` in `tools/cin_tools_01/preview.gd`. Other worktrees and synced `sources/` files were not edited. See INTERFACES.md for pinned references and specialist coordination, including the unverified remote reservations.

## Verification

Passed: 857 headless assertions across ten suites, 159 rendered assertions across the three isolated Studio/Cut-In Maker suites, baseline verification and candidate-part byte/boundary checks. The two broader native gameplay input suites failed/timed out with stationary fixtures and remain unresolved; their headless counterparts pass. Native recording completed with 190 samples and 0.132-second maximum clock drift. See QA.md and committed raw logs for exact scope. No result implies creator visual approval, Windows certification or completed production gait. Source preservation and candidate-part byte checks are reproducible with `tools/cin_tools_03/verify_preservation.py`.

## Deviations and risks

No new artwork was generated, transferred to a service or purchased. Reusing ART-08 source parts made an actual native rig feasible without pretending the approved flat art already contains hidden surfaces. The rig is FK and visibly limited; this is not ART-10 completion. Director's fixed two-shot prototype leaves full timeline composition to the existing native Animation panel. Studio edits save to their own data subfolder, never auto-publish into approved assets.

## Next owner / acceptance

Creator reviews Animator, hybrid handoff, sprint/brake/settle and Director reuse at native speed. Tool specialist can then improve exposed pose/clip UX and sequencing under this namespace. Animation specialist owns separated-part cleanup, contact/passing drawings and production gait. Cinematic/story specialist owns authored shots, narrative content and eventual StoryDirector integration. Remote file reservations must be rechecked before expanding the shared preview seam or touching their branches. Keep this PR draft and unmerged until review and required validation are complete.

Environment: Godot 4.6.1, root project and existing imported dependencies. No service, credential, plugin purchase or generated art prerequisite. macOS launcher assumes `/Applications/Godot.app`; otherwise run the scene through the editor. QA uses disposable ignored profiles. Swift/AVFoundation is only used to package the recorded review video on macOS, not to run Studio.
