@tool
extends EditorScript

## Room JSON Importer
## Converts web editor JSON (from fractured-room-editor.html) to Godot .tscn files
##
## Usage:
## 1. Design room at https://laibyrinth.com/fractured-room-editor.html
## 2. Export JSON, save to tools/room_import.json
## 3. Run this script in Godot (File → Run)
## 4. Scene saved to scenes/rooms/[room_name].tscn

const INPUT_JSON := "res://tools/room_import.json"
const OUTPUT_DIR := "res://scenes/rooms/"

func _run():
	print("=== Room JSON Importer ===")
	
	if not FileAccess.file_exists(INPUT_JSON):
		printerr("Error: %s not found" % INPUT_JSON)
		printerr("Save JSON from web editor as tools/room_import.json")
		return
	
	var json_text := FileAccess.get_file_as_string(INPUT_JSON)
	var json := JSON.new()
	var error := json.parse(json_text)
	
	if error != OK:
		printerr("Error parsing JSON: %s" % json.get_error_message())
		return
	
	var data: Dictionary = json.data
	_import_room(data)

func _import_room(data: Dictionary):
	var room_name := data.get("name", "imported_room")
	var biome := data.get("biome", "shibuya")
	
	print("Importing room: %s (biome: %s)" % [room_name, biome])
	
	# Create root node
	var room := Node2D.new()
	room.name = room_name.capitalize().replace(" ", "")
	
	# Add RoomController script
	var controller := Node2D.new()
	controller.name = "RoomController"
	controller.set_script(load("res://scripts/rooms/room_controller.gd"))
	room.add_child(controller)
	controller.owner = room
	
	# Environment group
	var env := Node2D.new()
	env.name = "Environment"
	room.add_child(env)
	env.owner = room
	
	# Platforms
	var platforms: Array = data.get("platforms", [])
	for p in platforms:
		_create_platform(env, room, p)
	
	# Moving platforms
	var moving: Array = data.get("movingPlatforms", [])
	for m in moving:
		_create_moving_platform(env, room, m)
	
	# Breakable platforms
	var breakable: Array = data.get("breakablePlatforms", [])
	for b in breakable:
		_create_breakable_platform(env, room, b)
	
	# One-way platforms
	var oneway: Array = data.get("onewayPlatforms", [])
	for o in oneway:
		_create_oneway_platform(env, room, o)
	
	# Enemies group
	var enemies_group := Node2D.new()
	enemies_group.name = "Enemies"
	room.add_child(enemies_group)
	enemies_group.owner = room
	
	var enemies: Array = data.get("enemies", [])
	for e in enemies:
		_create_enemy(enemies_group, room, e)
	
	# Hazards
	var hazards: Array = data.get("hazards", [])
	for h in hazards:
		_create_hazard(env, room, h)
	
	# Grapple points
	var grapple_points: Array = data.get("grapplePoints", [])
	for g in grapple_points:
		_create_grapple_point(env, room, g)
	
	# Checkpoints
	var checkpoints: Array = data.get("checkpoints", [])
	for c in checkpoints:
		_create_checkpoint(env, room, c)
	
	# Save scene
	var scene := PackedScene.new()
	scene.pack(room)
	
	var output_path := OUTPUT_DIR + room_name + ".tscn"
	var save_error := ResourceSaver.save(scene, output_path)
	
	if save_error == OK:
		print("✅ Room saved: %s" % output_path)
	else:
		printerr("❌ Failed to save room: error %d" % save_error)

func _create_platform(parent: Node, root: Node, data: Dictionary):
	var platform := StaticBody2D.new()
	platform.name = "Platform_%d" % parent.get_child_count()
	platform.position = Vector2(data.x, data.y)
	platform.collision_layer = 1
	
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(data.w, data.h)
	collision.shape = shape
	collision.position = Vector2(data.w / 2, data.h / 2)
	platform.add_child(collision)
	collision.owner = root
	
	var visual := ColorRect.new()
	visual.size = Vector2(data.w, data.h)
	visual.color = _get_platform_color(data.get("type", "Solid"))
	platform.add_child(visual)
	visual.owner = root
	
	parent.add_child(platform)
	platform.owner = root

func _create_moving_platform(parent: Node, root: Node, data: Dictionary):
	# TODO: Implement AnimatableBody2D with movement script
	_create_platform(parent, root, data)

func _create_breakable_platform(parent: Node, root: Node, data: Dictionary):
	# TODO: Implement breakable platform with health
	_create_platform(parent, root, data)

func _create_oneway_platform(parent: Node, root: Node, data: Dictionary):
	# TODO: Implement one-way collision
	_create_platform(parent, root, data)

func _create_enemy(parent: Node, root: Node, data: Dictionary):
	var enemy_type := data.get("type", "Echo").to_lower()
	var scene_path := "res://scenes/enemies/%s.tscn" % enemy_type
	
	if not FileAccess.file_exists(scene_path):
		printerr("Enemy scene not found: %s" % scene_path)
		return
	
	var enemy_scene: PackedScene = load(scene_path)
	var enemy := enemy_scene.instantiate()
	enemy.position = Vector2(data.x, data.y)
	
	parent.add_child(enemy)
	enemy.owner = root

func _create_hazard(parent: Node, root: Node, data: Dictionary):
	var hazard := Area2D.new()
	hazard.name = "Hazard_%s" % data.get("type", "Generic")
	hazard.position = Vector2(data.x, data.y)
	hazard.collision_layer = 0
	hazard.collision_mask = 2  # Player layer
	
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 20
	collision.shape = shape
	hazard.add_child(collision)
	collision.owner = root
	
	# Add hazard script
	hazard.set_script(load("res://scripts/rooms/hazard_zone.gd"))
	hazard.set("damage", 10.0)
	
	parent.add_child(hazard)
	hazard.owner = root

func _create_grapple_point(parent: Node, root: Node, data: Dictionary):
	var marker := Marker2D.new()
	marker.name = "GrapplePoint_%d" % parent.get_child_count()
	marker.position = Vector2(data.x, data.y)
	
	parent.add_child(marker)
	marker.owner = root

func _create_checkpoint(parent: Node, root: Node, data: Dictionary):
	var checkpoint := Area2D.new()
	checkpoint.name = "Checkpoint"
	checkpoint.position = Vector2(data.x, data.y)
	checkpoint.collision_layer = 0
	checkpoint.collision_mask = 2
	
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(32, 32)
	collision.shape = shape
	checkpoint.add_child(collision)
	collision.owner = root
	
	checkpoint.set_script(load("res://scripts/rooms/checkpoint.gd"))
	
	parent.add_child(checkpoint)
	checkpoint.owner = root

func _get_platform_color(type: String) -> Color:
	match type:
		"Solid": return Color(0.17, 0.17, 0.24)
		"Wood": return Color(0.4, 0.25, 0.1)
		"Stone": return Color(0.3, 0.3, 0.35)
		"Metal": return Color(0.5, 0.5, 0.55)
		"Ice": return Color(0.7, 0.85, 1.0)
		"Bamboo": return Color(0.3, 0.5, 0.2)
		_: return Color(0.2, 0.2, 0.25)
