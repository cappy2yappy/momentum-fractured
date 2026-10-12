extends SceneTree

## Deterministic input/physics assertions; this does not grade subjective feel
## or certify rendered 60 FPS. Run tools/validate_recovery.py for isolated saves.

var failures := 0
var checks := 0


func _init() -> void:
	call_deferred("_run")


func _check(condition: bool, message: String) -> void:
	checks += 1
	print("PASS: " if condition else "FAIL: ", message)
	if not condition:
		failures += 1


func _frames(count: int = 1) -> void:
	for _index in count:
		await physics_frame
		await process_frame


func _tap(action: String) -> void:
	Input.action_press(action)
	await process_frame
	await process_frame
	Input.action_release(action)
	await process_frame
	await process_frame


func _escape() -> void:
	var event := InputEventKey.new()
	event.keycode = KEY_ESCAPE
	event.physical_keycode = KEY_ESCAPE
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	await process_frame
	event = InputEventKey.new()
	event.keycode = KEY_ESCAPE
	event.physical_keycode = KEY_ESCAPE
	Input.parse_input_event(event)
	await process_frame
	await process_frame


func _release_inputs() -> void:
	for action in ["move_left", "move_right", "jump", "dash", "grapple", "map", "character_menu"]:
		Input.action_release(action)


func _run() -> void:
	create_timer(40.0).timeout.connect(func() -> void:
		print("FAIL: Live motion regression exceeded its 40 second watchdog")
		quit(2)
	)
	await process_frame
	var state := root.get_node("GameState")
	var save_file := String(state.get("save_path"))
	if not save_file.is_absolute_path() or save_file.begins_with("user://"):
		print("FAIL: This suite requires -- --test-save-path=<absolute isolated file>")
		quit(1)
		return
	state.call("new_game")
	await _movement_fixture()
	await _doors_and_hud()
	_release_inputs()
	paused = false
	print("LIVE MOTION REGRESSION: %d failure(s), %d checks; input/physics only, subjective feel and rendered FPS unassessed" % [failures, checks])
	quit(1 if failures else 0)


func _movement_fixture() -> void:
	var world := Node2D.new()
	world.name = "LiveMotionFixture"
	root.add_child(world)
	current_scene = world
	var floor_body := StaticBody2D.new()
	floor_body.position = Vector2(1000.0, 600.0)
	var collision := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(6000.0, 32.0)
	collision.shape = rectangle
	floor_body.add_child(collision)
	world.add_child(floor_body)
	var player = load("res://scenes/kaze.tscn").instantiate()
	player.position = Vector2(420.0, 500.0)
	world.add_child(player)
	await _frames(30)
	_check(player.is_on_floor(), "Actual player settles onto fixture collision geometry")
	var start := Vector2(player.position)
	Input.action_press("move_right")
	await _frames(1)
	_check(player.velocity.x > 0.0 and player.position.x > start.x, "Right input changes velocity and position within the next physics step")
	await _frames(8)
	_check(player.velocity.x >= 300.0 and player.velocity.x <= 340.01, "Held right input reaches the configured ground speed without overshoot")
	Input.action_release("move_right")
	await _frames(8)
	_check(absf(player.velocity.x) < 0.01, "Released ground movement stops within eight physics frames")
	Input.action_press("move_left")
	await _frames(8)
	_check(player.velocity.x < -300.0, "Opposite input responds with leftward movement")
	Input.action_release("move_left")
	await _frames(8)
	var short_height := await _jump_height(player, 1)
	var held_height := await _jump_height(player, 30)
	_check(short_height > 35.0, "A tapped grounded jump produces measurable ascent (%.2f px)" % short_height)
	_check(held_height > short_height + 45.0, "Holding jump increases actual apex height (short %.2f, held %.2f px)" % [short_height, held_height])
	_check(player.is_on_floor(), "Held jump returns to the physical floor without a forced reset")
	var before_dash := Vector2(player.position)
	Input.action_press("move_right")
	Input.action_press("dash")
	await _frames(1)
	_check(bool(player.get("is_dashing")) and player.velocity.x >= 1000.0, "Real dash input starts a high-speed movement window")
	Input.action_release("dash")
	await _frames(6)
	_check(player.position.x - before_dash.x > 85.0, "Dash traverses physical space over its active frames")
	await _frames(8)
	_check(not bool(player.get("is_dashing")), "Dash ends after its bounded duration")
	Input.action_release("move_right")
	await _frames(30)
	await _tether_motion(world, player)
	var sample_start := Time.get_ticks_usec()
	await _frames(60)
	print("MEASUREMENT: 60 headless physics frames sampled in %.3f seconds; rendered performance unmeasured" % [(Time.get_ticks_usec() - sample_start) / 1000000.0])
	current_scene = null
	world.queue_free()
	await _frames(2)


func _jump_height(player: CharacterBody2D, held_frames: int) -> float:
	_release_inputs()
	player.call("respawn", Vector2(420.0, 560.0))
	await _frames(6)
	var start_y := player.position.y
	var minimum_y := start_y
	Input.action_press("jump")
	await _frames(1)
	_check(player.velocity.y < -500.0 and not player.is_on_floor(), "Grounded jump input launches upward immediately (%d held frames)" % held_frames)
	minimum_y = minf(minimum_y, player.position.y)
	for frame_index in range(1, 80):
		if frame_index == held_frames:
			Input.action_release("jump")
		await _frames(1)
		minimum_y = minf(minimum_y, player.position.y)
	Input.action_release("jump")
	return start_y - minimum_y


func _tether_motion(world: Node2D, player: CharacterBody2D) -> void:
	player.call("respawn", Vector2(800.0, 470.0))
	var anchor := Node2D.new()
	anchor.position = Vector2(880.0, 230.0)
	anchor.add_to_group("grapple_anchor")
	world.add_child(anchor)
	var mouse := InputEventMouseMotion.new()
	mouse.position = anchor.global_position
	mouse.global_position = mouse.position
	Input.parse_input_event(mouse)
	await process_frame
	# Headless platforms may ignore synthetic cursor coordinates. Place this
	# authored fixture at the cursor Godot actually reports, keeping the
	# grapple action and every swing step on the real input/physics path.
	var actual_aim := player.get_global_mouse_position()
	if actual_aim.distance_to(anchor.global_position) > 1.0:
		print("FIXTURE: Headless cursor reports %s; anchor placed at that world position" % actual_aim)
		anchor.position = actual_aim
		player.call("respawn", actual_aim + Vector2(-80.0, 240.0))
	Input.action_press("grapple")
	Input.action_press("move_right")
	await _frames(1)
	_check(bool(player.get("grapple_active")), "Real grapple input attaches to the aimed authored anchor")
	var initial_angle := (player.global_position - anchor.global_position).angle()
	var max_distance := 0.0
	for _index in 18:
		await _frames(1)
		max_distance = maxf(max_distance, player.global_position.distance_to(anchor.global_position))
	_check(bool(player.get("grapple_active")), "Tether stays attached while grapple input remains held")
	_check(absf(angle_difference(initial_angle, (player.global_position - anchor.global_position).angle())) > 0.08, "Held directional input changes the actual tether swing angle")
	_check(max_distance <= float(player.get("grapple_length")) + 2.0, "Swing remains inside its rope-length constraint")
	Input.action_release("move_right")
	var before := player.velocity
	Input.action_release("grapple")
	await _frames(1)
	_check(not bool(player.get("grapple_active")), "Releasing actual grapple input detaches the tether")
	_check(player.velocity.length() > 80.0 and absf(player.velocity.x - before.x) < 25.0, "Tether release preserves horizontal swing momentum apart from normal air drag (before %s, after %s)" % [before, player.velocity])
	anchor.queue_free()


func _doors_and_hud() -> void:
	var state := root.get_node("GameState")
	state.call("new_game")
	var navigator := root.get_node("SceneNavigator")
	navigator.set("fade_duration", 0.02)
	navigator.call("goto_scene", "res://scenes/rooms/room_04_checkpoint.tscn", "entry_from_room3")
	await _wait_transition()
	_check(current_scene != null and current_scene.scene_file_path.ends_with("room_04_checkpoint.tscn"), "SceneNavigator actually loads the checkpoint room")
	if current_scene == null:
		return
	var room := current_scene
	var player := room.get_node("Kaze") as CharacterBody2D
	player.set_physics_process(false)
	await _frames(20)
	var hud := room.get_node("HUD")
	var mini_map := hud.get_node("MiniMapPanel/VBox/Map")
	var full_map := hud.get_node("MapOverlay/Content/Map")
	_check(state.call("has_visited_room", "room_04_checkpoint"), "Actual scene entry records its surveyed room")
	_check(mini_map.get("current_room_id") == "room_04_checkpoint" and full_map.get("current_room_id") == "room_04_checkpoint", "Minimap and full map identify the actual current room after scene loading")
	_check(String(hud.get_node("MiniMapPanel/VBox/RoomName").text).contains("Room04Checkpoint"), "HUD room-name text resolves after an actual scene transition")
	player.call("take_damage", 12.0)
	state.call("add_cells", 7)
	await process_frame
	_check(hud.get_node("HealthBar/Panel/VBox/HealthFill").value == 88.0, "HUD health bar follows actual player damage")
	_check(hud.get_node("CellCounter/Panel/HBox/Value").text == "7", "HUD cell counter follows progression state")
	var map_overlay := hud.get_node("MapOverlay") as Control
	var loadout := hud.get_node("CharacterPanel") as Control
	var pause_menu := hud.get_node("PauseMenu") as Control
	await _tap("map")
	_check(map_overlay.visible and paused, "Map input opens the full map and pauses gameplay")
	var feedback := root.get_node("CombatFeedback")
	feedback.call("hit_pause", 0.03)
	await _frames(6)
	_check(not bool(feedback.get("_hit_pause_active")) and map_overlay.visible and paused, "Expired combat hit-pause preserves the open map's gameplay pause")
	await _tap("character_menu")
	_check(loadout.visible and not map_overlay.visible and paused, "Loadout input switches from map to character information while paused")
	_check(String(hud.get_node("CharacterPanel/Content/Stats").text).contains("88 / 100"), "Loadout reports the current damaged health")
	await _tap("character_menu")
	_check(not loadout.visible and not paused, "Closing the loadout resumes gameplay")
	await _escape()
	_check(pause_menu.visible and paused, "Escape opens the actual pause menu")
	await _escape()
	_check(not pause_menu.visible and not paused, "Escape closes the pause menu and resumes gameplay")
	await _escape()
	await _tap("map")
	await _escape()
	_check(not (map_overlay.visible or loadout.visible or pause_menu.visible) or paused, "Interleaved Escape and map input cannot leave a visible overlay with gameplay unpaused")
	# Normalize only fixture UI state so later door checks remain independent.
	map_overlay.hide()
	loadout.hide()
	pause_menu.hide()
	paused = false
	var exit := room.get_node("Environment/LeftDoor") as Area2D
	player.global_position = exit.global_position
	await _wait_transition(true, true)
	_check(current_scene != null and current_scene.scene_file_path.ends_with("room_03_mixed.tscn"), "Physical left-door overlap transitions Room 4 to Room 3")
	if current_scene != null and current_scene != room:
		var restored := current_scene.get_node("Kaze") as CharacterBody2D
		restored.set_physics_process(false)
		var marker := current_scene.get_node("SpawnPoints/entry_from_room4") as Marker2D
		_check(restored.global_position.distance_to(marker.global_position) < 8.0, "Door transition arrives at the reciprocal authored marker (actual %s, expected %s)" % [restored.global_position, marker.global_position])
		_check(is_equal_approx(float(restored.call("get_current_health")), 88.0), "Door transition preserves health from the departing room")
		_check(state.call("has_visited_room", "room_03_mixed") and state.call("has_visited_room", "room_04_checkpoint"), "Survey state preserves both rooms after backtracking")
	var loaded_room := current_scene
	current_scene = null
	if loaded_room:
		loaded_room.queue_free()
	await _frames(2)


func _wait_transition(wait_for_start: bool = false, freeze_arrival: bool = false) -> void:
	var navigator := root.get_node("SceneNavigator")
	var starting_scene := current_scene
	for index in 100:
		await _frames(1)
		if freeze_arrival and current_scene != null and current_scene != starting_scene:
			var player := current_scene.get_node_or_null("Kaze")
			if player:
				player.set_physics_process(false)
		if not bool(navigator.get("is_transitioning")) and (not wait_for_start or index > 12):
			return
	_check(false, "Scene transition completes within 100 physical frames")
