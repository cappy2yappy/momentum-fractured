extends SceneTree
var failures = 0
var w
func _init(): call_deferred("run")
func check(value, label):
	print(("PASS " if value else "FAIL ") + label)
	if not value: failures += 1
func key_release(action):
	var event = InputEventAction.new()
	event.action = action
	event.pressed = false
	w.story.panel._input(event)
func run():
	w = load("res://tests/story_demo/demo.tscn").instantiate()
	root.add_child(w); current_scene = w
	w.set_physics_process(false)
	w.player.set_physics_process(true)
	w.save_path = ProjectSettings.globalize_path("res://../int01-evidence/disk-roundtrip.json")
	DirAccess.remove_absolute(w.save_path)
	var story = w.story
	check(story.Definition.valid_id("evt/int01/nested_event"), "slash separated IDs supported")
	check(not story.set_flag("junction_return"), "legacy flag writer rejected")
	var controls = InputMap.action_get_events("interact")
	check(controls.any(func(e): return e is InputEventJoypadButton and e.button_index == JOY_BUTTON_X), "gamepad X interaction registered")
	w.player.position = Vector2(700,1300)
	check(story.interact(w), "read accepted")
	key_release("ui_accept")
	check(story.panel.page == 1, "gamepad UI accept advances exactly one page")
	key_release("ui_cancel")
	check(not paused and w.hud.is_processing_input(), "gamepad cancel restores control")
	story.panel.inspect(w, {"pages":[], "title":"[TEST FIXTURE] Missing content"})
	check(story.panel.body.text == "No readable content is available.", "missing text fallback")
	story.panel._notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(not paused and not story.panel.opened, "focus interruption restores control")
	story.panel.inspect(w, {"description":"[TEST FIXTURE] room interruption"})
	w.build_room(0)
	check(not paused and not story.panel.opened, "same room rebuild restores control")
	story.panel.inspect(w, {"description":"[TEST FIXTURE] death"})
	w.player.hp = 0; story.panel._process(0)
	check(not paused and not story.panel.opened, "death interruption restores control")
	w.player.hp = 3
	story.rules = [{"trigger":"evt/int01_deferred", "effects":[{"kind":"set_flag","id":"evt/int01_ready"}]}]
	w.transition = 0.2
	story.report("evt/int01_deferred")
	check(not story.has("evt/int01_ready"), "transition defers event state")
	w.transition = 0
	w.player.set_physics_process(false); story.update(w,0)
	check(not story.has("evt/int01_ready"), "event waits for restored control")
	w.player.set_physics_process(true); story.update(w,0)
	check(story.has("evt/int01_ready"), "restored control flushes event exactly once")
	story.load_data("res://tests/story_demo/objects.json","res://tests/story_demo/rules.json")
	w.test_mode = false
	w.player.position = Vector2(1420,1300)
	check(story.interact(w), "activation applies before panel pauses")
	story.panel.close()
	check(FileAccess.file_exists(w.save_path), "actual disk save written")
	var saved = JSON.parse_string(FileAccess.get_file_as_string(w.save_path))
	check(saved.version == 8 and saved.expansion_flags.get("trap/int01_power",false), "version 8 existing flag dictionary owns activation")
	w.expansion_flags.clear(); w.load_progress()
	check(story.has("trap/int01_power") and story.has("disc/r0_int01_switch"), "disk reload restores discovery and activation")
	check(not story.interact(w), "once activation remains unavailable after disk reload")
	var before = FileAccess.get_file_as_bytes(w.save_path)
	check(not story.set_flag("trap/int01_power"), "repeated flag is idempotent")
	check(before == FileAccess.get_file_as_bytes(w.save_path), "repeated flag does not rewrite save")
	w.transition = 0.5
	story.set_flag("evt/int01_save_deferred")
	check(before == FileAccess.get_file_as_bytes(w.save_path), "no disk write during transition")
	w.transition = 0; story.update(w,0)
	check(JSON.parse_string(FileAccess.get_file_as_string(w.save_path)).expansion_flags.get("evt/int01_save_deferred",false), "queued save flushes after transition")
	var enemy = Node2D.new()
	enemy.set_meta("persistent_id", "int01_managed_probe")
	enemy.set_meta("story_managed_encounter", true)
	w.transition = 0.5
	w.on_enemy_defeated(enemy, false, false)
	check(not w.cleared_encounters.get("int01_managed_probe",false), "managed encounter persistence defers during transition")
	enemy.free()
	w.transition = 0; story.update(w,0)
	check(w.cleared_encounters.get("int01_managed_probe",false), "managed encounter persists after enemy is freed")
	before = FileAccess.get_file_as_bytes(w.save_path)
	story.record_encounter("int01_managed_probe")
	check(before == FileAccess.get_file_as_bytes(w.save_path), "managed encounter duplicate does not rewrite disk")
	enemy = Node2D.new()
	enemy.set_meta("persistent_id", "int01_legacy_probe")
	w.on_enemy_defeated(enemy, false, false)
	check(w.cleared_encounters.get("int01_legacy_probe",false), "legacy encounter immediate persistence preserved")
	enemy.free()
	w.test_mode = true
	var row = story.objects[0].duplicate(true)
	row.at = [220,1300]
	check(not story.safe_placement(row), "checkpoint overlap rejected")
	row.at = [w.right_exit_position().x,w.right_exit_position().y]
	check(not story.safe_placement(row), "door approach overlap rejected")
	story.objects = [row]
	w.player.position = Vector2(220,1300)
	w.player.hp = 1; w.interact()
	check(w.player.hp == 3 and not story.panel.opened, "legacy checkpoint priority retained")
	w.queue_free(); await process_frame
	print("INT01 CONTRACTS: %d failure(s)" % failures)
	quit(1 if failures else 0)
