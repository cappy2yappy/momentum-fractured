extends CanvasLayer

## Global scene transition manager.
## Handles fade transitions and applies spawn markers after room loads.

@export var fade_duration: float = 0.25

var is_transitioning: bool = false
var _fade_rect: ColorRect


func _ready() -> void:
	layer = 128
	process_mode = Node.PROCESS_MODE_ALWAYS

	_fade_rect = ColorRect.new()
	_fade_rect.name = "FadeRect"
	_fade_rect.color = Color(0, 0, 0, 0)
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fade_rect)

	# Apply checkpoint scene/spawn when booting the first room.
	await get_tree().process_frame
	var current_scene := get_tree().current_scene
	if (
		GameState.loaded_from_disk
		and current_scene
		and current_scene.scene_file_path != GameState.checkpoint_scene_path
	):
		GameState.set_pending_spawn(GameState.checkpoint_spawn_marker)
		var err := get_tree().change_scene_to_file(GameState.checkpoint_scene_path)
		if err != OK:
			push_error("Failed to restore checkpoint scene '%s' (error %d)" % [GameState.checkpoint_scene_path, err])
		await get_tree().process_frame

	_restore_player_in_current_scene()


func goto_scene(scene_path: String, spawn_marker: String) -> void:
	if is_transitioning or scene_path.is_empty():
		return

	is_transitioning = true
	var game_state := _game_state()
	if game_state:
		game_state.set_pending_spawn(spawn_marker)

	await _fade_to_alpha(1.0)
	var err := get_tree().change_scene_to_file(scene_path)
	if err != OK:
		push_error("Failed to change scene to %s (error %d)" % [scene_path, err])
		await _fade_to_alpha(0.0)
		is_transitioning = false
		return

	await get_tree().process_frame
	_restore_player_in_current_scene()
	await _fade_to_alpha(0.0)
	is_transitioning = false


func respawn_from_checkpoint() -> void:
	if is_transitioning:
		return

	var game_state := _game_state()
	if game_state == null:
		return
	game_state.restore_from_checkpoint()
	goto_scene(game_state.checkpoint_scene_path, game_state.checkpoint_spawn_marker)


func _fade_to_alpha(target_alpha: float) -> void:
	if _fade_rect == null:
		return

	var tween := create_tween()
	tween.tween_property(_fade_rect, "color:a", clampf(target_alpha, 0.0, 1.0), fade_duration)
	await tween.finished


func _restore_player_in_current_scene() -> void:
	var current_scene := get_tree().current_scene
	if current_scene == null:
		return

	var player := _find_player_in_scene(current_scene)
	if player == null:
		return

	var game_state := _game_state()
	if game_state == null:
		return
	var spawn_marker_name: String = String(game_state.consume_pending_spawn())
	var marker := _find_spawn_marker(current_scene, spawn_marker_name)
	if marker:
		player.global_position = marker.global_position

	game_state.apply_player_state(player)


func _find_player_in_scene(current_scene: Node) -> Node2D:
	for candidate in get_tree().get_nodes_in_group("player"):
		if candidate is Node2D and current_scene.is_ancestor_of(candidate):
			return candidate

	var fallback := current_scene.find_child("Kaze", true, false)
	if fallback is Node2D:
		return fallback
	return null


func _find_spawn_marker(current_scene: Node, marker_name: String) -> Marker2D:
	if marker_name.is_empty():
		return null

	var spawn_points := current_scene.get_node_or_null("SpawnPoints")
	if spawn_points and spawn_points.has_node(marker_name):
		var marker := spawn_points.get_node(marker_name)
		if marker is Marker2D:
			return marker

	var fallback := current_scene.find_child(marker_name, true, false)
	if fallback is Marker2D:
		return fallback

	# Legacy scenes may not define spawn markers; keep current player placement.
	return null


func _game_state() -> Node:
	return get_node_or_null("/root/GameState")
