# ART-06 quality control notes

## Consistency with approved art (PR28 / PR30)
- Materials: grey ashlar with moss joints, dark lacquered timber with iron straps, clay tile roofs, warm paper lanterns against indigo night. All modular prompts used PR30 ENVIRONMENT_LAYERS as the image reference; concepts also used PR28 staircase/crossing.
- Scale: piers 96 px, caps 48 px, pumps 420 px wide read correctly next to Kaze at zoom 1.0 (see native after captures). Kaze sprites, scales and pivots unchanged.
- Palette: supports tinted 0.85, back wall 0.78 / 0.86 blue so the bright capstone line remains the strongest horizontal in every frame. Lanterns are warm orange, clearly distinct from green tether anchors.

## Story framing
- Pump distribution between canal and conservatory (ST-03 R18 row): pumps, routing plate with a two-way branch diagram beside a newer repair patch, roots through housings.
- Post-attack: collapsed roofs, scorch, emergency shoring, abandoned toolbox (concepts). No clan crests, shrines, dojo forms or refuge iconography; nothing implies this is the original protected refuge. No named survivor or Mizuki hint.

## Boundaries verified
- Collider/art agreement, keep-clear and foreground spacing: validator 432 checks, 0 failures.
- Native integrated render: 9 checks, 0 failures; physics byte-identical.
- Approved baseline verifier and TR05/PR37 preservation verifier: 0 failures.

## Known issues and limits (honest list)
1. **Geometry is interim.** Dressing fits today's R18 including the 10 generated slabs #43 will replace. Treat the room layout as a pilot, not an approved room.
2. Overlapping or stacked slabs (G5/S2, G8/S3, G9/S3, G10/S4) draw doubled cap edges. Geometry fix, not art.
3. Ledge cap and floor tiles are made seamless by cross-fade; the floor grate repeats every 512 px and reads as regular. A second floor variant would break the rhythm.
4. Pier shafts repeat a middle section; the tallest (S4, 640 px) is the most likely to show it. An authored tall pier variant is recommended.
5. Back wall repeats once at x2178 with pilaster against pilaster; review that seam at gameplay scale in the east_gate frame.
6. Concept paintings are AI-generated (GPT Image 2.5 via Higgsfield) from approved references; they are direction, not production paint. Concept 01's platform layout is approximate, not registered.
7. Modular assets are generated with native alpha and processed deterministically (`process_assets.py`). No hand repaint pass yet; edge halos are minimal but a paint cleanup in the ORA is advised before final.
8. Not verified: exported Windows/macOS build (JSON include filter), Apple/Windows GPU render, performance (dozens of added texture draws, not profiled), gamepad/real-input route playthrough, reduced-motion (no animated elements are added, steam is static).
9. Creator review of style fidelity pending.
