# ART-03 — Recovery, visual polish and production art return

Owner: The Art Mane. Date: October 15, 2026, America/New_York.

**Verdict: three complete painted concepts ready for creator review.** Production sprite animation, runtime integration and creative acceptance remain pending. No merge.

## Recovery and correction

Reviewed actual PRs #24, #25, #26 and #27, including creator/PM feedback, full authoritative TR-03 assignment at `880718f51b761ffbe40fb028741135b58b00e5f1`, existing Art Mane continuity and both TR-03 Art Mane handoff reports. Recovered PR #26's head `0b96d41fa7b6b424591fdd685f5c8fdf9290c02b` into an isolated checkout. Prior records differ: CONTEXT/state still pointed at #25 while next-task pointed at #26; the current continuity resolves this drift.

The four committed #26 PNGs are damaged, not merely awkwardly displayed: all fail strict pixel decode and chunk CRC checks; all differ from their recorded size/hash. The master is 786,443 bytes versus 3,149,224 claimed, with no complete decodable scene. Its dimensions are 1672 × 941, and its extractor cuts this into 1672 × 307/283/319 strips. Best-effort partial decoding exposes only upper portions of each scene. See [RECOVERY_AUDIT.json](../art/tr03/art03_recovery/RECOVERY_AUDIT.json) for actual/claimed hashes and exact decoder errors. Binary corruption's cause and any pre-publication complete source remain unknown.

Preserved every prior asset/source file. Reconstructed three separate full landscape paintings using the existing Kaze contact sheet, biome art board and surviving painterly direction. Missing pixels were newly generated, not recovered. Retained brown complexion under scene lighting, long purple hair, green ribbons/chest bow, purple costume and anime silhouette. Doorway's rear angle naturally hides most of the chest bow; the front-facing references and other paintings preserve it.

## Deliverables

All new art is under `docs/art/tr03/art03_recovery/`:

| Deliverable | Result |
| --- | --- |
| 01_doorway.png | 1672 × 941; complete full figure turning into recessed timber doorway; threshold and interior floor depth |
| 02_staircase.png | 1672 × 941; distinct upper/lower boot contacts, bent leading knee, continuous supported stair flight and landing |
| 03_supported_crossing.png | 1672 × 941; planted running contact on continuous walkway, complete arch/piers and braced timber landing |
| REVIEW_GALLERY.png / .svg | All three full scenes, fitted without clipping; editable linked layout |
| BEFORE_AFTER.png | Paired old partial decodes versus reconstructed full paintings; missing-data fill clearly labeled |
| review_1280_*.png | Openable 1280 × 720 concept review copies |
| PRODUCTION_SOURCE.json | Exact per-image prompts, references, actual tool use and source limitations |
| ASSET_MANIFEST.json / RECOVERY_AUDIT.json / QA_RESULTS.json | SHA-256, byte sizes, dimensions, decoding/CRC results and visual observations |
| tools/art03_review.py | Reproducible layouts, comparison generation and strict file integrity audit |

The full PNGs are flattened raster masters. No layered PSD, Aseprite file, separated character/environment layers or 30-frame pack is claimed. Used built-in OpenAI image generation and Pillow; Higgsfield and Aseprite were not used.

## QA and limits

Passed: strict full decoding, every PNG chunk CRC and complete IEND for all eight new PNGs; visual inspection of all three generated full scenes plus gallery and comparisons; approved baseline verifier with zero failures. All final figures fit inside their scenes with visible hair, hands and boots. Stairs show separate tread contacts; crossing's load-bearing arch and pier foundations are visible. Warm doorway/daylight and cool night lighting retain brown skin, with final identity fidelity still subject to creator review.

The paintings are posed visual development, not exact production sprite matches or room-layout approvals. They use closer character framing than the approximately 97px upright gameplay target. 1280 × 720 copies check presentation readability only, not camera zoom-1 acceptance. Doorway is one turning-step concept, not a demonstrated entry/exit sequence; stair descent and walk-cycle drawings are absent. New-frame alpha/pivot/contact drift, integrated transition timing, exports and performance were not tested because no sprites or runtime were changed. No sustained-60FPS or playable-build claim.

Preservation: existing `assets/`, `scripts/`, `scenes/`, `project.godot`, old art and technical contract were not staged or changed by this task. The inherited CRLF QA_RESULTS.json shows Git normalization noise in this fresh checkout; it is excluded from all commits and its worktree bytes equal the base blob. Existing sources are not replaced. The old report's image-completeness claims are superseded by this measured recovery audit.

## Publication and handoff

Dedicated branch: `art/art03-complete-compositions`, based exactly on PR #26 head above. Draft PR targets `art/alpha-0.6.1-tr03-production-revision` to isolate this follow-up. Exact publication commit/PR pointers are recorded in `ART03_PUBLICATION.json` after the first backed-up checkpoint; no unpublished local state is described as backed up.

Checkout: `work/art03-recovery` inside the Kaze project workspace. This is a separate clone, not a managed Git worktree. No concurrent branch overwrite or force push.

Technical blockers to this concept delivery: none after reconstruction. Original missing pixels could not be recovered from Git; native layered source does not exist. Creative approval and later sprite authoring remain the next phase, not a completed requirement.

## Next production steps / Level coordination

1. Creator reviews full framing, skin/face fidelity, doorway depth, stair weight and visible supports. This is approval of concepts only.
2. Continue the existing 30-frame contract from PR #25 without repeating planning: walk6, turn4, entry3, exit3, profile2, ascent6, descent6; reuse current run. Start with rear turn and stair contact keys at canonical brown skin swatches. Do not reverse ascent to fake descent.
3. Retain 320 × 724 cells, pivot (160,600), 12px alpha margin and proposed 97px upright scale for future new clips. Existing clips retain their own scales/pivots.
4. PR #27 verified head `c2c002267c58e991966c0eebf7e098c6e7fff769` remains a comparison candidate with labeled placeholders, not accepted finished animation. Later integration must use Lane A's render adapter and actual R14/R13 depth-demo, R14/R17 stair and R15/R16 horizontal metadata. Preserve 0.65s/39 ticks and loader-event timing; no graph/collision/save changes or global support rollout.
5. Final sprites require boundary/alpha/anchor/facing/contact QA and actual gameplay-scale review before separately authorized integration. No merge is authorized here.

## Verified publication checkpoint

Published art commit: `f41e4e4c784ad170bfde0f6c33264e6af41c07c4`. Branch: `art/art03-complete-compositions`. Draft PR: [#28](https://github.com/cappy2yappy/momentum-fractured/pull/28), based on PR #26. Verified remote ref equals the local art checkpoint. Continuity records and this pointer are published as a following docs-only commit; retrieve its current exact HEAD from PR #28. Automatic review initially rejected PR creation as an unverified disclosure; read-only destination/ownership checks and the user's attached authorization resolved it, and the same PR action succeeded. No approval remains blocked.
