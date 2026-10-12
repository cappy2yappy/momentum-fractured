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
	world.player.set_physics_process(false)
	world.build_room(1)
	for enemy in world.enemies: enemy.set_physics_process(false)
	var guard = world.guard
	world.player.position = Vector2(1030, 1300)
	world.player.facing = 1
	var hp = guard.hp
	world.on_strike(1, 95)
	check(guard.hp == hp - 1, "Approved facing-aware melee connects at its existing reach")
	world.player.hp = 3
	world.player.parry_time = 0.2
	guard.state = "strike"
	guard.strike_done = false
	guard.timer = 0.16
	guard._physics_process(0.01)
	check(guard.state == "stunned" and world.player.hp == 3, "Approved parry stuns the facing attacker without damage")
	world.player.parry_time = 0.0
	world.player.invulnerable = 0.0
	guard.state = "strike"
	guard.strike_done = false
	guard.timer = 0.16
	guard._physics_process(0.01)
	check(world.player.hp == 2 and world.player.invulnerable > 1.0, "Missed parry keeps the approved damage and protection window")
	world.build_room(4)
	for enemy in world.enemies: enemy.set_physics_process(false)
	world.player.hitstop = 0.0
	world.player.tether_unlocked = true
	world.player.position = Vector2(1190, 900)
	world.player.velocity = Vector2(300, 80)
	var anchor = world.tether_anchors[1]
	check(world.player.apply_tether(anchor), "Approved in-range forward anchor accepts tether")
	for tick in 10: world.player.integrate_tether_swing(1.0 / 60.0, 1.0)
	check(world.player.tether_attached and world.player.tether_origin().distance_to(anchor) <= world.player.tether_length + 0.1, "Approved integrator maintains rope length while pumping")
	var exit_velocity = world.player.velocity
	world.player.release_tether()
	check(world.player.velocity == exit_velocity, "Approved swing release retains its exact velocity")
	world.player.press("attack")
	world.player.press("attack")
	check(world.player.queued and world.player.combo == 0, "Approved combo queues a follow-up during recovery")
	world.queue_free()
	current_scene = null
	for tick in 3: await process_frame
	print("APPROVED COMBAT SWING: %d failure(s)" % failures)
	quit(1 if failures else 0)
