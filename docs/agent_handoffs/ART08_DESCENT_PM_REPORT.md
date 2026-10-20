# ART08 descent revision report (Art Mane)

Branch art/art08-embodied-cinematic-animation, PR #62 (draft, no merge). Starting head 82d5998c. Creator feedback: the full-screen staircase is a good start but she looks like a hunchback going down. Descent is NOT approved. Creator visual acceptance is reserved.

## Which clips each launcher selects
Per docs/tr08/DEMO_ARGS.md and scripts/tr08_stair_stage.gd (Transition worktree, read only): Play-TR08-Stair-Descend (fixture TR08-Stair-Descend.json, R17 feet 1650,1298, E key) and any R17 to R14 descent run the queue stair_descend_enter, stair_descend_loop x loops, stair_descend_exit, then stair_arrive_idle_settle, with flip_h for the leftward heading. Play-TR08-Stair-Ascend uses the stair_ascend_* clips and is untouched (ascent strips byte identical, sha 67f27fb5, 59e9643a, e18a4fb5). There is no separate return-stair path.

## Diagnosis (inspected frames, docs/art/art08/descent/)
1. Wrong donor: v1 descent was cut from stair_up_key, a forward lunge (waist to collar 28 deg in its own drawing). A -14 deg counter rotation of the rigid torso left a rounded jacket back and head forward of the shoulders.
2. Run-like stride: 188 px pitch against a 131 px leg gave a bound with the trailing thigh kicked back near horizontal.
3. Heel-first landing and a swing foot lifted 22 px, no weight transfer onto a flexed knee.
4. The arrival settle clip (shared with the ascent) is built on the climb rig and rises 8.7 px, so a descent ended on the hunched pose.
Ribbon side: the v1 strip was right-facing from a right-facing donor; mirrored for the leftward descent it put the ribbon on the wrong side relative to the approved stair_down_key. v3 mirrors the approved left-facing key once, so Transition's flip returns the drawn side.

## What changed
- tools/art08/down_parts.py, down_rig.py: upper body (head, hair, torso, skirt, both arms) cut from assets/art04/kaze/stair_down_key.png; forearms cut at the elbow and rotated 16 deg counter-swing; hair tips sine-warped. Legs and boots reuse the approved stair_up_key leg tube and boot parts (same drawing style).
- tools/art08/gait.py: toe-first landing option; clips_profile.py: stair pitch, rise parameters; clips_build.py: STAIR_DOWN2 (lean -5, pelvis 168/152, clearance 14), DOWN_GEOM (pitch 100, drop 30).
- Clips: stair_descend_enter/loop/exit regenerated (4/8/4 frames, 480x724, pivot 240,600, same names and fps); NEW stair_descend_arrive_settle (4 f). Provenance "cut-out rig v2 (authored by script)", status candidate.
- Interface bumped to v3 (shared ANIMATION_INTERFACE.md, changelog line). INTEGRATION.md updated and mirrored.

## Measurements (all from rendered pixels or rig output, source px unless noted)
| metric | v1 before | v2 after |
| --- | --- | --- |
| waist to collar tilt, loop (mean, min, max deg forward) | 11.8 (9.7, 14.4) | 6.9 (6.2, 7.5) |
| head to collar offset, loop (px) | 10.8 | 12.5 (no improvement; the metric does not capture back curvature) |
| flat-foot slide, worst foot (px) | 1.76 | 1.24 |
| planted sole y error, loop (max px) | n/a | 1.14 |
| loop seam, virtual next frame vs frame 0 silhouette XOR | 0.18 | 0.069 |
| leg-band adjacent XOR min (real motion) | | 0.445 (loop) |
| hidden RGB pixels, palette outside approved | | 0, 0.0 percent |
Files: docs/art/art08/qa/descent_spine_v1.json, descent_spine_v2.json, descent_foot_slide.json, extra_profile.json, stair_descend_*.json. Limits of the metrics: waist is the skirt centroid, collar the white collar pixels; hunch is a shape judgement, shown visually, not a single number. In the loop, frames i and i+4 have near-identical leg silhouettes (min any pair XOR 0.009) but differ in arm swing and which leg is far.

## Real-cinematic before and after
Captured through the actual TR-08 cinematic (Transition commit 079d9b2, real E key press, xvfb llvmpipe gl_compatibility, 60 Hz fixed step, one frame every 3 ticks, played back at 20 fps = native speed): docs/art/art08/descent/descent_before_after_native20fps.mp4 and .gif (58 frame pairs), descent_before_after_sheet.png, cinematic_capture_before.json and _after.json. Before = their commit as bound to v1; after = same commit with my assets and the settle patch applied in a scratch checkout (the Transition worktree was not touched). Sprite2D playback capture of the shipped strips: docs/art/art08/godot_capture/descent_v3_sprite2d_capture.png (all 13 clips play).
Without the Transition patch the same capture shows the descent ending on stair_arrive_idle_settle (the old pose).

## Transition change needed (message sent to agent ae1d6a586094f46f5)
docs/art/art08/descent/transition_settle_patch.diff: add stair_descend_arrive_settle to CLIPS and a stand-in row in tr08_clip_library.gd, exclude it from the soles and root checks, and queue it for rise>0 in tr08_stair_stage.gd. The existing clips need no change. I did not edit their files.

## Limits and not done
- Upper body is rigid, only forearms and hair move; no spine flex per frame.
- Descent flight (100/30) differs from the ascent flight (188/43).
- A fraction of detached hair wisps and a small purple jacket shard below the back elbow remain (donor drawing); max_components 3.
- door clips and ascent unchanged. No Higgsfield credits used.
- Creator acceptance of the descent is not claimed.

## SHAs
See the closing section appended after push (commit, GitHub re-download verification).
