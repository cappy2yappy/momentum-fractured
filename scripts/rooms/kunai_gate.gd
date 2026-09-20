extends Area2D

var required_element := "fire"
var gate_id := ""
var blocker: StaticBody2D


func _ready() -> void:
	collision_layer = 4
	collision_mask = 16
	area_entered.connect(_on_area_entered)
	blocker = StaticBody2D.new()
	blocker.collision_layer = 1
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(34, 250)
	collision.shape = shape
	blocker.add_child(collision)
	add_child(blocker)
	queue_redraw()


func _on_area_entered(projectile: Area2D) -> void:
	if String(projectile.get("element")) != required_element:
		return
	if is_instance_valid(projectile):
		projectile.queue_free()
	monitoring = false
	blocker.collision_layer = 0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.25)
	await tween.finished
	queue_free()


func _draw() -> void:
	var color := Color(1.0, 0.3, 0.1, 0.78) if required_element == "fire" else Color(1.0, 0.9, 0.18, 0.78)
	draw_rect(Rect2(-17, -125, 34, 250), color, true)
	for y in range(-105, 106, 30):
		draw_line(Vector2(-28, y), Vector2(28, y), Color(color, 0.95), 3.0)
