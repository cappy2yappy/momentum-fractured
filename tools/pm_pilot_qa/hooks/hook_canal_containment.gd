extends RefCounted
## QA-owned. Canal-left containment (CANAL_CONTRACT v1, Room 13 left exit feet (120,1200) -> R0).
## Real keys and physics only: the player is placed at a start pose, then only InputEventKey drives it.
## With the Level geometry present the checks assert; on a baseline (no geometry) the same probes run and are
## printed as measurements, and the check is a SKIP unless --qa-expect-canal is passed (then it FAILs).
const MASS=Rect2(0,0,296,1020)
const PIER=Rect2(0,1020,72,180)
const HALL_X=296.0
const CEILING_FEET=1080.0
var q
var w
var c
var present=false

func hall_probe(start,dir_key,pattern,ticks=540):
	# pattern: "jump" spams jump, "dash" adds dash, "wall" holds dir_key with held jump chain.
	q.release_all()
	q.reset(13)
	w.player.position=start;w.player.velocity=Vector2.ZERO
	w.player.run=false;w.player.last_tap=-10;w.player.dash_cooldown=0
	q.live();await q.wait_ticks(5)
	var miny=INF;var minx=INF;var inside=false;var left_world=false;var left_room=false
	var min_in_hall=INF
	var returned=false
	var release=0
	var nextjump=0
	if pattern!="outer": q.key(dir_key,true)
	for t in ticks:
		if pattern=="outer":
			if t==10: q.key(dir_key,true)
			if t==0 or t==22: q.key(KEY_SPACE,true)
			if t==16 or t==30: q.key(KEY_SPACE,false)
			if t>40 and t%14==0: q.key(KEY_SPACE,true)
			if t>40 and t%14==9: q.key(KEY_SPACE,false)
			if t>40 and t%61==30: q.key(KEY_SHIFT,true)
			if t>40 and t%61==32: q.key(KEY_SHIFT,false)
		elif pattern=="wall":
			# Same idea as a human chaining wall jumps: jump (held 25 ticks) whenever on floor or wall.
			if (w.player.is_on_wall() or w.player.is_on_floor()) and not q.held.get(KEY_SPACE,false) and t>=nextjump:
				q.key(KEY_SPACE,true);release=t+25;nextjump=t+30
			if q.held.get(KEY_SPACE,false) and t>=release: q.key(KEY_SPACE,false)
			if t%90==40: q.key(KEY_SHIFT,true)
			if t%90==41: q.key(KEY_SHIFT,false)
		elif pattern=="hold":
			if t%22==0: q.key(KEY_SPACE,true)
			if t%22==20: q.key(KEY_SPACE,false)
		else:
			if t%14==0: q.key(KEY_SPACE,true)
			if t%14==9: q.key(KEY_SPACE,false)
		if pattern=="dash" and t%47==20: q.key(KEY_SHIFT,true)
		if pattern=="dash" and t%47==22: q.key(KEY_SHIFT,false)
		await q.wait_ticks(1)
		if w.room!=13:
			left_room=true
			break
		var p=w.player.position
		miny=minf(miny,p.y);minx=minf(minx,p.x)
		if p.x<-20 or p.x>1820 or p.y<-40: left_world=true
		elif left_world and p.y>1000 and p.x>=0 and p.x<=1800: returned=true
		var body=Rect2(p.x-14,p.y-60,28,60)
		if body.grow(-1).intersects(MASS) or body.grow(-1).intersects(PIER): inside=true
		if p.x<HALL_X-14: min_in_hall=minf(min_in_hall,p.y)
	q.release_all()
	return {"miny":miny,"minx":minx,"inside":inside,"left_world":left_world,"left_room":left_room,"returned":returned,"min_in_hall":min_in_hall,"end":w.player.position,"room":w.room}

func autopilot(targets,ticks_per=420):
	# Minimal real-key route follower: walks toward each target top, jumps near its edge, double-jumps when needed.
	var done=[]
	for t in targets:
		var ok=false
		var jump_t=-999
		var last_jump_press=-999
		for tick in ticks_per:
			var p=w.player.position
			var lo=t.position.x+22;var hi=t.end.x-22
			var want_r=p.x<lo;var want_l=p.x>hi
			q.key(KEY_D,want_r);q.key(KEY_A,want_l)
			var below=p.y>t.position.y+6
			var edge_dist=0.0
			if p.x<t.position.x: edge_dist=t.position.x-p.x
			elif p.x>t.end.x: edge_dist=p.x-t.end.x
			if w.player.is_on_floor() and below and tick-jump_t>35 and edge_dist<=150:
				q.key(KEY_SPACE,true);jump_t=tick
			elif tick-jump_t==16: q.key(KEY_SPACE,false)
			elif tick-jump_t==22 and not w.player.is_on_floor() and below and p.y-t.position.y>200: q.key(KEY_SPACE,true)
			elif tick-jump_t==36: q.key(KEY_SPACE,false)
			await q.wait_ticks(1)
			if w.room!=13: break
			p=w.player.position
			if w.player.is_on_floor() and absf(p.y-t.position.y)<=3 and p.x>=t.position.x and p.x<=t.end.x:
				ok=true;break
		q.release_all()
		done.append(ok)
		if not ok: break
	return done

func baseline_rows():
	var raw=JSON.parse_string(FileAccess.get_file_as_string(q.hooks_dir.path_join("r13_baseline_platforms.json")))
	var rows=[]
	for r in raw: rows.append(Rect2(r[0],r[1],r[2],r[3]))
	return rows

func run(qa):
	q=qa;w=qa.w;c=w.cinematic_transitions
	q.reset(13)
	present=w.platforms.has(MASS) and w.platforms.has(PIER)
	# Measurements that run everywhere (printed for the report).
	var starts=[["pad_mid",Vector2(250,1198),KEY_A,"jump"],["pad_mouth",Vector2(330,1198),KEY_A,"dash"],["pad_door_side",Vector2(150,1198),KEY_A,"jump"],["shelf",Vector2(260,1158),KEY_A,"dash"],["pad_hold_left",Vector2(250,1198),KEY_A,"hold"],["pad_door_hold",Vector2(150,1198),KEY_A,"hold"],["wall_184_left",Vector2(184,1198),KEY_A,"wall"],["wall_282_left",Vector2(282,1198),KEY_A,"wall"],["wall_282_right",Vector2(282,1198),KEY_D,"wall"],["pad_right_hold",Vector2(250,1198),KEY_D,"jump"]]
	var results={}
	for st in starts:
		var r=await hall_probe(st[1],st[2],st[3])
		results[st[0]]=r
		print("QA CANAL probe ",st[0]," min_feet_y=",r.miny," min_in_hall=",r.min_in_hall," min_x=",r.minx," left_room=",r.left_room," left_world=",r.left_world," inside_solid=",r.inside," end=",r.end)
	if not present:
		var msg="Canal gatehouse geometry (mass %s + pier %s) absent in this checkout; containment not asserted. Probe data printed above. NOT a pass."%[MASS,PIER]
		if q.expect_canal: q.check(false,"Candidate expected to carry the Canal geometry but it is absent")
		else: q.skip(msg)
		return
	# --- geometry matches the contract and nothing else in R13 moved
	q.reset(13)
	q.check(w.platforms.has(Rect2(0,1200,360,40)),"Exit pad (0,1200,360,40) retained")
	var base=baseline_rows();var added=[];var removed=[]
	for r in w.platforms:
		if not (r in base): added.append(r)
	for r in base:
		if not (r in w.platforms): removed.append(r)
	print("QA CANAL platform diff vs PR51 added=",added," removed=",removed)
	q.check(removed.is_empty(),"No PR51 R13 platform was removed or moved (%d removed)"%removed.size())
	var only_enclosure=true
	for r in added:
		if not (r==MASS or r==PIER): only_enclosure=false
	q.check(only_enclosure and added.size()==2 and MASS.end.x<=HALL_X,"The only added R13 colliders are the contract mass and pier, right edge x<=296")
	var ep=c.endpoint(w,13,0)
	q.check(ep.at==Vector2(120,1200) and ep.mode=="horizontal_walk" and ep.heading==-1,"Exit endpoint unchanged (120,1200), horizontal_walk, heading -1")
	q.check(w.cinematic_transitions.endpoint(w,0,13).at==Vector2(590,780) and c.endpoint(w,0,13).mode=="depth_door","Entrance R0->R13 unchanged (depth door at (590,780))")
	# aperture clear of colliders
	var aperture=Rect2(72,1068,96,132);var blockers=0
	for r in w.platforms:
		if r.intersects(aperture) and not (absf(r.position.y-1200)<1): blockers+=1
	q.check(blockers==0,"Aperture 72..168 x 1068..1200 has no collider inside it")
	# --- containment under real input
	for st in starts:
		var r=results[st[0]]
		if r.left_room: continue
		q.check(r.min_in_hall>=CEILING_FEET-1.5,"Probe %s never rises above the lintel inside the hall (min feet y %.1f, limit 1080)"%[st[0],r.min_in_hall])
		q.check(not r.inside,"Probe %s never clips into the mass or pier"%st[0])
		q.check(r.minx>=86.0-1.5,"Probe %s never goes left of the pier face plus radius (min x %.1f)"%[st[0],r.minx])
	# --- intended exit still works by walk and by E, repeatedly
	for cycle in 2:
		q.release_all();q.reset(0)
		w.player.position=c.endpoint(w,0,13).at-Vector2(0,2);w.player.velocity=Vector2.ZERO
		q.live();await q.wait_ticks(4)
		q.key(KEY_E,true);await q.wait_ticks(2);q.key(KEY_E,false)
		for t in 300:
			await q.wait_ticks(1)
			if w.room==13 and w.transition<=0: break
		await q.wait_ticks(20)
		q.check(w.room==13 and w.player.position.distance_to(Vector2(184,1198))<3.0,"Cycle %d: R0->R13 arrives at (184,1198): %s"%[cycle,w.player.position])
		var b=c.request_count
		q.key(KEY_A,true)
		for t in 240:
			await q.wait_ticks(1)
			if c.request_count>b: break
		q.key(KEY_A,false);await q.wait_ticks(60)
		q.check(w.room==0 and c.request_count==b+1 and w.player.is_on_floor(),"Cycle %d: walking left through the door lands in R0 once"%cycle)
	# --- other R13 routes: real-key climb up the main staircase to the R14 exit
	q.release_all();q.reset(13)
	w.player.position=Vector2(184,1198);w.player.velocity=Vector2.ZERO
	q.live();await q.wait_ticks(5)
	var legs=[Rect2(500,1050,300,40),Rect2(720,940,360,40),Rect2(1010,830,300,40),Rect2(1220,720,400,40),Rect2(1400,560,400,40)]
	var done=await autopilot(legs)
	print("QA CANAL route legs done=",done," end=",w.player.position)
	q.check(done.size()==legs.size() and not done.has(false),"Real-key climb from the arrival point over shelves 500/720/1010/1220/1400 reaches the R14 exit shelf (legs %s)"%[done])
	if done.size()==legs.size() and not done.has(false):
		var b2=c.request_count
		q.key(KEY_D,true)
		for t in 240:
			await q.wait_ticks(1)
			if c.request_count>b2: break
		q.key(KEY_D,false);await q.wait_ticks(60)
		q.check(w.room==14,"Walking right off the top shelf takes the R13->R14 automatic passage (room %d)"%w.room)
	# --- residual: exterior face of the mass at x=296 (informational, plainly reported)
	var res={}
	for st in [["outer_face_from_shelf_330",Vector2(330,1158)],["outer_face_from_shelf_400",Vector2(400,1158)],["outer_face_from_shelf_520",Vector2(520,1048)]]:
		var r=await hall_probe(st[1],KEY_A,"wall",900)
		print("QA CANAL RESIDUAL ",st[0]," min_feet_y=",r.miny," left_world=",r.left_world," left_room=",r.left_room," returned_by_fall_recovery=",r.returned," end=",w.player.position)
		res[st[0]]=[r.miny,r.left_world,r.returned]
	q.check(true,"Residual exterior-face wall-jump measured (informational, see QA CANAL RESIDUAL lines)")
