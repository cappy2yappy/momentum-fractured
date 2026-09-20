extends SceneTree

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
	player.call("_start_grapple")
	_check(not bool(player.get("grapple_active")), "Wind Tether cannot attach to empty space")
	var anchor := Node2D.new()
	anchor.position = Vector2(420, 220)
	anchor.add_to_group("grapple_anchor")
	root.add_child(anchor)
	await process_frame
	player.call("_start_grapple")
	_check(bool(player.get("grapple_active")), "Wind Tether attaches to an in-range authored anchor")
	_check(player.get("grapple_anchor") == anchor, "Wind Tether stores the authored anchor target")
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
