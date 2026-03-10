extends Node2D
class_name SpinVisual

## Lightweight rotating visual used for saw hazards.

@export var rotation_speed_degrees: float = 180.0


func _process(delta: float) -> void:
	rotation += deg_to_rad(rotation_speed_degrees) * delta
