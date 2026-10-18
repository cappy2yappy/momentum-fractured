@tool
extends CollisionPolygon2D
## Optional pilot-only slope: native polygon handles edit both drawing and physics.
func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if polygon.size() < 3 or Geometry2D.triangulate_polygon(polygon).is_empty():
		return
	draw_colored_polygon(polygon, Color("70819880") if disabled else Color("687b78"))
	var outline := polygon.duplicate()
	outline.append(polygon[0])
	draw_polyline(outline, Color("c7dbd0"), 2.0)
