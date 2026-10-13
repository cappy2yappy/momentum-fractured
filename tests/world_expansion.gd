extends SceneTree
var failures=0
var assertions=0
var w
func _init(): call_deferred("run")
func check(ok,message):
	assertions+=1
	print("PASS: " if ok else "FAIL: ",message)
	if not ok: failures+=1
func freeze():
	w.set_physics_process(false);w.player.set_physics_process(false)
	for e in w.enemies: e.set_physics_process(false)
func run():
	await process_frame
	w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w;freeze()
	check(w.ROOM_COUNT==21,"Exactly 21 append-only rooms")
	check(not w.player.momentum.enabled,"Momentum defaults disabled")
	check(w.player.grapple_range==440,"Integrated grapple range 440")
	var reached={0:true}
	for iteration in 21:
		for edge in w.world_edges():
			if reached.has(edge[0]): reached[edge[1]]=true
			if reached.has(edge[1]): reached[edge[0]]=true
	check(reached.size()==21,"World graph contains no isolated room")
	check(w.ROOM_MAP_COORDS.size()==21 and w.ROOM_NAMES.size()==21 and w.ROOM_REGIONS.size()==21,"Metadata covers all rooms")
	var coords={}
	for cell in w.ROOM_MAP_COORDS: coords[cell]=true
	check(coords.size()==21,"Map coordinates never overlap")
	# Negative approaches: geometry bypass must not grant reward or restoration.
	w.build_room(2);freeze();w.player.position=Vector2(2300,830);w._physics_process(0)
	check(not w.secret,"Cistern reward blocked behind unopened seal")
	w.opened_kunai_gates["cistern_wind_cache"]=true;w._physics_process(0)
	check(w.secret,"Cistern reward collected after opened seal")
	w.build_room(7);freeze();w.player.position=Vector2(2200,1300);w.interact()
	check(not w.completed,"Archive console blocked behind unopened Electric seal")
	w.opened_kunai_gates["relay_electric_seal"]=true;w.interact()
	check(w.completed,"Archive restoration accepted after opened seal")
	w.relay_fragments={"optional_a":true,"optional_b":true,"optional_c":true}
	w.build_room(9);freeze()
	check(not w.can_enter(10),"Arbitrary optional pickups cannot replace named sigils")
	w.relay_fragments={"undercroft_sigil":true,"terrace_west":true,"terrace_fire_cache":true}
	w.player.double_jump=true;w.player.tether_unlocked=true;w.player.dash_unlocked=true
	for element in ["wind","fire","electric"]: w.player.unlock_kunai(element)
	w.opened_kunai_gates.merge({"skyworks_wind_intake":true,"spire_wind_shutter":true,"pump_electric_isolator":true,"coil_fire_service":true,"lower_sluice_wind":true},true)
	w.expansion_flags["junction_return"]=true
	# Run actual transition timer for both directions and settle each arrival with collisions.
	for edge in w.Expansion.EDGES:
		for pair in [[edge.a,edge.b],[edge.b,edge.a]]:
			w.transition=0;w.pending_room=-1;w.build_room(pair[0]);freeze()
			var portal=null
			for candidate in w.expansion.portals(pair[0]):
				if candidate.target==pair[1]: portal=candidate
			check(portal!=null,"Reciprocal definition %d -> %d"%pair)
			w.player.position=portal.at;w.expansion.interact(w)
			for tick in 45: w._physics_process(1.0/60.0)
			freeze()
			check(w.room==pair[1] and w.player.position.distance_to(portal.arrival)<1,"Transition exact arrival %d -> %d"%pair)
			w.player.velocity=Vector2.ZERO;w.player.set_physics_process(true)
			for tick in 8: await physics_frame
			check(w.player.is_on_floor() and w.player.position.distance_to(portal.arrival)<5,"Arrival settles on safe floor %d -> %d"%pair)
			freeze()
	# Every mandatory ordinary step is conservative and each room has a recovery floor.
	for index in range(13,21):
		w.build_room(index);freeze();await process_frame
		var size=w.room_size(index)
		check(w.platforms.has(Rect2(0,size.y-140,size.x,140)),"Room %d has solid recovery floor"%index)
		check(w.camera.limit_right==size.x and w.camera.limit_bottom==size.y,"Room %d camera follows actual bounds"%index)
		check(w.room_discovery_level(index)==2,"Room %d map explored"%index)
		var steps=w.expansion.route_steps
		var safe=true
		for i in range(1,steps.size()):
			var a=steps[i-1];var b=steps[i]
			if absf(a.position.y-b.position.y)>180.1: safe=false
			if absf(a.get_center().x-b.get_center().x)-(a.size.x+b.size.x)/2.0>100.1: safe=false
		check(safe,"Room %d ordinary steps retain clearance below baseline jump envelope"%index)
		for e in w.enemies:
			var x=e.position.x;w.player.position=Vector2(size.x,e.position.y)
			for tick in 600: e._physics_process(1.0/60.0)
			check(e.position.x<=e.patrol_max and e.position.x>=e.patrol_min,"Room %d guard remains on bounded platform"%index)
			e.position.x=x
		for object in w.geometry.get_children():
			if object.get_script()==w.Expansion.Anchor:
				var at=object.get_attachment_position()
				var clearance=true
				for r in w.platforms:
					if r.grow(16).has_point(at): clearance=false
				check(clearance,"Room %d anchor is outside solid/support art collision"%index)
	# Actual pickup is single ownership and saves together with shortcut/checkpoint.
	w.build_room(13);freeze();w.player.restore_speed_upgrade(0);w.player.position=Vector2(450,440);w._physics_process(0)
	check(w.player.speed_upgrade_level==1 and w.player.movement_target_speed(false)==420,"In-world Stride I pickup awards tier one")
	w._physics_process(0);check(w.player.speed_upgrade_level==1,"Stride pickup cannot duplicate")
	w.build_room(16);freeze();w.player.position=Vector2(420,1120);w.interact()
	check(w.checkpoint_room==16 and w.checkpoint_position==Vector2(420,1118),"Root Shrine saves exact resting position")
	w.save_path="user://dev06_regression.json";w.test_mode=false
	check(w.save_progress(),"Version 8 expanded save written")
	w.test_mode=true;w.player.restore_speed_upgrade(0);w.expansion_flags.clear();w.visited.fill(false);w.load_progress()
	check(w.player.speed_upgrade_level==1 and w.expansion_flags.get("junction_return",false),"Stride and junction flag persist across reload")
	check(w.checkpoint_room==16 and w.visited[20],"New checkpoint and exploration persist")
	check(w.secret and w.completed and w.opened_kunai_gates.get("relay_electric_seal",false),"Opened seals and rewards persist")
	# Missing progression prerequisites reject both edge directions even at upgraded speed.
	for edge in w.Expansion.EDGES:
		for pair in [[edge.a,edge.b],[edge.b,edge.a]]:
			w.build_room(pair[0]);freeze()
			var old_completed=w.completed;var old_dash=w.player.dash_unlocked;var old_jump=w.player.double_jump
			var saved_gates=w.opened_kunai_gates.duplicate()
			w.completed=false;w.player.dash_unlocked=false;w.player.double_jump=false;w.opened_kunai_gates.clear()
			check(not w.can_enter(pair[1]),"Missing prerequisites fail closed %d -> %d"%pair)
			w.completed=old_completed;w.player.dash_unlocked=old_dash;w.player.double_jump=old_jump;w.opened_kunai_gates=saved_gates
	w.queue_free();current_scene=null
	for tick in 3: await process_frame
	print("WORLD EXPANSION: %d assertions, %d failure(s)"%[assertions,failures]);quit(1 if failures else 0)
