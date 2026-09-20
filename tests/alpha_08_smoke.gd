extends SceneTree

const ROOM_GRAPH := preload("res://scripts/rooms/room_graph.gd")

var failures := 0


func _init() -> void:
	call_deferred("_run")


func _check(condition: bool, message: String) -> void:
	if condition:
		print("PASS: ", message)
	else:
		failures += 1
		push_error("FAIL: " + message)


func _run() -> void:
	var game_state := root.get_node_or_null("GameState")
	_check(game_state != null, "GameState autoload exists")
	if game_state:
		game_state.call("new_game")
		_check(game_state.call("has_ability", "dash"), "New game includes baseline Dash")
		_check(game_state.call("has_ability", "tether"), "New game includes baseline Wind Tether")
		_check(game_state.call("has_ability", "wind_kunai"), "New game includes baseline Wind Kunai")

	var all_paths: Array[String] = [
		"res://scenes/rooms/room_01_combat.tscn",
		"res://scenes/rooms/room_02_platforming.tscn",
		"res://scenes/rooms/room_03_mixed.tscn",
		"res://scenes/rooms/room_04_checkpoint.tscn",
	]
	for room_index in range(5, 13):
		all_paths.append("res://scenes/rooms/room_%02d_route.tscn" % room_index)

	for path in all_paths:
		var packed := load(path) as PackedScene
		_check(packed != null, "%s loads" % path)
		if packed == null:
			continue
		var room := packed.instantiate()
		root.add_child(room)
		await process_frame
		var player := room.find_child("Kaze", true, false)
		_check(player != null, "%s has Kaze" % path)
		if player:
			_check(player.has_method("_start_grapple"), "Kaze has momentum tether")
			_check(player.has_method("get_current_kunai_element"), "Kaze has elemental kunai")
			_check(player.has_method("is_guard_veil_active"), "Kaze has Guard Veil")
			var constants: Dictionary = player.get_script().get_script_constant_map()
			_check(float(constants.get("GRAPPLE_RANGE", 9999.0)) <= 420.0, "Wind Tether range is parity-limited")
			_check(float(constants.get("COYOTE_TIME", 0.0)) <= 0.12, "Coyote time uses the web-parity window")
			var animated_sprite := player.get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
			_check(animated_sprite != null and animated_sprite.sprite_frames.get_frame_count(&"run") == 12, "Kaze run strip is sliced into frames")
		_check(room.get_node_or_null("HUD/MapOverlay/Content/Map") != null, "%s has the restored survey map" % path)
		_check(room.find_child("PaintedDistrictBackdrop", true, false) != null or path.contains("_route"), "%s has painted environment art" % path)
		if path.contains("_route"):
			_check(get_nodes_in_group("grapple_anchor").size() >= 3, "%s has visible grapple anchors" % path)
			_check(room.find_children("*", "Sprite2D", true, false).size() >= 2, "%s uses textured environment layers" % path)
		room.queue_free()
		await process_frame

	await _check_anchor_only_tether()
	await _check_mechanical_integrity()
	await _check_room_topology()
	await _check_authored_surface_room()

	if game_state:
		game_state.call("new_game")
		await _clear_progression_room(7)
		_check(game_state.call("has_ability", "fire_kunai"), "Storm Reliquary unlocks Fire Kunai")
		await _clear_progression_room(11)
		_check(game_state.call("has_ability", "electric_kunai"), "Hall milestone unlocks Electric Kunai")
		await _clear_progression_room(12)
		_check(game_state.call("has_ability", "guard_veil"), "Borrowed Face unlocks Guard Veil")
		game_state.call("manual_save")
		_check(game_state.call("has_ability", "guard_veil"), "Guard Veil progression persists")

	print("ALPHA 0.8 SMOKE TEST: %d failure(s), %d rooms" % [failures, all_paths.size()])
	quit(1 if failures > 0 else 0)


func _check_anchor_only_tether() -> void:
	var player := (load("res://scenes/kaze.tscn") as PackedScene).instantiate()
	root.add_child(player)
	player.position = Vector2(300, 400)
	await process_frame
	player.set_physics_process(false)
	player.call("_try_start_grapple", player.global_position + Vector2(100.0, -100.0))
	_check(not bool(player.get("grapple_active")), "Wind Tether cannot attach to empty space")
	var anchor := Node2D.new()
	anchor.position = Vector2(420, 220)
	anchor.add_to_group("grapple_anchor")
	root.add_child(anchor)
	await process_frame
	var off_target_aim := anchor.global_position + Vector2(240.0, 0.0)
	_check(not bool(player.call("_try_start_grapple", off_target_aim)), "Wind Tether rejects an anchor when aim is clearly elsewhere")
	_check(not bool(player.get("grapple_active")), "Rejected aim leaves Wind Tether inactive")
	player.call("_try_start_grapple", anchor.global_position)
	_check(bool(player.get("grapple_active")), "Wind Tether attaches to an in-range authored anchor")
	_check(player.get("grapple_anchor") == anchor, "Wind Tether stores the authored anchor target")

	player.velocity = Vector2(420.0, -260.0)
	player.call("_release_grapple")
	_check(player.velocity == Vector2(420.0, -260.0), "Wind Tether release preserves swing momentum")

	var blocker := StaticBody2D.new()
	blocker.position = (player.global_position + anchor.global_position) * 0.5
	var blocker_shape := CollisionShape2D.new()
	var blocker_rectangle := RectangleShape2D.new()
	blocker_rectangle.size = Vector2(120.0, 24.0)
	blocker_shape.shape = blocker_rectangle
	blocker.add_child(blocker_shape)
	root.add_child(blocker)
	await physics_frame
	_check(not bool(player.call("_try_start_grapple", anchor.global_position)), "Wind Tether cannot attach through solid geometry")

	player.global_position = Vector2(300.0, 500.0)
	anchor.global_position = Vector2(300.0, 100.0)
	blocker.global_position = Vector2(300.0, 420.0)
	blocker_rectangle.size = Vector2(160.0, 20.0)
	await physics_frame
	player.grapple_active = true
	player.grapple_anchor = anchor
	player.grapple_point = anchor.global_position
	player.grapple_length = 300.0
	player.velocity = Vector2(0.0, 240.0)
	player.call("_apply_grapple_constraint")
	_check(player.global_position.y >= 461.0, "Rope correction stops at blocking geometry instead of teleporting through it")
	_check(player.velocity.y <= 0.0, "Rope constraint removes outward radial velocity after a collision-safe correction")

	player.global_position = Vector2(420.0, 300.0)
	player.grapple_point = anchor.global_position
	player.velocity = Vector2.ZERO
	player.call("_apply_grapple_pump", 1.0, 1.0 / 60.0)
	_check(player.velocity.length() > 0.0, "Wind Tether pumping still adds tangential momentum")

	blocker.queue_free()
	anchor.queue_free()
	player.queue_free()
	await process_frame


func _check_mechanical_integrity() -> void:
	var game_state := root.get_node("GameState")
	var player := (load("res://scenes/kaze.tscn") as PackedScene).instantiate()
	root.add_child(player)
	await process_frame

	var health_events := {"player": 0, "game_state": 0}
	var on_player_health := func(_current: float, _maximum: float) -> void: health_events["player"] += 1
	var on_game_state_health := func(_current: float, _maximum: float) -> void: health_events["game_state"] += 1
	player.health_changed.connect(on_player_health)
	game_state.connect("player_health_changed", on_game_state_health)
	player.call("take_damage", 5.0)
	_check(health_events["player"] == 1, "One hit emits one player health event")
	_check(health_events["game_state"] == 1, "One hit updates GameState health once")

	player.call("_perform_attack")
	var hitbox: Area2D = player.get_node("Hitbox")
	_check(is_equal_approx(float(hitbox.get("auto_disable_timer")), 0.15), "Melee uses an explicit 0.15 second hit window")
	hitbox.call("mark_hit", player)
	player.call("_perform_attack")
	_check(not hitbox.call("has_hit", player), "Each combo step clears stale hit targets")
	_check(int(player.get("combo_step")) == 2, "Each accepted combo input advances with a fresh window")

	player.velocity = Vector2(1250.0, -280.0)
	player.facing_dir = 1
	player.call("_begin_dash")
	_check(is_equal_approx(player.velocity.x, 1250.0), "Dash preserves greater incoming horizontal momentum")
	_check(is_equal_approx(player.velocity.y, -280.0), "Dash preserves meaningful vertical momentum")
	var exit_speed: float = player.velocity.x
	player.call("_end_dash")
	_check(is_equal_approx(player.velocity.x, exit_speed), "Dash exit does not snap horizontal velocity")

	game_state.abilities_unlocked.erase("dash")
	player.is_dashing = false
	player.call("_begin_dash")
	_check(not player.is_dashing, "Locked Dash cannot start")
	game_state.call("unlock_ability", "dash")
	game_state.abilities_unlocked.erase("wind_kunai")
	_check(not player.call("_can_throw_current_kunai"), "Locked Wind Kunai cannot be thrown")
	game_state.call("unlock_ability", "wind_kunai")
	var gated_anchor := Node2D.new()
	gated_anchor.position = player.position + Vector2(80.0, -80.0)
	gated_anchor.add_to_group("grapple_anchor")
	root.add_child(gated_anchor)
	game_state.abilities_unlocked.erase("tether")
	player.grapple_active = false
	player.call("_start_grapple")
	_check(not player.grapple_active, "Locked Wind Tether cannot attach")
	game_state.call("unlock_ability", "tether")
	gated_anchor.queue_free()

	game_state.call("manual_save")
	game_state.abilities_unlocked.clear()
	_check(game_state.call("load_from_disk"), "Ability state reloads from disk")
	_check(game_state.call("has_ability", "dash"), "Baseline Dash survives save/load")
	_check(game_state.call("has_ability", "tether"), "Baseline Wind Tether survives save/load")
	_check(game_state.call("has_ability", "wind_kunai"), "Baseline Wind Kunai survives save/load")

	game_state.disconnect("player_health_changed", on_game_state_health)
	player.queue_free()
	await process_frame


func _check_room_topology() -> void:
	var markers_by_room := {}
	var transitions: Array[Dictionary] = []
	var observed_transitions := {}

	for room_key in ROOM_GRAPH.ROOM_SCENES:
		var room_id := String(room_key)
		var scene_path := ROOM_GRAPH.scene_for_room(room_id)
		var packed := load(scene_path) as PackedScene
		_check(packed != null, "%s topology scene loads" % room_id)
		if packed == null:
			continue
		var room := packed.instantiate()
		root.add_child(room)
		await process_frame

		var marker_names: Array[String] = []
		var spawn_points := room.get_node_or_null("SpawnPoints")
		_check(spawn_points != null, "%s defines SpawnPoints" % room_id)
		if spawn_points:
			for marker in spawn_points.get_children():
				if marker is Marker2D:
					marker_names.append(String(marker.name))
		markers_by_room[room_id] = marker_names
		_check("spawn_default" in marker_names, "%s defines spawn_default" % room_id)

		for exit_node in room.find_children("*", "DoorExit", true, false):
			var target_scene := String(exit_node.get("target_scene_path"))
			var target_room_id := ROOM_GRAPH.room_id_from_scene(target_scene)
			var target_spawn := String(exit_node.get("target_spawn_marker"))
			transitions.append({
				"source": room_id,
				"target": target_room_id,
				"target_scene": target_scene,
				"target_spawn": target_spawn,
			})
			observed_transitions["%s>%s" % [room_id, target_room_id]] = true
		room.queue_free()
		await process_frame

	for transition in transitions:
		var source_id := String(transition.source)
		var target_id := String(transition.target)
		var target_scene := String(transition.target_scene)
		var target_spawn := String(transition.target_spawn)
		_check(not target_id.is_empty(), "%s exit targets a canonical room scene" % source_id)
		_check(ROOM_GRAPH.has_transition(source_id, target_id), "%s → %s exists in the canonical graph" % [source_id, target_id])
		_check(target_scene == ROOM_GRAPH.scene_for_room(target_id), "%s → %s uses the canonical target scene" % [source_id, target_id])
		_check(markers_by_room.has(target_id) and target_spawn in markers_by_room[target_id], "%s → %s arrives at valid marker %s" % [source_id, target_id, target_spawn])

	for connection in ROOM_GRAPH.CONNECTIONS:
		var from_id := String(connection.from)
		var to_id := String(connection.to)
		_check(observed_transitions.has("%s>%s" % [from_id, to_id]), "%s → %s transition is implemented" % [from_id, to_id])
		if connection.bidirectional:
			_check(observed_transitions.has("%s>%s" % [to_id, from_id]), "%s → %s reciprocal transition is implemented" % [to_id, from_id])


func _check_authored_surface_room() -> void:
	var room := (load("res://scenes/rooms/room_05_route.tscn") as PackedScene).instantiate()
	root.add_child(room)
	await process_frame
	var platforms := room.get_node_or_null("Platforms")
	var anchors := room.get_node_or_null("GrappleAnchors")
	var enemies := room.get_node_or_null("Enemies")
	var spawn_points := room.get_node_or_null("SpawnPoints")
	var camera := room.get_node_or_null("RoomCamera") as Camera2D
	_check(room.name == "CompactSurfaceApproach", "Room 5 is the first authored parity-slice room")
	_check(not bool(room.get("build_default_environment")), "Authored surface room disables the prototype environment generator")
	_check(not bool(room.get("spawn_default_grapple_anchors")), "Authored surface room uses explicit anchors")
	_check(platforms != null and platforms.get_child_count() >= 10, "Compact Surface Approach has dense authored collision geometry")
	_check(anchors != null and anchors.get_child_count() == 3, "Compact Surface Approach has three intentional tether anchors")
	_check(enemies != null and enemies.get_child_count() == 3, "Compact Surface Approach has a three-lane encounter")
	_check(spawn_points != null and spawn_points.has_node("entry_shortcut"), "Compact Surface Approach reserves the Fire-return arrival landmark")
	_check(camera != null and camera.get("room_bounds") == Rect2(0, 0, 1920, 720), "Compact Surface Approach uses authored 1920×720 camera bounds")
	room.queue_free()
	await process_frame


func _clear_progression_room(room_index: int) -> void:
	var path := "res://scenes/rooms/room_%02d_route.tscn" % room_index
	var room := (load(path) as PackedScene).instantiate()
	root.add_child(room)
	await process_frame
	var count: int = room.enemy_counts[room_index]
	for _enemy in count:
		room.call("_on_enemy_died")
	room.queue_free()
	await process_frame
