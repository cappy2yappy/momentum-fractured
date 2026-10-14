extends SceneTree
func _init(): call_deferred("run")
func run():
	await process_frame
	var w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w
	w.set_physics_process(false);w.player.set_physics_process(false)
	var expected=-1
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--expected-room="): expected=int(arg.trim_prefix("--expected-room="))
	var valid=w.room==expected and w.save_path.is_absolute_path()
	print("PASS: " if valid else "FAIL: ","Explicit isolated prototype save loads expected room ",expected," actual=",w.room," path=",w.save_path)
	w.queue_free();current_scene=null
	for i in 3: await process_frame
	quit(0 if valid else 1)
