extends "res://tests/native_cinematic_transitions.gd"
## PM pilot (TRANSITION): staged R14 -> R17 stair cinematic. Live physics frames and
## real InputEventKey E presses; endpoint/ability fixtures only establish the start.
## Run with: -- --pm-staged-stair   (the pilot is opt-in; see docs/pm_pilot/transition).
const Data = preload("res://scripts/transition_pilot_data.gd")
var s
var c
var press_frame=0

func start(still=false,offset=-30.0):
	for code in [KEY_A,KEY_D,KEY_SPACE,KEY_E]: key(code,false)
	reset(14);c=w.cinematic_transitions;s=c.staged
	c.reduced=still;w.embodied_transitions.comparison="reduced" if still else "art-preview"
	w.player.position=c.endpoint(w,14,17).at+Vector2(offset,-2);w.player.velocity=Vector2.ZERO
	w.camera.reset_smoothing();live()
	await wait_ticks(6)

func press_e():
	press_frame=Engine.get_physics_frames()
	key(KEY_E,true);await wait_ticks(1);key(KEY_E,false)
	# The just-pressed edge is consumed on the next world tick; settle on it.
	for i in 2:
		if w.transition>0 or (s and s.phase!=""): break
		await wait_ticks(1)

func controlled() -> bool:
	return s.phase=="" and w.transition<=0 and w.player.is_physics_processing()

func camera_restored() -> bool:
	return w.camera.zoom==Vector2.ONE and w.camera.position==Vector2(0,-110) and w.camera.offset==Vector2.ZERO and w.camera.position_smoothing_enabled

## Runs until control returns; returns [ticks, max zoom, phases seen, body moved].
func run_sequence(extra=null):
	var ticks=0;var zoom=1.0;var phases=[];var feet=w.player.position;var moved=false
	while ticks<400:
		await wait_ticks(1);ticks+=1
		if s.phase!="" and not s.phase in phases: phases.append(s.phase)
		zoom=maxf(zoom,w.camera.zoom.x)
		if s.phase=="enter" and w.player.position!=feet: moved=true
		if extra: extra.call(ticks)
		if controlled() and ticks>2: break
	return [ticks,zoom,phases,moved]

func poke(t):
	if t%7==0: w.interact()

func run():
	await process_frame
	w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w;freeze();seed_fixture()
	output="res://build/pm_pilot/transition"
	DirAccess.make_dir_recursive_absolute(output)
	c=w.cinematic_transitions;s=c.staged
	check(s.enabled and Data.STAGED_STAIR.flag in OS.get_cmdline_user_args(),"Staged stair pilot enabled only by its explicit flag")
	check(Data.STAGED_STAIR.pairs==["14:17"],"Exactly one meaningful entrance is staged: R14->R17")
	# 1. Full cinematic through real E.
	await start()
	var before=c.request_count
	press_frame=Engine.get_physics_frames()
	key(KEY_E,true) # held through the whole sequence and beyond
	for i in 3:
		await wait_ticks(1)
		if s.phase!="": break
	check(s.phase=="enter" and w.transition==0 and not w.player.is_physics_processing(),"E starts the enter phase before the inherited loader")
	check(not w.player.sprite.visible and s.proxy.visible,"Render proxy replaces live sprite during staging")
	var start_proxy=s.proxy.position
	await wait_ticks(30)
	check(s.proxy.position.distance_to(start_proxy)>25 and s.proxy.position.y<start_proxy.y,"Enter phase visibly climbs the R14 flight (render only)")
	check(w.camera.zoom.x>1.2,"Enter phase frames a close-up")
	check("FULL GAIT PENDING" in s.placeholder,"Held ART-04 key is labelled FULL GAIT PENDING: "+s.placeholder)
	var result=await run_sequence()
	var seconds=(Engine.get_physics_frames()-press_frame)/60.0
	print("STAGED duration_s=",seconds," phases=",result[2]," max_zoom=",result[1]," last=",s.last_result," last_duration=",s.last_duration)
	check(seconds>=2.0 and seconds<=3.0,"Cinematic completes in 2-3 s from the E press (%.2f s)"%seconds)
	check(s.last_duration>=2.0 and s.last_duration<=3.0,"Sequence clock reports 2-3 s (%.2f s)"%s.last_duration)
	check(result[2]==["load","arrive"] or result[2]==["enter","load","arrive"],"Phases run enter -> load -> arrive: %s"%[result[2]])
	check(s.last_result=="completed" and s.completed==1 and s.aborted==0,"Sequence reports completion")
	check(w.room==17 and c.request_count==before+1,"Exactly one room request reaches R17")
	check(not result[3],"Collision body never driven during enter staging")
	check(w.player.position==Vector2(1680,1298),"Arrival feet are the unchanged reciprocal endpoint")
	check(w.player.sprite.visible and not s.proxy.visible and not w.embodied_transitions.proxy.visible,"Live Kaze restored, proxies hidden")
	check(camera_restored(),"Camera fully restored after the sequence")
	await wait_ticks(10)
	check(w.player.is_on_floor(),"Control restored on supported landing")
	# E has been held since the press: arrival must not bounce back.
	await wait_ticks(100);key(KEY_E,false);await wait_ticks(5)
	check(w.room==17 and c.request_count==before+1 and s.started==1,"E held through the sequence and 100 ticks after arrival cannot loop")
	# 2. No double trigger: repeated real E presses and direct interact calls.
	await start()
	before=c.request_count;var started=s.started
	await press_e()
	for i in 4:
		await wait_ticks(4);await press_e();w.interact()
	result=await run_sequence(poke)
	check(s.started==started+1 and c.request_count==before+1 and w.room==17,"Repeated E during the sequence never double-triggers")
	# 3. Reduced motion: shortened, static, no zoom.
	await start(true)
	await press_e()
	var still_pos=s.proxy.position
	await wait_ticks(5)
	check(s.proxy.position==still_pos,"Reduced motion holds the proxy still")
	result=await run_sequence()
	seconds=(Engine.get_physics_frames()-press_frame)/60.0
	print("REDUCED duration_s=",seconds," max_zoom=",result[1])
	check(seconds<=1.1 and w.room==17 and s.last_result=="completed","Reduced motion shortens the sequence (%.2f s) and still arrives"%seconds)
	check(result[1]==1.0 and camera_restored(),"Reduced motion never zooms the camera")
	c.reduced=false
	# 4. F6 mid-enter shortens the remaining staging and restores the camera at once.
	await start()
	await press_e();await wait_ticks(10)
	var f6=InputEventKey.new();f6.physical_keycode=KEY_F6;f6.pressed=true
	c._unhandled_key_input(f6)
	check(c.reduced and w.camera.zoom==Vector2.ONE,"F6 during enter switches to reduced and restores framing")
	result=await run_sequence()
	seconds=(Engine.get_physics_frames()-press_frame)/60.0
	check(w.room==17 and s.last_result=="completed" and seconds<1.4 and camera_restored(),"F6 mid-sequence completes sooner (%.2f s)"%seconds)
	c._unhandled_key_input(f6)
	check(not c.reduced,"F6 toggles back to cinematic motion")
	# 5. Interruptions: control always returns, no stuck state.
	for when in ["enter","load","arrive"]:
		for reason in ["pause","death","rebuild"]:
			await start()
			await press_e()
			var guard=0
			while s.phase!=when and guard<300:
				await wait_ticks(1);guard+=1
			if when!="enter": await wait_ticks(3)
			if reason=="pause":
				paused=true;await process_frame;await process_frame;paused=false
			elif reason=="death":
				w.checkpoint_room=14;w.checkpoint_position=Vector2(1300,478)
				w.player.hp=0;w.on_hurt()
			else:
				w.build_room(14 if when=="enter" else 17)
			var waited=0
			while not controlled() and waited<240:
				await wait_ticks(1);waited+=1
			await wait_ticks(20)
			print("INTERRUPT when=",when," reason=",reason," room=",w.room," result=",s.last_result," waited=",waited)
			check(controlled() and w.player.sprite.visible and not s.proxy.visible and camera_restored(),"Control restored after %s during %s"%[reason,when])
			check(w.room in [14,17] and w.player.is_on_floor(),"Supported and in a valid room after %s during %s (R%d)"%[reason,when,w.room])
			if reason=="pause" and when=="enter": check(w.room==14,"Pause during enter aborts in place without a room change")
			if reason=="pause" and when=="load": check(w.room==17,"Pause during the loader keeps the inherited loader outcome")
			w.player.hp=3
	# After an aborted sequence, a fresh E press still works.
	await start();await press_e();await wait_ticks(10)
	paused=true;await process_frame;paused=false
	await wait_ticks(5)
	await press_e()
	await run_sequence()
	check(w.room==17 and s.last_result=="completed","A new E press after an abort runs the full sequence")
	# 6. Watchdog ceiling.
	await start();await press_e();await wait_ticks(2)
	s.arrive_time=30.0
	result=await run_sequence()
	check(controlled() and s.last_result=="watchdog" and s.last_duration<=Data.STAGED_STAIR.watchdog+0.05,"Watchdog returns control within %.1f s"%Data.STAGED_STAIR.watchdog)
	# 7. Unstaged entrances keep their existing behavior.
	reset(17);c=w.cinematic_transitions;w.player.position=Vector2(1680,1298);live();await wait_ticks(4)
	await press_e()
	check(w.transition>0.6 and s.phase=="","R17->R14 keeps the inherited immediate E loader")
	await wait_ticks(50)
	await start();c.plain=true;await press_e()
	check(w.transition>0.6 and s.phase=="","Plain mode bypasses staging")
	c.plain=false;await wait_ticks(50)
	reset(0);w.player.position=Vector2(590,778);live();await wait_ticks(3);await press_e()
	check(w.pending_room==13 and s.phase=="","R0->R13 depth door untouched by the pilot")
	await wait_ticks(50)
	w.queue_free();current_scene=null
	for i in 3: await process_frame
	print("PM STAGED STAIR: %d checks, %d failure(s)"%[checks,failures]);quit(1 if failures else 0)
