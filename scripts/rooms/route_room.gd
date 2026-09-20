extends Node2D

const PLAYER_SCENE := preload("res://scenes/kaze.tscn")
const ECHO_SCENE := preload("res://scenes/enemies/echo.tscn")
const DRONE_SCENE := preload("res://scenes/enemies/drone.tscn")
const HUD_SCENE := preload("res://scenes/ui/hud.tscn")
const DISTRICT_TEXTURE := preload("res://rebuild/assets/district.png")
const TERRAIN_TEXTURE := preload("res://rebuild/assets/terrain.png")
const DOOR_SCRIPT := preload("res://scripts/rooms/door_exit.gd")
const ANCHOR_SCRIPT := preload("res://scripts/rooms/grapple_anchor.gd")
const WATER_SCRIPT := preload("res://scripts/rooms/water_zone.gd")
const KUNAI_GATE_SCRIPT := preload("res://scripts/rooms/kunai_gate.gd")
const ROOM_GRAPH := preload("res://scripts/rooms/room_graph.gd")

@export_range(5, 12) var room_index := 5

var room_names := {
	5: "Broken Span",
	6: "Wind Relay",
	7: "Reliquary Approach",
	8: "Canal Undercroft",
	9: "Conservatory Walk",
	10: "The Rootwell",
	11: "Hall of Borrowed Faces",
	12: "Borrowed Face Sanctum",
}
var enemy_counts := {5: 4, 6: 4, 7: 1, 8: 4, 9: 5, 10: 5, 11: 6, 12: 1}
var remaining_enemies := 0
var right_exit: Area2D
var room_id := ""
const EXIT_HEIGHTS := {5: 360.0, 6: 190.0, 7: 510.0, 8: 340.0, 9: 210.0, 10: 180.0, 11: 500.0, 12: 510.0}


func _ready() -> void:
	room_id = "room_%02d_route" % room_index
	GameState.visit_room(room_id)
	_build_background()
	_build_scenic_frame()
	_build_boundaries()
	_build_layout()
	_build_anchors()
	_build_water_if_needed()
	_build_kunai_gate_if_needed()
	_build_spawn_points()
	_build_player()
	_build_exits()
	_build_hud()
	_build_enemies()
	if room_index == 8:
		GameState.set_checkpoint(scene_file_path, "spawn_default")


func _build_background() -> void:
	var background := Sprite2D.new()
	var subterranean := room_index in [8, 10, 11, 12]
	background.texture = TERRAIN_TEXTURE if subterranean else DISTRICT_TEXTURE
	background.position = Vector2(640, 360)
	if subterranean:
		background.region_enabled = true
		background.region_rect = _terrain_region()
		background.scale = Vector2(1280.0 / 512.0, 720.0 / 512.0)
		background.modulate = Color(0.42, 0.48, 0.62, 0.86)
	else:
		background.scale = Vector2(1280.0 / 1536.0, 720.0 / 1024.0)
		background.modulate = Color(0.48, 0.44, 0.66, 0.86) if room_index < 9 else Color(0.45, 0.64, 0.48, 0.88)
	background.z_index = -20
	add_child(background)
	var shade := ColorRect.new()
	shade.position = Vector2.ZERO
	shade.size = Vector2(1280, 720)
	shade.color = Color(0.015, 0.02, 0.07, 0.30 if not subterranean else 0.44)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shade.z_index = -19
	add_child(shade)
	var title := Label.new()
	title.position = Vector2(76, 62)
	title.size = Vector2(500, 54)
	title.text = "SILENT DISTRICT  •  %s" % room_names[room_index].to_upper()
	title.add_theme_font_size_override("font_size", 19)
	title.modulate = Color(0.72, 0.94, 1.0, 0.90)
	title.z_index = 5
	add_child(title)


func _terrain_region() -> Rect2:
	if room_index in [8, 10]:
		return Rect2(512, 0, 512, 512)
	if room_index == 11:
		return Rect2(1024, 0, 512, 512)
	return Rect2(1024, 512, 512, 512)


func _build_scenic_frame() -> void:
	var subterranean := room_index in [8, 10, 11, 12]
	var frame_color := Color(0.035, 0.045, 0.09, 0.94) if not subterranean else Color(0.025, 0.035, 0.055, 0.96)
	_add_scenic_rect(Vector2(0, 0), Vector2(1280, 54 if not subterranean else 92), frame_color, -4)
	_add_scenic_rect(Vector2(0, 0), Vector2(58, 720), frame_color, -4)
	_add_scenic_rect(Vector2(1222, 0), Vector2(58, 720), frame_color, -4)
	if room_index in [5, 7, 9, 11]:
		_add_scenic_rect(Vector2(452, 120), Vector2(34, 580), Color(0.07, 0.08, 0.13, 0.82), -3)
		_add_scenic_rect(Vector2(930, 80), Vector2(30, 620), Color(0.07, 0.08, 0.13, 0.78), -3)
	if subterranean:
		_add_scenic_rect(Vector2(0, 548), Vector2(1280, 172), Color(0.015, 0.025, 0.05, 0.35), -2)


func _add_scenic_rect(position_value: Vector2, size: Vector2, color: Color, layer: int) -> void:
	var rect := ColorRect.new()
	rect.position = position_value
	rect.size = size
	rect.color = color
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.z_index = layer
	add_child(rect)


func _build_boundaries() -> void:
	_add_platform(Vector2(640, 700), Vector2(1280, 40), Color(0.10, 0.12, 0.20))
	_add_platform(Vector2(10, 360), Vector2(20, 720), Color(0.10, 0.12, 0.20))
	_add_platform(Vector2(1270, 360), Vector2(20, 720), Color(0.10, 0.12, 0.20))
	_add_platform(Vector2(640, 10), Vector2(1280, 20), Color(0.10, 0.12, 0.20))


func _build_layout() -> void:
	var layouts := {
		5: [[Vector2(250, 565), Vector2(260, 26)], [Vector2(610, 470), Vector2(240, 26)], [Vector2(970, 360), Vector2(250, 26)]],
		6: [[Vector2(220, 570), Vector2(230, 24)], [Vector2(480, 455), Vector2(200, 24)], [Vector2(750, 335), Vector2(210, 24)], [Vector2(1040, 220), Vector2(230, 24)]],
		7: [[Vector2(300, 530), Vector2(300, 28)], [Vector2(650, 410), Vector2(260, 28)], [Vector2(1020, 525), Vector2(280, 28)]],
		8: [[Vector2(245, 500), Vector2(300, 26)], [Vector2(640, 390), Vector2(250, 26)], [Vector2(1030, 505), Vector2(290, 26)]],
		9: [[Vector2(220, 560), Vector2(270, 25)], [Vector2(555, 455), Vector2(235, 25)], [Vector2(890, 350), Vector2(235, 25)], [Vector2(1100, 565), Vector2(190, 25)]],
		10: [[Vector2(255, 590), Vector2(240, 24)], [Vector2(510, 465), Vector2(190, 24)], [Vector2(760, 340), Vector2(190, 24)], [Vector2(1030, 215), Vector2(220, 24)]],
		11: [[Vector2(250, 520), Vector2(280, 26)], [Vector2(640, 420), Vector2(300, 26)], [Vector2(1030, 520), Vector2(280, 26)]],
		12: [[Vector2(350, 525), Vector2(300, 28)], [Vector2(930, 525), Vector2(300, 28)]],
	}
	for platform_data in layouts[room_index]:
		_add_platform(platform_data[0], platform_data[1], Color(0.16, 0.19, 0.29, 0.96))


func _add_platform(center: Vector2, size: Vector2, color: Color) -> void:
	var body := StaticBody2D.new()
	body.position = center
	body.collision_layer = 1
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	var visual := Sprite2D.new()
	visual.texture = TERRAIN_TEXTURE
	visual.region_enabled = true
	visual.region_rect = _terrain_region()
	visual.scale = size / Vector2(512.0, 512.0)
	visual.modulate = color.lightened(0.72)
	body.add_child(visual)
	var edge := ColorRect.new()
	edge.position = Vector2(-size.x * 0.5, -size.y * 0.5)
	edge.size = Vector2(size.x, 4)
	edge.color = Color(0.25, 0.84, 0.95, 0.85) if room_index < 9 else Color(0.48, 0.95, 0.55, 0.85)
	edge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(edge)
	add_child(body)


func _build_anchors() -> void:
	var positions := [Vector2(330, 250), Vector2(640, 160), Vector2(950, 260)]
	if room_index in [6, 10]:
		positions = [Vector2(290, 390), Vector2(550, 275), Vector2(820, 155), Vector2(1090, 105)]
	for anchor_position in positions:
		var anchor := Node2D.new()
		anchor.set_script(ANCHOR_SCRIPT)
		anchor.position = anchor_position
		add_child(anchor)


func _build_water_if_needed() -> void:
	if room_index not in [8, 10]:
		return
	var water := Area2D.new()
	water.set_script(WATER_SCRIPT)
	water.position = Vector2(640, 625)
	water.collision_layer = 0
	water.collision_mask = 2
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(1180, 150)
	collision.shape = shape
	water.add_child(collision)
	var visual := ColorRect.new()
	visual.position = Vector2(-590, -75)
	visual.size = Vector2(1180, 150)
	visual.color = Color(0.05, 0.35, 0.58, 0.52)
	visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	water.add_child(visual)
	add_child(water)


func _build_kunai_gate_if_needed() -> void:
	if room_index not in [8, 12]:
		return
	var gate := Area2D.new()
	gate.set_script(KUNAI_GATE_SCRIPT)
	gate.position = Vector2(1145, 545)
	gate.set("required_element", "fire" if room_index == 8 else "electric")
	gate.set("gate_id", "gate_%02d" % room_index)
	add_child(gate)


func _build_player() -> void:
	var player := PLAYER_SCENE.instantiate()
	player.name = "Kaze"
	player.position = Vector2(105, 625)
	add_child(player)
	GameState.apply_player_state(player)
	var camera := Camera2D.new()
	camera.position = Vector2(640, 360)
	camera.enabled = true
	add_child(camera)


func _build_spawn_points() -> void:
	var spawn_points := Node2D.new()
	spawn_points.name = "SpawnPoints"
	add_child(spawn_points)
	_add_spawn_marker(spawn_points, "spawn_default", Vector2(105, 625))
	for source_room_id in ROOM_GRAPH.incoming_rooms(room_id):
		var source_number := ROOM_GRAPH.room_number(source_room_id)
		var spawn_position := Vector2(105, 625)
		if source_number > room_index:
			spawn_position = Vector2(1175, EXIT_HEIGHTS[room_index])
		_add_spawn_marker(spawn_points, ROOM_GRAPH.entry_marker_from(source_room_id), spawn_position)


func _add_spawn_marker(parent: Node2D, marker_name: String, marker_position: Vector2) -> void:
	var marker := Marker2D.new()
	marker.name = marker_name
	marker.position = marker_position
	parent.add_child(marker)


func _build_exits() -> void:
	var previous_room_id := ROOM_GRAPH.room_id_for_index(room_index - 1)
	_add_exit(Vector2(32, 560), previous_room_id, "← BACK")
	if room_index < 12:
		var next_room_id := ROOM_GRAPH.room_id_for_index(room_index + 1)
		right_exit = _add_exit(Vector2(1248, EXIT_HEIGHTS[room_index]), next_room_id, "NEXT →")
	else:
		right_exit = _add_exit(Vector2(1248, EXIT_HEIGHTS[room_index]), ROOM_GRAPH.room_id_for_index(5), "LOOP →")


func _add_exit(position_value: Vector2, target_room_id: String, prompt: String) -> Area2D:
	var exit := Area2D.new()
	exit.set_script(DOOR_SCRIPT)
	exit.position = position_value
	exit.collision_layer = 0
	exit.collision_mask = 2
	exit.set("target_scene_path", ROOM_GRAPH.scene_for_room(target_room_id))
	exit.set("target_spawn_marker", ROOM_GRAPH.entry_marker_from(room_id))
	exit.set("door_prompt_text", prompt)
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(54, 230)
	collision.shape = shape
	exit.add_child(collision)
	var label := Label.new()
	label.name = "Label"
	label.position = Vector2(-70, -145)
	label.size = Vector2(140, 60)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.text = prompt
	exit.add_child(label)
	add_child(exit)
	return exit


func _build_hud() -> void:
	var hud := HUD_SCENE.instantiate()
	add_child(hud)


func _build_enemies() -> void:
	if GameState.is_room_cleared(room_id):
		remaining_enemies = 0
		return
	var count: int = enemy_counts[room_index]
	remaining_enemies = count
	for index in count:
		var enemy = ECHO_SCENE.instantiate() if index % 3 != 2 or room_index == 12 else DRONE_SCENE.instantiate()
		enemy.position = Vector2(310 + (index % 4) * 220, 610 - (index % 2) * 120)
		if room_index in [7, 12]:
			enemy.name = "StormReliquary" if room_index == 7 else "BorrowedFace"
			enemy.scale = Vector2(1.45, 1.45) if room_index == 7 else Vector2(1.65, 1.65)
			var boss_health := enemy.get_node("Health")
			boss_health.max_health = 180.0 if room_index == 7 else 280.0
			boss_health.current_health = boss_health.max_health
		var health := enemy.get_node("Health")
		health.died.connect(_on_enemy_died)
		add_child(enemy)
	_lock_right_exit(true)
	_update_enemy_hud()


func _on_enemy_died() -> void:
	remaining_enemies = maxi(0, remaining_enemies - 1)
	GameState.add_cells(10 if room_index < 12 else 100)
	if remaining_enemies == 0:
		GameState.mark_room_cleared(room_id)
		if room_index == 7:
			GameState.unlock_ability(GameState.ABILITY_FIRE_KUNAI)
		elif room_index == 11:
			GameState.unlock_ability(GameState.ABILITY_ELECTRIC_KUNAI)
		if room_index == 12:
			GameState.unlock_ability("guard_veil")
		_lock_right_exit(false)
	_update_enemy_hud()


func _lock_right_exit(locked: bool) -> void:
	if right_exit and right_exit.has_method("set_locked"):
		right_exit.call("set_locked", locked)


func _update_enemy_hud() -> void:
	var counter := get_node_or_null("HUD/EnemyCounter") as Label
	if counter == null:
		return
	if remaining_enemies <= 0:
		counter.text = "ROOM CLEARED"
		counter.modulate = Color(0.45, 1.0, 0.55)
	elif room_index == 7:
		counter.text = "STORM RELIQUARY // %d" % remaining_enemies
		counter.modulate = Color(0.4, 0.9, 1.0)
	elif room_index == 12:
		counter.text = "THE BORROWED FACE"
		counter.modulate = Color(1.0, 0.45, 0.65)
	else:
		counter.text = "HOSTILES // %d" % remaining_enemies
