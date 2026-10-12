extends Area2D

@export var required_element := "fire"
@export var gate_id := ""
@export var blocker_size := Vector2(34, 250)

var blocker: StaticBody2D
var is_open := false
var _feedback_tween: Tween


func _ready() -> void:
	collision_layer = 4
	collision_mask = 16
	area_entered.connect(_on_area_entered)
	var shape := RectangleShape2D.new()
	shape.size = blocker_size
	# The previous gate had no detection shape, so projectiles could never
	# trigger it through physical overlap.
	var detection := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if detection == null:
		detection = CollisionShape2D.new()
		add_child(detection)
	detection.shape = shape
	blocker = StaticBody2D.new()
	blocker.collision_layer = 1
	var collision := CollisionShape2D.new()
	collision.shape = shape
	blocker.add_child(collision)
	add_child(blocker)
	if GameState.is_gate_open(gate_id):
		_apply_open_state(false)
	queue_redraw()


func _on_area_entered(projectile: Area2D) -> void:
	if is_open or not ("element" in projectile):
		return
	if String(projectile.get("element")) != required_element:
		# Consume the deflected shot without opening or recording the gate.
		projectile.queue_free()
		if _feedback_tween and _feedback_tween.is_valid():
			_feedback_tween.kill()
		modulate = Color(1.0, 0.65, 0.25)
		_feedback_tween = create_tween()
		_feedback_tween.tween_property(self, "modulate", Color.WHITE, 0.2)
		return
	projectile.queue_free()
	_apply_open_state(true)
	GameState.open_gate(gate_id)


func _apply_open_state(animate: bool) -> void:
	is_open = true
	# Opening is commonly called inside area_entered: defer physics mutations.
	set_deferred("monitoring", false)
	blocker.set_deferred("collision_layer", 0)
	if animate:
		if _feedback_tween and _feedback_tween.is_valid():
			_feedback_tween.kill()
		_feedback_tween = create_tween()
		_feedback_tween.tween_property(self, "modulate:a", 0.0, 0.25)
		AudioManager.play_sfx("door_unlock")
	else:
		visible = false


func _draw() -> void:
	var color := Color(1.0, 0.3, 0.1, 0.78) if required_element == "fire" else Color(1.0, 0.9, 0.18, 0.78)
	draw_rect(Rect2(-blocker_size * 0.5, blocker_size), color, true)
	for y in range(int(-blocker_size.y * 0.5) + 20, int(blocker_size.y * 0.5), 30):
		draw_line(Vector2(-blocker_size.x * 0.8, y), Vector2(blocker_size.x * 0.8, y), Color(color, 0.95), 3.0)
