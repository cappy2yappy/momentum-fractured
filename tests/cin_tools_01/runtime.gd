extends "res://tests/native_cinematic_transitions.gd"
const Adapter = preload("res://tools/cin_tools_01/runtime_adapter.gd")
var adapter
var results: Array = []

func drive(count):
	for i in count: w._physics_process(1.0 / 60.0)

func fixture(index = 14, still = false):
	paused = false
	reset(index)
	adapter.reduced = still
	adapter.tr08.reduced = still
	w.player.set_physics_process(true)
	w.player.position = adapter.endpoint(w, index, 17 if index == 14 else 14).at - Vector2(0, 2)
	w.player.velocity = Vector2.ZERO
	w.checkpoint_room = 0
	w.checkpoint_position = Vector2(220,1298)

func start_trip():
	w.interact()
	check(adapter.owning and not w.player.is_physics_processing(), "Accepted E trigger suspends ordinary player physics")

func settle():
	for tick in 650:
		if not adapter.owning and not adapter.tr08.owns() and w.transition <= 0: return
		drive(1)
	check(false, "Bounded completion (no infinite waits)")

func preserved():
	return [w.checkpoint_room, w.checkpoint_position, w.completed, w.expansion_flags.duplicate(true), w.opened_kunai_gates.duplicate(true), w.relay_fragments.duplicate(true), w.player.double_jump, w.player.tether_unlocked, w.player.dash_unlocked]

func verify_trip(label, before, progress):
	settle()
	check(w.room == 17 and adapter.request_count == before + 1, label + ": authorized loader request exactly once")
	check(w.player.is_physics_processing() and w.player.sprite.visible and not adapter.owning and not adapter.tr08.owns(), label + ": control and live sprite restored")
	check(w.camera.zoom == Vector2.ONE and w.camera.position == Vector2(0,-110) and w.camera.offset == Vector2.ZERO and w.camera.position_smoothing_enabled, label + ": gameplay camera preserved")
	check(preserved() == progress, label + ": checkpoint and earned progression preserved")
	check(FileAccess.get_file_as_string(w.save_path) == "{\"sentinel\":true}", label + ": existing save bytes untouched")

func run():
	await process_frame
	w = load("res://scenes/main.tscn").instantiate()
	w.save_path = "/tmp/kaze-cin-tools-01-regression-save.json"
	var file = FileAccess.open(w.save_path, FileAccess.WRITE)
	file.store_string("{\"sentinel\":true}"); file.close()
	root.add_child(w); current_scene = w
	w.cinematic_transitions.cancel(w)
	w.remove_child(w.cinematic_transitions)
	w.cinematic_transitions.free()
	adapter = Adapter.new()
	w.cinematic_transitions = adapter
	w.add_child(adapter)
	adapter.configure(w)
	freeze(); seed_fixture()
	var default_preset = adapter.preset
	for still in [false, true]:
		fixture(14, still)
		var before = adapter.request_count
		var progress = preserved()
		start_trip()
		var handoffs_before = adapter.handoffs
		for i in 8: w.interact()
		check(adapter.handoffs == handoffs_before, "Overlapping/repeated triggers do not hand off early")
		if still:
			adapter.sequence.seek(.2, true)
			check(adapter.cutin.get_node("Framing").position == Vector2.ZERO and adapter.cutin.get_node("Framing").scale == Vector2.ONE and adapter.cutin.shake_strength == 0, "Reduced sequence has fixed framing and no shake")
		verify_trip("Reduced" if still else "Normal", before, progress)
	# Skip through all adapter and TR-08 phases, including before room request.
	for phase_name in ["opening", "middle", "closing", "tr08_open", "tr08_climb", "tr08_close"]:
		fixture()
		var before = adapter.request_count
		var progress = preserved()
		start_trip()
		match phase_name:
			"opening": drive(1)
			"middle": drive(48)
			"closing": drive(88)
			_:
				var wanted = phase_name.trim_prefix("tr08_")
				for i in 550:
					if adapter.tr08.stair.phase == wanted: break
					drive(1)
				check(adapter.tr08.stair.phase == wanted, "Reached " + phase_name)
		adapter.skip(); adapter.skip()
		verify_trip("Skip " + phase_name, before, progress)
	for phase_name in ["intro", "tr08_pre_request", "loader"]:
		fixture()
		var before = adapter.request_count
		var progress = preserved()
		start_trip()
		if phase_name != "intro":
			while adapter.owning: drive(1)
			if phase_name == "loader":
				while w.transition <= 0: drive(1)
		adapter.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
		paused = true
		await process_frame; await process_frame
		paused = false
		verify_trip("Focus loss " + phase_name, before, progress)
	fixture(); start_trip()
	var event = InputEventKey.new()
	event.physical_keycode = KEY_F6; event.pressed = true
	adapter._unhandled_key_input(event)
	check(adapter.reduced and adapter.sequence.current_animation == "reduced", "F6 switches active cut-in to reduced timeline")
	settle()
	# Missing preset and structurally incomplete scene both delegate safely.
	for missing in ["preset", "player"]:
		fixture()
		var before = adapter.request_count
		var progress = preserved()
		if missing == "preset": adapter.preset = null
		else:
			var empty_scene = PackedScene.new()
			var empty_node = Node2D.new()
			empty_scene.pack(empty_node); empty_node.free()
			adapter.preset = empty_scene
		w.interact()
		verify_trip("Missing " + missing, before, progress)
		adapter.preset = default_preset
	fixture(); start_trip()
	adapter.max_duration = .05
	var watchdog_before = adapter.request_count
	var watchdog_progress = preserved()
	verify_trip("Watchdog", watchdog_before, watchdog_progress)
	adapter.max_duration = 12
	# Both directions with repeated use of same adapter.
	for index in [17,14,17,14]:
		fixture(index)
		var before = adapter.request_count
		start_trip(); settle()
		check(w.room == (17 if index == 14 else 14) and adapter.request_count == before + 1 and w.player.is_physics_processing(), "Repeated reciprocal entry R%d completes once" % index)
	fixture(); start_trip(); w.build_room(15)
	check(not adapter.owning and adapter.last_outcome == "room_rebuilt" and w.transition <= 0 and w.player.is_physics_processing(), "External room rebuild supersedes stale accepted request")
	fixture(); start_trip(); w.respawn()
	check(not adapter.owning and w.room == w.checkpoint_room and w.pending_room == -1 and w.player.is_physics_processing(), "Respawn supersedes stale trip and restores checkpoint control")
	# Automatic passage policy remains inherited, including rejected gate.
	reset(13); w.player.double_jump = false
	check(adapter.automatic(w,13,0) and not w.can_enter(0), "Automatic Canal passage keeps original routing and gate")
	w.queue_free(); current_scene = null
	for i in 4: await process_frame
	print("CIN-TOOLS-01 RUNTIME: %d checks, %d failure(s)" % [checks,failures])
	quit(1 if failures else 0)
