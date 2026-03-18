extends CanvasLayer
class_name VictoryScreen

## End-of-slice victory summary.

@export var restart_scene_path: String = "res://scenes/rooms/room_01_combat.tscn"
@export var restart_spawn_marker: String = "spawn_default"

@onready var rooms_value: Label = $Panel/VBox/Stats/RoomsValue
@onready var cells_value: Label = $Panel/VBox/Stats/CellsValue
@onready var deaths_value: Label = $Panel/VBox/Stats/DeathsValue
@onready var time_value: Label = $Panel/VBox/Stats/TimeValue
@onready var continue_button: Button = $Panel/VBox/Buttons/ContinueButton
@onready var quit_button: Button = $Panel/VBox/Buttons/QuitButton


func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	_refresh_stats()


func _refresh_stats() -> void:
	var game_state := _game_state()
	if game_state == null:
		rooms_value.text = "0"
		cells_value.text = "0"
		deaths_value.text = "0"
		time_value.text = "00:00"
		return
	rooms_value.text = str(game_state.cleared_rooms.size())
	cells_value.text = str(game_state.cells)
	deaths_value.text = str(game_state.death_count)
	time_value.text = _format_time(game_state.get_run_time_seconds())


func _format_time(total_seconds: int) -> String:
	var seconds: int = max(0, total_seconds)
	var minutes: int = int(seconds / 60)
	var rem_seconds: int = seconds % 60
	return "%02d:%02d" % [minutes, rem_seconds]


func _on_continue_pressed() -> void:
	var scene_navigator := _scene_navigator()
	if scene_navigator:
		scene_navigator.goto_scene(restart_scene_path, restart_spawn_marker)


func _on_quit_pressed() -> void:
	get_tree().quit()


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
