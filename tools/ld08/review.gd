extends SceneTree
## Interactive creator fixture, using the actual game/controller and an isolated disposable save.
## godot --path . --script res://tools/ld08/review.gd -- --test --ld08-room=13
## Append --ld08-before or --ld08-roof-reference to compare. --ld08-closed-gates retains the Spire shutter.
func _init():call_deferred("run")
func run():
	await process_frame
	var room=13
	for arg in OS.get_cmdline_user_args():
		if arg=="--ld08-room=17":room=17
	var w=load("res://scenes/main.tscn").instantiate()
	w.save_path="user://ld08_review_only.json"
	root.add_child(w);current_scene=w;w.test_mode=true
	w.completed=true;w.guard_defeated=true;w.boss_defeated=true
	w.player.double_jump=true;w.player.dash_unlocked=true;w.player.tether_unlocked=true
	w.player.kunai_unlocked={"wind":true,"fire":true,"electric":true}
	w.relay_fragments={"undercroft_sigil":true,"terrace_west":true,"terrace_fire_cache":true}
	w.opened_kunai_gates={"skyworks_wind_intake":true,"spire_wind_shutter":not "--ld08-closed-gates" in OS.get_cmdline_user_args()}
	w.expansion_flags={"junction_return":true}
	w.checkpoint_room=room;w.checkpoint_position=Vector2(450,438) if room==13 else Vector2(1300,418)
	w.build_room(room);w.player.position=w.checkpoint_position;w.player.velocity=Vector2.ZERO;w.camera.reset_smoothing()
	var mode="OPEN-TOP CANDIDATE"
	if "--ld08-before" in OS.get_cmdline_user_args():mode="BEFORE: UNBOUNDED OPEN TOP"
	if "--ld08-roof-reference" in OS.get_cmdline_user_args():mode="PREVIOUS ROOF REFERENCE"
	DisplayServer.window_set_title("KAZE LD-08 | R%d | %s"%[room,mode])
	w.announce("LD-08 REVIEW: "+mode+". Disposable fixture; earned kit granted for traversal review.",8)
