# Selected candidates

All choices are proposed for creator review. Frame order comes directly from the audited ASSET-01 inventory. Source animation rates are unknown; **12 FPS is a review assumption**, not recovered source timing.

| ID | Exact selection | Content size (px) | Frames | Proposed treatment |
| --- | --- | --- | --- | --- |
| moss_surface | Mossy FloatingPlatforms, component 5 | 139 × 40 | 1 | Surface inlay tiled inside existing rectangles; 2px top rim at collider Y; original exit thresholds retained |
| hanging | Mossy Hanging Plants, component 0 | 29 × 104 | 1 | Recessed framing; never foreground occlusion |
| column | Mossy BackgroundDecoration, component 1 | 212 × 480 | 1 | Low-contrast background architecture with exclusion checks |
| grass | Vegetation/Grass2 | 43 × 38 | 30 | Sparse rear foliage, muted green |
| flower | Plant Animations/BlueFlower1 | 55 × 58 | 60 | Sparse cyan accent matching Kaze's cool scene palette |
| poison | Plant Animations/Plant 8 Poison | 88 × 66 | 30 | Inside the 96 × 100 steam sensor; original phase outline/hatching/text above art |
| slime_green | SlimeGreen | 84 × 56 | 30 | Preferred body-motion prototype |
| slime_orange | SlimeOrange | 84 × 53 | 30 | Alternate warmth/contrast comparison |
| cave_surface | Cave Platforms, component 8 | 225 × 40 | 1 | Repeated/clipped inside real surface faces |
| cave_rocks | Cave BigRocks1, component 1 | 253 × 166 | 1 | Recessed scenery, excluded from hazard and access zones |

Every frame adds a 2px transparent gutter on all sides. Content dimensions above exclude it. `tools/art11/selections.json` resolves inventory IDs/regions; [derivative-lineage.json](derivative-lineage.json) records every selected source/derivative hash, exact alpha-union crop, fixed pivot, dimensions, frame order and recipe. Pivot is bottom-center of the fixed content canvas, shared across the full sequence. No frames were discarded; 185 textures cover the ten selections.

The preparation recipe decodes original PNGs, crops one fixed union of alpha bounds for each sequence (or the audited atlas component), fixes transparent RGB edges, downsamples with Lanczos, and pads with transparent pixels. Godot loads each frame once into a shared ImageTexture cache. Linear filtering is the selected default; the native gallery also produces a nearest-filter comparison. Runtime tint is separate from the source bytes.

R16 surface tint: `#b2c2b7`; R15: `#abb7c1`. Foliage: `#9dbba7`. Recessed architecture: RGBA `(0.36,0.48,0.44,0.28)`. Existing Kaze artwork is unchanged, at the active controller's frame scale/pivot in the gallery and actual Player rendering in room captures.

The surface module repetition is visible in long runs and needs Art Mane's paintover/seam judgment. The cave modules fit existing platforms, but do not constitute a finished underground biome. The source slimes have ambient body loops, not windup/strike/hurt/death sets; existing guard cues remain authoritative. The poison plant is a presentation study on the existing steam cycle, not a new hazard implementation. BlueWizard remains optional/reference-only.
