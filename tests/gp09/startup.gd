extends SceneTree
const Demo = preload("res://scripts/gp09/vertical_slice.gd")
const Director = preload("res://scripts/story/story_director.gd")
class FaultDirector extends Director:
	var fault = ""
	var external_callback: Callable
	func register_effect_consumer(kind: String, id: String, handler: Callable) -> bool:
		if fault == "encounter" and kind == "spawn_encounter": return false
		if fault == "hazard" and kind == "arm_hazard": return false
		return super.register_effect_consumer(kind,id,handler)
	func load_data(objects_path: String, rules_path: String) -> bool:
		if objects_path.contains("data/gp09"):
			if fault == "story": return false
			if fault == "replacement":
				effect_consumers.spawn_encounter.gp09_guard = external_callback
				return false
			if fault == "inventory":
				objects = []; rules = []
				return true
		return super.load_data(objects_path,rules_path)
var failures = 0
var checks = 0
var path = "user://startup_test.json"
const SAVED = '{"version":8,"expansion_flags":{"disc/gp09_bundle":true},"cleared_encounters":{},"checkpoint_room":0,"checkpoint_position":[180,618]}'
func _init(): call_deferred("run")
func check(ok, label):
	checks += 1
	if not ok: failures += 1
	print(("PASS " if ok else "FAIL ") + label)
func prior(_context): pass
func run():
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--gp09-save="): path = arg.trim_prefix("--gp09-save=")
	for fault in ["encounter", "hazard", "story", "inventory", "replacement", "prior_encounter", "prior_hazard", "fresh_delete", ""]:
		if fault in ["", "fresh_delete"] and not "--gp09-fresh" in OS.get_cmdline_user_args(): continue
		if root.has_meta("gp09_fresh_applied"): root.remove_meta("gp09_fresh_applied")
		var file = FileAccess.open(path,FileAccess.WRITE)
		file.store_string(SAVED); file.close()
		var locked_save = FileAccess.open(path,FileAccess.READ) if fault == "fresh_delete" else null
		var director = FaultDirector.new()
		director.fault = fault
		director.external_callback = prior
		if fault == "prior_encounter": director.effect_consumers.spawn_encounter.gp09_guard = prior
		if fault == "prior_hazard": director.effect_consumers.arm_hazard.gp09_steam = prior
		director.effect_consumers.spawn_encounter.unrelated = prior
		var w = Demo.new(); w.story = director
		root.add_child(w); current_scene = w
		await physics_frame
		await physics_frame
		if fault != "":
			check(not w.initialized and not w.player.is_physics_processing(),fault + ": inactive")
			check(not w.startup_error.is_empty() and w.status.text.contains(w.startup_error) and w.status.is_visible_in_tree(),fault + ": visible diagnostic")
			check(w.consumers == null and w.steam == null and w.presenter == null,fault + ": staged resources disposed")
			check(director.effect_consumers.spawn_encounter.get("unrelated") == Callable(self,"prior"),fault + ": unrelated callback retained")
			var retained = fault in ["prior_encounter","replacement"]
			check(director.effect_consumers.spawn_encounter.has("gp09_guard") == retained,fault + ": encounter rollback by identity")
			if retained: check(director.effect_consumers.spawn_encounter.gp09_guard == Callable(self,"prior"),fault + ": prior/replacement identity retained")
			check(director.effect_consumers.arm_hazard.has("gp09_steam") == (fault == "prior_hazard"),fault + ": hazard rollback")
			check(not w.save_progress() and w.save_attempts == 0,fault + ": save refused")
			if fault == "story" and DisplayServer.get_name() != "headless":
				await process_frame
				await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png("res://docs/gp09/evidence/startup/failure-native.png")
			w.interact(); w.reconcile_story(); w.respawn()
			var event = InputEventKey.new(); event.pressed = true
			event.physical_keycode = KEY_F9; w._unhandled_input(event)
			event.physical_keycode = KEY_F5; w._unhandled_input(event)
			check(not w.reload_requested and not w.exiting and not w.safe_to_leave(),fault + ": input/exit refused")
			w._ready()
			check(not w.initialized and FileAccess.get_file_as_string(path) == SAVED and not root.has_meta("gp09_fresh_applied"),fault + ": no retry or save deletion")
		else:
			check(w.initialized and w.player.is_physics_processing(),"success: activated")
			check(director.objects.size() == 1 and director.rules.size() == 3,"success: story loaded")
			check(w.consumers.hazards.bindings.size() == 1 and not w.steam.enabled,"success: one inactive hazard binding")
			check(w.enemies.is_empty(),"success: no premature encounter")
			check(not FileAccess.file_exists(path) and root.has_meta("gp09_fresh_applied"),"success: fresh deletion committed")
			w._ready()
			check(director.effect_consumers.spawn_encounter.size() == 2 and director.effect_consumers.arm_hazard.size() == 1,"success: repeated ready does not duplicate")
			check(w.save_progress(),"success: save allowed after startup")
			var bytes = FileAccess.get_file_as_bytes(path)
			w.queue_free(); current_scene = null
			await process_frame
			w = Demo.new(); root.add_child(w); current_scene = w
			check(w.initialized and FileAccess.get_file_as_bytes(path) == bytes,"success: reentry retains saved bytes")
		if locked_save != null: locked_save.close()
		w.queue_free(); current_scene = null
		await process_frame
	print("STARTUP_RESULT checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)
