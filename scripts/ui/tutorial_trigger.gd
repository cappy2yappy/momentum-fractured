extends Area2D
class_name TutorialTrigger

## Reusable tutorial trigger.
## Can fire from: player overlap, room clear, first enemy defeat, or on room start.

@export var tutorial_id: String = ""
@export_multiline var message: String = ""
@export var popup_path: NodePath
@export var duration: float = 5.0
@export var dismiss_on_action: bool = true
@export var show_on_ready: bool = false
@export var trigger_on_body_enter: bool = true
@export var show_after_first_enemy_defeat: bool = false
@export var show_on_room_clear: bool = false
@export var room_controller_path: NodePath

var _triggered: bool = false
var _room_controller: Node = null


func _ready() -> void:
	if trigger_on_body_enter:
		body_entered.connect(_on_body_entered)
	else:
		monitoring = false

	if show_after_first_enemy_defeat or show_on_room_clear:
		_room_controller = _resolve_room_controller()
		if _room_controller:
			if show_after_first_enemy_defeat and _room_controller.has_signal("enemy_defeated"):
				var on_enemy_defeated := Callable(self, "_on_enemy_defeated")
				if not _room_controller.is_connected("enemy_defeated", on_enemy_defeated):
					_room_controller.connect("enemy_defeated", on_enemy_defeated)
			if show_on_room_clear and _room_controller.has_signal("room_cleared"):
				var on_room_cleared := Callable(self, "_on_room_cleared")
				if not _room_controller.is_connected("room_cleared", on_room_cleared):
					_room_controller.connect("room_cleared", on_room_cleared)

	if show_on_ready:
		call_deferred("_trigger_tutorial")


func _on_body_entered(body: Node2D) -> void:
	if _triggered:
		return
	if not body.is_in_group("player"):
		return
	_trigger_tutorial()


func _on_enemy_defeated(_remaining: int) -> void:
	_trigger_tutorial()


func _on_room_cleared() -> void:
	_trigger_tutorial()


func _trigger_tutorial() -> void:
	if _triggered:
		return
	if tutorial_id.is_empty() or message.strip_edges().is_empty():
		return

	if GameState.has_method("has_seen_tutorial") and bool(GameState.call("has_seen_tutorial", tutorial_id)):
		_triggered = true
		_disable_trigger()
		return

	var popup: Node = _resolve_popup()
	if popup == null or not popup.has_method("show_message"):
		return

	popup.call("show_message", message, duration, dismiss_on_action)
	if GameState.has_method("mark_tutorial_seen"):
		GameState.call("mark_tutorial_seen", tutorial_id)

	_triggered = true
	_disable_trigger()


func _resolve_popup() -> Node:
	if not popup_path.is_empty():
		return get_node_or_null(popup_path)
	return get_tree().current_scene.get_node_or_null("TutorialPopup")


func _resolve_room_controller() -> Node:
	if not room_controller_path.is_empty():
		return get_node_or_null(room_controller_path)

	var node: Node = get_parent()
	while node:
		if node.has_signal("room_cleared") or node.has_signal("enemy_defeated"):
			return node
		node = node.get_parent()
	return null


func _disable_trigger() -> void:
	monitoring = false
	monitorable = false
	var shape: CollisionShape2D = get_node_or_null("CollisionShape2D")
	if shape:
		shape.set_deferred("disabled", true)
