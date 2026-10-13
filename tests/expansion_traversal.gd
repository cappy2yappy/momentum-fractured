extends SceneTree
var w
var failures=0
func _init(): call_deferred("run")
func check(ok,message):
	print("PASS: " if ok else "FAIL: ",message)
	if not ok: failures+=1
func leap(a:Rect2,b:Rect2,index:int):
	w.player.set_physics_process(false)
	var dir=1 if b.get_center().x>a.get_center().x else -1
	var start_x=clampf(b.get_center().x,a.position.x+28,a.end.x-28)
	# Launch near the facing edge only when landings do not overlap.
	if b.position.x>a.end.x: start_x=a.end.x-28
	elif b.end.x<a.position.x: start_x=a.position.x+28
	w.player.position=Vector2(start_x,a.position.y-2);w.player.velocity=Vector2.ZERO
	w.player.jump_buffer=0;w.player.air_used=false;w.player.run=false;w.player.last_tap=-10
	w.player.set_physics_process(true)
	for tick in 5: await physics_frame
	var action="right" if dir>0 else "left"
	Input.action_press("jump")
	var landed=false
	for tick in 100:
		# The preserved controller retains horizontal velocity in air. Counter-steer
		# using its measured air acceleration, instead of assuming release brakes.
		var projected=w.player.position.x+w.player.velocity.x*absf(w.player.velocity.x)/2400.0
		var error=b.get_center().x-projected
		Input.action_release("right");Input.action_release("left")
		if absf(error)>12: Input.action_press("right" if error>0 else "left")
		w.player.run=false;w.player.last_tap=-10
		await physics_frame
		# Brake above the middle of the intended landing rather than running off it.
		# Intermediate rises fit a single held jump; double-jump is available but not needed.
		# One-way service ledges can land Kaze on a higher overlapping waypoint.
		# Accept that only inside this route's landing corridor, never a lower floor.
		if tick>15 and w.player.is_on_floor() and w.player.position.x>=b.position.x+14 and w.player.position.x<=b.end.x-14 and w.player.position.y<=b.position.y+4:
			landed=true;break
	Input.action_release("right");Input.action_release("left");Input.action_release("jump");w.player.set_physics_process(false)
	check(landed,"Base-speed live landing room %d: %s -> %s; end=%s"%[index,a.position,b.position,w.player.position])
func run():
	await process_frame
	w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w;w.set_physics_process(false)
	w.player.double_jump=true;w.player.tether_unlocked=true;w.player.dash_unlocked=true
	w.player.momentum.enabled=false;w.player.restore_speed_upgrade(0)
	for gate in ["lower_sluice_wind","spire_wind_shutter","pump_electric_isolator","coil_fire_service"]: w.opened_kunai_gates[gate]=true
	for index in range(13,21):
		w.build_room(index);w.player.set_physics_process(false)
		for e in w.enemies: e.set_physics_process(false)
		await process_frame
		var steps=w.expansion.route_steps.duplicate()
		for i in range(1,steps.size()): await leap(steps[i-1],steps[i],index)
		# Every object must offer a real unobstructed attachment approach.
		for object in w.geometry.get_children():
			if object.get_script()!=w.Expansion.Anchor: continue
			var at=object.get_attachment_position();var eligible=false
			for dx in [-250,-160,-80,80,160,250]:
				for dy in [110,200,300]:
					w.player.position=at+Vector2(dx,dy);w.player.velocity=Vector2.ZERO;w.player.set_physics_process(true)
					await physics_frame;await physics_frame;w.player.set_physics_process(false)
					w.player.facing=-1 if dx>0 else 1
					if w.player.can_tether_anchor(at): eligible=true;break
				if eligible: break
			check(eligible,"Room %d object anchor %s has actual facing/height/airborne/clearance eligibility"%[index,at])
		w.player.position=Vector2(w.room_size(index).x/2,w.room_size(index).y-145)
		w.player.velocity=Vector2.ZERO;w.player.set_physics_process(true)
		for tick in 8: await physics_frame
		check(w.player.is_on_floor(),"Room %d failed traversal recovers on dry floor"%index)
		w.player.set_physics_process(false)
	w.queue_free();current_scene=null
	for tick in 3: await process_frame
	print("EXPANSION TRAVERSAL: %d failure(s)"%failures);quit(1 if failures else 0)
