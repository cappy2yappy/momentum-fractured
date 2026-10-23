# GP-09 QA — 2026-10-23

## Result

The isolated slice is playable and reviewable on Windows. Shared production files have no content changes.

| Check | Result |
| --- | --- |
| GP09 lifecycle integration, headless | 36 checks / 0 failures |
| GP09 lifecycle integration, native NVIDIA OpenGL | 36 checks / 0 failures |
| GP09 fresh-start reload + reduced motion, headless | 36 checks / 0 failures |
| Approved baseline | 32 / 0 |
| Approved combat / swing | 7 / 0 |
| Movement / momentum | 53 / 0 |
| Sprite integration | 43 / 0 |
| EN01 framework | 52 / 0 |
| EN01 consumer contract | 31 / 0 |
| HAZ01 toolkit | 56 / 0 |
| HAZ01 contract | 17 / 0 |
| Asset/controller preservation verifier | 0 failures |
| Standalone Windows release executable startup | Exit 0; no script/runtime errors |
| Exported PCK, complete input-driven traversal with Godot editor executable | Exit 0; all 15 stages complete; no runtime errors |

Engine: Godot 4.6.1 official, commit 14d19694e. Native GPU: NVIDIA GeForce RTX 4070 Laptop GPU, OpenGL 3.3 compatibility.

Integration assertions cover examination ownership, actual version-8 disk writes, reload before presentation, duplicate requests, interrupted presentation retry, deferred defeat after the enemy node has been freed, control-restoration deferral, hazard damage, both recovery locations, defeated-state reload, exit queue flushing, and movement after the exit.

## Recording

[gameplay.mp4](gameplay.mp4) is 850 frames, 1280 × 720, 30 FPS, approximately 28.3 seconds. It is actual rendered Godot gameplay driven by `tests/gp09/record.gd`, not a human playtest. Movement, attacks, parry attempts and jumping use controller input. Inspection and recovery invoke the same room interaction entry point as E. The recording does not teleport the player, set progression flags, or directly damage enemies.

Godot MovieWriter generated an AVI; FFmpeg converted it to H.264 MP4. The renderer ran faster than wall time during recording; playback retains the fixed 30 FPS simulation timing. Minor subsequent edits only protected fresh-launch reloads and save-failure messaging; the final exported content completed the same traversal.

## Limitations and findings

- The environment uses provisional geometric art and a reused cinematic template/ART08 candidate presentation. This is a systems slice, not approved final environment or animation art.
- The exit leads to a safe apron in the same isolated room. No production room or campaign route is connected.
- Physical gamepad hardware and a human balance/playability session remain untested. The automated route finishes with recovery available.
- The release executable was boot-tested; release-template `--script` did not execute the external QA driver. That attempt is retained in `packaged-traversal.log` and is **not** a full executable traversal pass. The final PCK was instead traversed with the official editor executable using `--main-pack`, recorded separately.
- An early native inspection run failed before creating its save; the final native run completed all 36 checks. Tests explicitly inspect current interaction preconditions.
- Initial object placement intersected the shared doorway exclusion radius; it was moved. HAZ01's adapter combines its initial-enable setting with story flags; its local placement now follows that contract.
- Initial export omitted root MetSysSettings.tres. The packaging script now copies it; the final package boots cleanly and the exported content passes traversal.
- Export/editor shutdown reports inherited renderer/text-resource leak diagnostics. Final runtime test logs contain no script errors. Early direct shell launches had a profile-related native crash; final runs use private APPDATA/LOCALAPPDATA profiles.

## Source preservation

All GP09 source additions are confined to `scripts/gp09`, `scenes/gp09`, `data/gp09`, `tests/gp09`, and `docs/gp09`. Generated import metadata was restored. The shared world serializer, StoryDirector, EN01/HAZ01, player/guard, transitions, approved sprites, production room geometry, project.godot and export_presets.cfg are unchanged.

Raw suite logs and counts are in `evidence/`. Historical test counts in PR90 are reference evidence only; the table above reports runs performed for this slice.
