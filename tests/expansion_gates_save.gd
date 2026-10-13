extends SceneTree
var failures=0
var w
func _init(): call_deferred("run")
func check(ok,message):
	print("PASS: " if ok else "FAIL: ",message)
	if not ok: failures+=1
func freeze():
	w.set_physics_process(false);w.player.set_physics_process(false)
	for enemy in w.enemies: enemy.set_physics_process(false)
func save_reload():
	w.test_mode=false;w.save_progress();w.test_mode=true
	w.opened_kunai_gates.clear();w.secret=false;w.completed=false;w.expansion_flags.clear();w.load_progress()
func run():
	await process_frame
	w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w;freeze()
	w.save_path="user://dev06_gate_states.json"
	for index in [2,7]:
		w.build_room(index);freeze()
		var seal="cistern_wind_cache" if index==2 else "relay_electric_seal"
		var at=Vector2(2300,830) if index==2 else Vector2(2200,1300)
		w.opened_kunai_gates.erase(seal);w.secret=false;w.completed=false
		w.checkpoint_room=index;w.checkpoint_position=at-Vector2(0,2)
		save_reload();w.player.position=at
		if index==2: w._physics_process(0)
		else: w.interact()
		check(not (w.secret if index==2 else w.completed),"Locked reward stays locked after saved alternate-side approach: %s"%seal)
		w.opened_kunai_gates[seal]=true
		save_reload();w.player.position=at
		if index==2: w._physics_process(0)
		else: w.interact()
		check(w.secret if index==2 else w.completed,"Opened but uncollected state survives reload: %s"%seal)
		save_reload()
		check((w.secret if index==2 else w.completed) and w.opened_kunai_gates.get(seal,false),"Completed reward and seal survive reload: %s"%seal)
	for index in [15,17,18,19]:
		w.build_room(index);freeze();await process_frame
		var gate=w.Expansion.GATES[index];var at=gate[2]-Vector2(120,60)
		w.spawn_kunai("fire" if gate[1]!="fire" else "wind",1,at)
		for tick in 25: await physics_frame
		check(not w.opened_kunai_gates.get(gate[0],false),"Wrong real projectile rejected: "+gate[0])
		w.spawn_kunai(gate[1],1,at)
		for tick in 25: await physics_frame
		check(w.opened_kunai_gates.get(gate[0],false),"Matching real projectile opens: "+gate[0])
	# Version 7 thirteen-room save migration preserves earned kit; app/save identity unchanged.
	w.player.unlock_speed_upgrade("stride_1");save_reload()
	var data=JSON.parse_string(FileAccess.get_file_as_string(w.save_path))
	data.version=7;data.visited.resize(13);data.erase("expansion_flags");data.checkpoint_room=7;data.checkpoint_position=[2200,1298]
	var file=FileAccess.open(w.save_path,FileAccess.WRITE);file.store_string(JSON.stringify(data));file.close()
	w.visited.fill(false);w.load_progress()
	check(w.visited.size()==21 and not w.visited[20],"Legacy visited array expands without claiming exploration")
	check(w.player.speed_upgrade_level==1 and w.checkpoint_room==7 and w.completed,"Version 7 earned speed/Archive/checkpoint survive migration")
	check(w.expansion_flags.is_empty(),"Legacy save does not unlock new shortcut or lore")
	w.queue_free();current_scene=null
	for tick in 3: await process_frame
	print("EXPANSION GATES SAVE: %d failure(s)"%failures);quit(1 if failures else 0)
