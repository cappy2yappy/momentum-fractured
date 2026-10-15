extends SceneTree
var failures=0
var count=0
func _init(): call_deferred("run")
func check(ok,label):
	count+=1;print("PASS: " if ok else "FAIL: ",label)
	if not ok: failures+=1
func run():
	await process_frame
	var w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w
	w.set_physics_process(false);w.player.set_physics_process(false)
	var expected="refined";var expected_save=""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--expect="): expected=arg.trim_prefix("--expect=")
		if arg.begins_with("--tr03-save="): expected_save=arg.trim_prefix("--tr03-save=")
	var e=w.embodied_transitions
	check(e.comparison==expected,"CLI comparison resolves to "+expected)
	check(e.production_active()==(expected in ["art-preview","reduced"]),"CLI art activation follows explicit preview/reduced flags")
	check(w.save_path==expected_save and w.save_path.contains(" "),"Explicit comparison save path containing spaces retained")
	check(w.player.momentum.enabled==false and w.player.speed_upgrade_level==0,"Launcher defaults preserve ordinary movement")
	if expected=="reduced": check(w.mixed_transitions.graphic_mode=="reduced","CLI reduced motion reaches authoritative graphic policy")
	w.queue_free();current_scene=null
	for tick in 3: await process_frame
	print("ART04 PROFILE OPTIONS: %d assertions, %d failure(s)"%[count,failures]);quit(1 if failures else 0)
