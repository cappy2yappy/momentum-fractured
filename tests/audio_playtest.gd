extends SceneTree
## Editor-only fixture. --test is required: no creator profiles loaded or saved.
func _init(): call_deferred("run")
func run():
	if "--test" not in OS.get_cmdline_user_args():
		push_error("Audio playtest requires --test for profile isolation."); quit(1); return
	await process_frame
	var w = load("res://scenes/main.tscn").instantiate(); root.add_child(w); current_scene = w
	w.player.double_jump = true; w.player.tether_unlocked = true; w.player.dash_unlocked = true
	for element in ["wind", "fire", "electric"]: w.player.kunai_unlocked[element] = true
	w.guard_defeated = true; w.boss_defeated = true; w.completed = true
	w.opened_kunai_gates["cistern_wind_cache"] = true
	var room = 14 if "--roof" in OS.get_cmdline_user_args() else (15 if "--canal" in OS.get_cmdline_user_args() else 4)
	w.checkpoint_room = room
	w.checkpoint_position = {4: Vector2(350,1108),14: Vector2(185,1098),15: Vector2(185,498)}[room]
	w.build_room(room); w.player.position = w.checkpoint_position; w.camera.reset_smoothing()
	print("AUD01 SEEDED REVIEW: room ", room, "; all abilities unlocked; saves disabled.")
