extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("set_water_zone"):
		body.call("set_water_zone", self, true, _surface_y())
	elif body.has_method("set_in_water"):
		body.call("set_in_water", true)


func _on_body_exited(body: Node2D) -> void:
	if body.has_method("set_water_zone"):
		body.call("set_water_zone", self, false, _surface_y())
	elif body.has_method("set_in_water"):
		body.call("set_in_water", false)


func _surface_y() -> float:
	var collision := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision and collision.shape is RectangleShape2D:
		return collision.global_position.y - (collision.shape as RectangleShape2D).size.y * absf(collision.global_scale.y) * 0.5
	return global_position.y
