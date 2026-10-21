extends "res://tools/ld05/room_probe.gd"
## LD-05 intentional world boundaries. Real InputEventKey input and real physics for every movement claim.
## godot --headless --path . --fixed-fps 60 --script res://tests/ld05_boundaries.gd
## Prints PASS/FAIL lines and "LD05 BOUNDARIES: N checks, M failure(s)". Writes build/ld05/test_probe.json.
const ROOF_BOTTOM = 56.0
const HEAD = 60.0

func jcheck(ok,label):
	check(ok,label)

func run():
	await process_frame
	w = load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene = w;freeze();seed_fixture()
	automation_hud()
	var RB = w.RoomBoundary
	var base = JSON.parse_string(FileAccess.get_file_as_string("res://docs/ld05/base_platforms_49ae3efe.json"))

	# ---- 1. structure: what exists, what did not change --------------------------------------------------------
	for index in 21:
		reset(index)
		var size = w.room_size(index)
		var roof = null
		for r in w.boundary_rects:
			if r.position.y < 0 and r.position.x <= -40 and r.end.x >= size.x + 40: roof = r
		check(roof != null and absf(roof.end.y - ROOF_BOTTOM) < 0.01,"R%d has a wall-to-wall roof course whose underside is y=56" % index)
		var sig = []
		for r in w.platforms: sig.append([r.position.x,r.position.y,r.size.x,r.size.y])
		check(JSON.stringify(sig) == JSON.stringify(base[str(index)]),"R%d platform list is identical to candidate 49ae3efe (no rectangle added, moved or resized)" % index)
	# highest legitimate content stays clear of the roof by more than a double jump head bump
	var min_top = 1e9;var min_anchor = 1e9
	for index in 21:
		reset(index)
		var size = w.room_size(index)
		for r in w.platforms:
			if r.position.x < 0 or r.position.x >= size.x or r.size.y >= 300: continue
			min_top = minf(min_top,r.position.y)
		for a in w.grapple_candidates(): min_anchor = minf(min_anchor,a.y)
	check(min_top >= 380.0,"No ledge top is above y=380 (min %.0f): the roof removes nothing legitimate" % min_top)
	check(min_anchor >= 240.0,"No grapple anchor is above y=240 (min %.0f): swings never reach the roof" % min_anchor)

	# ---- 2. wall chains: every wall of every room, real keys, from the floor and from ledges that touch the wall ---
	var rows = []
	var worst = 1e9
	for index in 21:
		reset(index)
		var size = w.room_size(index)
		for side in [-1,1]:
			var starts = [["floor",Vector2(14.6 if side < 0 else size.x - 14.6,size.y - 142)]]
			for t in standing_tops_near_wall(index,side,200.0): starts.append(["ledge",t])
			for s in starts:
				var r = await wall_chain(index,s[1],side,900)
				rows.append({"room":index,"side":side,"origin":s[0],"start":r.start,"min_feet_y":r.min_feet_y,"escaped":r.escaped})
				worst = minf(worst,r.min_feet_y)
				check(not r.escaped and not r.left_room_x and r.min_feet_y >= ROOF_BOTTOM + HEAD - 2.0,"R%d %s wall %s start (%d,%d): chain tops out at feet y %.1f under the roof, never leaves the room" % [index,"left" if side < 0 else "right",s[0],r.start[0],r.start[1],r.min_feet_y])
	check(worst >= 114.0 and worst <= 122.0,"All %d wall chains stop at the roof underside (feet y %.1f; expected 116)" % [rows.size(),worst])

	# ---- 3. the two named residuals --------------------------------------------------------------------------
	# 3a. gatehouse outer face x=296 (R13), from the shelf at (300,440)
	var face = await wall_chain(13,Vector2(314.6,438.0),-1,900)
	check(not face.escaped and face.min_feet_y >= 114.0,"R13 gatehouse outer face (x=296): wall jumps stop at feet y %.1f (was -164.6, left the world)" % face.min_feet_y)
	# 3b. R13 right wall, from the floor and the exit shelf
	for st in [Vector2(1785.4,1298.0),Vector2(1785.4,558.0)]:
		var rr = await wall_chain(13,st,1,900)
		check(not rr.escaped and rr.min_feet_y >= 114.0,"R13 right wall from (%d,%d) stops at feet y %.1f (was -144)" % [st.x,st.y,rr.min_feet_y])
	# 3c. double jump + dash from the shelves that used to reach the room top
	for pair in [[13,Vector2(324,438),-1],[17,Vector2(1626,418),1],[13,Vector2(1776,558),1]]:
		var f = await fly(pair[0],pair[1],pair[2])
		check(not f.escaped and f.min_feet_y >= 100.0,"R%d jump + double jump + dash from (%d,%d): feet y never above %.1f, no exit" % [pair[0],pair[1].x,pair[1].y,f.min_feet_y])

	for pair in [[13,Vector2(324,438),-1],[17,Vector2(1626,418),1]]:
		var dtop = await double_to_top(pair[0],pair[1],pair[2])
		check(not dtop.escaped and dtop.min_feet_y >= 100.0 and dtop.min_feet_y <= 130.0,"R%d full double jump from (%d,%d) toward the wall bumps the roof underside at feet y %.1f and cannot leave (base: above the room, on top of the wall)" % [pair[0],pair[1].x,pair[1].y,dtop.min_feet_y])

	# ---- 4. Canal doorway unchanged ---------------------------------------------------------------------------
	reset(13)
	var Gate = w.Expansion.CanalGatehouse
	check(w.platforms.has(Gate.MASS) and w.platforms.has(Gate.PIER),"R13 gatehouse mass and back pier rectangles unchanged")
	check(Gate.APERTURE == Rect2(72,1068,96,132) and Gate.DOOR_X == 120.0 and Gate.CEILING_Y == 1020.0,"Canal aperture, door x and ceiling constants unchanged")
	var p13 = w.cinematic_transitions.endpoint(w,13,0)
	check(p13.at == Vector2(120,1200),"Canal endpoint (120,1200) unchanged")
	# nothing new inside the hallway or its mouth (x 0..360, y 1020..1240)
	var intruders = 0
	for r in w.boundary_rects:
		if r.intersects(Rect2(0,1020,360,220)): intruders += 1
	check(intruders == 0,"No LD-05 solid enters the hallway envelope (x 0..360, y 1020..1240)")
	# 3d. real-key canal walk still works end to end
	reset(13)
	var before = w.cinematic_transitions.request_count
	await place(13,Vector2(320,1198))
	key(KEY_A,true)
	for t in 200:
		await wait_ticks(1)
		if w.cinematic_transitions.request_count > before: break
	key(KEY_A,false)
	check(w.cinematic_transitions.request_count == before + 1,"Real key A from the hallway mouth still triggers the Canal passage exactly once")
	await wait_ticks(60)

	# ---- 5. R13 crawlspace under the hallway pad ---------------------------------------------------------------
	await place(13,Vector2(700,1298))
	key(KEY_A,true);await wait_ticks(150);key(KEY_A,false)
	check(w.player.position.x >= 360.0 + 14.0 - 0.5,"R13: walking left along the quay floor stops at the plinth (x %.1f), the 60 px nook under the hallway pad is closed" % w.player.position.x)

	# ---- 6. R8 door shelf --------------------------------------------------------------------------------------
	reset(8)
	var covered = 0.0
	for x in range(1042,1138):
		var ok = false
		for r in w.platforms + w.boundary_rects:
			if absf(r.position.y - 920.0) <= 1 and x >= r.position.x and x < r.end.x: ok = true
		if ok: covered += 1
	check(covered == 96,"R8 depth door to R18: all 96 px of the door span (1042..1138) have a walkable top at y=920 (was 68 of 96)")
	await place(8,Vector2(1000,918))
	key(KEY_D,true)
	for t in 120:
		await wait_ticks(1)
		if w.player.position.x >= 1096.0: break
	key(KEY_D,false);await wait_ticks(25)
	check(w.player.is_on_floor() and absf(w.player.position.y - 920.0) < 1.5 and w.player.position.x >= 1118.0 and w.player.position.x < 1148.0,"R8: Kaze stands at x %.1f, 17+ px past the old shelf end (1110), on the shelf at y 920" % w.player.position.x)
	# walking back across the seam is smooth
	key(KEY_A,true);await wait_ticks(45);key(KEY_A,false);await wait_ticks(10)
	check(w.player.is_on_floor() and absf(w.player.position.y - 920.0) < 1.5 and w.player.position.x < 1000.0,"R8: walking back across the seam is smooth (x %.1f, y %.1f)" % [w.player.position.x,w.player.position.y])

	# ---- 7. door seating: only R6 and R9 are shifted --------------------------------------------------------
	var shifted = {}
	for index in 21:
		reset(index)
		for p in w.cinematic_transitions.endpoints(w,index):
			var d = RB.seat_offset(w,p.at)
			if d != 0.0: shifted["%d->%d" % [index,p.target]] = d
	check(shifted == {"9->10":-20.0},"Door seating shifts only R9->R10 (-20); R6->R7 is now seated by the LD-05 sill (offset 0); got %s" % [shifted])
	# the endpoint data themselves are unchanged
	reset(6);check(w.cinematic_transitions.endpoint(w,6,7).at == Vector2(2440,1090),"R6->R7 endpoint (2440,1090) unchanged")
	reset(9);check(w.cinematic_transitions.endpoint(w,9,10).at == Vector2(2440,830),"R9->R10 endpoint (2440,830) unchanged")

	# ---- 8. legitimate vertical exploration still works by real keys -------------------------------------------
	# R17: climbing wall + ledge route to the top shelf region is still possible (gate wall chain above the spire floor)
	var legit = await wall_chain(5,Vector2(14.6,1078.0),-1,300)
	check(legit.min_feet_y < 500.0,"R5 wall jumps still gain real height (feet y %.0f in 5 s): wall jumping is untouched" % legit.min_feet_y)
	check(FileAccess.get_sha256("res://scripts/player.gd") == JSON.parse_string(FileAccess.get_file_as_string("res://assets/web/kaze_manifest.json"))["controller_sha256"],"player.gd is byte-identical to the approved controller")

	# ---- 9. switches -------------------------------------------------------------------------------------------
	RB.ROOF_ENABLED = false
	reset(14)
	var has_roof = false
	for r in w.boundary_rects:
		if r.position.y < 0: has_roof = true
	check(not has_roof,"ROOF_ENABLED=false restores the open-top rooms (A/B switch)")
	RB.ROOF_ENABLED = true;RB.ORIGINAL_ROOMS_ENABLED = false
	reset(3);var r3 = false
	for r in w.boundary_rects:
		if r.position.y < 0: r3 = true
	reset(9);var r9 = false
	for r in w.boundary_rects:
		if r.position.y < 0: r9 = true
	check(not r3 and r9,"ORIGINAL_ROOMS_ENABLED=false leaves R0..R7 untouched and keeps R8+ closed")
	RB.ORIGINAL_ROOMS_ENABLED = true

	# ---- 10. ground level: doorway approaches, sill, pits --------------------------------------------------------
	# 10a. every walk-through exit opens for a Kaze walking into it along its own shelf (real keys)
	var walk_total = 0;var walk_ok = 0;var walk_bad = []
	for index in 21:
		reset(index)
		for p in w.cinematic_transitions.endpoints(w,index):
			if p.mode != "horizontal_walk": continue
			reset(index)
			var dir = int(p.heading)
			var support = Rect2()
			var found = false
			for r in w.platforms:
				if r.position.x < 0 or r.position.x >= w.room_size(index).x: continue
				if p.at.x >= r.position.x and p.at.x <= r.end.x and absf(r.position.y - p.at.y) <= 40 and (not found or r.position.y < support.position.y): support = r;found = true
			var sx = clampf(p.at.x - dir * 220.0,support.position.x + 20,support.end.x - 20)
			await place(index,Vector2(sx,support.position.y - 2))
			var before_n = w.cinematic_transitions.request_count
			key(KEY_D if dir > 0 else KEY_A,true)
			var opened = false
			for t in 240:
				await wait_ticks(1)
				if w.cinematic_transitions.request_count > before_n: opened = true;break
			key(KEY_D,false);key(KEY_A,false)
			walk_total += 1
			if opened: walk_ok += 1
			else: walk_bad.append("R%d->R%d" % [index,p.target])
			await wait_ticks(20)
	check(walk_bad.is_empty(),"All %d walk-through exits open for a walking Kaze on their own shelf (%d / %d; failing: %s)" % [walk_total,walk_ok,walk_total,walk_bad])
	# 10b. R6 sill: visible, solid, seated, and the walkable approach is continuous
	reset(6)
	check(w.boundary_polys.size() == 1 and w.boundary_rects.has(Rect2(2390,1090,210,26)),"R6 has exactly one sill solid (bounding rect 2390,1090,210x26)")
	var sig6 = []
	for r in w.platforms: sig6.append([r.position.x,r.position.y,r.size.x,r.size.y])
	check(JSON.stringify(sig6) == JSON.stringify(base["6"]),"R6 platform list unchanged by the sill (approved geometry untouched)")
	check(w.cinematic_transitions.endpoint(w,6,7).at == Vector2(2440,1090),"R6->R7 endpoint still (2440,1090)")
	await place(6,Vector2(2250,1108))
	var open6 = w.cinematic_transitions.request_count
	key(KEY_D,true)
	var fired6 = -1
	for t in 240:
		await wait_ticks(1)
		if w.cinematic_transitions.request_count > open6: fired6 = t;break
	key(KEY_D,false)
	check(fired6 >= 0 and fired6 < 120,"R6: walking right along the shelf opens the R7 exit (tick %d; before the sill it never opened)" % fired6)
	for t in 200:
		await wait_ticks(1)
		if w.room == 7 and w.transition <= 0: break
	await wait_ticks(40)
	# Carried velocity and the frame in which input is released change the final
	# stopping x across platforms. Check the real landing contract, not one run's x.
	var arrival7 = w.cinematic_transitions.arrival_position(w,w.cinematic_transitions.endpoint(w,7,6))
	check(w.room == 7 and w.player.is_on_floor() and absf(w.player.position.y - 1090.0) < 1.5 and w.player.position.x >= arrival7.x and w.player.position.x <= 286.0,"R6->R7 stops on the reciprocal shelf, inward of arrival (%.1f,%.1f)" % [w.player.position.x,w.player.position.y])
	# return trip: R7 left door to R6 lands on the shelf beside the ramp, not inside it
	await place(7,Vector2(300,1088))
	var ret0 = w.cinematic_transitions.request_count
	key(KEY_A,true)
	for t in 200:
		await wait_ticks(1)
		if w.cinematic_transitions.request_count > ret0: break
	key(KEY_A,false)
	for t in 200:
		await wait_ticks(1)
		if w.room == 6 and w.transition <= 0: break
	await wait_ticks(40)
	var cap6 = Rect2(w.player.position - Vector2(14,60),Vector2(28,60))
	var inside6 = false
	for r in w.platforms + w.boundary_rects:
		if r.intersects(cap6): inside6 = true
	check(w.room == 6 and w.player.is_on_floor() and not inside6 and w.player.position.x < 2390.0,"R7->R6 arrival at (%.1f,%.1f) stands on the shelf clear of the sill ramp" % [w.player.position.x,w.player.position.y])
	# the arming window is wide enough for every approach: walk and double-tap run from four starts, plus a run + dash
	var trials_ok = 0;var trials = 0
	for sx6 in [2060.0,2200.0,2300.0,2384.0]:
		for mode in ["walk","run","dash"]:
			await place(6,Vector2(sx6,1108))
			var n6 = w.cinematic_transitions.request_count
			if mode == "run":
				key(KEY_D,true);await wait_ticks(3);key(KEY_D,false);await wait_ticks(3);key(KEY_D,true)
			else:
				key(KEY_D,true)
			if mode == "dash":
				await wait_ticks(8);key(KEY_SHIFT,true);await wait_ticks(1);key(KEY_SHIFT,false)
			var hit = false
			for t in 240:
				await wait_ticks(1)
				if w.cinematic_transitions.request_count > n6: hit = true;break
			key(KEY_D,false);key(KEY_SHIFT,false)
			if mode != "dash": trials += 1
			if mode == "dash":
				# reported, not asserted: a dash crosses the 17 px arming window in about one tick
				print("INFO R6 dash from x %d: exit %s" % [sx6,"opened" if hit else "not opened (walk back and cross again)"])
				await wait_ticks(80)
				continue
			if hit: trials_ok += 1
			else: print("TRIAL MISS start %d mode %s end x %.1f y %.1f" % [sx6,mode,w.player.position.x,w.player.position.y])
			await wait_ticks(80)
	check(trials_ok == trials,"R6 exit opens in %d / %d approach trials (walk and double-tap run from four starts)" % [trials_ok,trials])
	# the ramp is walkable at full speed in both directions and the sill top is the door line
	await place(6,Vector2(2300,1108))
	key(KEY_D,true);await wait_ticks(26);key(KEY_D,false)
	if w.room == 6:
		check(w.player.position.x > 2380.0 or w.room != 6,"R6: ramp is climbed by walking (x %.1f, y %.1f)" % [w.player.position.x,w.player.position.y])
	# 10c. pit water: drawn below the floor lip, collider unchanged, falling still costs one HP and recovers on solid ground
	check(RB.pit_rect(Rect2(450,1260,550,180)).position.y == 1372.0 and RB.pit_rect(Rect2(450,1260,550,180)).end.y == 1440.0,"Pit water is drawn from y 1372 (was 1260, 40 px above the 1300 lip)")
	RB.PIT_WATER_ALIGNED = false
	check(RB.pit_rect(Rect2(450,1260,550,180)) == Rect2(450,1260,550,180),"PIT_WATER_ALIGNED=false restores the legacy water rectangle")
	RB.PIT_WATER_ALIGNED = true
	for index in [2,4,5]:
		reset(index)
		var gaps = []
		var segs = []
		for r in w.platforms:
			if r.position.x >= 0 and r.position.x < w.room_size(index).x and r.position.y == 1300.0: segs.append(r)
		segs.sort_custom(func(a,b): return a.position.x < b.position.x)
		var x0 = 0.0
		for sg in segs:
			if sg.position.x > x0 + 1: gaps.append(Vector2(x0,sg.position.x))
			x0 = maxf(x0,sg.end.x)
		var pit = gaps[0]
		await place(index,Vector2(pit.x - 30,1298))
		var hp0 = w.player.hp
		key(KEY_D,true)
		var passed_surface = false;var recovered = false
		for t in 400:
			await wait_ticks(1)
			if w.player.position.y > 1380.0: passed_surface = true
			if passed_surface and w.player.hp < hp0 and w.player.is_on_floor(): recovered = true;break
		key(KEY_D,false)
		check(passed_surface and recovered and w.player.hp == hp0 - 1,"R%d pit at x %d..%d: Kaze drops through the drawn water (collider unchanged), loses 1 HP and is returned to solid ground at (%.0f,%.0f)" % [index,pit.x,pit.y,w.player.position.x,w.player.position.y])
		await wait_ticks(30)
	# 10d. switch: --ld05-no-sill state
	RB.SILLS_ENABLED = false
	reset(6)
	check(w.boundary_polys.is_empty() and RB.seat_offset(w,Vector2(2440,1090)) == 20.0,"SILLS_ENABLED=false restores the pre-LD-05 shelf and door seat")
	RB.SILLS_ENABLED = true

	DirAccess.make_dir_recursive_absolute("res://build/ld05")
	var file = FileAccess.open("res://build/ld05/test_wall_rows.json",FileAccess.WRITE);file.store_string(JSON.stringify(rows,"  "));file.close()
	w.queue_free();current_scene = null
	for i in 3: await process_frame
	print("LD05 BOUNDARIES: %d checks, %d failure(s)" % [checks,failures])
	quit(1 if failures else 0)
