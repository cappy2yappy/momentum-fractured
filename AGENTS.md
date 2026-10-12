# Kaze development baseline

The creator subsequently authorized cleaned sprite integration on 2026-10-12. Active sheets are now `assets/kaze/cleaned/kaze_*.png`; preserve both these and the original `assets/web` sheets. See docs/SPRITE_INTEGRATION_2026-10-12.md for the visual-only controller changes. The manifest locks active/original artwork and unchanged physics separately.

The creator approved the Alpha 0.5.2 source and the four purple-outfit Kaze sheets in assets/web on 2026-10-12. Read docs/CANONICAL_BASELINE.md and docs/REPOSITORY_GUIDE.md before changing gameplay or importing work from another branch.

- The root project.godot is the active Godot 4.6.1 project.
- Preserve the approved sprites byte for byte unless the user requests an art change. assets/kaze/cleaned/kaze_*.png are the active character sheets; assets/web/kaze_*.png are preserved originals. Older assets/*.png and sprites on historical branches are not substitute character art.
- Preserve approved movement, tether momentum and original eight-room geometry. For combat changes, keep movement calculations intact and explain any intentional controller checksum change; update the preservation contract and tests together.
- Use a development branch. Preserve historical branches and commits; no force push or history rewrite. Merging into main requires an explicit user request.
- Run tools/verify_baseline.py for asset/preservation changes and the relevant Godot regression suites for gameplay changes. Use disposable user data for tests.
- Do not copy historical agents' task prompts or status claims into current instructions. Verify recovered features before integrating them.
- Keep generated engine caches, build outputs and personal saves out of Git. Label untested art or recovered systems as pending integration.
