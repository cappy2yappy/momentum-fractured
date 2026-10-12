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
	world.player.double_jump = true
	world.player.tether_unlocked = true
	world.player.dash_unlocked = true
	world.player.unlock_kunai("fire")
	world.opened_kunai_gates["terrace_return_relay"] = true
	world.relay_fragments["undercroft_sigil"] = true
	world.cleared_encounters["intake_sentinel"] = true
	world.checkpoint_room = 8
	world.checkpoint_position = Vector2(2060, 1298)
	world.completed = true
	world.build_room(9)
	world.save_path = "user://alpha05_regression_only.json"
	world.test_mode = false
	check(world.save_progress(), "Expanded save writes successfully")
	world.test_mode = true
	world.player.double_jump = false
	world.player.kunai_unlocked["fire"] = false
	world.opened_kunai_gates.clear()
	world.relay_fragments.clear()
	world.cleared_encounters.clear()
	world.visited.fill(false)
	world.checkpoint_room = 0
	world.load_progress()
	check(world.player.double_jump and world.player.kunai_unlocked.fire, "Original abilities survive expanded saves")
	check(world.checkpoint_room == 8 and world.checkpoint_position == Vector2(2060, 1298), "New shrine and exact spawn survive restart")
	check(world.opened_kunai_gates.get("terrace_return_relay", false) and world.relay_fragments.size() == 1, "Shortcut and side objective survive restart")
	check(world.room_discovery_level(9) == 2 and world.visited[9], "MetSys exploration persists for added rooms")
	world.build_room(8)
	check(world.enemies.is_empty(), "Cleared annex encounter stays cleared after reload")
	world.respawn()
	check(world.player.hp == 3 and world.player.position == Vector2(2060, 1298), "Saved annex shrine remains a safe death recovery point")
	world.player.set_physics_process(false)
	var data = JSON.parse_string(FileAccess.get_file_as_string(world.save_path))
	data.version = 4
	for key in ["checkpoint_position", "relay_fragments", "cleared_encounters"]: data.erase(key)
	data.checkpoint_room = 3
	data.visited.resize(8)
	data.selected_kunai = "not_an_element"
	var file = FileAccess.open(world.save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	world.load_progress()
	check(world.checkpoint_room == 3 and world.player.double_jump and world.player.kunai_unlocked.fire, "Existing Alpha 0.5 save version 4 loads without losing earned kit")
	check(world.checkpoint_position == Vector2(220, 1298) and world.relay_fragments.is_empty(), "Legacy saves initialize added data safely")
	check(world.player.selected_kunai in ["wind", "fire", "electric"], "Unknown selected element cannot break the HUD")
	world.save_path = "user://missing_folder/cannot_save.json"
	world.test_mode = false
	world.hud.manual_save()
	check(world.message.contains("Could not save"), "Failed manual save preserves honest error feedback")
	world.test_mode = true
	world.queue_free()
	current_scene = null
	for tick in 3: await process_frame
	print("SAVE COMPATIBILITY: %d failure(s)" % failures)
	quit(1 if failures else 0)
