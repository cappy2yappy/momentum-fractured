# ART-01-0061 — Inspect-derived implementation specification

## Audited baseline retained

Work began from integration head `34be30436996284ec2f783269c40269d321ed427`, verified by fetch on October 14. The original audit is carried forward; targeted source reads and LD comparison review completed the art constraints without restarting gameplay development.

| Observed fact | Evidence / implication |
| --- | --- |
| Godot4.6.1, GL Compatibility | root project.godot; favor simple CanvasItem textures and opaque backdrops |
| Viewport1280×720, stretch mode viewport | Author composition tests at native view; display resize is not new world scale |
| Camera2D parented to player, position.y=-110, smoothing8 | No explicit camera.zoom override found: default (1,1). Gameplay scale target is current world pixel scale, not the LD contact-sheet thumbnail |
| Restored cleaned Kaze scale retained | idle0.264990881 / run0.382578054 / attack0.378751572 / traversal0.339192793; approximate average silhouettes97/97/95/78 world pixels |
| Room bounds | R14 2600×1440; R15 2200×1440; R17 1800×2160; R19 2400×1440 |
| Current backdrop | world._draw stretches DistrictBackground over room_size; layers are procedural drawn geometry; no existing Parallax2D stack found |
| Assets PNG; runtime Sprite2D plus procedural Rect2 platforms | No active tile grid/TileMapLayer geometry contract; supplied prototype chunks must be implemented independently of collision |
| HUD coverage | Health panel(20,20,350,108); kit(890,20,80,52); pause(982,20,92,52); minimap(1090,20,160,116); momentum near y130; contextual message near y148; lower control text/touch areas |

## Layer contract proposal — engineering review required

Ordered back to front: `BG00_sky` → `BG10_far_landscape` → `BG20_mid_architecture` → `BG30_local_backdrop` → `GP00_collision_visuals` → `GP10_actors_effects` → sparse `FG00_frame` → HUD. Proposed world z indices -100/-80/-60/-40/0/10/30; preserve existing CanvasLayer HUD above the world. Current parent _draw already paints an opaque image and platforms, so merely inserting a negative-z child would hide the new background. Integration must separate parent background drawing from geometry or provide a compatible render hook; **that runtime refactor is not performed by this assignment**.

Use Godot Parallax2D or a compatible camera-relative draw path after Integration approval. Scroll scales are per-biome proposals in the visual bible, interpreted as fraction of camera movement; validate Godot's actual scroll_scale semantics in the implementation. No parallax behavior is tested here. World collision visuals remain scroll1.00. No foreground layer may cross anchors, vent telegraphs, seals or landing pads; omit near-frame décor when it would occlude.

## Source/export policy

- Layered SVG prototypes are editable sources with named groups; produce final anime-painted source in a licensed layered authoring format during a later approved pass. No claim of Aseprite, ArtCraft or Photoshop use.
- Godot can import SVG as a raster texture; prototype SVG sources must be marked review-only and not referenced by runtime scripts. If later exported as PNG, preserve group opacity and alpha, sRGB8 RGBA, zero transparent RGB, no premultiplied fringe. Use opaque base sky/wall where appropriate.
- Proposed full backdrop master2560×1440 = 2× native viewport in each dimension, chosen for panning coverage; use repeat/chunking for wider/taller rooms, never one anisotropically stretched whole-room painting. Tiling masters have exact edge continuity; keep unique landmark chunks separate.
- Scenic scale1.0 by default at current zoom; do not resize Kaze or camera to fit the painting. Test at 1280×720; 640×360 previews are readability reductions, not target render resolution.
- Painted art uses linear filtering without forced pixel snapping; do not impose nearest filtering on the anime brush style. Prototype imported SVG generates pixels; proposed final backgrounds disable mipmaps initially at zoom1 and enable/test if camera zoom changes. Keep texture compression quality high around route silhouettes and translucent VFX; validate chosen desktop format empirically.

## Repeat / seam / assembly policy

City sky: no unique moon/landmark at repeat boundary. Use matching horizon and neutral edge columns; window clusters stop short of seams. Skyline is a 1280px repeating architecture motif in the authored prototype; the standalone mast is an optional landmark group and must not repeat every screen in final production. Culvert arches use a640px period; pipes meet equal y positions at both x boundaries. Near wall panels use straight matched mortar joints. Vertical shaft rail panels require matching rail centerlines at top/bottom; no completed shaft texture is claimed.

Prototype composite SVGs contain separate groups, plus separate layer SVGs for placement. They are composition blockouts, not seamless production-painted assets. All six layer exports and two composites now pass exact left/right raster-column checks (zero differing rows). Animated long-pan testing and final painted seam checks remain production gates.

## Readability policy

| Feature | Proposed visual rule | Preserve current semantics |
| --- | --- | --- |
| Traversable surface | 4px continuous light lip over dark support at zoom1; calm backing within20px | Background roofs have subdued broken/soft tops, not identical route lips |
| Grapple anchor | Clear circle/target silhouette with sparse backdrop within48world px | Keep green supported-anchor language; no new decorative green disks |
| Exit | Distinct housing + E cue and landing base | Retain LD48×65 inset /64×84 housing proposal; art doesn't change interaction radius |
| Kunai seal | Shape/symbol plus established wind/fire/electric hues | Décor cannot imply a fourth gate type or relabel colors |
| Vents / enemies | Keep animated warning and readable silhouette; scene saturation is lower than hazard cues | No painted steam in hazard lanes that hides actual4-second vent sequence |
| Pickups | Local negative space and distinct outline | Props cannot resemble sigil/pickup outlines |
| HUD | No key landmark behind opaque top panels; avoid detailed lower touch regions | Composition respects inspected rectangles and stable map visibility |

Use shape and motion with color. Proposed contrast checks: ordinary overlay text >=4.5:1, important route lip vs support >=3:1. Values measured for proposed palette pairs are stored in previews/contrast_checks.json; these don't prove pixel-level readability of a final painting. Screen-space rendered actor visibility and color-vision/grayscale checks are pending.

## Performance budget — proposal, not benchmark

60FPS remains a hard game target; no FPS compliance is claimed. Max3 full-canvas static layers per visible biome initially; prefer opaque base + two sparse transparent layers and <=16visible static chunks. One2560×1440 RGBA8 layer is14.06MiB uncompressed; three42.19MiB, plus about14.06MiB if all use a full mip chain (approx56.25MiB total). Compression/driver residency differs. Keep <=2 optional low-rate texture animations and <=32lightweight particles per view in a later prototype. No full-screen blur, bloom or fragment noise is required.

Production measurement gate: profile worst-case room R19 at native view with effects + UI; record frame-time median/p95, draw calls, video memory and test machine. Require p95<=16.67ms without changing simulation rate. Static image previews cannot measure this.

## Packaging / provenance

All new SVG/Markdown/JSON are original authored review material. Generated mood board, if available, is AI-generated concept art using references for direction, not a licensed stock texture. Neither is an approved production asset. Preserve source reference commit/hash links rather than copying third-party PNGs again. Asset manifest lists hashes, dimensions, formats, status and assembly role. PNG preview exports are renders of the original SVGs, not screenshots unless explicitly named composition-capture or baseline-capture.
