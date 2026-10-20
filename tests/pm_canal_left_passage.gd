extends "res://tests/automatic_passage_reliability.gd"
## PM pilot (TRANSITION): Canal-left (R13 (120,1200) -> R0) automatic passage against the
## LEVEL contract geometry. Real InputEventKey input and live physics on every approach.
## If scripts/canal_gatehouse.gd (LEVEL branch) is not combined into this checkout, the
## contract's back pier and gatehouse mass are STUBBED with the same rectangles via the
## ordinary world.add_platform path. The log states which geometry was used.
const Data = preload("res://scripts/transition_pilot_data.gd")
const GATEHOUSE = "res://scripts/canal_gatehouse.gd"
var stubbed = false

func level_combined() -> bool:
	return ResourceLoader.exists(GATEHOUSE)

func ensure_geometry():
	if w.room!=13 or level_combined(): return
	if Data.CANAL_LEFT.pier in w.platforms: return
	w.add_platform(Data.CANAL_LEFT.pier);w.add_platform(Data.CANAL_LEFT.mass);stubbed=true

func reset(index):
	super.reset(index)
	ensure_geometry()

func canal_stage(x:float):
	for code in [KEY_A,KEY_D,KEY_SPACE,KEY_SHIFT,KEY_E]: key(code,false)
	reset(13)
	w.player.position=Vector2(x,1198);w.player.velocity=Vector2.ZERO
	w.player.run=false;w.player.last_tap=-10;w.player.dash_cooldown=0
	live();await wait_ticks(6)

func contract_checks():
	var d=Data.CANAL_LEFT
	reset(13);var c=w.cinematic_transitions;var p=c.endpoint(w,13,0)
	check(p.at==Vector2(d.door_x,d.floor_y) and p.mode=="horizontal_walk" and int(p.heading)==-1,"Runtime Canal endpoint matches contract door centre/floor and heading")
	check(c.arrival_position(w,c.endpoint(w,13,0))==d.arrival,"Runtime R13 arrival matches contract (184,1198)")
	check(d.aperture.position.x<d.trigger_x and d.trigger_x<d.aperture.end.x,"Trigger line lies inside the drawn aperture")
	check(d.aperture.encloses(Rect2(d.trigger_x-14,d.floor_y-60,28,60)),"Kaze 28x60 capsule at the trigger is fully inside the aperture")
	check(d.frame.encloses(d.aperture) and d.aperture.end.y==d.floor_y and d.frame.end.y==d.floor_y,"Frame encloses aperture; both sit on the walking surface")
	if level_combined():
		var g=load(GATEHOUSE)
		check(g.APERTURE==d.aperture and g.PIER==d.pier and g.MASS==d.mass and g.DOOR_X==d.door_x,"LEVEL gatehouse constants equal the transition data block")
	# Behavioral mirror of the unchanged update(): trigger x, corridor and arming.
	for case in [[121.0,120.0,1198.0,true],[125.0,121.0,1198.0,false],[124.0,119.0,1110.0,true],[124.0,119.0,1107.0,false],[124.0,119.0,1208.0,true],[124.0,119.0,1210.0,false]]:
		reset(13);w.player.set_physics_process(true)
		w.player.position=Vector2(200,1198);c.update(w,0) # arm (x>=136)
		check(c.armed.get(0,false),"Inward line x>=%d arms the passage"%int(d.arm_x))
		w.player.position=Vector2(case[0],case[2]);w.player.velocity=Vector2(-400,0);c.update(w,1.0/60.0)
		w.player.position=Vector2(case[1],case[2]);c.update(w,1.0/60.0)
		w.player.set_physics_process(false)
		check((w.pending_room==0)==case[3],"Crossing %.0f->%.0f at feet y %.0f %s"%[case[0],case[1],case[2],"fires" if case[3] else "does not fire"])
	reset(13);w.player.set_physics_process(true)
	w.player.position=Vector2(130,1198);c.update(w,0);w.player.position=Vector2(119,1198);w.player.velocity=Vector2(-400,0);c.update(w,1.0/60.0)
	w.player.set_physics_process(false)
	check(w.pending_room==-1,"Never armed (no inward x>=136 sample): no activation")

func approaches():
	var c=w.cinematic_transitions
	for style in ["walk","sprint","dash","jump"]:
		for offset in ([0,10,20,30,40] if style=="jump" else [0]):
			reset(13);w.player.position=Vector2(300,1198);w.player.velocity=Vector2.ZERO
			live();await wait_ticks(4)
			await approach([13,0],offset,style)

func no_unintended():
	var c=w.cinematic_transitions
	# Stand inside the aperture (not crossed) holding E: never activates.
	await canal_stage(150)
	var before=c.request_count
	key(KEY_E,true);await wait_ticks(120);key(KEY_E,false)
	check(c.request_count==before and w.room==13,"Idle inside the opening holding E does not activate")
	# Walk inward out of the hallway.
	key(KEY_D,true);await wait_ticks(40);key(KEY_D,false);await wait_ticks(10)
	check(c.request_count==before and w.room==13,"Walking inward away from the door does not activate")
	# Jump straight up under the hallway ceiling.
	await canal_stage(200);before=c.request_count
	key(KEY_SPACE,true);await wait_ticks(12);key(KEY_SPACE,false);await wait_ticks(70)
	check(c.request_count==before and w.room==13 and w.player.is_on_floor(),"Vertical jump under the ceiling does not activate")
	check(w.player.position.x>136,"Vertical jump stays in the hallway")
	# Stop short of the trigger, then reverse.
	await canal_stage(260);before=c.request_count
	key(KEY_A,true);await wait_ticks(14);key(KEY_A,false);await wait_ticks(40)
	print("STOP x=",w.player.position.x)
	check(c.request_count==before and w.player.position.x>Data.CANAL_LEFT.trigger_x,"Stop before the trigger line stays in R13")
	key(KEY_D,true);await wait_ticks(10);key(KEY_D,false);await wait_ticks(10)
	check(c.request_count==before,"Reverse after stopping does not activate")
	# Jump toward the door, release before landing, settle: no activation; then reapproach.
	await canal_stage(300);before=c.request_count
	key(KEY_A,true)
	for tick in 90:
		if w.player.position.x<=200: break
		await wait_ticks(1)
	key(KEY_SPACE,true);await wait_ticks(8);key(KEY_SPACE,false)
	await wait_ticks(6);key(KEY_A,false)
	await wait_ticks(120)
	print("RELEASED x=",w.player.position.x," floor=",w.player.is_on_floor()," requests=",c.request_count-before)
	var crossed_released=w.player.position.x<=Data.CANAL_LEFT.trigger_x
	check(w.player.is_on_floor() and (c.request_count==before or not crossed_released),"Released airborne approach settles without a held-direction activation")
	if c.request_count==before:
		key(KEY_D,true);await wait_ticks(4);key(KEY_D,false);await wait_ticks(4)
		check(c.request_count==before,"Inward tap at the door does not activate")
		key(KEY_A,true);await wait_ticks(70);key(KEY_A,false)
		check(c.request_count==before+1 and w.room==0,"Outward reapproach activates exactly once")
	# Leftmost reachable feet x against the pier, and recovery only on the pad.
	# Leftmost reachable feet x: walk in from the hallway and hold left against the pier.
	await canal_stage(140);before=c.request_count
	# TR-08 reviewed change: the embodied doorway turn/cross precedes the room request,
	# so wait for the request and the hidden swap (bounded) instead of a fixed 60 ticks.
	key(KEY_A,true)
	for tick in 150:
		await wait_ticks(1)
		if w.room==0: break
	key(KEY_A,false)
	print("PIER-WALK x=",w.player.position.x," room=",w.room," requests=",c.request_count-before)
	check(c.request_count==before+1 and w.room==0,"Walking into the opening from just inside activates once")
	# Arrival from R0 into the hallway and no reciprocal loop.
	reset(0);w.player.position=Vector2(590,778);live();await wait_ticks(3)
	before=c.request_count
	key(KEY_E,true);await wait_ticks(1);key(KEY_E,false)
	# TR-08 reviewed change: wait for the embodied passage to hand back control (bounded)
	# instead of a fixed 45 ticks; the arrival point itself is unchanged.
	for tick in 300:
		await wait_ticks(1)
		if w.room==13 and not c.tr08.owns() and w.transition<=0: break
	ensure_geometry()
	check(w.room==13 and w.player.position.distance_to(Data.CANAL_LEFT.arrival)<3,"R0 -> R13 arrives in the hallway at the contract arrival")
	await physics_frame
	var query=PhysicsShapeQueryParameters2D.new()
	query.shape=w.player.get_child(0).shape;query.transform=w.player.get_child(0).global_transform;query.collision_mask=1
	check(w.player.get_world_2d().direct_space_state.intersect_shape(query).is_empty(),"Hallway arrival capsule clear of pier/mass/ceiling")
	await wait_ticks(150)
	check(w.room==13 and c.request_count==before+1,"Idle after hallway arrival cannot loop back")

func run():
	await process_frame
	output="res://build/pm_pilot/transition"
	DirAccess.make_dir_recursive_absolute(output)
	w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w;freeze();seed_fixture()
	automation_hud()
	print("PM CANAL geometry=",("LEVEL canal_gatehouse.gd combined" if level_combined() else "STUB from CANAL_CONTRACT v1 rectangles"))
	await contract_checks()
	await approaches()
	await no_unintended()
	print("PM CANAL stubbed=",stubbed)
	w.queue_free();current_scene=null
	for i in 3: await process_frame
	print("PM CANAL LEFT: %d checks, %d failure(s)"%[checks,failures]);quit(1 if failures else 0)
