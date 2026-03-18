extends Node

const ROOM_01 := "res://scenes/rooms/room_01_combat.tscn"
const ROOM_02 := "res://scenes/rooms/room_02_platforming.tscn"
const ROOM_03 := "res://scenes/rooms/room_03_mixed.tscn"
const ROOM_04 := "res://scenes/rooms/room_04_checkpoint.tscn"

const TRANSITION_WAIT := 0.7


func _ready() -> void:
	var game_state := _game_state()
	if game_state and game_state.has_method("reset_progress"):
		game_state.reset_progress()
	await get_tree().process_frame

	var ok := true
	ok = await _load_room(ROOM_01) and ok
	ok = await _verify_room_01_locked_then_unlock() and ok
	ok = await _trigger_door_and_expect("Environment/RightDoor", ROOM_02) and ok

	ok = await _trigger_door_and_expect("Environment/RightDoor", ROOM_03) and ok

	ok = await _verify_room_03_locked_then_unlock() and ok
	ok = await _trigger_door_and_expect("Environment/RightDoor", ROOM_04) and ok

	if ok:
		print("ROOM_FLOW_SMOKE: PASS")
		get_tree().quit(0)
	else:
		push_error("ROOM_FLOW_SMOKE: FAIL")
		get_tree().quit(1)


func _load_room(scene_path: String) -> bool:
	get_tree().change_scene_to_file.call_deferred(scene_path)
	await get_tree().process_frame
	await get_tree().process_frame
	return _assert_current_scene(scene_path)


func _verify_room_01_locked_then_unlock() -> bool:
	if not _assert_current_scene(ROOM_01):
		return false
	var door := get_tree().current_scene.get_node_or_null("Environment/RightDoor")
	if door == null:
		push_error("Room 01 missing RightDoor")
		return false
	if not bool(door.get("is_locked")):
		push_error("Room 01 right door should start locked")
		return false
	var controller := get_tree().current_scene
	if controller and controller.has_method("_clear_room"):
		controller.call("_clear_room")
		await get_tree().create_timer(0.35).timeout
	return not bool(door.get("is_locked"))


func _verify_room_03_locked_then_unlock() -> bool:
	if not _assert_current_scene(ROOM_03):
		return false
	var door := get_tree().current_scene.get_node_or_null("Environment/RightDoor")
	if door == null:
		push_error("Room 03 missing RightDoor")
		return false
	if not bool(door.get("is_locked")):
		push_error("Room 03 right door should start locked")
		return false
	var controller := get_tree().current_scene
	if controller and controller.has_method("_clear_room"):
		controller.call("_clear_room")
		await get_tree().create_timer(0.4).timeout
	return not bool(door.get("is_locked"))


func _trigger_door_and_expect(door_path: String, expected_scene: String) -> bool:
	var scene := get_tree().current_scene
	if scene == null:
		push_error("No active scene before door trigger")
		return false
	var player := scene.get_node_or_null("Kaze")
	if player == null:
		push_error("No player node found in %s" % scene.scene_file_path)
		return false
	var door := scene.get_node_or_null(door_path)
	if door == null:
		push_error("Door missing at %s in %s" % [door_path, scene.scene_file_path])
		return false

	door.set("_cooldown_timer", 0.0)
	if door.has_method("_on_body_entered"):
		door.call("_on_body_entered", player)
	else:
		push_error("Door at %s missing _on_body_entered handler" % door_path)
		return false

	await get_tree().create_timer(TRANSITION_WAIT).timeout
	return _assert_current_scene(expected_scene)


func _assert_current_scene(expected_scene_path: String) -> bool:
	var scene := get_tree().current_scene
	if scene == null:
		push_error("No current scene; expected %s" % expected_scene_path)
		return false
	if scene.scene_file_path != expected_scene_path:
		push_error("Expected scene %s but found %s" % [expected_scene_path, scene.scene_file_path])
		return false
	return true


func _game_state() -> Node:
	return get_node_or_null("/root/GameState")
