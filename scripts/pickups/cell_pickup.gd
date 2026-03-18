extends Area2D

## Cell currency pickup dropped by enemies.

@export var amount: int = 5
@export var magnet_speed: float = 360.0
@export var magnet_radius: float = 110.0

var _target_player: Node2D = null

@onready var _label: Label = $Label


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if _label:
		_label.text = "+%d" % amount

	await get_tree().create_timer(10.0).timeout
	if is_inside_tree():
		queue_free()


func _physics_process(delta: float) -> void:
	if _target_player == null:
		_find_player_magnet_target()
		return

	if not is_instance_valid(_target_player):
		_target_player = null
		return

	var to_player := _target_player.global_position - global_position
	if to_player.length() <= 10.0:
		_collect()
		return

	global_position += to_player.normalized() * magnet_speed * delta


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_collect()


func _collect() -> void:
	var game_state := _game_state()
	if game_state:
		game_state.add_cells(amount)
	var audio_manager := _audio_manager()
	if audio_manager:
		audio_manager.play_sfx("cell_pickup")
	queue_free()


func _find_player_magnet_target() -> void:
	for candidate in get_tree().get_nodes_in_group("player"):
		if candidate is Node2D:
			var distance := global_position.distance_to(candidate.global_position)
			if distance <= magnet_radius:
				_target_player = candidate
				return


func _game_state() -> Node:
	if not is_inside_tree():
		return null
	var tree := get_tree()
	return tree.root.get_node_or_null("GameState") if tree else null


func _audio_manager() -> Node:
	if not is_inside_tree():
		return null
	var tree := get_tree()
	return tree.root.get_node_or_null("AudioManager") if tree else null
