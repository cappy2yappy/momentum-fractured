extends SceneTree
var failures = 0
var w
func _init(): call_deferred("run")
func check(ok, message):
	print("PASS: " if ok else "FAIL: ", message)
	if not ok: failures += 1
func write_save(data):
	var file = FileAccess.open(w.save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data)); file.close()
func freeze():
	w.set_physics_process(false); w.player.set_physics_process(false)
	for enemy in w.enemies: enemy.set_physics_process(false)
func run():
	await process_frame
	w = load("res://scenes/main.tscn").instantiate(); root.add_child(w); current_scene = w; freeze()
	w.save_path = "user://gp01_stabilization.json"
	w.build_room(19); freeze()
	var gate = w.Expansion.GATES[19]
	w.opened_kunai_gates.erase(gate[0])
	var shot = w.Kunai.new(); shot.world = w; shot.element = "fire"
	shot.position = gate[2] - Vector2(50, 60); w.add_child(shot); shot.set_physics_process(false)
	shot._physics_process(0.12)
	check(w.opened_kunai_gates.get(gate[0], false), "Fire projectile cannot tunnel through 30px seal during 120ms physics step")
	await process_frame
	w.build_room(19); freeze(); w.opened_kunai_gates.erase(gate[0])
	shot = w.Kunai.new(); shot.world = w; shot.element = "wind"
	shot.position = gate[2] - Vector2(50, 60); w.add_child(shot); shot.set_physics_process(false); shot._physics_process(0.12)
	check(not w.opened_kunai_gates.get(gate[0], false) and shot.is_queued_for_deletion(), "Wrong element is consumed at crossed seal without opening it")
	await process_frame
	w.build_room(1); freeze()
	var enemy = w.guard; var old_hp = enemy.hp
	shot = w.Kunai.new(); shot.world = w; shot.position = enemy.position + Vector2(-100, -50)
	w.add_child(shot); shot.set_physics_process(false); shot._physics_process(0.25)
	check(enemy.hp == old_hp - 1 and shot.is_queued_for_deletion(), "Long-step projectile hits crossed enemy exactly once")
	await process_frame
	# Valid sparse saves must replace state, not retain a previously loaded profile.
	w.opened_kunai_gates["relay_electric_seal"] = true; w.relay_fragments["terrace_fire_cache"] = true
	w.cleared_encounters["expansion_guard_13"] = true; w.player.kunai_unlocked.fire = true; w.visited.fill(true)
	write_save({"version": 8, "kunai_unlocked": {"wind": true}, "selected_kunai": "fire"})
	w.load_progress()
	check(w.relay_fragments.is_empty() and w.cleared_encounters.is_empty(), "Sparse valid save clears stale reward and encounter flags")
	check(w.player.selected_kunai == "wind" and not w.player.kunai_unlocked.fire, "Load normalizes selected locked element to an earned element")
	check(w.visited[0] and not w.visited[20], "Sparse save cannot retain stale discovery")
	# Incorrect field shapes and string booleans must fail closed, not throw.
	write_save({"version": 8, "opened_kunai_gates": [], "relay_fragments": [], "cleared_encounters": [], "kunai_unlocked": [], "visited": [], "metsys": {"discovered_cells": 7, "stored_objects": [], "custom_markers": false}, "checkpoint_room": "bad", "checkpoint_position": [null, {}]})
	w.load_progress()
	check(w.opened_kunai_gates.is_empty() and w.relay_fragments.is_empty() and w.cleared_encounters.is_empty(), "Malformed collection fields load safely as empty state")
	check(w.checkpoint_room == 0 and w.checkpoint_position == Vector2(220, 1298), "Malformed checkpoint falls back to safe Haven")
	check(not w.player.kunai_unlocked.values().has(true), "Malformed ability collection cannot retain old unlocks")
	write_save({"version": 8, "double_jump": "false", "tether_unlocked": "false", "dash_unlocked": "false", "completed": "false", "opened_kunai_gates": {"skyworks_wind_intake": "false"}, "expansion_flags": {"junction_return": "false"}, "kunai_unlocked": {"fire": "false"}})
	w.load_progress()
	check(not w.completed and not w.player.double_jump and not w.player.tether_unlocked and not w.player.dash_unlocked, "String flags do not grant traversal or story progress")
	check(not w.opened_kunai_gates.get("skyworks_wind_intake", false) and not w.expansion_flags.get("junction_return", false) and not w.player.kunai_unlocked.fire, "String flags do not open elemental seals or returns")
	write_save({"version": 8, "double_jump": true, "kunai_unlocked": {"wind": true,"fire": true}, "selected_kunai": "fire", "checkpoint_room":16, "checkpoint_position":[420,1118], "opened_kunai_gates":{"coil_fire_service":true}, "metsys":{"discovered_cells":[[5,2,0,2],"bad",[null,0,0,2]],"custom_markers":[[5,2,0,1]],"stored_objects":{"valid":true,"invalid":"false"}}})
	w.load_progress()
	check(w.player.double_jump and w.player.kunai_unlocked.fire and w.player.selected_kunai == "fire", "Valid earned kit and selection are preserved")
	check(w.checkpoint_room == 16 and w.checkpoint_position == Vector2(420,1118) and w.opened_kunai_gates.get("coil_fire_service",false), "Valid expanded checkpoint and Fire seal are preserved")
	check(w.room_discovery_level(20) == 2, "Valid MetSys discovery survives filtering malformed entries")
	# Fire return: current architecture uses Coil→Junction, not historical room9→5.
	w.completed = true; w.relay_fragments = {"undercroft_sigil":true,"terrace_west":true,"terrace_fire_cache":true}
	w.opened_kunai_gates["skyworks_wind_intake"] = true
	check(w.expansion.allowed(w,"coil"), "Current Fire service route recognizes opened Fire seal and regional requirements")
	w.opened_kunai_gates.erase("coil_fire_service")
	check(not w.expansion.allowed(w,"coil"), "Current Fire service route fails closed when seal is removed")
	w.queue_free(); current_scene = null
	for i in 3: await process_frame
	print("GAMEPLAY STABILIZATION: %d failure(s)" % failures); quit(1 if failures else 0)
