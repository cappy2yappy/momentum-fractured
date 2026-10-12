# Approved Kaze sprites

These are the preserved original sheets. The creator authorized cleaned runtime replacements on October 12; active bindings now use `assets/kaze/cleaned`. See [integration notes](../../docs/SPRITE_INTEGRATION_2026-10-12.md). The manifest records both original and active hashes.

The creator confirmed these four sheets on 2026-10-12. They are the purple-outfit Kaze shown in the reviewed Alpha 0.5.2 build. Runtime bindings are in scripts/player.gd; the travel-kit portrait uses the idle sheet. Original image bytes are preserved.

Each is an eight-frame horizontal strip. No sheet resizing or re-slicing is part of this organization pass.

| Animation | File | Sheet size | Frame size |
| --- | --- | --- | --- |
| Idle | kaze_idle_strip.png | 3832 × 479 | 479 × 479 |
| Run | kaze_run_strip.png | 3280 × 410 | 410 × 410 |
| Combat | kaze_combat_strip.png | 3736 × 467 | 467 × 467 |
| Traversal | kaze_traversal_strip.png | 4008 × 501 | 501 × 501 |

## Idle

![Approved Kaze idle sheet](kaze_idle_strip.png)

## Run

![Approved Kaze run sheet](kaze_run_strip.png)

## Combat

![Approved Kaze combat sheet](kaze_combat_strip.png)

## Traversal

![Approved Kaze traversal sheet](kaze_traversal_strip.png)

Checksums, dimensions and runtime paths are recorded in [kaze_manifest.json](kaze_manifest.json). Run `python tools/verify_baseline.py` from the project root to verify them. Legacy red-scarf sprites on other branches must not be silently substituted for these assets.
