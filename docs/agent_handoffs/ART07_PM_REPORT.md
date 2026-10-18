# ART-07 PM Report: Core Character Animation Fidelity

Status: BLOCKED on artwork production. No new animation assets were delivered.
Report type: honest interim handoff. Nothing in this report claims creator approval.

## 1. Branch, commit, PR

| Item | Value |
| --- | --- |
| Branch | `art/art07-core-animation-fidelity` (local worktree) |
| Base commit | `5fc41d231ee7a030a5c273e5263f96be54b55a8e` (tip of `art/art06-kaze-lateral-transition-pilot`) |
| ART-07 commits | None yet. This report is uncommitted. |
| Pushed to GitHub | No |
| Draft PR | None opened |
| Issue | https://github.com/cappy2yappy/momentum-fractured/issues/48 |

Remote-delivery verification: not applicable. No binaries exist to push or hash.

## 2. Inventory of delivered assets

None. No idle, long-idle, or crouch frames, strips, previews, GIFs, or contact sheets were produced or accepted.

Rejected experiment output (not committed, not for use): one Nano Banana Pro idle key-pose sheet, see section 6.

## 3. Recovered baseline (the actual sprite contract)

Source: ART-06 commit `5fc41d2`, `scripts/player.gd`, `assets/kaze/cleaned/`, `assets/web/kaze_manifest.json`.

| Property | Idle (approved, active) |
| --- | --- |
| Strip | `assets/kaze/cleaned/kaze_idle_strip.png` |
| Strip size | 2176 x 724 |
| Frames | 8, each 272 x 724 |
| Ground baseline | row 591 |
| Engine visual scale | 0.2649908807267889 |
| Sprite offset | `(0, texture_height/2 - baseline)` |
| Playback | `animation_clock / 0.16`, about 6.25 fps |
| Visible height | about 364 source px, about 96.5 game px |
| Facing | drawn right, left uses `flip_h = facing < 0` |

Measured frame bounds on the approved idle strip: top row 223 to 242, bottom row 590 on all 8 frames. Horizontal extents vary by frame (columns 25 to 247), so registration must be by baseline row and root, not by bounding box.

Findings that affect planning:
- The ART-06 480 x 724 transition cell is not the idle contract. Idle uses 272 x 724 cells.
- `player.gd` has no crouch state at this baseline. The collision capsule is fixed (radius 14, height 60). Crouch is art-only and needs an engineering hook later. No collision or state-machine change was made or proposed here.
- There is no long-idle or wait state in the current animator, which also needs an engineering hook.

Not recovered: PR #28, #30, #34, #39, #41 and #38 were not individually inspected beyond what the ART-06 branch contains. Treat the contract above as derived from the ART-06 tree only.

## 4. Timing, dimensions, and registration contract (proposed for ART-07)

Proposed, not yet exercised on real frames:
- Cell 272 x 724, baseline row 591, scale 0.26499, same sprite offset formula as idle.
- Idle: 8 or more frames at 0.16 s, loop-seamless. Frame 0 matches frame N by pixel diff within a set tolerance.
- Long-idle: idle-to-wait, wait loop, return-to-idle as separate clips.
- Crouch: `crouch_enter`, `crouch_idle`, `crouch_exit`, same cell and baseline, no anchor drift.
- No silent scale or anchor changes. Any change must be called out in the manifest.

## 5. QA and Godot test results

- Pixel QA (clipping, alpha, alignment, duplicate-pose, silhouette, identity): not run, no frames.
- Godot testbed (ART-05): not run. Godot is not installed in the cloud sandbox. Previews would be Pillow composites as in ART-06.

## 6. Generation attempts and provenance (Higgsfield)

All attempts used references cropped from the approved idle strip (frame 0 and frames 0, 4, 6).

| # | Model | Result | Credits |
| --- | --- | --- | --- |
| 1 | `gpt_image_2_5` (x2 variants) | Blocked, status `nsfw` | 0 |
| 2 | `nano_banana_pro` (job `f8d84221-aea8-40e1-8514-49d2d0ed1a89`) | Completed, rejected on QA | 0 observed |
| 3 | `autosprite`, idle, 8 frames, 512 px (job `675a49f9-ed3a-466a-8d22-10aee5ab8f10`) | Failed after queuing, no reason given | 2 |
| 4 | `flux_3_image` (job `7b3d9562-880d-4c9a-ae1d-a35a01a8972c`) | Blocked, status `nsfw` | 0 observed |

Balance: 436.64 before, 434.64 after. Total spend 2 credits. Correction to earlier chat notes: the Nano Banana Pro run did not show a charge.

Why attempt 2 was rejected: against the approved idle frames, legs and hips were heavier, the skirt hem was shorter, and the face rendered more mature. That breaks the approved proportions and 16-year-old presentation. The four poses were also near-identical, so there was no usable breathing or weight-shift information. It drew a ground line despite instructions.

Moderation: two of four attempts were blocked with no reason returned. The cause is unknown. Prompt wording was not altered to evade the filter, and the character's canonical age was kept in the prompts. This should be raised with Higgsfield support rather than worked around.

## 7. Approved, candidate, incomplete

| Item | Status |
| --- | --- |
| Standard idle | Incomplete, no assets |
| Long-idle (idle-to-wait, wait, return) | Incomplete, no assets |
| Crouch (enter, idle, exit) | Incomplete, no assets |
| Baseline contract in section 3 | Recovered, not yet reviewed by creator |
| Approved Kaze artwork | Unchanged. No files in `assets/` were modified. |

Nothing here is approved or candidate-ready.

## 8. Known defects and artistic risks

- No in-game animation improvement exists yet.
- Generators have not held Kaze's identity. The one that passed moderation drifted proportions and apparent age.
- AI generation for this character carries a moderation risk and an identity-drift risk. Drawn key poses are the lower-risk path.
- Warping the approved idle frames can give subtle breathing, hair and ribbon motion, but it is not redrawn animation and cannot produce long-idle acting or crouch.

## 9. Engineering integration requirements (for later, not done)

- Crouch: add a state and animation hook in `player.gd`. Collision shape and crouch mechanics must stay under engineering and creator approval.
- Long-idle: add an inactivity timer and a clip transition in `animate()`. Today idle uses `int(animation_clock / 0.16) % 8`.
- Per-clip entries needed in the visual scale and baseline dictionaries if new strips use a different cell.
- Default animations must not be replaced until the creator approves.

## 10. Recommended next steps

1. Decide the production path. Recommended: Aseprite with drawn key poses (creator or artist) using approved frames as onion-skin references. Claude then scripts in-betweens, registration, strips, previews, QA, manifest, and PR through the Aseprite CLI (`--batch`, `--script`, `--sheet`, `--data`). Needs either a connected folder or Claude Code running locally.
2. In parallel, Claude can build a mesh-warped standard idle from the approved frames, labeled as subtle idle motion, to give Priority 1 a reviewable candidate.
3. Ask Higgsfield support why this reference set is flagged. Do not rewrite prompts to evade it.
4. After assets exist: pixel QA, game-scale contact sheets, GIFs, ART-05 Godot testbed run on a machine with Godot, commit, push, draft PR, SHA256 verification against GitHub.
5. Do not merge. No creator approval is claimed for any new art.
