extends SceneTree
var failures = 0
func _init(): call_deferred("_run")
func check(ok, message):
	print("PASS: " if ok else "FAIL: ", message)
	if not ok: failures += 1
func _run():
	await process_frame
	var world = load("res://scenes/main.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	world.set_physics_process(false)
	check(world.ROOM_COUNT >= 8, "Approved eight-room foundation remains present")
	check(world.player.hp == 3 and not world.player.double_jump, "Original starting progression is intact")
	check(FileAccess.get_sha256("res://scripts/player.gd") == "58a1c319183a993bde9abc6f639b4adaefe245f89de24e6f0f9338bc9519339d", "Approved controller is byte-for-byte unchanged")
	var approved = JSON.parse_string(FileAccess.get_file_as_string("res://docs/APPROVED_GEOMETRY.json"))
	for index in 8:
		world.build_room(index)
		world.player.set_physics_process(false)
		var signature = []
		for rect in world.platforms: signature.append([rect.position.x, rect.position.y, rect.size.x, rect.size.y])
		check(JSON.stringify(signature) == JSON.stringify(approved[str(index)].platforms), "Room %d original collision geometry is unchanged" % index)
		check(world.platforms.size() >= 6, "Room %d loads original geometry" % index)
		check(world.room_discovery_level(index) == 2, "Room %d registers MetSys exploration" % index)
	world.build_room(0)
	world.player.position = Vector2(220, 1298)
	world.player.velocity = Vector2.ZERO
	world.player.set_physics_process(true)
	for tick in 4: await physics_frame
	Input.action_press("right")
	for tick in 30: await physics_frame
	Input.action_release("right")
	print("METRIC: walk_velocity=", world.player.velocity.x)
	check(is_equal_approx(world.player.velocity.x, 400.0), "Approved walk speed reaches 400")
	for tick in 20: await physics_frame
	world.player.position = Vector2(220, 1298)
	world.player.velocity = Vector2.ZERO
	for tick in 4: await physics_frame
	var floor_y = world.player.position.y
	Input.action_press("jump")
	var minimum_y = floor_y
	for tick in 40:
		await physics_frame
		minimum_y = minf(minimum_y, world.player.position.y)
	Input.action_release("jump")
	print("METRIC: held_jump_height=", floor_y - minimum_y)
	check(floor_y - minimum_y > 230 and floor_y - minimum_y < 236, "Approved held jump height remains in its measured band")
	world.player.set_physics_process(false)
	world.hud.toggle_map()
	check(paused and world.hud.map_open, "MetSys atlas pauses gameplay")
	world.hud.toggle_pause()
	check(paused and world.hud.pause_open and not world.hud.map_open, "Pause replaces atlas")
	world.hud.toggle_pause()
	check(not paused, "Closing pause resumes gameplay")
	world.queue_free()
	current_scene = null
	for tick in 3: await process_frame
	print("APPROVED BASELINE: %d failure(s)" % failures)
	quit(1 if failures else 0)
