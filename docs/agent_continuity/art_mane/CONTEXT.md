# The Art Mane — ART-03 verified recovery

State: handed-off for creator concept review. Branch: `art/art03-complete-compositions`. Draft [PR #28](https://github.com/cappy2yappy/momentum-fractured/pull/28), stacked on PR #26 at `0b96d41fa7b6b424591fdd685f5c8fdf9290c02b`. Verified published art checkpoint: `f41e4e4c784ad170bfde0f6c33264e6af41c07c4`; continuity/report pointers are a following docs-only commit. Retrieve live PR head before resuming. No merge.

Recovered #24/#25 technical work, #26 damaged paintings/master and source prompts, canonical Kaze/biome references, and #27 implementation status. All four #26 PNGs fail strict decoding/CRC and disagree with their recorded hashes. The shallow triptych export cannot recover missing pixels; original pre-publication completeness and corruption cause are unknown. Old art/source bytes preserved.

Delivered three separate complete 1672 × 941 reconstructed paintings: doorway, stair ascent, supported crossing. Full review gallery, before/after, 1280 × 720 review copies, exact prompts, flattened raster masters, editable gallery SVG, measured integrity audit and PM report. Start at docs/art/tr03/art03_recovery/README.md and docs/agent_handoffs/ART03_RECOVERY_PM_REPORT.md.

Verified: all eight new PNGs strict-decode, chunk CRC and IEND pass; full scenes/gallery/comparisons visually inspected; baseline verifier zero failures; protected runtime/assets unchanged. Existing production_revision/QA_RESULTS.json has inherited Git CRLF normalization noise but worktree bytes equal the base blob; excluded from task commits.

Tools actually used: OpenAI built-in image_gen, Pillow, Git/GitHub. No Higgsfield or Aseprite use. These are concepts, not sprites/animations or exact gameplay-scale captures. Brown skin retained under lighting; creator identity/pose/architecture approval pending. No layered painting source exists.

Next: creator reviews full paintings; then author actual rear-turn and stair keys followed by the existing 30-frame pack. Retain PR #25 canvas320×724/pivot(160,600), current sprite registration and 0.65s/39-tick semantics. PR #27 at c2c002267c58e991966c0eebf7e098c6e7fff769 provides labeled render-adapter placeholders. No new sprite integration or merge authorized.
