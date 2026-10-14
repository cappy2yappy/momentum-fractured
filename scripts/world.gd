extends Node2D

const Player = preload("res://scripts/player.gd")
const Guard = preload("res://scripts/guard.gd")
const Kunai = preload("res://scripts/kunai.gd")
const Hud = preload("res://scripts/hud.gd")
const DistrictBackground = preload("res://assets/web/district-fidelity.png")

const Extension = preload("res://scripts/route_extension.gd")
const Expansion = preload("res://scripts/world_expansion.gd")
const ROOM_COUNT = 21
const ROOM_NAMES = [
	"CANAL HAVEN", "LANTERN MARKET", "FLOODED CISTERN", "ECHO SHRINE",
	"BROKEN SPAN", "ASCENT TOWER", "TIDE WARDEN", "RELAY ARCHIVE",
	"RELAY UNDERCROFT", "SIGNAL TERRACE",
	"SKYWORKS APPROACH", "STORM FOUNDRY", "KEEPER RELAY",
	"MOORING LOFT", "BELLROOF WALK", "LOWER SLUICE", "ROOT SHRINE",
	"COUNTERWEIGHT SPIRE", "PUMP GALLERY", "COIL SERVICE HALL", "RELAY JUNCTION",
]
const ROOM_COLORS = [
	Color("211e32"), Color("2b2030"), Color("172a35"), Color("29233b"),
	Color("182837"), Color("242139"), Color("241c2d"), Color("1d2934"),
	Color("202939"), Color("29243a"),
	Color("283442"), Color("39283a"), Color("28283e"),
	Color("292434"),Color("302b3b"),Color("1b2a30"),Color("26352e"),
	Color("282c39"),Color("30352e"),Color("30313f"),Color("29372f"),
]
const ROOM_MAP_COORDS = [
	Vector3i(0, 2, 0), Vector3i(1, 2, 0), Vector3i(2, 2, 0), Vector3i(2, 1, 0),
	Vector3i(3, 1, 0), Vector3i(4, 1, 0), Vector3i(4, 0, 0), Vector3i(5, 0, 0),
	Vector3i(5, 1, 0), Vector3i(6, 1, 0),
	Vector3i(6, 0, 0), Vector3i(7, 0, 0), Vector3i(7, 1, 0),
	Vector3i(-1,2,0),Vector3i(-1,1,0),Vector3i(2,3,0),Vector3i(3,3,0),
	Vector3i(4,2,0),Vector3i(4,3,0),Vector3i(5,3,0),Vector3i(5,2,0),
]
const ROOM_REGIONS = ["CANAL WARD", "CANAL WARD", "CANAL WARD", "ECHO WORKS", "ECHO WORKS", "ECHO WORKS", "STORM KEEP", "STORM KEEP", "ECHO WORKS", "STORM KEEP", "SKYWORKS", "SKYWORKS", "SKYWORKS", "CANAL WARD", "CANAL WARD", "CANAL WARD", "ROOT CONSERVATORY", "ECHO WORKS", "ROOT CONSERVATORY", "SKYWORKS", "ROOT CONSERVATORY"]

var save_path = "user://silent_district_alpha_v3.json"
var player
var guard
var active_enemy
var enemies: Array = []
var kunai_gates: Array = []
var opened_kunai_gates: Dictionary = {}
var camera = Camera2D.new()
var geometry = Node2D.new()
var room = 0
var visited = [true,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false]
var expansion = Expansion.new()
var expansion_flags: Dictionary = {}
var guard_defeated = false
var boss_defeated = false
var completed = false
var skyworks_restored = false
var secret = false
var checkpoint_room = 0
var checkpoint_position = Vector2(220, 1298)
var relay_fragments: Dictionary = {}
var cleared_encounters: Dictionary = {}
var pending_arrival = Vector2.INF
var extension = Extension.new()
var platforms: Array[Rect2] = []
var tether_anchors: Array[Vector2] = []
var tether_effect_anchor = Vector2.ZERO
var tether_effect_time = 0.0
var afterimages_spawned = 0
var metsys_progress: Dictionary = {}
var metsys
var hud
var message = "The rooftop relay is dark. Follow the canal route east."
var message_time = 7.0
var transition = 0.0
var pending_room = -1
var pending_from_room = 0
var test_mode = false
var fall_recovering = false

func _ready():
	test_mode = "--test" in OS.get_cmdline_user_args()
	metsys = get_node("/root/MetSys")
	metsys.reset_state()
	metsys.set_save_data()
	configure_input()
	add_child(geometry)
	player = Player.new()
	add_child(player)
	player.strike.connect(on_strike)
	player.hurt.connect(on_hurt)
	player.tether_requested.connect(on_tether_requested)
	player.afterimage_requested.connect(spawn_dash_afterimage)
	player.kunai_requested.connect(spawn_kunai)
	player.add_child(camera)
	camera.position.y = -110
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 8
	camera.limit_left = 0;camera.limit_right = 2600
	camera.limit_top = 0;camera.limit_bottom = 1440
	var layer = CanvasLayer.new()
	add_child(layer)
	hud = Hud.new()
	hud.world = self
	layer.add_child(hud)
	if not test_mode: load_progress()
	player.momentum.enabled = "--momentum-prototype" in OS.get_cmdline_user_args() or "--momentum" in OS.get_cmdline_user_args()
	register_metsys_progress()
	build_room(checkpoint_room)
	player.position = checkpoint_position
	camera.reset_smoothing()

func configure_input():
	var keys = {
		"left": [KEY_A, KEY_LEFT], "right": [KEY_D, KEY_RIGHT],
		"jump": [KEY_SPACE, KEY_W, KEY_UP], "attack": [KEY_J],
		"parry": [KEY_F, KEY_K], "interact": [KEY_E], "map": [KEY_M],
		"pause": [KEY_ESCAPE], "loadout": [KEY_I], "tether": [KEY_Q], "dash": [KEY_SHIFT],
		"kunai": [KEY_R], "cycle_kunai": [KEY_T],
	}
	for action in keys:
		if not InputMap.has_action(action): InputMap.add_action(action)
		for key in keys[action]:
			var event = InputEventKey.new();event.physical_keycode = key
			InputMap.action_add_event(action, event)
	for pair in [["attack", MOUSE_BUTTON_LEFT], ["parry", MOUSE_BUTTON_RIGHT]]:
		var event = InputEventMouseButton.new();event.button_index = pair[1]
		InputMap.action_add_event(pair[0], event)

func build_room(index):
	reset_room_actions()
	for child in get_children():
		if child.get_script() == Kunai or child.is_in_group("route_afterimage"):
			child.queue_free()
	room = clampi(index, 0, ROOM_COUNT - 1)
	visited[room] = true
	sync_metsys_room(room)
	for child in geometry.get_children():
		geometry.remove_child(child);child.queue_free()
	for enemy in enemies:
		if is_instance_valid(enemy): enemy.queue_free()
	enemies.clear()
	active_enemy = null
	guard = null
	platforms.clear()
	tether_anchors.clear()
	kunai_gates.clear()
	var bounds = room_size(room)
	camera.limit_right = int(bounds.x);camera.limit_bottom = int(bounds.y)
	for rect in [Rect2(-40, 0, 40, bounds.y), Rect2(bounds.x, 0, 40, bounds.y)]: add_platform(rect)
	var floor_segments = [Rect2(0, bounds.y - 140, bounds.x, 140)]
	if room == 2:
		floor_segments = [Rect2(0, 1300, 640, 140), Rect2(930, 1300, 420, 140), Rect2(1680, 1300, 520, 140), Rect2(2380, 1300, 220, 140)]
	elif room == 4:
		floor_segments = [Rect2(0, 1300, 450, 140), Rect2(1000, 1300, 280, 140), Rect2(2050, 1300, 550, 140)]
	elif room == 5:
		floor_segments = [Rect2(0, 1300, 500, 140), Rect2(780, 1300, 720, 140), Rect2(1850, 1300, 750, 140)]
	for rect in floor_segments: add_platform(rect)
	match room:
		0:
			for rect in [Rect2(480, 1110, 300, 40), Rect2(860, 780, 420, 48), Rect2(260, 780, 390, 48), Rect2(1400, 1080, 300, 40), Rect2(1850, 900, 300, 40)]: add_platform(rect)
		1:
			for rect in [Rect2(370, 1120, 280, 40), Rect2(790, 950, 330, 40), Rect2(1450, 1080, 300, 40), Rect2(1800, 900, 270, 40), Rect2(2140, 720, 320, 40)]: add_platform(rect)
			if not guard_defeated:
				spawn_enemy(Vector2(1100, 1300), false, true)
				spawn_enemy(Vector2(520, 1120), false)
				spawn_enemy(Vector2(1900, 900), false)
		2:
			for rect in [Rect2(330, 1120, 260, 40), Rect2(710, 940, 280, 40), Rect2(1090, 1100, 300, 40), Rect2(1510, 870, 300, 40), Rect2(1980, 1050, 250, 40), Rect2(2220, 850, 260, 40)]: add_platform(rect)
			spawn_enemy(Vector2(1190, 1100), false)
			create_kunai_gate("cistern_wind_cache", "wind", Vector2(2150, 850), 250)
		3:
			for rect in [Rect2(0, 850, 300, 40), Rect2(420, 1060, 330, 40), Rect2(920, 830, 360, 40), Rect2(1480, 1030, 340, 40), Rect2(2000, 790, 340, 40)]: add_platform(rect)
			tether_anchors = [Vector2(1090, 650), Vector2(2170, 610)]
		4:
			for rect in [Rect2(300, 1110, 310, 40), Rect2(930, 1030, 270, 40), Rect2(1530, 890, 270, 40), Rect2(2130, 1080, 270, 40)]: add_platform(rect)
			tether_anchors = [Vector2(780, 720), Vector2(1370, 610), Vector2(1940, 650)]
			spawn_enemy(Vector2(1080, 1030), false)
			spawn_enemy(Vector2(1660, 890), false)
			create_kunai_gate("span_fire_cache", "fire", Vector2(1990, 1080), 270)
		5:
			for rect in [Rect2(0, 1080, 280, 40), Rect2(300, 1110, 280, 40), Rect2(680, 900, 280, 40), Rect2(1030, 680, 280, 40), Rect2(1390, 930, 280, 40), Rect2(1760, 700, 280, 40), Rect2(2130, 930, 470, 40)]: add_platform(rect)
			tether_anchors = [Vector2(820, 650), Vector2(1900, 520)]
			spawn_enemy(Vector2(820, 900), false)
			spawn_enemy(Vector2(1510, 930), false)
		6:
			for rect in [Rect2(300, 1110, 280, 40), Rect2(760, 1000, 310, 40), Rect2(1510, 1000, 310, 40), Rect2(2020, 1110, 580, 40)]: add_platform(rect)
			if not boss_defeated: spawn_enemy(Vector2(1320, 1300), true, true)
		7:
			for rect in [Rect2(0, 1090, 300, 40), Rect2(390, 1090, 300, 40), Rect2(820, 870, 340, 40), Rect2(1300, 650, 380, 40), Rect2(1830, 880, 320, 40)]: add_platform(rect)
			tether_anchors = [Vector2(990, 650), Vector2(1480, 430)]
			create_kunai_gate("relay_electric_seal", "electric", Vector2(2000, 1300), 300)
		8, 9, 10, 11, 12:
			extension.build_room(self, room)
	expansion.build_room(self,room)
	queue_redraw()

func room_size(index: int) -> Vector2:
	return Expansion.SIZES.get(index,Vector2(2600,1440))

func has_required_sigils() -> bool:
	for id in ["undercroft_sigil","terrace_west","terrace_fire_cache"]:
		if not relay_fragments.get(id,false): return false
	return true

func world_edges() -> Array:
	var edges = []
	for i in 12: edges.append([i,i+1])
	edges.append([3,9]);edges.append([8,12])
	for e in Expansion.EDGES: edges.append([e.a,e.b])
	return edges

func reset_room_actions():
	player.release_tether()
	player.momentum.reset()
	player.attack_time = 0.0
	player.queued = false
	player.did_strike = false
	player.dash_time = 0.0

func sync_metsys_room(index: int):
	var coords: Vector3i = ROOM_MAP_COORDS[index]
	metsys.current_layer = coords.z
	metsys.visit_cell(coords)
	metsys.last_player_position = coords
	for edge in world_edges():
		if edge[0] == index: metsys.discover_cell(ROOM_MAP_COORDS[edge[1]])
		elif edge[1] == index: metsys.discover_cell(ROOM_MAP_COORDS[edge[0]])

func room_discovery_level(index: int) -> int:
	if not metsys.save_data: return 2 if visited[index] else 0
	return metsys.save_data.is_cell_discovered(ROOM_MAP_COORDS[index])

func explored_room_count() -> int:
	var total = 0
	for index in ROOM_COUNT:
		if room_discovery_level(index) == 2: total += 1
	return total

func room_region(index: int) -> String:
	return ROOM_REGIONS[clampi(index, 0, ROOM_COUNT - 1)]

func gate_label(target_room: int) -> String:
	match target_room:
		2: return "WINDSTEP" if not player.double_jump else "OPEN"
		4: return "WIND TETHER" if not player.tether_unlocked else "OPEN"
		6: return "GALE DASH" if not player.dash_unlocked else "OPEN"
		7: return "WARDEN" if not boss_defeated else "OPEN"
		8: return "RELAY" if not completed else "OPEN"
		10: return "3 SIGILS" if not has_required_sigils() else "OPEN"
		11: return "WIND" if not opened_kunai_gates.get("skyworks_wind_intake", false) else "OPEN"
		12: return "ELECTRIC" if not opened_kunai_gates.get("foundry_electric_relay", false) else "OPEN"
	return "OPEN"

func current_objective() -> String:
	if not player.double_jump: return "Defeat the Market sentinel and claim Windstep."
	if not player.tether_unlocked: return "Reach Echo Shrine and recover Wind Tether."
	if not player.dash_unlocked: return "Cross Broken Span and recover Gale Dash."
	if not boss_defeated: return "Break the Tide Warden's seal."
	if not completed: return "Restore the Relay Archive."
	if not has_required_sigils(): return "Survey the annexes: %d / 3 relay sigils recovered." % relay_fragments.size()
	if room == 10 and not opened_kunai_gates.get("skyworks_wind_intake", false): return "Use Wind Kunai to release the intake seal."
	if room == 11 and not opened_kunai_gates.get("foundry_electric_relay", false): return "Save at Foundry Refuge. Open the Electric relay."
	if room == 12 and not cleared_encounters.get("storm_keeper", false): return "Storm Keeper: parry the sweep; jump the ground pulse."
	if not cleared_encounters.get("storm_keeper", false): return "Follow Signal Terrace east. Reach SkyWorks and face the Storm Keeper."
	if not skyworks_restored: return "Attune the Keeper Relay beyond the arena."
	return "SkyWorks restored. The Undercroft return is open."

func register_metsys_progress():
	var progress = {
		"guard_defeated": guard_defeated, "windstep": player.double_jump,
		"wind_tether": player.tether_unlocked, "gale_dash": player.dash_unlocked,
		"boss_defeated": boss_defeated, "secret_letter": secret, "relay_restored": completed,
	}
	for id in progress:
		var token = RefCounted.new()
		token.set_meta(&"object_id", StringName("silent_district/" + id))
		metsys_progress[id] = token
		var was_stored = metsys.register_storable_object(token, func(): pass)
		if was_stored: apply_metsys_progress_flag(id)

func apply_metsys_progress_flag(id: String):
	match id:
		"guard_defeated": guard_defeated = true
		"windstep": player.double_jump = true
		"wind_tether": player.tether_unlocked = true
		"gale_dash": player.dash_unlocked = true
		"boss_defeated": boss_defeated = true
		"secret_letter": secret = true
		"relay_restored": completed = true

func store_metsys_progress():
	var progress = {
		"guard_defeated": guard_defeated, "windstep": player.double_jump,
		"wind_tether": player.tether_unlocked, "gale_dash": player.dash_unlocked,
		"boss_defeated": boss_defeated, "secret_letter": secret, "relay_restored": completed,
	}
	for id in progress:
		if progress[id] and id in metsys_progress and not metsys.is_object_id_stored(StringName("silent_district/" + id)):
			metsys.store_object(metsys_progress[id])

func serialize_metsys_save() -> Dictionary:
	var raw: Dictionary = metsys.get_save_data()
	var discovered: Array = []
	for coords in raw.get(&"discovered_cells", {}):
		discovered.append([coords.x, coords.y, coords.z, raw[&"discovered_cells"][coords]])
	var markers: Array = []
	for coords in raw.get(&"custom_markers", {}):
		markers.append([coords.x, coords.y, coords.z, raw[&"custom_markers"][coords]])
	var stored: Dictionary = {}
	for id in raw.get(&"stored_objects", {}): stored[str(id)] = raw[&"stored_objects"][id]
	return {"discovered_cells": discovered, "stored_objects": stored, "custom_markers": markers, "cell_overrides": raw.get(&"cell_overrides", [])}

func saved_flag(value) -> bool:
	return value is bool and value

func saved_flags(value) -> Dictionary:
	var result = {}
	if value is Dictionary:
		for key in value:
			if key is String: result[key] = saved_flag(value[key])
	return result

func saved_number(value, fallback: float) -> float:
	if (value is int or value is float) and is_finite(float(value)): return float(value)
	return fallback

func valid_map_entry(entry) -> bool:
	if not entry is Array or entry.size() < 4: return false
	for i in 4:
		if not (entry[i] is int or entry[i] is float) or not is_finite(float(entry[i])): return false
	return true

func restore_metsys_save(encoded: Dictionary):
	var discovered: Dictionary[Vector3i, int] = {}
	var stored: Dictionary[StringName, bool] = {}
	var markers: Dictionary[Vector3i, int] = {}
	var cells = encoded.get("discovered_cells", [])
	if cells is Array:
		for entry in cells:
			if valid_map_entry(entry):
				discovered[Vector3i(int(entry[0]), int(entry[1]), int(entry[2]))] = clampi(int(entry[3]), 0, 2)
	var saved_objects = saved_flags(encoded.get("stored_objects", {}))
	for id in saved_objects: stored[StringName(id)] = saved_objects[id]
	var saved_markers = encoded.get("custom_markers", [])
	if saved_markers is Array:
		for entry in saved_markers:
			if valid_map_entry(entry):
				markers[Vector3i(int(entry[0]), int(entry[1]), int(entry[2]))] = int(entry[3])
	metsys.set_save_data()
	metsys.save_data.discovered_cells = discovered
	metsys.save_data.stored_objects = stored
	metsys.save_data.custom_markers = markers
	metsys.map_updated.emit()

func spawn_enemy(at: Vector2, is_boss: bool, is_required: = false, enemy_script = Guard):
	var enemy = enemy_script.new()
	enemy.player = player
	enemy.position = at
	enemy.home = at.x
	enemy.is_required = is_required
	if not is_boss:
		for surface in platforms:
			if absf(surface.position.y-at.y)<2 and at.x>surface.position.x and at.x<surface.end.x:
				enemy.patrol_min = surface.position.x+45
				enemy.patrol_max = surface.end.x-45
				break
	if is_boss:
		enemy.is_boss = true
		enemy.hp = 14
		enemy.max_hp = 14
		enemy.display_name = "TIDE WARDEN"
		enemy.move_speed = 175.0
		enemy.chase_distance = 850.0
		enemy.attack_range = 130.0
	enemy.defeated.connect( func(): on_enemy_defeated(enemy, is_boss, is_required))
	add_child(enemy)
	enemies.append(enemy)
	if is_required:
		active_enemy = enemy
		guard = enemy
	return enemy

func on_enemy_defeated(enemy, is_boss: bool, is_required: bool):
	enemies.erase(enemy)
	var encounter_id = str(enemy.get_meta("persistent_id", ""))
	if not encounter_id.is_empty():
		cleared_encounters[encounter_id] = true
		save_progress()
	if active_enemy == enemy: active_enemy = null
	if guard == enemy: guard = null
	if is_boss and enemy.get_meta("progression_boss", "tide_warden") == "tide_warden":
		boss_defeated = true
		save_progress()
		announce("The Tide Warden breaks. The Relay Archive is open.", 7)
	elif is_required and not is_boss:
		guard_defeated = true
		save_progress()
		announce("The guard falls. Claim the Windstep scroll.", 5)
	elif is_boss:
		announce("Storm Keeper defeated. Attune the relay with E.", 8)

func add_platform(rect: Rect2):
	platforms.append(rect)
	var body = StaticBody2D.new()
	var shape = CollisionShape2D.new()
	var box = RectangleShape2D.new();box.size = rect.size
	shape.shape = box;shape.position = rect.get_center()
	# New service ledges allow upward passage; perimeter and recovery floors stay solid.
	if room >= 13 and rect.size.y == 40 and rect.position.x >= 0:
		shape.one_way_collision = true
		shape.one_way_collision_margin = 8.0
	body.add_child(shape);geometry.add_child(body)

func create_kunai_gate(id: String, element: String, at: Vector2, height: float):
	var gate = {"id": id, "element": element, "position": at, "height": height, "body": null}
	if not opened_kunai_gates.get(id, false):
		var body = StaticBody2D.new()
		var shape = CollisionShape2D.new()
		var box = RectangleShape2D.new();box.size = Vector2(30, height)
		shape.shape = box;shape.position = at - Vector2(0, height / 2.0)
		body.add_child(shape);geometry.add_child(body)
		gate["body"] = body
	kunai_gates.append(gate)

func spawn_kunai(element, direction, at):
	var projectile = Kunai.new()
	projectile.element = element
	projectile.direction = direction
	projectile.position = at
	projectile.world = self
	add_child(projectile)

func resolve_kunai(projectile) -> bool:
	for gate in kunai_gates:
		if opened_kunai_gates.get(gate["id"], false): continue
		var center = gate["position"] - Vector2(0, gate["height"] / 2.0)
		if absf(projectile.position.x - center.x) < 28 and absf(projectile.position.y - center.y) < gate["height"] / 2.0 + 20:
			if projectile.element == gate["element"]:
				opened_kunai_gates[gate["id"]] = true
				if is_instance_valid(gate["body"]): gate["body"].queue_free()
				save_progress()
				announce(projectile.element.capitalize() + " seal broken.", 3)
				queue_redraw()
			else:
				announce("The seal rejects the " + projectile.element.capitalize() + " Kunai.", 2)
			return true
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.hp > 0 and projectile.position.distance_to(enemy.position + Vector2(0, -50)) < enemy.hit_radius + 28:
			enemy.receive_hit(1)
			return true
	return false

func announce(text, seconds = 4.0):
	message = text;message_time = seconds

func on_strike(damage, reach):
	var target = null
	var closest = INF
	for enemy in enemies:
		if not is_instance_valid(enemy) or enemy.hp <= 0: continue
		var d = enemy.position - player.position
		if absf(d.x) <= reach + enemy.hit_radius and absf(d.y) < 105 and d.x * player.facing > - enemy.hit_radius:
			if d.length_squared() < closest:
				closest = d.length_squared();target = enemy
	if target:
		target.receive_hit(damage)
		player.hitstop = 0.055 if damage == 1 else 0.085

func spawn_dash_afterimage(texture, frame, at, flip_h):
	afterimages_spawned += 1
	var ghost = Sprite2D.new()
	ghost.add_to_group("route_afterimage")
	ghost.texture = texture
	ghost.hframes = 8
	ghost.frame = frame
	ghost.scale = player.sprite.scale
	ghost.offset = player.sprite.offset
	ghost.flip_h = flip_h
	ghost.position = at
	ghost.modulate = Color(0.55, 0.95, 1.0, 0.48)
	add_child(ghost)
	move_child(ghost, player.get_index())
	var tween = ghost.create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, 0.24)
	tween.tween_callback(ghost.queue_free)

func on_hurt():
	if player.hp <= 0: call_deferred("respawn")

func respawn():
	transition = 0.0
	pending_room = -1
	pending_arrival = Vector2.INF
	player.set_physics_process(true)
	fall_recovering = false
	player.hp = 3
	build_room(checkpoint_room)
	player.position = checkpoint_position
	player.velocity = Vector2.ZERO
	player.attack_time = 0
	player.invulnerable = 1.5
	camera.reset_smoothing()
	announce("The wind returns you to the last shrine. Earned abilities are safe.")

func recover_from_fall():
	if fall_recovering: return
	fall_recovering = true
	player.hp -= 1
	if player.hp <= 0:
		respawn()
		return
	build_room(room)
	player.position = left_exit_position() + Vector2(110, -2)
	player.velocity = Vector2.ZERO
	player.invulnerable = 1.2
	camera.reset_smoothing()
	fall_recovering = false
	announce("The current pulls Kaze back to solid ground.", 3)

func request_room(target, arrival = Vector2.INF):
	if transition > 0 or target < 0 or target >= ROOM_COUNT: return
	if not can_enter(target): return
	pending_arrival = arrival
	pending_from_room = room
	pending_room = target
	transition = 0.65
	player.set_physics_process(false)
	hud.clear_touches()

func can_enter(target):
	if room == 1 and target == 2 and not player.double_jump:
		announce("The sluice climb needs Windstep.");return false
	if room == 3 and target == 4 and not player.tether_unlocked:
		announce("The broken span needs a Wind Tether.");return false
	if room == 5 and target == 6 and not player.dash_unlocked:
		announce("The storm gate needs Gale Dash.");return false
	if room == 7 and target == 8 and not completed:
		announce("Restore the Relay Archive before exploring its annexes.");return false
	if room == 9 and target == 10 and not has_required_sigils():
		announce("Recover all three relay sigils to power the SkyWorks lift.");return false
	if room == 10 and target == 11 and not opened_kunai_gates.get("skyworks_wind_intake", false):
		announce("Use Wind Kunai to release the intake seal.");return false
	if room == 11 and target == 12 and not opened_kunai_gates.get("foundry_electric_relay", false):
		announce("Use Electric Kunai to open the Foundry relay.");return false
	if room == 6 and target == 7 and not boss_defeated:
		announce("The Tide Warden seals the archive.");return false
	if room >= 13 or target >= 13:
		for portal in expansion.portals(room):
			if portal.target == target: return expansion.allowed(self,portal.need)
		return false
	return true

func left_exit_position() -> Vector2:
	if room >= 13: return expansion.portals(room)[0].at
	return Vector2(120, [1300, 1300, 1300, 850, 1300, 1080, 1300, 1090, 1090, 830, 830, 760, 1300][room])

func right_exit_position() -> Vector2:
	if room >= 13: return expansion.portals(room)[-1].at
	return Vector2(2440, [1300, 1300, 850, 1300, 1080, 1300, 1090, 1300, 830, 830, 760, 1300, 1300][room])

func interact():
	if transition > 0: return
	if room == 0 and player.position.distance_to(Vector2(220, 1300)) < 95:
		player.hp = 3;checkpoint_room = 0;checkpoint_position = Vector2(220, 1298);save_progress();announce("Canal Haven restored. Journey saved.")
		return
	if room == 3 and player.position.distance_to(Vector2(1320, 1300)) < 115:
		player.hp = 3;checkpoint_room = 3;checkpoint_position = Vector2(1320, 1298);save_progress();announce("Echo Shrine awakened. Checkpoint saved.")
		return
	if room == 7 and player.position.distance_to(Vector2(2200, 1300)) < 140:
		if not opened_kunai_gates.get("relay_electric_seal", false):
			announce("Open the Electric archive seal before restoring the relay.");return
		completed = true;checkpoint_room = 7;checkpoint_position = Vector2(2200, 1298);save_progress()
		announce("Relay restored. The Silent District route is open.", 15)
		return
	if expansion.interact(self): return
	if extension.interact(self): return
	if room >= 13: return
	if room > 0 and player.position.distance_to(left_exit_position()) < 105:
		request_room(room - 1)
	elif room < 12 and player.position.distance_to(right_exit_position()) < 105:
		request_room(room + 1)

func grapple_candidates() -> Array[Vector2]:
	var candidates: Array[Vector2] = tether_anchors.duplicate()
	for object in get_tree().get_nodes_in_group("kaze_grapple_anchor"):
		if is_ancestor_of(object) and object.has_method("is_available_for") and object.has_method("get_attachment_position") and object.is_available_for(player):
			candidates.append(object.get_attachment_position())
	return candidates

func select_tether_anchor():
	var nearest = null
	var distance = clampf(player.grapple_range, 80.0, 480.0) + 1.0
	for anchor in grapple_candidates():
		var candidate = player.tether_origin().distance_to(anchor)
		if candidate < distance and player.can_tether_anchor(anchor):
			distance = candidate
			nearest = anchor
	return nearest

func on_tether_requested():
	var nearest = select_tether_anchor() if player.tether_unlocked else null
	if nearest == null:
		announce("No Wind Tether anchor in range.", 2)
	elif player.apply_tether(nearest):
		tether_effect_anchor = nearest
		tether_effect_time = 1.0
		announce("Wind Tether", 1)

func _physics_process(dt):
	message_time = maxf(0, message_time - dt)
	if player.tether_attached:
		tether_effect_anchor = player.tether_anchor
		tether_effect_time = 1.0
	else:
		tether_effect_time = maxf(0, tether_effect_time - dt * 5.0)
	metsys.exact_player_position = player.position
	if transition > 0:
		transition -= dt
		if transition < 0.32 and pending_room >= 0:
			var target = pending_room;pending_room = -1
			var moving_east = target > pending_from_room
			build_room(target)
			var destination = left_exit_position() if moving_east else right_exit_position()
			player.position = destination + Vector2(110 if moving_east else -140, -2) if pending_arrival == Vector2.INF else pending_arrival
			pending_arrival = Vector2.INF
			player.velocity = Vector2.ZERO
			camera.reset_smoothing()
		if transition <= 0: player.set_physics_process(true)
	if Input.is_action_just_pressed("interact"): interact()
	if room == 1 and guard_defeated and not player.double_jump and player.position.distance_to(Vector2(1580, 1260)) < 90:
		player.double_jump = true;player.unlock_kunai("wind");save_progress()
		announce("WINDSTEP + WIND KUNAI — Double-jump; press R to break green seals.", 8)
	if room == 3 and not player.tether_unlocked and player.position.distance_to(Vector2(1320, 1260)) < 105:
		player.tether_unlocked = true;save_progress()
		announce("WIND TETHER — Hold Q near a green anchor, then pump the swing with movement.", 9)
	if room == 5 and not player.dash_unlocked and player.position.distance_to(Vector2(1320, 1260)) < 105:
		player.dash_unlocked = true;save_progress()
		announce("GALE DASH — Press Shift to burst through the storm gate.", 9)
	if room == 4 and not player.kunai_unlocked["fire"] and player.position.distance_to(Vector2(1080, 990)) < 100:
		player.unlock_kunai("fire");save_progress()
		announce("FIRE KUNAI — R throws; T cycles elements. Red seals now yield.", 8)
	if room == 5 and not player.kunai_unlocked["electric"] and player.position.distance_to(Vector2(1510, 890)) < 105:
		player.unlock_kunai("electric");save_progress()
		announce("ELECTRIC KUNAI — Blue relay seals can now be opened.", 8)
	if room == 2 and not secret and opened_kunai_gates.get("cistern_wind_cache", false) and player.position.distance_to(Vector2(2300, 830)) < 80:
		secret = true;player.hp = 3;save_progress()
		announce("Hidden letter: the next convoy leaves before dawn. Health restored.", 7)
	extension.update_progress(self)
	expansion.update(self,dt)
	if player.position.y > room_size(room).y + 70 and not fall_recovering:
		call_deferred("recover_from_fall")
	queue_redraw()

func save_progress():
	if test_mode: return true
	store_metsys_progress()
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		announce("Could not save. Your current session can continue.");return false
	file.store_string(JSON.stringify({
		"version": 8, "expansion_flags": expansion_flags, "speed_upgrade_level": player.speed_upgrade_level, "skyworks_restored": skyworks_restored, "checkpoint_position": [checkpoint_position.x, checkpoint_position.y],
		"relay_fragments": relay_fragments, "cleared_encounters": cleared_encounters, "double_jump": player.double_jump,
		"tether_unlocked": player.tether_unlocked, "dash_unlocked": player.dash_unlocked,
		"kunai_unlocked": player.kunai_unlocked, "selected_kunai": player.selected_kunai,
		"opened_kunai_gates": opened_kunai_gates,
		"guard_defeated": guard_defeated, "boss_defeated": boss_defeated,
		"completed": completed, "secret": secret, "visited": visited,
		"checkpoint_room": checkpoint_room,
		"metsys": serialize_metsys_save(),
	}))
	file.close()
	return true

func load_progress():
	if not FileAccess.file_exists(save_path): return
	var data = JSON.parse_string(FileAccess.get_file_as_string(save_path))
	if not data is Dictionary or saved_number(data.get("version", 0), 0) < 1: return
	expansion_flags = saved_flags(data.get("expansion_flags", {}))
	player.restore_speed_upgrade(data.get("speed_upgrade_level", 0))
	player.momentum.reset()
	player.double_jump = saved_flag(data.get("double_jump", false))
	player.tether_unlocked = saved_flag(data.get("tether_unlocked", false))
	player.dash_unlocked = saved_flag(data.get("dash_unlocked", false))
	var saved_kunai = saved_flags(data.get("kunai_unlocked", {}))
	for element in player.kunai_unlocked: player.kunai_unlocked[element] = saved_kunai.get(element, false)
	if saved_number(data.get("version", 0), 0) < 4 and player.double_jump: player.kunai_unlocked["wind"] = true
	var selected = data.get("selected_kunai", "wind")
	player.selected_kunai = selected if selected is String and selected in player.kunai_unlocked else "wind"
	if not player.kunai_unlocked.get(player.selected_kunai, false):
		player.selected_kunai = "wind"
		for element in ["wind", "fire", "electric"]:
			if player.kunai_unlocked[element]:
				player.selected_kunai = element
				break
	opened_kunai_gates = saved_flags(data.get("opened_kunai_gates", {}))
	guard_defeated = saved_flag(data.get("guard_defeated", false))
	boss_defeated = saved_flag(data.get("boss_defeated", false))
	completed = saved_flag(data.get("completed", false))
	skyworks_restored = saved_flag(data.get("skyworks_restored", false))
	secret = saved_flag(data.get("secret", false))
	checkpoint_room = clampi(int(saved_number(data.get("checkpoint_room", 0), 0)), 0, ROOM_COUNT - 1)
	checkpoint_position = Vector2(220, 1298)
	var checkpoint_at = data.get("checkpoint_position", [220, 1298])
	if checkpoint_at is Array and checkpoint_at.size() == 2:
		checkpoint_position = Vector2(clampf(saved_number(checkpoint_at[0], 220), 40, room_size(checkpoint_room).x-40), clampf(saved_number(checkpoint_at[1], 1298), 80, room_size(checkpoint_room).y-50))
	relay_fragments = saved_flags(data.get("relay_fragments", {}))
	cleared_encounters = saved_flags(data.get("cleared_encounters", {}))
	var metsys_encoded = data.get("metsys", {})
	restore_metsys_save(metsys_encoded if metsys_encoded is Dictionary else {})
	visited.fill(false)
	visited[0] = true
	var saved_visited = data.get("visited", [])
	if saved_visited is Array:
		for i in mini(saved_visited.size(), ROOM_COUNT):
			visited[i] = saved_flag(saved_visited[i])
			if visited[i]: metsys.visit_cell(ROOM_MAP_COORDS[i])

func _draw():
	if not is_instance_valid(player): return
	draw_rect(Rect2(Vector2.ZERO,room_size(room)), ROOM_COLORS[room])
	draw_texture_rect(DistrictBackground, Rect2(Vector2.ZERO,room_size(room)), false, Color(0.72, 0.7, 0.86, 0.92))
	draw_rect(Rect2(Vector2.ZERO,room_size(room)), Color(ROOM_COLORS[room], 0.18))
	if room in [15,16,18,19]:
		draw_rect(Rect2(Vector2.ZERO,room_size(room)),Color(0.025,0.045,0.05,0.64))
	for rect in platforms:
		if rect.position.x < 0 or rect.position.x >= room_size(room).x: continue
		draw_rect(rect, Color("252631"))
		draw_rect(Rect2(rect.position, Vector2(rect.size.x, 7)), Color("aaa18b"))
		draw_rect(Rect2(rect.position + Vector2(0, 7), Vector2(rect.size.x, 9)), Color("54535c"))
	for gate in kunai_gates:
		if opened_kunai_gates.get(gate["id"], false): continue
		var color = {"wind": Color("79d69a"), "fire": Color("ed7852"), "electric": Color("5ec8ee")}[gate["element"]]
		var rect = Rect2(gate["position"] - Vector2(15, gate["height"]), Vector2(30, gate["height"]))
		draw_rect(rect, Color(color, 0.18))
		draw_rect(rect, color, false, 4)
		for y in range(int(rect.position.y) + 18, int(rect.end.y), 34): draw_line(Vector2(rect.position.x, y), Vector2(rect.end.x, y + 16), Color(color, 0.75), 3)
	if room == 2:
		for rect in [Rect2(640, 1260, 290, 180), Rect2(1350, 1260, 330, 180), Rect2(2200, 1260, 180, 180)]: draw_water(rect)
	elif room == 4:
		for rect in [Rect2(450, 1260, 550, 180), Rect2(1280, 1260, 770, 180)]: draw_water(rect)
	elif room == 5:
		for rect in [Rect2(500, 1260, 280, 180), Rect2(1500, 1260, 350, 180)]: draw_water(rect)
	for anchor in grapple_candidates():
		var in_range = player.tether_unlocked and player.can_tether_anchor(anchor)
		var pulse = 3.0 + sin(player.age * 7.0) * 2.0 if in_range else 0.0
		draw_circle(anchor, 25 + pulse, Color(0.68, 0.9, 0.57, 0.12 if in_range else 0.07))
		draw_arc(anchor, 20 + pulse, 0, TAU, 28, Color("d5ffb4") if in_range else Color("93b982"), 4 if in_range else 3)
		draw_circle(anchor, 7, Color("e9ffd6") if in_range else Color("a5ca90"))
		draw_line(anchor - Vector2(12, 0), anchor + Vector2(12, 0), Color("d5ffb4"), 2)
		draw_line(anchor - Vector2(0, 12), anchor + Vector2(0, 12), Color("d5ffb4"), 2)
	if tether_effect_time > 0:
		draw_tether_effect()
	if room > 0 and room < 13: draw_door(left_exit_position())
	if room < 12: draw_door(right_exit_position())
	if room == 0:
		draw_rect(Rect2(190, 1256, 60, 44), Color("63516e"));draw_circle(Vector2(220, 1237), 18, Color("c8d69f"))
		draw_string(ThemeDB.fallback_font, Vector2(105, 1185), "CANAL HAVEN", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("e6dcc4"))
	elif room == 1 and not player.double_jump:
		draw_circle(Vector2(1580, 1240), 22, Color("b8c68b") if guard_defeated else Color("665a70"))
		draw_string(ThemeDB.fallback_font, Vector2(1505, 1188), "WINDSTEP", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("e6dcc4"))
	elif room == 2 and not secret:
		draw_rect(Rect2(2284, 815, 32, 20), Color("e9d8b5"))
	elif room == 3:
		draw_circle(Vector2(1320, 1242), 34, Color("7e69a0"));draw_circle(Vector2(1320, 1242), 18, Color("c8d69f"))
		draw_string(ThemeDB.fallback_font, Vector2(1235, 1178), "WIND TETHER", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("e6dcc4"))
	elif room == 4 and not player.kunai_unlocked["fire"]:
		draw_circle(Vector2(1080, 980), 20, Color("ed7852"));draw_string(ThemeDB.fallback_font, Vector2(1010, 940), "FIRE KUNAI", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("ffd4b3"))
	elif room == 5:
		draw_circle(Vector2(1320, 1242), 30, Color("8cb6ca"));draw_line(Vector2(1288, 1242), Vector2(1352, 1242), Color("e4f5ff"), 5)
		draw_string(ThemeDB.fallback_font, Vector2(1255, 1178), "GALE DASH", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("e6dcc4"))
		if not player.kunai_unlocked["electric"]:
			draw_circle(Vector2(1510, 880), 20, Color("5ec8ee"));draw_string(ThemeDB.fallback_font, Vector2(1415, 840), "ELECTRIC KUNAI", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("d4f5ff"))
	elif room == 7:
		draw_rect(Rect2(2140, 1080, 120, 220), Color("2e3c4f"));draw_rect(Rect2(2160, 1110, 80, 120), Color("9bc5a0"), false, 5)
		draw_string(ThemeDB.fallback_font, Vector2(2080, 1035), "RELAY CONTROL", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("e6dcc4"))
	extension.draw_room(self)
	expansion.draw_room(self)
	draw_string(ThemeDB.fallback_font, Vector2(980, 260), ROOM_NAMES[room], HORIZONTAL_ALIGNMENT_CENTER, 640, 32, Color(0.9, 0.84, 0.75, 0.55))

func draw_tether_effect():
	var start = player.tether_origin()
	var finish = tether_effect_anchor
	var direction = finish - start
	if direction.length() < 1: return
	var normal = direction.normalized().orthogonal()
	var points = PackedVector2Array()
	for i in range(11):
		var amount = float(i) / 10.0
		var wave = sin(amount * TAU * 2.0 - player.age * 28.0) * 10.0 * sin(amount * PI)
		points.append(start.lerp(finish, amount) + normal * wave)
	var strength = clampf(tether_effect_time, 0.0, 1.0)
	draw_polyline(points, Color(0.45, 1.0, 0.72, 0.2 * strength), 14, true)
	draw_polyline(points, Color(0.66, 1.0, 0.78, 0.85 * strength), 6, true)
	draw_polyline(points, Color(0.94, 1.0, 0.84, 0.95 * strength), 2, true)
	draw_circle(start, 16 + 8 * strength, Color(0.66, 1.0, 0.78, 0.25 * strength))
	draw_circle(finish, 28 + 12 * strength, Color(0.66, 1.0, 0.78, 0.22 * strength))

func draw_door(at: Vector2, color = Color("d1b08e")):
	draw_rect(Rect2(at + Vector2(-37, -133), Vector2(74, 133)), Color("171523"))
	draw_rect(Rect2(at + Vector2(-40, -136), Vector2(80, 136)), color, false, 4)
	draw_circle(at + Vector2(22, -58), 4, color)

func draw_water(rect: Rect2):
	draw_rect(rect, Color("15364a"))
	for x in range(int(rect.position.x), int(rect.end.x), 42):
		draw_arc(Vector2(x, rect.position.y + 8), 20, PI, TAU, 10, Color(0.42, 0.77, 0.83, 0.65), 3)
