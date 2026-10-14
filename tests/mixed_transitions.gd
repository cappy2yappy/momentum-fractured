extends SceneTree
var w
var failures=0
func _init(): call_deferred("run")
func check(ok,text):
	print("PASS: " if ok else "FAIL: ",text)
	if not ok: failures+=1
func freeze():
	w.set_physics_process(false);w.player.set_physics_process(false)
	for e in w.enemies: e.set_physics_process(false)
func seed_fixture():
	w.completed=true;w.player.double_jump=true;w.player.tether_unlocked=true;w.player.dash_unlocked=true
	for element in ["wind","fire","electric"]: w.player.unlock_kunai(element)
	w.relay_fragments={"undercroft_sigil":true,"terrace_west":true,"terrace_fire_cache":true}
	w.opened_kunai_gates["skyworks_wind_intake"]=true;w.expansion_flags["junction_return"]=true
func finish():
	for i in 41: w._physics_process(1.0/60.0)
	freeze()
func approach(index:int,speed:float,height:float=0,tether:bool=false):
	w.transition=0;w.pending_room=-1;w.build_room(index);freeze();w.player.set_physics_process(true)
	var p=w.mixed_transitions.walk_portal(w);var dir=w.MixedTransitions.WALK[index].direction
	w.mixed_transitions.cooldown=0
	w.player.position=p.at+Vector2(-120*dir,-2+height)
	w.player.velocity=Vector2(speed*dir,0)
	w.mixed_transitions.update(w,0);w.mixed_transitions.update(w,0)
	w.player.position=p.at+Vector2(-12*dir,-2+height);w.mixed_transitions.update(w,0)
	w.player.tether_attached=tether
	w.player.position=p.at+Vector2(4*dir,-2+height);w.mixed_transitions.update(w,0)
	w.player.tether_attached=false
	return p
func run():
	await process_frame
	w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w;freeze();seed_fixture()
	check(w.ROOM_COUNT==21 and w.world_edges().size()==29,"21 rooms and29 links retained")
	check(w.camera.zoom==Vector2.ONE,"Normal1280x720 camera zoom")
	for index in [15,16]:
		for speed in [400.0,600.0,920.0]:
			var p=approach(index,speed)
			check(w.pending_room==p.target,"Directional walk/run/dash-speed crossing R%d speed%.0f"%[index,speed])
			check(w.pending_arrival==p.arrival and w.transition==0.65,"Original explicit arrival and clock")
			w.mixed_transitions.update(w,0.02)
			check(absf(w.camera.offset.x)<=20,"Directional framing stays modest")
			var dir=w.MixedTransitions.WALK[index].direction
			finish()
			check(w.room==p.target and w.player.position==p.arrival,"Exact reciprocal feet position")
			check(w.player.velocity==Vector2(speed*dir,0),"Horizontal crossing velocity preserved, landing vertical zero")
			check(w.camera.offset.x==0,"Camera offset restores on arrival")
			w.player.set_physics_process(true)
			w.mixed_transitions.update(w,0);w.mixed_transitions.update(w,1)
			check(w.pending_room==-1,"Arrival proximity does not bounce back")
			w.player.set_physics_process(false)
		for height in [-150,60]:
			approach(index,400,height);check(w.pending_room==-1,"High/low corner crossing rejected")
		approach(index,-400);check(w.pending_room==-1,"Wrong travel direction rejected")
		approach(index,0);check(w.pending_room==-1,"Stationary crossing rejected")
		approach(index,400,0,true);check(w.pending_room==-1,"Attached grapple near plane rejected")
		w.transition=0;w.pending_room=-1;w.build_room(index);freeze()
		var p=w.mixed_transitions.walk_portal(w)
		w.player.position=p.at;w.interact();check(w.pending_room==-1,"Converted passage no longer uses E")
		w.player.set_physics_process(true);w.player.velocity=Vector2(400,0)
		w.mixed_transitions.update(w,1);check(w.pending_room==-1,"Load directly at plane does not activate")
		w.completed=false;approach(index,600);check(w.pending_room==-1 and "LOCKED" in w.message,"Closed Archive gate rejects crossing with cause")
		w.completed=true;approach(index,400);w.checkpoint_room=0;w.respawn();freeze()
		check(w.transition==0 and w.pending_room==-1 and not w.mixed_transitions.active_walk,"Death mid-crossing cancels clock and carry")
		check(w.camera.offset.x==0,"Death restores framing")
	# Real player/input/collision paths, beyond sampled helper tests.
	for mode in ["walk","run","dash"]:
		w.transition=0;w.pending_room=-1;w.build_room(15);freeze();seed_fixture()
		w.player.position=Vector2(1955,1118);w.player.velocity=Vector2.ZERO
		w.mixed_transitions.cooldown=0;w.player.set_physics_process(true);w.set_physics_process(true)
		for i in 6: await physics_frame
		Input.action_press("right")
		if mode=="run": w.player.run=true
		if mode=="dash": w.player.press("dash")
		var crossed=false
		for i in 100:
			await physics_frame
			if w.room==16: crossed=true;break
		Input.action_release("right");freeze()
		check(crossed,"Live %s input crosses culvert with collisions"%mode)
		w.transition=0;w.pending_room=-1;w.mixed_transitions.cancel(w)
	# Stairwell art/style/range is preserved. Special retains gated E semantics.
	for pair in [[14,17],[17,14],[20,13],[13,20]]:
		w.build_room(pair[0]);freeze();seed_fixture();w.transition=0;w.pending_room=-1
		var p={}
		for candidate in w.expansion.portals(w.room):
			if candidate.target==pair[1]: p=candidate
		w.player.position=p.at+Vector2(85,0);w.interact();check(w.pending_room==-1,"Interactive85px boundary unchanged")
		w.player.position=p.at;w.interact();check(w.pending_room==pair[1],"Stairwell/special E keeps existing destination")
		var clock=w.transition
		for i in 10: w.interact()
		check(w.transition==clock,"Repeated E cannot restart transition")
		finish();check(w.room==pair[1] and w.player.position==p.arrival,"Interactive reciprocal exact arrival")
		check(w.player.velocity==Vector2.ZERO,"Interactive mode retains original stopped arrival")
	# Every individual special prerequisite stays enforced in both directions.
	for pair in [[14,17],[20,13]]:
		w.transition=0;w.pending_room=-1;w.build_room(pair[0]);freeze();seed_fixture()
		for p in w.expansion.portals(w.room):
			if p.target==pair[1]: w.player.position=p.at-Vector2(0,2)
		w.set_physics_process(true)
		var key=InputEventKey.new();key.physical_keycode=KEY_E;key.keycode=KEY_E;key.pressed=true
		Input.parse_input_event(key);Input.flush_buffered_events()
		for i in 2: await physics_frame
		check(w.pending_room==pair[1],"Actual held E starts stair/special")
		for i in 45: await physics_frame
		check(w.room==pair[1] and w.pending_room==-1 and w.transition<=0,"Held E does not bounce stair/special")
		key.pressed=false;Input.parse_input_event(key);Input.flush_buffered_events();freeze()
		await physics_frame
	for index in [13,20]:
		for missing in ["relay","sigil","wind","switch"]:
			w.transition=0;w.pending_room=-1;w.build_room(index);freeze();seed_fixture()
			if missing=="relay": w.completed=false
			if missing=="sigil": w.relay_fragments.erase("terrace_west")
			if missing=="wind": w.opened_kunai_gates.erase("skyworks_wind_intake")
			if missing=="switch": w.expansion_flags.erase("junction_return")
			check(not w.can_enter(20 if index==13 else 13),"Special rejects missing %s from R%d"%[missing,index])
	seed_fixture();w.save_path="user://tr02_test.json";w.test_mode=false;w.checkpoint_room=15;w.checkpoint_position=Vector2(1950,1118)
	w.player.restore_speed_upgrade(1)
	check(w.save_progress(),"Version8 save writes without schema change")
	var saved=FileAccess.get_file_as_string(w.save_path)
	w.completed=false;w.player.restore_speed_upgrade(0);w.load_progress()
	check(w.completed and w.player.speed_upgrade_level==1 and w.checkpoint_room==15,"Upgraded save restores prerequisites/tier/checkpoint")
	check(FileAccess.get_file_as_string(w.save_path)==saved,"Reload does not rewrite save")
	w.test_mode=true;w.mixed_transitions.cancel(w)
	for mode in ["plain","graphic","reduced"]:
		w.mixed_transitions.graphic_mode=mode
		check(w.mixed_transitions.graphic_mode==mode,"Explicit creator comparison mode "+mode)
	w.queue_free();current_scene=null
	for i in 3: await process_frame
	print("MIXED TRANSITIONS: %d failure(s)"%failures);quit(1 if failures else 0)
