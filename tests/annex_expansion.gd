extends SceneTree
var failures = 0
var world
func _init(): call_deferred("_run")
func check(ok, message):
	print("PASS: " if ok else "FAIL: ", message)
	if not ok: failures += 1
func freeze_enemies():
	for enemy in world.enemies: enemy.set_physics_process(false)
func shoot(element, at, direction):
	world.spawn_kunai(element, direction, at)
	for tick in 20: await physics_frame
func _run():
	await process_frame
	world = load("res://scenes/main.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	world.set_physics_process(false)
	world.player.set_physics_process(false)
	check(world.ROOM_COUNT == 10, "Two annex rooms extend the approved route")
	for index in 10:
		world.build_room(index)
		freeze_enemies()
		check(world.platforms.size() >= 6 and world.room_discovery_level(index) == 2, "Room %d geometry and MetSys discovery load" % index)
	world.build_room(7)
	check(not world.can_enter(8), "Annexes await original relay completion")
	world.player.position = Vector2(2200, 1300)
	world.interact()
	check(world.completed and world.can_enter(8), "Original relay now opens the annex route")
	world.player.double_jump = true
	world.player.tether_unlocked = true
	world.player.dash_unlocked = true
	for element in ["wind", "fire", "electric"]: world.player.unlock_kunai(element)
	world.request_room(8)
	for tick in 45:
		world._physics_process(1.0 / 60.0)
		await physics_frame
	check(world.room == 8 and world.player.position.x > 150, "Original transition sequence reaches the Undercroft")
	world.player.set_physics_process(false)
	freeze_enemies()
	world.player.position = Vector2(1470, 690)
	world.extension.update_progress(world)
	check(world.relay_fragments.size() == 1, "Undercroft sigil is collectible once")
	world.extension.update_progress(world)
	check(world.relay_fragments.size() == 1, "Repeated overlap cannot duplicate a sigil")
	world.player.position = Vector2(2060, 1300)
	world.interact()
	check(world.checkpoint_room == 8 and world.checkpoint_position == Vector2(2060, 1298), "New shrine records its exact safe spawn")
	world.build_room(9)
	freeze_enemies()
	world.player.set_physics_process(false)
	world.player.position = Vector2(1490, 600)
	world.extension.update_progress(world)
	world.player.position = Vector2(2240, 770)
	world.extension.update_progress(world)
	check(world.relay_fragments.size() == 2, "Fire cache rejects collection through a bypass")
	await shoot("wind", Vector2(2000, 758), 1)
	check(not world.opened_kunai_gates.get("terrace_fire_cache", false), "Real Wind projectile cannot open the Fire cache")
	await shoot("fire", Vector2(2000, 758), 1)
	check(world.opened_kunai_gates.get("terrace_fire_cache", false), "Real Fire projectile opens the cache")
	world.extension.update_progress(world)
	check(world.relay_fragments.size() == 3, "Opened cache completes the three-sigil side objective")
	world.player.position = Vector2(160, 620)
	world.interact()
	check(world.pending_room == -1, "Shortcut door checks its Electric seal even after a geometry bypass")
	await shoot("electric", Vector2(470, 568), -1)
	check(world.opened_kunai_gates.get("terrace_return_relay", false), "Real Electric projectile opens the return")
	world.interact()
	for tick in 45:
		world._physics_process(1.0 / 60.0)
		await physics_frame
	check(world.room == 3 and absf(world.player.position.x - 2100) < 2, "Return reaches Echo Shrine at its dedicated safe landing")
	world.player.set_physics_process(false)
	world.player.position = Vector2(2250, 790)
	world.interact()
	for tick in 45:
		world._physics_process(1.0 / 60.0)
		await physics_frame
	check(world.room == 9 and absf(world.player.position.x - 480) < 2, "Reciprocal return lands safely on the terrace")
	world.player.set_physics_process(false)
	freeze_enemies()
	world.hud.toggle_loadout()
	check(paused and world.hud.loadout_open and not world.hud.map_open, "Kit pauses gameplay exclusively")
	world.hud.select_loadout_at(Vector2(750, 420))
	check(world.player.selected_kunai == "fire", "Kit selection equips unlocked Fire Kunai")
	world.hud.toggle_map()
	check(paused and world.hud.map_open and not world.hud.loadout_open, "Atlas replaces kit without unpausing")
	world.hud.toggle_pause()
	check(paused and world.hud.pause_open and not world.hud.map_open, "Pause replaces atlas")
	world.hud.toggle_pause()
	check(not paused, "Closing the last overlay resumes play")
	check(world.hud.touch_buttons.has("kunai") and world.hud.touch_buttons.has("cycle_kunai"), "Touch controls expose both elemental actions")
	world.player.tether_attached = true
	world.player.attack_time = 0.3
	world.player.dash_time = 0.18
	world.spawn_kunai("fire", 1, Vector2(1700, 700))
	world.build_room(8)
	await process_frame
	check(not world.player.tether_attached and world.player.attack_time == 0 and world.player.dash_time == 0, "Room rebuild clears stale transient actions without editing the controller")
	var projectile_exists = false
	for child in world.get_children():
		if child.get_script() == world.Kunai: projectile_exists = true
	check(not projectile_exists, "Room changes discard old projectiles")
	world.transition = 0.5
	world.pending_room = 9
	world.player.hp = 0
	world.respawn()
	check(world.room == 8 and world.player.position == Vector2(2060, 1298) and world.player.hp == 3 and world.pending_room == -1, "Death during a transition safely restores the earned shrine")
	world.player.set_physics_process(false)
	world.queue_free()
	current_scene = null
	for tick in 3: await process_frame
	print("ANNEX EXPANSION: %d failure(s)" % failures)
	quit(1 if failures else 0)
