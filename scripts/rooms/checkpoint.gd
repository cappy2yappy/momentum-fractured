extends Area2D
class_name Checkpoint

## Checkpoint trigger.
## Captures current player state and updates respawn location.

@export var checkpoint_spawn_marker: String = "spawn_checkpoint"
@export var heal_to_full: bool = true
@export var one_time_use: bool = false
@export var checkpoint_notification_text: String = "Checkpoint saved"

var _activated: bool = false

@onready var _label: Label = get_node_or_null("Label")
@onready var _glow_rect: ColorRect = get_node_or_null("ColorRect")


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_setup_glow()


func _on_body_entered(body: Node2D) -> void:
	if one_time_use and _activated:
		return
	if not body.is_in_group("player"):
		return

	if heal_to_full and body.has_method("get_max_health") and body.has_method("set_health_values"):
		var max_health := float(body.call("get_max_health"))
		body.call("set_health_values", max_health, max_health)

	GameState.capture_player_state(body)
	var scene_path := body.get_tree().current_scene.scene_file_path
	GameState.set_checkpoint(scene_path, checkpoint_spawn_marker)

	_activated = true
	modulate = Color(0.5, 1.0, 0.7, 1.0)
	if _label:
		_label.text = "CHECKPOINT\n(activated)"

	_show_checkpoint_notification(body)
	AudioManager.play_sfx("checkpoint")


func _setup_glow() -> void:
	if _glow_rect == null:
		return

	_glow_rect.modulate.a = 0.45
	var glow_tween := create_tween()
	glow_tween.set_loops()
	glow_tween.tween_property(_glow_rect, "modulate:a", 0.82, 0.8)
	glow_tween.tween_property(_glow_rect, "modulate:a", 0.4, 0.8)


func _show_checkpoint_notification(body: Node2D) -> void:
	var scene := body.get_tree().current_scene
	if scene == null:
		return

	var hud := scene.find_child("HUD", true, false)
	if hud and hud.has_method("show_notification"):
		hud.call("show_notification", checkpoint_notification_text, Color(0.76, 1.0, 0.8, 1.0), 1.1)

