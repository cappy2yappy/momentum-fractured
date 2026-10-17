# ART-06 Handoff: Kaze Lateral Room-Transition Pilot

Branch: `art/art06-kaze-lateral-transition-pilot` (stacked on PR #41, `art/art05-animation-pipeline`)
Date: 2026-10-16
Status: CANDIDATE. Nothing here is approved, merged, or bound to default gameplay.

## 1. Where things stand (read this first)

| Item | On git? | Notes |
|---|---|---|
| Authoring contract (`source_art/art06/authoring.json`) | Yes | cell 480x724, baseline 491, root x 240, scale 0.38258, 20 fps |
| Identity reference crops (`source_art/art06/refs/*`) | Yes | Derived from approved run frames; originals untouched |
| Tools (`tools/art06/`: register, qa, cutaway, preview) | Yes | Python: numpy, Pillow, scipy |
| Generated pixel assets (`assets/art06/**`: strips, hero strips, cutaway frames, MANIFEST, previews, GIF) | NO | Generated in an isolated cloud sandbox that could not reach GitHub storage. Delivered as `art06_pilot.zip` (14.5 MB, 84 files) in the owner's Higgsfield file storage, media id c6054f75-151d-4c9c-b4c8-55c5d8d6a334 |
| Raw AI sheets and cleaned frames (`source_art/art06/raw`, `frames`) | NO | In the same zip |
| Godot import / SpriteFrames / in-engine capture | NOT DONE | No Godot run has happened. Previews are Pillow composites on stand-in rooms |
| Handoff (this doc) | Yes | |

Action to close the gap: unzip `art06_pilot.zip` at the repo root on this branch, commit, push. `assets/art06/MANIFEST.json` lists hashes so the drop can be verified.

## 2. What was made

One lateral room transition, right-facing (left uses the engine's existing `flip_h` convention):

- `lat_depart`: 3 frames (run commit, anticipation drop, launch). Non-looping.
- `lat_travel`: 6 frames (R contact, R support drive, flight, L contact, L support drive, flight). Looping. Shown on a separate transition screen.
- `lat_emerge`: 4 frames (burst in, brake plant, recover absorb, ready). Non-looping.
- Cutaway "Ribbon Rush": original slanted purple bands, parallax gate pillars and green streaks echoing her hair ribbon. No text, no strobing. Max tick-to-tick mean luminance step 1.5%. Persona 5 was timing and composition inspiration only; no artwork, type, UI or effects were copied.

Timeline: 13 ticks at 20 fps (0.65 s, matching the TR05 loader clock). Tick map: D0-D2 departure in room, T0-T5 travel in cutaway, E0-E3 emergence in the next room. Room swap happens near tick 6 (about 0.32 s remaining in the loader). Cutaway bands cover the screen ticks 2-9 and are clear by tick 10.

## 3. Contracts

- Cell 480x724, pivot (240, 491 baseline). Lowest opaque row on baseline in every frame (matches approved run strip convention).
- Engine scale 0.3825780535911868 for in-room Kaze. Hero (cutaway) draw scale 0.4591 (2.4x run scale, 2x supersampled hero strips).
- Note: existing PR #41 transition poses use 320x724 cell, pivot (160,600), scale 0.303125. This pilot uses the run-strip family contract instead. Transition Masta should not mix the two.
- Frame height calibrated to approved run height (253 source px) per clip, one uniform scale per clip.

## 4. QA results (tools/art06/qa.py)

- Zero problems flagged: baseline row, hidden RGB, low-alpha residue, 12 px margin, no source clipping, all frame hashes unique, no near-duplicate pairs (travel worst pair IoU 0.766).
- Not covered: any in-engine check. Animator or testbed (ART-05) review has not happened.

## 5. Candid art assessment

- Strong: silhouette, ribbon and hair carry through the departure and emergence; the cutaway reads as a distinct screen and is clear of text.
- Weak: the travel cycle alternates near and far leg subtly. It is three poses repeated as distinct drawings, so it may read as less than a full stride at game speed. Recommend an animator pass before approval.
- Weak: emergence frame E0 is about 10% smaller than the approved run because the clip was calibrated to the ready pose. Visible as a slight pop. Known trade-off.
- Baseline observation (not caused by this work): approved idle and run differ about 44% in head size.
- Previews are stand-in rooms, not Godot captures. Do not judge final integration from them.

## 6. Status by sequence

| Sequence | Status |
|---|---|
| lat_depart | Candidate |
| lat_travel | Candidate (needs animator review) |
| lat_emerge | Candidate |
| Ribbon Rush cutaway | Candidate |
| PR #41 turn_depth | Plausible candidate from board review: frame 3 legs pressed or crossed, short (0.20 s). Written critique NOT done |
| PR #41 enter_depth | Work in progress, incomplete |
| PR #41 stair_up | Rejected |
| Depth-door entry correction | NOT STARTED |
| Stair ascent/descent cycles | NOT STARTED |
| Anything approved | None |

## 7. Integration notes for Transition Masta

- Opt-in adapter only. Do not bind to default gameplay. Do not alter movement, progression or saves.
- Loader clock: `elapsed = 0.65 - w.transition`; swap below 0.32 s remaining. Transition Masta owns loader, cutaway and arrival timing.
- Left-facing: mirror via `flip_h = heading < 0`, same as existing run.
- Reduced motion plan: follow TR05 reduced behavior (no proxy motion, anchor frame 0) plus a short fade instead of Ribbon Rush bands. Not yet built or previewed.
- Photosensitivity: low-luminance, non-strobing by design, measured 1.5% max step.
- Repetition policy (full cutaway every crossing vs abbreviated return) is an open creator decision. Not hard-coded.

## 8. Provenance

- Generated with the Higgsfield MCP, model gpt_image_2_5, high quality, 2k, transparent background, conditioned on approved run frames. Jobs: dep_t1 0fb84da1-d908-4745-9f00-a9a3bd5b1006, trv_t0 24a22fda-9f68-4974-90a4-61436fe851c0, em_t1 e84a9c9e-b360-4e9f-a2a3-90455677baca. Rejected: dep_v1 (opaque gray background), other alternates.
- Canon: Kaze is 16. PR #41's historical prompts describe her as 25; that is preserved as truthful provenance and was not followed here.
- Cutaway and previews are procedural (Pillow), not AI generated.

## 9. Open items for the PM

1. Owner drops the zip into the branch (see section 1).
2. Decide next target: Godot import and ART-05 testbed run, or priorities 3 and 4 (depth-door entry fix, stair cycles).
3. Animator review of the travel cycle.
4. Creator decision on cutaway repetition.
5. Housekeeping: `tools/art06/__pycache__` was committed and should be removed.
6. Run `tools/verify_baseline.py` after the assets land.
