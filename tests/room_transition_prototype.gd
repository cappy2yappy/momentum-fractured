extends SceneTree
var failures = 0
func _init(): call_deferred("run")
func check(ok, message):
	print("PASS: " if ok else "FAIL: ",message)
	if not ok: failures += 1
func finish(w):
	for i in 41: w._physics_process(1.0/60.0)
	var restored=w.player.is_physics_processing()
	w.player.set_physics_process(false)
	return restored
func seed_progress(w):
	w.player.double_jump=true;w.player.tether_unlocked=true;w.player.dash_unlocked=true
	w.player.kunai_unlocked.wind=true;w.completed=true;w.opened_kunai_gates.cistern_wind_cache=true
func run():
	await process_frame
	var w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w
	w.set_physics_process(false);w.player.set_physics_process(false)
	w.save_path="user://tr01_regression.json"
	check(InputMap.action_get_events("interact")[0].physical_keycode == KEY_E or InputMap.action_get_events("interact")[0].keycode == KEY_E,"Primary interaction remains E")
	for index in 21:
		check((not w.RoomPresentation.exit_style(index).is_empty()) == (index in [14,15]),"Room %d bounded style selection"%index)
	for index in [14,15]:
		for portal in w.expansion.portals(index):
			# TR-02 explicitly converts only R15<->R16 to directional crossing.
			# Its E expectations are superseded by tests/mixed_transitions.gd.
			if w.mixed_transitions.is_walk(index,portal.target): continue
			seed_progress(w);w.build_room(index);w.player.set_physics_process(false)
			var geometry_before=w.platforms.duplicate()
			var checkpoint_before=[w.checkpoint_room,w.checkpoint_position]
			# Larger drawn doorway must not broaden interaction horizontally or vertically.
			for offset in [Vector2(85,0),Vector2(0,-85),Vector2(86,0)]:
				w.player.position=portal.at+offset;w.interact()
				check(w.transition==0 and w.pending_room==-1,"R%d -> R%d rejects offset %s"%[index,portal.target,offset])
			# Remove exactly the prerequisite for each selected endpoint.
			match portal.need:
				"windstep": w.player.double_jump=false
				"relay": w.completed=false
				"climb": w.player.dash_unlocked=false
				"sluice": w.opened_kunai_gates.erase("cistern_wind_cache")
			w.player.position=portal.at;w.interact()
			check(w.transition==0 and w.pending_room==-1 and "sealed" in w.message,"R%d -> R%d rejects missing %s with feedback"%[index,portal.target,portal.need])
			seed_progress(w);w.player.position=portal.at+Vector2(84,0);w.interact()
			check(w.pending_room==portal.target and w.pending_arrival==portal.arrival,"R%d -> R%d accepts inside original radius and preserves explicit arrival"%[index,portal.target])
			var remaining=w.transition
			for i in 10: w.interact()
			check(w.transition==remaining and w.pending_room==portal.target,"Repeated input cannot restart or change departure")
			check(w.RoomPresentation.uses_pilot_transition(w),"Departure uses bounded wind-fold accent")
			var restored=finish(w)
			check(w.room==portal.target and w.player.position==portal.arrival,"Exact reciprocal destination/feet coordinates")
			check(w.transition<=0 and restored and w.player.visible and w.player.modulate.a==1,"Transition ends with physics restored and player visible")
			var landed=false
			for platform in w.platforms:
				if absf(platform.position.y-portal.arrival.y-2)<1 and portal.arrival.x>platform.position.x and portal.arrival.x<platform.end.x: landed=true
			check(landed,"Arrival is above existing supported dry landing")
			check([w.checkpoint_room,w.checkpoint_position]==checkpoint_before,"Transit preserves checkpoint")
			match portal.need:
				"windstep": w.player.double_jump=false
				"relay": w.completed=false
				"climb": w.player.tether_unlocked=false
				"sluice": w.player.kunai_unlocked.wind=false
			w.player.position=portal.arrival;w.interact()
			check(w.transition<=0 and w.pending_room==-1,"Reciprocal return also enforces %s"%portal.need)
			seed_progress(w)
			w.player.position=portal.arrival;w.interact()
			check(w.pending_room==index,"Reciprocal E interaction returns to pilot room")
			finish(w)
			check(w.room==index and w.player.position==portal.at-Vector2(0,2),"Return keeps exact original arrival")
			check(w.platforms==geometry_before,"Presentation leaves collision platform set unchanged")
			# Interrupted effect must not leave visibility/physics locked.
			w.player.position=portal.at;w.interact();w.respawn()
			check(w.transition==0 and w.pending_room==-1 and w.player.is_physics_processing() and w.player.visible,"Death resets existing clock/pending target and restores physics")
			w.player.set_physics_process(false)
	seed_progress(w);w.checkpoint_room=15;w.checkpoint_position=Vector2(185,498)
	w.test_mode=false
	check(w.save_progress(),"Prototype fixture saves using unchanged save API")
	var saved=FileAccess.get_file_as_string(w.save_path)
	w.completed=false;w.checkpoint_room=0;w.load_progress()
	check(w.completed and w.checkpoint_room==15 and w.checkpoint_position==Vector2(185,498),"Reload preserves ability and checkpoint state")
	check(FileAccess.get_file_as_string(w.save_path)==saved,"Loading does not rewrite save payload")
	w.test_mode=true
	w.build_room(14);w.player.set_physics_process(false);seed_progress(w)
	w.player.position=w.expansion.portals(14)[0].at
	var key=InputEventKey.new();key.keycode=KEY_E;key.physical_keycode=KEY_E;key.pressed=true
	w.set_physics_process(true)
	Input.parse_input_event(key)
	Input.flush_buffered_events()
	for i in 2: await physics_frame
	w.set_physics_process(false)
	check(w.pending_room==13,"Actual E key activates pilot via normal world input path")
	w.set_physics_process(true)
	for i in 45: await physics_frame
	check(w.room==13 and w.transition<=0 and w.pending_room==-1 and w.player.is_physics_processing(),"Held E does not bounce back after timer completes; physics restored")
	w.set_physics_process(false);w.player.set_physics_process(false)
	key.pressed=false;Input.parse_input_event(key);Input.flush_buffered_events()
	w.build_room(1);w.player.position=w.left_exit_position()+Vector2(105,0);w.interact()
	check(w.pending_room==-1,"Unchanged original exit rejects outside 105px radius")
	w.player.position=w.left_exit_position();w.interact();finish(w)
	check(w.room==0 and not w.RoomPresentation.uses_pilot_transition(w),"Unchanged original room transition remains functional")
	w.queue_free();current_scene=null
	for i in 3: await process_frame
	print("ROOM TRANSITION PROTOTYPE: %d failure(s)"%failures);quit(1 if failures else 0)
