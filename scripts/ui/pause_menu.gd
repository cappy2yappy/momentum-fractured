extends Control

## Pause menu with manual save and new game actions.

@onready var _panel: PanelContainer = $Panel
@onready var _save_button: Button = $Panel/VBox/SaveButton
@onready var _new_game_button: Button = $Panel/VBox/NewGameButton
@onready var _resume_button: Button = $Panel/VBox/ResumeButton

var _is_open: bool = false


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_save_button.pressed.connect(_on_save_pressed)
	_new_game_button.pressed.connect(_on_new_game_pressed)
	_resume_button.pressed.connect(_on_resume_pressed)


func _input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return
	if not event.pressed or event.echo:
		return
	if event.keycode != KEY_ESCAPE:
		return

	if _is_open:
		close_menu()
	else:
		open_menu()


func open_menu() -> void:
	_is_open = true
	visible = true
	get_tree().paused = true


func close_menu() -> void:
	_is_open = false
	visible = false
	get_tree().paused = false


func _on_save_pressed() -> void:
	var game_state := _game_state()
	if game_state:
		game_state.manual_save()
	var hud := get_parent()
	if hud and hud.has_method("show_notification"):
		hud.call("show_notification", "Game saved", Color(0.85, 0.95, 1.0, 1.0), 0.8)


func _on_new_game_pressed() -> void:
	close_menu()
	var game_state := _game_state()
	var scene_navigator := _scene_navigator()
	if game_state and scene_navigator:
		game_state.new_game()
		scene_navigator.goto_scene(game_state.DEFAULT_START_SCENE, game_state.DEFAULT_START_SPAWN)


func _on_resume_pressed() -> void:
	close_menu()


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
