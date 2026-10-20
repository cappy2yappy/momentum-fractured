# MISSING POSES: authored Kaze material not in the repo (ART-PM pilot)

Status: exact request list. Nothing below exists as an approved drawing. The pilot staging preview uses only the approved run and idle strips plus deterministic composition (a dark tint, occlusion layers and a wipe). It does not contain an entry, traversal or departure animation, and it must not be described as one.

Canvas for every new frame: **320 x 724, pivot (160, 600), engine scale 0.303125** (ART-04 contract, `assets/art04/ART04_ASSETS.json`; sprite offset (0,-238)). Feet contact on the pivot row. Transparent background, same purple jacket, green bow and ribbon, dark skirt, thigh-high boots and hair mass as the approved cleaned strips. Do not mirror rear-facing entries to make outward exits (`docs/tr04/ART_REQUESTS_AND_NARRATIVE.md`). Directions are screen-space.

## What exists and what it can honestly do

| Material | Status | Use here |
|---|---|---|
| `assets/kaze/cleaned/kaze_run_strip.png` (8 frames), `kaze_idle_strip.png` (8) | approved authored drawings, own scales 0.3826 / 0.2650 | Approach and standing at the Canal door (flip_h for left, exactly as `player.gd` does) |
| `assets/art04/kaze/*_key.png` (4 keys) | held poses, single drawings, creator acceptance pending | Registered in the manifest as held poses, not used in the Canal preview |
| PR #41 `turn_depth` (4 frames) | candidate for the right-to-rear turn only | Not imported. Wrong direction for a leftward exit |
| PR #41 `enter_depth`, `stair_up` | WIP with defects / rejected | Not imported |
| Higgsfield | not used. An earlier generation drifted off model and some were blocked; no moderation bypass, no credits spent | none |

## A. Canal exit, R13 left (Kaze walks left, aperture in the rear plane at x 72..168)

| # | Pose / clip | Frames | Direction | Must show | Why the approved material cannot cover it |
|---|---|---|---|---|---|
| A1 | `canal_walk_left` | 8 (loop) | left profile | Slow grounded walk, upright torso, arms swinging, hair and ribbon trailing; contact, down, passing, up for both feet | Only a sprint and an idle exist. A sprint into a 96 px door reads as a collision, not a doorway. |
| A2 | `canal_turn_left_to_rear` | 4 | left profile to rear three-quarter | Head turns toward the door first, shoulders follow, weight shifts onto the inner foot | PR #41 `turn_depth` only covers right-to-rear. Mirroring it flips the asymmetric ribbon and hair; needs a creator decision or a new drawing. |
| A3 | `canal_step_into_door` | 6 | rear | Last step over the sill, shoulders slightly lowered under the head, hand reaching the door leaf, back foot lifting | `enter_depth` is a single WIP key with defects. |
| A4 | `canal_exit_held_end` | 1 | rear, mostly in shadow | Final silhouette against the lit far end | none |

Subtotal A: 19 frames.

## B. Canal arrival, R13 side (from R0, Kaze feet at (184,1198), facing right)

| # | Pose / clip | Frames | Direction | Must show |
|---|---|---|---|---|
| B1 | `canal_emerge_from_door` | 6 | front three-quarter to profile right | Stepping out of the aperture toward the viewer, then angling right |
| B2 | `canal_turn_front_to_right` | 4 | front to right profile | Weight transfer, head leads |
| B3 | `canal_walk_right` | 8 (loop) | right profile | Mirror-independent slow walk matching A1 (drawn, not flipped, because of the asymmetric ribbon) |

Subtotal B: 18 frames.

## C. R14 to R17 stair (recommended pilot, STORY guidance). Not built in this pilot

| # | Pose / clip | Frames | Direction | Must show |
|---|---|---|---|---|
| C1 | `stair_up_climb` | 8 (loop) | right-facing profile, ascending | Foot contacts on treads, knee lift, hand near rail; not an altitude cue |
| C2 | `stair_down_descend` | 8 (loop) | right-facing profile, descending | Heel-first contacts, torso counter-lean |
| C3 | `stair_enter_up`, `stair_enter_down` | 4 each | profile | Transition from floor walk to first tread |
| C4 | `stair_arrive_up`, `stair_arrive_down` | 4 each | profile | Landing and return to floor walk |

Subtotal C: 32 frames. The approved `stair_up_key` / `stair_down_key` are single held poses and cannot form a cycle.

**Total: 69 drawn frames** (A 19, B 18, C 32), plus per-clip pivot and contact data.

## What is needed

1. An artist, or the creator, with access to the original layered Kaze source files (the ART-04 keys were cut from larger source drawings: turn root (650,1470), entry root (600,1459) at scale 0.2348), and a frame-animation tool (Aseprite, Krita, Clip Studio). Aseprite is not available in this sandbox and no drawing tablet input exists.
2. Or a creator-driven image-generation pass with a locked Kaze reference set, run by the creator under their own moderation and credit decisions, followed by cleanup against the approved strips. This agent did not do that.
3. Creator sign-off on A2 (mirror versus new drawing) and on whether the R0 end of the Canal needs its own arrival art.
4. Level and Story decisions already requested elsewhere: the R0 end of the passage and any camera behaviour.

## Interim rule for engineering

Use the approved run and idle strips for approach and standing. Hide the character inside the aperture with the occlusion layers and a tint (see `docs/pm_pilot/art/ART_INTEGRATION.md`). Do not stretch, squeeze or mirror a rear key to fake an entry. Keep the placeholder label honest until the frames above exist.
