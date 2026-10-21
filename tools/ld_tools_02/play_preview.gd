extends SceneTree
## Same game scene/controller; a disposable fixture, never a second world runtime.
func _init(): call_deferred("run")
func run():
	if "--test" not in OS.get_cmdline_user_args():
		push_error("Room preview requires --test to protect personal saves");quit(2);return
	var path = "res://tools/ld_tools_01/r18_layout.tscn"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--room-layout="): path = arg.trim_prefix("--room-layout=")
	var packed = ResourceLoader.load(path,"PackedScene",ResourceLoader.CACHE_MODE_IGNORE)
	if not packed is PackedScene: push_error("Cannot load preview layout");quit(2);return
	var layout = packed.instantiate()
	if not layout is Node2D: layout.free();quit(2);return
	var report = load("res://tools/ld_tools_02/layout_contract.gd").read(layout)
	layout.free()
	if not report.errors.is_empty(): push_error(str(report.errors));quit(2);return
	if report.room_id == 18 and report.room_size == Vector2(2600,1440):
		var w = load("res://scenes/main.tscn").instantiate()
		root.add_child(w);current_scene = w
		w.save_path = "user://room_creator_preview_%d.json" % OS.get_process_id()
		w.player.double_jump = true;w.player.dash_unlocked = true;w.player.tether_unlocked = true
		for element in ["wind","fire","electric"]: w.player.kunai_unlocked[element] = true
		w.completed = true
		w.relay_fragments = {"undercroft_sigil":true,"terrace_west":true,"terrace_fire_cache":true}
		w.opened_kunai_gates = {"skyworks_wind_intake":true}
		w.checkpoint_room = 18;w.checkpoint_position = Vector2(260,998)
		w.authored_r18_enabled = true;w.authored_r18_path = path;w.build_room(18)
		w.player.position = Vector2(260,998)
		w.camera.position_smoothing_enabled = false;w.camera.reset_smoothing()
		w.announce("R18 LIVE PILOT | fixture progression/abilities | personal saves isolated",10)
	else:
		# A disconnected geometry lab with the unchanged Kaze controller. No world graph.
		var input_setup = load("res://scripts/world.gd").new()
		input_setup.configure_input()
		# The game allocates these before _ready; adopt them before freeing the input helper.
		for orphan in [input_setup.camera,input_setup.geometry,input_setup.embodied_transitions,input_setup.cinematic_transitions]:
			input_setup.add_child(orphan)
		input_setup.embodied_transitions.add_child(input_setup.embodied_transitions.proxy)
		input_setup.free()
		var lab = Node2D.new();root.add_child(lab);current_scene = lab
		var authoring = packed.instantiate();lab.add_child(authoring)
		if authoring.has_node("Markers"): authoring.get_node("Markers").hide()
		var player = load("res://scripts/player.gd").new();lab.add_child(player)
		player.double_jump = true;player.dash_unlocked = true;player.tether_unlocked = true
		player.position = Vector2(220,report.room_size.y-142)
		var camera = Camera2D.new();player.add_child(camera);camera.position.y = -110
		camera.limit_left = 0;camera.limit_top = 0
		camera.limit_right = int(report.room_size.x);camera.limit_bottom = int(report.room_size.y)
		var label = Label.new();label.text = "GEOMETRY LAB | unchanged Kaze controller | no progression or connections"
		var layer = CanvasLayer.new();lab.add_child(layer);layer.add_child(label)
