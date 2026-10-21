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
Asset commit 750e194fff747a71c0f629c5b9a5b7a287354491 on art/art08-embodied-cinematic-animation (confirmed through gh api repos/cappy2yappy/momentum-fractured/commits/<branch>). All 12 shipped strip PNGs re-downloaded from GitHub at that SHA and compared with MANIFEST.json: 12 verified, 0 mismatches. Descent strips: enter 0cc04d4178ab, loop 0c5bc6402148, exit f171d7e4f303, descend_arrive_settle 15d6c4452945 (SHA256 prefixes; full values in assets/art08/MANIFEST.json). Ascent, door and ascent settle strips are byte identical to the earlier verified set. A later docs-only commit adds this section; it changes no PNG.
Environment: Godot 4.6.1, xvfb llvmpipe gl_compatibility; python numpy, opencv, scipy, PIL; model Claude Sonnet 5.5.

## B3a: ascent settle true-animation fix (stair_arrive_idle_settle)
Coordinator request: the QA W3 stair hook measured the ascent at 88 percent of moving windows against a 90 percent gate, the one failing window being frame 3 of stair_arrive_idle_settle. Only that clip was touched (name, 4 frames, cell 480x724, pivot 240,600 unchanged). Descent clips and the ascent enter/loop/exit strips are byte identical (descent sha 0cc04d41, 0c5bc640, f171d7e4, 15d6c445).
Cause measured with the QA tool (tools/pm_pilot_qa/true_animation.py, POSE_T 0.10, GAIT_T 0.30): the ease-out put frame 3 at gait time 5.0 and frame 2 at 4.917, so frame 3 differed from frame 2 by a leg silhouette difference of only 0.218 and a full silhouette difference of 0.135, and the clip then holds its last frame through the 0.30 s close phase. The failing window (t 2.25, frame 3, 1 distinct pose, leg 0.0) is that pure hold.
Change: frame times now evenly spaced (4.25, 4.5, 4.75, 5.0), which redraws frames 1 to 3 as distinct poses (the far foot is clearly in the air at frame 2 and lands at frame 3), and the manifest row carries durations 0.12, 0.16, 0.20, 0.20 s (Transition already reads durations, no code change). Root motion x per frame 41.25, 15.5, 15.5, 0 (same 72.25 total). New settle sha256 0d917aa3e07a8a44cf781f9ffa660b27e80735ac966e19fe177889dff8a49164.
Per-frame difference (QA analyzer, 0 = identical silhouette), consecutive pairs 0-1, 1-2, 2-3:
| | leg difference | full silhouette difference | frame 3 vs frames 0,1,2 (full) |
| --- | --- | --- | --- |
| before | 1.197, 0.735, 0.218 | 0.527, 0.365, 0.135 | 0.524, 0.411, 0.135 |
| after | 1.315, 0.770, 0.671 | 0.556, 0.356, 0.315 | 0.524, 0.446, 0.315 |
No pair of frames is byte identical (raw RGBA mean abs difference consecutive 7.9, 5.2, 2.4 before; recomputed in docs/art/art08/qa/ascent_settle_b3a.json). This is a retiming of the same rig, so frame 3 itself is the same final standing pose; what is new is that frame 2 is now a real mid-step pose, so frame 3 is a real arrival step. No scaling, bobbing or hold was used.
QA hook measured by me (tools/pm_pilot_qa hook_w3_stair, headless, Transition eb3cc0f with these assets in a scratch checkout, W3-STAIR-ASCEND-TRUE-ANIM): before 87.5 percent of 8 windows (reproduced); re-spacing only 88.9 percent of 9 (still the pure-hold window); re-spacing plus durations 100 percent of 8, no bad window, 44 PASS and 0 FAIL in the stair hook, descent still 100 percent of 7. Ascent E-to-control time 2.88 s to 3.23 s (gate 1.5 to 6.0). Honest note: the durations lengthen the ascent ending by 0.35 s; without them the pure hold window (last frame plus the 0.30 s close phase) cannot be removed by drawing alone. The rendered letterbox gate was not run here.
Before/after through the real cinematic (Transition eb3cc0f, real E press at R14, xvfb llvmpipe, 60 Hz fixed step, one frame per 3 ticks, played at 20 fps): docs/art/art08/ascent_settle/ascent_settle_before_after_native20fps.mp4 and .gif, cinematic_capture_before.json (58 frames, 3.02 s) and _after.json (65 frames, 3.37 s).
Not run by me: the full QA W3 run (core, doorway, rendered), so other gates are unverified for this strip. Creator visual acceptance is reserved.
