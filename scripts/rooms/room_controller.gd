extends Node2D
class_name RoomController

const DISTRICT_TEXTURE := preload("res://rebuild/assets/district.png")
const TERRAIN_TEXTURE := preload("res://rebuild/assets/terrain.png")

## Room Controller - combat encounter flow + persistence glue.
## Handles enemy clear state, door lock/unlock, and player death respawn.

signal room_cleared
signal enemy_defeated(remaining: int)

@export var room_id: String = ""
@export var player_node: NodePath
@export var enemies_node: NodePath
@export var door_barriers: Array[NodePath] = []
@export var door_exits: Array[NodePath] = []
@export var enemy_counter_label: NodePath
@export var cells_per_enemy: int = 5
@export var door_unlock_delay: float = 0.2
@export_category("Prototype presentation helpers")
@export var build_default_environment: bool = true
@export var spawn_default_grapple_anchors: bool = true

var total_enemies: int = 0
var remaining_enemies: int = 0
var is_cleared: bool = false

var _player: Node = null


func _ready() -> void:
	GameState.visit_room(room_id)
	if build_default_environment:
		_build_web_parity_environment()
	if spawn_default_grapple_anchors:
		_spawn_default_grapple_anchors()
	await get_tree().process_frame

	_player = get_node_or_null(player_node) if not player_node.is_empty() else _find_player()
	_connect_player_signals()
	if _player:
		GameState.capture_player_state(_player)

	_initialize_room_state()
	_update_ui()


func _build_web_parity_environment() -> void:
	var background := Sprite2D.new()
	background.name = "PaintedDistrictBackdrop"
	background.texture = DISTRICT_TEXTURE
	background.position = Vector2(640, 360)
	background.scale = Vector2(1280.0 / 1536.0, 720.0 / 1024.0)
	background.modulate = Color(0.48, 0.43, 0.66, 0.88)
	background.z_index = -20
	add_child(background)

	var shade := ColorRect.new()
	shade.name = "AtmosphereShade"
	shade.position = Vector2.ZERO
	shade.size = Vector2(1280, 720)
	shade.color = Color(0.015, 0.02, 0.07, 0.32)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shade.z_index = -19
	add_child(shade)

	var environment := get_node_or_null("Environment")
	if environment:
		for child in environment.get_children():
			if child is StaticBody2D:
				_texture_static_body(child)

	var location := Label.new()
	location.position = Vector2(76, 62)
	location.size = Vector2(520, 42)
	location.text = "SILENT DISTRICT  •  %s" % room_id.replace("room_", "").replace("_", " ").to_upper()
	location.add_theme_font_size_override("font_size", 19)
	location.modulate = Color(0.72, 0.94, 1.0, 0.90)
	location.z_index = 5
	add_child(location)


func _texture_static_body(body: StaticBody2D) -> void:
	var collision := body.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision == null or not (collision.shape is RectangleShape2D):
		return
	var rectangle := collision.shape as RectangleShape2D
	var texture_layer := Sprite2D.new()
	texture_layer.name = "TerrainTexture"
	texture_layer.texture = TERRAIN_TEXTURE
	texture_layer.region_enabled = true
	texture_layer.region_rect = Rect2(512, 0, 512, 512)
	texture_layer.scale = rectangle.size / Vector2(512.0, 512.0)
	texture_layer.modulate = Color(0.54, 0.62, 0.78, 0.98)
	texture_layer.z_index = -1
	body.add_child(texture_layer)
	for visual in body.get_children():
		if visual is ColorRect:
			visual.modulate.a = 0.16


func _spawn_default_grapple_anchors() -> void:
	var anchor_positions: Array[Vector2] = [Vector2(420, 220), Vector2(720, 150), Vector2(1010, 260)]
	if "02" in room_id:
		anchor_positions = [Vector2(330, 250), Vector2(620, 120), Vector2(930, 230)]
	elif "03" in room_id:
		anchor_positions = [Vector2(280, 190), Vector2(590, 280), Vector2(920, 130)]
	for anchor_position in anchor_positions:
		var anchor := Node2D.new()
		anchor.set_script(preload("res://scripts/rooms/grapple_anchor.gd"))
		anchor.position = anchor_position
		add_child(anchor)


func _initialize_room_state() -> void:
	if not room_id.is_empty() and GameState.is_room_cleared(room_id):
		is_cleared = true
		_remove_enemies()
		_unlock_doors()
		return

	_setup_enemies()
	if total_enemies <= 0:
		is_cleared = true
		if not room_id.is_empty():
			GameState.mark_room_cleared(room_id)
		_unlock_doors()
	else:
		_lock_doors()


func _connect_player_signals() -> void:
	if _player == null:
		return

	var on_player_died := Callable(self, "_on_player_died")
	if _player.has_signal("died") and not _player.is_connected("died", on_player_died):
		_player.connect("died", on_player_died)

func _setup_enemies() -> void:
	total_enemies = 0
	remaining_enemies = 0

	var enemies_container := get_node_or_null(enemies_node) if not enemies_node.is_empty() else null
	if enemies_container == null:
		return

	for child in enemies_container.get_children():
		var health := child.get_node_or_null("Health")
		if health and health.has_signal("died"):
			var on_enemy_died := Callable(self, "_on_enemy_died").bind(child)
			if not health.is_connected("died", on_enemy_died):
				health.connect("died", on_enemy_died)
			total_enemies += 1

	remaining_enemies = total_enemies


func _on_enemy_died(enemy_node: Node) -> void:
	remaining_enemies = max(0, remaining_enemies - 1)
	var reward := cells_per_enemy * _get_combo_multiplier()
	if is_instance_valid(enemy_node) and enemy_node.has_method("spawn_cell_drop"):
		enemy_node.call("spawn_cell_drop", reward)
	else:
		GameState.add_cells(reward)

	emit_signal("enemy_defeated", remaining_enemies)
	_update_ui()

	if remaining_enemies <= 0 and not is_cleared:
		_clear_room()


func _clear_room() -> void:
	is_cleared = true
	emit_signal("room_cleared")

	if not room_id.is_empty():
		GameState.mark_room_cleared(room_id)

	if door_unlock_delay > 0.0:
		await get_tree().create_timer(door_unlock_delay).timeout
	_unlock_doors()
	_update_ui()


func _lock_doors() -> void:
	for barrier_path in door_barriers:
		var barrier := get_node_or_null(barrier_path)
		if barrier:
			barrier.show()
			if barrier.has_method("set_collision_layer_value"):
				barrier.set_collision_layer_value(1, true)
			if barrier.has_method("set_collision_mask_value"):
				barrier.set_collision_mask_value(1, true)

	_set_exits_locked(true)


func _unlock_doors() -> void:
	for barrier_path in door_barriers:
		var barrier := get_node_or_null(barrier_path)
		if barrier:
			barrier.hide()
			if barrier.has_method("set_collision_layer_value"):
				barrier.set_collision_layer_value(1, false)
			if barrier.has_method("set_collision_mask_value"):
				barrier.set_collision_mask_value(1, false)

	_set_exits_locked(false)
	AudioManager.play_sfx("door_unlock")


func _set_exits_locked(locked: bool) -> void:
	for exit_path in door_exits:
		var exit := get_node_or_null(exit_path)
		if exit == null:
			continue

		if exit.has_method("set_locked"):
			exit.call("set_locked", locked)
			continue

		# Backward compatibility for scenes that still use plain Area2D exits.
		if exit is Area2D:
			if not locked and not exit.body_entered.is_connected(_on_legacy_exit_triggered):
				exit.body_entered.connect(_on_legacy_exit_triggered)
			if exit.has_node("Label"):
				var label := exit.get_node("Label")
				if label is Label:
					label.text = "← EXIT\n(unlocked)" if not locked else "← EXIT\n(locked)"


func _on_legacy_exit_triggered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	GameState.capture_player_state(body)
	SceneNavigator.goto_scene(get_tree().current_scene.scene_file_path, "spawn_default")


func _on_player_died() -> void:
	SceneNavigator.respawn_from_checkpoint()


func _remove_enemies() -> void:
	var enemies_container := get_node_or_null(enemies_node) if not enemies_node.is_empty() else null
	if enemies_container == null:
		return

	for child in enemies_container.get_children():
		child.queue_free()

	total_enemies = 0
	remaining_enemies = 0


func _find_player() -> Node:
	if not is_inside_tree():
		return null

	var tree := get_tree()
	if tree == null:
		return null

	for candidate in tree.get_nodes_in_group("player"):
		return candidate
	return null


func _update_ui() -> void:
	var counter := get_node_or_null(enemy_counter_label) if not enemy_counter_label.is_empty() else null
	if counter == null or not (counter is Label):
		return

	if is_cleared:
		counter.text = "Room Cleared"
		counter.modulate = Color(0.4, 1.0, 0.4, 1.0)
	else:
		counter.text = "Enemies Remaining: %d" % remaining_enemies
		counter.modulate = Color(1.0, 1.0, 1.0, 1.0)


func _get_combo_multiplier() -> int:
	if not GameState.has_method("get_combo_count"):
		return 1

	var combo_count := int(GameState.call("get_combo_count"))
	if combo_count >= 10:
		return 3
	if combo_count >= 5:
		return 2
	return 1
