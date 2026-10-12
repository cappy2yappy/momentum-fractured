extends Area2D

@export var required_element := "fire"
@export var gate_id := ""
@export var gate_size := Vector2(34, 250)
var blocker: StaticBody2D
var is_open := false
var feedback_label: Label


func _ready() -> void:
	collision_layer = 4
	collision_mask = 16
	area_entered.connect(_on_area_entered)
	var shape := RectangleShape2D.new()
	shape.size = gate_size
	var trigger := CollisionShape2D.new()
	trigger.shape = shape
	add_child(trigger)
	blocker = StaticBody2D.new()
	blocker.collision_layer = 1
	var collision := CollisionShape2D.new()
	collision.shape = shape
	blocker.add_child(collision)
	add_child(blocker)
	feedback_label = Label.new()
	feedback_label.position = Vector2(-130, -minf(gate_size.y * 0.5, 120.0) - 42)
	feedback_label.size = Vector2(260, 40)
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_label.text = "%s SEAL • F + %s Kunai" % [required_element.to_upper(), required_element.capitalize()]
	add_child(feedback_label)
	GameState.map_changed.connect(_sync_state)
	GameState.discover_gate(gate_id)
	_sync_state()
	queue_redraw()


func _sync_state() -> void:
	if not GameState.is_gate_open(gate_id):
		return
	is_open = true
	blocker.set_deferred("collision_layer", 0)
	set_deferred("monitoring", false)
	visible = false


func _on_area_entered(projectile: Area2D) -> void:
	if is_open or not is_instance_valid(projectile) or projectile.get_script() != preload("res://scripts/player/kunai_projectile.gd"):
		return
	var element := String(projectile.get("element"))
	projectile.queue_free()
	if element != required_element:
		feedback_label.text = "Requires %s Kunai • scroll to select" % required_element.capitalize()
		return
	is_open = true
	GameState.open_gate(gate_id)
	blocker.set_deferred("collision_layer", 0)
	set_deferred("monitoring", false)
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.25)


func _draw() -> void:
	var color := Color(1.0, 0.3, 0.1, 0.78) if required_element == "fire" else Color(1.0, 0.9, 0.18, 0.78)
	draw_rect(Rect2(-gate_size * 0.5, gate_size), color, true)
	for y in range(int(-gate_size.y * 0.5) + 20, int(gate_size.y * 0.5), 30):
		draw_line(Vector2(-28, y), Vector2(28, y), Color(color, 0.95), 3.0)
