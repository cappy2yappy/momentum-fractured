# Installed MetDevSys evaluation

Evaluated the creator's installed files **read-only**, 2026-10-16 (America/New_York). Godot AI editor/session inspection confirmed Godot 4.6.1 and plugin bridge 3.2.1 on the active OneDrive checkout. No runtime MCP bridge was used. Installed plugin.cfg files report Metroidvania Developer System **3.2.0** and MetSys **1.7-dev**. No installed files were changed or plugins updated.

## Finding

**MetDevSys can coexist with MetSys and has appropriate authoring primitives; it is not a direct editor for Kaze's generated geometry.** Its MetSys mode does not inherently require replacing the map. It could become an optional painter after a separate geometry-to-scene conversion and validated integration adapter. We are not rejecting it as incompatible with MetSys.

For this bounded pilot, ordinary saved Godot nodes give the requested mouse editing with less integration surface. No MDS runtime, world graph, gate system, map converter, save model or game scene is introduced.

| Need | Installed source evidence | Conclusion |
| --- | --- | --- |
| Keep MetSys map | `plugin.gd:4,237-246`; `core/map_model.gd`; `core/graph.gd:58` | MetSys-aware mode exists. Using the plugin does not necessarily replace MetSys. Compatibility with this particular 1.7-dev setup was not independently exercised. |
| Paint persistent room nodes | `core/room_painter.gd:4-17,55-113,615` | Opens a PackedScene outside the tree, copies saved TileMapLayers/MDSFreeform/stamps/effects, writes them back. |
| Solid / one-way / decorative polygons | `nodes/mds_freeform.gd:1-85,415-421` | Freeform supports solid toggle, collision overrides, layer/mask, one-way and margin; creates a native StaticBody2D/CollisionPolygon2D. |
| Scenery layers | `core/room_painter.gd:19-26` | Separate Background/Terrain/Decor/Foreground layers and freeform/stamp groups exist. |
| Existing runtime R18 | Kaze `scripts/world_expansion.gd:68-87`, `scripts/world.gd:142-173,419-430` | Shelves and interpolation steps are generated at runtime; the painter's saved-scene scan does not expose these as mouse-editable room nodes. |
| Preserve graph / saves / progression | Installed README's New world/Create game scene workflow and `core/world.gd:1108` | Do not run world conversion, create MDSWorldGame, auto-generate gates or replace Kaze's world loader for this pilot. Those are outside scope. |

A plugin-wide room conversion would not solve adoption safely by itself: Kaze also uses `world.platforms` for drawing/queries and `add_platform()` for perimeter repairs and automatic one-way policy. A naïve second scene would duplicate collision or leave stale arrays. The native prototype makes that boundary explicit in MIGRATION.md.

## Evidence pins

SHA-256 of installed source files (not upstream latest; paths relative to `addons/MetroidvaniaDeveloperSystem`):

| File | SHA-256 |
| --- | --- |
| `plugin.cfg` | `97b6b54b6a7893d4bc7afb795cc094ac156d7ce73f7efc5a3c130d5ab26739e7` |
| `core/room_painter.gd` | `ce54a4eaa788cb73295b7a0bb021f83531cf9c35a55e33f46c30a00f2be5f81a` |
| `nodes/mds_freeform.gd` | `47b1ff17cbc2720edae64c88d6b90215482f3d9b5750a5a53ffe82790367c380` |

The installed README describes Godot >=4.6 and MetSys 1.6 for MetSys mode. This is a documented requirement, not proof of 1.7-dev integration. Evidence here is source inspection, not a MetDevSys UI workflow/playtest. Its files were not copied into the deliverable or enabled in the pilot.
