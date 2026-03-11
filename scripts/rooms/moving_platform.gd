extends AnimatableBody2D
class_name MovingPlatform

## Configurable moving platform with multiple path patterns.

enum Pattern { HORIZONTAL, VERTICAL, CIRCULAR }

@export var pattern: Pattern = Pattern.HORIZONTAL
@export var move_distance: Vector2 = Vector2(120.0, 90.0)
@export var move_speed: float = 1.4
@export var phase_offset: float = 0.0
@export var show_path_indicator: bool = true

var _origin: Vector2
var _time: float = 0.0
var _previous_position: Vector2
var _path_visual: Line2D = null
var _direction_arrow: Polygon2D = null


func _ready() -> void:
	_origin = global_position
	_previous_position = global_position
	_time = phase_offset
	_create_path_visual()
	_create_direction_arrow()


func _physics_process(delta: float) -> void:
	_time += delta * move_speed
	_previous_position = global_position
	global_position = _origin + _calculate_offset(_time)
	_update_direction_arrow()


func _calculate_offset(time_value: float) -> Vector2:
	match pattern:
		Pattern.HORIZONTAL:
			return Vector2(sin(time_value) * move_distance.x, 0.0)
		Pattern.VERTICAL:
			return Vector2(0.0, sin(time_value) * move_distance.y)
		Pattern.CIRCULAR:
			return Vector2(cos(time_value) * move_distance.x, sin(time_value) * move_distance.y)
		_:
			return Vector2.ZERO


func _create_path_visual() -> void:
	if not show_path_indicator or get_parent() == null:
		return
	if DisplayServer.get_name() == "headless":
		return

	_path_visual = Line2D.new()
	_path_visual.name = "%s_Path" % name
	_path_visual.width = 2.0
	_path_visual.default_color = Color(0.7, 0.85, 1.0, 0.5)
	_path_visual.z_index = -2
	_path_visual.global_position = _origin

	match pattern:
		Pattern.HORIZONTAL:
			_path_visual.add_point(Vector2(-move_distance.x, 0.0))
			_path_visual.add_point(Vector2(move_distance.x, 0.0))
		Pattern.VERTICAL:
			_path_visual.add_point(Vector2(0.0, -move_distance.y))
			_path_visual.add_point(Vector2(0.0, move_distance.y))
		Pattern.CIRCULAR:
			var steps := 24
			for i in steps + 1:
				var ratio := float(i) / steps
				var angle := ratio * TAU
				_path_visual.add_point(Vector2(cos(angle) * move_distance.x, sin(angle) * move_distance.y))

	get_parent().add_child.call_deferred(_path_visual)


func _exit_tree() -> void:
	if _path_visual and not _path_visual.is_inside_tree():
		_path_visual.queue_free()


func _create_direction_arrow() -> void:
	_direction_arrow = Polygon2D.new()
	_direction_arrow.name = "DirectionArrow"
	_direction_arrow.color = Color(0.95, 0.95, 0.95, 0.9)
	_direction_arrow.polygon = PackedVector2Array([
		Vector2(14.0, 0.0),
		Vector2(-8.0, 6.0),
		Vector2(-8.0, -6.0),
	])
	_direction_arrow.position = Vector2.ZERO
	add_child(_direction_arrow)


func _update_direction_arrow() -> void:
	if _direction_arrow == null:
		return

	var movement := global_position - _previous_position
	if movement.length_squared() < 0.01:
		return

	_direction_arrow.rotation = movement.angle()
