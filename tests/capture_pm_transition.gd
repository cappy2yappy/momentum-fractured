extends "res://tests/native_cinematic_transitions.gd"
## PM pilot (TRANSITION) graphical captures. Run rendered (xvfb + gl_compatibility):
##   godot --path . --fixed-fps 60 --rendering-method gl_compatibility --resolution 1280x720 \
##     --script res://tests/capture_pm_transition.gd -- --pm-staged-stair --pm-capture-dir=<abs dir>
## Seeded fixtures + real InputEventKey input; NOT human gameplay footage.
const Data = preload("res://scripts/transition_pilot_data.gd")
var log_rows=[]

func note(name,extra:Dictionary):
	extra["file"]=name+".png";extra["room"]=w.room;extra["feet"]=[w.player.position.x,w.player.position.y]
	extra["transition"]=w.transition;extra["zoom"]=w.camera.zoom.x
	log_rows.append(extra);print("CAPTURE ",JSON.stringify(extra))

func stub_canal():
	if w.room!=13 or ResourceLoader.exists("res://scripts/canal_gatehouse.gd"): return false
	if not Data.CANAL_LEFT.pier in w.platforms:
		w.add_platform(Data.CANAL_LEFT.pier);w.add_platform(Data.CANAL_LEFT.mass)
	return true

func stair(still:bool):
	for code in [KEY_A,KEY_D,KEY_E]: key(code,false)
	reset(14);var c=w.cinematic_transitions;var s=c.staged
	c.reduced=still;w.embodied_transitions.comparison="reduced" if still else "art-preview"
	w.player.position=c.endpoint(w,14,17).at+Vector2(-40,-2);w.player.velocity=Vector2.ZERO;w.player.animate(0)
	w.camera.reset_smoothing();w.message_time=0;live();await wait_ticks(8)
	var prefix="pm_stair_14-17_"+("reduced" if still else "cinematic")
	await shot(prefix+"_00_before");note(prefix+"_00_before",{"phase":"before"})
	key(KEY_E,true)
	for t in 4:
		await wait_ticks(1)
		if s.phase!="": break
	key(KEY_E,false)
	var marks=[0.12,0.3,0.5,0.75,1.0,1.18,1.45,1.75,2.05,2.3] if not still else [0.08,0.4,0.7,0.9]
	var i=1
	for m in marks:
		var guard=0
		while s.phase!="" and s.timeline()<m and guard<240:
			await wait_ticks(1);guard+=1
		if s.phase=="": break
		var name=prefix+"_%02d_t%.2f_%s"%[i,s.timeline(),s.phase]
		await shot(name);note(name,{"phase":s.phase,"t":s.timeline(),"placeholder":s.placeholder});i+=1
	var guard=0
	while s.phase!="" and guard<300:
		await wait_ticks(1);guard+=1
	await wait_ticks(4)
	await shot(prefix+"_99_control");note(prefix+"_99_control",{"phase":"control","result":s.last_result,"duration":s.last_duration})
	freeze()

func canal():
	for code in [KEY_A,KEY_D,KEY_E,KEY_SPACE]: key(code,false)
	reset(13);var stub=stub_canal();var c=w.cinematic_transitions
	w.player.position=Vector2(330,1198);w.player.velocity=Vector2.ZERO;w.player.facing=-1;w.player.animate(0)
	w.camera.reset_smoothing();w.message_time=0;live();await wait_ticks(8)
	var geometry="LEVEL combined" if not stub else "contract stub (LEVEL not combined)"
	await shot("pm_canal_00_approach");note("pm_canal_00_approach",{"geometry":geometry,"art":c.art.has("L1_door_frame")})
	key(KEY_A,true)
	var shots=[[200.0,"pm_canal_01_hallway"],[150.0,"pm_canal_02_in_aperture"]]
	var before=c.request_count
	for tick in 120:
		await wait_ticks(1)
		if not shots.is_empty() and w.player.position.x<=shots[0][0]:
			await shot(shots[0][1]);note(shots[0][1],{"geometry":geometry});shots.pop_front()
		if c.request_count>before:
			await shot("pm_canal_03_trigger");note("pm_canal_03_trigger",{"geometry":geometry,"trigger_x":Data.CANAL_LEFT.trigger_x});break
	await wait_ticks(10);await shot("pm_canal_04_wipe");note("pm_canal_04_wipe",{})
	key(KEY_A,false)
	await wait_ticks(40);await shot("pm_canal_05_arrived_r0");note("pm_canal_05_arrived_r0",{})
	# Reverse: E at the R0 walkway door, arrive inside the R13 hallway.
	key(KEY_E,true);await wait_ticks(1);key(KEY_E,false)
	await wait_ticks(44);stub_canal();await wait_ticks(2)
	await shot("pm_canal_06_arrived_hallway");note("pm_canal_06_arrived_hallway",{"geometry":geometry})
	freeze()
	# Locked state (no Windstep) for the drawn door.
	reset(13);stub_canal();w.player.double_jump=false
	w.player.position=Vector2(330,1198);w.player.velocity=Vector2.ZERO;w.player.animate(0);w.camera.reset_smoothing();w.message_time=0
	await wait_ticks(2);await shot("pm_canal_07_locked");note("pm_canal_07_locked",{"locked":true})

func run():
	await process_frame
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--pm-capture-dir="): output=arg.trim_prefix("--pm-capture-dir=")
	if not output.is_absolute_path() and not output.begins_with("res://"): output="res://build/pm_pilot/transition/captures"
	DirAccess.make_dir_recursive_absolute(output)
	w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w;freeze();seed_fixture()
	w.hud.set_script(load("res://tests/fixtures/transition_test_hud.gd"));w.hud.world=w
	print("PM CAPTURE renderer=",RenderingServer.get_video_adapter_name()," driver=",RenderingServer.get_current_rendering_driver_name()," viewport=",root.size)
	await stair(false)
	await stair(true)
	await canal()
	var f=FileAccess.open(output+"/captures.json",FileAccess.WRITE);f.store_string(JSON.stringify(log_rows,"  "));f.close()
	w.queue_free();current_scene=null
	for i in 3: await process_frame
	print("PM CAPTURE done: %d frames"%log_rows.size());quit(0)
