# Exit audit (report only): door, trigger, collision and enclosure

Author: LEVEL pilot. Base: PR51 head baedd678. Only the Canal-left exit (R13 -> R0, edge a:0 b:13) was changed; everything else below is as found on that base. Source: `tests/audit_exit_alignment.gd` (real key input for the wall-jump probe; static geometry for the rest). Raw data: `docs/pm_pilot/exit_audit.json`. The audit ran on the post-change tree; for every row except R13 -> R0 the baseline run was identical (compared row by row).

## What was measured
- Door span supported: a collider whose top is within 2 px of the door feet covers the whole 96 px drawn door (feet x +-48).
- Support top vs door feet: collider top minus door feet y (0 is right; +20 means the door floats 20 px above its shelf, -20 means it is sunk 20 px).
- Trigger to wall: distance from the trigger line (the door centre for walk-through exits) to the wall contact line (14 px from the wall).
- Past-door dead space: floor between the far edge of the drawn door and the wall, where Kaze can stand beyond the door.
- Wall-jump probe: Kaze starts on the exit support touching the boundary wall, holds toward the wall and chains held wall jumps for 360 ticks (6 s). The trigger is not armed in this fixture, so it measures only the open column above. Min feet y below 0 means above the top of the room (the room is 1440 high and has no top).

## Walk-through (horizontal_walk) exits
| Exit | Feet (x,y) | Door span supported | Support top vs door feet | Support to wall | Trigger to wall (px) | Past-door dead space (px) | Wall-jump probe, min feet y | Left the room |
|---|---|---|---|---|---|---|---|---|
| R0 Canal Haven -> R1 | (2440,1300) | yes | +0 | yes | 146 | 98 | 141 | no |
| R1 R1 -> R0 | (120,1300) | yes | +0 | yes | 106 | 58 | 141 | no |
| R1 R1 -> R2 | (2440,1300) | yes | +0 | yes | 146 | 98 | 141 | no |
| R2 R2 -> R1 | (120,1300) | yes | +0 | yes | 106 | 58 | 141 | no |
| R2 R2 -> R3 | (2440,850) | yes | +0 | yes | 146 | 98 | -200 | YES |
| R3 R3 -> R2 | (120,850) | yes | +0 | yes | 106 | 58 | -200 | YES |
| R3 R3 -> R4 | (2440,1300) | yes | +0 | yes | 146 | 98 | 141 | no |
| R4 R4 -> R3 | (120,1300) | yes | +0 | yes | 106 | 58 | 141 | no |
| R4 R4 -> R5 | (2440,1080) | yes | +0 | yes | 146 | 98 | -78 | no |
| R5 R5 -> R4 | (120,1080) | yes | +0 | yes | 106 | 58 | -78 | no |
| R5 R5 -> R6 | (2440,1300) | yes | +0 | yes | 146 | 98 | 1030 | no |
| R6 R6 -> R5 | (120,1300) | yes | +0 | yes | 106 | 58 | 141 | no |
| R6 R6 -> R7 | (2440,1090) | NO | +20 | yes | 146 | 98 | 162 | no |
| R7 R7 -> R6 | (120,1090) | yes | +0 | yes | 106 | 58 | 125 | no |
| R7 R7 -> R8 | (2440,1300) | yes | +0 | yes | 146 | 98 | 141 | no |
| R8 R8 -> R7 | (120,1090) | yes | +0 | yes | 106 | 58 | -68 | no |
| R8 R8 -> R9 | (2440,830) | yes | +0 | yes | 146 | 98 | -232 | YES |
| R9 R9 -> R8 | (120,830) | yes | +0 | yes | 106 | 58 | -232 | YES |
| R9 R9 -> R10 | (2440,830) | NO | -20 | yes | 146 | 98 | -232 | YES |
| R10 R10 -> R9 | (120,830) | yes | +0 | yes | 106 | 58 | -232 | YES |
| R10 R10 -> R11 | (2440,760) | yes | +0 | yes | 146 | 98 | -232 | YES |
| R11 R11 -> R10 | (120,760) | yes | +0 | yes | 106 | 58 | -232 | YES |
| R11 R11 -> R12 | (2440,1300) | yes | +0 | yes | 146 | 98 | 860 | no |
| R12 R12 -> R11 | (120,1300) | yes | +0 | yes | 106 | 58 | 930 | no |
| R13 Mooring Loft -> R0 | (120,1200) | yes | +0 | yes | 106 | 58 | 1198 | no |
| R13 Mooring Loft -> R14 | (1680,560) | yes | +0 | yes | 106 | 58 | -232 | YES |
| R14 Bellroof Walk -> R13 | (120,1100) | yes | +0 | yes | 106 | 58 | -58 | no |
| R14 Bellroof Walk -> R9 | (2440,830) | yes | +0 | yes | 146 | 98 | -232 | YES |
| R15 Lower Sluice -> R2 | (120,500) | yes | +0 | yes | 106 | 58 | -232 | YES |
| R15 Lower Sluice -> R16 | (2080,1120) | yes | +0 | yes | 106 | 58 | -38 | no |
| R16 Root Shrine -> R15 | (120,1120) | yes | +0 | yes | 106 | 58 | -38 | no |
| R16 Root Shrine -> R8 | (1880,760) | yes | +0 | yes | 106 | 58 | -232 | YES |
| R17 Counterweight Spire -> R5 | (120,1900) | yes | +0 | yes | 106 | 58 | 741 | no |
| R18 Pump Gallery -> R16 | (120,1000) | yes | +0 | yes | 106 | 58 | -158 | no |
| R18 Pump Gallery -> R19 | (2440,760) | yes | +0 | yes | 146 | 98 | -232 | YES |
| R19 Coil Service Hall -> R18 | (120,760) | yes | +0 | yes | 106 | 58 | -232 | YES |
| R19 Coil Service Hall -> R11 | (2280,980) | yes | +0 | yes | 106 | 58 | -178 | no |
| R20 Relay Junction -> R17 | (120,760) | yes | +0 | yes | 106 | 58 | -232 | YES |
| R20 Relay Junction -> R19 | (2080,1120) | yes | +0 | yes | 106 | 58 | -38 | no |

## Interact (depth door, wind fold, stair) exits
| Exit | Mode | Feet (x,y) | Door span supported | Support top vs door feet |
|---|---|---|---|---|
| R0 -> R13 | depth_door | (590,780) | yes | +0 |
| R2 -> R15 | depth_door | (470,1120) | yes | +0 |
| R3 -> R9 | depth_door | (2250,790) | yes | +0 |
| R5 -> R17 | depth_door | (2240,930) | yes | +0 |
| R8 -> R16 | depth_door | (550,1110) | yes | +0 |
| R8 -> R18 | depth_door | (1090,920) | NO | +0 |
| R8 -> R12 | depth_door | (1470,740) | yes | +0 |
| R9 -> R14 | depth_door | (1100,1040) | yes | +0 |
| R9 -> R3 | depth_door | (160,620) | yes | +0 |
| R11 -> R19 | depth_door | (890,980) | yes | +0 |
| R12 -> R8 | depth_door | (220,830) | yes | +0 |
| R13 -> R20 | wind_fold | (900,400) | yes | +0 |
| R14 -> R17 | stair_up | (1450,480) | yes | +0 |
| R16 -> R18 | depth_door | (1000,430) | yes | +0 |
| R17 -> R14 | stair_down | (1680,1300) | yes | +0 |
| R17 -> R20 | depth_door | (1500,420) | yes | +0 |
| R18 -> R8 | depth_door | (1200,1180) | yes | +0 |
| R19 -> R20 | depth_door | (1800,480) | yes | +0 |
| R20 -> R13 | wind_fold | (600,520) | yes | +0 |

## Findings
1. **Systematic door/trigger mismatch at every wall-side walk-through exit.** The door is drawn 96 px wide centred on the trigger line, but the wall is 106 px (left) or 146 px (right) past the trigger, so 58 px (left) or 98 px (right) of floor continues past the drawn door. Kaze can stand in that strip with the door behind them, which is the stop-against-the-wall case TR-06 patched with a "supported recovery". Pre-existing by design; fixed only for R13 -> R0 (a back pier now ends the floor at the aperture's left edge, x 72).
2. **Open wall-jump column above the wall-side walk-through exits.** Of 39 wall-side walk-through rows, 24 reached a feet y below 0 (above the top of the room) and 15 left the world entirely (x outside the room) by chained held wall jumps in 6 s. The remaining rows climbed 100 to 1000 px; none has a lintel, ceiling or enclosure. The R13 -> R0 row below is a fixture artefact: the probe stands at x 14.6, which is now inside the back pier, so its numbers are meaningless; the real containment measurements for that exit are in `tests/canal_geometry.gd` (wall jumps inside the hallway never get above feet y 1080, the lintel head-bump limit; baseline same attempt reached y -137 and x -639). The other exits are NOT fixed; they follow the same recipe (a back pier plus a gatehouse mass whose underside is the ceiling) if the creator wants them done.
3. **Room boundary has no top.** (Traced for R13: a bot that chains wall jumps up the new gatehouse face tops out at y -137 about 5 s later, walks off the roof and out of the world at x<0, and the existing fall recovery then returns Kaze to (230,1198), inside the hallway. Same mechanism ends every such escape in the baseline, so there is no soft lock, but it is an unintended space.) `world.gd:build_room` adds only a left wall, a right wall and a floor. Any boundary wall adjacent to any standable ledge can be wall-jumped to y<0, so a whole-room top bound (or a limit on wall-jump height) is a separate, game-wide decision. It is not made here because it would either be a blanket ceiling or a movement change, both ruled out.
4. **Door floating or sunk against its support.** R6 -> R7 (+20: door feet 20 px above the shelf top at (2440,1090)) and R9 -> R10 (-20: door feet 20 px below the shelf top at (2440,830)). The code already special-cases the R9 landing (`LevelGeometry.legacy_arrival`, `arrival_position`), and TR-05 notes the R9 art feet being 20 px low. Cosmetic/legacy; not touched.
5. **R8 -> R18 (1090,920) depth door**: the shelf under it ends at x 1110 while the drawn door spans x 1042..1138, so the right 28 px of the door overhangs empty space. Interact exit (E within 85 px), no walk-through issue. Not touched; R18 belongs to the LD-04 lane.
6. **Corridor height versus door height.** The auto-trigger corridor is feet y at.y-90 .. at.y+8 and the drawn door is 132 tall (Kaze head 60), so a jump that crosses the door line with feet above at.y-90 passes over without triggering. That matches a 132 px door plus the body well enough that it is not logged as a defect; it is relevant to Art because a taller door would need the corridor widened by Transition.
7. **R13 right exit (R13 -> R14 at (1680,560)) has the same open column** as every other wall-side exit; it was out of scope for this task.

## Not claimed
No human playtest, no Windows run, no exhaustive jump-arc proof. The probe is one bot per exit.
