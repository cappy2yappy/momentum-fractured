extends "res://tests/native_cinematic_transitions.gd"
## TR-08 Canal Doorway hang probe. Loads the real Play-Canal-Doorway fixture
## (docs/tr08/fixtures/TR08-Canal-Exit.json, R13 feet (330,1158)) through the normal save
## path for EVERY run and drives only real InputEventKey presses. Classifies each run and
## prints a compact state-change trace. Run: -- "--tr05-save=<abs profile json>"
const FIXTURE = "res://docs/tr08/fixtures/TR08-Canal-Exit.json"
var held = {}
var results = []
var trace = []

func key(code,pressed):
	held[code]=pressed
	super.key(code,pressed)

func save_path() -> String:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--tr05-save="): return arg.trim_prefix("--tr05-save=")
	return ""

func load_fixture():
	for code in [KEY_A,KEY_D,KEY_SPACE,KEY_SHIFT,KEY_E]: key(code,false)
	if is_instance_valid(w):
		w.queue_free();await process_frame;await process_frame
	var f=FileAccess.open(save_path(),FileAccess.WRITE)
	f.store_string(FileAccess.get_file_as_string(FIXTURE));f.close()
	w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w

func snapshot() -> String:
	var t8=w.cinematic_transitions.tr08
	var p=w.player
	return "room=%d phase=%s tr=%.3f pend=%d phys=%s floor=%s pos=(%.1f,%.1f) vel=(%.0f,%.0f) clip=%s f=%d armed=%s cd=%.2f A=%s D=%s"%[w.room,t8.phase(),w.transition,w.pending_room,p.is_physics_processing(),p.is_on_floor(),p.position.x,p.position.y,p.velocity.x,p.velocity.y,t8.canal.kaze.clip.get("name","") if t8.canal.phase!="" else "",t8.canal.kaze.frame,w.cinematic_transitions.armed.get(0,false),w.cinematic_transitions.cooldown,held.get(KEY_A,false),held.get(KEY_D,false)]

func coarse() -> String:
	var t8=w.cinematic_transitions.tr08
	return "%d|%s|%s|%s|%s"%[w.room,t8.phase(),w.transition>0,w.player.is_physics_processing(),w.pending_room]

## One run: `script` is called every tick with the tick index and may press keys.
func run_case(name:String,start_delay:int,script:Callable,limit:=900) -> Dictionary:
	await load_fixture()
	await wait_ticks(start_delay)
	var last="";var lines=[];var owned_ticks=0;var max_owned=0;var started=-1;var done=-1
	var reqs=w.cinematic_transitions.request_count
	for tick in limit:
		await script.call(tick)
		await wait_ticks(1)
		var t8=w.cinematic_transitions.tr08
		if t8.owns():
			owned_ticks+=1;max_owned=maxi(max_owned,owned_ticks)
			if started<0: started=tick
		else: owned_ticks=0
		var c=coarse()
		if c!=last or (OS.get_environment("PROBE_TRACE")=="1" and tick%6==0 and done<0):
			lines.append("t%03d %s"%[tick,snapshot()]);last=c
		if w.room==0 and not t8.owns() and w.transition<=0 and w.player.is_physics_processing() and done<0: done=tick
		if done>=0 and tick>done+30: break
	for code in [KEY_A,KEY_D,KEY_SPACE,KEY_SHIFT,KEY_E]: key(code,false)
	var t8=w.cinematic_transitions.tr08
	var outcome="completed" if done>=0 else ("stuck_owned" if t8.owns() else ("frozen" if not w.player.is_physics_processing() else ("in_r13" if w.room==13 else "other")))
	var r={"name":name,"outcome":outcome,"start_tick":started,"done_tick":done,"requests":w.cinematic_transitions.request_count-reqs,"canal_result":t8.canal.last_result,"canal_started":t8.canal.started,"final":snapshot()}
	results.append(r)
	print("CASE ",name," -> ",outcome," start=",started," done=",done," req=",r.requests," canal=",t8.canal.last_result," final: ",r.final)
	if outcome!="completed" or OS.get_environment("PROBE_TRACE")=="1":
		for l in lines: print("   ",l)
	return r

func run():
	await process_frame
	output="res://build/tr08/hang"
	DirAccess.make_dir_recursive_absolute(output)
	var cases=0
	# 1. Hold A from rest, varied start delays (frame timing after load).
	for d in [1,2,3,5,8,13,21,34]:
		await run_case("hold_from_rest_d%d"%d,d,func(t): if t==0: key(KEY_A,true))
	# 2. Tap-walk: release A at varied points and re-press (repeated attempts).
	for gap in [6,10,15,22,30,45]:
		await run_case("pulse_gap%d"%gap,4,func(t):
			if t%gap==0: key(KEY_A,true)
			elif t%gap==gap-3: key(KEY_A,false))
	# 3. Release A at varied ticks after start (hold durations through the threshold).
	for rel in [20,25,28,30,32,35,40,50,70]:
		await run_case("release_at%d"%rel,4,func(t):
			if t==0: key(KEY_A,true)
			if t==rel: key(KEY_A,false))
	# 4. Sprint (double tap) and dash.
	for d in [2,5,9]:
		await run_case("sprint_d%d"%d,d,func(t):
			if t==0: key(KEY_A,true)
			if t==2: key(KEY_A,false)
			if t==3: key(KEY_A,true))
	for at in [2,8,14,20,26]:
		await run_case("dash_at%d"%at,4,func(t):
			if t==0: key(KEY_A,true)
			if t==at: key(KEY_SHIFT,true)
			if t==at+1: key(KEY_SHIFT,false))
	# 5. Jumps at varied points of the approach (off the shelf, mid-fall, near the door).
	for at in [0,5,10,15,18,21,24,27,30,34]:
		for hold in [4,12]:
			await run_case("jump_at%d_h%d"%[at,hold],4,func(t):
				if t==0: key(KEY_A,true)
				if t==at: key(KEY_SPACE,true)
				if t==at+hold: key(KEY_SPACE,false))
	# 6. Stop and reverse around the threshold, then re-approach.
	for x in [180,150,135,125,121]:
		await run_case("reverse_at_x%d"%x,4,func(t):
			if t==0: key(KEY_A,true)
			if held.get(KEY_A,false) and w.player.position.x<=x and not w.get_meta("rev",false):
				key(KEY_A,false);key(KEY_D,true);w.set_meta("rev",true);w.set_meta("rev_t",t)
			if w.get_meta("rev",false) and held.get(KEY_D,false) and t>=int(w.get_meta("rev_t"))+8:
				key(KEY_D,false);key(KEY_A,true))
	# 7. Hold A AND mash E during the approach and the passage.
	await run_case("hold_with_e_mash",4,func(t):
		if t==0: key(KEY_A,true)
		if t%5==0: key(KEY_E,true)
		elif t%5==1: key(KEY_E,false))
	# 8. Walk in, stand still inside the door (x<=120 past the trigger after release), then hold A.
	for wait in [10,30,60]:
		await run_case("idle_in_doorway_w%d"%wait,4,func(t):
			if t==0: key(KEY_A,true)
			if t==24: key(KEY_A,false)
			if t==24+wait: key(KEY_A,true))
	# 9. Interruptions that happen in real play: window focus loss (auto-pause), Esc pause,
	# map and kit toggles, at varied ticks; resumed with the real key, A kept held.
	for kind in ["focus","esc","map"]:
		for at in [30,38,44,52,60,70,80,95]:
			await run_case("%s_at%d"%[kind,at],4,func(t):
				if t==0: key(KEY_A,true)
				if t==at:
					if kind=="focus": w.hud.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
					elif kind=="esc": key(KEY_ESCAPE,true);await process_frame;key(KEY_ESCAPE,false)
					else: key(KEY_M,true);await process_frame;key(KEY_M,false)
					for i in 6: await process_frame
					if kind=="map": key(KEY_M,true);await process_frame;key(KEY_M,false)
					else: key(KEY_ESCAPE,true);await process_frame;key(KEY_ESCAPE,false)
					for i in 3: await process_frame)
	# 10. Grounded approach (step off the shelf, settle on the pad, then hold A) so the
	# TR-08 sequence runs; interrupt at offsets from its start, resume, keep A held.
	for kind in ["focus","esc","map"]:
		for off in [1,8,16,24,32,40,48,60,75]:
			await run_case("grounded_%s_off%d"%[kind,off],4,func(t):
				if t==0: key(KEY_A,true)
				if t==22: key(KEY_A,false)
				if t==40: key(KEY_A,true)
				var t8=w.cinematic_transitions.tr08
				if t8.owns() and not w.has_meta("s0"): w.set_meta("s0",t)
				if w.has_meta("s0") and t==int(w.get_meta("s0"))+off and not w.has_meta("hit"):
					w.set_meta("hit",true)
					if kind=="focus": w.hud.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
					elif kind=="esc": key(KEY_ESCAPE,true);await process_frame;key(KEY_ESCAPE,false)
					else: key(KEY_M,true);await process_frame;key(KEY_M,false)
					for i in 6: await process_frame
					if kind=="map": key(KEY_M,true);await process_frame;key(KEY_M,false)
					else: key(KEY_ESCAPE,true);await process_frame;key(KEY_ESCAPE,false)
					for i in 3: await process_frame)
	var tally={}
	for r in results: tally[r.outcome]=tally.get(r.outcome,0)+1
	print("PROBE runs=",results.size()," tally=",tally)
	var f=FileAccess.open(output+"/probe.json",FileAccess.WRITE);f.store_string(JSON.stringify(results,"\t"));f.close()
	w.queue_free();current_scene=null
	for i in 3: await process_frame
	quit(0)
