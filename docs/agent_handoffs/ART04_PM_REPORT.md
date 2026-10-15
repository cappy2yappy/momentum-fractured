# Kaze — ART-04 Project Management return

Date: October 15, 2026, America/New_York. Owner: The Art Mane. Milestone: Alpha 0.6.1.

**Delivered: usable transparent production art and native game-scale review, pending creator acceptance and Level integration.** Four authored Kaze keys, eight environment textures, one packed atlas, two collision-free Godot prefabs and a real four-key SpriteFrames resource. No active game binding, accepted art replacement or merge.

## Authority / recovered work

Read the complete ART-04 assignment at `4d2c97ba47717f9f7958a91d1992504822c85628`. Verified ART-03 #28 at `fc998f9b22f3e778cc51ee2c81668ad73ac7902e` and PR #27 at `c2c002267c58e991966c0eebf7e098c6e7fff769`, inspected actual approved paintings/current cleaned Kaze idle/run frames, existing30-frame contract, endpoint metadata, structural pilot code and continuity. ART-03 visual direction is now creator-approved; its old pending-review records are historical. Preserved all existing art and sources.

Dedicated branch: `art/art04-production-pilots`, based on verified #28. Local checkout: `work/art03-recovery`; separate PR27 reference snapshot: `work/art04-level-reference`. Exact art SHA and draft PR are recorded below after publication. No other agent branch was overwritten or force-pushed.

## Implemented assets, not proposals

| Group | Supplied |
| --- | --- |
| Kaze keys | rear-quarter depth turn, inward rear step, right-up stair contact, separately drawn left-down landing; each320 ×724 RGBA, pivot(160,600), source occupied height calibrated to approximately94–97px game display |
| Door | full open frame, split rear frame, front jamb/threshold occluder, separate painted interior; shared208 ×224 canvas/root(120,208) |
| Stair | supported masonry flight/landing and separated front contact lip |
| Supports | R14 detailed timber knee braces/wall backing/tile cap; R15 arch with radial voussoirs/keystone and two rooted piers |
| Godot resources | four explicitly named single-key nonloop clips, registered preview node and three-layer doorway prefab; texture import settings supplied |
| Editable/source | nine high-resolution RGBA generation masters (including preserved pre-cleanup arch), eight OpenRaster sources, exact prompts/reference provenance, deterministic export/registration script |
| Evidence | eight native1280 ×720 zoom1 captures, before/after room comparison, in-engine pose gallery, environment layer board, black/white/gray/indigo alpha review, manifests/hashes and native renderer logs |

Inventory and exact anchors: [review index](../art/art04/README.md), [Level coordination contract](../art/art04/LEVEL_HANDOFF.md), `assets/art04/ART04_ASSETS.json`, `assets/art04/MANIFEST.json`. Source files: `source_art/art04/`. Runtime texture payload is approximately1.4MB including metadata/imports; source/review files are excluded from engine import with `.gdignore`.

Used built-in OpenAI image_gen for actual raster drawing; Pillow/NumPy for requested extraction, alpha cleanup, fixed root transforms, packing and review layouts; Git/GitHub; native Godot4.6.1. No Aseprite/Higgsfield use claimed. ORA paint layers are flattened within their individual layer; only door foreground/rear/interior and character hidden guides are actually separated. No invented hand-painted body/hair layers or layered PSD claim.

## Actual QA

- 13 runtime PNGs: full decode, chunk CRC/IEND and SHA-256 verification passed; all RGBA with genuine transparent pixels; zero hidden RGB at alpha0. Low-alpha export noise removed, visible contours retained. Four fixed320 ×724 keys and atlas cell parity/12px margin checks passed.
- Eight ORA archives pass ZIP CRC and merged-image decoding. All eight native capture files are1280 ×720. Source hashes and image bounds recorded.
- Godot4.6.1 on native macOS Apple M4/OpenGL compatibility loaded the real SpriteFrames resource and instantiated both prefabs. Final native capture log has no script/resource error. Camera zoom1.0. R14 colliders remain23 before/after; R15 remain15. Baseline verifier zero failures.
- Visually inspected all authored masters, final key sheet, transparent layer board, native doorway/stair/support captures and enlarged stair contacts. Brown skin, purple hair/costume and green ribbons/bow retained. Rear view naturally hides the chest bow. Warm-pixel proxy samples are recorded, not treated as an identity approval; final artistic fidelity remains a creator review gate.
- Captures show a real turning silhouette, rear inward step, distinct ascent/descent knee mechanics and contact surfaces. Frame roots remain fixed; environment stair staging uses vertical0.8 to align lower/upper treads, never character squeezing. Foot contacts were reviewed statically; no animated contact-drift certification is claimed.
- First custom-draw fixture released temporary texture resources before rendering and showed white rectangles. Cached textures corrected this; only corrected captures are delivered. Initial sandbox GUI attempt aborted; authorized native rendering succeeded. Headless import emitted profile-permission/certificate/shutdown diagnostics; successful native render evidence is distinguished from those diagnostics.

## What remains incomplete

These four usable keys are **not complete motion cycles**. Remaining turn/inward/outward/reorientation/ascent/descent/walk frames and opposite-facing review remain open; approved run is unchanged. Four keys are not relabeled as30 frames or a finished animation pack. No new default player clip was bound.

The actual room captures expose inherited procedural roof masses/large canal arcs drawing over parts of the production dressing. Level must resolve those scoped placeholder layers and match material brightness against its final room lighting. This is an integration task, not evidence that a full room reskin is accepted. R17 descent arrival, live proxy timing/occlusion, reduced-motion playback and cancel/death/rebuild cleanup remain for Level's integration QA.

No playable ART04 build, native Windows export/check, input/gamepad test, save/progression regression rerun or sustained60FPS certification is claimed. No gameplay/scene graph/collider/save code is changed on this art branch. A static native Mac fixture is not a full build smoke test or creator playtest.

## Coordination / recommended next actions

Level contract is based on actual PR27 source, not inferred scene coordinates. Consume reviewed `assets/art04/` from the pinned art checkpoint, keep runtime integration on Lane A's branch and retain original/refined/art-preview/reduced/plain options. Do not merge this art branch's older gameplay foundation wholesale. Preserve existing run registration and0.65s/39-tick loader events. No live Level acknowledgment is assumed; publication/coordination links follow below.

1. Creator reviews four keys and actual-scale screenshots for identity, contacts and materials.
2. Level resolves only pilot placeholder layer ordering; maps accepted keys into render adapter and existing R14/R13 depth demo/R14/R17 stair metadata, with fallback and explicit missing-cycle labels.
3. Continue the accepted30-frame production contract after focused key feedback; outward/front-quarter and real walk art are still needed. Do not reverse ascent to fake descent or slow approved movement to suit art.
4. Level validates actual transitions, safety cleanup, both directions, destination masking, saves and bounded render cost. Build Shogun then pins art/integration commits for separate Mac/Windows comparison packages.

No merge, public release or approved sprite replacement authorized by this report.

## Verified publication and coordination

- Art branch: `art/art04-production-pilots`.
- Published production art commit: `9f4e7151b1f8aa683123ee59aa549c3d8c2b4bb7`.
- Draft PR: [#30](https://github.com/cappy2yappy/momentum-fractured/pull/30), stacked on ART-03 #28.
- Level implementation coordination: [PR27 comment](https://github.com/cappy2yappy/momentum-fractured/pull/27#issuecomment-6201972556), containing exact asset names, pivots, room anchors, missing clips and review/integration boundaries. No response or integration is assumed.
- Native renderer evidence: [NATIVE_RENDER.txt](../art/art04/NATIVE_RENDER.txt), [baseline capture](../art/art04/BASELINE_RENDER.txt).

Publication pointers, renderer text logs and continuity are a subsequent documentation checkpoint; current exact branch HEAD is recorded in PR30's description. No force push or merge. Source/gameplay preservation compared against ART03 base has zero task changes outside the new art/review/continuity paths. Inherited CRLF QA file noise remains excluded.
