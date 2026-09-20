extends Node2D


func _ready() -> void:
	add_to_group("grapple_anchor")
	z_index = 4
	queue_redraw()


func _draw() -> void:
	var points := PackedVector2Array([
		Vector2(0, -11), Vector2(9, -5), Vector2(9, 5),
		Vector2(0, 11), Vector2(-9, 5), Vector2(-9, -5)
	])
	draw_colored_polygon(points, Color(0.2, 0.78, 0.95, 0.92))
	draw_polyline(points + PackedVector2Array([points[0]]), Color(0.78, 1.0, 1.0), 2.0)
	draw_circle(Vector2.ZERO, 3.0, Color.WHITE)
