@tool
extends CollisionShape2D
## The editable RectangleShape2D IS the visual outline and the physics source.
## Native orange handles resize it; move this node, not a separate art object.
@export var solid_color := Color("687b78")
@export var one_way_color := Color("d5b56e")
@export var disabled_color := Color("70819880")

func _process(_delta: float) -> void:
	# Redraw also catches native resource-handle edits and built-in checkbox changes.
	queue_redraw()

func _draw() -> void:
	if not shape is RectangleShape2D:
		return
	var rect := Rect2(-shape.size / 2.0, shape.size)
	var tint := disabled_color if disabled else (one_way_color if one_way_collision else solid_color)
	draw_rect(rect, tint)
	draw_rect(rect, tint.lightened(0.3), false, 2.0)
	if one_way_collision and not disabled:
		draw_line(rect.position, rect.position + Vector2(rect.size.x, 0), Color("fff0ba"), 4.0)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if not shape is RectangleShape2D:
		warnings.append("Use RectangleShape2D here; use the slope example for polygons.")
	if scale != Vector2.ONE or (get_parent() is Node2D and get_parent().scale != Vector2.ONE):
		warnings.append("Keep collision scale at (1,1). Resize Shape > Size or use orange shape handles.")
	return warnings
