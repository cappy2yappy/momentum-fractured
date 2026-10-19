extends "res://tests/automatic_passage_reliability.gd"
## LEVEL pilot: Canal-left (R13 left exit <-> R0) geometry. Real InputEventKey movement only.
## Fixtures set the starting room, abilities and the initial feet position, never positions
## or velocities during an approach. Contract: docs/pm_pilot/CANAL_CONTRACT.md.
const Gatehouse = preload("res://scripts/canal_gatehouse.gd")
const DOOR = Vector2(120,1200)
var mode_label = "after"

func place(pos, index = 13):
	for code in [KEY_A,KEY_D,KEY_SPACE,KEY_SHIFT,KEY_E,KEY_Q]: key(code,false)
	reset(index)
	w.player.position = pos;w.player.velocity = Vector2.ZERO
	w.player.run = false;w.player.last_tap = -10;w.player.dash_cooldown = 0
	live();await wait_ticks(4)

func req() -> int:
	return w.cinematic_transitions.request_count

# events: [[tick, keycode, down], ...]. Runs until the transition requests or `limit` ticks.
func play(events, limit = 300, stop_on_request = true):
	var before = req()
	var tick = 0
	var miny = w.player.position.y
	var minx = w.player.position.x
	var maxx = minx
	while tick < limit:
		for e in events:
			if e[0] == tick: key(e[1],e[2])
		await wait_ticks(1)
		tick += 1
		if w.room == 13 and w.transition <= 0:
			miny = minf(miny,w.player.position.y);minx = minf(minx,w.player.position.x);maxx = maxf(maxx,w.player.position.x)
		if stop_on_request and req() > before: break
	for code in [KEY_A,KEY_D,KEY_SPACE,KEY_SHIFT]: key(code,false)
	return {"requests":req() - before,"miny":miny,"minx":minx,"maxx":maxx,"ticks":tick}

func settle_exit(label, result, before):
	check(result.requests == 1,"%s requests the R13->R0 passage exactly once"%label)
	await wait_ticks(60)
	check(w.room == 0 and w.player.is_on_floor(),"%s lands supported in R0 (%s)"%[label,w.player.position])
	check(req() == before + 1,"%s did not loop after arrival"%label)
	await wait_ticks(60)
	check(w.room == 0 and req() == before + 1,"%s stays in R0 after settling"%label)

func exit_case(label, start, events, limit = 300):
	await place(start)
	var before = req()
	var r = await play(events,limit)
	await settle_exit(label,r,before)
	return r

func geometry_facts():
	await place(Vector2(184,1198))
	var rects = w.platforms
	var aperture = Gatehouse.APERTURE
	var blockers = 0
	for r in rects:
		if r.position.x < 0 or r.position.x >= 1800: continue
		if r.intersects(aperture): blockers += 1
	check(blockers == 0,"Door aperture %s has no collider inside it (found %d)"%[aperture,blockers])
	check(aperture.get_center().x == DOOR.x and aperture.end.y == DOOR.y,"Aperture is centred on door x=120 and stands on y=1200")
	var supported = false
	for r in rects:
		if r.position.y == 1200 and r.position.x <= aperture.position.x and r.end.x >= aperture.end.x: supported = true
	check(supported,"A support rectangle at y=1200 spans the whole aperture")
	var capsule_h = 60.0
	check(aperture.size.y > capsule_h * 2 and Gatehouse.CEILING_Y == 1020.0 and (1200.0 - Gatehouse.CEILING_Y) / capsule_h == 3.0,"Aperture 132 and ceiling clearance 180 versus Kaze height 60")
	var ep = w.cinematic_transitions.endpoint(w,13,0)
	check(ep.at == DOOR and ep.mode == "horizontal_walk" and ep.heading == -1,"Trigger endpoint unchanged: at (120,1200), horizontal_walk, heading -1")
	check(ep.at.x >= aperture.position.x + 14 and ep.at.x <= aperture.end.x - 14,"Trigger x lies where Kaze's whole body is inside the aperture")
	var mass = Gatehouse.MASS
	check(mass.end.x < 300 and mass.end.y == 1020.0,"Enclosure mass stays left of x=300 (shelf at 300,440 untouched) and ends at the lintel")
	for shelf in [Rect2(200,1160,400,40),Rect2(720,940,360,40),Rect2(1220,720,400,40),Rect2(1400,560,360,40),Rect2(600,480,500,40),Rect2(300,440,400,40),Rect2(740,400,320,40)]:
		var present = false
		for r in w.platforms:
			# TR-04 may extend perimeter shelves to the room edge; the top and start must be retained.
			if r.position == shelf.position and r.size.y == 40 and r.end.x >= shelf.end.x: present = true
		check(present and not shelf.intersects(mass) and not shelf.intersects(Gatehouse.PIER),"Route shelf %s retained and clear of the enclosure"%shelf)
	check(w.platforms.has(Rect2(0,1200,360,40)),"Exit pad is still the extended landing (0,1200,360,40)")
	check(w.geometry.get_child_count() > 0,"Colliders exist")
	# Collision is the same rectangles that are drawn: every mass body shape matches a platform rect.
	var shape_rects = []
	for body in w.geometry.get_children():
		for child in body.get_children():
			if child is CollisionShape2D and child.shape is RectangleShape2D:
				shape_rects.append(Rect2(child.position - child.shape.size / 2.0,child.shape.size))
	check(shape_rects.has(Gatehouse.MASS) and shape_rects.has(Gatehouse.PIER),"Enclosure colliders equal the visible rectangles")
	# Arrival from R0 is inside the hallway, under the lintel, supported.
	var arrival = w.cinematic_transitions.arrival_position(w,ep)
	check(arrival == Vector2(184,1198),"Arrival point in R13 is (184,1198), got %s"%arrival)

func approaches():
	var A = KEY_A;var D = KEY_D
	var b0 = req()
	await exit_case("Walk from mouth",Vector2(340,1198),[[0,A,true]])
	await exit_case("Walk from inside hall",Vector2(250,1198),[[0,A,true]])
	await exit_case("Sprint (double tap) from mouth",Vector2(340,1198),[[0,A,true],[1,A,false],[3,A,true]])
	await exit_case("Dash from mouth",Vector2(340,1198),[[0,A,true],[6,KEY_SHIFT,true],[7,KEY_SHIFT,false]])
	await exit_case("Dash starting inside hall",Vector2(280,1198),[[0,A,true],[2,KEY_SHIFT,true],[3,KEY_SHIFT,false]])
	for jt in [0,10,20,30,40,50,60,80]:
		await exit_case("Jump at tick %d"%jt,Vector2(360,1198),[[0,A,true],[jt,KEY_SPACE,true],[jt + 12,KEY_SPACE,false]])
	await exit_case("Jump inside hall bumps ceiling",Vector2(250,1198),[[0,A,true],[3,KEY_SPACE,true],[30,KEY_SPACE,false]])
	await exit_case("Double jump in hall",Vector2(280,1198),[[0,A,true],[2,KEY_SPACE,true],[8,KEY_SPACE,false],[14,KEY_SPACE,true],[28,KEY_SPACE,false]])
	await exit_case("Fall from shelf (200,1160)",Vector2(240,1158),[[0,A,true]])
	await exit_case("Fall from stair step (500,1050)",Vector2(520,1048),[[0,A,true]],500)
	await exit_case("Jump up from floor beside the pad",Vector2(400,1298),[[0,A,true],[2,KEY_SPACE,true],[18,KEY_SPACE,false]],500)
	await exit_case("Jump up from floor under the pad",Vector2(330,1298),[[0,A,true],[2,KEY_SPACE,true],[22,KEY_SPACE,false]],500)
	# Stopping before the threshold, then continuing.
	await place(Vector2(340,1198));var before = req()
	var r = await play([[0,A,true],[14,A,false]],40,false)
	check(r.requests == 0 and w.room == 13,"Stop in the mouth does not trigger")
	await wait_ticks(40)
	check(req() == before and w.room == 13 and w.player.position.x > 120,"Stopped Kaze stays put left of the mouth and right of the door")
	r = await play([[0,A,true]],200)
	await settle_exit("Resume after stopping",r,before)
	# Reversing: toward the door, back out, then in again.
	await place(Vector2(340,1198));before = req()
	r = await play([[0,A,true],[22,A,false],[22,D,true],[44,D,false],[44,A,true]],400)
	await settle_exit("Reversal",r,before)
	# Reverse with the door still ahead: turning around before it never triggers.
	await place(Vector2(250,1198));before = req()
	r = await play([[0,A,true],[10,A,false],[10,D,true]],90,false)
	check(r.requests == 0 and w.player.position.x > 250,"Reversing before the door leaves the hall without triggering")
	# Failed jump: jump, change mind in mid air, land, then take the door.
	await place(Vector2(360,1198));before = req()
	r = await play([[0,A,true],[5,KEY_SPACE,true],[17,KEY_SPACE,false],[19,A,false],[19,D,true],[40,D,false]],160,false)
	check(r.requests == 0 and w.room == 13 and w.player.is_on_floor(),"Aborted jump lands safely on the exit support")
	r = await play([[0,A,true]],300)
	await settle_exit("Re-approach after aborted jump",r,before)
	# Overshoot into the end of the hallway without trigger (cannot happen at normal speed),
	# so verify the leftmost stop is the pier face and recovery fires by holding left.
	await place(Vector2(200,1198));before = req()
	r = await play([[0,A,true]],200)
	check(r.requests == 1 and r.minx >= 86 - 1.5,"Leftmost reachable x is the pier face plus radius (min %.2f)"%r.minx)
	await settle_exit("Walk from the middle of the hall",r,before)
	# Held direction through the door and past arrival in R0.
	await place(Vector2(340,1198));before = req()
	await play([[0,A,true]],300,true)
	key(A,true);await wait_ticks(140);key(A,false)
	check(w.room == 0 and req() == before + 1,"Held left through R13->R0 does not bounce back")

func round_trip():
	for cycle in 3:
		await place(Vector2(590,778),0)
		var c = w.cinematic_transitions
		var before = c.request_count
		key(KEY_E,true);await wait_ticks(2);key(KEY_E,false)
		await wait_ticks(60)
		check(w.room == 13 and w.player.is_on_floor(),"Cycle %d R0->R13 by E arrives supported"%cycle)
		check(w.player.position.distance_to(Vector2(184,1198)) < 3.0,"Cycle %d arrival at (184,1198), got %s"%[cycle,w.player.position])
		check(w.player.facing == 1,"Arrival faces into the room")
		await wait_ticks(60)
		check(w.room == 13,"Cycle %d does not bounce back from stationary arrival"%cycle)
		key(KEY_E,true);await wait_ticks(80);key(KEY_E,false)
		check(w.room == 13,"Cycle %d held E cannot send Kaze back through the walk-through exit"%cycle)
		var b2 = c.request_count
		key(KEY_A,true)
		for t in 140:
			await wait_ticks(1)
			if c.request_count > b2: break
		key(KEY_A,false)
		await wait_ticks(60)
		check(w.room == 0 and c.request_count == b2 + 1,"Cycle %d R13->R0 by walking left"%cycle)
		check(w.player.is_on_floor(),"Cycle %d lands supported in R0"%cycle)

func stride_pickup():
	await place(Vector2(330,438))
	check(w.player.speed_upgrade_level == 0,"Stride I not yet collected")
	key(KEY_D,true)
	for t in 120:
		await wait_ticks(1)
		if w.player.speed_upgrade_level == 1: break
	key(KEY_D,false)
	check(w.player.speed_upgrade_level == 1,"Stride I pickup at (450,440) collected by real walking from the shelf's left end")
	w.player.speed_upgrade_level = 1
	await exit_case("After Stride I: walk",Vector2(340,1198),[[0,KEY_A,true]])
	w.player.speed_upgrade_level = 1
	await exit_case("After Stride I: sprint",Vector2(340,1198),[[0,KEY_A,true],[1,KEY_A,false],[3,KEY_A,true]])
	w.player.speed_upgrade_level = 1
	await exit_case("After Stride I: sprint from the far side of the pad",Vector2(358,1198),[[0,KEY_A,true],[1,KEY_A,false],[3,KEY_A,true],[12,KEY_SHIFT,true],[13,KEY_SHIFT,false]])
	w.player.speed_upgrade_level = 0

# Hold toward a wall and chain wall jumps (jump held for the full arc). Returns min feet y.
func climb(label, start, toward, limit = 600, hall_limit = 100000.0):
	await place(start)
	var kt = KEY_A if toward < 0 else KEY_D
	key(kt,true)
	var release = 0;var nextjump = 0;var miny = start.y;var inside_mass = false
	var before = req()
	for t in limit:
		if (w.player.is_on_wall() or w.player.is_on_floor()) and not held_keys.get(KEY_SPACE,false) and t >= nextjump:
			key(KEY_SPACE,true);release = t + 25;nextjump = t + 30
		if held_keys.get(KEY_SPACE,false) and t >= release: key(KEY_SPACE,false)
		if t % 90 == 40 and w.player.dash_cooldown <= 0: key(KEY_SHIFT,true)
		if t % 90 == 41: key(KEY_SHIFT,false)
		await wait_ticks(1)
		if w.room != 13 or w.transition > 0: break
		if w.player.position.x <= hall_limit: miny = minf(miny,w.player.position.y)
		var body = Rect2(w.player.position - Vector2(13,60),Vector2(26,59))
		if body.intersects(Gatehouse.MASS) or body.intersects(Gatehouse.PIER): inside_mass = true
	for code in [kt,KEY_SPACE,KEY_SHIFT]: key(code,false)
	print("CLIMB ",label," start=",start," end=",w.player.position," room=",w.room," min_feet_y=",miny)
	return {"miny":miny,"room":w.room,"inside":inside_mass,"left":req() > before}

func containment():
	# The baseline reached y=-89 by wall-jumping the left wall at the old pad. Inside the
	# hallway the lintel must now stop every vertical attempt at head height.
	for start in [Vector2(86,1198),Vector2(100,1198),Vector2(184,1198),Vector2(282,1198)]:
		for toward in [-1,1]:
			# Only the time spent inside the hallway counts; heading right walks out into the room.
			var r = await climb("hall x=%d toward %d"%[start.x,toward],start,toward,360,282.0)
			# Allow the unavoidable exit; the question is height.
			check(r.miny >= 1080.0 - 1.5,"Hall attempt from %s toward %d never rises above the lintel (min feet y %.1f, limit 1080)"%[start,toward,r.miny])
			check(not r.inside,"Hall attempt from %s never clips into the mass"%[start])
	var r = await climb("shelf (200,1160) under the lintel",Vector2(240,1158),-1,360)
	check(r.miny >= 1080.0 - 1.5,"Wall jumps from the first shelf inside the hall are capped by the lintel (%.1f)"%r.miny)
	r = await climb("under-pad cavity",Vector2(14.5,1298),-1,240)
	check(r.miny >= 1250.0,"Cavity under the pad stays a dead end (min %.1f)"%r.miny)
	# Exterior face: honest measurement, informational about the residual route.
	var top_outs = []
	for start in [Vector2(330,1158),Vector2(400,1158),Vector2(520,1048)]:
		r = await climb("exterior face from %s"%start,start,-1,900)
		top_outs.append(r.miny)
		check(not r.inside,"Exterior face attempt never clips into the mass")
	print("RESIDUAL exterior face wall-climb min feet y (game-wide wall-jump rule): ",top_outs)

func leg_rect(step):
	return step

func landed_on(rect:Rect2) -> bool:
	var p = w.player.position
	return w.player.is_on_floor() and p.x >= rect.position.x - 8 and p.x <= rect.end.x + 8 and absf(p.y - rect.position.y) <= 3

func route_legs():
	# Same bot before and after: from each ordered route step, walk toward a point on the next step and
	# jump (full held jump) when the ballistic flight time covers the remaining distance.
	var steps = w.expansion.route_steps.duplicate()
	var ok = 0
	for i in steps.size() - 1:
		var a:Rect2 = steps[i];var b:Rect2 = steps[i + 1]
		await place(Vector2(a.get_center().x,a.position.y - 2))
		var target = clampf(a.get_center().x,b.position.x + 40,b.end.x - 40)
		var dir = 1 if target >= w.player.position.x else -1
		var kt = KEY_D if dir > 0 else KEY_A
		var dy = a.position.y - b.position.y
		var disc = 1.0 - 4.0 * dy / 900.0
		var flight = (1.0 + sqrt(maxf(disc,0.0))) / 2.0
		key(kt,true)
		var land = false;var jumped = false
		for t in 300:
			var remaining = (target - w.player.position.x) * dir
			if remaining < 0 and not jumped:
				key(kt,false);dir = -dir;kt = KEY_D if dir > 0 else KEY_A;key(kt,true)
			if not jumped and w.player.is_on_floor() and remaining <= 400.0 * flight * 0.92:
				key(KEY_SPACE,true);jumped = true
			if jumped and held_keys.get(KEY_SPACE,false) and w.player.velocity.y > 0: key(KEY_SPACE,false)
			await wait_ticks(1)
			if jumped and landed_on(b): land = true;break
			if jumped and w.player.is_on_floor() and not held_keys.get(KEY_SPACE,false) and t > 20: jumped = false
		key(kt,false);key(KEY_SPACE,false)
		print("LEG %02d %s -> %s reached=%s end=%s"%[i,a,b,land,w.player.position])
		if land: ok += 1
	print("ROUTE_LEGS_OK ",ok,"/",steps.size() - 1)
	return ok

func anchor_check():
	# Grapple anchor (900,690) from shelf (720,940): jump, hold Q in the rise, expect attachment.
	await place(Vector2(860,938))
	w.player.facing = 1
	key(KEY_D,true);key(KEY_SPACE,true)
	var attached = false
	for t in 40:
		await wait_ticks(1)
		if t >= 3 and not w.player.is_on_floor() and not attached:
			key(KEY_Q,true)
		attached = w.player.tether_attached
		if attached: break
	check(attached,"Grapple anchor (900,690) can still be tethered from shelf (720,940)")
	key(KEY_Q,false);key(KEY_D,false);key(KEY_SPACE,false)
	await wait_ticks(30)

func run():
	await process_frame
	output = "res://build/canal/native"
	DirAccess.make_dir_recursive_absolute(output)
	w = load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene = w;freeze();seed_fixture()
	automation_hud()
	print("CANAL engine=",Engine.get_version_info().string," driver=",RenderingServer.get_current_rendering_driver_name())
	await geometry_facts()
	await approaches()
	await round_trip()
	await stride_pickup()
	await containment()
	var legs = await route_legs()
	await anchor_check()
	w.queue_free();current_scene = null
	for i in 3: await process_frame
	print("CANAL: %d checks, %d failure(s), route legs ok %d"%[checks,failures,legs]);quit(1 if failures else 0)
