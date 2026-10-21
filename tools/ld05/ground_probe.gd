extends "res://tools/ld05/room_probe.gd"
## LD-05 ground-level reach probe (measurement only). Real InputEventKey input and real physics; the only state written
## is the start pose. For every room it builds a surface graph: from sample points on every standing surface it plays a
## battery of real-key moves (short hop, full jump, jump + double jump, jump + double jump + dash, walk off, grapple) in
## both directions and records which surface Kaze lands on, or where Kaze falls out of the room.
##   godot --headless --path . --fixed-fps 60 --script res://tools/ld05/ground_probe.gd -- --out=res://build/ld05/ground.json [--rooms=2,4]
## tools/ld05/ground_audit.py turns the JSON into the graph findings (unreachable, trapped, fall cost, recovery pose).
const SETTLE = 150
var variants = ["hop", "jump", "double", "dash", "walk", "run", "grapple"]

var gates_closed = false

func seed_fixture():
	super.seed_fixture()
	if gates_closed: w.opened_kunai_gates = {}

func surfaces(index):
	var size = w.room_size(index)
	var out = []
	var all = []
	for r in w.platforms: all.append(r)
	for r in w.boundary_rects:
		if r.position.y >= 0: all.append(r)
	for r in all:
		if r.position.x < 0 or r.position.x >= size.x: continue
		out.append(r)
	return out

func surface_at(index, pos:Vector2):
	# The surface whose top Kaze is standing on at pos (feet), or -1.
	var s = surfaces(index)
	for i in s.size():
		var r = s[i]
		if absf(r.position.y - pos.y) <= 3.0 and pos.x >= r.position.x - 6 and pos.x <= r.end.x + 6: return i
	return -1

func starts_for(r:Rect2, floorlike:bool):
	var xs = []
	if floorlike:
		var x = r.position.x + 16
		while x < r.end.x - 16:
			xs.append(x);x += 200.0
		xs.append(r.end.x - 16)
	else:
		xs = [r.position.x + 16, r.position.x + r.size.x * 0.5, r.end.x - 16]
	var out = []
	for x in xs: out.append(Vector2(clampf(x,r.position.x + 15,r.end.x - 15),r.position.y - 2))
	return out

func play(index, start:Vector2, dir:int, kind:String):
	await place(index,start)
	var size = w.room_size(index)
	var hp0 = w.player.hp
	var kt = KEY_A if dir < 0 else KEY_D
	key(kt,true)
	var fell = false;var fell_x = 0.0;var grounded_run = 0;var maxy = start.y;var miny = start.y
	var anchors = w.tether_anchors.duplicate()
	for n in w.get_tree().get_nodes_in_group("kaze_grapple_anchor"):
		if w.is_ancestor_of(n) and n.has_method("get_attachment_position"): anchors.append(n.get_attachment_position())
	for t in SETTLE + 80:
		match kind:
			"hop":
				if t == 0: key(KEY_SPACE,true)
				if t == 7: key(KEY_SPACE,false)
			"jump":
				if t == 0: key(KEY_SPACE,true)
				if t == 22: key(KEY_SPACE,false)
			"double", "dash":
				if t == 0: key(KEY_SPACE,true)
				if t == 22: key(KEY_SPACE,false)
				if t == 32: key(KEY_SPACE,true)
				if t == 54: key(KEY_SPACE,false)
				if kind == "dash" and t == 62: key(KEY_SHIFT,true)
				if kind == "dash" and t == 63: key(KEY_SHIFT,false)
			"run":
				# double tap to run, then a full jump + double jump + dash from the run
				if t == 0: key(kt,false)
				if t == 2: key(kt,true)
				if t == 5: key(kt,false)
				if t == 7: key(kt,true)
				if t == 24: key(KEY_SPACE,true)
				if t == 46: key(KEY_SPACE,false)
				if t == 56: key(KEY_SPACE,true)
				if t == 78: key(KEY_SPACE,false)
				if t == 86: key(KEY_SHIFT,true)
				if t == 87: key(KEY_SHIFT,false)
			"grapple":
				if t == 0: key(KEY_SPACE,true)
				if t == 14: key(KEY_SPACE,false)
				if t == 6: key(KEY_Q,true)
				if t == 90: key(KEY_SPACE,true)
				if t == 96: key(KEY_SPACE,false);key(KEY_SHIFT,true)
				if t == 97: key(KEY_SHIFT,false)
		await wait_ticks(1)
		if not still_here(index): break
		var p = w.player.position
		maxy = maxf(maxy,p.y);miny = minf(miny,p.y)
		if p.y > size.y + 20:
			fell = true;fell_x = p.x;break
		if p.x < -20 or p.x > size.x + 20: break
		var started = t > 4
		if started and w.player.is_on_floor() and not held_keys.get(KEY_SPACE,false):
			grounded_run += 1
			if grounded_run >= 6: break
		else:
			grounded_run = 0
	var end = w.player.position
	var landed = surface_at(index,end) if (not fell and w.player.is_on_floor()) else -1
	release_all()
	return {"kind":kind,"dir":dir,"start":[start.x,start.y],"end":[snappedf(end.x,0.1),snappedf(end.y,0.1)],"landed":landed,"fell":fell,"fell_x":snappedf(fell_x,0.1),"miny":snappedf(miny,0.1),"on_floor":w.player.is_on_floor()}

func recovery_pose(index):
	reset(index)
	var pos = w.left_exit_position() + Vector2(110,-2)
	var cap = Rect2(pos - Vector2(14,60),Vector2(28,60))
	var inside = false
	for r in w.platforms + w.boundary_rects:
		if r.intersects(cap): inside = true
	var support = -1
	var s = surfaces(index)
	for i in s.size():
		var r = s[i]
		if pos.x >= r.position.x and pos.x <= r.end.x and r.position.y >= pos.y - 2 and r.position.y <= pos.y + 90: support = i if (support < 0 or r.position.y < s[support].position.y) else support
	return {"pos":[pos.x,pos.y],"inside_solid":inside,"support":support,"support_gap":(s[support].position.y - pos.y) if support >= 0 else null}

func run():
	args()
	for a in OS.get_cmdline_user_args():
		if a == "--gates=closed": gates_closed = true
	await process_frame
	w = load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene = w;freeze();seed_fixture()
	automation_hud()
	DirAccess.make_dir_recursive_absolute(out_path.get_base_dir())
	var data = {"rooms":[]}
	for index in 21:
		if not only_rooms.is_empty() and not (index in only_rooms): continue
		reset(index)
		var size = w.room_size(index)
		var surf = surfaces(index)
		var srows = []
		for i in surf.size():
			var r = surf[i]
			srows.append({"i":i,"rect":[r.position.x,r.position.y,r.size.x,r.size.y]})
		var room = {"index":index,"name":w.ROOM_NAMES[index],"size":[size.x,size.y],"surfaces":srows,"edges":[],"recovery":recovery_pose(index)}
		room["endpoints"] = statics(index).endpoints
		room["anchors"] = statics(index).anchors
		reset(index)
		for i in surf.size():
			var r = surf[i]
			if r.position.y <= 8 or r.size.x < 20: continue
			var floorlike = r.size.x >= 800 and r.position.y >= size.y - 160
			for st in starts_for(r,floorlike):
				for dir in [-1,1]:
					for kind in variants:
						if kind == "grapple":
							var near = false
							for a in room.anchors:
								if absf(a[0] - st.x) < 420 and a[1] < st.y - 60: near = true
							if not near: continue
						var res = await play(index,st,dir,kind)
						res["from"] = i
						room.edges.append(res)
		data.rooms.append(room)
		print("GROUNDPROBE ",index," surfaces=",surf.size()," edges=",room.edges.size())
		var file = FileAccess.open(out_path,FileAccess.WRITE);file.store_string(JSON.stringify(data));file.close()
	w.queue_free();current_scene = null
	for i in 3: await process_frame
	quit(0)
