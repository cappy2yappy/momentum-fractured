extends "res://tests/native_cinematic_transitions.gd"
## Real physics/key-event regression. No position or velocity writes during approaches.
## Fresh cases walk from the normal R0 spawn into R1, with no save/ability fixtures.
var held_keys={}
func key(code,pressed):
	held_keys[code]=pressed
	super.key(code,pressed)

func wait_ticks(count):
	for i in count:
		await physics_frame
		# Windows clears held keys on focus loss. Reissue only a lost held key,
		# through the same InputEventKey path; never drive the controller directly.
		for code in held_keys:
			if held_keys[code] and not Input.is_physical_key_pressed(code): super.key(code,true)

func fresh():
	for code in [KEY_A,KEY_D,KEY_SPACE,KEY_SHIFT,KEY_E]: key(code,false)
	if is_instance_valid(w):
		w.queue_free();await process_frame
	w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w
	automation_hud()
	await wait_ticks(3)
	check(not w.test_mode and w.room==0 and not w.player.double_jump,"Fresh normal save path, R0, no Windstep")
	key(KEY_D,true)
	for tick in 420:
		await wait_ticks(1)
		if w.cinematic_transitions.request_count>0: break
	key(KEY_D,false)
	await wait_ticks(45)
	check(w.room==1 and w.player.is_on_floor(),"Fresh real-key R0->R1 traversal arrives supported")

func approach(pair,offset,style):
	var c=w.cinematic_transitions
	var p=c.endpoint(w,pair[0],pair[1])
	var code=KEY_A if p.heading<0 else KEY_D
	var before=c.request_count
	if style=="sprint":
		key(code,true);await wait_ticks(2);key(code,false);await wait_ticks(1)
	key(code,true)
	var jumped=false
	var jump_tick=-1
	var wall_stopped=false
	var airborne=false
	for tick in 360:
		if not jumped and style=="jump" and (p.at.x-w.player.position.x)*p.heading<=40+offset:
			key(KEY_SPACE,true);jumped=true;jump_tick=tick
		if jumped and tick==jump_tick+8: key(KEY_SPACE,false)
		if tick==5 and style=="dash": key(KEY_SHIFT,true)
		if tick==6 and style=="dash": key(KEY_SHIFT,false)
		await wait_ticks(1)
		if w.room==pair[0] and w.transition<=0:
			airborne=airborne or not w.player.is_on_floor()
			wall_stopped=wall_stopped or (w.player.is_on_wall() and absf(w.player.velocity.x)<1)
		if c.request_count>before: break
	key(code,false);key(KEY_SPACE,false);key(KEY_SHIFT,false)
	print("TRACE pair=",pair," offset=",offset," style=",style," pos=",w.player.position," velocity=",w.player.velocity," floor=",w.player.is_on_floor()," wall_stopped=",wall_stopped," airborne=",airborne)
	check(c.request_count==before+1,"Real keys %s %s offset=%d requests exactly once"%[pair,style,offset])
	await wait_ticks(55)
	check(w.room==pair[1] and w.player.is_on_floor(),"Real keys %s %s offset=%d lands supported"%[pair,style,offset])
	if DisplayServer.get_name()!="headless" and style=="jump" and offset==0 and pair in [[1,0],[13,14]]:
		await shot("tr06_jump_%d-%d_landed"%pair)
	await wait_ticks(40)
	check(c.request_count==before+1,"Stopped arrival cannot loop")

func stage(pair,distance=180):
	for code in [KEY_A,KEY_D,KEY_SPACE,KEY_SHIFT,KEY_E]: key(code,false)
	reset(pair[0]);var p=w.cinematic_transitions.endpoint(w,pair[0],pair[1])
	w.player.position=p.at-Vector2(p.heading*distance,2);w.player.velocity=Vector2.ZERO
	w.player.run=false;w.player.last_tap=-10;w.player.dash_cooldown=0
	live();await wait_ticks(4)
	return p

func controls():
	for pair in [[13,0],[13,14],[14,13],[1,0],[1,2]]:
		var p=await stage(pair)
		var c=w.cinematic_transitions
		var before=c.request_count
		var outward=KEY_A if p.heading<0 else KEY_D
		var inward=KEY_D if p.heading<0 else KEY_A
		key(outward,true);await wait_ticks(7);key(outward,false);await wait_ticks(30)
		check(w.room==pair[0] and c.request_count==before,"Stop before threshold stays in %s"%[pair])
		key(inward,true);await wait_ticks(8);key(inward,false);await wait_ticks(12)
		check(c.request_count==before,"Reverse away from %s does not activate"%[pair])
		key(outward,true)
		for tick in 100:
			await wait_ticks(1)
			if c.request_count>before: break
		await wait_ticks(80);key(outward,false)
		print("CONTROL pair=",pair," room=",w.room," requests=",c.request_count-before," pos=",w.player.position," physics=",w.player.is_physics_processing()," paused=",paused)
		check(w.room==pair[1] and c.request_count==before+1,"Held direction through %s causes no arrival loop"%[pair])
	# Miss the aperture with a jump, release against the wall, then reapproach.
	var p=await stage([13,0]);var c=w.cinematic_transitions;var before=c.request_count
	key(KEY_A,true)
	for tick in 90:
		if w.player.position.x<=p.at.x+80: break
		await wait_ticks(1)
	key(KEY_SPACE,true);await wait_ticks(8);key(KEY_SPACE,false)
	for tick in 80:
		await wait_ticks(1)
		if w.player.is_on_wall(): break
	check(not w.player.is_on_floor(),"Release fixture reaches wall airborne through physics")
	key(KEY_A,false);await wait_ticks(180)
	check(w.room==13 and w.player.is_on_floor() and c.request_count==before,"Airborne wall approach released to idle does not activate")
	key(KEY_D,true);await wait_ticks(4)
	check(c.request_count==before,"Inward key at missed wall exit does not activate")
	key(KEY_D,false);await wait_ticks(10);key(KEY_A,true);await wait_ticks(80);key(KEY_A,false)
	check(w.room==0 and c.request_count==before+1,"Outward reapproach recovers missed wall exit")

func guards_and_hints():
	await stage([5,4],100)
	var c=w.cinematic_transitions
	var before=c.request_count
	check(c.armed.get(4,false),"Wrong-height fixture first arms at correct endpoint shelf")
	# Adversarial staging: actual lower floor beneath the elevated R5 left exit.
	w.player.position=Vector2(14.1,1298);w.player.velocity=Vector2.ZERO
	await wait_ticks(6);key(KEY_A,true);await wait_ticks(30);key(KEY_A,false)
	check(w.player.is_on_floor() and c.request_count==before,"Armed outward wall contact on wrong floor cannot recover")
	await stage([13,0],100)
	w.player.position=Vector2(14.1,1198);w.player.velocity=Vector2.ZERO
	await wait_ticks(6)
	before=c.request_count;w.player.tether_attached=true;key(KEY_A,true)
	c.update(w,1.0/60.0)
	check(c.request_count==before,"Supported recovery rejects tether-attached state")
	key(KEY_A,false);w.player.tether_attached=false
	var tested=0
	for index in 21:
		reset(index)
		for p in c.endpoints(w,index):
			if p.mode!="horizontal_walk": continue
			reset(index)
			w.player.double_jump=false;w.player.tether_unlocked=false;w.player.dash_unlocked=false
			w.completed=false;w.boss_defeated=false;w.relay_fragments.clear();w.opened_kunai_gates.clear();w.expansion_flags.clear()
			w.player.kunai_unlocked={"wind":false,"fire":false,"electric":false}
			w.message=""
			if w.can_enter(p.target): continue
			var expected=w.message
			if expected.is_empty(): expected="Route sealed: "+p.need.replace("_"," ").to_upper()+". Consult the atlas."
			# Repeating an authored hint with the same timer must not erase it.
			w.message=expected;w.message_time=4
			cross(p)
			check(w.transition==0 and w.message==expected,"Gate R%d->R%d retains prerequisite: %s"%[index,p.target,expected])
			tested+=1
	print("TR06 gated automatic endpoints=",tested)

func run():
	await process_frame
	output="res://build/tr06/native"
	DirAccess.make_dir_recursive_absolute(output)
	print("TR06 engine=",Engine.get_version_info().string," driver=",RenderingServer.get_current_rendering_driver_name())
	for offset in range(0,41,5):
		await fresh()
		await approach([1,0],offset,"jump")
	# Endpoint fixtures only establish initial room/abilities. Movement remains live.
	for pair in [[13,0],[13,14],[14,13],[1,2]]:
		for style in ["walk","sprint","dash","jump"]:
			for offset in ([0,10,20,30,40] if style=="jump" else [0]):
				reset(pair[0]);var p=w.cinematic_transitions.endpoint(w,pair[0],pair[1])
				w.player.position=p.at-Vector2(p.heading*180,2);w.player.velocity=Vector2.ZERO
				live();await wait_ticks(4)
				await approach(pair,offset,style)
	reset(1);w.player.double_jump=false
	var p=w.cinematic_transitions.endpoint(w,1,2)
	w.player.position=p.at-Vector2(100,2);w.player.velocity=Vector2.ZERO
	live();await wait_ticks(4);key(KEY_D,true);await wait_ticks(50);key(KEY_D,false)
	check(w.room==1 and w.transition==0,"Locked Windstep gate blocks real walking")
	check("Windstep" in w.message,"Locked gate preserves authored Windstep hint: "+w.message)
	await controls()
	await guards_and_hints()
	# Broader coverage uses endpoint staging, not a claim of unseeded campaign traversal.
	var pairs=[]
	for index in 21:
		for ep in w.cinematic_transitions.endpoints(w,index):
			if ep.mode=="horizontal_walk": pairs.append([index,ep.target])
	for pair in pairs:
		await stage(pair,100)
		await approach(pair,0,"jump")
	print("TR06 broader native endpoints=",pairs.size())
	w.queue_free();current_scene=null
	for i in 3: await process_frame
	print("TR06: %d checks, %d failure(s)"%[checks,failures]);quit(1 if failures else 0)
