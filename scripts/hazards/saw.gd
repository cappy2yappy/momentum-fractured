extends Area2D
class_name SawHazard

@export var damage: float = 15.0
@export var rotation_speed_degrees: float = 180.0
@export var move_axis: Vector2 = Vector2.ZERO
@export var move_distance: float = 0.0
@export var move_speed: float = 1.0

var _origin: Vector2
var _time: float = 0.0


func _ready() -> void:
	_origin = global_position
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	rotation += deg_to_rad(rotation_speed_degrees) * delta
	if move_distance > 0.0 and move_axis.length_squared() > 0.0:
		_time += delta * move_speed
		global_position = _origin + move_axis.normalized() * sin(_time) * move_distance


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if body.has_method("take_damage"):
		body.call("take_damage", damage)
