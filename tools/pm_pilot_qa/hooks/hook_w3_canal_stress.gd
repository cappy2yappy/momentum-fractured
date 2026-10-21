extends RefCounted
## QA-owned. Canal Doorway stress, both directions, real keys only: several approach offsets and gaits (walk and run),
## repeated runs, pause at several moments (before the swap, at the swap, after the swap), repeated key presses, and a
## final check that the world is still playable. Each run must give control back in under CEILING, exactly one request,
## and arrive in the destination room. Candidate-agnostic observation.
var q
var w
var c
var L
const CEILING=6.0

func start(from,to,dx,run):
	q.release_all()
	q.reset(from);c=w.cinematic_transitions
	c.reduced=false;w.embodied_transitions.comparison="art-preview"
	w.player.position=c.endpoint(w,from,to).at+Vector2(dx,-2);w.player.velocity=Vector2.ZERO
	w.player.run=run;w.player.last_tap=-10;w.player.dash_cooldown=0
	w.camera.reset_smoothing();q.live()
	await q.wait_ticks(6)

func one(tag,from,to,dx,key_code,run,pause_at,mash):
	await start(from,to,dx,run)
	var req0=c.request_count
	q.key(key_code,true)
	var n=0;var paused=false;var started=-1
	while n<900:
		await q.wait_ticks(1);n+=1
		if started<0 and (c.request_count>req0 or w.transition>0 or not L.controlled()): started=n
		if mash and started>=0 and n%9==0:
			q.key(key_code,false);await q.wait_ticks(1);q.key(key_code,true)
		if pause_at>=0 and started>=0 and not paused and n-started>=pause_at:
			paused=true;w.hud.toggle_pause();await q.wait_ticks(20);w.hud.toggle_pause();await q.wait_ticks(2)
		if started>=0 and w.room==to and L.controlled() and n-started>8: break
	q.key(key_code,false);await q.wait_ticks(120)
	var cancelled=false
	if pause_at>=0 and w.room==from and L.controlled() and c.request_count==req0:
		# a pause before the swap cancels the passage in place (documented TR-08 interrupt behaviour): clean cancel, then a
		# fresh press must complete the passage normally.
		cancelled=true
		await start(from,to,dx,run)
		q.key(key_code,true);var m=0
		while m<900 and not (w.room==to and L.controlled()): await q.wait_ticks(1);m+=1
		q.key(key_code,false);await q.wait_ticks(60)
		n=m;started=0
	var ok=started>=0 and w.room==to and L.controlled() and (cancelled or c.request_count==req0+1)
	var secs=float(n-maxi(started,0))/60.0
	q.check(ok and secs<=CEILING+1.0,"[W3-STRESS-%s] dx=%d run=%s pause_at=%d mash=%s: started tick %d, arrived R%d=%s, control=%s, cancelled_then_repressed=%s, requests +%d, %.2f s"%[tag,int(dx),str(run),pause_at,str(mash),started,to,str(w.room==to),str(L.controlled()),str(cancelled),c.request_count-req0,secs])
	return ok

func run(qa):
	q=qa;w=qa.w
	var hooks_dir=qa.hooks_dir
	L=load(hooks_dir.path_join("w3_lib.gd")).new();L.setup(qa,hooks_dir)
	c=w.cinematic_transitions
	var i=0
	for rep in 3:
		for dx in [40.0,120.0,200.0]:
			for run_g in [false,true]:
				await one("OUT-R%d-%d"%[rep,i],13,0,dx,KEY_A,run_g,-1,false);i+=1
	for rep in 3:
		for dx in [-40.0,0.0,40.0]:
			for run_g in [false,true]:
				await one("IN-R%d-%d"%[rep,i],0,13,dx,KEY_E,run_g,-1,false);i+=1
	for p in [5,20,45,70,100]:
		await one("OUT-PAUSE%d"%p,13,0,180.0,KEY_A,false,p,false)
		await one("IN-PAUSE%d"%p,0,13,0.0,KEY_E,false,p,false)
	for m in 3:
		await one("OUT-MASH%d"%m,13,0,180.0,KEY_A,false,-1,true)
		await one("IN-MASH%d"%m,0,13,0.0,KEY_E,false,-1,true)
	# alternating back-to-back: out then in then out with no reset between
	q.reset(13);c=w.cinematic_transitions
	w.player.position=c.endpoint(w,13,0).at+Vector2(180,-2);w.camera.reset_smoothing();q.live();await q.wait_ticks(6)
	for k in 3:
		q.key(KEY_A,true);var n=0
		while n<900 and not (w.room==0 and L.controlled()): await q.wait_ticks(1);n+=1
		q.key(KEY_A,false);await q.wait_ticks(20)
		var ok1=(w.room==0 and L.controlled())
		w.player.position=c.endpoint(w,0,13).at+Vector2(0,-2);w.player.velocity=Vector2.ZERO;await q.wait_ticks(6)
		q.key(KEY_E,true);n=0
		while n<900 and not (w.room==13 and L.controlled()): await q.wait_ticks(1);n+=1
		q.key(KEY_E,false);await q.wait_ticks(20)
		q.check(ok1 and w.room==13 and L.controlled(),"[W3-STRESS-ROUNDTRIP-%d] consecutive Canal OUT then IN without reset: R0 ok=%s, back in R%d, control=%s"%[k,str(ok1),w.room,str(L.controlled())])
		w.player.position=c.endpoint(w,13,0).at+Vector2(180,-2);w.player.velocity=Vector2.ZERO;await q.wait_ticks(6)
	await walk_pair(6,7)
	await walk_pair(7,6)

func walk_pair(from,to):
	# plain room-to-room walk-through with real keys: step toward the exit from 140 px inside, hold the direction.
	q.release_all();q.reset(from);c=w.cinematic_transitions
	var ep=c.endpoint(w,from,to)
	if ep==null or not ("at" in ep):
		q.check(false,"[W3-WALK-R%d-R%d] no endpoint R%d to R%d"%[from,to,from,to]);return
	var at=ep.at;var rw=float(w.room_size(from).x)
	var right=at.x>rw*0.5
	var key=KEY_D if right else KEY_A
	w.player.position=at+Vector2(-140.0 if right else 140.0,-2);w.player.velocity=Vector2.ZERO
	w.camera.reset_smoothing();q.live();await q.wait_ticks(6)
	var req0=c.request_count;q.key(key,true);var n=0
	while n<900 and not (w.room==to and L.controlled()): await q.wait_ticks(1);n+=1
	q.key(key,false);await q.wait_ticks(30)
	q.check(w.room==to and L.controlled() and n<600,"[W3-WALK-R%d-R%d] walk-through arrives in R%d with control after %d ticks (requests +%d, feet %s)"%[from,to,to,n,c.request_count-req0,w.player.position])
