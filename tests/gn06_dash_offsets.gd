extends "res://tools/ld05/room_probe.gd"
## GN-06 extended regression (Transition). Real key events only. A Gale Dash across an
## automatic exit must open the transition exactly once and land supported, for many
## start offsets and dash timings, on the R6 -> R7 sill case and on every automatic exit.
## Run at several rates: --fixed-fps 30 / 60 / 144.
var cases = 0

func dash_case(index:int,start:Vector2,code:int,tap:int,tag:String) -> bool:
	await place(index,start)
	var c=w.cinematic_transitions
	var n=c.request_count
	key(code,true)
	for t in 360:
		if t==tap: key(KEY_SHIFT,true)
		if t==tap+1: key(KEY_SHIFT,false)
		await wait_ticks(1)
		if c.request_count>n: break
	release_all()
	var requested=c.request_count==n+1
	for t in 400:
		await wait_ticks(1)
		if not c.tr08.owns() and w.transition<=0: break
	# Momentum carry can keep her moving (and falling) after control returns: wait
	# (bounded) for a supported landing in the destination, as issue #42 does.
	for t in 180:
		if w.player.is_on_floor(): break
		await wait_ticks(1)
	var ok=requested and c.request_count==n+1 and w.room!=index and w.player.is_on_floor() and w.player.is_physics_processing()
	cases+=1
	if not ok: print("GN06 MISS ",tag," start=",start," tap=",tap," room=",w.room," feet=",w.player.position," req=",c.request_count-n)
	return ok

func run():
	await process_frame
	w = load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene = w
	freeze();seed_fixture();automation_hud()
	print("GN06 fps=",Engine.max_fps," physics=",Engine.physics_ticks_per_second," time_scale=",Engine.time_scale)
	# 1. R6 -> R7 sill: floor y 1110 under the (2440,1090) endpoint, many offsets and taps.
	var r6_ok=0;var r6_n=0
	for x in range(2140,2421,20):
		for tap in [0,2,4,6,8,10,14]:
			r6_n+=1
			if await dash_case(6,Vector2(x,1108),KEY_D,tap,"r6"): r6_ok+=1
	check(r6_ok==r6_n,"R6 -> R7: dash across the sill requests R7 once and lands supported (%d of %d)"%[r6_ok,r6_n])
	# Walking and sprinting across the same sill still work (no change in behaviour).
	await place(6,Vector2(2300,1108));var c=w.cinematic_transitions;var n=c.request_count
	key(KEY_D,true)
	for t in 200:
		await wait_ticks(1)
		if c.request_count>n: break
	release_all()
	check(c.request_count==n+1,"R6 -> R7: plain walk still requests once")
	await wait_ticks(80)
	# 2. Every automatic exit: dash approach from its real arrival point (64 px inward on the
	# reviewed shelf; further inward is not always the same supported floor, e.g. R5).
	var all_ok=0;var all_n=0;var misses=[]
	for index in 21:
		for p in c.endpoints(w,index):
			if p.mode!="horizontal_walk": continue
			var dir=int(p.heading)
			var start=c.arrival_position(w,p)
			for tap in [0,1,2,3]:
				all_n+=1
				if await dash_case(index,start,KEY_A if dir<0 else KEY_D,tap,"%d->%d"%[index,p.target]): all_ok+=1
				else: misses.append("%d->%d tap%d"%[index,p.target,tap])
	check(all_ok==all_n,"Every automatic exit opens on a dash approach (%d of %d) %s"%[all_ok,all_n,misses])
	# 3. Arming band never opens a stationary or reversed approach.
	await place(6,Vector2(2380,1108));n=c.request_count
	await wait_ticks(120)
	check(c.request_count==n,"R6: standing on the lower floor inward of the sill never requests")
	key(KEY_A,true);await wait_ticks(30);key(KEY_A,false);await wait_ticks(20)
	check(c.request_count==n and w.room==6,"R6: walking away from the exit never requests")
	print("GN06 cases=",cases)
	w.queue_free();current_scene = null
	for i in 3: await process_frame
	print("GN06 DASH OFFSETS: %d checks, %d failure(s)" % [checks,failures])
	quit(1 if failures else 0)
