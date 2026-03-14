extends CanvasLayer
class_name TutorialPopup

## Lightweight contextual tutorial popup.
## Can auto-dismiss and optionally close on the player's next action.

@export var default_duration: float = 5.0
@export var dismiss_actions: Array[StringName] = [
	&"move_left",
	&"move_right",
	&"jump",
	&"dash",
	&"attack_light",
]

@onready var panel: PanelContainer = $Panel
@onready var message_label: Label = $Panel/Message

var _is_visible: bool = false
var _dismiss_on_action: bool = true
var _hide_tween: Tween = null


func _ready() -> void:
	_hide_immediate()


func show_message(message: String, duration: float = -1.0, dismiss_on_action: bool = true) -> void:
	if message.strip_edges().is_empty():
		return

	if _hide_tween and _hide_tween.is_valid():
		_hide_tween.kill()
		_hide_tween = null

	_dismiss_on_action = dismiss_on_action
	_is_visible = true
	visible = true
	panel.visible = true
	panel.modulate.a = 0.0
	message_label.text = message

	var shown_duration: float = default_duration if duration <= 0.0 else duration

	var tween := create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.18)
	tween.tween_interval(shown_duration)
	tween.tween_callback(Callable(self, "hide_popup"))


func hide_popup() -> void:
	if not _is_visible:
		return

	_is_visible = false
	if _hide_tween and _hide_tween.is_valid():
		_hide_tween.kill()

	_hide_tween = create_tween()
	_hide_tween.tween_property(panel, "modulate:a", 0.0, 0.22)
	await _hide_tween.finished
	_hide_immediate()


func _unhandled_input(event: InputEvent) -> void:
	if not _is_visible or not _dismiss_on_action:
		return

	if event is InputEventKey and event.is_pressed():
		hide_popup()
		return

	if event is InputEventMouseButton and event.is_pressed():
		hide_popup()
		return

	for action_name in dismiss_actions:
		if event.is_action_pressed(action_name):
			hide_popup()
			return


func _hide_immediate() -> void:
	visible = false
	panel.visible = false
	panel.modulate.a = 0.0
