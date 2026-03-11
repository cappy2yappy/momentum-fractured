extends Node

## Persistent progression state for the current metroidvania slice.
## Tracks room clears, checkpoint data, and player stats across scene loads.

const SAVE_PATH := "user://fractured_save.dat"
const DEFAULT_START_SCENE := "res://scenes/rooms/room_01_combat.tscn"
const DEFAULT_START_SPAWN := "spawn_default"

signal cells_changed(total_cells: int)
signal player_health_changed(current: float, max_health: float)
signal checkpoint_updated(scene_path: String, spawn_marker: String)
signal room_cleared(room_id: String)
signal combo_changed(combo_count: int)
signal abilities_changed(abilities: Array[String])
signal state_reset

var cleared_rooms: Dictionary = {}
var cells: int = 0
var combo_count: int = 0
var abilities_unlocked: Array[String] = []
var loaded_from_disk: bool = false

var player_health: float = 100.0
var player_max_health: float = 100.0

var checkpoint_health: float = 100.0
var checkpoint_max_health: float = 100.0
var checkpoint_scene_path: String = DEFAULT_START_SCENE
var checkpoint_spawn_marker: String = DEFAULT_START_SPAWN

var pending_spawn_marker: String = DEFAULT_START_SPAWN


func _ready() -> void:
	if not load_from_disk():
		_set_defaults()
		loaded_from_disk = false
	else:
		loaded_from_disk = true
	_emit_runtime_signals()


func _set_defaults() -> void:
	cleared_rooms.clear()
	cells = 0
	player_health = 100.0
	player_max_health = 100.0
	checkpoint_health = player_health
	checkpoint_max_health = player_max_health
	checkpoint_scene_path = DEFAULT_START_SCENE
	checkpoint_spawn_marker = DEFAULT_START_SPAWN
	pending_spawn_marker = DEFAULT_START_SPAWN
	combo_count = 0
	abilities_unlocked.clear()


func _emit_runtime_signals() -> void:
	emit_signal("cells_changed", cells)
	emit_signal("player_health_changed", player_health, player_max_health)
	emit_signal("checkpoint_updated", checkpoint_scene_path, checkpoint_spawn_marker)
	emit_signal("combo_changed", combo_count)
	emit_signal("abilities_changed", abilities_unlocked)


func is_room_cleared(room_id: String) -> bool:
	if room_id.is_empty():
		return false
	return bool(cleared_rooms.get(room_id, false))


func mark_room_cleared(room_id: String) -> void:
	if room_id.is_empty() or is_room_cleared(room_id):
		return

	cleared_rooms[room_id] = true
	emit_signal("room_cleared", room_id)
	save_to_disk()


func add_cells(amount: int) -> void:
	if amount == 0:
		return

	cells = max(0, cells + amount)
	emit_signal("cells_changed", cells)
	save_to_disk()


func set_player_health(current: float, max_health_value: float = -1.0) -> void:
	var old_health := player_health
	var old_max := player_max_health
	if max_health_value > 0.0:
		player_max_health = max_health_value
	player_health = clampf(current, 0.0, player_max_health)
	if !is_equal_approx(old_health, player_health) or !is_equal_approx(old_max, player_max_health):
		emit_signal("player_health_changed", player_health, player_max_health)
		save_to_disk()


func capture_player_state(player: Node) -> void:
	if not is_instance_valid(player):
		return

	if player.has_method("get_current_health") and player.has_method("get_max_health"):
		set_player_health(float(player.call("get_current_health")), float(player.call("get_max_health")))


func apply_player_state(player: Node) -> void:
	if not is_instance_valid(player):
		return

	if player.has_method("set_health_values"):
		player.call("set_health_values", player_health, player_max_health)


func set_checkpoint(scene_path: String, spawn_marker: String) -> void:
	if scene_path.is_empty() or spawn_marker.is_empty():
		return

	checkpoint_scene_path = scene_path
	checkpoint_spawn_marker = spawn_marker
	checkpoint_health = player_health
	checkpoint_max_health = player_max_health
	emit_signal("checkpoint_updated", checkpoint_scene_path, checkpoint_spawn_marker)
	save_to_disk()


func restore_from_checkpoint() -> void:
	player_max_health = checkpoint_max_health
	player_health = checkpoint_health
	emit_signal("player_health_changed", player_health, player_max_health)


func set_pending_spawn(marker: String) -> void:
	pending_spawn_marker = marker if not marker.is_empty() else DEFAULT_START_SPAWN


func consume_pending_spawn() -> String:
	var marker := pending_spawn_marker
	pending_spawn_marker = DEFAULT_START_SPAWN
	return marker


func register_combo_hit() -> void:
	combo_count += 1
	emit_signal("combo_changed", combo_count)


func reset_combo() -> void:
	if combo_count == 0:
		return
	combo_count = 0
	emit_signal("combo_changed", combo_count)


func get_combo_count() -> int:
	return combo_count


func has_ability(ability_id: String) -> bool:
	return ability_id in abilities_unlocked


func unlock_ability(ability_id: String) -> void:
	if ability_id.is_empty() or ability_id in abilities_unlocked:
		return
	abilities_unlocked.append(ability_id)
	emit_signal("abilities_changed", abilities_unlocked)
	save_to_disk()


func reset_progress() -> void:
	_set_defaults()
	loaded_from_disk = false
	save_to_disk()
	_emit_runtime_signals()
	emit_signal("state_reset")


func new_game() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	_set_defaults()
	loaded_from_disk = false
	_emit_runtime_signals()
	emit_signal("state_reset")


func manual_save() -> void:
	save_to_disk()


func get_debug_snapshot() -> Dictionary:
	return {
		"cells": cells,
		"player_health": player_health,
		"player_max_health": player_max_health,
		"checkpoint_scene_path": checkpoint_scene_path,
		"checkpoint_spawn_marker": checkpoint_spawn_marker,
		"pending_spawn_marker": pending_spawn_marker,
		"cleared_room_count": cleared_rooms.size(),
		"combo_count": combo_count,
		"abilities_unlocked": abilities_unlocked,
		"loaded_from_disk": loaded_from_disk,
	}


func save_to_disk() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Failed to open save file for writing: %s" % SAVE_PATH)
		return

	var payload := {
		"cleared_rooms": cleared_rooms,
		"cells": cells,
		"player_health": player_health,
		"player_max_health": player_max_health,
		"checkpoint_health": checkpoint_health,
		"checkpoint_max_health": checkpoint_max_health,
		"checkpoint_scene_path": checkpoint_scene_path,
		"checkpoint_spawn_marker": checkpoint_spawn_marker,
		"pending_spawn_marker": pending_spawn_marker,
	}
	file.store_string(JSON.stringify(payload))


func load_from_disk() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return false

	var data := parsed as Dictionary
	cleared_rooms = data.get("cleared_rooms", {})
	cells = int(data.get("cells", 0))
	player_health = float(data.get("player_health", 100.0))
	player_max_health = float(data.get("player_max_health", 100.0))
	checkpoint_health = float(data.get("checkpoint_health", player_health))
	checkpoint_max_health = float(data.get("checkpoint_max_health", player_max_health))
	checkpoint_scene_path = String(data.get("checkpoint_scene_path", DEFAULT_START_SCENE))
	checkpoint_spawn_marker = String(data.get("checkpoint_spawn_marker", DEFAULT_START_SPAWN))
	pending_spawn_marker = String(data.get("pending_spawn_marker", checkpoint_spawn_marker))
	abilities_unlocked.clear()
	for ability in data.get("abilities_unlocked", []):
		abilities_unlocked.append(String(ability))

	player_health = clampf(player_health, 0.0, player_max_health)
	checkpoint_health = clampf(checkpoint_health, 0.0, checkpoint_max_health)
	if checkpoint_scene_path.is_empty():
		checkpoint_scene_path = DEFAULT_START_SCENE
	if checkpoint_spawn_marker.is_empty():
		checkpoint_spawn_marker = DEFAULT_START_SPAWN
	if pending_spawn_marker.is_empty():
		pending_spawn_marker = checkpoint_spawn_marker

	return true
