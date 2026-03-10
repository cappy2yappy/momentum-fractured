extends AnimatableBody2D
class_name MovingPlatform

## Simple ping-pong platform motion for platforming rooms.

@export var travel_offset: Vector2 = Vector2(160.0, 0.0)
@export var cycle_duration: float = 2.0
@export var start_phase: float = 0.0

var _origin: Vector2
var _time: float = 0.0


func _ready() -> void:
	_origin = global_position
	_time = start_phase * TAU


func _physics_process(delta: float) -> void:
	if cycle_duration <= 0.0:
		global_position = _origin
		return

	_time = wrapf(_time + delta * TAU / cycle_duration, 0.0, TAU)
	var t := (sin(_time) + 1.0) * 0.5
	global_position = _origin + travel_offset * t
