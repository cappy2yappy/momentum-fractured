extends RefCounted
## QA-owned. Wave 3 Canal doorway, BOTH directions: R13 left exit -> R0 (walk through, real A key) and R0 -> R13 (depth
## door, real E). Kaze must physically pass the threshold with true frames, not be covered by a wipe; label, arrival,
## reduced motion, control restoration, no double trigger, progression untouched. Candidate-agnostic observation only.
var q
var w
var c
var L
var truth={}
const CEILING=6.0
const APERTURE_X=Vector2(72,168)

func load_truth(dir):
	var p=dir.path_join("w3_ground_truth.json")
	if FileAccess.file_exists(p):
		var j=JSON.parse_string(FileAccess.get_file_as_string(p))
		if typeof(j)==TYPE_DICTIONARY: truth=j

func start(from,to,dx):
	q.release_all()
	q.reset(from);c=w.cinematic_transitions
	c.reduced=false;w.embodied_transitions.comparison="art-preview"
	w.player.position=c.endpoint(w,from,to).at+Vector2(dx,-2);w.player.velocity=Vector2.ZERO
	w.player.run=false;w.player.last_tap=-10;w.player.dash_cooldown=0
	w.camera.reset_smoothing();q.live()
	await q.wait_ticks(6)

func arrival_ok(tag,from,to):
	var key="%d:%d"%[from,to]
	var expect=c.endpoint(w,to,from).at
	var facing_want=null
	if truth.has(key):
		expect=Vector2(truth[key].x,truth[key].y);facing_want=int(truth[key].facing)
	var d=w.player.position.distance_to(expect)
	var tol=float(truth[key].get("tol",12.0)) if truth.has(key) else 90.0
	q.check(w.room==to and d<=tol and w.player.is_on_floor(),"[W3-%s-ARRIVAL] arrives in R%d supported, feet %s within %.0f px of %s (distance %.1f)"%[tag,to,w.player.position,tol,expect,d])
	if facing_want!=null: q.check(int(w.player.facing)==facing_want,"[W3-%s-FACING] arrival facing %d equals the PR61 ground truth %d"%[tag,int(w.player.facing),facing_want])
	else: q.skip("[W3-%s-FACING] no ground truth facing for %s. NOT a pass."%[tag,key])
	print("QA W3 TRUTH ",key," ",JSON.stringify({"x":w.player.position.x,"y":w.player.position.y,"facing":int(w.player.facing),"room":w.room}))

func play(tag,from,to,dx,key_code,hold_through,use_f6=false):
	await start(from,to,dx)
	if use_f6:
		q.raw_key(KEY_F6,true);await q.wait_ticks(2);q.raw_key(KEY_F6,false);await q.wait_ticks(2)
	var snap0=L.snap()
	var press=func(): q.key(key_code,true)
	var rel=func(t):
		if not hold_through and t==2: q.key(key_code,false)
	var res=await L.drive(tag,press,to,w.ROOM_NAMES[to],rel,900,8)
	q.key(key_code,false)
	print("QA W3 ",tag," seconds=",res.seconds," ended=",res.ended," rooms=",res.rooms," requests=",res.requests," max_zoom=",res.max_zoom," labels=",res.labels.keys()," swap_tick=",res.swap_tick)
	return [res,snap0]

func through_checks(tag,res,door_at):
	# Physical passage evidence from the observed actor, before the room swap.
	var last=res.swap_tick if res.swap_tick>0 else L.samples.size()
	var vis=0;var tot=0;var near=false;var polys={}
	for i in range(0,mini(last,L.samples.size())):
		var s=L.samples[i];tot+=1
		if s.get("visible",false):
			vis+=1;polys[JSON.stringify([s.tex,s.frame,s.region])]=true
			if absf(s.pos[0]-door_at.x)<=60.0 and absf(s.pos[1]-door_at.y)<=140.0: near=true
	var share=float(vis)/maxf(1.0,float(tot))
	q.check(share>=0.7,"[W3-%s-VISIBLE] Kaze visible on %.0f%% of the %d ticks before the room swap (need >=70%%; a wipe that hides Kaze fails)"%[tag,share*100.0,tot])
	q.check(near,"[W3-%s-THRESHOLD] the visible actor reaches the doorway at %s before the swap (within 60 px x, 140 px y)"%[tag,door_at])
	q.check(polys.size()>=5,"[W3-%s-POSES] at least 5 distinct frames shown before the swap (turn, step, cross): %d"%[tag,polys.size()])
	if L.rendered:
		var worst=0.0;var n=0
		for g in res.grabs:
			if res.swap_tick>0 and absi(g.tick-res.swap_tick)<=10:
				worst=maxf(worst,g.flat);n+=1
		q.check(n>0 and worst<=0.90,"[W3-%s-NOT-WIPE] frames within 10 ticks of the swap are %.0f%% flat blocks at worst (%d grabs; a full-screen wipe scores near 100%%; need <=90%%)"%[tag,worst*100.0,n])
	else:
		q.skip("[W3-%s-NOT-WIPE] pixel flatness at the swap needs a rendered run. NOT a pass."%tag)

func full(tag,from,to,dx,key_code,hold_through,door_at):
	var r=await play(tag,from,to,dx,key_code,hold_through)
	var res=r[0];var snap0=r[1]
	q.check(res.started and res.ended and res.seconds>=1.5 and res.seconds<=CEILING,"[W3-%s-DURATION] input to control back %.2f s (need 1.5..%.1f s; contract about 2 to 4 s plus wipe)"%[tag,res.seconds,CEILING])
	q.check(res.requests==1 and res.rooms==[from,to],"[W3-%s-ONCE] one room request and one swap R%d to R%d (requests %d, rooms %s)"%[tag,from,to,res.requests,res.rooms])
	arrival_ok(tag,from,to)
	q.restored("W3 %s completion"%tag)
	q.check(L.snap()==snap0,"[W3-%s-PROGRESSION] abilities, gates, fragments, flags, HP unchanged"%tag)
	q.check(not res.labels.is_empty(),"[W3-%s-LABEL] destination label '%s' evidence: %s (pixel placement is a human review item)"%[tag,w.ROOM_NAMES[to],res.labels.keys()])
	await through_checks(tag,res,door_at)
	var an=L.analyze(tag)
	print("QA W3 ",tag," animation=",JSON.stringify(an))
	q.check(String(an.get("verdict","")).begins_with("TRUE_ANIMATION"),"[W3-%s-TRUE-ANIM] genuine multi-pose movement: verdict %s, true-motion %.0f%% of %d moving windows, distinct poses %d (%s)"%[tag,an.get("verdict"),float(an.get("true_motion_fraction",0.0))*100.0,int(an.get("moving_windows",0)),int(an.get("distinct_poses_total",0)),an.get("reason","")])
	await L.fullscreen_checks(tag,res)
	# second request after arrival with the key still held
	await start(from,to,dx)
	var req0=c.request_count
	q.key(key_code,true)
	var n=0
	while n<900 and not (w.room==to and L.controlled()):
		await q.wait_ticks(1);n+=1
	await q.wait_ticks(120)
	q.key(key_code,false);await q.wait_ticks(4)
	q.check(w.room==to and c.request_count==req0+1,"[W3-%s-HELD-KEY] key held through the sequence and 120 ticks after: one request, no bounce (requests +%d, room %d)"%[tag,c.request_count-req0,w.room])
	var x0=w.player.position.x
	q.key(KEY_D,true);await q.wait_ticks(14);q.key(KEY_D,false);await q.wait_ticks(8)
	var x1=w.player.position.x
	q.key(KEY_A,true);await q.wait_ticks(14);q.key(KEY_A,false);await q.wait_ticks(8)
	q.check(absf(x1-x0)>20 or absf(w.player.position.x-x1)>20,"[W3-%s-CONTROL] Kaze obeys real keys after the sequence (moved %.0f right, %.0f left)"%[tag,x1-x0,w.player.position.x-x1])
	return res.seconds

func reduced(tag,from,to,dx,key_code,hold_through,full_secs):
	var r=await play(tag+"-REDUCED",from,to,dx,key_code,hold_through,true)
	var res=r[0];var t=tag+"-REDUCED"
	q.check(c.reduced and res.ended and w.room==to and res.seconds<=CEILING,"[W3-%s-COMPLETES] real F6 reduced motion completes into R%d in %.2f s"%[t,to,res.seconds])
	q.check(res.max_zoom<=1.001,"[W3-%s-NO-ZOOM] camera never zooms (max %.3f)"%[t,res.max_zoom])
	q.check(full_secs<0.0 or res.seconds<full_secs-0.2,"[W3-%s-SHORTER] reduced %.2f s shorter than full %.2f s"%[t,res.seconds,full_secs])
	q.check(not res.labels.is_empty(),"[W3-%s-LABEL] destination label kept: %s"%[t,res.labels.keys()])
	var seen={}
	for s in L.samples:
		if s.get("visible",false) and s.get("tex","")!="": seen[JSON.stringify([s.tex,s.frame,s.region])]=true
	q.check(seen.size()>=2,"[W3-%s-FRAMES] true frames or first/last cross-fade still shown (%d distinct frames)"%[t,seen.size()])
	arrival_ok(t,from,to)
	q.restored("W3 %s"%t)
	c.reduced=false;w.embodied_transitions.comparison="art-preview"

func wait_control():
	var n=0
	while n<500 and not L.controlled():
		await q.wait_ticks(1);n+=1
	return n

func cancels(tag,from,to,dx,key_code):
	await start(from,to,dx)
	q.key(key_code,true)
	var n=0
	while n<600 and c.request_count==0 and w.transition<=0 and L.controlled():
		await q.wait_ticks(1);n+=1
	await q.wait_ticks(15);q.key(key_code,false)
	w.hud.toggle_pause();await q.wait_ticks(25);w.hud.toggle_pause();await q.wait_ticks(5)
	n=await wait_control()
	q.check(L.controlled() and n<500 and not q.paused,"[W3-%s-CANCEL-PAUSE] pause mid-sequence then resume: control back after %d ticks"%[tag,n])
	await start(from,to,dx)
	q.key(key_code,true)
	n=0
	while n<600 and c.request_count==0 and w.transition<=0 and L.controlled():
		await q.wait_ticks(1);n+=1
	await q.wait_ticks(15);q.key(key_code,false)
	w.respawn();await q.wait_ticks(10)
	n=await wait_control()
	await q.wait_ticks(5)
	q.check(L.controlled() and w.player.hp>0 and n<500,"[W3-%s-CANCEL-DEATH] respawn mid-sequence: control and sprite restored after %d ticks"%[tag,n])
	await start(from,to,dx)
	q.key(key_code,true)
	n=0
	while n<600 and c.request_count==0 and w.transition<=0 and L.controlled():
		await q.wait_ticks(1);n+=1
	await q.wait_ticks(15);q.key(key_code,false)
	w.build_room(from);q.freeze();q.live()
	n=await wait_control()
	await q.wait_ticks(5)
	q.check(L.controlled() and n<500,"[W3-%s-CANCEL-ROOMCHANGE] room rebuilt mid-sequence: control restored after %d ticks"%[tag,n])
	q.skip("[W3-%s-CANCEL-TIMEOUT] a stall cannot be forced candidate-agnostically; only the %.0f s ceiling is asserted. NOT a pass."%[tag,CEILING])

func run(qa):
	q=qa;w=qa.w
	var hooks_dir=qa.hooks_dir
	L=load(hooks_dir.path_join("w3_lib.gd")).new();L.setup(qa,hooks_dir)
	load_truth(hooks_dir)
	c=w.cinematic_transitions
	var door_out=c.endpoint(w,13,0).at
	var door_in=c.endpoint(w,0,13).at
	var a=await full("DOOR-CANAL-OUT",13,0,180.0,KEY_A,true,door_out)
	var b=await full("DOOR-CANAL-IN",0,13,0.0,KEY_E,false,door_in)
	await reduced("DOOR-CANAL-OUT",13,0,180.0,KEY_A,true,a)
	await reduced("DOOR-CANAL-IN",0,13,0.0,KEY_E,false,b)
	await cancels("DOOR-CANAL-OUT",13,0,180.0,KEY_A)
	await cancels("DOOR-CANAL-IN",0,13,0.0,KEY_E)
