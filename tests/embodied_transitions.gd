extends SceneTree
var w
var failures=0
var assertions=0
var observed_modes=[]
func _init(): call_deferred("run")
func check(ok,text):
	assertions+=1;print("PASS: " if ok else "FAIL: ",text)
	if not ok: failures+=1
func freeze():
	w.set_physics_process(false);w.player.set_physics_process(false)
	for e in w.enemies: e.set_physics_process(false)
func seed_fixture():
	w.completed=true;w.player.double_jump=true;w.player.tether_unlocked=true;w.player.dash_unlocked=true
	w.relay_fragments={"undercroft_sigil":true,"terrace_west":true,"terrace_fire_cache":true}
	w.opened_kunai_gates["skyworks_wind_intake"]=true;w.expansion_flags["junction_return"]=true
func portal(a,b):
	for p in w.expansion.portals(a):
		if p.target==b: return p
	return {}
func reset(index):
	w.embodied_transitions.cancel(w);w.transition=0;w.pending_room=-1;w.mixed_transitions.cancel(w)
	w.build_room(index);freeze();seed_fixture();w.player.hp=3
func finish():
	var swap_ticks=[];var source=w.room;var tick=0
	while w.transition>0 and tick<45:
		w._physics_process(1.0/60.0);tick+=1
		if w.room!=source and swap_ticks.is_empty(): swap_ticks.append(tick)
	freeze()
	check(tick==39 or tick==40,"Original0.65s clock resumes within floating-point tick tolerance")
	check(swap_ticks==[20],"Room swap stays on original below0.32 threshold / tick20")
func run():
	await process_frame
	w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w;freeze();seed_fixture()
	check(w.world_edges().size()==29 and w.ROOM_COUNT==21,"21-room /29-link graph preserved")
	check(w.embodied_transitions.comparison=="refined","Refined scoped comparison defaults active")
	check(not w.embodied_transitions.depth_demo,"Depth demonstration opt-in only")
	check(w.embodied_transitions.policy(w,14,13).mode=="fallback","Ambiguous doorway remains fallback by default")
	check(w.embodied_transitions.policy(w,14,17).mode=="stair_up" and w.embodied_transitions.policy(w,17,14).mode=="stair_down","Stair directions authored explicitly, not room-y inferred")
	check(w.embodied_transitions.policy(w,20,13).mode=="wind_fold","Exceptional wind-fold remains original")
	# Every directed edge receives an explicit presentation classification.
	var classified=0
	for edge in w.world_edges():
		for pair in [[edge[0],edge[1]],[edge[1],edge[0]]]:
			if w.embodied_transitions.policy(w,pair[0],pair[1]).mode in ["fallback","horizontal_walk","stair_up","stair_down","wind_fold"]: classified+=1
	check(classified==58,"All58 directed endpoints classified without invented links")
	for pair in [[14,17],[17,14],[14,13],[13,14]]:
		reset(pair[0]);w.embodied_transitions.depth_demo=true
		var p=portal(pair[0],pair[1]);w.player.position=p.at-Vector2(0,2);w.player.velocity=Vector2(173,-20);w.player.animate(0)
		var position=w.player.position;var scale=w.player.sprite.scale;var offset=w.player.sprite.offset;var facing=w.player.facing
		w.interact()
		check(w.pending_room==pair[1] and w.transition==0.65,"Existing E activation and clock %d->%d"%pair)
		check(w.embodied_transitions.active and not w.player.sprite.visible and w.embodied_transitions.proxy.visible,"Exactly one visible render representation during staging")
		var width=w.embodied_transitions.proxy.scale.x
		for tick in 12: w._physics_process(1.0/60.0)
		check(w.player.position==position and w.player.velocity==Vector2(173,-20),"Proxy never alters departure simulation position/velocity")
		check(w.player.sprite.scale==scale and w.player.sprite.offset==offset and w.player.facing==facing,"Actual sprite registration and facing unchanged")
		if pair in [[14,13],[13,14]]:
			check(absf(w.embodied_transitions.proxy.position.x-p.at.x)<0.1,"Inward entry stays on doorway depth axis after approach")
			check(w.embodied_transitions.proxy.scale.x<width,"Depth turn uses labeled render-only quarter placeholder")
		else:
			var dy=w.embodied_transitions.proxy.position.y-p.at.y
			check(signf(dy)==w.embodied_transitions.rise,"Stair contact rises/descends in explicit direction")
		for tick in 30: w._physics_process(1.0/60.0)
		freeze()
		check(w.room==pair[1] and w.player.position==p.arrival,"Authoritative exact reciprocal arrival retained")
		check(w.player.velocity==Vector2.ZERO,"Interactive arrival still stops simulation")
		check(w.player.sprite.visible and not w.embodied_transitions.active and not w.embodied_transitions.proxy.visible,"Completion restores actual character and clears proxy")
		check(w.player.sprite.scale==scale and w.player.sprite.offset==offset,"Completion never changes actual clip scale/pivot")
	# No clock mutation or doubled request under repeated E.
	reset(14);w.player.position=portal(14,17).at;w.interact()
	var remaining=w.transition
	for i in 8: w.interact()
	check(w.transition==remaining,"Repeated E cannot restart embodied clock")
	finish()
	# Abort handling, including pause while the existing loader remains frozen.
	for reason in ["pause","death","rebuild"]:
		reset(14);w.player.position=portal(14,17).at;w.interact()
		if reason=="pause":
			paused=true;await process_frame;await process_frame
			check(w.transition==0.65 and not w.embodied_transitions.active and w.player.sprite.visible,"Pause restores visuals without discarding pending authoritative transition")
			paused=false;finish()
		elif reason=="death":
			w.checkpoint_room=0;w.respawn();freeze()
			check(w.pending_room==-1 and w.transition==0 and w.player.sprite.visible and not w.embodied_transitions.proxy.visible,"Death restores actual sprite and cancels transition")
		else:
			w.build_room(14);freeze()
			check(w.player.sprite.visible and not w.embodied_transitions.active,"Unrelated rebuild restores proxy-hidden character")
	reset(14);w.player.dash_unlocked=false;w.player.position=portal(14,17).at;w.interact()
	check(w.pending_room==-1 and not w.embodied_transitions.active and w.player.sprite.visible,"Denied gate cannot hide character or start staging")
	# Non-mutating architecture: full collision snapshot before/after drawing controls.
	for index in [14,15]:
		reset(index);var signature=JSON.stringify(w.platforms);var children=w.geometry.get_child_count();var gates=JSON.stringify(w.opened_kunai_gates)
		w.embodied_transitions.structural_dressing=false;w.build_room(index);freeze()
		check(JSON.stringify(w.platforms)==signature and w.geometry.get_child_count()==children and JSON.stringify(w.opened_kunai_gates)==gates,"Dressing toggle leaves platforms, colliders, gates unchanged R%d"%index)
	# Live grounded input samples; no helper pretending the player is grounded.
	for pair in [[15,16],[16,15]]:
		for running in [false,true]:
			reset(pair[0]);w.embodied_transitions.comparison="refined";w.embodied_transitions.depth_demo=false
			var p=portal(pair[0],pair[1]);var dir=w.MixedTransitions.WALK[pair[0]].direction
			w.player.position=p.at+Vector2(-130*dir,-2);w.player.velocity=Vector2.ZERO;w.player.run=false
			w.player.last_tap=-10;w.mixed_transitions.cooldown=0
			w.set_physics_process(true);w.player.set_physics_process(true)
			for tick in 6: await physics_frame
			var action="right" if dir>0 else "left";Input.action_press(action)
			if running:
				await physics_frame;Input.action_release(action);await physics_frame;Input.action_press(action)
				await physics_frame;await physics_frame
				check(w.player.run,"Actual directional double-tap activates existing run state")
			var seen=false;var carried=0.0;var sampled_mode=""
			for tick in 100:
				await physics_frame
				if w.embodied_transitions.active:
					seen=true;sampled_mode=w.embodied_transitions.mode;carried=w.mixed_transitions.carried_x
					observed_modes.append(sampled_mode);break
			Input.action_release(action);freeze()
			check(seen and sampled_mode==("horizontal_run" if running else "horizontal_walk"),"Live grounded intent selects %s from R%d"%["run" if running else "walk",pair[0]])
			check(not running or w.embodied_transitions.proxy.texture==w.player.clips.run,"Running reuses current approved eight-frame clip")
			for tick in 42: w._physics_process(1.0/60.0)
			freeze()
			check(w.room==pair[1] and w.player.position==p.arrival and w.player.velocity.x==carried,"Live passage keeps exact TR-02 x carry / arrival")
	# Current TR-02, refined, reduced and plain retain core gating/clock behavior.
	for comparison in ["original","refined","reduced","plain"]:
		reset(14);w.embodied_transitions.comparison=comparison
		w.player.position=portal(14,17).at;w.interact()
		check(w.embodied_transitions.active==(comparison in ["refined","reduced"]),"Explicit comparison route "+comparison)
		if comparison=="reduced":
			w._physics_process(0.05);var at=w.embodied_transitions.proxy.position
			w._physics_process(0.05)
			check(w.embodied_transitions.proxy.position==at and w.embodied_transitions.proxy.frame==0,"Reduced motion uses static pose without translation or cycling")
		for tick in 45: w._physics_process(1.0/60.0)
		freeze();check(w.room==17 and w.player.position==portal(14,17).arrival,"Comparison mode never changes destination")
	# Input mapping is observed, not claimed to have hardware testing.
	var key_e=false
	for event in InputMap.action_get_events("interact"):
		if event is InputEventKey and event.physical_keycode==KEY_E: key_e=true
	check(key_e,"Existing keyboard E mapping preserved")
	var joy=false
	for event in InputMap.action_get_events("interact"):
		if event is InputEventJoypadButton or event is InputEventJoypadMotion: joy=true
	print("LIMITATION: gamepad interaction mapping inherited=",joy,"; physical hardware not available")
	w.queue_free();current_scene=null
	for tick in 3: await process_frame
	print("EMBODIED TRANSITIONS: %d assertions, %d failure(s)"%[assertions,failures]);quit(1 if failures else 0)
