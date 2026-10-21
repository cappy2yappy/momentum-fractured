extends "res://tests/native_cinematic_transitions.gd"
## TR-08: full-screen staircase cinematic (R14 <-> R17) and embodied Canal doorway
## (R13 left exit <-> R0). Live physics frames and real InputEventKey presses; endpoint and
## ability fixtures only establish the start. Run: -- --test   (default build, TR-08 on).
## With -- --test --tr08-off the suite instead checks that the PR61 behaviour is restored.
const Data = preload("res://scripts/transition_pilot_data.gd")
const Library = preload("res://scripts/tr08_clip_library.gd")
var c
var t8
var press_frame = 0

func setup(index:int,feet:Vector2,still:=false):
	for code in [KEY_A,KEY_D,KEY_SPACE,KEY_E,KEY_SHIFT]: key(code,false)
	reset(index);c=w.cinematic_transitions;t8=c.tr08
	c.reduced=still;t8.reduced=still
	w.embodied_transitions.comparison="reduced" if still else "art-preview"
	w.player.position=feet;w.player.velocity=Vector2.ZERO;w.message_time=0
	w.camera.reset_smoothing();live()
	await wait_ticks(8)

func press(code:=KEY_E):
	press_frame=Engine.get_physics_frames()
	key(code,true);await wait_ticks(1);key(code,false)
	for i in 3:
		if t8.owns() or w.transition>0: break
		await wait_ticks(1)

func seconds() -> float:
	return (Engine.get_physics_frames()-press_frame)/60.0

func controlled() -> bool:
	return not t8.owns() and w.transition<=0 and w.player.is_physics_processing()

func camera_untouched() -> bool:
	return w.camera.zoom==Vector2.ONE and w.camera.position==Vector2(0,-110) and w.camera.offset==Vector2.ZERO and w.camera.position_smoothing_enabled

## Waits until control returns. Records phases, stage feet extremes and stage framing.
func until_control(limit:=420,extra=null) -> Dictionary:
	var info={"ticks":0,"phases":[],"min_y":INF,"max_y":-INF,"zooms":[],"stage_pos":[],"frames":[],"body_moved":false,"layer_seen":false,"label":""}
	var body=w.player.position
	var start_room=w.room
	while info.ticks<limit:
		await wait_ticks(1);info.ticks+=1
		var p=t8.phase()
		if p!="" and not p in info.phases: info.phases.append(p)
		if t8.stair.phase=="climb":
			info.min_y=minf(info.min_y,t8.stair.feet.y);info.max_y=maxf(info.max_y,t8.stair.feet.y)
			info.zooms.append(t8.stair.zoom);info.stage_pos.append(t8.stair.stage.position)
			info.frames.append(t8.stair.kaze.frame)
			if t8.stair.layer.visible: info.layer_seen=true
			if t8.stair.kaze.is_standin(): info.label=t8.stair.kaze.status()
		if t8.canal.phase!="":
			info.frames.append(t8.canal.kaze.frame)
			if t8.canal.kaze.is_standin(): info.label=t8.canal.kaze.status()
		if w.room==start_room and t8.owns() and w.player.position!=body: info.body_moved=true
		if extra: await extra.call(info.ticks)
		if controlled() and info.ticks>2: break
	return info

func run():
	await process_frame
	w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w;freeze();seed_fixture()
	c=w.cinematic_transitions;t8=c.tr08
	if "--tr08-off" in OS.get_cmdline_user_args():
		await legacy_mode()
	else:
		bindings()
		await stair_suite()
		await canal_suite()
		await unchanged_suite()
	w.queue_free();current_scene=null
	for i in 3: await process_frame
	print("TR08: %d checks, %d failure(s)"%[checks,failures]);quit(1 if failures else 0)

## Manifest-driven clip table: stand-ins labelled, swaps by file path, hard rules.
func bindings():
	check(t8.enabled,"TR-08 is the default presentation (no flag needed)")
	for name in Library.CLIPS:
		var clip=t8.table[name]
		check(clip.texture!=null and clip.frames.size()>=1 and clip.fps>0,"Clip %s resolves to a playable strip"%name)
		if clip.bound=="art08-standin":
			check(clip.label==Library.STANDIN_LABEL and clip.frames.size()>=2,"ART-08 stand-in clip %s binds but stays labelled stand-in"%name)
		elif clip.bound!="art08":
			check("STAND-IN" in clip.provenance and clip.label==Library.STANDIN_LABEL,"Unbound clip %s is labelled stand-in"%name)
		else:
			check(clip.frames.size()>=2 and not clip.provenance.to_lower() in Library.NOT_ANIMATION,"Bound clip %s is multi-frame ART-08 animation"%name)
	var path="user://tr08_test_manifest.json"
	var f=FileAccess.open(path,FileAccess.WRITE)
	f.store_string(JSON.stringify({"cell":[272,724],"pivot":[136,491],"clips":[
		{"name":"stair_ascend_loop","strip":"assets/kaze/cleaned/kaze_run_strip.png","hframes":8,"cell":[272,724],"pivot":[136,491],"fps":14,"loop":true,"facing":"right","root_motion_px_per_frame":[26,-13],"provenance":"authored drawing"},
		{"name":"stair_descend_loop","strip":"assets/kaze/cleaned/kaze_run_strip.png","hframes":8,"fps":14,"provenance":"held"},
		{"name":"door_cross","strip":"assets/art08/does_not_exist_strip.png","hframes":8,"fps":12,"provenance":"authored drawing"},
		{"name":"door_emerge","strip":"assets/art04/kaze/enter_depth_key.png","hframes":1,"fps":12,"provenance":"authored drawing"},
		{"name":"door_turn_to_side","strip":"assets/kaze/cleaned/kaze_idle_strip.png","hframes":8,"fps":12,"provenance":"cut-out rig","status":"unfinished"},
		{"name":"door_turn_to_rear","strip":"assets/kaze/cleaned/kaze_idle_strip.png","hframes":8,"fps":16,"provenance":"reused frames","status":"stand_in"}]}))
	f.close()
	var table=Library.build(path)
	check(table.stair_ascend_loop.bound=="art08" and table.stair_ascend_loop.strip=="res://assets/kaze/cleaned/kaze_run_strip.png","A valid manifest row binds by file path")
	check(table.stair_ascend_loop.root_motion.size()==8 and table.stair_ascend_loop.root_motion[3]==Vector2(26,-13),"Manifest root motion drives the bound clip")
	check(table.stair_descend_loop.bound=="stand-in" and "not animation" in table.stair_descend_loop.rejected,"A held clip is never bound as animation")
	check(table.door_cross.bound=="stand-in" and "not in this checkout" in table.door_cross.rejected,"A missing strip falls back to the labelled stand-in")
	check(table.door_emerge.bound=="stand-in" and "fewer than 2" in table.door_emerge.rejected,"A single-frame strip is rejected")
	check(table.door_turn_to_side.bound=="stand-in" and "unfinished" in table.door_turn_to_side.rejected,"A clip with status unfinished never binds")
	check(table.door_turn_to_rear.bound=="art08-standin" and table.door_turn_to_rear.label==Library.STANDIN_LABEL,"An ART-08 stand_in clip binds by path but keeps the STAND-IN label")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	var empty=Library.build("res://does/not/exist.json")
	check(Library.summary(empty).filter(func(r): return r.bound=="art08").is_empty(),"Without a manifest every clip is a labelled stand-in")

func stair_case(index:int,target:int,feet:Vector2,still:bool) -> Dictionary:
	await setup(index,feet,still)
	var before=c.request_count;var started=t8.stair.started
	await press()
	var tag="%d->%d%s"%[index,target," reduced" if still else ""]
	check(t8.stair.phase=="open" and w.transition==0 and not w.player.is_physics_processing(),"Stair %s: real E opens the full-screen stage before the loader"%tag)
	check(t8.stair.layer.visible and t8.stair.layer.layer>1,"Stair %s: stage is a full-screen layer above the HUD"%tag)
	var info=await until_control()
	var s=seconds()
	print("TR08 STAIR ",tag," seconds=",s," result=",t8.stair.last_result," phases=",info.phases," shown=",t8.stair.shown)
	if still:
		check(s<=1.6,"Stair %s: reduced motion is short (%.2f s)"%[tag,s])
		var fixed=true
		for z in info.zooms: fixed=fixed and z==1.0
		for p in info.stage_pos: fixed=fixed and p==info.stage_pos[0]
		check(fixed and info.zooms.size()>5,"Stair %s: reduced motion has no camera zoom or pan"%tag)
	else:
		check(s>=2.5 and s<=4.0,"Stair %s: cinematic lasts 2.5 to 4 s (%.2f s)"%[tag,s])
		check(info.zooms.max()>1.0 and info.stage_pos[0]!=info.stage_pos[-1],"Stair %s: stage camera follows the climb"%tag)
	var distinct={};for fr in info.frames: distinct[fr]=true
	check(distinct.size()>=4,"Stair %s: clip frames advance (not a held pose), %d distinct"%[tag,distinct.size()])
	var travel=info.max_y-info.min_y
	check(travel>100,"Stair %s: Kaze travels the flight on stage (%.0f px of rise)"%[tag,travel])
	var last=t8.stair.path[t8.stair.path.size()-1]
	check(signf(last.y)==float(t8.stair.rise),"Stair %s: travel follows the authored direction (%s)"%[tag,"up" if t8.stair.rise<0 else "down"])
	check(t8.stair.kaze.base_scale*float(t8.stair.kaze.clip.figure)>=360,"Stair %s: Kaze at cinematic scale (>=50 percent of the screen)"%tag)
	check(t8.stair.last_result=="completed" and t8.stair.started==started+1,"Stair %s: sequence completes"%tag)
	check(w.room==target and c.request_count==before+1,"Stair %s: exactly one room request"%tag)
	check(not info.body_moved,"Stair %s: collision body never driven before the swap"%tag)
	var expected=c.endpoint(w,target,index).at-Vector2(0,2)
	check(w.player.position==expected,"Stair %s: arrival feet are the unchanged reciprocal endpoint %s"%[tag,expected])
	check(w.player.sprite.visible and not t8.stair.layer.visible and not w.embodied_transitions.proxy.visible,"Stair %s: live Kaze restored, stage hidden"%tag)
	check(camera_untouched(),"Stair %s: world camera untouched"%tag)
	await wait_ticks(10)
	check(w.player.is_on_floor() and w.player.is_physics_processing(),"Stair %s: control restored on a supported landing"%tag)
	return info

func stair_suite():
	var bindings_standin=t8.table.stair_ascend_loop.bound!="art08"
	for still in [false,true]:
		var info=await stair_case(14,17,Vector2(1420,478),still)
		if bindings_standin: check(Library.STANDIN_LABEL in info.label,"Stand-in stair clip is visibly labelled on screen")
		await stair_case(17,14,Vector2(1650,1298),still)
	c.reduced=false;t8.reduced=false
	# E held through the whole sequence and 100 ticks after: no loop back.
	await setup(14,Vector2(1420,478))
	var before=c.request_count
	press_frame=Engine.get_physics_frames();key(KEY_E,true)
	await until_control()
	await wait_ticks(100);key(KEY_E,false);await wait_ticks(5)
	check(w.room==17 and c.request_count==before+1,"Stair: E held through the cinematic and 100 ticks after cannot loop")
	# No double trigger: repeated real E presses and direct interact calls.
	await setup(14,Vector2(1420,478))
	before=c.request_count;var started=t8.stair.started
	await press()
	await until_control(420,func(t):
		if t%9==0:
			key(KEY_E,true);await wait_ticks(1);key(KEY_E,false);w.interact())
	check(t8.stair.started==started+1 and c.request_count==before+1 and w.room==17,"Stair: repeated E during the cinematic never double-triggers")
	# F6 mid-climb: reduced motion takes over, shortens and freezes the stage camera.
	await setup(14,Vector2(1420,478))
	await press()
	while t8.stair.phase!="climb": await wait_ticks(1)
	await wait_ticks(12)
	var f6=InputEventKey.new();f6.physical_keycode=KEY_F6;f6.pressed=true
	c._unhandled_key_input(f6)
	var pos=t8.stair.stage.position;await wait_ticks(3)
	check(c.reduced and t8.stair.still and t8.stair.stage.position==pos and t8.stair.zoom==1.0,"Stair: F6 mid-climb freezes framing at once")
	await until_control()
	check(w.room==17 and t8.stair.last_result=="completed" and seconds()<2.6,"Stair: F6 mid-sequence completes sooner (%.2f s)"%seconds())
	c._unhandled_key_input(f6)
	check(not c.reduced,"F6 toggles back to cinematic motion")
	# Interruptions: control always returns in a valid supported room.
	for when in ["open","climb_before_swap","climb_after_swap","close"]:
		for reason in ["pause","death","rebuild"]:
			await setup(14,Vector2(1420,478))
			await press()
			var guard=0
			while guard<300:
				var s=t8.stair
				var ok=(when=="open" and s.phase=="open") or (when=="climb_before_swap" and s.phase=="climb" and s.swap_time<0) or (when=="climb_after_swap" and s.phase=="climb" and s.swap_time>=0 and w.transition<=0) or (when=="close" and s.phase=="close")
				if ok: break
				await wait_ticks(1);guard+=1
			var reached=t8.stair.phase!=""
			if reason=="pause":
				paused=true;await process_frame;await process_frame;paused=false
			elif reason=="death":
				w.checkpoint_room=14;w.checkpoint_position=Vector2(1300,478);w.player.hp=0;w.on_hurt()
			else: w.build_room(17 if w.room==17 else 14)
			var waited=0
			while not controlled() and waited<240:
				await wait_ticks(1);waited+=1
			await wait_ticks(20)
			print("TR08 STAIR INTERRUPT when=",when," reason=",reason," reached=",reached," room=",w.room," result=",t8.stair.last_result)
			check(reached and controlled() and w.player.sprite.visible and not t8.stair.layer.visible and camera_untouched(),"Stair: control restored after %s during %s"%[reason,when])
			check(w.room in [14,17] and w.player.is_on_floor(),"Stair: supported in a valid room after %s during %s (R%d)"%[reason,when,w.room])
			w.player.hp=3
	# A fresh E press after an abort runs the full sequence.
	await setup(14,Vector2(1420,478));await press();await wait_ticks(6)
	paused=true;await process_frame;paused=false;await wait_ticks(5)
	await press();await until_control()
	check(w.room==17 and t8.stair.last_result=="completed","Stair: a new E press after an abort runs the full sequence")
	# Watchdog: an overlong queue still returns control.
	await setup(14,Vector2(1420,478));await press();await wait_ticks(2)
	for i in 40: t8.stair.queue.insert(0,"stair_ascend_loop")
	await until_control(600)
	check(controlled() and t8.stair.last_result=="watchdog" and t8.stair.last_duration<=Data.TR08.stair.watchdog+0.05,"Stair: watchdog returns control within %.1f s"%Data.TR08.stair.watchdog)
	# Locked stair keeps its specific gate hint and never opens the stage.
	await setup(14,Vector2(1420,478));w.player.dash_unlocked=false;w.message=""
	before=c.request_count;await press();await wait_ticks(10)
	check(t8.stair.phase=="" and w.transition==0 and c.request_count==before and w.room==14,"Stair: locked climb gate never starts the cinematic")
	check(w.message=="Route sealed: CLIMB. Consult the atlas.","Stair: locked gate keeps its specific hint: "+w.message)
	await setup(17,Vector2(1650,1298));w.player.tether_unlocked=false;w.message=""
	await press();await wait_ticks(10)
	check(t8.stair.phase=="" and w.room==17 and w.message=="Route sealed: CLIMB. Consult the atlas.","Stair: locked descent keeps its specific hint")
	# Out of E range: nothing starts.
	await setup(14,Vector2(1300,478));before=c.request_count;await press();await wait_ticks(10)
	check(t8.stair.phase=="" and c.request_count==before,"Stair: E outside the 85 px stair radius does nothing")

func canal_case(start_room:int,feet:Vector2,code:int,hold:bool,still:bool) -> Dictionary:
	await setup(start_room,feet,still)
	var target=0 if start_room==13 else 13
	var before=c.request_count;var started=t8.canal.started
	press_frame=Engine.get_physics_frames()
	key(code,true)
	if not hold: await wait_ticks(1);key(code,false)
	var guard=0
	while not t8.owns() and guard<240:
		await wait_ticks(1);guard+=1
	key(code,false)
	var tag="%d->%d%s"%[start_room,target," reduced" if still else ""]
	var trigger_x=w.player.position.x
	check(t8.canal.phase!="" and w.transition==0 and c.request_count==before,"Canal %s: passage starts embodied, loader not yet requested"%tag)
	if start_room==13: check(trigger_x<=Data.CANAL_LEFT.trigger_x and trigger_x>=Data.CANAL_LEFT.leftmost_feet_x-0.5,"Canal %s: starts at the unchanged x=120 trigger (feet x %.1f)"%[tag,trigger_x])
	var info=await until_control()
	var s=seconds()
	print("TR08 CANAL ",tag," seconds=",s," result=",t8.canal.last_result," phases=",info.phases," shown=",t8.canal.shown)
	var names=[];for row in t8.canal.shown: names.append(row[1])
	check("door_turn_to_rear" in names and "door_cross" in names and "door_emerge" in names and "door_turn_to_side" in names,"Canal %s: turn, cross, emerge and turn-out all play: %s"%[tag,names])
	if start_room==0: check("door_walk_out" in names,"Canal %s: Kaze walks out of the Canal opening to the arrival point"%tag)
	check(t8.canal.last_result=="completed" and t8.canal.started==started+1,"Canal %s: sequence completes"%tag)
	check(w.room==target and c.request_count==before+1,"Canal %s: exactly one room request"%tag)
	check(s<=(2.6 if still else 4.0) and s>=(0.6 if still else 1.2),"Canal %s: duration within bounds (%.2f s)"%[tag,s])
	var distinct={};for fr in info.frames: distinct[fr]=true
	check(distinct.size()>=3,"Canal %s: frames advance through the passage (%d distinct)"%[tag,distinct.size()])
	check(not info.body_moved,"Canal %s: collision body never driven before the swap"%tag)
	if target==13:
		var expected=c.arrival_position(w,c.endpoint(w,13,0))
		check(w.player.position==expected and w.player.facing==1,"Canal %s: arrival is the unchanged inward point %s facing away from the door"%[tag,expected])
	else:
		check(w.player.position==Vector2(590,778),"Canal %s: arrival is the unchanged R0 door point"%tag)
	check(w.player.sprite.visible and not t8.canal.layer.visible and not w.embodied_transitions.proxy.visible,"Canal %s: live Kaze restored, doorway layer hidden"%tag)
	await wait_ticks(10)
	check(w.player.is_on_floor() and w.player.is_physics_processing() and w.player.velocity.x==0,"Canal %s: control restored standing on a supported floor"%tag)
	return info

func canal_suite():
	var info=await canal_case(13,Vector2(190,1198),KEY_A,true,false)
	if t8.table.door_cross.bound!="art08": check(Library.STANDIN_LABEL in info.label,"Stand-in door clip is visibly labelled")
	await canal_case(0,Vector2(630,778),KEY_E,false,false)
	await canal_case(0,Vector2(560,778),KEY_E,false,false)
	await canal_case(13,Vector2(190,1198),KEY_A,true,true)
	await canal_case(0,Vector2(630,778),KEY_E,false,true)
	c.reduced=false;t8.reduced=false
	# Held direction through the passage and after: no arrival loop (R0 has no left exit).
	await setup(13,Vector2(190,1198))
	var before=c.request_count
	key(KEY_A,true)
	await until_control(300)
	await wait_ticks(100);key(KEY_A,false);await wait_ticks(5)
	check(w.room==0 and c.request_count==before+1,"Canal: held direction through the passage causes no arrival loop")
	# Arrival in R13 then immediate reverse through the same door works once (stop/reverse).
	await setup(0,Vector2(600,778));before=c.request_count
	await press();await until_control()
	key(KEY_A,true)
	var guard=0
	while not t8.owns() and guard<200:
		await wait_ticks(1);guard+=1
	key(KEY_A,false)
	await until_control()
	check(w.room==0 and c.request_count==before+2,"Canal: stop and reverse back through the opening succeeds once")
	# Stop before the threshold and reverse: nothing starts.
	await setup(13,Vector2(260,1198));before=c.request_count
	key(KEY_A,true);await wait_ticks(10);key(KEY_A,false);await wait_ticks(30)
	key(KEY_D,true);await wait_ticks(20);key(KEY_D,false);await wait_ticks(10)
	check(t8.canal.phase=="" and c.request_count==before and w.room==13,"Canal: stopping short and reversing never starts the passage")
	# Wrong direction: walking right out of the hallway never triggers the left exit.
	await setup(13,Vector2(100,1198));before=c.request_count
	key(KEY_D,true);await wait_ticks(40);key(KEY_D,false);await wait_ticks(10)
	check(t8.canal.phase=="" and c.request_count==before,"Canal: wrong-direction walk away from the door does not trigger")
	# Locked Windstep: the authored hint stays and nothing is staged.
	await setup(13,Vector2(190,1198));w.player.double_jump=false;w.message=""
	key(KEY_A,true);await wait_ticks(60);key(KEY_A,false);await wait_ticks(5)
	check(t8.canal.phase=="" and w.room==13 and w.transition==0,"Canal: locked Windstep gate never starts the passage")
	check(w.message=="Route sealed: WINDSTEP. Consult the atlas.","Canal: locked gate keeps its specific hint: "+w.message)
	await setup(0,Vector2(600,778));w.player.double_jump=false;w.message=""
	await press();await wait_ticks(10)
	check(t8.canal.phase=="" and w.room==0 and w.message=="Route sealed: WINDSTEP. Consult the atlas.","Canal: locked R0 door keeps its specific hint")
	# Airborne crossing just after leaving the floor (TR08 hang fix 2): the live body lands
	# under unchanged physics, then the embodied passage plays; no counterfeit footsteps.
	await setup(13,Vector2(300,1198));before=c.request_count
	var landed_before=t8.canal.landing_started
	key(KEY_A,true)
	var jumped=false
	for tick in 120:
		if not jumped and w.player.position.x<=160: key(KEY_SPACE,true);jumped=true
		await wait_ticks(1)
		if c.request_count>before or t8.owns(): break
	key(KEY_SPACE,false)
	var airborne=not w.player.is_on_floor()
	print("TR08 CANAL AIRBORNE airborne=",airborne," phase=",t8.phase()," requests=",c.request_count-before)
	if airborne: check(t8.canal.phase=="land" and c.request_count==before and w.player.is_physics_processing() and w.player.sprite.visible,"Canal: an airborne crossing lets the live body land first (physics on, no proxy)")
	key(KEY_A,false)
	for tick in 400:
		await wait_ticks(1)
		if controlled() and w.room==0: break
	check(w.room==0 and controlled() and c.request_count==before+1,"Canal: airborne approach reaches R0 with control, one request")
	if airborne: check(t8.canal.landing_started==landed_before+1 and t8.canal.last_result=="completed","Canal: after landing the embodied passage completes")
	# Interruptions.
	for when in ["turn","cross","emerge","turn_out"]:
		for reason in ["pause","death","rebuild"]:
			await setup(13,Vector2(190,1198))
			key(KEY_A,true)
			var g=0
			while t8.canal.phase!=when and g<300:
				await wait_ticks(1);g+=1
				if t8.owns(): key(KEY_A,false)
			key(KEY_A,false)
			var reached=t8.canal.phase==when
			if reason=="pause":
				paused=true;await process_frame;await process_frame;paused=false
			elif reason=="death":
				w.checkpoint_room=13;w.checkpoint_position=Vector2(330,1158);w.player.hp=0;w.on_hurt()
			else: w.build_room(w.room)
			var waited=0
			while not controlled() and waited<240:
				await wait_ticks(1);waited+=1
			await wait_ticks(20)
			print("TR08 CANAL INTERRUPT when=",when," reason=",reason," reached=",reached," room=",w.room," result=",t8.canal.last_result," owns=",t8.owns()," tr=",w.transition," phys=",w.player.is_physics_processing()," spr=",w.player.sprite.visible," layer=",t8.canal.layer.visible," floor=",w.player.is_on_floor()," pos=",w.player.position)
			check(reached and controlled() and w.player.sprite.visible and not t8.canal.layer.visible,"Canal: control restored after %s during %s"%[reason,when])
			check(w.room in [0,13] and w.player.is_on_floor(),"Canal: supported in a valid room after %s during %s (R%d)"%[reason,when,w.room])
			w.player.hp=3
	# Watchdog.
	await setup(13,Vector2(190,1198));key(KEY_A,true)
	while not t8.owns(): await wait_ticks(1)
	key(KEY_A,false)
	t8.canal.request_at=99.0
	await until_control(600)
	check(controlled() and t8.canal.last_result=="watchdog" and w.room==13,"Canal: watchdog returns control in place")

## Everything TR-08 does not own keeps its inherited behaviour.
func unchanged_suite():
	await setup(13,Vector2(1500,560))
	var p=c.endpoint(w,13,14);var before=c.request_count
	w.player.position=p.at+Vector2(-200,-2);w.camera.reset_smoothing();await wait_ticks(4)
	key(KEY_D,true)
	var guard=0
	while c.request_count==before and guard<200:
		await wait_ticks(1);guard+=1
	key(KEY_D,false)
	check(not t8.owns() and w.transition>0.6,"Ordinary side passage R13->R14 stays automatic and immediate")
	await wait_ticks(60)
	await setup(20,Vector2(600,518));await press()
	check(not t8.owns() and w.pending_room==13,"R20 wind-fold keeps its own E presentation")
	await wait_ticks(60)
	c.plain=true;await setup(14,Vector2(1420,478));await press()
	check(not t8.owns() and w.transition>0.6,"Plain mode keeps the inherited plain stair fade")
	await wait_ticks(60);c.plain=false
	check(w.ROOM_COUNT==21 and w.expansion.EDGES.size()==15,"Room graph unchanged: 21 rooms, 15 expansion links")

## --tr08-off: exact PR61 candidate presentation is reachable.
func legacy_mode():
	check(not t8.enabled,"--tr08-off disables TR-08")
	await setup(14,Vector2(1420,478));await press()
	check(not t8.owns() and w.transition>0.6,"--tr08-off: R14->R17 stair uses the inherited 0.65 s loader")
	await wait_ticks(60)
	check(w.room==17,"--tr08-off: stair still arrives")
	await setup(13,Vector2(190,1198));var before=c.request_count
	key(KEY_A,true)
	var guard=0
	while c.request_count==before and guard<200:
		await wait_ticks(1);guard+=1
	key(KEY_A,false)
	check(not t8.owns() and w.transition>0.6,"--tr08-off: Canal-left is the inherited automatic wipe")
	await wait_ticks(60)
	check(w.room==0,"--tr08-off: Canal-left still arrives")
