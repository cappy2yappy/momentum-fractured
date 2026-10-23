extends "res://tools/ld05/ground_probe.gd"
## Real InputEventKey / unchanged controller. Above y=0 is permitted; lateral escape is not.
var samples = []
var baseline = false

func reset(index):
	super.reset(index)
	# The legacy helper builds before seeding. Rebuild so closed gates really have colliders.
	w.build_room(index);freeze()

func lateral(pos: Vector2) -> bool:
	return pos.x < -20 or pos.x > 1820

func chain(index, start: Vector2, side: int, evade: bool):
	await place(index, start)
	var miny = w.player.position.y
	var escaped = false
	var saw_wall = false
	var phase = -1
	var jump_release = -1
	var next_jump = 0
	var lowest = w.player.position
	var outward = KEY_A if side < 0 else KEY_D
	var inward = KEY_D if side < 0 else KEY_A
	key(outward, true)
	for t in 1800:
		if phase < 0:
			if (w.player.is_on_wall() or w.player.is_on_floor()) and not held_keys.get(KEY_SPACE, false) and t >= next_jump:
				key(KEY_SPACE, true);jump_release = t + 25;next_jump = t + 30
			if held_keys.get(KEY_SPACE, false) and t >= jump_release: key(KEY_SPACE, false)
			if evade and w.player.is_on_ceiling():
				phase = t
				key(outward, false);key(inward, true);key(KEY_SPACE, false)
		else:
			# Attempt to round the cornice: reverse, dash out, double-jump, then return.
			var n = t - phase
			if n == 2: key(KEY_SHIFT, true)
			if n == 3: key(KEY_SHIFT, false)
			if n == 20: key(KEY_SPACE, true)
			if n == 45: key(KEY_SPACE, false);key(inward, false);key(outward, true)
			if n > 50 and (w.player.is_on_wall() or w.player.is_on_floor()) and not held_keys.get(KEY_SPACE,false) and t >= next_jump:
				key(KEY_SPACE,true);jump_release=t+25;next_jump=t+30
			if held_keys.get(KEY_SPACE,false) and t >= jump_release and n > 45: key(KEY_SPACE,false)
		await wait_ticks(1)
		if not still_here(index): break
		saw_wall = saw_wall or w.player.is_on_wall()
		if w.player.position.y < miny: miny = w.player.position.y;lowest = w.player.position
		if lateral(w.player.position): escaped = true;break
	release_all()
	var result = {"room":index,"kind":"cornice_evade" if evade else "wall_chain","start":[start.x,start.y],"dir":side,"miny":miny,"apex":[lowest.x,lowest.y],"escape":escaped,"wall_contact":saw_wall,"end":[w.player.position.x,w.player.position.y]}
	samples.append(result)
	return result

func run():
	baseline = "--ld08-before" in OS.get_cmdline_user_args()
	await process_frame
	w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w;freeze();seed_fixture();automation_hud()
	var fixtures=JSON.parse_string(FileAccess.get_file_as_string("res://tests/ld08/escape_cases.json"))
	var reproduced=0
	for closed in [false,true]:
		gates_closed=closed
		for e in fixtures:
			var r=await play(e.room,Vector2(e.start[0],e.start[1]),e.dir,e.kind)
			var escaped=lateral(Vector2(r.end[0],r.end[1]))
			r["room"]=e.room;r["gates_closed"]=closed;r["escape"]=escaped;samples.append(r)
			if escaped: reproduced+=1
			if not baseline: check(not escaped,"R%d historical %s from %s closed=%s stays inside: %s"%[e.room,e.kind,e.start,closed,r.end])
	if baseline: check(reproduced>=12,"Before: historical above-top lateral escapes reproduced (%d open+closed)"%reproduced)
	for closed in [false,true]:
		gates_closed=closed
		for spec in [[13,Vector2(314.6,438),-1],[13,Vector2(1785.4,558),1],[17,Vector2(14.6,1898),-1],[17,Vector2(1785.4,1298),1]]:
			for evade in [false,true]:
				var r=await chain(spec[0],spec[1],spec[2],evade)
				r["gates_closed"]=closed
				if not baseline: check(not r.escape and r.wall_contact,"R%d %s closed=%s retains wall jumps, no lateral escape; apex %s"%[spec[0],r.kind,closed,r.apex])
	# Exercise all actual object-based anchors (the old room probe looked only in the empty tether_anchors array).
	gates_closed=false
	for index in [13,17]:
		reset(index)
		var anchors=w.grapple_candidates().duplicate()
		for a in anchors:
			var starts=[]
			for r in w.platforms:
				if r.size.y==40 and r.position.y>a.y+60 and r.position.y<a.y+440:
					var x=clampf(a.x,r.position.x+24,r.end.x-24)
					if absf(x-a.x)<300: starts.append(Vector2(x,r.position.y-2))
			var attached=false
			for start in starts:
				for side in [-1,1]:
					var r=await grapple(index,a,start,side)
					attached=attached or r.attached
					r["room"]=index;r["kind"]="grapple";r["escape"]=lateral(w.player.position);samples.append(r)
					if not baseline: check(not r.escape,"R%d grapple/release/dash at %s direction %d stays inside"%[index,a,side])
			if not baseline: check(attached,"R%d anchor %s attaches via real Q input"%[index,a])
	var out="res://docs/ld08/evidence/traversal_%s.json"%("before" if baseline else ("after_native" if DisplayServer.get_name()!="headless" else "after"))
	var f=FileAccess.open(out,FileAccess.WRITE);f.store_string(JSON.stringify({"checks":checks,"failures":failures,"samples":samples},"  "));f.close()
	w.queue_free();current_scene=null
	for i in 3: await process_frame
	print("LD08 TRAVERSAL: %d checks, %d failure(s)"%[checks,failures]);quit(1 if failures else 0)
