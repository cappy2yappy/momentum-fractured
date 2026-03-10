extends Node2D
class_name RoomController

## Room Controller - combat encounter flow + persistence glue.
## Handles enemy clear state, door lock/unlock, and player death respawn.

signal room_cleared
signal enemy_defeated(remaining: int)

@export var room_id: String = ""
@export var player_node: NodePath
@export var enemies_node: NodePath
@export var door_barriers: Array[NodePath] = []
@export var door_exits: Array[NodePath] = []
@export var enemy_counter_label: NodePath
@export var cells_per_enemy: int = 5
@export var door_unlock_delay: float = 0.2

var total_enemies: int = 0
var remaining_enemies: int = 0
var is_cleared: bool = false

var _player: Node = null


func _ready() -> void:
	await get_tree().process_frame

	_player = get_node_or_null(player_node) if not player_node.is_empty() else _find_player()
	_connect_player_signals()
	if _player:
		GameState.capture_player_state(_player)

	_initialize_room_state()
	_update_ui()


func _initialize_room_state() -> void:
	if not room_id.is_empty() and GameState.is_room_cleared(room_id):
		is_cleared = true
		_remove_enemies()
		_unlock_doors()
		return

	_setup_enemies()
	if total_enemies <= 0:
		is_cleared = true
		if not room_id.is_empty():
			GameState.mark_room_cleared(room_id)
		_unlock_doors()
	else:
		_lock_doors()


func _connect_player_signals() -> void:
	if _player == null:
		return

	var on_player_died := Callable(self, "_on_player_died")
	if _player.has_signal("died") and not _player.is_connected("died", on_player_died):
		_player.connect("died", on_player_died)

	var on_player_health_changed := Callable(self, "_on_player_health_changed")
	if _player.has_signal("health_changed") and not _player.is_connected("health_changed", on_player_health_changed):
		_player.connect("health_changed", on_player_health_changed)


func _setup_enemies() -> void:
	total_enemies = 0
	remaining_enemies = 0

	var enemies_container := get_node_or_null(enemies_node) if not enemies_node.is_empty() else null
	if enemies_container == null:
		return

	for child in enemies_container.get_children():
		var health := child.get_node_or_null("Health")
		if health and health.has_signal("died"):
			var on_enemy_died := Callable(self, "_on_enemy_died").bind(child)
			if not health.is_connected("died", on_enemy_died):
				health.connect("died", on_enemy_died)
			total_enemies += 1

	remaining_enemies = total_enemies


func _on_enemy_died(enemy_node: Node) -> void:
	remaining_enemies = max(0, remaining_enemies - 1)
	GameState.add_cells(cells_per_enemy)

	emit_signal("enemy_defeated", remaining_enemies)
	_update_ui()

	if remaining_enemies <= 0 and not is_cleared:
		_clear_room()

	# Let the enemy finish its own death flow first, then free if still present.
	if is_instance_valid(enemy_node):
		await get_tree().process_frame
		if is_instance_valid(enemy_node):
			enemy_node.queue_free()


func _clear_room() -> void:
	is_cleared = true
	emit_signal("room_cleared")

	if not room_id.is_empty():
		GameState.mark_room_cleared(room_id)

	if door_unlock_delay > 0.0:
		await get_tree().create_timer(door_unlock_delay).timeout
	_unlock_doors()
	_update_ui()


func _lock_doors() -> void:
	for barrier_path in door_barriers:
		var barrier := get_node_or_null(barrier_path)
		if barrier:
			barrier.show()
			if barrier.has_method("set_collision_layer_value"):
				barrier.set_collision_layer_value(1, true)
			if barrier.has_method("set_collision_mask_value"):
				barrier.set_collision_mask_value(1, true)

	_set_exits_locked(true)


func _unlock_doors() -> void:
	for barrier_path in door_barriers:
		var barrier := get_node_or_null(barrier_path)
		if barrier:
			barrier.hide()
			if barrier.has_method("set_collision_layer_value"):
				barrier.set_collision_layer_value(1, false)
			if barrier.has_method("set_collision_mask_value"):
				barrier.set_collision_mask_value(1, false)

	_set_exits_locked(false)


func _set_exits_locked(locked: bool) -> void:
	for exit_path in door_exits:
		var exit := get_node_or_null(exit_path)
		if exit == null:
			continue

		if exit.has_method("set_locked"):
			exit.call("set_locked", locked)
			continue

		# Backward compatibility for scenes that still use plain Area2D exits.
		if exit is Area2D:
			if not locked and not exit.body_entered.is_connected(_on_legacy_exit_triggered):
				exit.body_entered.connect(_on_legacy_exit_triggered)
			if exit.has_node("Label"):
				var label := exit.get_node("Label")
				if label is Label:
					label.text = "← EXIT\n(unlocked)" if not locked else "← EXIT\n(locked)"


func _on_legacy_exit_triggered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	GameState.capture_player_state(body)
	SceneNavigator.goto_scene(get_tree().current_scene.scene_file_path, "spawn_default")


func _on_player_died() -> void:
	SceneNavigator.respawn_from_checkpoint()


func _on_player_health_changed(current: float, max_health: float) -> void:
	GameState.set_player_health(current, max_health)


func _remove_enemies() -> void:
	var enemies_container := get_node_or_null(enemies_node) if not enemies_node.is_empty() else null
	if enemies_container == null:
		return

	for child in enemies_container.get_children():
		child.queue_free()

	total_enemies = 0
	remaining_enemies = 0


func _find_player() -> Node:
	for candidate in get_tree().get_nodes_in_group("player"):
		return candidate
	return null


func _update_ui() -> void:
	var counter := get_node_or_null(enemy_counter_label) if not enemy_counter_label.is_empty() else null
	if counter == null or not (counter is Label):
		return

	if is_cleared:
		counter.text = "Room Cleared"
		counter.modulate = Color(0.4, 1.0, 0.4, 1.0)
	else:
		counter.text = "Enemies Remaining: %d" % remaining_enemies
		counter.modulate = Color(1.0, 1.0, 1.0, 1.0)
