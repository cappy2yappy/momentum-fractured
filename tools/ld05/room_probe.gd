extends "res://tests/audit_exit_alignment.gd"
## LD-05 room probe (report/measurement only, never edits game files, never writes player state during a probe
## except the fixture start pose). Real InputEventKey input and real physics.
##   godot --headless --path . --fixed-fps 60 --script res://tools/ld05/room_probe.gd -- --out=res://build/ld05/probe.json [--rooms=0,1,2]
## For every room it records static geometry (platforms, anchors, endpoints) and four probe families:
##   wall   : hold toward a side wall and chain held wall jumps from the floor and from each ledge near the wall
##   fly    : from ledges whose top is high enough, jump + double jump + dash toward the wall and the room top
##   grapple: from the ledge nearest below each high anchor, jump, press Q and swing toward each side
##   door   : support/trigger alignment of every endpoint (analyse() of tests/audit_exit_alignment.gd)
## A probe "escapes" when Kaze ends x outside the room, or climbs above feet y = ROOF_PROBE_Y (the room top edge).
const ROOF_PROBE_Y = -8.0
var out_path = "res://build/ld05/probe.json"
var only_rooms = []
var report = {"rooms":[]}

func args():
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="): out_path = a.substr(6)
		if a.begins_with("--rooms="):
			for s in a.substr(8).split(","): only_rooms.append(int(s))

func release_all():
	for code in [KEY_A,KEY_D,KEY_SPACE,KEY_SHIFT,KEY_E,KEY_Q]: key(code,false)

func place(index, pos:Vector2):
	release_all()
	reset(index)
	w.player.position = pos;w.player.velocity = Vector2.ZERO
	w.player.run = false;w.player.last_tap = -10;w.player.dash_cooldown = 0
	w.player.release_tether()
	live();await wait_ticks(4)

func still_here(index): return w.room == index and w.transition <= 0

# ---- wall chain ------------------------------------------------------------------------------
func wall_chain(index, start:Vector2, toward:int, max_ticks:int = 1500):
	await place(index,start)
	var size = w.room_size(index)
	var kt = KEY_A if toward < 0 else KEY_D
	key(kt,true)
	var release = 0;var nextjump = 0;var miny = w.player.position.y;var escaped = false;var maxx = w.player.position.x;var minx = maxx
	var top_tick = -1
	for t in max_ticks:
		if (w.player.is_on_wall() or w.player.is_on_floor()) and not held_keys.get(KEY_SPACE,false) and t >= nextjump:
			key(KEY_SPACE,true);release = t + 25;nextjump = t + 30
		if held_keys.get(KEY_SPACE,false) and t >= release: key(KEY_SPACE,false)
		await wait_ticks(1)
		if not still_here(index): break
		var p = w.player.position
		miny = minf(miny,p.y);minx = minf(minx,p.x);maxx = maxf(maxx,p.x)
		if p.x < -20 or p.x > size.x + 20 or p.y < ROOF_PROBE_Y - 150:
			escaped = true;break
		if miny < ROOF_PROBE_Y and top_tick < 0: top_tick = t
		# Stalled under something: no progress for 3 s while on wall or floor.
		if t > 240 and t % 180 == 0 and absf(p.y - start.y) < 4: break
	release_all()
	var end = w.player.position
	return {"start":[start.x,start.y],"toward":toward,"min_feet_y":snappedf(miny,0.1),"escaped":escaped,
		"above_room_top":miny < ROOF_PROBE_Y,"left_room_x":minx < -20 or maxx > size.x + 20,"end":[snappedf(end.x,0.1),snappedf(end.y,0.1)],"ticks_to_top":top_tick}

# ---- free flight -------------------------------------------------------------------------------
func fly(index, start:Vector2, toward:int):
	await place(index,start)
	var size = w.room_size(index)
	var kt = KEY_A if toward < 0 else KEY_D
	key(kt,true)
	var miny = start.y;var escaped = false
	# jump, double jump near apex, dash, repeat once
	key(KEY_SPACE,true);await wait_ticks(22);key(KEY_SPACE,false)
	await wait_ticks(10)
	key(KEY_SPACE,true);await wait_ticks(22);key(KEY_SPACE,false)
	for step in 3:
		await wait_ticks(8)
		if step == 0: key(KEY_SHIFT,true);await wait_ticks(1);key(KEY_SHIFT,false)
		miny = minf(miny,w.player.position.y)
	for t in 160:
		await wait_ticks(1)
		if not still_here(index): break
		var p = w.player.position
		miny = minf(miny,p.y)
		if p.x < -20 or p.x > size.x + 20: escaped = true;break
	release_all()
	return {"start":[start.x,start.y],"toward":toward,"min_feet_y":snappedf(miny,0.1),"escaped":escaped or miny < ROOF_PROBE_Y - 40,"end":[snappedf(w.player.position.x,0.1),snappedf(w.player.position.y,0.1)]}

# ---- grapple -----------------------------------------------------------------------------------
func grapple(index, anchor:Vector2, start:Vector2, toward:int):
	await place(index,start)
	var size = w.room_size(index)
	var kt = KEY_A if toward < 0 else KEY_D
	key(KEY_SPACE,true);await wait_ticks(14);key(KEY_SPACE,false)
	key(kt,true)
	var miny = start.y;var attached = false;var escaped = false
	for t in 150:
		if t == 6: key(KEY_Q,true)
		await wait_ticks(1)
		if not still_here(index): break
		attached = attached or w.player.tether_attached
		var p = w.player.position
		miny = minf(miny,p.y)
		if t == 90: key(KEY_SPACE,true)
		if t == 96: key(KEY_SPACE,false);key(KEY_SHIFT,true)
		if t == 97: key(KEY_SHIFT,false)
		if p.x < -20 or p.x > size.x + 20: escaped = true;break
	release_all()
	return {"anchor":[anchor.x,anchor.y],"start":[start.x,start.y],"toward":toward,"attached":attached,"min_feet_y":snappedf(miny,0.1),"escaped":escaped or miny < ROOF_PROBE_Y}

# ---- static --------------------------------------------------------------------------------------
func statics(index):
	var size = w.room_size(index)
	var plats = []
	for r in w.platforms:
		var boundary = r.position.x < 0 or r.position.x >= size.x
		plats.append({"rect":[r.position.x,r.position.y,r.size.x,r.size.y],"boundary":boundary,"one_way":(index >= 13 and r.size.y == 40 and r.position.x >= 0)})
	var gates = []
	for g in w.kunai_gates: gates.append({"id":g.id,"element":g.element,"at":[g.position.x,g.position.y],"height":g.height})
	var anchors = []
	for a in w.tether_anchors: anchors.append([a.x,a.y])
	for n in w.get_tree().get_nodes_in_group("kaze_grapple_anchor"):
		if w.is_ancestor_of(n) and n.has_method("get_attachment_position"): anchors.append([n.get_attachment_position().x,n.get_attachment_position().y])
	var eps = []
	for p in w.cinematic_transitions.endpoints(w,index):
		eps.append({"target":p.target,"at":[p.at.x,p.at.y],"mode":p.mode,"heading":int(p.heading)})
	var enemies = []
	for e in w.enemies:
		if is_instance_valid(e): enemies.append([e.position.x,e.position.y])
	return {"index":index,"size":[size.x,size.y],"name":w.ROOM_NAMES[index],"platforms":plats,"gates":gates,"anchors":anchors,"endpoints":eps,"enemies":enemies}

func standing_tops_near_wall(index, side:int, reach:float):
	# Distinct ledge tops that touch or sit within `reach` px of the wall (start poses for ledge probes).
	var size = w.room_size(index)
	var tops = []
	for r in w.platforms:
		if r.position.x < 0 or r.position.x >= size.x: continue
		if r.size.y > 400: continue
		var near = r.position.x <= reach if side < 0 else r.end.x >= size.x - reach
		if not near: continue
		if r.position.y > size.y - 150: continue
		var x = clampf(14.6 if side < 0 else size.x - 14.6,r.position.x + 14.6,r.end.x - 14.6) if (r.position.x <= 1 if side < 0 else r.end.x >= size.x - 1) else (r.position.x + 20 if side < 0 else r.end.x - 20)
		tops.append(Vector2(x,r.position.y - 2))
	return tops

func run():
	args()
	await process_frame
	w = load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene = w;freeze();seed_fixture()
	automation_hud()
	DirAccess.make_dir_recursive_absolute(out_path.get_base_dir())
	for index in 21:
		if not only_rooms.is_empty() and not (index in only_rooms): continue
		reset(index)
		var room = statics(index)
		var size = w.room_size(index)
		room["wall"] = []
		for side in [-1,1]:
			var floor_start = Vector2(14.6 if side < 0 else size.x - 14.6,size.y - 142)
			var r = await wall_chain(index,floor_start,side)
			r["origin"] = "floor";r["side"] = side
			room.wall.append(r)
			for t in standing_tops_near_wall(index,side,200.0):
				var rr = await wall_chain(index,t,side,900)
				rr["origin"] = "ledge";rr["side"] = side
				room.wall.append(rr)
		# interior tall faces (the Canal gatehouse mass): chain from the floor and from each ledge that touches the face
		room["face"] = []
		for r in w.platforms:
			if r.position.x < 0 or r.position.x >= size.x or r.size.y < 300: continue
			if r.end.y >= size.y - 200: continue # floor segments are not faces
			var fx = r.end.x + 14.6
			var starts = [Vector2(fx,size.y - 142)]
			for q in w.platforms:
				if q.position.x < 0 or q.position.x >= size.x or q.size.y > 400 or q.position.y > size.y - 200 or q.position.y < r.position.y: continue
				if fx >= q.position.x - 4 and fx <= q.end.x - 14.6: starts.append(Vector2(maxf(fx,q.position.x + 14.6),q.position.y - 2))
			for st in starts:
				var rr = await wall_chain(index,st,-1,900)
				rr["face_rect"] = [r.position.x,r.position.y,r.size.x,r.size.y]
				room.face.append(rr)
		room["fly"] = []
		for side in [-1,1]:
			for r in w.platforms:
				if r.position.x < 0 or r.position.x >= size.x or r.size.y > 400: continue
				if r.position.y > 560: continue
				var near = r.position.x <= 520 if side < 0 else r.end.x >= size.x - 520
				if not near: continue
				var x = clampf(r.position.x + 24 if side < 0 else r.end.x - 24,r.position.x + 14.6,r.end.x - 14.6)
				var f = await fly(index,Vector2(x,r.position.y - 2),side)
				f["side"] = side
				room.fly.append(f)
		room["grapple"] = []
		reset(index)
		for a in w.tether_anchors:
			if a.y > 560: continue
			# nearest ledge below the anchor within 300 px horizontally
			var best = null;var bd = 1e9
			for r in w.platforms:
				if r.position.x < 0 or r.position.x >= size.x or r.size.y > 400 or r.position.y < a.y + 60: continue
				var cx = clampf(a.x,r.position.x + 14.6,r.end.x - 14.6)
				var d = absf(cx - a.x) + (r.position.y - a.y) * 0.5
				if d < bd: bd = d;best = Vector2(cx,r.position.y - 2)
			if best == null: continue
			for side in [-1,1]:
				var g = await grapple(index,a,best,side)
				g["side"] = side
				room.grapple.append(g)
		reset(index)
		room["door"] = []
		for p in w.cinematic_transitions.endpoints(w,index):
			var row = analyse(index,p)
			room.door.append(row)
		report.rooms.append(room)
		print("ROOMPROBE ",index," wall=",room.wall.size()," fly=",room.fly.size()," grapple=",room.grapple.size())
	var file = FileAccess.open(out_path,FileAccess.WRITE);file.store_string(JSON.stringify(report,"  "));file.close()
	w.queue_free();current_scene = null
	for i in 3: await process_frame
	quit(0)
