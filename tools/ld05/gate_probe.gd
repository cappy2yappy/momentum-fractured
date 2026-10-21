extends "res://tools/ld05/room_probe.gd"
## LD-05 gate bypass probe: can Kaze get past a closed kunai gate by real input (wall jump / jump / double jump / dash)?
## godot --headless --path . --fixed-fps 60 --script res://tools/ld05/gate_probe.gd -- --out=res://build/ld05/gates.json
func bypass(index, gate, side:int, double_jump:bool, mode:String):
	w.opened_kunai_gates = {}
	var sx = gate.position.x - side * 70.0
	var support = false
	for r in w.platforms:
		if r.position.x >= 0 and r.position.x < w.room_size(index).x and absf(r.position.y - gate.position.y) <= 2 and gate.position.x >= r.position.x and gate.position.x <= r.end.x:
			support = true;sx = clampf(sx,r.position.x + 16,r.end.x - 16)
	await place(index,Vector2(sx,gate.position.y - 2))
	if not w.kunai_gates.is_empty():
		w.opened_kunai_gates = {}
	w.player.double_jump = double_jump
	var kt = KEY_D if side > 0 else KEY_A
	key(kt,true)
	var start_x = w.player.position.x
	var passed = false;var miny = w.player.position.y
	var release = 0;var nextjump = 0
	for t in 700:
		if mode == "chain":
			if (w.player.is_on_wall() or w.player.is_on_floor()) and not held_keys.get(KEY_SPACE,false) and t >= nextjump:
				key(KEY_SPACE,true);release = t + 25;nextjump = t + 30
			if held_keys.get(KEY_SPACE,false) and t >= release: key(KEY_SPACE,false)
		elif mode == "double":
			if t == 20: key(KEY_SPACE,true)
			if t == 40: key(KEY_SPACE,false)
			if t == 52: key(KEY_SPACE,true)
			if t == 72: key(KEY_SPACE,false);key(KEY_SHIFT,true)
			if t == 73: key(KEY_SHIFT,false)
		await wait_ticks(1)
		if not still_here(index): break
		miny = minf(miny,w.player.position.y)
		if (w.player.position.x - gate.position.x) * side > 30: passed = true;break
	release_all()
	return {"room":index,"gate":gate.id,"at":[gate.position.x,gate.position.y],"height":gate.height,"side":side,"mode":mode,"double_jump":double_jump,"passed":passed,"supported_start":support,"min_feet_y":snappedf(miny,0.1),"end":[snappedf(w.player.position.x,0.1),snappedf(w.player.position.y,0.1)]}

func run():
	args()
	await process_frame
	w = load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene = w;freeze();seed_fixture()
	automation_hud()
	var rows = []
	for index in 21:
		w.opened_kunai_gates = {}
		reset(index)
		var gates = w.kunai_gates.duplicate()
		for g in gates:
			if g.body == null: continue
			for mode in ["chain","double"]:
				for dj in [false,true]:
					if mode == "double" and not dj: continue
					rows.append(await bypass(index,g,1,dj,mode))
					reset(index)
	DirAccess.make_dir_recursive_absolute(out_path.get_base_dir())
	var file = FileAccess.open(out_path,FileAccess.WRITE);file.store_string(JSON.stringify(rows,"  "));file.close()
	for r in rows: print("GATE R",r.room," ",r.gate," h=",r.height," ",r.mode," dj=",r.double_jump," passed=",r.passed," miny=",r.min_feet_y)
	w.queue_free();current_scene = null
	for i in 3: await process_frame
	quit(0)
