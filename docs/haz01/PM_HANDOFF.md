# HAZ-01 PM handoff

Owner: Level Masta. Milestone: Alpha 0.7. Status: prototype implementation and automated validation complete; draft review requested. Base selected by creator: `feature/ld05-intentional-world-boundaries` (`30155f5`). Feature branch: `feature/haz01-toolkit`.

Delivered three working types: collapsing platform, timed steam vent, timed electrical conduit. The conduit uses timed danger; elemental disable behavior and the fourth type (crusher) are deferred to avoid expanding collision and validation scope. No production placement is proposed in this change.

The reusable node and inspector resources expose placement coordinates/dimensions, phase timing, optional existing progression requirements, lifecycle events and reset policy. Damage calls the current Kaze API. Reset checks prevent a collapsed surface rebuilding around a body. Saves retain optional disabled state and restart danger cycles at safe phases. All danger cues remain readable without flashing or motion.

The standalone Godot course includes a recovery floor, safe observation/exit areas, and an existing grapple anchor. It grants existing dash/tether solely for testing. Campaign scenes and save schema remain unchanged. Play instructions and the Room Creator contract are in [README](README.md).

## Verified evidence

Godot 4.6.1, macOS Apple Silicon, 2026-10-22:

| Suite | Passed | Failed |
| --- | ---: | ---: |
| HAZ-01 toolkit | 56 | 0 |
| Existing movement/momentum | 53 | 0 |
| Existing save compatibility | 11 | 0 |
| Existing LD-05 boundaries | 172 | 0 |
| Total | 292 | 0 |

All four processes exited zero, with no GDScript parse/runtime errors. Raw logs and machine-readable totals are in `evidence/`. The headless runs emit a macOS system-certificate lookup diagnostic; it does not prevent offline gameplay testing. Asset/controller preservation verification reports zero failures. Native OpenGL captures show the course across its cycle. The original interrupted/save-path-failed attempts were rerun using bounded processes and redirected temporary test save paths; only completed evidence is published.

No pre-existing tracked source file changed. This preserves the approved 21-room geometry, existing roof setting, exits, progression and Kaze physics byte-for-byte relative to the selected base. Boundary tests independently check room geometry and traversal.

## Review and next integration step

Review the native course for warning readability and timing. This is a prototype with diagnostic art, not final environmental art/audio. Human playtesting, exported Windows verification and combat encounters combined with hazards are not claimed. Cycle partition testing covers 30/60/120/144 Hz; it is not four rendered platform playthroughs.

After creator-marked blueprints arrive, consider replacing the existing R15/R18/R19 periodic rectangles individually. Keep checkpoint/arrival/doorway volumes clear, reserve waiting space on both sides, retain a permanent return route and re-run traversal with earned abilities. The room owner must validate unique placement IDs, bind Kaze, store snapshots and reset hazards after moving Kaze to a safe spawn. No campaign integration is implied by this toolkit PR.

PM acceptance recommendation: accept as an isolated toolkit prototype after native review; schedule production placements, art/audio and crusher as separate follow-up work. Do not merge or alter approved layouts without the creator's requested review.
