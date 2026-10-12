extends SceneTree
var failures = 0
var world
func _init(): call_deferred("_run")
func check(ok, message):
	print("PASS: " if ok else "FAIL: ", message)
	if not ok: failures += 1
func freeze():
	world.player.set_physics_process(false)
	for enemy in world.enemies: enemy.set_physics_process(false)
func shoot(element, at):
	world.spawn_kunai(element, 1, at)
	for tick in 20: await physics_frame
func transition():
	for tick in 45:
		world._physics_process(1.0/60.0)
		await physics_frame
	freeze()
func _run():
	await process_frame
	world = load("res://scenes/main.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	world.set_physics_process(false)
	freeze()
	check(world.ROOM_COUNT == 13, "SkyWorks expands the accepted route to thirteen rooms")
	for index in 13:
		world.build_room(index)
		freeze()
		check(world.platforms.size() >= 6 and world.room_discovery_level(index) == 2, "Room %d loads collision, anchors and MetSys survey" % index)
	world.build_room(9)
	freeze()
	check(not world.can_enter(10), "SkyWorks requires three earned relay sigils")
	for id in ["undercroft_sigil", "terrace_west", "terrace_fire_cache"]: world.relay_fragments[id] = true
	world.player.double_jump = true
	world.player.tether_unlocked = true
	world.player.dash_unlocked = true
	world.completed = true
	check(world.can_enter(10), "Earned sigils open the new region")
	world.request_room(10)
	await transition()
	check(world.room == 10 and world.player.position.x == 230, "Actual transition reaches the SkyWorks entrance")
	check(not world.can_enter(11), "Wind seal cannot be bypassed at the route door")
	await shoot("fire", Vector2(2000, 758))
	check(not world.opened_kunai_gates.get("skyworks_wind_intake", false), "Wrong element does not release intake")
	await shoot("wind", Vector2(2000, 758))
	check(world.can_enter(11), "Live Wind projectile opens the Foundry route")
	world.request_room(11)
	await transition()
	check(world.room == 11, "Foundry transition completes")
	world.player.position = Vector2(1720,1300)
	world.interact()
	check(world.checkpoint_room == 11 and world.checkpoint_position == Vector2(1720,1298), "Foundry Refuge saves an exact recovery point")
	check(not world.can_enter(12), "Electric relay locks the Keeper approach")
	await shoot("electric", Vector2(2250,708))
	check(world.can_enter(12), "Live Electric projectile opens the arena")
	world.request_room(12)
	await transition()
	check(world.room == 12 and is_instance_valid(world.active_enemy), "Keeper spawns on entering the arena")
	world.player.position = Vector2(2220,1300)
	world.interact()
	check(not world.skyworks_restored, "Relay cannot be attuned before the Keeper is defeated")
	world.active_enemy.receive_hit(18)
	await process_frame
	check(world.cleared_encounters.get("storm_keeper",false), "Keeper defeat is recorded persistently")
	world.interact()
	check(world.skyworks_restored and world.checkpoint_room == 12, "Explicit attunement completes the SkyWorks objective")
	world.player.position = Vector2(220,830)
	world.interact()
	await transition()
	check(world.room == 8 and world.player.position.x == 1590, "Keeper return reaches the accepted Undercroft landing")
	world.player.position = Vector2(1470,740)
	world.interact()
	await transition()
	check(world.room == 12 and world.player.position.x == 430, "Keeper return works in both directions")
	check(world.active_enemy == null, "Defeated Keeper does not respawn on backtracking")
	world.save_path = "user://skyworks_regression_only.json"
	world.test_mode = false
	world.save_progress()
	world.test_mode = true
	world.skyworks_restored = false
	world.cleared_encounters.clear()
	world.opened_kunai_gates.clear()
	world.load_progress()
	check(world.skyworks_restored and world.cleared_encounters.get("storm_keeper",false) and world.opened_kunai_gates.get("foundry_electric_relay",false), "Save/reload retains Keeper, attunement and regional seals")
	var data = JSON.parse_string(FileAccess.get_file_as_string(world.save_path))
	data.version = 5
	data.erase("skyworks_restored")
	data.visited.resize(10)
	var file = FileAccess.open(world.save_path,FileAccess.WRITE)
	file.store_string(JSON.stringify(data));file.close()
	world.load_progress()
	check(not world.skyworks_restored and world.relay_fragments.size() == 3, "Accepted 0.5.1 saves retain sigils while new story state initializes safely")
	world.queue_free()
	current_scene = null
	for tick in 3: await process_frame
	print("SKYWORKS PROGRESSION: %d failure(s)" % failures)
	quit(1 if failures else 0)
