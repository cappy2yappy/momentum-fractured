extends Area2D
class_name AbilityReliquary

## Authored ability reward and checkpoint interaction.
## The reward remains sealed until its encounter is clear, then requires an
## explicit player interaction so progression cannot happen off-screen.

@export var required_room_id: String = ""
@export var ability_id: String = "fire_kunai"
@export var ability_display_name: String = "Fire Kunai"
@export var checkpoint_spawn_marker: String = "spawn_checkpoint"
@export var claim_gate_path: NodePath
@export var interact_action: StringName = &"interact"

var _player_in_range: Node2D = null
var _claimed: bool = false

@onready var _prompt: Label = get_node_or_null("Prompt")
@onready var _core: CanvasItem = get_node_or_null("Core")


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if GameState.has_signal("room_cleared"):
		GameState.room_cleared.connect(_on_room_cleared)
	_claimed = GameState.has_ability(ability_id)
	_apply_claim_gate_state()
	_update_presentation()


func _process(_delta: float) -> void:
	if _player_in_range == null or _claimed or not _encounter_is_clear():
		return
	if Input.is_action_just_pressed(interact_action):
		claim_reward(_player_in_range)


func claim_reward(player: Node2D) -> bool:
	if _claimed or player == null or not player.is_in_group("player"):
		return false
	if not _encounter_is_clear():
		return false

	var scene_root := _resolve_scene_root(player)
	if scene_root == null:
		return false
	GameState.unlock_ability(ability_id)
	GameState.capture_player_state(player)
	GameState.set_checkpoint(scene_root.scene_file_path, checkpoint_spawn_marker)
	_claimed = true
	_apply_claim_gate_state()
	_update_presentation()
	_show_notification(player, "%s acquired  •  Checkpoint attuned" % ability_display_name)
	AudioManager.play_sfx("checkpoint")
	return true


func _resolve_scene_root(player: Node) -> Node:
	var candidate := player
	var highest_scene_root: Node = null
	while candidate:
		if not candidate.scene_file_path.is_empty():
			highest_scene_root = candidate
		candidate = candidate.get_parent()
	if highest_scene_root:
		return highest_scene_root
	var current_scene := player.get_tree().current_scene
	if current_scene and not current_scene.scene_file_path.is_empty():
		return current_scene
	return null


func _encounter_is_clear() -> bool:
	return required_room_id.is_empty() or GameState.is_room_cleared(required_room_id)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	_player_in_range = body
	_update_presentation()


func _on_body_exited(body: Node2D) -> void:
	if body == _player_in_range:
		_player_in_range = null
		_update_presentation()


func _on_room_cleared(room_id: String) -> void:
	if room_id == required_room_id:
		_update_presentation()


func _apply_claim_gate_state() -> void:
	var gate := get_node_or_null(claim_gate_path)
	if gate == null:
		return
	gate.visible = not _claimed
	if gate.has_method("set_collision_layer_value"):
		gate.set_collision_layer_value(1, not _claimed)
	if gate.has_method("set_collision_mask_value"):
		gate.set_collision_mask_value(1, not _claimed)


func _update_presentation() -> void:
	if _core:
		_core.modulate = Color(1.0, 0.42, 0.18, 1.0) if not _claimed else Color(0.38, 1.0, 0.74, 1.0)
	if _prompt == null:
		return
	if _claimed:
		_prompt.text = "%s CLAIMED\nCHECKPOINT ACTIVE" % ability_display_name.to_upper()
		_prompt.modulate = Color(0.55, 1.0, 0.78, 1.0)
	elif not _encounter_is_clear():
		_prompt.text = "RELIQUARY SEALED\nCLEAR THE CHAMBER"
		_prompt.modulate = Color(0.72, 0.72, 0.82, 1.0)
	elif _player_in_range:
		_prompt.text = "E  •  CLAIM %s" % ability_display_name.to_upper()
		_prompt.modulate = Color(1.0, 0.7, 0.34, 1.0)
	else:
		_prompt.text = "%s RELIQUARY" % ability_display_name.to_upper()
		_prompt.modulate = Color(1.0, 0.56, 0.3, 1.0)


func _show_notification(player: Node2D, message: String) -> void:
	var scene := player.get_tree().current_scene
	if scene == null:
		return
	var hud := scene.find_child("HUD", true, false)
	if hud and hud.has_method("show_notification"):
		hud.call("show_notification", message, Color(1.0, 0.62, 0.3, 1.0), 1.8)
