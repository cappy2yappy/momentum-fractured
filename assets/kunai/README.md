# Elemental kunai asset manifest

Original artwork supplied by the project owner. These PNGs are preserved byte for byte, including their alpha channels; no resizing, recompression, or color edits were applied.

| File | Dimensions | Layout | Animation |
| --- | --- | --- | --- |
| `kunai_wind_strip.png` | 2048 × 288 | 4 columns × 1 row | Wind, frames 0–3 from left to right |
| `kunai_fire_strip.png` | 2048 × 288 | 4 columns × 1 row | Fire, frames 0–3 from left to right |
| `kunai_electric_strip.png` | 2048 × 288 | 4 columns × 1 row | Electric, frames 0–3 from left to right |
| `kunai_all_source.png` | 1983 × 793 | Combined reference sheet | Wind top row, fire middle row, electric bottom row; four poses per row |

## Animation regions

Each individual strip has four nominal 512 × 288 frame cells:

| Frame | Region `(x, y, width, height)` |
| --- | --- |
| 0 | `(0, 0, 512, 288)` |
| 1 | `(512, 0, 512, 288)` |
| 2 | `(1024, 0, 512, 288)` |
| 3 | `(1536, 0, 512, 288)` |

The kunai point right. In Godot, the strips can be sliced with `hframes = 4`, `vframes = 1`, or equivalent AtlasTexture regions. Playback rate, loop behavior, scale, and pivot remain integration decisions; no timing was supplied. Inspect cell edges and alignment before gameplay integration: effects can approach frame boundaries. The combined source sheet is a reference, not a uniform runtime atlas.

## Source integrity (SHA-256)

- `kunai_all_source.png`: `74466e77f9057d4ef0ef6e16c63211bddf0add20bae3e34d67a607160019e78f`
- `kunai_electric_strip.png`: `6e993667fd49c85b3cbbe66b2885e2bb255539c80df2bc5a9de925d15afad783`
- `kunai_fire_strip.png`: `d52e0f60e10a09d41dae3efe1a7d46b1da43b592bb6add95859f00cde83c4c26`
- `kunai_wind_strip.png`: `a6164691c12ec1376d99c1575a1932c9456bd23870a58e0ac160227addcc55e5`

## Scope and validation

This asset pass adds artwork and this manifest only. Gameplay integration is pending. No gameplay scripts, scenes, collisions, or import settings are changed. Destination SHA-256 hashes were checked against the supplied originals; all four files are 32-bit RGBA PNGs. Godot import/boot validation was not run because a Godot executable was unavailable in this environment.
