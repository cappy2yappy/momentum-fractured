# Room layout contract

The source of truth is a Godot 4.6.1 **PackedScene**, normally a text `.tscn`. `layout_contract.gd.read(Node2D)` returns `records`, `errors`, `room_id`, `room_size` and `version`; callers must reject any nonempty `errors`. The runtime pilot validates before attaching native physics or suppressing any generated geometry. Missing/unsupported layouts report an error and fall back to the original generator.

| Field | Format 1 compatibility | Format 2 |
|---|---|---|
| Root | Node2D, identity transform | Node2D, identity transform; optional `room_layout.gd` overlays |
| `metadata/format_version` | integer 1 | integer 2 |
| `metadata/room_id` | integer 18 | nonnegative integer, stable across edits |
| `metadata/room_size` | implicit Vector2(2600,1440) | required positive finite Vector2 |
| Baseline | frozen PR39 SHA retained | provenance metadata may be retained |
| `Geometry/*` | native StaticBody2D rectangles | same reusable contract |
| Background / Foreground | frozen placeholders suppressed in live pilot | non-solid Node2D / Polygon2D / Sprite2D scenery |
| Markers | legacy ladder proposal, hidden in game | Marker2D + optional room_marker.gd; hidden in game |

Coordinates are **room-local Godot pixels**, +X right and +Y down. A CollisionShape2D's position is its rectangle center; RectangleShape2D.size is the full size. Ancestor translations are supported. Rotation, scale, mirroring and skew are rejected. Positions, dimensions and margins must be finite; sizes must be positive and one-way margins nonnegative. Room boundaries guide authoring, not an implicit clamp; the original west/east walls extend 40px outside the bounds.

Bodies use **layer 1 / mask 1**, stationary surfaces, and a direct CollisionShape2D child. Its native `disabled`, `one_way_collision` and `one_way_collision_margin` persist. Shared-resource edits follow normal Godot behavior; the helper duplication action explicitly creates unique shapes. Trees serialize in deterministic native order. Each enabled record supplies `rect:Rect2`, `disabled:bool`, `one_way:bool`, `margin:float`, `layer:int`, `mask:int`. Disabled records never populate `world.platforms`.

Enabled slopes, arbitrary collision polygons, nonrectangular shapes, moving physics surfaces, physics in decoration branches, and unknown executable layout scripts are rejected. The old format 1 disabled slope example remains accepted and disabled. New traversal mechanics have no implementation here. Validation is a compatibility check for trusted local authoring scenes, not a sandbox for untrusted scene scripts: Godot instantiates a scene before inspecting it.

## R18 integration boundary

`world.gd` adds one preload, default-off opt-in state, a preparation call at the normal room build boundary, and guards against generated collision and terrain duplication. No other inherited runtime file changes. `--authored-r18` registers only room 18; IDs 0–17 and 19–20 always use their existing builders. A custom layout can be selected by the explicit preview launcher. Live R18 requires identity 18 and bounds 2600×1440.

The unchanged default scene is **the exact LD-TOOLS-01 file**. It supplies 18 rectangle bodies: two walls, one floor and fifteen one-way ledges, with original margins. Native bodies are instantiated once under `world.geometry`. Original generation calls still compute existing route bookkeeping, but `add_platform` returns before appending or creating bodies while the authored pilot is active. Game-owned anchors, gates and enemies still build once; cleanup frees the authored scene through the existing room owner.

The adapter populates the complete legacy `world.platforms` list, including walls and floor. Its audited consumers are enemy patrol support, cinematic arrival support and terrain drawing; Bellroof's rectangle operations remain room-14-only. `expansion.route_steps` retains its legacy computed route list for compatibility; it is not an alternate collision source and has no current gameplay consumer outside construction. Editing geometry does not redefine that legacy design bookkeeping.

Production terrain calls the unchanged `LevelGeometry.draw_surface` once per visible enabled rectangle. A small native draw node places it between authored background/foreground branches; `world._draw` skips its terrain loop only while the pilot is active. Authoring collision ink is hidden; physics remains native. This keeps the approved terrain atlas and allows proper decoration ordering without drawing slabs twice.

World graph, all 29 links, portal feet coordinates, progression prerequisites, opened gates, encounter persistence, checkpoint recovery, save version 8, application identity, and movement/controller files remain unchanged. Markers never feed these systems. No personal-save conversion is required.

## Compatibility limits

The adoption base is PR49 `00d74c36212e0493c242c25e15d4200ef094a49c`, inheriting PR39 `5dfc4c4f077c5408ecbe49f1cafafea1dcb1003c` and PR37. PR58, PR63 and PR74 were inspected as references and not imported. Their Canal/ground/transition changes and known GN-06 regression cannot be certified by this branch's results. Rebase or integration against a different base requires geometry/support-query parity checks against that exact source; never regenerate the freeze to hide drift.

The native editor action model follows Godot's [EditorUndoRedoManager](https://docs.godotengine.org/en/4.6/classes/class_editorundoredomanager.html) and [EditorInterface](https://docs.godotengine.org/en/4.6/classes/class_editorinterface.html) APIs. Creator approval remains required before default adoption or any room redesign.
