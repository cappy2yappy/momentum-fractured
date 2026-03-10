extends Area2D
class_name Checkpoint

## Checkpoint trigger.
## Captures current player state and updates respawn location.

@export var checkpoint_spawn_marker: String = "spawn_checkpoint"
@export var heal_to_full: bool = true
@export var one_time_use: bool = false

var _activated: bool = false

@onready var _label: Label = get_node_or_null("Label")


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if one_time_use and _activated:
		return
	if not body.is_in_group("player"):
		return

	if heal_to_full and body.has_method("get_max_health") and body.has_method("set_health_values"):
		var max_health := float(body.call("get_max_health"))
		body.call("set_health_values", max_health, max_health)

	var game_state := _game_state()
	if game_state == null:
		return
	game_state.capture_player_state(body)
	var scene_path := body.get_tree().current_scene.scene_file_path
	game_state.set_checkpoint(scene_path, checkpoint_spawn_marker)

	_activated = true
	modulate = Color(0.5, 1.0, 0.7, 1.0)
	if _label:
		_label.text = "CHECKPOINT\n(activated)"


func _game_state() -> Node:
	return get_node_or_null("/root/GameState")
