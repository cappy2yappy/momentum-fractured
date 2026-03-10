extends Camera2D
class_name RoomCamera

## Smooth room-constrained follow camera.
## Keeps the viewport inside room bounds while tracking the player.

@export var player_path: NodePath
@export var room_bounds: Rect2 = Rect2(0, 0, 1280, 720)
@export var follow_speed: float = 8.0

var _player: Node2D


func _ready() -> void:
	make_current()
	_resolve_player()


func _physics_process(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		_resolve_player()
		if _player == null:
			return

	# Clamp the target so camera never shows outside room geometry.
	var viewport_half := get_viewport_rect().size * 0.5 * zoom
	var min_x := room_bounds.position.x + viewport_half.x
	var max_x := room_bounds.end.x - viewport_half.x
	var min_y := room_bounds.position.y + viewport_half.y
	var max_y := room_bounds.end.y - viewport_half.y

	if max_x < min_x:
		max_x = min_x
	if max_y < min_y:
		max_y = min_y

	var target := _player.global_position
	target.x = clampf(target.x, min_x, max_x)
	target.y = clampf(target.y, min_y, max_y)

	var weight := clampf(delta * follow_speed, 0.0, 1.0)
	global_position = global_position.lerp(target, weight)


func _resolve_player() -> void:
	if not player_path.is_empty():
		_player = get_node_or_null(player_path)
		if _player:
			return

	for candidate in get_tree().get_nodes_in_group("player"):
		if candidate is Node2D:
			_player = candidate
			return
