# Art Mane requests and narrative evaluation

TR04 uses the existing `assets/web/terrain-materials.png` six-panel atlas inside actual collision rectangles, with visible top/side caps. It does not replace Kaze sheets, generate new artwork or claim a finished biome art pass. ART04 PR30 assets remain unchanged. Door/stair preview remains opt-in exactly as PR31.

## Environmental requests

| Priority | Room group | Requested delivery | Constraints |
|---|---|---|---|
| P1 | R13/R14 Canal left exits | Modular quay/roof wall returns and landing caps, 40px ledge thickness, 40-100px boundary extensions | Mechanical top stays y1200/y1100; draw to x0. No foreground obstruction of Kaze or E cue. |
| P1 | R2/R4/R9 right exits | Cistern masonry cap120px, bridge cap200px, Terrace cap140px | Top850/1080/810 respectively; water below R2/R4 stays visibly open. Terrace threshold art should register at shelf810 while existing interaction marker remains830. |
| P1 | R15-20 | Biome wall-return modules for80px left/50px right repairs; 40px tops | Match dry masonry/root-industrial/coil regions. Keep one-way nature legible; do not depict solid columns across upward routes. |
| P1 | R17 stair | Right-end wall return for visible stair crop endingx1800 | Contact anchor1680,1300; source crop and front lip remain identical. Current dark atlas strip is temporary. |
| P2 | R0-12 | Modular platform end caps, underside corbels, retaining masonry, foundations | Preserve existing collision outlines, intentional water gaps, combat telegraphs, grapple rope paths. |
| P2 | R13-20 | Region-specific background/foreground sets | Repeated district backdrop is still visible; roots/pipes/ruin silhouettes should support navigation without implying new solid surfaces. |

Transparent layers, pivot/placement JSON, pixel dimensions, intended scale, collision-free bounds and a zoom1 Godot screenshot are needed for each delivery. Coordinate against `evidence/geometry_after.json` and the existing 58 directed endpoints over 29 links.

## Missing Kaze animation delivery

ART04 contains four single held keys: quarter-back turn, inward entry, separate ascent and descent. Required next: grounded walking cycle, turn/entry in-betweens, outward/front-quarter exit, both arrival orientations, and complete ascent/descent contact cycles. Use the established320x724 canvas, pivot160,600 and scale0.303125 for new ART04 frames. Older approved sheet clips retain their own scales/pivots. Do not mirror a rear-facing entry to manufacture an outward exit.

The runtime keeps labels and approved-idle fallbacks. Native input tests validate E activation, feet support and cleanup; they do not certify completed anatomical animation.

## Ruins-escape evaluation — proposal only

The current topology could support an escape through occupied waterfront ruins: Haven/Market establish a refuge; Cistern/Sluice expose evacuation infrastructure; Shrine/Spire provide landmarks; machinery routes reconnect to the refuge. Existing inspection ledger, convoy letter and counterweight/service lore already provide useful environmental prompts.

This is an evaluation, not accepted canon. Story Agent and creator must decide the escape motivation, sequence, chronology, who maintains the lamps, and whether the Haven return expresses refuge or retreat. No story flags, dialogue, room names, boss milestones or progression requirements were changed. Preserve optional loops and exploration instead of enforcing a new linear escape route.
