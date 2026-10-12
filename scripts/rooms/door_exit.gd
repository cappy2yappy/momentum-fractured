extends Area2D
class_name DoorExit

## Door trigger that loads another room scene.
## Can be locked by room combat state or left always-open.

@export_file("*.tscn") var target_scene_path: String = ""
@export var target_spawn_marker: String = "spawn_default"
@export var door_prompt_text: String = "EXIT"
@export var locked_text: String = "(locked)"
@export var unlocked_text: String = "(open)"
@export var requires_room_clear: bool = false
@export var room_id: String = ""
@export var required_gate_id: String = ""
@export var transition_cooldown: float = 0.3

var is_locked: bool = false
var _room_locked: bool = false
var _cooldown_timer: float = 0.0

@onready var _label: Label = get_node_or_null("Label")


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_cooldown_timer = transition_cooldown
	if requires_room_clear and not room_id.is_empty():
		_room_locked = not GameState.is_room_cleared(room_id)
	GameState.gate_opened.connect(_on_gate_opened)
	GameState.map_changed.connect(_refresh_lock)
	_refresh_lock()


func _process(delta: float) -> void:
	if _cooldown_timer > 0.0:
		_cooldown_timer = maxf(0.0, _cooldown_timer - delta)


func set_locked(locked: bool) -> void:
	_room_locked = locked
	_refresh_lock()


func refresh_locked_from_state() -> void:
	if requires_room_clear and not room_id.is_empty():
		_room_locked = not GameState.is_room_cleared(room_id)
	else:
		_room_locked = false
	_refresh_lock()


func _on_gate_opened(gate_id: String) -> void:
	if gate_id == required_gate_id:
		_refresh_lock()


func _refresh_lock() -> void:
	is_locked = _room_locked or (not required_gate_id.is_empty() and not GameState.is_gate_open(required_gate_id))
	_update_label()


func _on_body_entered(body: Node2D) -> void:
	if is_locked:
		return
	if _cooldown_timer > 0.0:
		return
	if target_scene_path.is_empty():
		return
	if not body.is_in_group("player"):
		return

	GameState.capture_player_state(body)
	SceneNavigator.goto_scene(target_scene_path, target_spawn_marker)


func _update_label() -> void:
	if _label == null:
		return

	var state_text := locked_text if is_locked else unlocked_text
	_label.text = "%s\n%s" % [door_prompt_text, state_text]
