# LD-08 exact collision contract

Coordinates are room-local pixels; y increases downward. Player capsule is unchanged: radius 14, height 60, feet at player position. Both target rooms are 1,800 px wide.

| Room | Operation | Rectangle `(x, y, width, height)` | Physical purpose |
| --- | --- | --- | --- |
| R13 | Remove roof in candidate mode | `(-40, -640, 1880, 696)` | Removes the continuous y=56 underside |
| R13 | Add west upper stem | `(-40, -240, 336, 240)` | Continues the existing gatehouse face at x=296 |
| R13 | Add west projecting upper story | `(-40, -800, 720, 560)` | Visible masonry soffit at y=-240; ends at x=680 |
| R13 | Add east upper stem | `(1800, -240, 40, 240)` | Continues the existing east wall |
| R13 | Add east projecting upper story | `(1416, -800, 424, 560)` | Visible masonry soffit at y=-240 |
| R17 | Remove roof in candidate mode | `(-40, -640, 1880, 696)` | Removes the continuous y=56 underside |
| R17 | Add west upper stem | `(-40, -240, 40, 240)` | Continues the existing west wall |
| R17 | Add west hoist casing | `(-40, -800, 424, 560)` | Visible metal soffit at y=-240; ends at x=384 |
| R17 | Add east upper stem | `(1800, -240, 40, 240)` | Continues the existing east wall |
| R17 | Add east hoist casing | `(1416, -800, 424, 560)` | Visible metal soffit at y=-240 |

All added shapes are ordinary StaticBody2D / RectangleShape2D solids on the existing environment layer. None are one-way, hazards, teleporters, invisible walls, movement clamps or input filters. The rectangles passed to collision creation are also passed to the solid renderer. Existing side-wall colliders receive matching visual skins in the two rooms so the upper structures visibly continue down to the floor; those side-wall colliders are not changed.

The central openings are x=680..1416 in R13 and x=384..1416 in R17. There is no central roof collider at any height. All new collision ends at or above y=0, leaving the existing positive-y platform list untouched. The camera's top limit becomes -800 in these rooms and returns to 0 on loading any other room or either reference mode.

Preserved: the R13 Canal mass `(0,0,296,1020)`, pier `(0,1020,72,180)`, aperture `(72,1068,96,132)`, endpoint `(120,1200)`, floor, plinth and hallway; all R13/R17 shelves and anchors; the R17 wind shutter; every portal and prerequisite; Bellroof; ground repairs; controller, saves and progression. `world.gd` only gains a scoped background draw call. No save/respawn hook ships.

`--ld08-before` removes only the target roofs and adds no new structure. `--ld08-roof-reference` restores the prior roof rectangles and rendering, with no new structures or camera changes. `OpenTop.ENABLED=false` is the programmatic disable switch used by the geometry contract test.
