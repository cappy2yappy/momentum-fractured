extends RefCounted
## QA-owned. Wave 3 staircase R14 <-> R17: ascent AND descent, full-screen presentation (rendered runs), true multi-frame
## movement, destination label, reduced motion, arrival correctness, control restoration (completion, pause, death,
## room change), no double trigger, progression untouched. Candidate-agnostic: only real E key input and observation.
var q
var w
var c
var L
var truth={}
const FULL_MIN=1.5
const CEILING=6.0

func load_truth(dir):
	var p=dir.path_join("w3_ground_truth.json")
	if FileAccess.file_exists(p):
		var j=JSON.parse_string(FileAccess.get_file_as_string(p))
		if typeof(j)==TYPE_DICTIONARY: truth=j

func start(from,to,off):
	q.release_all()
	q.reset(from);c=w.cinematic_transitions
	c.reduced=false;w.embodied_transitions.comparison="art-preview"
	w.player.position=c.endpoint(w,from,to).at+Vector2(off,-2);w.player.velocity=Vector2.ZERO
	w.player.run=false;w.player.last_tap=-10
	w.camera.reset_smoothing();q.live()
	await q.wait_ticks(6)

func arrival_ok(tag,from,to):
	var key="%d:%d"%[from,to]
	var expect=c.endpoint(w,to,from).at
	var facing_want=null
	if truth.has(key):
		expect=Vector2(truth[key].x,truth[key].y);facing_want=int(truth[key].facing)
	var d=w.player.position.distance_to(expect)
	q.check(w.room==to and d<=12.0,"[W3-%s-ARRIVAL] arrives in R%d with feet within 12 px of %s (distance %.1f, feet %s)"%[tag,to,expect,d,w.player.position])
	if facing_want!=null: q.check(int(w.player.facing)==facing_want,"[W3-%s-FACING] arrival facing %d equals the PR61 ground truth %d"%[tag,int(w.player.facing),facing_want])
	else: q.skip("[W3-%s-FACING] no ground truth facing for %s. NOT a pass."%[tag,key])
	print("QA W3 TRUTH ",key," ",JSON.stringify({"x":w.player.position.x,"y":w.player.position.y,"facing":int(w.player.facing),"room":w.room}))

func play(tag,from,to,off,use_f6=false,grab=true):
	await start(from,to,off)
	if use_f6:
		q.raw_key(KEY_F6,true);await q.wait_ticks(2);q.raw_key(KEY_F6,false);await q.wait_ticks(2)
	var snap0=L.snap()
	var press=func(): q.key(KEY_E,true)
	var rel=func(t):
		if t==2: q.key(KEY_E,false)
	var res=await L.drive(tag,press,to,w.ROOM_NAMES[to],rel,900,(8 if grab else 0))
	q.key(KEY_E,false)
	print("QA W3 ",tag," seconds=",res.seconds," physics_frames=",res.physics_frames_to_control," ended=",res.ended," rooms=",res.rooms," requests=",res.requests," max_zoom=",res.max_zoom," labels=",res.labels.keys()," swap_tick=",res.swap_tick)
	return [res,snap0]

func full(dir,from,to,off):
	var tag="STAIR-"+dir
	var r=await play(tag,from,to,off)
	var res=r[0];var snap0=r[1]
	q.check(res.started,"[W3-%s-STARTS] real E at the stair starts a presented sequence"%tag)
	q.check(res.ended and res.seconds>=FULL_MIN and res.seconds<=CEILING,"[W3-%s-DURATION] E to control back %.2f s (need %.1f..%.1f s; contract about 2 to 4 s plus wipe)"%[tag,res.seconds,FULL_MIN,CEILING])
	q.check(res.requests==1 and res.rooms==[from,to],"[W3-%s-ONCE] exactly one room request and one swap R%d to R%d (requests %d, rooms %s)"%[tag,from,to,res.requests,res.rooms])
	arrival_ok(tag,from,to)
	q.restored("W3 %s completion"%tag)
	q.check(L.snap()==snap0,"[W3-%s-PROGRESSION] abilities, gates, fragments, flags, HP unchanged by the sequence"%tag)
	q.check(not res.labels.is_empty(),"[W3-%s-LABEL] destination label '%s' evidence: %s (pixel placement is a human review item)"%[tag,w.ROOM_NAMES[to],res.labels.keys()])
	var an=L.analyze(tag)
	print("QA W3 ",tag," animation=",JSON.stringify(an))
	q.check(String(an.get("verdict","")).begins_with("TRUE_ANIMATION"),"[W3-%s-TRUE-ANIM] genuine multi-pose movement: verdict %s, true-motion %.0f%% of %d moving windows, distinct poses %d (%s)"%[tag,an.get("verdict"),float(an.get("true_motion_fraction",0.0))*100.0,int(an.get("moving_windows",0)),int(an.get("distinct_poses_total",0)),an.get("reason","")])
	await L.fullscreen_checks(tag,res)
	# E held through the whole sequence plus 120 ticks: exactly one request.
	await start(from,to,off)
	var req0=c.request_count
	q.key(KEY_E,true)
	var n=0
	while n<900 and not (w.room==to and L.controlled()):
		await q.wait_ticks(1);n+=1
	await q.wait_ticks(120)
	q.key(KEY_E,false);await q.wait_ticks(4)
	q.check(w.room==to and c.request_count==req0+1,"[W3-%s-HELD-E] E held through the sequence and 120 ticks after: one request, no bounce (requests +%d, room %d)"%[tag,c.request_count-req0,w.room])
	var x0=w.player.position.x
	q.key(KEY_D,true);await q.wait_ticks(14);q.key(KEY_D,false);await q.wait_ticks(8)
	var x1=w.player.position.x
	q.key(KEY_A,true);await q.wait_ticks(14);q.key(KEY_A,false);await q.wait_ticks(8)
	q.check(absf(w.player.position.x-x0)>20 or absf(x1-x0)>20,"[W3-%s-CONTROL] Kaze obeys real keys after the sequence (moved %.0f px right, %.0f px left)"%[tag,x1-x0,w.player.position.x-x1])
	return res.seconds

func reduced(dir,from,to,off,full_secs):
	var tag="STAIR-"+dir+"-REDUCED"
	var r=await play(tag,from,to,off,true)
	var res=r[0]
	q.check(c.reduced,"[W3-%s-FLAG] real F6 enabled reduced motion"%tag)
	q.check(res.ended and res.seconds<=CEILING and w.room==to,"[W3-%s-COMPLETES] completes into R%d in %.2f s"%[tag,to,res.seconds])
	q.check(full_secs<0.0 or res.seconds<full_secs-0.3,"[W3-%s-SHORTER] reduced %.2f s is shorter than full %.2f s"%[tag,res.seconds,full_secs])
	q.check(res.max_zoom<=1.001,"[W3-%s-NO-ZOOM] camera never zooms in reduced motion (max %.3f)"%[tag,res.max_zoom])
	q.check(not res.labels.is_empty(),"[W3-%s-LABEL] destination label kept in reduced motion: %s"%[tag,res.labels.keys()])
	var seen={}
	for s in L.samples:
		if s.get("visible",false) and s.get("tex","")!="": seen[JSON.stringify([s.tex,s.frame,s.region])]=true
	q.check(seen.size()>=2,"[W3-%s-FRAMES] reduced motion still shows true frames or a first/last cross-fade (%d distinct frames shown)"%[tag,seen.size()])
	arrival_ok(tag,from,to)
	q.restored("W3 %s"%tag)
	c.reduced=false;w.embodied_transitions.comparison="art-preview"

func wait_control():
	var n=0
	while n<500 and not L.controlled():
		await q.wait_ticks(1);n+=1
	return n

func cancels(dir,from,to,off):
	var tag="STAIR-"+dir
	await start(from,to,off)
	q.key(KEY_E,true);await q.wait_ticks(1);q.key(KEY_E,false);await q.wait_ticks(20)
	w.hud.toggle_pause();await q.wait_ticks(25);w.hud.toggle_pause();await q.wait_ticks(5)
	var n=await wait_control()
	q.check(L.controlled() and n<500 and not q.paused,"[W3-%s-CANCEL-PAUSE] pause mid-sequence then resume: control back after %d ticks"%[tag,n])
	await q.wait_ticks(10);q.restored("W3 %s pause"%tag)
	await start(from,to,off)
	q.key(KEY_E,true);await q.wait_ticks(1);q.key(KEY_E,false);await q.wait_ticks(25)
	w.respawn();await q.wait_ticks(10)
	n=await wait_control()
	await q.wait_ticks(5)
	q.check(L.controlled() and w.player.hp>0 and n<500,"[W3-%s-CANCEL-DEATH] respawn mid-sequence: control, live sprite and zoom restored after %d ticks"%[tag,n])
	await start(from,to,off)
	q.key(KEY_E,true);await q.wait_ticks(1);q.key(KEY_E,false);await q.wait_ticks(25)
	w.build_room(from);q.freeze();q.live()
	n=await wait_control()
	await q.wait_ticks(5)
	q.check(L.controlled() and n<500,"[W3-%s-CANCEL-ROOMCHANGE] room rebuilt mid-sequence: no stuck stage, control restored after %d ticks (room %d)"%[tag,n,w.room])
	q.skip("[W3-%s-CANCEL-TIMEOUT] a stall cannot be forced from outside a candidate-agnostic harness; only the %.0f s ceiling in DURATION is asserted. NOT a pass."%[tag,CEILING])

func locked_and_neighbour():
	await start(14,17,-30.0)
	q.strip_abilities();w.message="";w.message_time=0
	var before=c.request_count
	q.key(KEY_E,true);await q.wait_ticks(2);q.key(KEY_E,false);await q.wait_ticks(80)
	var locked=not w.can_enter(17)
	q.check(not locked or (w.room==14 and c.request_count==before and L.controlled()),"[W3-STAIR-LOCKED] gated stair (locked=%s) starts no sequence and keeps control (room %d, requests +%d)"%[locked,w.room,c.request_count-before])
	await start(13,14,-180.0)
	before=c.request_count
	q.key(KEY_D,true)
	for t in 500:
		await q.wait_ticks(1)
		if c.request_count>before: break
	q.key(KEY_D,false);await q.wait_ticks(80)
	q.check(w.room==14 and c.request_count==before+1,"[W3-NEIGHBOUR] R13 to R14 lateral passage still completes once (room %d, requests +%d)"%[w.room,c.request_count-before])

func run(qa):
	q=qa;w=qa.w
	var hooks_dir=qa.hooks_dir
	L=load(hooks_dir.path_join("w3_lib.gd")).new();L.setup(qa,hooks_dir)
	load_truth(hooks_dir)
	c=w.cinematic_transitions
	var asc=await full("ASCEND",14,17,-30.0)
	var desc=await full("DESCEND",17,14,0.0)
	await reduced("ASCEND",14,17,-30.0,asc)
	await reduced("DESCEND",17,14,0.0,desc)
	await cancels("ASCEND",14,17,-30.0)
	await cancels("DESCEND",17,14,0.0)
	await locked_and_neighbour()
