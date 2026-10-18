# ART-07R PM Report: Core Animation Recovery and Production

Status: **Phase 1 delivered as an optional candidate. Phase 2 (long-idle) and Phase 3 (crouch) are not started.**
No merge, no default sprite replacement, no creator approval claimed.

## 1. Remote branch, commits, PR

| Item | Value |
| --- | --- |
| Branch | `art/art07-core-animation-fidelity` |
| Base | `5fc41d231ee7a030a5c273e5263f96be54b55a8e` (tip of `art/art06-kaze-lateral-transition-pilot`) |
| Interim report commit | `65e1e08d3650349ae1573985af3470b2bb6ac9e9` |
| **Art delivery commit** | `86a31672e21ab64588ffadffb2a6f80a3fc639ce` |
| Report update commit | the branch tip after this file; see the PR |
| Draft PR | https://github.com/cappy2yappy/momentum-fractured/pull/53 (draft, base is the ART-06 branch so the diff is ART-07 only) |
| Tracking issue | https://github.com/cappy2yappy/momentum-fractured/issues/48 (referenced, not closed) |

Reconciliation: my earlier chat note said the interim report was uncommitted. It was committed and pushed as `65e1e08` shortly after, which is the state PM saw. No history was rewritten.

## 2. Reference verification (PR #30, #39, #41 and the ART-06 base)

The brief's PR descriptions do not match the repository. Actual PRs:

| PR | Actual content | What I inspected |
| --- | --- | --- |
| #30 `art/art04-production-pilots` @ `a6b76b9` | ART-04 transparent pilots and four Kaze transition keys | file list, `key_pose_atlas.png` (viewed), ART04 PM report |
| #39 `feature/alpha-0.6.1-tr05-pr37` @ `5dfc4c4` | TR-05 transition prototype, not a gameplay movement baseline PR | `scripts/player.gd` idle bindings, TR05 report |
| #41 `art/art05-animation-pipeline` @ `60859a8` | ART-05 testbed, turn candidate, exporter, manifest | `assets/art05/MANIFEST.json`, README (read in full) |

Findings:
- Approved appearance: PR #30's four 320 x 724 keys show the same character (purple blazer, green ribbon bow and tails, black pleated skirt, purple stockings and boots). Kaze stays canonically 16.
- **The idle contract is identical in PR #39 and the ART-06 base**: `kaze_idle_strip.png` (SHA256 `03db06f8...5697`), `player.gd` idle binding, scale 0.2649908807267889, baseline 591, 0.16 s/frame. A git diff of the cleaned assets and `player.gd` between the two commits is empty.
- ART-04/05 transition cells (320 x 724, pivot (160,600), scale 0.303125) are a different contract from idle (272 x 724, baseline 591). I used the idle contract.
- PR #30 and #41 were not exhaustively reviewed beyond the files above, and I did not run the ART-05 testbed itself (see section 7).

## 3. Delivered sequences and readiness

| Sequence | Status |
| --- | --- |
| Standard idle, procedural 8f | **Candidate, optional, not approved, not human reviewed** |
| Standard idle, procedural 16f | Candidate, needs engine edits to bind |
| Standard idle, redrawn | Not done |
| Long-idle (idle-to-wait, wait, return) | **Not started** |
| Crouch (enter, hold, exit) | **Not started** |

What the candidate is: deterministic pixel displacement of **one** approved drawing (frame 1 of the approved idle strip). Chest breathing, a restrained weight shift with feet pinned, one lagged pendulum for the long hair, ribbon flutter. **It is not redrawn animation** and is not equivalent to one. It adds no pose, expression or silhouette. Frame 0 equals the approved frame exactly and rows 548 and below are byte-identical in every frame.

## 4. Visual previews (commit-pinned GitHub links)

Base: `https://github.com/cappy2yappy/momentum-fractured/blob/86a31672e21ab64588ffadffb2a6f80a3fc639ce/docs/art/art07/idle_procedural/`
- `compare_approved_vs_candidates_game_scale_x4.gif` (approved, 8f, 16f side by side)
- `godot_native_playback_16ticks.gif` (real Godot render)
- `candidate_8f_game_scale_x4.gif`, `candidate_16f_game_scale_x4.gif`, `candidate_8f_game_scale_x1.gif`
- `contact_sheet_game_scale_x4.png`, `candidate_frames_0_2_4_6_native_res.png`, `difference_heat_frames_1_to_7.png`
- `README.md` (reviewer notes)

GIFs are previews quantized to 200 colors; the PNG strips and frames are the assets.

## 5. Asset inventory (62 manifest files; 63 with the manifest)

| Path | Content |
| --- | --- |
| `assets/art07/idle_procedural/kaze_idle_procedural_8f_strip.png` | 2176 x 724, 8 frames |
| `assets/art07/idle_procedural/kaze_idle_procedural_16f_strip.png` | 4352 x 724, 16 frames |
| `assets/art07/idle_procedural/frames_8f/kaze_idle_procedural_8f_00..07.png` | individual 272 x 724 frames |
| `assets/art07/idle_procedural/*.png.import` (10) | Godot 4.6.1 import files |
| `assets/art07/MANIFEST.json` | hashes, contract, QA status |
| `source_art/art07/idle_procedural/` | approved source frame, `params.json`, hair and ribbon masks |
| `docs/art/art07/idle_procedural/` | GIFs, contact sheets, `QA_REPORT.json`, `GODOT_VALIDATION.json`, `godot_capture/` (16 native frames and render log) |
| `tools/art07/` | `idle_procedural.py`, `build_idle_candidate.py`, `package_evidence.py`, `write_manifest.py`, `validate_idle_godot.gd`, `capture_idle_godot.gd` |

## 6. Sprite registration contract

| Property | Value |
| --- | --- |
| Cell | 272 x 724, same as the live idle strip |
| Baseline row | 591 (lowest opaque row is 590 in every frame) |
| Engine scale | 0.2649908807267889 |
| Sprite offset | `(0, texture_height/2 - 591) = (0, -229)` |
| Facing | drawn right, `flip_h = facing < 0` |
| 8f timing | 0.16 s per frame, 1.28 s loop, `hframes = 8`. Drop-in; binding it is a texture-path swap that was **not** made |
| 16f timing | 0.08 s per frame, 1.28 s loop, `hframes = 16`. Needs engine edits (`player.gd` hardcodes `hframes = 8` and a 0.16 s idle divisor). **Not made** |
| Trim, resize, recentre | none |

## 7. QA and Godot validation actually performed

Pixel QA (`QA_REPORT.json`): 15 checks per set, 8f and 16f, **all pass**. Checks: dimensions, frame 0 equals approved, feet rows pinned, baseline row, alpha margin (27 px), unique frames, loop seam, near-duplicate poses, silhouette area (max 2.97%), silhouette height, identity colour shift (0.16 levels), hidden RGB, edge softening (max 3.8%), displacement-field fold test (max gradient 0.58 against a fold limit of 1.0), motion size.

Build determinism: two consecutive runs gave byte-identical files (22 compared).

Baseline preservation: `python tools/verify_baseline.py` reported 0 failures; no approved asset changed.

Godot 4.6.1 (official build, download checksum matched the published SHA512):
- Headless project import completed. New assets imported without errors.
- `validate_idle_godot.gd`: **9 of 9 pass**, run on the imported textures: loads, size parity with the live strip, offset unchanged (0,-229), frame 0 equals approved frame 1 in Godot's own pixels, feet rows identical in all 24 frames, baseline row, 8-frame SpriteFrames at 6.25 fps, `player.gd`-style Sprite2D stepping.
- `capture_idle_godot.gd`: 16 timed native frames rendered with the exact scale and offset formula, at 1x and 3x.

Not done:
- Not run in the ART-05 testbed (`tools/art05/testbed.tscn`); modifying its manifest would touch ART-05 work, so I used a separate fixture.
- The candidate was not bound into the player scene, so no in-game movement test.
- The render used software GL (Mesa llvmpipe) under a virtual display in a cloud sandbox: not a GPU, not Windows or macOS, not a human play session, not sustained-FPS certified.
- No human review of the motion.

## 8. Hash verification against GitHub

Every file in the manifest was re-downloaded from GitHub at commit `86a3167...` through the contents API (not read from local disk) and hashed.
- Manifest fetched from GitHub: SHA256 `53728bf9adcdd5af7374cf3f2dae484b9381cc13f55ae15544ec6fd83cda1e5d`.
- **62 of 62 files matched** the manifest SHA256 and byte size; 0 mismatches.
- This report is not in the manifest (it carries the commit it describes); it is verified separately in the PR.

## 9. Artistic issues and incomplete work

- The motion is **subtle**: head rise about 3 source px (0.8 game px), hair and ribbon tips at most 7 source px (1.9 game px). At true gameplay size it reads as a faint breath, much quieter than the approved loop, whose frame 4 drops the head top by about 19 source px.
- One source pose means the candidate loses the approved loop's stance variation. It is calmer, not richer.
- The hair mask is color and polygon based; no tearing was found by the numeric fold test or by eye at 3x, but the hair edge near the left sleeve needs a human look in motion.
- Loop seam (frame 7 to 0) is the largest adjacent delta in the 8f set (2.43 against 2.23), inside the pass bound but worth watching.
- Amplitudes are parameters (`source_art/art07/idle_procedural/params.json`); they were tuned down once to keep the silhouette within 3%. A stronger version is possible but would push those bounds.
- No sequence here replaces hand-drawn acting. Long-idle personality and crouch cannot be made by deformation.

## 10. Phase 2 and 3 status and blockers

- Higgsfield: two of four attempts were blocked as `nsfw`, one output drifted off-model (heavier legs and hips, shorter skirt, more mature face), one job failed after queuing. No further paid attempts were made. Last observed balance 434.64 credits; total spend 2 credits. I did not alter prompts to evade moderation.
- Aseprite is on the creator's computer, not in this sandbox, so I could not draw there. I can script everything after the drawing step through its CLI once a folder is connected or Claude Code runs locally.
- Long-idle and crouch need **drawn key poses**. Pipeline work that is ready to reuse: the 272 x 724 / baseline 591 contract, the registration and QA scripts, the Godot validation and capture fixtures, and the manifest tooling.

## 11. Engineering integration requirements (nothing done)

- Bind the 8f candidate only after creator approval: change the `clips["idle"]` texture path in `scripts/player.gd` (line 78). Nothing else is needed; scale, baseline and timing already match.
- 16f needs a per-clip frame count and duration instead of the hardcoded 8 and 0.16 s.
- Crouch needs a new state, animation hook and art; the collision capsule must stay unchanged unless engineering decides otherwise.
- Long-idle needs an inactivity timer and clip transitions in `animate()`.

## 12. Creator decisions required

1. Accept, reject, or ask for a stronger version of the procedural idle (and whether the quiet single-pose look is acceptable).
2. Choose the production path for long-idle and crouch: drawn key poses by the creator or an artist in Aseprite (recommended), or another approved method.
3. Whether to raise the Higgsfield moderation flags with support. I will not try to bypass them.
4. Whether to connect a folder or run Claude Code locally so Aseprite can be driven from the CLI.

## 13. Recommended next steps

1. Creator reviews the two GIFs in the PR and decides on item 1 above.
2. Obtain drawn key poses for long-idle (idle-to-wait, wait, return) and crouch (enter, hold, exit), at 272 x 724 on the baseline 591 contract, using the approved idle frames as onion-skin references.
3. Claude then builds in-betweens, registration, strips, QA, previews, Godot validation and the manifest with the existing scripts.
4. Do not merge. Do not replace default sprites.
