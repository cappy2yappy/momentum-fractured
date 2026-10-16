extends SceneTree
# Cross-PR contract: loading sparse progression must not affect presentation or layout.
var failures = 0
func _init(): call_deferred("run")
func check(ok, message):
	print("PASS: " if ok else "FAIL: ", message)
	if not ok: failures += 1
func run():
	await process_frame
	var w = load("res://scenes/main.tscn").instantiate()
	root.add_child(w); current_scene = w
	w.set_physics_process(false); w.player.set_physics_process(false)
	print("ISOLATED_PROFILE=", OS.get_user_data_dir())
	check(not w.completed and not w.player.double_jump and w.room == 0, "Fresh isolated profile starts at Haven with original kit")
	for index in [14,15,17,19]:
		w.build_room(index); w.player.set_physics_process(false)
		var before = w.platforms.duplicate()
		w.opened_kunai_gates["coil_fire_service"] = true
		w.save_path = "user://int01_sparse.json"
		var f = FileAccess.open(w.save_path,FileAccess.WRITE)
		f.store_string('{"version":8}'); f.close(); w.load_progress()
		check(w.platforms == before and w.opened_kunai_gates.is_empty(), "Room %d LD geometry survives GP sparse normalization without stale gates" % index)
		check(w.RoomPresentation != null and not w.can_enter(20), "Room %d presentation remains available and missing progression rejects route" % index)
	# Gate interaction at exact compact door location, and rejection outside unchanged radius.
	w.build_room(14); w.player.set_physics_process(false)
	var portal = w.expansion.portals(14)[0]
	w.player.position = portal.at; w.pending_room = -1
	w.expansion.interact(w)
	check(w.pending_room == -1, "Compact door rejects missing Windstep")
	w.player.double_jump = true
	w.player.position = portal.at + Vector2(86,0)
	check(not w.expansion.interact(w), "Compact door keeps original 85px interaction radius")
	if w.cinematic_transitions.enabled:
		var p=w.cinematic_transitions.endpoint(w,14,portal.target);var dir=int(p.heading)
		w.player.set_physics_process(true);w.cinematic_transitions.cooldown=0
		w.player.position=p.at-Vector2(dir*100,2);w.player.velocity=Vector2(dir*400,0);w.cinematic_transitions.update(w,0)
		w.player.position=p.at+Vector2(dir*2,-2);w.cinematic_transitions.update(w,0);w.player.set_physics_process(false)
	else: w.player.position = portal.at; w.expansion.interact(w)
	check(w.pending_room == portal.target, "Compact passage accepts earned Windstep with current trigger policy")
	w.queue_free(); current_scene = null
	for tick in 3: await process_frame
	print("INTEGRATION CANDIDATE: %d failure(s)" % failures)
	quit(1 if failures else 0)
