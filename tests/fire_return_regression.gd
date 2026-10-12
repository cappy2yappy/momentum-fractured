extends SceneTree

var failures := 0

func _init() -> void:
	call_deferred("_run")

func check(ok: bool, message: String) -> void:
	print("PASS: " if ok else "FAIL: ", message)
	if not ok:
		failures += 1

func fire_at_gate(gate: Area2D, element: String) -> void:
	var projectile := Area2D.new()
	projectile.set_script(load("res://scripts/player/kunai_projectile.gd"))
	projectile.element = element
	projectile.position = gate.global_position + Vector2(-100, 0)
	root.add_child(projectile)
	for tick in 14:
		await physics_frame

func _run() -> void:
	await process_frame
	var state := root.get_node("GameState")
	state.new_game()
	var room = load("res://scenes/rooms/room_09_route.tscn").instantiate()
	root.add_child(room)
	await process_frame
	var player = room.get_node("Kaze")
	player.set_physics_process(false)
	var gate = room.get_node("Gates/FireReturnSeal")
	check("fire_return" in state.discovered_gates, "Room entry discovers Fire return on map")
	check(not gate.is_open and gate.blocker.collision_layer == 1, "New game starts with a solid Fire seal")
	check(room.get_node("Doors/ExitDeeper").required_gate_id.is_empty(), "Fire seal never gates mandatory deeper travel")
	check(room.get_node("Doors/ExitShortcut").required_gate_id == "fire_return", "Portal checks persistent seal state against traversal bypass")
	player.position = Vector2(900, 450)
	await physics_frame
	player.move_and_collide(Vector2(200, 0))
	check(player.position.x < 960, "Physical seal stops a high-speed crossing")
	await fire_at_gate(gate, "wind")
	check(not state.is_gate_open("fire_return") and gate.feedback_label.text.contains("Requires Fire"), "Real wrong-element collision explains required Fire")
	await fire_at_gate(gate, "fire")
	check(state.is_gate_open("fire_return") and gate.blocker.collision_layer == 0, "Real Fire collision opens the physical seal")
	state.manual_save()
	state.opened_gates.clear()
	state.discovered_gates.clear()
	check(state.load_from_disk() and state.is_gate_open("fire_return"), "Fire shortcut and map discovery survive save/load")
	room.queue_free()
	await process_frame
	var surface = load("res://scenes/rooms/room_05_route.tscn").instantiate()
	root.add_child(surface)
	await process_frame
	var surface_gate = surface.get_node("Landmarks/ShortcutArch/FireReturnSeal")
	await physics_frame
	check(surface_gate.is_open and surface_gate.blocker.collision_layer == 0, "Surface representation shares opened gate state")
	check(surface.has_node("SpawnPoints/entry_from_room9"), "Return shortcut has a safe directional surface arrival")
	check(surface.get_node("Doors/ExitShortcut").target_spawn_marker == "entry_from_room5", "Surface portal targets reciprocal intake arrival")
	surface.queue_free()
	for tick in 3:
		await process_frame
	state.new_game()
	check(state.opened_gates.is_empty() and state.discovered_gates.is_empty(), "New game clears seal progression")
	print("FIRE RETURN REGRESSION: %d failure(s)" % failures)
	quit(1 if failures else 0)
