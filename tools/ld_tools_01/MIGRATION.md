# Format 1 and reversible adoption path

## Saved representation

The source of truth is a normal PackedScene (`.tscn`) with Node2D root metadata `format_version=1`, `room_id=18`, and the pinned baseline SHA. Coordinates are room-local Godot pixels, +X right, +Y down; R18 bounds are 2600x1440. Baseline walls extend 40px outside the sides.

`Geometry/*` are native StaticBody2D nodes, layer=1 and mask=1. Each `Surface` child is CollisionShape2D with its own RectangleShape2D. Position is the rectangle center; Shape.size is full width/height. Native `disabled`, `one_way_collision`, and `one_way_collision_margin` persist in the scene. Body and surface ancestors must be identity scale/rotation/skew for the current rectangle adapter. Translation is supported. Native resource handles and Inspector values both edit the collider directly.

`rectangle_surface.gd` draws the exact local rectangle `Rect2(-shape.size/2,shape.size)` on the same node/transform as physics. There is no manually synchronized second art rectangle. One-way gold/solid teal/disabled translucent is an authoring convention. The top highlight and thin outline are debug decoration, not additional collision. The slope script draws the same polygon used by native CollisionPolygon2D; self-intersecting polygons are invalid. Disabled geometry is explicitly translucent. Foreground/background props are ordinary Polygon2D/Sprite2D nodes with no collision. Marker2D ladders have no executable traversal semantics.

`r18_frozen.json` records exact final builder rectangles after LevelGeometry.perimeter_landing, not just the five SHELVES entries. It contains **18** native geometry bodies: 2 walls + 1 floor + 15 one-way ledges (5 authored shelves + 10 interpolation slabs). Existing side ledges span to the perimeter. It intentionally excludes the conditional electric gate, enemies, hazards, anchors, exits, lore and progression. They remain game-owned. The isolated scene cannot establish route or encounter parity for these omitted systems.

`layout_records.gd.read(layout)` is an executable read-only adapter returning `{records, errors}`. Each record has `rect:Rect2`, `disabled:bool`, `one_way:bool`, `margin:float`, `layer:int`, `mask:int`. Reject a nonempty errors array. Filter disabled records before populating gameplay solid queries. Enabled slopes are rejected because Kaze's existing rectangle consumers cannot safely represent them as axis-aligned bounds. The adapter does not instantiate into a game, mutate a world, or approve a migration.

## Later migration — explicit approval required

1. Preserve the pinned generator and its freeze. Initially adopt the **unchanged** `r18_layout.tscn` geometry only, not the mouse-edited example. Confirm every rectangle and physics flag matches at the chosen adoption base; do not silently regenerate the reference if the base drifts.
2. Add one R18-only, default-off opt-in at the world geometry construction boundary in a later branch. Split geometry creation from non-geometry setup so the existing gate/enemy/anchor/hazard/lore logic still runs once. Skip the original R18 perimeter/floor/platform generator when opt-in is on. Do not build both and try to remove arbitrary StaticBodies afterward; that risks deleting the electric gate.
3. Instantiate the authored PackedScene under the room's geometry owner. Keep its native bodies as the collision source. Do **not** feed its rectangles through `world.add_platform()` again: that would duplicate native colliders and reapply one-way/perimeter rules, overriding an author's solid choice.
4. Populate legacy `world.platforms` and any support-query structures from validated enabled records, in deterministic tree order. Ensure game drawing uses the authored visual surfaces once; avoid rendering a second generated slab over them. Audit every Rect2-based consumer before supporting new shape types. Keep disabled/scenery records out of solid support queries.
5. Keep room IDs, all 29 links, portal feet coordinates, gates/prerequisites, checkpoint/save schema and abilities untouched. Room transitions/cleanup own and free the scene normally. No new ladder edge or climbing controller. Require separate design/controller approval for enabled slopes.
6. Run baseline, collision hashes, save/load, transition/arrival and real-input route/recovery QA for R18, plus all-room preservation. Review capsule clearance, intentional drops, tether arcs, gate reachability, return routes and props hiding hazards. Creator signs off before enabling adoption or changing the frozen geometry.

**Rollback:** switch the opt-in off to use the original generator; remove the opt-in adapter/scene registration in a later revert. No save conversion or map rewrite is needed because none was authorized. Keep the authoring scenes as disconnected tools if useful. Current pilot removal is simply removal of this new tools directory; no existing source imports it.

This pilot addresses the authoring workflow part of issue43. It does not close the issue's authored-space redesign, gameplay-scale before/after player captures, annotated purpose map, story/encounter design or human route acceptance.
