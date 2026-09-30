extends SceneTree

var failures := 0

func _check(ok: bool, message: String) -> void:
	if ok:
		print("PASS: ", message)
	else:
		failures += 1
		push_error(message)

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var room := (load("res://scenes/rooms/room_08_route.tscn") as PackedScene).instantiate()
	_check(room.get_node("RoomCamera").room_bounds == Rect2(0, 0, 1920, 1080), "Authored canal camera bounds")
	var water := room.get_node("Water") as Area2D
	var shape := water.get_node("CollisionShape2D").shape as RectangleShape2D
	_check(shape.size == Vector2(1880, 610) and water.position == Vector2(960, 735), "Deep traversable water spans Y430–1040")
	_check(water.get_script().resource_path.ends_with("water_zone.gd"), "Water uses swim state rather than death hazard")
	_check(room.get_node("SpawnPoints/entry_from_room7").position == Vector2(105, 336), "Threshold arrival on dry entry ledge")
	_check(room.get_node("SpawnPoints/entry_from_room9").position == Vector2(1770, 866), "Return arrival at underwater intake")
	_check(room.get_node("Doors/ExitLeft").target_spawn_marker == "entry_from_room8", "Backtrack names reciprocal threshold marker")
	_check(room.get_node("Doors/ExitLowerRight").target_spawn_marker == "entry_from_room8", "Forward route names reciprocal return marker")
	_check(room.get_node("Doors/ExitLeft").requires_room_clear == false, "Retreat remains open during water encounter")
	for jet in room.get_node("CurrentJets").get_children():
		_check(jet.damage == 12 and jet.warning_duration >= 0.6 and jet.inactive_duration > jet.active_duration, "Current has warning, safe interval, survivable damage")
	_check(room.has_node("Platforms/RightSurfaceRecovery"), "Dry right shore supports surfacing and recovery")
	for source in ["room_07_route", "room_09_route"]:
		var neighbor := (load("res://scenes/rooms/" + source + ".tscn") as PackedScene).instantiate()
		# Generated neighbors create markers only after ready; authored scenes expose them now.
		if neighbor.has_node("SpawnPoints"):
			_check(neighbor.has_node("SpawnPoints/entry_from_room8"), source + " reciprocal arrival exists")
		neighbor.free()
	root.get_node("GameState").new_game()
	root.add_child(room)
	var player = room.get_node("Kaze")
	player.global_position = Vector2(1500, 750)
	player.velocity = Vector2.ZERO
	for i in 12:
		await physics_frame
	_check(player.in_water, "Real water collision enters swimming")
	var neutral_y: float = player.global_position.y
	for i in 30:
		await physics_frame
	_check(absf(player.global_position.y - neutral_y) < 8.0, "Neutral swimming holds depth in authored canal")
	Input.action_press("swim_down")
	for i in 45:
		await physics_frame
	Input.action_release("swim_down")
	_check(player.global_position.y > neutral_y + 60.0, "Live input descends through deep water")
	var deep_y: float = player.global_position.y
	Input.action_press("swim_up")
	for i in 90:
		await physics_frame
	Input.action_release("swim_up")
	_check(player.global_position.y < deep_y - 120.0, "Live input ascends from the deep route")
	room.queue_free()
	for i in 3:
		await process_frame
	print("CANAL CHAMBER REGRESSION: %d failure(s)" % failures)
	quit(1 if failures else 0)
