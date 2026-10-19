extends RefCounted
## QA-owned. Wave 3 world-boundary probes with REAL key input only (no position or velocity writes after the start pose).
## For every room and every authored endpoint it starts Kaze just inside the endpoint and runs scripted jump, hold-jump,
## wall-jump chain and dash patterns in both directions, with the full kit and the base kit. It records which 64 px cells
## Kaze occupied/stood in, whether she ever left the room rectangle, which other endpoints she reached, and writes
## w3_reach_<label>.json. Ground truth for comparison: tools/pm_pilot_qa/hooks/w3_reach_truth_<control>.json produced by this
## same hook on PR51 (baedd678) and candidate 49ae3efe.
##   * ESCAPE check: no probe may leave the room rectangle (x -16..W+16, y above -40) or enter space outside the world.
##   * ROUTES check: an endpoint pair reached in the control must still be reached (else a legitimate route may be lost).
## Lost non-critical cells are printed for review (Level removes unintended areas on purpose); they never pass silently.
var q
var w
var c
const CELL=64.0
var rooms_filter=[]
var label="run"
var quick=false

func args():
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--qa-reach-rooms="): rooms_filter=Array(a.substr(17).split(",")).map(func(s): return int(s))
		if a.begins_with("--qa-reach-label="): label=a.substr(17)
		if a=="--qa-reach-quick": quick=true

func cell(p): return "%d,%d"%[int(floor(p.x/CELL)),int(floor(p.y/CELL))]

func probe(room,start,key_dir,pattern,kit,ticks,eps):
	q.release_all()
	q.reset(room)
	if kit=="base": q.strip_abilities()
	w.player.position=start;w.player.velocity=Vector2.ZERO
	w.player.run=false;w.player.last_tap=-10;w.player.dash_cooldown=0
	w.camera.reset_smoothing();q.live();await q.wait_ticks(4)
	var size=w.room_size(room)
	var cells={};var stand={};var touched={}
	var out={"escaped":false,"room_change":-1,"min_y":INF,"min_x":INF,"max_x":-INF,"max_y":-INF}
	q.key(key_dir,true)
	var release=0;var nextjump=0
	for t in ticks:
		match pattern:
			"jump":
				if t%14==0: q.key(KEY_SPACE,true)
				if t%14==9: q.key(KEY_SPACE,false)
			"hold":
				if t%22==0: q.key(KEY_SPACE,true)
				if t%22==20: q.key(KEY_SPACE,false)
			"wall":
				if (w.player.is_on_wall() or w.player.is_on_floor()) and not q.held.get(KEY_SPACE,false) and t>=nextjump:
					q.key(KEY_SPACE,true);release=t+25;nextjump=t+30
				if q.held.get(KEY_SPACE,false) and t>=release: q.key(KEY_SPACE,false)
				if t%90==40: q.key(KEY_SHIFT,true)
				if t%90==41: q.key(KEY_SHIFT,false)
			"dash":
				if t%14==0: q.key(KEY_SPACE,true)
				if t%14==9: q.key(KEY_SPACE,false)
				if t%47==20: q.key(KEY_SHIFT,true)
				if t%47==22: q.key(KEY_SHIFT,false)
		await q.wait_ticks(1)
		if w.room!=room:
			out.room_change=w.room;break
		var p=w.player.position
		out.min_y=minf(out.min_y,p.y);out.min_x=minf(out.min_x,p.x);out.max_x=maxf(out.max_x,p.x);out.max_y=maxf(out.max_y,p.y)
		cells[cell(p)]=true
		if w.player.is_on_floor(): stand[cell(p)]=true
		if p.x<-16 or p.x>size.x+16 or p.y<-40 or p.y>size.y+200: out.escaped=true
		for i in eps.size():
			if absf(p.x-eps[i].at.x)<=72.0 and absf(p.y-eps[i].at.y)<=48.0: touched[i]=true
	q.release_all()
	out["cells"]=cells.keys();out["stand"]=stand.keys();out["touched"]=touched.keys()
	return out

func run(qa):
	q=qa;w=qa.w;c=w.cinematic_transitions
	args()
	var hooks_dir=qa.hooks_dir
	var report={"label":label,"rooms":{}}
	var ticks=240 if quick else 360
	var patterns=["jump","wall"] if quick else ["jump","hold","wall","dash"]
	var kits=["full"] if quick else ["full","base"]
	var total=0;var escapes=[];var changes=0
	for room in 21:
		if not rooms_filter.is_empty() and not (room in rooms_filter): continue
		q.reset(room)
		var eps=c.endpoints(w,room)
		var info={"size":[w.room_size(room).x,w.room_size(room).y],"endpoints":eps.map(func(e): return [e.at.x,e.at.y,e.target]),"probes":0,"cells":{},"stand":{},"touch_pairs":{},"escapes":[],"room_changes":[],"min_y":INF}
		for si in eps.size():
			var e=eps[si]
			var start=Vector2(e.at.x-int(e.heading)*64,e.at.y-2)
			if e.mode in ["stair_up","stair_down","depth_door"]: start=e.at+Vector2(-int(e.heading)*8,-2)
			for kit in kits:
				for pattern in patterns:
					for dir in [KEY_A,KEY_D]:
						var r=await probe(room,start,dir,pattern,kit,ticks,eps)
						total+=1;info.probes+=1
						for k in r.cells: info.cells["%s|%s"%[kit,k]]=true
						for k in r.stand: info.stand["%s|%s"%[kit,k]]=true
						for ti in r.touched: info.touch_pairs["%d>%d|%s"%[si,ti,kit]]=true
						info.min_y=minf(info.min_y,r.min_y)
						if r.escaped:
							info.escapes.append({"start":[start.x,start.y],"pattern":pattern,"dir":"A" if dir==KEY_A else "D","kit":kit,"min":[r.min_x,r.min_y],"max":[r.max_x,r.max_y]})
							escapes.append("R%d %s %s %s"%[room,pattern,"A" if dir==KEY_A else "D",kit])
						if r.room_change>=0:
							changes+=1
							info.room_changes.append({"pattern":pattern,"to":r.room_change,"kit":kit})
		info.cells=info.cells.keys();info.stand=info.stand.keys();info.touch_pairs=info.touch_pairs.keys()
		report.rooms[str(room)]=info
		print("QA W3 REACH R%d probes=%d cells=%d stand=%d touch=%d escapes=%d room_changes=%d min_y=%.0f"%[room,info.probes,info.cells.size(),info.stand.size(),info.touch_pairs.size(),info.escapes.size(),info.room_changes.size(),info.min_y])
	var path=(qa.out_dir if qa.out_dir!="" else "user://w3_out").path_join("w3_reach_%s.json"%label)
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var f=FileAccess.open(path,FileAccess.WRITE)
	if f!=null: f.store_string(JSON.stringify(report));f.close()
	print("QA W3 REACH wrote ",path)
	q.check(escapes.is_empty(),"[W3-REACH-NO-ESCAPE] %d probes with real input: %d left the room rectangle (x -16..W+16, y above -40): %s"%[total,escapes.size(),", ".join(escapes.slice(0,12))])
	# Compare with ground truth when available.
	var truths=[]
	for n in ["pr51","c49"]:
		var tp=hooks_dir.path_join("w3_reach_truth_%s.json"%n)
		if FileAccess.file_exists(tp):
			var j=JSON.parse_string(FileAccess.get_file_as_string(tp))
			if typeof(j)==TYPE_DICTIONARY: truths.append([n,j])
	if truths.is_empty():
		q.skip("[W3-REACH-ROUTES] no ground-truth reach JSON in the hooks directory. NOT a pass.")
		return
	for t in truths:
		var lost_pairs=[];var lost_cells=0;var gained_cells=0;var comparable=0
		for rid in report.rooms:
			if not t[1].rooms.has(rid): continue
			var a=report.rooms[rid];var b=t[1].rooms[rid]
			comparable+=1
			if a.endpoints.size()!=b.endpoints.size(): continue
			for p in b.touch_pairs:
				if not (p in a.touch_pairs): lost_pairs.append("R%s %s"%[rid,p])
			for k in b.stand:
				if not (k in a.stand): lost_cells+=1
			for k in a.stand:
				if not (k in b.stand): gained_cells+=1
		print("QA W3 REACH compare vs ",t[0]," rooms=",comparable," lost_pairs=",lost_pairs.size()," lost_stand_cells=",lost_cells," gained_stand_cells=",gained_cells," lost=",lost_pairs.slice(0,20))
		q.check(lost_pairs.is_empty(),"[W3-REACH-ROUTES-vs-%s] endpoint reachability pairs found in %s and missing now: %d (%s); stand cells lost %d / gained %d are for review"%[t[0],t[0],lost_pairs.size(),", ".join(lost_pairs.slice(0,8)),lost_cells,gained_cells])
