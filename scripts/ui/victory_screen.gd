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
	rooms_value.text = str(GameState.cleared_rooms.size())
	cells_value.text = str(GameState.cells)
	deaths_value.text = str(GameState.death_count)
	time_value.text = _format_time(GameState.get_run_time_seconds())


func _format_time(total_seconds: int) -> String:
	var seconds: int = max(0, total_seconds)
	var minutes: int = int(seconds / 60)
	var rem_seconds: int = seconds % 60
	return "%02d:%02d" % [minutes, rem_seconds]


func _on_continue_pressed() -> void:
	SceneNavigator.goto_scene(restart_scene_path, restart_spawn_marker)


func _on_quit_pressed() -> void:
	get_tree().quit()
