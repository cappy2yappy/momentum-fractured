extends RefCounted
## QA-owned. Cinematic completion and control restoration for the staged R14->R17 stair
## (Transition contract: opt-in --pm-staged-stair, total 2.35 s = 0.85 walk-in + 0.65 loader +
## 0.85 arrival, reduced motion 0.95 s, 4 s safety timeout). Real InputEventKey E / F6 / D input.
## Duration is measured by MY frame counter from the E key event to the first tick at which control is
## observably back; the controller's own markers (phase, completed, aborted, last_result) are
## cross-checked, never trusted alone.
var q
var w
var c
var s
var max_seen=0.0

func controlled():
	return s.phase=="" and w.transition<=0 and w.player.is_physics_processing()

func start(still=false,offset=-30.0,room=14,target=17):
	q.release_all()
	q.reset(room);c=w.cinematic_transitions;s=c.staged
	c.reduced=still;w.embodied_transitions.comparison="reduced" if still else "art-preview"
	w.player.position=c.endpoint(w,room,target).at+Vector2(offset,-2);w.player.velocity=Vector2.ZERO
	w.player.run=false;w.player.last_tap=-10
	w.camera.reset_smoothing();q.live()
	await q.wait_ticks(6)

# Presses E (real key) and returns [seconds, max_zoom, phases_seen] when control is back.
func sequence(hold_e=true,extra=null):
	var f0=Engine.get_physics_frames()
	q.key(KEY_E,true)
	if not hold_e:
		await q.wait_ticks(1);q.key(KEY_E,false)
	var phases=[];var zoom=1.0;var ticks=0;var started=false
	while ticks<500:
		await q.wait_ticks(1);ticks+=1
		if s.phase!="":
			started=true
			if not (s.phase in phases): phases.append(s.phase)
		zoom=maxf(zoom,w.camera.zoom.x)
		if extra: await extra.call(ticks)
		if started and controlled(): break
		if not started and w.transition>0: started=true
	var secs=(Engine.get_physics_frames()-f0)/60.0
	max_seen=maxf(max_seen,secs)
	return [secs,zoom,phases]

func off_checks():
	await start()
	var before=c.request_count
	q.key(KEY_E,true);await q.wait_ticks(1);q.key(KEY_E,false);await q.wait_ticks(3)
	q.check(s.phase=="" and w.transition>0,"Flag off: R14->R17 uses the inherited loader immediately (staged phase '%s', transition %.2f)"%[s.phase,w.transition])
	await q.wait_ticks(80)
	q.check(w.room==17 and w.transition<=0 and c.request_count==before+1 and s.started==0,"Flag off: inherited stair completes once, staged controller never starts")
	q.restored("flag-off R14->R17")

func on_checks():
	var args=OS.get_cmdline_user_args()
	var cli_reduced="--tr05-reduced-motion" in args
	q.check("--pm-staged-stair" in args and s.enabled,"Staged stair enabled by its explicit flag only")
	if cli_reduced:
		await start(c.reduced)
		q.check(c.reduced,"--tr05-reduced-motion starts the session reduced")
		var before=c.request_count
		var r=await sequence()
		q.check(r[0]>=0.85 and r[0]<=1.1,"Reduced (CLI) staged stair completes in %.2f s (contract 0.95)"%r[0])
		q.check(r[1]==1.0,"Reduced (CLI) never zooms the camera (max %.3f)"%r[1])
		q.check(s.last_result=="completed" and w.room==17 and c.request_count==before+1,"Reduced (CLI) completes once into R17")
		q.key(KEY_E,false)
		q.restored("reduced CLI stair")
		return
	# 1. Full sequence, E held throughout and for 100 ticks after arrival, D held as well.
	await start()
	var before=c.request_count;var hp=w.player.hp
	q.key(KEY_D,true)
	var r=await sequence()
	q.key(KEY_D,false)
	print("QA STAGED full seconds=",r[0]," phases=",r[2]," max_zoom=",r[1]," marker=",s.last_result," last_duration=",s.last_duration)
	q.check(r[0]>=2.25 and r[0]<=2.5,"Full sequence E-to-control %.2f s (contract 2.35)"%r[0])
	q.check(r[2]==["enter","load","arrive"],"Phases enter, load, arrive observed: %s"%[r[2]])
	q.check(r[1]>1.2,"Cinematic close-up occurred (max zoom %.2f)"%r[1])
	q.check(s.last_result=="completed" and s.completed==1 and s.aborted==0 and s.started==1,"Marker reports completed 1, aborted 0, started 1 (%s)"%s.last_result)
	q.check(s.last_duration>=2.0 and s.last_duration<=3.0,"Marker clock %.2f s within 2-3 s"%s.last_duration)
	q.check(w.room==17 and c.request_count==before+1,"Exactly one room request, now in R17")
	q.check(w.player.position.distance_to(Vector2(1680,1298))<3.0,"Arrival feet at the reciprocal endpoint (1680,1298): %s"%w.player.position)
	q.restored("staged stair completion")
	q.check(w.player.hp==hp and not q.paused,"HP unchanged and tree not paused")
	await q.wait_ticks(100);q.key(KEY_E,false);await q.wait_ticks(5)
	q.check(w.room==17 and c.request_count==before+1 and s.started==1,"E and D held through sequence plus 100 ticks: no bounce, no second sequence")
	# Control actually handed back: real key moves Kaze.
	var x0=w.player.position.x
	q.key(KEY_A,true);await q.wait_ticks(14);q.key(KEY_A,false)
	q.check(absf(w.player.position.x-x0)>20,"Kaze obeys a real key after the sequence (moved %.0f px)"%(w.player.position.x-x0))
	# 2. Mashing E (real) cannot double trigger.
	await start()
	before=c.request_count;var st=s.started
	var mash=func(t):
		if t%5==0:
			q.key(KEY_E,false);await q.wait_ticks(1);q.key(KEY_E,true)
	r=await sequence(false,mash)
	q.key(KEY_E,false);await q.wait_ticks(5)
	q.check(s.started==st+1 and c.request_count==before+1 and w.room==17,"E mashed throughout starts one sequence and one request")
	q.restored("E mashing")
	# 3. F6 reduced motion before start.
	await start()
	q.raw_key(KEY_F6,true);await q.wait_ticks(2);q.raw_key(KEY_F6,false);await q.wait_ticks(2)
	q.check(c.reduced,"F6 switched reduced motion on")
	before=c.request_count
	r=await sequence()
	q.key(KEY_E,false)
	q.check(r[0]>=0.85 and r[0]<=1.1,"Reduced (F6) completes in %.2f s (contract 0.95)"%r[0])
	q.check(r[1]==1.0 and s.last_result=="completed" and w.room==17,"Reduced (F6) no zoom, completed, in R17")
	q.restored("reduced F6 stair")
	c.reduced=false;w.embodied_transitions.comparison="art-preview"
	# 4. F6 mid-enter shortens, never extends, and still completes.
	await start()
	var f6=func(t):
		if t==12:
			q.raw_key(KEY_F6,true);await q.wait_ticks(1);q.raw_key(KEY_F6,false)
	r=await sequence(true,f6)
	q.key(KEY_E,false)
	q.check(r[0]<1.7 and s.last_result=="completed" and w.room==17,"F6 pressed mid-enter completes early (%.2f s) and arrives"%r[0])
	q.restored("F6 mid-enter")
	c.reduced=false;w.embodied_transitions.comparison="art-preview"
	# 5. Pause mid-enter, then resume: control must return, camera restored.
	await start()
	q.key(KEY_E,true);await q.wait_ticks(20);q.key(KEY_E,false)
	var phase_before=s.phase
	w.hud.toggle_pause();await q.wait_ticks(30)
	w.hud.toggle_pause();await q.wait_ticks(5)
	var n=0
	while n<420 and not controlled():
		await q.wait_ticks(1);n+=1
	q.check(phase_before=="enter" and controlled() and n<420,"Pause during enter then resume: control back after %d ticks (marker %s, room %d: sequence is aborted by pause, not resumed)"%[n,s.last_result,w.room])
	await q.wait_ticks(10)
	q.restored("pause mid-enter")
	# 6. Pause during the arrival phase.
	await start()
	q.key(KEY_E,true);await q.wait_ticks(1);q.key(KEY_E,false)
	n=0
	while n<400 and s.phase!="arrive":
		await q.wait_ticks(1);n+=1
	await q.wait_ticks(10)
	w.hud.toggle_pause();await q.wait_ticks(20);w.hud.toggle_pause();await q.wait_ticks(5)
	n=0
	while n<420 and not controlled():
		await q.wait_ticks(1);n+=1
	q.check(controlled() and n<420 and w.room==17,"Pause during arrival then resume: control back in R17 after %d ticks"%n)
	await q.wait_ticks(10)
	q.restored("pause mid-arrival")
	# 7. Death/respawn mid-sequence.
	await start()
	q.key(KEY_E,true);await q.wait_ticks(1);q.key(KEY_E,false);await q.wait_ticks(25)
	w.respawn();await q.wait_ticks(10)
	n=0
	while n<420 and not controlled():
		await q.wait_ticks(1);n+=1
	await q.wait_ticks(5)
	q.check(controlled() and w.player.hp>0 and w.player.sprite.visible and not s.proxy.visible,"Respawn mid-enter: control and live sprite restored (%d ticks)"%n)
	q.restored("respawn mid-enter")
	# 8. Locked stair never starts a sequence.
	await start()
	q.strip_abilities();w.message="";w.message_time=0
	before=c.request_count;st=s.started
	q.key(KEY_E,true);await q.wait_ticks(2);q.key(KEY_E,false);await q.wait_ticks(60)
	var locked=not w.can_enter(17)
	q.check(not locked or (s.started==st and w.room==14 and c.request_count==before and s.phase==""),"Gated R14->R17 (when locked) starts no sequence and keeps control; locked=%s message='%s'"%[locked,w.message])
	# 9. Reciprocal R17->R14 stair keeps the inherited presentation and completes.
	await start(false,0.0,17,14)
	before=c.request_count;st=s.started
	q.key(KEY_E,true);await q.wait_ticks(1);q.key(KEY_E,false);await q.wait_ticks(80)
	q.check(w.room==14 and s.started==st and c.request_count==before+1 and w.transition<=0,"R17->R14 stair is not staged and completes once")
	q.restored("R17->R14 inherited stair")
	# 10. Neighbouring lateral doorway with the flag on is untouched.
	await start(false,-180.0,13,14)
	before=c.request_count;st=s.started
	q.key(KEY_D,true)
	for t in 400:
		await q.wait_ticks(1)
		if c.request_count>before: break
	q.key(KEY_D,false);await q.wait_ticks(60)
	q.check(w.room==14 and s.started==st and c.request_count==before+1,"R13->R14 lateral passage unchanged with the flag on")
	q.restored("R13->R14 with flag")
	q.check(max_seen<=4.0,"No sequence exceeded the 4 s safety ceiling (max %.2f s)"%max_seen)

func run(qa):
	q=qa;w=qa.w;c=w.cinematic_transitions
	if not ("staged" in c) or c.staged==null:
		qa.skip("staged stair cinematic not present in this checkout (baseline or non-Transition candidate). Nothing verified. NOT a pass.")
		return
	s=c.staged
	if not s.enabled:
		await off_checks()
		qa.skip("full staged-stair checks not run in this process (flag --pm-staged-stair absent); the flagged process runs them")
		return
	await on_checks()
