# ART05 → Transition Masta / Level handoff

Foundation: PR39 `5dfc4c4f077c5408ecbe49f1cafafea1dcb1003c`, itself on PR37 `b950373efb5c4621d7da7e0be1506db048e3043a`. No gameplay or existing presentation script was modified.

## Supplied now

- `assets/art05/kaze/ART05_candidates.tres`, horizontal sheets and `MANIFEST.json` carry actual counts and status per clip. `turn_depth` is a 4-frame right-quarter/profile → rear candidate, 20 fps, duration 0.20 s. Its starting angle still needs a profile-to-turn seam review against live movement before binding.
- `tools/art05/proxy_adapter.gd` applies this candidate to TR39's actual `Sprite2D` render proxy with explicit opt-in. It preserves source frame dimensions, pivot and uniform scale. Native fixture checks texture parity on the real `w.embodied_transitions.proxy`. It always refuses entry/stair WIP and does not own root movement, gameplay facing, timing, visibility or cleanup.
- No X reflection is certified. Rear drawings must not be reused as front-facing emergence. Do not reverse ascent for descent.
- The Bellroof module belongs only at `(520,1220)` with native dimensions `(180,80)`. The testbed adds a collision-free visual overlay; it neither edits `bellroof_walk.gd` nor paints across a gap. Other masses, supports, Canal boundaries and art remain future work.

## Timing / ownership

The existing loader still owns 0.65 s / 39 ticks and the room swap below 0.32 s remaining. A 0.20 s turn cannot simply be concatenated with all other nominal clips to extend that clock. PR39 treats R13↔R14 as automatic **side passages**, so do not force this rear turn into those passages. Use it only for a meaningful depth entrance after seam/facing approval and source/occluder timing review. Keep approved running phase, reciprocal arrival, reduced/plain options, pause/death/cancel cleanup and the live player restoration unchanged.

## Missing production drawings

Entry needs believable left/right contacts and a seamless rear start. Stair source is rejected for clipped cells and repeated lead-leg mechanics: redraw with clear blank margins, alternate contacts, passing knee, body lift and landing recovery. Separate descent, front-quarter emergence, return-to-profile and walking remain absent. Keep the existing explicit fallback/prototype labels until complete sequences pass review.

## Before binding to default gameplay

Review at actual gameplay speed in the supplied testbed; validate identity, source/destination facings, clipping, planted contacts and both directions. Then test real source/swap/arrival/resume windows, occlusion, stopping, reversal, reduced motion, room rebuild, pause/death/cancel and sprite/camera restoration through PR39's owner. The ART05 fixture proves import/playback/real-proxy compatibility, **not** live transition acceptance.
