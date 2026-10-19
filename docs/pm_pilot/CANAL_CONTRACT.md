# CANAL OPENING / THRESHOLD CONTRACT (Room 13 MOORING LOFT, left exit to Room 0 CANAL HAVEN)

Status: v1, published by LEVEL (branch feature/pm-pilot-canal-geometry). Base: PR51 head baedd678.
If LEVEL changes any number below, BOTH copies (this file and docs/pm_pilot/CANAL_CONTRACT.md in the LEVEL branch) are updated and the change is announced loudly in LEVEL's final reply.
All coordinates are room pixels in Room 13 (size 1800x1440), y grows downward, feet-anchored. No em dashes anywhere.

## 1. Measured player (scripts/player.gd, do not change)
- Collision: CapsuleShape2D radius 14, height 60 (total), shape centre at (0,-30) from feet. So Kaze is 28 px wide x 60 px tall, feet at node origin, head top at y_feet-60.
- Gravity 1800; jump v=-900 -> apex 225 px (held), variable jump cut at -360; double jump (needs Windstep) another 225; wall jump velocity (+-480,-880) -> about 215 px; dash 920 px/s for 0.18 s = about 166 px; walk 400, sprint 600 (double tap), Stride I x1.05.
- Sprite is a visual only, scale idle 0.265, run 0.383, attack 0.379, traversal 0.339 of the source strips, feet baseline aligned to node origin. Art must be authored against the 28x60 collision, not the sprite padding.

## 2. Exit endpoint (graph data, UNCHANGED)
- EDGE {a:0,b:13, pa (590,780) in R0, pb (120,1200) in R13, need windstep} in scripts/world_expansion.gd. Do not move pb.
- R13 endpoint mode: horizontal_walk, heading -1 (exit by walking LEFT), automatic trigger (scripts/cinematic_transitions.gd).

## 3. Door / opening (the aperture Kaze walks into)
- Door centre x = 120.
- Clear width = 96 -> aperture x 72..168.
- Clear height = 132 -> aperture y 1068..1200 (2.2x Kaze height, 3.4x Kaze width).
- Floor / support: pad top y = 1200 (one-way landing, x 0..360, 40 thick, from LevelGeometry.LANDINGS; unchanged). Kaze feet stand at y = 1200 (arrival uses 1198).
- Target art rectangle for the door (replaces draw_exit's 96x132 dark rect): **x 72, y 1068, w 96, h 132** (the aperture). Door frame (jambs + head) art: **x 40, y 1032, w 160, h 168**, bottom-centre anchor (120,1200). Optional door leaf: same 96x132 aperture rect, drawn open/ajar so the opening stays readable.

## 4. Threshold / trigger (owned by cinematic_transitions.gd, UNCHANGED by LEVEL)
- Trigger x = 120 (the door centre). Fires when Kaze's feet-x crosses from x>120 to x<=120 moving left with intent, in the corridor y 1110..1208 (at.y-90 .. at.y+8), armed after having been at x>=136 (at.x+16).
- Band: x 120 exactly is the line; a "recovery" also fires for x<=120 if Kaze is supported on the pad and holds left. Kaze body at trigger spans x 106..134, fully inside the aperture 72..168.
- Corridor y range: 1110..1208 (feet). Kaze on the pad (1200) and on shelf (200,1160) (feet 1160) are both in range.
- Arrival in R13 from R0: Kaze feet at (184, 1198), facing +1 (right), velocity carried. 64 px inward of the door centre, inside the hallway, under the lintel. (computed by arrival_position(): at.x - heading*64.)
- Leftmost reachable feet-x after the build is 86 (back pier face x=72 + capsule radius 14); the old stop-at-the-wall at x=14 no longer exists.

## 5. Enclosure (cave mouth / hallway) - solid, visible geometry added by LEVEL
- Back pier: Rect (0,1020,72,180) -> x 0..72, y 1020..1200. Rear end of the hallway; the door aperture is set in the rear plane just right of it.
- Gatehouse mass (lintel and quay wall above): Rect (0,0,296,1020) -> x 0..296, y 0..1020. Its underside is the CEILING at y = 1020.
- Hallway interior: x 72..296 (224 wide), floor y 1200 (pad; shelf (200,1160) sits inside it), ceiling y 1020, clear height 180 above the pad = 3.0x Kaze (140 above the first shelf).
- Mouth: open to the right at x = 296. Nothing is added to the right of x=296. The pad continues to x 360 (existing).
- The mass stops at x=296 so the shelf at (300,440) and every other listed R13 shelf and the grapple anchor (900,690) are untouched.
- Collision is the same visible rectangles. No invisible barriers. Mass rects are not 40 px thick so they are solid (not one-way).

## 6. Art layers the Art Mane must deliver (px, room coordinates)
All are noninteractive silhouettes. Z order from back to front:
1. L0 hall back wall (rear plane, behind everything): x 72, y 1020, w 224, h 180. Tileable horizontally, quay masonry, dark.
2. L1 door frame + aperture + optional door leaf: frame x 40, y 1032, w 160, h 168; aperture x 72, y 1068, w 96, h 132; leaf same as aperture. Behind Kaze.
3. L2 gatehouse mass face: x 0, y 0, w 296, h 1020 (only the lower 360 px, y 660..1020, is normally on screen near the exit; upper part may be a tiling stone fill). Lintel course band: x 72, y 960, w 224, h 60 (its bottom edge at y 1020 is the physical ceiling). Behind Kaze (it is solid, Kaze never overlaps it).
4. L3 back pier face: x 0, y 1020, w 72, h 180. Behind Kaze.
5. Kaze (z 0, world child).
6. L4 foreground lip (optional, in front of Kaze): x 284, y 1004, w 40, h 40 corbel at the mouth. It sits above Kaze's head except when she bumps the ceiling at the mouth, and must NOT cover the aperture or the walking envelope (y 1020..1200 for x < 284).
7. Transition overlays (cinematic z 3, embodied z 4) stay above everything.
- Current procedural stand-in lives in scripts/canal_gatehouse.gd (LEVEL): it tiles the approved blue masonry tile (assets/web/terrain-materials.png region 512,0) inside the collider rectangles, drawn in world._draw before the platform surfaces and before the door. Art replaces it by swapping those draw calls for the textures above; do not add colliders from art. The legacy R13 silhouette at x=140 is suppressed where it overlaps the mass.
- Known residual (not a contract item): the exterior right face of the gatehouse mass at x=296 is an ordinary wall and Kaze can chain wall jumps up it, as on every room boundary in the game (rooms have no top). See docs/pm_pilot/EXIT_AUDIT.md finding 3.

## 7. What the Transition agent may and may not change in scripts/cinematic_transitions.gd
MAY: presentation only. draw_exit() art (replace the 96x132 rect with the art above, same anchor at=(120,1200)), label text, the begin()/present()/arrived() staging and camera effects, timings, reduced-motion/plain variants.
MAY NOT: endpoints() data (at, target, arrival, mode, heading), the crossing/armed/corridor/recovery logic in update(), supported_exit(), arrival_position() offsets (64 px inward, y-2), the cooldown semantics, passage_allowed(), or anything that moves the trigger off x=120 / corridor y 1110..1208. If the staged sequence needs Kaze moved during the ~2-3 s presentation, do it with presentation proxies, not by changing player position rules or the trigger. Any need to change the threshold must be requested from LEVEL, who will update this contract.
LEVEL does not edit cinematic_transitions.gd at all.
