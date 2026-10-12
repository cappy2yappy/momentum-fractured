extends SceneTree
var failures = 0
func _init(): call_deferred("_run")
func check(ok, message):
	print("PASS: " if ok else "FAIL: ",message)
	if not ok: failures += 1
func _run():
	await process_frame
	var world = load("res://scenes/main.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	world.set_physics_process(false)
	world.build_room(12)
	var keeper = world.active_enemy
	keeper.set_physics_process(false)
	world.player.set_physics_process(false)
	world.player.position = Vector2(1120,1300)
	world.player.facing = 1
	world.player.parry_time = 0.2
	keeper.begin_attack("sweep")
	check(keeper.state == "windup" and keeper.timer >= 0.9, "Sweep gives a readable phase-one warning")
	keeper._physics_process(0.91)
	keeper._physics_process(0.01)
	check(keeper.state == "stunned" and world.player.hp == 3 and keeper.timer > 1.1, "Correct parry grants a long punish window without damage")
	world.player.parry_time = 0
	world.player.invulnerable = 0
	keeper.begin_attack("sweep")
	keeper._physics_process(0.91)
	keeper._physics_process(0.01)
	check(world.player.hp == 2, "Unparried close sweep deals one normal hit")
	var hp = world.player.hp
	keeper._physics_process(0.01)
	check(world.player.hp == hp, "A strike cannot damage repeatedly")
	world.player.position = Vector2(900,1300)
	world.player.invulnerable = 0
	keeper.begin_attack("sweep")
	keeper._physics_process(0.91)
	keeper._physics_process(0.01)
	check(world.player.hp == hp, "Sweep misses outside its telegraphed reach")
	world.player.position = Vector2(1120,1298)
	world.player.velocity = Vector2.ZERO
	world.player.hitstop = 0
	world.player.set_physics_process(true)
	for tick in 5: await physics_frame
	world.player.set_physics_process(false)
	world.player.invulnerable = 0
	keeper.begin_attack("pulse")
	keeper._physics_process(0.91)
	keeper._physics_process(0.01)
	check(world.player.hp == hp - 1, "Grounded player is vulnerable to the marked ground pulse")
	world.player.hp = 3
	world.player.invulnerable = 0
	world.player.hitstop = 0
	world.player.set_physics_process(true)
	Input.action_press("jump")
	for tick in 8: await physics_frame
	Input.action_release("jump")
	world.player.set_physics_process(false)
	keeper.begin_attack("pulse")
	keeper._physics_process(0.91)
	keeper._physics_process(0.01)
	check(world.player.hp == 3, "A real jump clears the ground pulse using the approved controller")
	keeper.begin_attack("sweep")
	keeper.receive_hit(9)
	check(keeper.phase == 2 and keeper.state == "windup", "Half health activates phase two without light-hit stun-lock")
	keeper.begin_attack("pulse")
	check(is_equal_approx(keeper.timer,0.68), "Phase two accelerates warning timing while retaining a tell")
	keeper.state = "strike"
	keeper.timer = 0
	keeper.strike_done = true
	keeper._physics_process(0.01)
	check(keeper.state == "recover" and keeper.timer >= 0.7, "Phase two still grants recovery openings")
	world.player.position = Vector2(2440,1300)
	keeper.state = "patrol"
	var original_x = keeper.position.x
	keeper._physics_process(0.1)
	check(keeper.position.x > original_x, "Keeper pursues a ranged attacker after being engaged")
	keeper.receive_hit(9)
	await process_frame
	check(world.cleared_encounters.get("storm_keeper",false) and not world.boss_defeated, "Keeper victory is independent of Tide Warden progression")
	world.queue_free()
	current_scene = null
	for tick in 3: await process_frame
	print("STORM KEEPER: %d failure(s)" % failures)
	quit(1 if failures else 0)
