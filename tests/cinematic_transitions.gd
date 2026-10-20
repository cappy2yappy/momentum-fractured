extends SceneTree
var w
var failures=0
var checks=0
func _init(): call_deferred("run")
func check(ok,label):
	checks+=1
	print("PASS: " if ok else "FAIL: ",label)
	if not ok: failures+=1
func freeze():
	w.set_physics_process(false);w.player.set_physics_process(false)
	for e in w.enemies: e.set_physics_process(false)
func seed_fixture():
	w.completed=true;w.guard_defeated=true;w.boss_defeated=true
	w.player.double_jump=true;w.player.dash_unlocked=true;w.player.tether_unlocked=true
	w.player.hp=3;w.player.release_tether();w.player.dash_time=0
	w.relay_fragments={"undercroft_sigil":true,"terrace_west":true,"terrace_fire_cache":true}
	w.opened_kunai_gates={"skyworks_wind_intake":true,"cistern_wind_cache":true,"foundry_electric_relay":true,"spire_wind_shutter":true,"pump_electric_isolator":true,"coil_fire_service":true}
	w.expansion_flags={"junction_return":true}
	for element in ["wind","fire","electric"]: w.player.kunai_unlocked[element]=true
func reset(index):
	w.cinematic_transitions.cancel(w);w.embodied_transitions.cancel(w);w.mixed_transitions.cancel(w)
	w.transition=0;w.pending_room=-1;w.pending_arrival=Vector2.INF
	w.build_room(index);freeze();seed_fixture();w.cinematic_transitions.cooldown=0
	w.camera.zoom=Vector2.ONE;w.camera.position=Vector2(0,-110);w.camera.offset=Vector2.ZERO;w.camera.position_smoothing_enabled=true
func ticks(count):
	for i in count: w._physics_process(1.0/60.0)
	freeze()
func cross(p,height=0,backward=false,tether=false):
	var dir=int(p.heading)
	w.player.set_physics_process(true)
	w.player.position=p.at+Vector2(-60*dir,-2+height)
	w.player.velocity=Vector2((-400 if backward else 400)*dir,0)
	w.player.tether_attached=tether
	w.cinematic_transitions.update(w,0)
	w.player.position=p.at+Vector2(2*dir,-2+height)
	w.cinematic_transitions.update(w,1.0/60.0)
	w.player.set_physics_process(false)
func run():
	await process_frame
	w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w;freeze();seed_fixture()
	var c=w.cinematic_transitions
	check(c.enabled,"TR05 is ordinary default, not a launcher-only effect")
	var count=0
	for index in 21:
		reset(index)
		for p in c.endpoints(w,index):
			var shape=c.policy(w,index,p.target)
			if p.mode!="horizontal_walk":
				check(shape.get("trigger","")!="automatic","R%d->R%d meaningful entrance retains interaction"%[index,p.target])
				continue
			count+=1;reset(index)
			check(c.automatic(w,index,p.target),"R%d->R%d side passage automatic"%[index,p.target])
			w.player.position=p.at-Vector2(0,2);w.interact()
			check(w.transition==0,"E does not activate ordinary R%d->R%d"%[index,p.target])
			cross(p)
			check(w.pending_room==p.target and w.transition==0.65,"Directional crossing requests R%d->R%d once"%[index,p.target])
			var total=c.request_count
			for repeat in 5: w.interact()
			ticks(42)
			check(w.room==p.target and w.transition<=0 and c.request_count==total,"R%d->R%d completes0.65s without duplicate E"%[index,p.target])
			var back=c.endpoint(w,p.target,index)
			if back.mode=="horizontal_walk":
				check(w.player.position==c.arrival_position(w,back) and w.player.facing==-int(back.heading),"R%d arrival is inward and facing away from door"%p.target)
			check(w.player.sprite.visible and not w.embodied_transitions.proxy.visible,"R%d actual character restored"%p.target)
			await physics_frame
			var query=PhysicsShapeQueryParameters2D.new()
			query.shape=w.player.get_child(0).shape;query.transform=w.player.get_child(0).global_transform;query.collision_mask=1
			check(w.player.get_world_2d().direct_space_state.intersect_shape(query).is_empty(),"R%d arrival capsule has no immediate solid overlap"%p.target)
			# Idle at arrival beyond cooldown never causes a proximity/held-E bounce.
			w.player.velocity=Vector2.ZERO;w.player.set_physics_process(true)
			for tick in 90:
				c.update(w,1.0/60.0);w.interact()
			w.player.set_physics_process(false)
			# Meaningful interior entrances may respond to NEW E calls; only wall
			# reciprocal assertions apply here (held-key native proof is separate).
			if back.mode=="horizontal_walk": check(c.request_count==total and w.transition<=0,"R%d reciprocal threshold cannot loop while stationary"%p.target)
	print("AUTOMATIC ENDPOINTS=",count)
	# Specific Canal and reciprocal R13 direction regression.
	for pair in [[13,0],[13,14],[14,13],[15,16],[16,15]]:
		reset(pair[0]);var p=c.endpoint(w,pair[0],pair[1])
		check(p.mode=="horizontal_walk","Required pilot %s is horizontal"%[pair])
		for reason in ["wrong_height","backwards","tether"]:
			reset(pair[0]);cross(p, -200 if reason=="wrong_height" else 0,reason=="backwards",reason=="tether")
			check(w.transition==0,"%s rejects %s crossing"%[pair,reason])
	reset(13);w.player.double_jump=false;cross(c.endpoint(w,13,0))
	check(w.pending_room==-1 and w.transition==0,"Canal-left keeps windstep gate")
	reset(15);w.completed=false;cross(c.endpoint(w,15,16))
	check(w.pending_room==-1,"Archive passage remains locked without completion")
	# Both staircase directions: actual visual displacement, camera and cleanup.
	# TR-08 reviewed change (docs/tr08/TEST_CHANGES.md): the stair is now the default
	# full-screen cinematic. E opens the stage first and releases the unchanged 0.65 s
	# loader under the opaque cover; Kaze travels on the stage, never the world camera.
	for still in [false,true]:
		for pair in [[14,17],[17,14]]:
			reset(pair[0]);c.reduced=still;c.tr08.reduced=still;w.embodied_transitions.comparison="reduced" if still else "art-preview"
			var p=c.endpoint(w,pair[0],pair[1]);w.player.position=p.at-Vector2(0,2);w.player.velocity=Vector2.ZERO
			w.interact();var feet=w.player.position
			var stage=c.tr08.stair
			check(stage.phase=="open" and w.transition==0,"Stair %s E opens the TR-08 full-screen stage"%[pair])
			var released=-1
			for tick in 40:
				ticks(1)
				if w.transition>0: released=tick;break
			check(released>=0 and w.transition>0.6 and w.pending_room==pair[1],"Stair %s releases the existing loader clock under the cover"%[pair])
			check(w.player.position==feet and w.player.velocity==Vector2.ZERO,"Cinematic never drives collision-body root motion")
			while stage.phase=="open": ticks(1)
			ticks(3);var first=stage.feet
			ticks(12);var second=stage.feet
			check(first.distance_to(second)>25 and signf(second.y-first.y)==w.embodied_transitions.PILOTS["%d:%d"%pair].rise,"Stair %s stage visibly moves Kaze along correct rise"%[pair])
			if still:
				check(stage.zoom==1.0 and w.camera.zoom==Vector2.ONE,"Reduced staircase keeps fixed framing and world camera")
			else:
				check(stage.layer.visible and stage.kaze.base_scale*float(stage.kaze.clip.figure)>=360,"Cinematic stair is full-screen with Kaze at cinematic scale")
			var guard=0
			while stage.phase!="" and guard<400:
				ticks(1);guard+=1
			var bounds=stage.last_duration<=1.6 if still else (stage.last_duration>=2.5 and stage.last_duration<=4.0)
			check(w.room==pair[1] and w.player.sprite.visible and stage.last_result=="completed" and bounds,"Stair %s arrives and restores live Kaze (%.2f s)"%[pair,stage.last_duration])
			check(w.camera.zoom==Vector2.ONE and w.camera.position==Vector2(0,-110) and w.camera.position_smoothing_enabled,"Camera fully restored after stair %s"%[pair])
			check(w.player.position==c.endpoint(w,pair[1],pair[0]).at-Vector2(0,2),"Stair %s arrival feet are the unchanged reciprocal endpoint"%[pair])
	c.reduced=false;c.tr08.reduced=false
	for reason in ["respawn","rebuild","pause","toggle"]:
		reset(14);w.embodied_transitions.comparison="art-preview";w.player.position=Vector2(1450,478);w.interact();ticks(8)
		if reason=="respawn": w.checkpoint_room=0;w.respawn();freeze()
		elif reason=="rebuild": w.build_room(15);freeze()
		elif reason=="pause": paused=true;await process_frame;await process_frame;paused=false
		else:
			var event=InputEventKey.new();event.physical_keycode=KEY_F6;event.pressed=true;c._unhandled_key_input(event)
			check(c.reduced,"F6 enables reduced motion during active stair")
		check(w.camera.zoom==Vector2.ONE and w.camera.position==Vector2(0,-110),"Camera restores on "+reason)
		c.reduced=false
	reset(0);w.player.position=Vector2(590,778);w.interact()
	check(w.pending_room==13,"Meaningful interior depth entrance0->13 still uses E")
	reset(20);w.player.position=Vector2(600,518);w.interact()
	check(w.pending_room==13 and w.embodied_transitions.policy(w,20,13).mode=="wind_fold","Exceptional wind-fold keeps E and its own policy")
	reset(13);w.player.double_jump=false
	for p in c.endpoints(w,13):
		if p.mode=="horizontal_walk": check(c.passage_allowed(w,p)==w.can_enter(p.target),"Silent locked artwork agrees with authoritative gate")
	check(w.ROOM_COUNT==21 and w.expansion.EDGES.size()==15,"Room graph stays21 rooms and15 expansion links")
	w.queue_free();current_scene=null
	for i in 3: await process_frame
	print("TR05: %d checks, %d failure(s)"%[checks,failures]);quit(1 if failures else 0)
