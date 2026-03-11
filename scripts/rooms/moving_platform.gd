extends AnimatableBody2D
class_name MovingPlatform

## Simple deterministic moving platform for traversal rooms.
## Moves back and forth along a configurable axis.

@export var move_axis: Vector2 = Vector2.RIGHT
@export var move_distance: float = 120.0
@export var move_speed: float = 1.4
@export var phase_offset: float = 0.0

var _origin: Vector2
var _time: float = 0.0


func _ready() -> void:
	_origin = global_position
	_time = phase_offset


func _physics_process(delta: float) -> void:
	_time += delta * move_speed
	var direction := move_axis.normalized()
	global_position = _origin + direction * sin(_time) * move_distance
