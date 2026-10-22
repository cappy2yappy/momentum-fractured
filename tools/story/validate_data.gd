extends SceneTree
const Definition = preload("res://scripts/story/object_definition.gd")
const EFFECTS = ["set_flag", "announce", "objective", "spawn_encounter", "arm_hazard", "request_cutin"]
func _init(): call_deferred("run")
func run():
	var errors: Array[String] = []
	var objects = JSON.parse_string(FileAccess.get_file_as_string("res://data/story/objects.json"))
	errors.append_array(Definition.validate(objects))
	var rules = JSON.parse_string(FileAccess.get_file_as_string("res://data/story/rules.json"))
	errors.append_array(Definition.validate_rules(rules))
	# Fixture data remains separate and is explicitly validated as provisional.
	var fixtures = JSON.parse_string(FileAccess.get_file_as_string("res://tests/story_demo/objects.json"))
	errors.append_array(Definition.validate(fixtures))
	var w = load("res://tests/story_demo/demo.tscn").instantiate()
	root.add_child(w); current_scene = w
	w.set_physics_process(false); w.player.set_physics_process(false)
	for row in fixtures.objects:
		if not w.story.safe_placement(row): errors.append("Unsafe placement: " + row.id)
	if not objects.objects.is_empty() or not rules.rules.is_empty(): errors.append("Production story placement requires creator review")
	for error in errors: print("FAIL " + error)
	print("INT01 DATA: %d failure(s)" % errors.size())
	w.queue_free(); await process_frame
	quit(1 if not errors.is_empty() else 0)
