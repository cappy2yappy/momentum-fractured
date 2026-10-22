# Alpha 0.7 animation recovery — Agent A

Owner: Codex animation agent. Branch `codex/alpha07-animation`, isolated from
Candidate 3 and the 21-room production world. Base PR78 commit
`af18438` (full SHA in inventory.json).

## Initial recovery result (superseded source blocker)

**Update:** the creator subsequently supplied the exact Image4. Its preserved source,
alpha audit, extracted catalog and native pose studies are documented in
[ART09](../art09-image4/README.md). The initial missing-source finding below is
historical; finished gait/identity acceptance remains pending.

Recovered existing approved artwork and audited the existing staircase candidates.
No new ninja frames have been produced: the creator-selected **Higgsfield Image 4**
was not attached to this task, named in the inspected repository material, or
identified by an exact media ID. It is required before cutting usable frames or
building ascent, descent and braking candidates. No reconstructed substitute or
new generation was made. Existing live art and gameplay files are untouched.

PR62 art head `98d639f32c34d862bbe6ecf1fb4a8c70e1736414` documents the
script-authored ART08 candidate lineage; PR64 transition head
`ed1875307e21f057add025ebebdec1e3f371e90f` binds those candidates. Both
remain draft and creator visual acceptance is pending. The PR62 creator comment
specifically rejects the earlier hunched descent. Existing v3 descent is a later
candidate, not approval of the Image4 animation request. ART08 explicitly reports
no Higgsfield generation. ART07 reports blocked/drifted/failed generation attempts;
ART06's older pilot ZIP media ID is not proof of Image4 provenance.

## Inventory and gates

`inventory.json` records exact SHA256, byte counts, PNG dimensions, frame cells,
pivots, timings, contact markers, root motion and provenance. It distinguishes the
8 approved active/original sheets from 14 ART08 manifest entries (including an
alias, a stand-in and the unfinished `door_turn_to_side`). Run from project root:

```sh
python3 tools/alpha07_animation/audit.py --output docs/alpha07/animation/inventory.json
python3 tools/verify_baseline.py
```

Image4 intake must record its exact source file/media ID and hash, then inspect
frame count, alpha, face/outfit/ribbon continuity, limb changes, pivots and foot
contact. Produce separate candidate-only strips with explicit source timing and
ascent/descent/braking status. Do not replace `assets/kaze/cleaned` or
`assets/web` or bind into world transitions before visual approval. A single held
pose or transformed still must not be called frame animation.

## Existing native-speed demonstration on Mac

This launches the existing PR78 Cut-In Maker → TR08 staircase fixture at real
engine speed. It is **existing baseline footage**, not a new arms-back ninja
candidate. With Godot 4.6.1 installed at `/Applications/Godot.app`:

```sh
./tools/alpha07_animation/launch_existing_staircase.command
```

Use D to approach, E at stairs, Space to skip, Esc to pause/resume, F6 to toggle
reduced motion. The fixture seeds traversal prerequisites; it is not earned
progress. For authoring review open `project.godot`, then run
`tools/cin_tools_01/preview.tscn` as current scene. The launcher uses `--test` so
normal personal saves are not loaded or written.

## Integration handoff

No shared interface or save schema changed. The integration owner retains
world/save/transition ownership. Resume only when the actual Image4 source is
available; confirm source identity before editing. Existing staircase runtime
regressions and before/after captures must be repeated for any future candidate.
A clean merge and this checksum audit do not prove runtime compatibility.

## Current validation (Godot 4.6.1 / macOS Apple M4)

- Asset audit: 8 approved sheets, 14 ART08 entries, 0 integrity failures.
- Existing preservation verifier: 0 failures.
- Existing TR08 regression with disposable test paths: 226 checks, 0 failures,
  0 script errors. Includes ascent/descent, interruptions and restoration.
- Existing sprite regression: 43 checks, 0 failures, 0 script errors.
- Real rendered Cut-In Maker/TR08 capture: 3 checks, 0 failures; 111 actual
  post-draw samples over 6.749 wall-clock seconds. Captures cover before input,
  staircase playback and restored player control. This is an unchanged baseline
  sequence, not an art before/after comparison. Exact timestamp frames remain
  under ignored `build/cin_tools_01/capture`; creator-facing stills/timing copied
  to the coordination workspace outputs/animation directory.
- MP4 encoding was attempted but the installed Swift compiler and SDK versions
  do not match. The native-speed playable launcher and actual rendered captures
  are available; a new ninja before/after is blocked on Image4 source.

Native rendering required approved access to the macOS window server. Fresh
editor import first stalled in MetSys editor UID initialization; disabling editor
plugins temporarily allowed import, then project.godot was restored exactly.
Use `--log-file /absolute/writable/path.log` for automated Godot runs here to avoid
the engine's user-log rotation crash inside the sandbox. Existing QA runner
isolates direct test user paths; direct invocation of older suites may not.
No save/reload/controller validation of new art is claimed because none was made.
