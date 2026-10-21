extends SceneTree
var fails = 0
func _init(): call_deferred("run")
func check(ok,label):
	print("PASS: " if ok else "FAIL: ",label)
	if not ok: fails += 1
func run():
	if "--test" not in OS.get_cmdline_user_args(): quit(2);return
	var w = load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene = w
	w.set_physics_process(false);w.player.set_physics_process(false)
	w.save_path = "user://room-creator-cross-process.json"
	if "--prepare" in OS.get_cmdline_user_args():
		w.completed = true;w.player.double_jump = true;w.player.unlock_speed_upgrade("stride_1")
		w.opened_kunai_gates = {"pump_electric_isolator":true}
		w.expansion_flags = {"lore_18":true};w.checkpoint_room = 18;w.checkpoint_position = Vector2(260,998)
		w.test_mode = false;check(w.save_progress(),"Serialize R18 pilot checkpoint in isolated profile");w.test_mode = true
	else:
		check(FileAccess.file_exists(w.save_path),"Serialized R18 checkpoint exists in a new process")
		w.load_progress()
		w.respawn();w.set_physics_process(false);w.player.set_physics_process(false)
		check(w.room == 18 and w.player.position == Vector2(260,998),"Cross-process R18 checkpoint restored")
		check(w.completed and w.player.double_jump and w.player.speed_upgrade_level == 1,"Cross-process progression retained")
		check(w.opened_kunai_gates.get("pump_electric_isolator",false) and w.expansion_flags.get("lore_18",false),"Cross-process gate/lore retained")
		check(w.authored_room_active == w.authored_r18_enabled,"Save is readable with either runtime mode")
	w.queue_free();current_scene = null
	await process_frame;await process_frame;quit(1 if fails else 0)
