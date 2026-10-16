extends SceneTree
var failures=0
var w
func _init(): call_deferred("run")
func check(ok,label):
	print("PASS: " if ok else "FAIL: ",label)
	if not ok: failures+=1
func freeze():
	w.set_physics_process(false);w.player.set_physics_process(false)
	for e in w.enemies: e.set_physics_process(false)
func ticks(count):
	for i in count: w.player._physics_process(1.0/60.0)
func run():
	await process_frame
	w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w;freeze()
	w.save_path="user://tr04-disposable.json"
	var p=w.player
	for index in w.LevelGeometry.LANDINGS:
		w.build_room(index);freeze();await physics_frame
		for at in w.LevelGeometry.LANDINGS[index]:
			var edge=28 if at.x<200 else w.room_size(index).x-28
			p.position=Vector2(edge,at.y-2);p.velocity=Vector2.ZERO;p.touch={};ticks(30)
			check(p.is_on_floor() and absf(p.position.y-at.y)<1,"R%d %s perimeter supports stopped capsule"%[index,at])
			var grounded=true
			for speed in [400,600,630,920]:
				p.position=at-Vector2(0,2);p.velocity=Vector2(-speed if edge<200 else speed,0)
				p.touch={"left":edge<200,"right":edge>200};p.run=speed>=600;ticks(50)
				p.touch={};ticks(30)
				grounded=grounded and p.is_on_floor() and absf(p.position.y-at.y)<1
			check(grounded,"R%d walk/sprint/upgraded/inherited920 stop at perimeter"%index)
			# Expansion ledges must still pass upward and catch a downward landing.
			if index>=13:
				p.touch={};p.position=Vector2(edge,at.y+76);p.velocity=Vector2(0,-600);p.touch.jump=true
				var rose=false
				for i in 22:
					p._physics_process(1.0/60.0);rose=rose or p.position.y<at.y-5
				check(rose,"R%d one-way extension retains upward passage"%index)
				p.touch={};p.position=Vector2(edge,at.y-75);p.velocity=Vector2(0,200);ticks(30)
				check(p.is_on_floor() and absf(p.position.y-at.y)<1,"R%d extension catches downward landing"%index)
	# Item stop/reapproach on the affected Canal Ward link, with the real pickup.
	w.build_room(13);freeze();await physics_frame
	p.position=Vector2(450,440);p.velocity=Vector2.ZERO;p.touch={};w.expansion.update(w,1.0/60.0)
	check(p.speed_upgrade_level==1,"Real Stride pickup still collects while stopped")
	p.position=Vector2(28,1198);p.velocity=Vector2.ZERO;ticks(120)
	p.touch.right=true;ticks(12);p.touch={};ticks(20)
	p.double_jump=false;w.interact()
	check(w.pending_room==-1 and p.is_on_floor(),"Locked Canal exit keeps safe footing after stop/reapproach")
	p.double_jump=true
	if w.cinematic_transitions.enabled:
		p.set_physics_process(true);w.cinematic_transitions.cooldown=0
		p.position=Vector2(180,1198);p.velocity=Vector2(-400,0);w.cinematic_transitions.update(w,0)
		p.position=Vector2(118,1198);w.cinematic_transitions.update(w,0);p.set_physics_process(false)
	else: p.position=Vector2(120,1198);w.interact()
	check(w.pending_room==0,"Canal left exit reapproach activates with its current passage policy")
	for i in 41: w._physics_process(1.0/60.0)
	freeze();await physics_frame;ticks(30)
	check(w.room==0 and p.is_on_floor(),"Canal reciprocal arrival remains supported")
	w.build_room(10);freeze();w.request_room(9)
	for i in 20: w._physics_process(1.0/60.0)
	freeze();await physics_frame
	var query=PhysicsShapeQueryParameters2D.new();query.shape=p.get_child(0).shape;query.transform=p.get_child(0).global_transform;query.collision_mask=1
	check(p.get_world_2d().direct_space_state.intersect_shape(query).is_empty(),"Terrace capsule has no solid overlap immediately after swap")
	for i in 21: w._physics_process(1.0/60.0)
	freeze();await physics_frame;ticks(30)
	check(w.room==9 and p.is_on_floor() and absf(p.position.y-810)<1,"Terrace legacy arrival settles above solid shelf, not inside it")
	check(w.LevelGeometry.legacy_arrival(9,Vector2(480,618))==Vector2(480,618),"Explicit Terrace return arrival remains untouched")
	check(w.ROOM_COUNT==21 and w.world_edges().size()==29,"21 rooms and 29 links preserved")
	w.queue_free();current_scene=null
	for i in 3: await process_frame
	print("LEVEL GEOMETRY: %d failure(s)"%failures);quit(1 if failures else 0)
