extends "res://tests/tr08_canal_hang_probe.gd"
## TR08 hang regression (deterministic, real InputEventKey input only; the fixture is the
## real Play-Canal-Doorway save loaded through the normal save path for every case).
## Fails on 079d9b28 (pre-fix), passes after the fix. Run headless:
##   -- "--tr05-save=<abs profile json>"
## Covered: (1) pause / window focus loss / map toggle BEFORE the request used to leave
## Kaze in the doorway holding A forever (trigger disarmed); (2) holding A from the shelf
## crossed x=120 airborne and skipped the embodied passage; retry and control handoff.
var failures_count = 0

func expect(ok:bool,label:String):
	check(ok,label)

func interrupt(kind:String):
	if kind=="focus": w.hud.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	elif kind=="esc": key(KEY_ESCAPE,true);await process_frame;key(KEY_ESCAPE,false)
	else: key(KEY_M,true);await process_frame;key(KEY_M,false)
	for i in 6: await process_frame
	if kind=="map": key(KEY_M,true);await process_frame;key(KEY_M,false)
	else: key(KEY_ESCAPE,true);await process_frame;key(KEY_ESCAPE,false)
	for i in 3: await process_frame

func handed_back(r:Dictionary) -> bool:
	var t8=w.cinematic_transitions.tr08
	return r.outcome=="completed" and w.room==0 and w.player.is_physics_processing() and w.player.sprite.visible and not t8.canal.layer.visible and not t8.owns()

func run():
	await process_frame
	output="res://build/tr08/hang"
	DirAccess.make_dir_recursive_absolute(output)
	var t8
	# 1. Hold A from rest on the real fixture: the embodied passage must play, once.
	for d in [1,4,9,17]:
		var r=await run_case("hold_from_rest_d%d"%d,d,func(t): if t==0: key(KEY_A,true))
		t8=w.cinematic_transitions.tr08
		expect(handed_back(r) and r.requests==1,"Hold A from rest (start delay %d) completes with one request and control back"%d)
		expect(r.start_tick>=0 and t8.canal.last_result=="completed" and t8.canal.shown.size()>=4,"Hold A from rest (delay %d) plays the embodied doorway, not the inherited wipe"%d)
		expect(r.done_tick>=0 and r.done_tick<=200,"Hold A from rest (delay %d) hands back control by tick 200 (%d)"%[d,r.done_tick])
	# 2. Interruptions before the request, A kept held: must still pass through, once.
	for kind in ["focus","esc","map"]:
		for off in [1,6,12,20,28,34]:
			var r=await run_case("pre_request_%s_off%d"%[kind,off],4,func(t):
				if t==0: key(KEY_A,true)
				if t==22: key(KEY_A,false)
				if t==40: key(KEY_A,true)
				var c8=w.cinematic_transitions.tr08
				if c8.owns() and not w.has_meta("s0"): w.set_meta("s0",t)
				if w.has_meta("s0") and t==int(w.get_meta("s0"))+off and not w.has_meta("hit"):
					w.set_meta("hit",true);w.set_meta("pre",c8.canal.request_time<0)
					await interrupt(kind))
			expect(w.get_meta("pre",false),"Interruption %s+%d really landed before the request"%[kind,off])
			expect(handed_back(r) and r.requests==1,"After %s at +%d ticks with A held, the passage completes once with control back"%[kind,off])
	# 3. Interruption during the landing phase (stepping off the shelf with A held).
	for kind in ["focus","esc"]:
		var r=await run_case("landing_%s"%kind,4,func(t):
			if t==0: key(KEY_A,true)
			var c8=w.cinematic_transitions.tr08
			if c8.canal.phase=="land" and not w.has_meta("hit"):
				w.set_meta("hit",true);await interrupt(kind))
		expect(w.has_meta("hit") and handed_back(r) and r.requests==1,"Interruption (%s) while landing still completes once"%kind)
	# 4. Retry: two interruptions in a row before the request, then completion.
	var r2=await run_case("double_retry",4,func(t):
		if t==0: key(KEY_A,true)
		if t==22: key(KEY_A,false)
		if t==40: key(KEY_A,true)
		var c8=w.cinematic_transitions.tr08
		var n=int(w.get_meta("hits",0))
		if c8.owns() and c8.canal.request_time<0 and c8.canal.phase in ["turn","cross"] and n<2 and c8.canal.phase_time>0.1:
			w.set_meta("hits",n+1);await interrupt("focus"))
	expect(int(w.get_meta("hits",0))==2 and handed_back(r2) and r2.requests==1,"Two pre-request interruptions then completion: exactly one request, control back")
	# 5. Abort then release A: Kaze stays put in the doorway, nothing loops, A again exits.
	var r3=await run_case("abort_release_then_press",4,func(t):
		if t==0: key(KEY_A,true)
		if t==22: key(KEY_A,false)
		if t==40: key(KEY_A,true)
		var c8=w.cinematic_transitions.tr08
		if c8.owns() and not w.has_meta("hit"):
			w.set_meta("hit",true);key(KEY_A,false);await interrupt("esc");w.set_meta("at",t)
		if w.has_meta("at") and t==int(w.get_meta("at"))+60:
			w.set_meta("idle_ok",w.room==13 and not c8.owns() and w.cinematic_transitions.request_count==int(w.get_meta("req0",0)) and w.player.is_physics_processing())
			key(KEY_A,true)
		if t==0: w.set_meta("req0",w.cinematic_transitions.request_count))
	expect(w.get_meta("idle_ok",false),"After an aborted passage with A released, Kaze stands with control and nothing fires")
	expect(handed_back(r3) and r3.requests==1,"Pressing A again after the abort exits through the doorway once")
	print("TR08 HANG REGRESSION: %d checks, %d failure(s)"%[checks,failures])
	w.queue_free();current_scene=null
	for i in 3: await process_frame
	quit(1 if failures else 0)
