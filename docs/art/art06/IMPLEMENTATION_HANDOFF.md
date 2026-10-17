# ART-06 implementation handoff: Codex and Level Masta

All coordinates are world pixels in R18 (2600 x 1440). Collider tops are feet coordinates. Source of truth for placement: `assets/art06/r18/r18_layout.json`.

## 1. Layer model

| Layer | Draw point | Collides | Occludes Kaze | Contents |
|---|---|---|---|---|
| `bg_far` | after district background | no | no | damaged buildings (desaturated), base hidden behind back-wall crown |
| `bg_wall` | after `bg_far` | no | no | ruined back wall; arch openings are true alpha so the approved district background shows through |
| `bg_props` | after `bg_wall` | no | no | pump drums, pipe runs, elbows, routing plate, steam, lanterns |
| `support` | after `bg_props` | no | no | piers, relieving arches, timber beams, broken column; tinted 0.85 so they sit behind the walking plane |
| `gate_dressing` | after `support` | no | no | isolator frame around the existing electric gate; runtime gate bars still draw on top |
| `surface` | replaces `LevelGeometry.draw_surface` for listed rects | **matches collider exactly** | no | ledge cap tile (48 px: 40 px collider + 8 px lip shadow), floor face tile (140 px) |
| runtime markers | unchanged, after surfaces | as today | as today | gates, anchors, doors, labels, lore marker, vent telegraph |
| `fg_occluder` | Node2D, `z_index = 20` | no | **yes** | dark pipe/root silhouettes at the top corners only |

Solid vs one-way: the floor (0,1300,2600,140) is the only solid in-room surface. All 15 shelves are one-way (runtime rule: room >= 13, height 40). Art uses the same capstone language for both; the only solid-specific cue is the deep floor face.

## 2. Collision agreement rules (enforced by `tools/art06/validate_layout.py`)

1. Every in-room collider has exactly one surface entry with an identical rectangle, and the collider type matches. No art-only walkables.
2. Piers start at a real surface top or the floor. Nothing draws a horizontal cap across an open gap.
3. Under-ledge voids stay readable as open: the S0 lower-bay shelf gets a relieving arch, not a solid block, because the 80 px under it is physically open.
4. Keep-clear zones (3 tether anchors r70, both exits, undercroft door, vent hazard, lore marker, guard patrol lane 755..1145) are free of every dressing layer drawn above the background. `bg_wall` is exempt because it draws before all runtime markers.
5. Foreground occluders stay at least 120 px from any walkable surface.

## 3. Proposed runtime wiring (Codex)

Module: `tools/art06/proposed/r18_dressing.gd` (move to `scripts/r18_dressing.gd` and update `SELF_PATH`). Four hook lines, exactly what `tools/art06/apply_proposed_hooks.py` applies to a throwaway copy for testing:

```gdscript
# scripts/world.gd
const R18Dressing = preload("res://scripts/r18_dressing.gd")
# _draw():
RoomPresentation.draw_background(self)
R18Dressing.draw_back(self)
...
if not R18Dressing.draw_surface(self,rect): LevelGeometry.draw_surface(self,rect)
# build_room(), after cinematic_transitions.room_loaded(self):
R18Dressing.room_loaded(self)

# scripts/world_expansion.gd draw_room(), inside the silhouette loop:
if w.room==18 and w.R18Dressing.enabled(w): continue
```

Properties verified natively with the hooks applied: platform rectangles and every CollisionShape2D identical to the unpatched runtime; gate count unchanged; foreground node is a plain Node2D above Kaze with no physics; it is parented to `geometry`, so leaving R18 removes it; all 16 textures load; 16/16 in-room colliders have registered surface art. Unknown rectangles fall through to the default renderer, so a geometry change can never make a platform invisible.

Export note: `r18_layout.json` is read with `FileAccess`. Add `assets/art06/r18/*.json` to each export preset's `include_filter` (current presets include only `world/*.txt`), or convert the layout to a `.tres`. **Not yet verified in an exported build.**

Import settings: Godot defaults as committed (`compress/mode=0` lossless, no mipmaps, `fix_alpha_border=true`).

## 4. Level Masta: when #43 geometry lands

1. Dump the new colliders: `godot --path . --script res://tools/art06/capture_r18.gd -- --test`.
2. Edit `surfaces` (one per collider), move/add `supports` so each new mass is carried, re-check `keep_clear` against new anchors/exits.
3. Run the validator until 0 failures, then the integrated capture.
4. Retire the `interim_catwalk` beams for any slab you delete. The pier/arch/beam/cap kit already covers authored masonry masses; the back wall and pumps are geometry-independent.

Requests to Level from the art pass (not changed here):
- G5 overlaps S2 (x1065..1200, 8 px apart), G8 overlaps S3 (8 px), and G9/G10 stack 47 px over S3/S4. Overlapping one-way slabs draw as doubled cap edges no art can hide; these are geometry, flagged for #43.
- G3/G4 at y933/867 and G9/G10 at y713/667 are fractional coordinates from interpolation; authored geometry should land on whole pixels.
- The vent hazard bay (650,1210) has no visual source in the room story; a cracked pump outlet there would justify it if Level keeps it.
