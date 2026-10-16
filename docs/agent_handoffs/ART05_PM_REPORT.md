# KAZE ART-05 — PM return

October 16, 2026 · Alpha 0.6.1 · dedicated branch `art/art05-animation-pipeline` · draft only, do not merge.

**Delivered:** a reusable sprite-sheet production/testbed workflow, one complete short turn candidate, entry/stair WIP, and one original Bellroof masonry example rendered against PR37 geometry. **The overall transition-animation mission remains incomplete:** no complete doorway enter/emerge/return bundle or stair ascent/descent/landing pack is certified or bound to default gameplay.

## Authority and preservation

Started from PR39 head `5dfc4c4f077c5408ecbe49f1cafafea1dcb1003c`, containing PR37 geometry `b950373efb5c4621d7da7e0be1506db048e3043a`. Recovered actual PR30 assets at `a6b76b9938825307bdcd4efb687c7198ea0d8681` and verified byte equality, PNG dimensions, real SpriteFrames and prefab settings. ART04's contract is confirmed: 320 × 724, pivot (160,600), scale 0.303125, centered sprite offset (0,-238). Existing clips have different contracts and are preserved.

Read PR34's production-workflow guidance and PR38/ST03's environmental handoff, including damaged refuge/search framing and geometry-first dressing. Used PR30's approved character/architecture as image inputs. No third-party sprite, clip or extracted frame was copied. Existing controller, physics, collision construction, transitions, progression, save logic, project configuration and original artwork remain byte-exact; task changes are additive.

## Actual EOD deliverables

| Requested item | Delivered / acceptance boundary |
| --- | --- |
| Reusable animation testbed | Working Godot scene with actual-scale reference comparison, 2.5× inspection, pause/frame step, speed, guides, manifest-driven frame count/rate, native captures and real-room before/after |
| Complete candidate animation | `turn_depth`: 4 distinct painted frames at20fps /0.20s, initial quarter/profile → rear, including2 intermediate angles. Complete short turn clip, not a complete doorway transition. Candidate identity/motion review remains subject to creator acceptance |
| Second animation in progress | `stair_up`:6 painted frames, explicitly rejected WIP due to source clipping/weak alternating mechanics. Also8-frame `enter_depth` WIP with crossed legs and seam defects |
| Environment example | New soot-weathered cap/timber/masonry module at exact Bellroof west block `(520,1220,180,80)`, imported and rendered in native Godot zoom1.0. No visual floor across adjacent gap |
| Sources / manifests |4 original flattened RGBA masters, exact prompts, fixed registration JSON,3 editable ORA frame stacks with hidden root guides, SpriteFrames resource, runtime/source hashes and per-frame contact/status metadata |
| In-engine evidence |20 actual1280×720 native captures, derived timed GIF sequences, native playback/resource/proxy checks, real Bellroof before/after and logs |
| Branch / PR / report |Dedicated additive branch stacked on PR39; draft PR publication pointer follows below; this PM report and Transition/Level handoff included |

Review: [motion-first index](../art/art05/README.md), [native turn sequence](../art/art05/evidence/turn_depth_native.gif), [Bellroof after](../art/art05/evidence/bellroof_after.png), [TR39/Level consumption contract](../art/art05/TRANSITION_HANDOFF.md).

## Verification actually run

- **78 final-file technical checks, zero failures.** PNG CRC/IEND/decode, real RGBA/zero hidden RGB, fixed cells/pivot/shared clip scale,12px export margins, unique frames, ORA integrity, source hashes, source-cell clipping detection, opaque180×80 solid-face envelope and additive preservation. Turn contact contour maximum ground error0.303125worldpx; horizontal contact-centroid span0.978577worldpx within the measured heel ROI. These are bounded technical measures, not automatic identity/anatomy approval.
- **80 native Godot checks, zero failures.** Official4.6.1 on macOS Apple M4/OpenGL3. Real SpriteFrames counts/rates, all18 individual candidate/WIP frame imports, fixed scale/offset, actual-speed four-frame traversal, native nonloop completion,1280×720 captures, actual room collider invariance, zoom1.0 and exact module placement. Real PR39 render proxy accepts candidate frames with explicit opt-in; WIP clips are refused.
- **368 existing TR05 checks, zero failures**, run headless with `--test`. Automatic side passages, meaningful depth entrances, both stair directions, cleanup, reduced motion/camera restoration and existing graph policy remain passing. No active runtime code was changed.
- Approved-art/controller verifier and all59 PR37 preservation checks pass. No source/test/scene/physics/geometry/progression file from the pinned PR39 foundation was changed.
- Visually inspected approved keys, new full turn sequence/registration board, native first/final turn views and actual Bellroof before/after. Brown skin, purple hair/outfit, green ribbons, cuffs, skirt and boots persist across candidate frames; no missing limb was observed in the turn. Entry/stair artifacts are explicitly not promoted.

Evidence: [technical measurements](../art/art05/evidence/TECHNICAL_QA.json), [native log](../art/art05/evidence/NATIVE_RENDER.txt), [TR05 log](../art/art05/evidence/TRANSITION_REGRESSION.txt), [baseline](../art/art05/evidence/BASELINE.txt), [preservation](../art/art05/evidence/PRESERVATION.txt), [capture hashes](../art/art05/evidence/CAPTURE_MANIFEST.json).

## Iterations and limitations

The initial entry generation was rejected by image-generation output moderation; no asset was retained from it. Neutral adult game-animation wording produced the supplied sheet. Stair export QA exposed source artwork touching cell boundaries; the sheet remains rejected even though the final output has transparent padding. This prevents a false clipping pass caused by shrinking damaged artwork into a larger canvas.

Native review exposed overlapping fixture labels and an ungrounded traversal pose in the frozen room; the fixture now hides its gameplay HUD, uses an explicit approved idle and labels the art review above it. A final contact-contour inspection found small horizontal settle drift; the authored final root was corrected by2sourcepx, then sheets were re-exported, reimported and native evidence recaptured. Candidate clip timing remains20fps; review GIFs add a400ms endpoint hold between repetitions.

The first sandboxed native graphics launch aborted before drawing. The authorized native run succeeded. Headless editor import emits macOS certificate/editor-profile permission/shutdown diagnostics; the headless regression has a certificate diagnostic but zero script/parser/assertion failures. The final native renderer log is clean. These distinctions are retained; no blanket error-free import claim is made.

No separated character body/hair paint rig, Aseprite authoring, PSD layers, optical-flow inbetweens, default gameplay binding, complete turn-to-entry seam acceptance, outward/front-quarter clip, walking cycle, finished stair gait/descent, Canal environmental integration, exported package, Windows run, human campaign/gamepad test or sustained60FPS result is claimed. Existing PR39 held stair art remains unchanged in ordinary gameplay.

## Next production work

1. Review the right-to-rear turn candidate as motion, including its initial quarter/profile seam, accessories and final contact. Do not mirror it automatically for another facing.
2. Correct entry foot alternation and rear seam; redraw stair source with clear cell margins, alternating contact/passing/weight transfer, rise and landing recovery. Author descent separately, then front-facing emergence and return-to-profile.
3. Transition Masta consumes only accepted clips through the existing render proxy and0.65s/39tick owner. PR39's R13↔R14 is an automatic lateral passage, so a rear depth turn must not be forced into it. Validate occlusion, source/swap/arrival/resume and reduced/cancel/death/rebuild behavior before default binding.
4. Level/Art can expand the approved masonry treatment across corrected Bellroof masses and Canal boundaries, always using actual collision rectangles. Current pilot is one solid module, not a room reskin.

No merge performed.
