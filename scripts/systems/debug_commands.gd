extends Node

## Debug hotkeys for rapid iteration of room flow + save state.
## F5 reset progress, F6 respawn at checkpoint, F7 add cells,
## F8 set checkpoint to nearest spawn marker, F9 print current state.

@export var enabled_in_non_debug_builds: bool = false
@export var cells_grant_amount: int = 50


func _input(event: InputEvent) -> void:
	if not _debug_enabled():
		return
	if not (event is InputEventKey):
		return
	if not event.pressed or event.echo:
		return

	match event.keycode:
		KEY_F5:
			debug_reset_progress()
		KEY_F6:
			debug_respawn_checkpoint()
		KEY_F7:
			debug_add_cells(cells_grant_amount)
		KEY_F8:
			debug_set_checkpoint_here()
		KEY_F9:
			debug_print_state()


func debug_reset_progress() -> void:
	var game_state := _game_state()
	var scene_navigator := _scene_navigator()
	if game_state == null or scene_navigator == null:
		return
	game_state.reset_progress()
	scene_navigator.goto_scene(game_state.checkpoint_scene_path, game_state.checkpoint_spawn_marker)
	print("[Debug] Progress reset to default start.")


func debug_respawn_checkpoint() -> void:
	var scene_navigator := _scene_navigator()
	if scene_navigator == null:
		return
	scene_navigator.respawn_from_checkpoint()
	print("[Debug] Respawning at checkpoint.")


func debug_add_cells(amount: int) -> void:
	var game_state := _game_state()
	if game_state == null:
		return
	game_state.add_cells(amount)
	print("[Debug] Added %d cells (total: %d)." % [amount, game_state.cells])


func debug_set_checkpoint_here() -> void:
	var scene := get_tree().current_scene
	if scene == null:
		return

	var player := _find_player(scene)
	if player == null:
		return

	var marker_name := _nearest_spawn_marker_name(scene, player.global_position)
	if marker_name.is_empty():
		marker_name = "spawn_default"

	var game_state := _game_state()
	if game_state == null:
		return
	game_state.capture_player_state(player)
	game_state.set_checkpoint(scene.scene_file_path, marker_name)
	print("[Debug] Checkpoint updated: %s @ %s" % [scene.scene_file_path, marker_name])


func debug_print_state() -> void:
	var game_state := _game_state()
	if game_state == null:
		return
	print("[Debug] %s" % JSON.stringify(game_state.get_debug_snapshot()))


func _find_player(scene: Node) -> Node2D:
	for candidate in get_tree().get_nodes_in_group("player"):
		if candidate is Node2D and scene.is_ancestor_of(candidate):
			return candidate
	return null


func _nearest_spawn_marker_name(scene: Node, from_position: Vector2) -> String:
	var spawn_points := scene.get_node_or_null("SpawnPoints")
	if spawn_points == null:
		return ""

	var nearest_name := ""
	var nearest_distance := INF
	for child in spawn_points.get_children():
		if child is Marker2D:
			var distance := from_position.distance_squared_to(child.global_position)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_name = child.name

	return nearest_name


func _debug_enabled() -> bool:
	return OS.is_debug_build() or enabled_in_non_debug_builds


func _game_state() -> Node:
	if not is_inside_tree():
		return null
	var tree := get_tree()
	return tree.root.get_node_or_null("GameState") if tree else null


func _scene_navigator() -> Node:
	if not is_inside_tree():
		return null
	var tree := get_tree()
	return tree.root.get_node_or_null("SceneNavigator") if tree else null
