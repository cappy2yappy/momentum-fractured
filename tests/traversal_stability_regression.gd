extends SceneTree

var failures := 0
func _init() -> void:
	call_deferred("_run")
func check(ok: bool, message: String) -> void:
	print("PASS: " if ok else "FAIL: ", message)
	if not ok:
		failures += 1
func settle_transition() -> void:
	await create_timer(0.75).timeout

func _run() -> void:
	await process_frame
	root.get_node("GameState").new_game()
	var state := root.get_node("GameState")
	var navigator := root.get_node("SceneNavigator")
	navigator.goto_scene("res://scenes/rooms/room_09_route.tscn", "entry_from_room8")
	await settle_transition()
	check(current_scene != null and current_scene.name == "FireReturnIntake", "Navigator loads the authored return intake")
	var player = current_scene.get_node("Kaze")
	player.set_physics_process(false)
	var shortcut = current_scene.get_node("Doors/ExitShortcut")
	shortcut._cooldown_timer = 0.0
	shortcut._on_body_entered(player)
	check(not navigator.is_transitioning, "Locked portal rejects crossing even if player bypasses physical gate")
	state.open_gate("fire_return")
	shortcut._on_body_entered(player)
	await settle_transition()
	check(current_scene.name == "CompactSurfaceApproach", "Opened portal actually transitions to surface")
	player = current_scene.get_node("Kaze")
	player.set_physics_process(false)
	var arrival = current_scene.get_node("SpawnPoints/entry_from_room9")
	print("SURFACE ARRIVAL: ", player.position, " marker: ", arrival.position)
	check(player.position.distance_to(arrival.position) < 45, "Shortcut arrives safely outside the reciprocal portal trigger")
	check(not navigator.is_transitioning, "Arrival does not immediately bounce to intake")
	shortcut = current_scene.get_node("Doors/ExitShortcut")
	shortcut._cooldown_timer = 0.0
	shortcut._on_body_entered(player)
	await settle_transition()
	check(current_scene.name == "FireReturnIntake", "Surface portal returns to intake")
	player = current_scene.get_node("Kaze")
	player.set_physics_process(false)
	check(player.position.distance_to(current_scene.get_node("SpawnPoints/entry_from_room5").position) < 45, "Reciprocal shortcut spawn lands on return ledge")
	print("INTAKE ARRIVAL: ", player.position, " marker: ", current_scene.get_node("SpawnPoints/entry_from_room5").position)
	state.set_checkpoint("res://scenes/rooms/room_07_route.tscn", "spawn_checkpoint")
	navigator.goto_scene("res://scenes/rooms/room_10_route.tscn", "spawn_default")
	await settle_transition()
	player = current_scene.get_node("Kaze")
	player.die()
	await settle_transition()
	check(current_scene.name == "UndergroundThreshold", "Death in generated route returns to authored checkpoint")
	player = current_scene.get_node("Kaze")
	check(not player.is_dead and player.get_current_health() > 0, "Checkpoint restores a living player")
	player.position = Vector2(2000, 1300)
	await physics_frame
	await settle_transition()
	check(current_scene.name == "UndergroundThreshold" and current_scene.get_node("Kaze").position.y < 1100, "Out-of-bounds failure recovers through checkpoint")
	current_scene.queue_free()
	current_scene = null
	await create_timer(0.3).timeout
	print("TRAVERSAL STABILITY REGRESSION: %d failure(s)" % failures)
	quit(1 if failures else 0)
