# CIN-TOOLS-01 — PM handoff

Status: implemented prototype, ready for draft review; creator acceptance pending. No merge, default gameplay activation or Wave 3 integration performed.

## Delivered

- Three editable Godot AnimationPlayer / AnimationLibrary scenes: biome entrance, boss subject reveal, special transition.
- Native saved-scene configuration, timeline authoring instructions, safe read-only preview with standard/reduced modes and step/scrub controls.
- Isolated playable staircase demo: real E trigger → authored reveal → unchanged TR-08 action → existing room request → control restoration. Skip and focus loss complete accepted trips once; death/rebuild yields to checkpoint authority.
- Recovered interface/ownership documentation, limitations/stand-ins, 40 successful headless/rendered suite runs plus real-time capture, screenshots and timestamp-preserving MP4.

## Integration boundary

Branch: `tools/cin-tools-01-cutin-maker`.

Base/dependency: `feature/tr08-fullscreen-embodied-cinematics`, PR #64 at `ed1875307e21f057add025ebebdec1e3f371e90f`. This is a separate stacked tooling PR, not a modification of PR #64. PR #74 / Wave 3 is neither changed nor merged. No production `scripts/`, assets, project settings, original tests, gameplay scene, physics, routing or save schema changed.

Worktree: project workspace `work/cin-tools-01` (created manually because the app worktree tool could not resolve a repository from this project mirror). Original checkout `work/ld-tools-02` is used only as the Git common repository. Only this new branch is published.

## Verified

- Headless: 33 suites, 2,444 PASS, zero failed assertions or script errors.
- Rendered macOS: 7 suites, 777 PASS, zero failed assertions or script errors.
- Real-time capture: 3 PASS; viewport JPEG timestamps preserved in silent H.264 MP4. Baseline verifier passed.
- All game and TR-08 files are unchanged relative to the inspected dependency. Generated Godot import artifacts and cache/build files are excluded.

See [QA](../cin_tools_01/QA.md) for exact coverage and validation limits. Start with the [authoring guide](../cin_tools_01/README.md) and [interfaces](../cin_tools_01/INTERFACES.md).

## Next owner / remaining decisions

Creator / PM: review the draft, open the preview and duplicate a template, replace candidate environment/subject artwork and assign approved sound streams. Validate the native editor workflow and preferred pacing on macOS and Windows. ART-08 strips remain candidates; the boss subject, environment staging and audio references remain explicitly temporary. See [inventory](../cin_tools_01/LIMITATIONS.md).

After creator acceptance, decide which production transitions should opt into an adapter and coordinate against the accepted TR-08 base. Ordinary passages must retain their existing automatic behavior. No production adoption is implied by this handoff.
