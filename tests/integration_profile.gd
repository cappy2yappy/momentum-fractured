extends SceneTree
# Two separate processes verify the real default save path under a disposable HOME.
var failures=0
func _init(): call_deferred("run")
func check(ok,message):
	print("PASS: " if ok else "FAIL: ",message)
	if not ok: failures+=1
func run():
	await process_frame
	var w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w
	w.set_physics_process(false);w.player.set_physics_process(false)
	print("PROFILE_PATH=",OS.get_user_data_dir()," SAVE=",w.save_path)
	if "--prepare" in OS.get_cmdline_user_args():
		check(w.room==0 and not w.player.double_jump and w.player.speed_upgrade_level==0,"Fresh process starts with ordinary Haven progression")
		w.player.double_jump=true;w.player.tether_unlocked=true;w.player.dash_unlocked=true
		w.player.restore_speed_upgrade(1);w.player.unlock_kunai("fire")
		w.checkpoint_room=16;w.checkpoint_position=Vector2(420,1118)
		w.opened_kunai_gates["coil_fire_service"]=true
		check(w.save_progress(),"Seeded upgraded profile writes through default save path")
	else:
		check(w.player.double_jump and w.player.tether_unlocked and w.player.dash_unlocked,"New process restores earned traversal kit")
		check(w.player.speed_upgrade_level==1 and w.player.kunai_unlocked.fire,"New process restores Stride and Fire")
		check(w.checkpoint_room==16 and w.checkpoint_position==Vector2(420,1118),"New process restores Root Shrine checkpoint")
		check(w.opened_kunai_gates.get("coil_fire_service",false),"New process restores Fire return seal")
		check(w.player.momentum.meter==0,"Temporary momentum starts empty after reload")
	w.queue_free();current_scene=null
	for tick in 3: await process_frame
	print("INTEGRATION PROFILE: %d failure(s)"%failures);quit(1 if failures else 0)
