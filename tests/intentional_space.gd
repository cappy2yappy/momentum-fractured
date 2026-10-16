extends "res://tests/expansion_traversal.gd"
func run():
	await process_frame
	w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w;w.set_physics_process(false);w.player.set_physics_process(false)
	w.save_path="user://ld03-disposable.json"
	w.build_room(14)
	for e in w.enemies: e.set_physics_process(false)
	await physics_frame
	var b=w.BellroofWalk
	check(w.ROOM_COUNT==21 and w.world_edges().size()==29,"21 rooms /29 links retained")
	check(b.SOLIDS.size()==6 and b.STEPS.size()==6,"Six grounded masses and six recoverable steps built")
	for rect in b.SOLIDS+b.STEPS:
		check(rect in w.platforms,"Visible lower geometry exists in collision data: %s"%rect)
		var found=false
		for body in w.geometry.get_children():
			if not body is StaticBody2D or body.get_child_count()==0: continue
			var shape=body.get_child(0)
			if shape is CollisionShape2D and shape.shape is RectangleShape2D and shape.position==rect.get_center() and shape.shape.size==rect.size:
				found=body.collision_layer==1 and shape.one_way_collision==(rect in b.STEPS)
		check(found,"Layer/one-way policy matches masonry versus steps: %s"%rect.position)
	check(w.expansion.LORE[14]==b.LOG_POSITION,"Existing optional log registered to its lower alcove")
	w.player.double_jump=false;w.player.dash_unlocked=false;w.player.tether_unlocked=false;w.player.restore_speed_upgrade(0);w.player.momentum.enabled=false
	var routes=[
		[Rect2(300,1300,160,40),b.SOLIDS[0],b.SOLIDS[1],b.SOLIDS[2],b.SOLIDS[3],b.STEPS[1],b.STEPS[2],Rect2(1590,830,320,40)],
		[Rect2(350,1300,160,40),b.STEPS[0],Rect2(0,1100,600,40)],
		[Rect2(2440,1300,160,40),b.STEPS[5],b.STEPS[3],b.STEPS[4],Rect2(1900,830,700,40)],
		[b.SOLIDS[4],b.SOLIDS[5],b.STEPS[3]],
	]
	for path in routes:
		for i in range(1,path.size()): await leap(path[i-1],path[i],14)
	# Every solid foundation ends at the retained floor, not above empty space.
	for rect in b.SOLIDS: check(rect.end.y==1300,"Foundation is grounded at actual floor: %s"%rect.position)
	w.player.set_physics_process(false);w.player.position=b.LOG_POSITION-Vector2(0,2);w.player.velocity=Vector2.ZERO
	w.expansion_flags.erase("lore_14");w.expansion.update(w,1.0/60.0)
	check(w.expansion_flags.get("lore_14",false),"New location collects the existing optional log flag")
	var completed=w.completed;var fragments=w.relay_fragments.duplicate();var opened=w.opened_kunai_gates.duplicate()
	w.expansion.update(w,1.0/60.0)
	check(w.completed==completed and w.relay_fragments==fragments and w.opened_kunai_gates==opened,"Log does not award mandatory progression or open gates")
	check(not w.expansion.allowed(w,"relay") and not w.expansion.allowed(w,"climb"),"Lower route cannot bypass locked Terrace/Spire progression")
	# Simulate a historical R14 checkpoint in the now-solid pier. Godot must
	# recover it safely through existing physics, or the design must leave it free.
	w.player.position=Vector2(950,1298);w.player.velocity=Vector2.ZERO;w.player.set_physics_process(true)
	for i in 5: await physics_frame
	check(w.player.is_on_floor() and absf(w.player.position.y-1300)<1,"Historical structure14 fixture remains free and grounded")
	w.player.set_physics_process(false)
	for rect in b.SOLIDS:
		var old=Vector2(rect.get_center().x,1298)
		var staged=b.stage_checkpoint(w,old)
		w.player.position=staged;await physics_frame
		var query=PhysicsShapeQueryParameters2D.new();query.shape=w.player.get_child(0).shape;query.transform=w.player.get_child(0).global_transform;query.collision_mask=1
		check(staged.x==old.x and staged.y<=old.y and w.player.get_world_2d().direct_space_state.intersect_shape(query).is_empty(),"Old save feet receive capsule-clear staging: %s -> %s"%[old,staged])
	check(b.stage_checkpoint(w,Vector2(950,1298))==Vector2(950,1298),"Unobstructed historical Bellroof save stays exact")
	w.test_mode=false;w.checkpoint_room=14;w.checkpoint_position=Vector2(1300,1298)
	w.expansion_flags.lore_14=true;w.player.double_jump=true
	check(w.save_progress(),"Version8 Bellroof save with old lower-floor feet writes")
	w.expansion_flags.clear();w.checkpoint_room=0;w.load_progress();w.respawn();w.player.set_physics_process(false);await physics_frame
	check(w.room==14 and w.checkpoint_position==Vector2(1300,1218) and w.player.double_jump and w.expansion_flags.get("lore_14",false),"Reload/respawn stages old feet and preserves earned ability/lore")
	w.expansion_flags.erase("lore_14");w.expansion.update(w,1.0/60.0)
	check(w.expansion_flags.get("lore_14",false),"Uncollected old save can discover relocated log")
	w.build_room(15)
	check(b.stage_checkpoint(w,Vector2(1300,1298))==Vector2(1300,1298),"Other-room checkpoint coordinates stay exact")
	w.queue_free();current_scene=null
	for i in 3: await process_frame
	print("INTENTIONAL SPACE: %d failure(s)"%failures);quit(1 if failures else 0)
