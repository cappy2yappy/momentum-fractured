extends SceneTree
var failures = 0
var world
func _init(): call_deferred("_run")
func check(ok, message):
	print("PASS: " if ok else "FAIL: ", message)
	if not ok: failures += 1
func probe(room, start, target: Rect2, second_jump):
	world.player.set_physics_process(false)
	world.build_room(room)
	for enemy in world.enemies: enemy.set_physics_process(false)
	await process_frame
	world.player.position = start
	world.player.velocity = Vector2.ZERO
	world.player.jump_buffer = 0.0
	world.player.double_jump = true
	world.player.set_physics_process(true)
	for tick in 6: await physics_frame
	Input.action_press("right")
	Input.action_press("jump")
	var landed = false
	for tick in 100:
		if second_jump and tick == 15:
			Input.action_release("jump")
			await physics_frame
			Input.action_press("jump")
		await physics_frame
		if tick > 18 and world.player.is_on_floor() and world.player.position.x >= target.position.x and world.player.position.x <= target.end.x and absf(world.player.position.y - target.position.y) < 4:
			landed = true
			break
	Input.action_release("right")
	Input.action_release("jump")
	print("LANDING: ", world.player.position)
	check(landed, "Room %d live jump reaches %s" % [room, target.position])
func _run():
	await process_frame
	world = load("res://scenes/main.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	world.set_physics_process(false)
	await probe(8, Vector2(600, 1108), Rect2(770, 920, 340, 40), true)
	await probe(8, Vector2(1050, 918), Rect2(1300, 740, 340, 40), true)
	await probe(9, Vector2(1110, 848), Rect2(1360, 640, 400, 40), true)
	await probe(9, Vector2(1660, 638), Rect2(1980, 810, 480, 40), false)
	await probe(10, Vector2(1180, 828), Rect2(1400, 620, 360, 40), true)
	await probe(11, Vector2(1410, 778), Rect2(1500, 560, 400, 40), true)
	world.player.set_physics_process(false)
	world.queue_free()
	current_scene = null
	for tick in 3: await process_frame
	print("ANNEX TRAVERSAL: %d failure(s)" % failures)
	quit(1 if failures else 0)
