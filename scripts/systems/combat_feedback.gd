extends CanvasLayer

## Global combat feedback layer.
## Provides pooled damage numbers, hit pause, and flash helpers.

@export var pool_size: int = 12

var _pool: Array[Label] = []
var _pool_index: int = 0
var _hit_pause_active: bool = false


func _ready() -> void:
	layer = 200
	process_mode = Node.PROCESS_MODE_ALWAYS
	for _i in pool_size:
		var label := Label.new()
		label.visible = false
		label.top_level = true
		label.z_index = 200
		add_child(label)
		_pool.append(label)


func spawn_damage_number(world_position: Vector2, damage: float, critical: bool = false) -> void:
	if _pool.is_empty():
		return

	var label := _pool[_pool_index]
	_pool_index = (_pool_index + 1) % _pool.size()

	label.visible = true
	label.text = "%d" % roundi(damage)
	label.modulate = Color(1.0, 0.95, 0.35, 1.0) if critical else Color(1.0, 1.0, 1.0, 1.0)
	# Convert world coordinates to viewport-space for HUD-layer labels.
	var viewport_pos := get_viewport().get_canvas_transform() * (world_position + Vector2(randf_range(-8.0, 8.0), -42.0))
	label.position = viewport_pos

	var tween := label.create_tween()
	tween.tween_property(label, "position:y", label.position.y - 26.0, 0.42)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.42)
	tween.finished.connect(func() -> void:
		label.visible = false
	)


func flash_target(target: Node, flash_color: Color = Color(1, 1, 1, 1), return_duration: float = 0.1) -> void:
	if target == null:
		return

	var visual := _find_visual_node(target)
	if visual == null:
		return

	var original := visual.modulate
	visual.modulate = flash_color
	var tween := visual.create_tween()
	tween.tween_property(visual, "modulate", original, return_duration)


func hit_pause(duration: float = 0.05) -> void:
	if _hit_pause_active or duration <= 0.0:
		return

	_hit_pause_active = true
	get_tree().paused = true
	await get_tree().create_timer(duration, true).timeout
	get_tree().paused = false
	_hit_pause_active = false


func _find_visual_node(target: Node) -> CanvasItem:
	if target is CanvasItem:
		var item := target as CanvasItem
		if item.name == "AnimatedSprite2D" or item.name == "Sprite2D" or item.name == "ColorRect":
			return item

	for child in target.get_children():
		if child is CanvasItem:
			var item := child as CanvasItem
			if item.name == "AnimatedSprite2D" or item.name == "Sprite2D" or item.name == "ColorRect":
				return item

	return null
