@tool
extends EditorScript

## Room JSON Importer
## Converts web editor JSON into a playable room scene that matches project conventions.

const INPUT_JSON := "res://tools/room_import.json"
const OUTPUT_DIR := "res://scenes/rooms/"

const KAZE_SCENE := preload("res://scenes/kaze.tscn")
const HUD_SCENE := preload("res://scenes/ui/hud.tscn")
const ECHO_SCENE := preload("res://scenes/enemies/echo.tscn")
const ROOM_CONTROLLER_SCRIPT := preload("res://scripts/rooms/room_controller.gd")
const ROOM_CAMERA_SCRIPT := preload("res://scripts/camera/room_camera.gd")
const HAZARD_SCRIPT := preload("res://scripts/rooms/hazard_zone.gd")
const CHECKPOINT_SCRIPT := preload("res://scripts/rooms/checkpoint.gd")
const MOVING_PLATFORM_SCRIPT := preload("res://scripts/rooms/moving_platform.gd")
const SPIN_VISUAL_SCRIPT := preload("res://scripts/rooms/spin_visual.gd")


func _run() -> void:
	print("=== Room JSON Importer ===")

	if not FileAccess.file_exists(INPUT_JSON):
		printerr("Error: %s not found" % INPUT_JSON)
		printerr("Save JSON from the web editor as tools/room_import.json")
		return

	var json_text := FileAccess.get_file_as_string(INPUT_JSON)
	var json := JSON.new()
	var error := json.parse(json_text)
	if error != OK:
		printerr("Error parsing JSON: %s" % json.get_error_message())
		return
	if not (json.data is Dictionary):
		printerr("Error: root JSON payload must be a dictionary")
		return

	var data := json.data as Dictionary
	var output_path := _import_room(data)
	if output_path.is_empty():
		return

	print("Room saved: %s" % output_path)


func _import_room(data: Dictionary) -> String:
	var room_name := _room_name_from_data(data)
	var room_id := _snake_case(room_name)
	var width := maxf(_float_value(data, "width", 1280.0), 640.0)
	var height := maxf(_float_value(data, "height", 720.0), 480.0)

	var room := Node2D.new()
	room.name = _scene_name(room_name)
	room.set_script(ROOM_CONTROLLER_SCRIPT)
	room.set("room_id", room_id)
	room.set("player_node", NodePath("Kaze"))
	room.set("enemies_node", NodePath("Enemies"))
	room.set("enemy_counter_label", NodePath("HUD/EnemyCounter"))

	var camera := Camera2D.new()
	camera.name = "RoomCamera"
	camera.position = Vector2(width * 0.5, height * 0.5)
	camera.set_script(ROOM_CAMERA_SCRIPT)
	camera.set("player_path", NodePath("../Kaze"))
	camera.set("room_bounds", Rect2(0, 0, width, height))
	room.add_child(camera)
	camera.owner = room

	var spawn_points := Node2D.new()
	spawn_points.name = "SpawnPoints"
	room.add_child(spawn_points)
	spawn_points.owner = room

	var spawn_default := Marker2D.new()
	spawn_default.name = "spawn_default"
	spawn_default.position = _default_spawn(data, width, height)
	spawn_points.add_child(spawn_default)
	spawn_default.owner = room

	var environment := Node2D.new()
	environment.name = "Environment"
	room.add_child(environment)
	environment.owner = room

	var enemies := Node2D.new()
	enemies.name = "Enemies"
	room.add_child(enemies)
	enemies.owner = room

	_add_room_bounds(environment, room, width, height)

	for platform_data in _array_value(data, "platforms"):
		_create_platform(environment, room, platform_data)

	for platform_data in _array_value(data, "movingPlatforms"):
		_create_moving_platform(environment, room, platform_data)

	for platform_data in _array_value(data, "breakablePlatforms"):
		_create_breakable_platform(environment, room, platform_data)

	for platform_data in _array_value(data, "onewayPlatforms"):
		_create_oneway_platform(environment, room, platform_data)

	for enemy_data in _array_value(data, "enemies"):
		_create_enemy(enemies, room, enemy_data)

	for hazard_data in _array_value(data, "hazards"):
		_create_hazard(environment, room, hazard_data)

	for grapple_data in _array_value(data, "grapplePoints"):
		_create_grapple_point(environment, room, grapple_data)

	for checkpoint_data in _array_value(data, "checkpoints"):
		_create_checkpoint(environment, spawn_points, room, checkpoint_data)

	var player := KAZE_SCENE.instantiate()
	player.name = "Kaze"
	player.position = spawn_default.position
	room.add_child(player)
	player.owner = room

	var hud := HUD_SCENE.instantiate()
	hud.name = "HUD"
	room.add_child(hud)
	hud.owner = room

	var scene := PackedScene.new()
	var pack_error := scene.pack(room)
	if pack_error != OK:
		printerr("Failed to pack room scene: error %d" % pack_error)
		return ""

	var output_path := OUTPUT_DIR + room_id + ".tscn"
	var save_error := ResourceSaver.save(scene, output_path)
	if save_error != OK:
		printerr("Failed to save room scene: error %d" % save_error)
		return ""
	return output_path


func _add_room_bounds(environment: Node2D, root: Node, width: float, height: float) -> void:
	_create_rect_body(environment, root, "Floor", Vector2(width * 0.5, height - 40.0), Vector2(width, 80.0), Color(0.12, 0.16, 0.24, 1.0))
	_create_rect_body(environment, root, "Ceiling", Vector2(width * 0.5, 40.0), Vector2(width, 80.0), Color(0.12, 0.16, 0.24, 1.0))
	_create_rect_body(environment, root, "LeftWall", Vector2(40.0, height * 0.5), Vector2(80.0, height), Color(0.12, 0.16, 0.24, 1.0))
	_create_rect_body(environment, root, "RightWall", Vector2(width - 40.0, height * 0.5), Vector2(80.0, height), Color(0.12, 0.16, 0.24, 1.0))


func _create_rect_body(parent: Node, root: Node, name: String, body_position: Vector2, size: Vector2, color: Color) -> void:
	var body := StaticBody2D.new()
	body.name = name
	body.position = body_position
	body.collision_layer = 1

	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	collision.owner = root

	var visual := ColorRect.new()
	visual.offset_left = -size.x * 0.5
	visual.offset_top = -size.y * 0.5
	visual.offset_right = size.x * 0.5
	visual.offset_bottom = size.y * 0.5
	visual.color = color
	body.add_child(visual)
	visual.owner = root

	parent.add_child(body)
	body.owner = root


func _create_platform(parent: Node, root: Node, data: Dictionary) -> void:
	var size := _platform_size(data)
	var center := _platform_center(data)
	_create_rect_body(parent, root, "Platform_%d" % parent.get_child_count(), center, size, _get_platform_color(_string_value(data, "type", "Solid")))


func _create_moving_platform(parent: Node, root: Node, data: Dictionary) -> void:
	var platform := AnimatableBody2D.new()
	platform.name = "MovingPlatform_%d" % parent.get_child_count()
	platform.position = _platform_center(data)
	platform.collision_layer = 1
	platform.set_script(MOVING_PLATFORM_SCRIPT)

	var move_x := _float_value(data, "moveX", 120.0)
	var speed := maxf(_float_value(data, "speed", 1.0), 0.1)
	platform.set("travel_offset", Vector2(move_x, 0.0))
	platform.set("cycle_duration", clampf(absf(move_x) / (110.0 * speed), 1.2, 4.0))

	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = _platform_size(data)
	collision.shape = shape
	platform.add_child(collision)
	collision.owner = root

	var visual := ColorRect.new()
	visual.offset_left = -shape.size.x * 0.5
	visual.offset_top = -shape.size.y * 0.5
	visual.offset_right = shape.size.x * 0.5
	visual.offset_bottom = shape.size.y * 0.5
	visual.color = Color(0.2, 0.5, 0.68, 1.0)
	platform.add_child(visual)
	visual.owner = root

	parent.add_child(platform)
	platform.owner = root


func _create_breakable_platform(parent: Node, root: Node, data: Dictionary) -> void:
	_create_rect_body(parent, root, "BreakablePlatform_%d" % parent.get_child_count(), _platform_center(data), _platform_size(data), Color(0.45, 0.33, 0.18, 1.0))


func _create_oneway_platform(parent: Node, root: Node, data: Dictionary) -> void:
	_create_rect_body(parent, root, "OneWayPlatform_%d" % parent.get_child_count(), _platform_center(data), _platform_size(data), Color(0.36, 0.55, 0.28, 1.0))


func _create_enemy(parent: Node, root: Node, data: Dictionary) -> void:
	var enemy_type := _string_value(data, "type", "Echo").to_lower()
	var enemy := ECHO_SCENE.instantiate() if enemy_type == "echo" else null
	if enemy == null:
		printerr("Unsupported enemy type: %s" % enemy_type)
		return

	enemy.position = Vector2(_float_value(data, "x", 0.0), _float_value(data, "y", 0.0))
	parent.add_child(enemy)
	enemy.owner = root


func _create_hazard(parent: Node, root: Node, data: Dictionary) -> void:
	var hazard_type := _string_value(data, "type", "Saw").to_lower()
	var hazard := Area2D.new()
	hazard.name = "Hazard_%s_%d" % [hazard_type.capitalize(), parent.get_child_count()]
	hazard.position = Vector2(_float_value(data, "x", 0.0), _float_value(data, "y", 0.0))
	hazard.collision_layer = 0
	hazard.collision_mask = 2
	hazard.set_script(HAZARD_SCRIPT)

	var collision := CollisionShape2D.new()
	if hazard_type == "saw":
		var circle := CircleShape2D.new()
		circle.radius = 36.0
		collision.shape = circle
		hazard.set("damage", 35.0)
		hazard.set("instant_kill", false)

		var spinner := Node2D.new()
		spinner.name = "Spinner"
		spinner.set_script(SPIN_VISUAL_SCRIPT)
		hazard.add_child(spinner)
		spinner.owner = root

		var visual := Polygon2D.new()
		visual.polygon = PackedVector2Array([Vector2(0, -36), Vector2(12, -12), Vector2(36, 0), Vector2(12, 12), Vector2(0, 36), Vector2(-12, 12), Vector2(-36, 0), Vector2(-12, -12)])
		visual.color = Color(0.92, 0.92, 0.98, 0.95)
		spinner.add_child(visual)
		visual.owner = root
	else:
		var rect := RectangleShape2D.new()
		rect.size = Vector2(140.0, 80.0)
		collision.shape = rect
		hazard.set("instant_kill", true)

		var visual_rect := ColorRect.new()
		visual_rect.offset_left = -70.0
		visual_rect.offset_top = -40.0
		visual_rect.offset_right = 70.0
		visual_rect.offset_bottom = 40.0
		visual_rect.color = Color(0.8, 0.18, 0.22, 0.72)
		hazard.add_child(visual_rect)
		visual_rect.owner = root

	hazard.add_child(collision)
	collision.owner = root

	parent.add_child(hazard)
	hazard.owner = root


func _create_grapple_point(parent: Node, root: Node, data: Dictionary) -> void:
	var marker := Marker2D.new()
	marker.name = "GrapplePoint_%d" % parent.get_child_count()
	marker.position = Vector2(_float_value(data, "x", 0.0), _float_value(data, "y", 0.0))
	parent.add_child(marker)
	marker.owner = root


func _create_checkpoint(parent: Node, spawn_points: Node, root: Node, data: Dictionary) -> void:
	var spawn_name := "spawn_checkpoint_%d" % spawn_points.get_child_count()
	var checkpoint := Area2D.new()
	checkpoint.name = "Checkpoint_%d" % parent.get_child_count()
	checkpoint.position = Vector2(_float_value(data, "x", 0.0), _float_value(data, "y", 0.0))
	checkpoint.collision_layer = 0
	checkpoint.collision_mask = 2
	checkpoint.set_script(CHECKPOINT_SCRIPT)
	checkpoint.set("checkpoint_spawn_marker", spawn_name)

	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(180.0, 120.0)
	collision.shape = shape
	checkpoint.add_child(collision)
	collision.owner = root

	var visual := ColorRect.new()
	visual.offset_left = -90.0
	visual.offset_top = -60.0
	visual.offset_right = 90.0
	visual.offset_bottom = 60.0
	visual.color = Color(0.2, 0.9, 0.65, 0.45)
	checkpoint.add_child(visual)
	visual.owner = root

	var label := Label.new()
	label.name = "Label"
	label.offset_left = -96.0
	label.offset_top = -42.0
	label.offset_right = 96.0
	label.offset_bottom = 42.0
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.text = "CHECKPOINT"
	checkpoint.add_child(label)
	label.owner = root

	parent.add_child(checkpoint)
	checkpoint.owner = root

	var spawn_marker := Marker2D.new()
	spawn_marker.name = spawn_name
	spawn_marker.position = checkpoint.position + Vector2(0.0, 40.0)
	spawn_points.add_child(spawn_marker)
	spawn_marker.owner = root


func _room_name_from_data(data: Dictionary) -> String:
	var provided_name := _string_value(data, "name", "")
	if not provided_name.is_empty():
		return provided_name
	return "%s_import" % _string_value(data, "biome", "room")


func _scene_name(room_name: String) -> String:
	var parts := _snake_case(room_name).split("_", false)
	var built := ""
	for part in parts:
		built += part.capitalize()
	return built


func _snake_case(value: String) -> String:
	return value.strip_edges().to_lower().replace(" ", "_").replace("-", "_")


func _default_spawn(data: Dictionary, width: float, height: float) -> Vector2:
	var platforms := _array_value(data, "platforms")
	if not platforms.is_empty():
		var first_platform := platforms[0] as Dictionary
		return Vector2(_float_value(first_platform, "x", 80.0) + 40.0, _float_value(first_platform, "y", height - 120.0) - 40.0)
	return Vector2(minf(160.0, width * 0.25), height - 120.0)


func _platform_center(data: Dictionary) -> Vector2:
	var size := _platform_size(data)
	return Vector2(_float_value(data, "x", 0.0) + size.x * 0.5, _float_value(data, "y", 0.0) + size.y * 0.5)


func _platform_size(data: Dictionary) -> Vector2:
	return Vector2(maxf(_float_value(data, "w", 160.0), 20.0), maxf(_float_value(data, "h", 20.0), 10.0))


func _array_value(data: Dictionary, key: String) -> Array:
	var value = data.get(key, [])
	return value if value is Array else []


func _string_value(data: Dictionary, key: String, fallback: String) -> String:
	return String(data.get(key, fallback))


func _float_value(data: Dictionary, key: String, fallback: float) -> float:
	var value = data.get(key, fallback)
	if value is int or value is float:
		return float(value)
	var parsed := String(value).to_float()
	return parsed if not is_zero_approx(parsed) or String(value) == "0" else fallback


func _get_platform_color(platform_type: String) -> Color:
	match platform_type:
		"Wood":
			return Color(0.45, 0.32, 0.18, 1.0)
		"Stone":
			return Color(0.33, 0.33, 0.38, 1.0)
		"Metal":
			return Color(0.48, 0.5, 0.58, 1.0)
		"Ice":
			return Color(0.7, 0.85, 1.0, 1.0)
		"Bamboo":
			return Color(0.3, 0.5, 0.2, 1.0)
		_:
			return Color(0.17, 0.17, 0.24, 1.0)
