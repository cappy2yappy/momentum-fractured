extends SceneTree
## PM-pilot independent QA harness (test-only).
## Runs against ANY worktree: godot --path <worktree> --script <abs path to this file> -- [args]
## Self-contained: depends only on the target project's scenes/scripts, so it also runs on
## baselines (e.g. PR39) that lack tests/automatic_passage_reliability.gd.
## Real input: InputEventKey through Input.parse_input_event; real physics. Approaches never write
## position or velocity. Fixture setup (rooms, abilities) only establishes the starting state.
## Line protocol (parsed by tools/pm_pilot_qa/run_qa.py):
##   PASS: [section] label     FAIL: [section] label     SKIP: [section] reason (never counted as pass)
## Args: --qa-sections=a,b  --qa-hooks=<dir>  --qa-expect-reduced
var w
var checks=0
var failures=0
var skips=0
var section="init"
var held={}
var only=[]
var hooks_dir=""
var expect_reduced=false
var expect_canal=false
var out_dir=""
const ALL=["start","issue42","matrix","controls","hints","endpoints","save","combat","graph","reduced","reduced_cli","capture","hook_cinematic_completion","hook_canal_containment"]

func _init(): call_deferred("run")

func check(ok,label):
	checks+=1
	print("PASS: " if ok else "FAIL: ","[",section,"] ",label)
	if not ok: failures+=1
func skip(reason):
	skips+=1
	print("SKIP: [",section,"] ",reason)
func want(name): return only.is_empty() or name in only
func begin(name):
	section=name
	print("SECTION: ",name)

func key(code,pressed):
	held[code]=pressed
	var event=InputEventKey.new();event.physical_keycode=code;event.keycode=code;event.pressed=pressed
	Input.parse_input_event(event);Input.flush_buffered_events()
func raw_key(code,pressed):
	var event=InputEventKey.new();event.physical_keycode=code;event.keycode=code;event.pressed=pressed
	Input.parse_input_event(event);Input.flush_buffered_events()
func wait_ticks(count):
	for i in count:
		await physics_frame
		# Focus loss can clear held keys under windowed automation; reissue through the same input path.
		for code in held:
			if held[code] and not Input.is_physical_key_pressed(code): raw_key(code,true)
func release_all():
	for code in [KEY_A,KEY_D,KEY_SPACE,KEY_SHIFT,KEY_E,KEY_J,KEY_F]: key(code,false)

func hud_stub():
	var here=get_script().resource_path.get_base_dir()
	var path=here.path_join("fixtures/pm_pilot_qa_hud.gd")
	if FileAccess.file_exists(path):
		w.hud.set_script(load(path));w.hud.world=w

func freeze():
	w.set_physics_process(false);w.player.set_physics_process(false)
	for e in w.enemies: e.set_physics_process(false)
func live():
	w.set_physics_process(true);w.player.set_physics_process(true)
	for e in w.enemies: e.set_physics_process(false)
func seed_fixture():
	w.completed=true;w.guard_defeated=true;w.boss_defeated=true
	w.player.double_jump=true;w.player.dash_unlocked=true;w.player.tether_unlocked=true
	w.player.hp=3;w.player.release_tether();w.player.dash_time=0
	w.relay_fragments={"undercroft_sigil":true,"terrace_west":true,"terrace_fire_cache":true}
	w.opened_kunai_gates={"skyworks_wind_intake":true,"cistern_wind_cache":true,"foundry_electric_relay":true,"spire_wind_shutter":true,"pump_electric_isolator":true,"coil_fire_service":true}
	w.expansion_flags={"junction_return":true}
	for element in ["wind","fire","electric"]: w.player.kunai_unlocked[element]=true
func strip_abilities():
	w.player.double_jump=false;w.player.tether_unlocked=false;w.player.dash_unlocked=false
	w.completed=false;w.boss_defeated=false;w.guard_defeated=false
	w.relay_fragments.clear();w.opened_kunai_gates.clear();w.expansion_flags.clear()
	w.player.kunai_unlocked={"wind":false,"fire":false,"electric":false}
func reset(index):
	w.cinematic_transitions.cancel(w);w.embodied_transitions.cancel(w);w.mixed_transitions.cancel(w)
	w.transition=0;w.pending_room=-1;w.pending_arrival=Vector2.INF
	w.build_room(index);freeze();seed_fixture();w.cinematic_transitions.cooldown=0
	w.camera.zoom=Vector2.ONE;w.camera.position=Vector2(0,-110);w.camera.offset=Vector2.ZERO;w.camera.position_smoothing_enabled=true
func cross(p,height=0,backward=false,tether=false):
	# Unit-style crossing (direct controller update). Used ONLY for gate-hint and guard checks,
	# never as evidence of real-input traversal.
	var dir=int(p.heading)
	w.player.set_physics_process(true)
	w.player.position=p.at+Vector2(-60*dir,-2+height)
	w.player.velocity=Vector2((-400 if backward else 400)*dir,0)
	w.player.tether_attached=tether
	w.cinematic_transitions.update(w,0)
	w.player.position=p.at+Vector2(2*dir,-2+height)
	w.cinematic_transitions.update(w,1.0/60.0)
	w.player.set_physics_process(false)
func stage(pair,distance=180):
	release_all()
	reset(pair[0]);var p=w.cinematic_transitions.endpoint(w,pair[0],pair[1])
	w.player.position=p.at-Vector2(p.heading*distance,2);w.player.velocity=Vector2.ZERO
	w.player.run=false;w.player.last_tap=-10;w.player.dash_cooldown=0
	live();await wait_ticks(4)
	return p
func new_world(keep_save=false):
	release_all()
	# Every scene starts from a genuinely fresh profile unless a test says otherwise
	# (the game autosaves on checkpoints/transitions; stale files would leak fixtures).
	if not keep_save:
		var d=ProjectSettings.globalize_path("user://silent_district_alpha_v3.json")
		if FileAccess.file_exists(d): DirAccess.remove_absolute(d)
	if is_instance_valid(w):
		w.queue_free();await process_frame
	w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w
	hud_stub()
	await wait_ticks(3)
func restored(label):
	var ok=w.transition<=0 and not paused and w.player.is_physics_processing() and w.player.sprite.visible and not w.embodied_transitions.proxy.visible
	ok=ok and w.camera.zoom==Vector2.ONE and w.camera.position==Vector2(0,-110) and w.player.hp>0
	check(ok,"Control state restored after transition: "+label)
func responsive(pair,label):
	# Real key away from the door must move Kaze: proves control returned to the player.
	var p=w.cinematic_transitions.endpoint(w,pair[1],pair[0])
	var away=KEY_A if p.heading>0 else KEY_D
	var x0=w.player.position.x
	key(away,true);await wait_ticks(14);key(away,false);await wait_ticks(10)
	check(absf(w.player.position.x-x0)>20 and w.room==pair[1],"Kaze responds to real input after arrival: "+label)

# ---------------------------------------------------------------- approaches
func approach(pair,offset,style,tag):
	var c=w.cinematic_transitions
	var p=c.endpoint(w,pair[0],pair[1])
	var code=KEY_A if p.heading<0 else KEY_D
	var before=c.request_count
	if style=="sprint":
		key(code,true);await wait_ticks(2);key(code,false);await wait_ticks(1)
	key(code,true)
	var jumped=false
	var jump_tick=-1
	var wall_stopped=false
	var airborne=false
	for tick in 420:
		if not jumped and style=="jump" and (p.at.x-w.player.position.x)*p.heading<=40+offset:
			key(KEY_SPACE,true);jumped=true;jump_tick=tick
		if jumped and tick==jump_tick+8: key(KEY_SPACE,false)
		if tick==5 and style=="dash": key(KEY_SHIFT,true)
		if tick==6 and style=="dash": key(KEY_SHIFT,false)
		await wait_ticks(1)
		if w.room==pair[0] and w.transition<=0:
			airborne=airborne or not w.player.is_on_floor()
			wall_stopped=wall_stopped or (w.player.is_on_wall() and absf(w.player.velocity.x)<1)
		if c.request_count>before: break
	key(code,false);key(KEY_SPACE,false);key(KEY_SHIFT,false)
	print("TRACE ",tag," pair=",pair," offset=",offset," style=",style," pos=",w.player.position," vel=",w.player.velocity," floor=",w.player.is_on_floor()," wall_stopped=",wall_stopped," airborne=",airborne)
	check(c.request_count==before+1,"%s real keys %s %s offset=%d requests exactly once"%[tag,pair,style,offset])
	await wait_ticks(55)
	check(w.room==pair[1] and w.player.is_on_floor(),"%s real keys %s %s offset=%d lands supported in target"%[tag,pair,style,offset])
	await wait_ticks(40)
	check(c.request_count==before+1,"%s stopped arrival %s %s offset=%d cannot loop"%[tag,pair,style,offset])

# ---------------------------------------------------------------- sections
func sec_start():
	begin("start")
	print("HARNESS: script=",get_script().resource_path," hud_stub=",FileAccess.file_exists(get_script().resource_path.get_base_dir().path_join("fixtures/pm_pilot_qa_hud.gd")))
	print("PLATFORM: os=",OS.get_name()," driver=",RenderingServer.get_current_rendering_driver_name()," adapter=\"",RenderingServer.get_video_adapter_name(),"\" display=",DisplayServer.get_name()," engine=",Engine.get_version_info().string)
	await new_world()
	var pl=w.player
	check(not w.test_mode and w.room==0,"Fresh normal start (not --test) in R0")
	check(pl.hp==3 and not pl.double_jump and not pl.tether_unlocked and not pl.dash_unlocked,"Starting abilities: 3 HP, no Windstep, no Tether, no Dash")
	check(not pl.kunai_unlocked.wind and not pl.kunai_unlocked.fire and not pl.kunai_unlocked.electric,"No elemental kunai at start")
	check(not w.completed and not w.boss_defeated and not w.guard_defeated and w.relay_fragments.is_empty() and w.opened_kunai_gates.is_empty() and w.expansion_flags.is_empty(),"No progression flags at start")
	check(pl.speed_upgrade_level==0 and w.checkpoint_room==0,"Speed upgrade 0 and checkpoint R0")
	var manifest=JSON.parse_string(FileAccess.get_file_as_string("res://assets/web/kaze_manifest.json"))
	check(FileAccess.get_sha256("res://scripts/player.gd")==manifest["controller_sha256"],"Controller checksum matches approved manifest (movement untouched)")
	check(not FileAccess.file_exists(w.save_path),"Disposable profile: no pre-existing save file")
	var c=w.cinematic_transitions
	check(c.enabled and not c.reduced,"Cinematic controller enabled, reduced motion off by default")
	# Walk the normal spawn to the R0 right exit with real keys.
	key(KEY_D,true)
	for tick in 480:
		await wait_ticks(1)
		if c.request_count>0: break
	key(KEY_D,false)
	await wait_ticks(60)
	check(w.room==1 and w.player.is_on_floor(),"Fresh real-key R0->R1 walk arrives supported")
	restored("R0->R1 fresh walk")

func sec_issue42():
	begin("issue42")
	# Issue #42: fresh save, real keys, walk R0->R1, then walk left and jump at 0..40px extra offsets.
	for offset in range(0,41,5):
		await new_world()
		check(not w.test_mode and w.room==0 and not w.player.double_jump,"offset=%d fresh normal save, R0, no Windstep"%offset)
		key(KEY_D,true)
		for tick in 480:
			await wait_ticks(1)
			if w.cinematic_transitions.request_count>0: break
		key(KEY_D,false)
		await wait_ticks(50)
		check(w.room==1 and w.player.is_on_floor(),"offset=%d fresh R0->R1 arrival supported"%offset)
		await approach([1,0],offset,"jump","issue42")
	# Same issue, grounded wall stall: never jump, only walk (control case).
	await new_world()
	key(KEY_D,true)
	for tick in 480:
		await wait_ticks(1)
		if w.cinematic_transitions.request_count>0: break
	key(KEY_D,false);await wait_ticks(50)
	await approach([1,0],0,"walk","issue42")
	await responsive([1,0],"issue42 walk")

func sec_matrix():
	begin("matrix")
	# Fixtures only set the initial room/abilities; every approach is real keys + physics.
	for pair in [[13,0],[13,14],[14,13],[1,2],[1,0]]:
		for style in ["walk","sprint","dash","jump"]:
			for offset in ([0,10,20,30,40] if style=="jump" else [0]):
				await stage(pair,180)
				await approach(pair,offset,style,"matrix")
		restored("matrix %s"%[pair])
		await responsive(pair,"matrix %s"%[pair])
	# R0 -> R13 Canal-left is a depth door: E, not automatic. Locked without Windstep, open with it.
	await stage([0,13],0)
	var c=w.cinematic_transitions
	check(not c.automatic(w,0,13),"R0->R13 depth door stays explicit E interaction")
	w.player.double_jump=false;w.message="";w.message_time=0
	var p=c.endpoint(w,0,13);w.player.position=p.at-Vector2(0,2);w.player.velocity=Vector2.ZERO;await wait_ticks(4)
	var before=c.request_count
	key(KEY_E,true);await wait_ticks(2);key(KEY_E,false);await wait_ticks(30)
	check(w.room==0 and c.request_count==before,"R0->R13 refused without Windstep")
	check("Windstep" in w.message.capitalize() or "windstep" in w.message.to_lower() or w.message!="","R0->R13 locked E gives a hint: "+w.message)
	w.player.double_jump=true;w.message=""
	key(KEY_E,true);await wait_ticks(2);key(KEY_E,false)
	for t in 400:
		await wait_ticks(1)
		if w.room==13 and w.transition<=0: break
	await wait_ticks(20)
	check(w.room==13 and w.player.is_on_floor(),"R0->R13 E door with Windstep arrives supported in Canal")
	restored("R0->R13 E")
	# Canal-left return: R13 left exit (feet 120,1200) -> R0, walking, once more from the arrival.
	var q=c.endpoint(w,13,0)
	check(q.at==Vector2(120,1200),"R13 left exit endpoint feet are (120,1200): %s"%q.at)

func sec_controls():
	begin("controls")
	for pair in [[13,0],[13,14],[14,13],[1,0],[1,2]]:
		var p=await stage(pair)
		var c=w.cinematic_transitions
		var before=c.request_count
		var outward=KEY_A if p.heading<0 else KEY_D
		var inward=KEY_D if p.heading<0 else KEY_A
		key(outward,true);await wait_ticks(7);key(outward,false);await wait_ticks(30)
		check(w.room==pair[0] and c.request_count==before,"Stop before threshold stays in %s"%[pair])
		key(inward,true);await wait_ticks(8);key(inward,false);await wait_ticks(12)
		check(c.request_count==before,"Reverse away from %s does not activate"%[pair])
		key(outward,true)
		for tick in 120:
			await wait_ticks(1)
			if c.request_count>before: break
		await wait_ticks(80);key(outward,false)
		check(w.room==pair[1] and c.request_count==before+1,"Held direction through %s: one request, no arrival loop (room=%d requests=%d)"%[pair,w.room,c.request_count-before])
	# Arrival cooldown timing: a request immediately after arrival is impossible.
	var p=await stage([13,14]);var c=w.cinematic_transitions;var before=c.request_count
	key(KEY_D,true)
	for tick in 120:
		await wait_ticks(1)
		if c.request_count>before: break
	key(KEY_D,false)
	for tick in 120:
		await wait_ticks(1)
		if w.room==14 and w.transition<=0: break
	check(w.room==14 and c.cooldown>0 or w.room==14,"R13->R14 arrival reached; cooldown now %.2f"%c.cooldown)
	var stamp=c.request_count
	key(KEY_A,true);await wait_ticks(12);key(KEY_A,false)
	check(c.request_count==stamp,"Immediate reverse within the arrival cooldown does not bounce back")
	await wait_ticks(60)
	key(KEY_A,true)
	for tick in 120:
		await wait_ticks(1)
		if c.request_count>stamp: break
	key(KEY_A,false);await wait_ticks(50)
	check(c.request_count==stamp+1 and w.room==13,"Deliberate reverse after cooldown crosses back exactly once")
	# Jump past, release against wall, then reapproach.
	p=await stage([13,0]);c=w.cinematic_transitions;before=c.request_count
	key(KEY_A,true)
	for tick in 90:
		if w.player.position.x<=p.at.x+80: break
		await wait_ticks(1)
	key(KEY_SPACE,true);await wait_ticks(8);key(KEY_SPACE,false)
	for tick in 80:
		await wait_ticks(1)
		if w.player.is_on_wall(): break
	check(not w.player.is_on_floor(),"Release fixture reaches wall airborne through physics")
	key(KEY_A,false);await wait_ticks(180)
	check(w.room==13 and w.player.is_on_floor() and c.request_count==before,"Airborne wall approach released to idle does not activate")
	key(KEY_D,true);await wait_ticks(4)
	check(c.request_count==before,"Inward key at missed wall exit does not activate")
	key(KEY_D,false);await wait_ticks(10);key(KEY_A,true);await wait_ticks(80);key(KEY_A,false)
	check(w.room==0 and c.request_count==before+1,"Outward reapproach recovers missed wall exit (grounded, no softlock)")

func sec_hints():
	begin("hints")
	var c
	# Wrong height: elevated R5 left exit vs lower floor beneath it.
	await stage([5,4],100)
	c=w.cinematic_transitions
	var before=c.request_count
	w.player.position=Vector2(14.1,1298);w.player.velocity=Vector2.ZERO
	await wait_ticks(6);key(KEY_A,true);await wait_ticks(30);key(KEY_A,false)
	check(w.player.is_on_floor() and c.request_count==before,"Wrong height: armed outward wall contact on lower floor cannot transition")
	await stage([13,0],100)
	w.player.position=Vector2(14.1,1198);w.player.velocity=Vector2.ZERO
	await wait_ticks(6)
	before=c.request_count;w.player.tether_attached=true;key(KEY_A,true)
	c.update(w,1.0/60.0)
	check(c.request_count==before,"Tether-attached state rejected at supported wall exit")
	key(KEY_A,false);w.player.tether_attached=false
	# Backward velocity and wrong height via unit crossing.
	reset(1);var p1=c.endpoint(w,1,0)
	before=c.request_count;cross(p1,0,true)
	check(c.request_count==before,"Backward-velocity crossing rejected")
	reset(1);before=c.request_count;cross(p1,-120)
	check(c.request_count==before,"Crossing 120px above the exit rejected")
	# Authored base-game gate hints, one by one.
	var expect={[1,2]:"Windstep",[3,4]:"Wind Tether",[5,6]:"Gale Dash",[6,7]:"Tide Warden",[7,8]:"Relay Archive",[9,10]:"relay sigils",[10,11]:"Wind Kunai",[11,12]:"Electric Kunai"}
	for pair in expect:
		reset(pair[0]);strip_abilities();w.message="";w.message_time=0
		var p=c.endpoint(w,pair[0],pair[1])
		cross(p)
		check(w.transition==0 and expect[pair] in w.message,"Locked R%d->R%d keeps specific hint containing '%s': '%s'"%[pair[0],pair[1],expect[pair],w.message])
		check(not ("PASSAGE LOCKED" in w.message),"Locked R%d->R%d hint not overwritten by PASSAGE LOCKED"%[pair[0],pair[1]])
	# Same, but the message already holds the identical text and timer (repeat announcement).
	reset(1);strip_abilities();w.message="The sluice climb needs Windstep.";w.message_time=4
	cross(c.endpoint(w,1,2))
	check("Windstep" in w.message and w.transition==0,"Repeat of identical hint text and timer still preserved")
	# All gated automatic endpoints.
	var tested=0
	for index in 21:
		reset(index)
		for p in c.endpoints(w,index):
			if p.mode!="horizontal_walk": continue
			reset(index);strip_abilities();w.message=""
			if w.can_enter(p.target): continue
			var expected=w.message
			if expected.is_empty(): expected="Route sealed: "+p.need.replace("_"," ").to_upper()+". Consult the atlas."
			w.message=expected;w.message_time=4
			cross(p)
			check(w.transition==0 and w.message==expected and not ("PASSAGE LOCKED" in w.message and p.need!=""),"Gated R%d->R%d retains prerequisite text '%s' (got '%s')"%[index,p.target,expected,w.message])
			tested+=1
	print("QA gated automatic endpoints tested=",tested)
	check(tested>=20,"At least 20 gated automatic endpoints exercised (%d)"%tested)
	# Real keys, locked Windstep gate.
	await stage([1,2],100)
	w.player.double_jump=false;w.message="";w.message_time=0
	key(KEY_D,true);await wait_ticks(50);key(KEY_D,false)
	check(w.room==1 and w.transition==0,"Locked Windstep gate blocks real walking")
	check("Windstep" in w.message and not ("PASSAGE LOCKED" in w.message),"Real-key locked R1->R2 shows Windstep hint: '"+w.message+"'")
	# Unlock and pass.
	w.player.double_jump=true
	key(KEY_A,true);await wait_ticks(40);key(KEY_A,false);await wait_ticks(5)
	key(KEY_D,true)
	for tick in 150:
		await wait_ticks(1)
		if w.room==2: break
	key(KEY_D,false)
	await wait_ticks(40)
	print("TRACE unlock-pass room=",w.room," pos=",w.player.position," vel=",w.player.velocity," floor=",w.player.is_on_floor()," cooldown=",c.cooldown," armed=",c.armed," req=",c.request_count," msg=",w.message)
	check(w.room==2 and w.player.is_on_floor(),"After Windstep, R1->R2 passes with real keys")

func sec_endpoints():
	begin("endpoints")
	var pairs=[]
	reset(0)
	for index in 21:
		for ep in w.cinematic_transitions.endpoints(w,index):
			if ep.mode=="horizontal_walk": pairs.append([index,ep.target])
	check(pairs.size()==39,"39 automatic horizontal_walk endpoints (found %d)"%pairs.size())
	for pair in pairs:
		await stage(pair,100)
		await approach(pair,0,"jump","endpoints")
		restored("endpoints %s"%[pair])

func sec_save():
	begin("save")
	await new_world()
	w.player.double_jump=true;w.player.tether_unlocked=true;w.player.dash_unlocked=true
	w.player.unlock_kunai("fire");w.opened_kunai_gates["terrace_return_relay"]=true
	w.relay_fragments["undercroft_sigil"]=true;w.cleared_encounters["intake_sentinel"]=true
	w.checkpoint_room=8;w.checkpoint_position=Vector2(2060,1298);w.completed=true;w.boss_defeated=true
	w.build_room(9);freeze()
	w.save_path="user://qa_roundtrip.json"
	check(not w.test_mode,"Save test runs in normal (non --test) mode")
	check(w.save_progress() and FileAccess.file_exists(w.save_path),"Save writes the file")
	w.player.double_jump=false;w.player.tether_unlocked=false;w.player.dash_unlocked=false
	w.player.kunai_unlocked["fire"]=false;w.opened_kunai_gates.clear();w.relay_fragments.clear();w.cleared_encounters.clear()
	w.completed=false;w.boss_defeated=false;w.checkpoint_room=0
	w.load_progress()
	check(w.player.double_jump and w.player.tether_unlocked and w.player.dash_unlocked and w.player.kunai_unlocked.fire,"In-session reload restores abilities")
	check(w.opened_kunai_gates.get("terrace_return_relay",false) and w.relay_fragments.get("undercroft_sigil",false) and w.cleared_encounters.get("intake_sentinel",false),"Reload restores gates, fragments, cleared encounters")
	check(w.checkpoint_room==8 and w.checkpoint_position==Vector2(2060,1298) and w.completed and w.boss_defeated,"Reload restores checkpoint and flags")
	var path=w.save_path
	await new_world()
	w.save_path=path;w.load_progress()
	check(w.player.double_jump and w.player.dash_unlocked and w.checkpoint_room==8,"A brand-new scene instance loading the same file restores the kit and checkpoint")
	# Corrupt / legacy handling.
	var f=FileAccess.open(path,FileAccess.WRITE);f.store_string("{not json");f.close()
	w.player.double_jump=false
	w.load_progress()
	check(not w.player.double_jump,"Corrupt save does not grant abilities or crash")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	check(not FileAccess.file_exists("user://silent_district_alpha_v3.json"),"Round trip used only its own path; default profile save untouched")

func sec_combat():
	begin("combat")
	await new_world()
	w.build_room(1);freeze()
	var guard=w.guard
	w.player.position=Vector2(1030,1300);w.player.facing=1
	var hp=guard.hp
	w.on_strike(1,95)
	check(guard.hp==hp-1,"Melee strike connects at existing reach")
	w.player.facing=-1;hp=guard.hp;w.on_strike(1,95)
	check(guard.hp==hp,"Melee strike does not hit behind the player")
	w.player.facing=1;w.player.hp=3
	w.player.parry_time=0.2;guard.state="strike";guard.strike_done=false;guard.timer=0.16;guard._physics_process(0.01)
	check(guard.state=="stunned" and w.player.hp==3,"Parry stuns the attacker without damage")
	w.player.parry_time=0.0;w.player.invulnerable=0.0;guard.state="strike";guard.strike_done=false;guard.timer=0.16;guard._physics_process(0.01)
	check(w.player.hp==2 and w.player.invulnerable>1.0,"Missed parry takes 1 damage and grants protection")
	w.player.press("attack");w.player.press("attack")
	check(w.player.queued and w.player.combo==0,"Combo queues a follow-up")
	# Real key attack with physics live.
	await new_world();w.build_room(1);live()
	w.player.position=Vector2(1030,1298);w.player.facing=1;w.player.velocity=Vector2.ZERO
	await wait_ticks(4)
	var g=w.guard;g.set_physics_process(false);hp=g.hp
	key(KEY_J,true);await wait_ticks(2);key(KEY_J,false);await wait_ticks(40)
	check(g.hp<hp,"Real J key attack with live physics damages the guard (hp %d -> %d)"%[hp,g.hp])
	check(w.player.attack_time<=0 and w.player.is_physics_processing(),"Attack recovers; player control continues")

func sec_graph():
	begin("graph")
	await new_world()
	check(w.ROOM_COUNT==21 and w.world_edges().size()==29,"21 rooms and 29 links preserved (%d rooms, %d links)"%[w.ROOM_COUNT,w.world_edges().size()])
	var c=w.cinematic_transitions
	var total=0;var auto=0
	for index in 21:
		for p in c.endpoints(w,index):
			total+=1
			if p.mode=="horizontal_walk": auto+=1
	check(total==58 and auto==39,"58 classified endpoints, 39 automatic, 19 explicit (%d/%d)"%[total,auto])
	var ok_pairs=true
	for e in w.world_edges():
		var a=false;var b=false
		for p in c.endpoints(w,e[0]):
			if p.target==e[1]: a=true
		for p in c.endpoints(w,e[1]):
			if p.target==e[0]: b=true
		if not (a and b):
			ok_pairs=false;print("GRAPH missing endpoint for edge ",e)
	check(ok_pairs,"Every graph edge has an endpoint in both directions")
	# Reachability with the full kit.
	reset(0)
	var adjacency={}
	for e in w.world_edges():
		for pair in [[e[0],e[1]],[e[1],e[0]]]:
			w.room=pair[0]
			if w.can_enter(pair[1]):
				adjacency[pair[0]]=adjacency.get(pair[0],[])+[pair[1]]
	var seen={0:true};var queue=[0]
	while not queue.is_empty():
		var n=queue.pop_front()
		for m in adjacency.get(n,[]):
			if not seen.has(m): seen[m]=true;queue.append(m)
	check(seen.size()==21,"All 21 rooms reachable with full kit (%d)"%seen.size())
	# Progression gates close on a fresh kit and open with the matching ability.
	var gates={[1,2]:"double_jump",[3,4]:"tether_unlocked",[5,6]:"dash_unlocked"}
	for pair in gates:
		reset(pair[0]);strip_abilities();w.room=pair[0]
		check(not w.can_enter(pair[1]),"Fresh kit: R%d->R%d gated"%pair)
		w.player.set(gates[pair],true)
		check(w.can_enter(pair[1]),"With %s: R%d->R%d opens"%[gates[pair],pair[0],pair[1]])
	reset(6);strip_abilities();w.room=6
	check(not w.can_enter(7),"Fresh: R6->R7 gated by boss");w.boss_defeated=true;check(w.can_enter(7),"Boss defeated opens R6->R7")
	reset(7);strip_abilities();w.room=7
	check(not w.can_enter(8),"Fresh: R7->R8 gated by relay archive");w.completed=true;check(w.can_enter(8),"Completed opens R7->R8")
	# Original eight-room geometry.
	var approved=JSON.parse_string(FileAccess.get_file_as_string("res://docs/APPROVED_GEOMETRY.json"))
	var geo_ok=true
	for index in 8:
		w.build_room(index);freeze()
		var sig=[]
		for rect in w.platforms: sig.append([rect.position.x,rect.position.y,rect.size.x,rect.size.y])
		var expected=approved[str(index)].platforms.duplicate(true)
		for row in expected:
			if index==2 and row==[2220.0,850.0,260.0,40.0]: row[2]=380.0
			if index==4 and row==[2130.0,1080.0,270.0,40.0]: row[2]=470.0
		if JSON.stringify(sig)!=JSON.stringify(expected): geo_ok=false;print("GEOMETRY differs room ",index)
	check(geo_ok,"Original eight-room geometry equals approved reference (plus recorded TR04 repairs)")

func sec_reduced():
	begin("reduced")
	await stage([1,0],100)
	var c=w.cinematic_transitions
	check(not c.reduced,"Reduced motion off at start of section")
	raw_key(KEY_F6,true);await wait_ticks(2);raw_key(KEY_F6,false);await wait_ticks(2)
	check(c.reduced and w.embodied_transitions.comparison=="reduced" and w.mixed_transitions.graphic_mode=="reduced","F6 enables reduced motion across all three controllers")
	check("REDUCED" in w.message,"F6 announces reduced motion: "+w.message)
	# Real-key crossing under reduced motion: camera never leaves rest zoom.
	var before=c.request_count
	var max_zoom=1.0;var hid=false
	key(KEY_A,true)
	for tick in 200:
		await wait_ticks(1)
		max_zoom=maxf(max_zoom,w.camera.zoom.x)
		if w.transition>0 and not w.player.sprite.visible: hid=true
		if c.request_count>before and w.transition<=0 and w.room==0: break
	key(KEY_A,false);await wait_ticks(60)
	check(w.room==0 and c.request_count==before+1,"Reduced-motion real-key crossing R1->R0 completes once")
	check(max_zoom<=1.001,"Reduced motion: camera never zooms (max %.3f)"%max_zoom)
	restored("reduced-motion crossing")
	raw_key(KEY_F6,true);await wait_ticks(2);raw_key(KEY_F6,false);await wait_ticks(2)
	check(not c.reduced,"F6 toggles back to cinematic motion")
	check(w.camera.zoom==Vector2.ONE,"Camera at rest zoom after toggling back")

func sec_reduced_cli():
	begin("reduced_cli")
	await new_world()
	var c=w.cinematic_transitions
	if expect_reduced:
		check(c.reduced and w.embodied_transitions.comparison=="reduced","--tr05-reduced-motion starts the session reduced")
	else:
		check(not c.reduced,"Without --tr05-reduced-motion the session starts cinematic")

func shot(name):
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(out_dir)
	var img=root.get_texture().get_image()
	img.save_png(out_dir.path_join(name+".png"))
	print("CAPTURE ",name," room=",w.room," feet=",w.player.position," transition=",w.transition)

func sec_capture():
	begin("capture")
	if DisplayServer.get_name()=="headless" or out_dir=="":
		skip("capture needs a rendered display and --qa-out=<dir> (graphical category only). NOT a pass.")
		return
	# Canal-left: fixture start on the hall shelf, then real A key through the door.
	release_all();reset(13)
	var c=w.cinematic_transitions
	w.player.position=Vector2(330,1158);w.player.velocity=Vector2.ZERO
	w.camera.reset_smoothing();live();await wait_ticks(8)
	await shot("canal_01_start_on_shelf")
	var before=c.request_count;var got={}
	key(KEY_A,true)
	for tick in 300:
		await wait_ticks(1)
		var x=w.player.position.x
		if not got.has("a") and x<=250: got["a"]=true;await shot("canal_02_approach")
		if not got.has("b") and x<=150 and w.room==13: got["b"]=true;await shot("canal_03_at_door")
		if c.request_count>before: break
	key(KEY_A,false)
	check(c.request_count==before+1,"Capture run: Canal-left crossed by real A key")
	await wait_ticks(12);await shot("canal_04_transition_early")
	await wait_ticks(14);await shot("canal_05_transition_mid")
	for tick in 120:
		await wait_ticks(1)
		if w.transition<=0 and w.room==0: break
	await wait_ticks(30);await shot("canal_06_arrived_R0")
	check(w.room==0 and w.player.is_on_floor(),"Capture run: arrived in R0 supported")
	# Staged stair (only when the Transition pilot is present and enabled).
	var st=c.get("staged")
	if st==null or not st.enabled:
		skip("staged stair captures need a Transition candidate run with --pm-staged-stair. NOT a pass.")
		return
	release_all();reset(14)
	w.player.position=c.endpoint(w,14,17).at+Vector2(-30,-2);w.player.velocity=Vector2.ZERO
	w.camera.reset_smoothing();live();await wait_ticks(8)
	await shot("stair_00_before")
	key(KEY_E,true)
	var marks={14:"stair_01_enter_early",40:"stair_02_enter_late",60:"stair_03_loader",78:"stair_04_loader_late",100:"stair_05_arrive_early",125:"stair_06_arrive_late",170:"stair_07_control_back"}
	var n=0
	while n<180:
		await wait_ticks(1);n+=1
		if marks.has(n): await shot(marks[n])
	key(KEY_E,false)
	check(w.room==17 and st.phase=="" and w.transition<=0,"Capture run: stair sequence finished in R17 with control back")

func run_hook(name):
	begin(name)
	var path=hooks_dir.path_join(name+".gd") if hooks_dir!="" else ""
	if path=="" or not FileAccess.file_exists(path):
		skip("PENDING: candidate not available; hook tools/pm_pilot_qa/hooks/%s.gd absent. This is NOT a pass."%name)
		return
	var hook=load(path).new()
	await hook.run(self)

func run():
	await process_frame
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--qa-sections="): only=a.substr(14).split(",")
		if a.begins_with("--qa-hooks="): hooks_dir=a.substr(11)
		if a=="--qa-expect-reduced": expect_reduced=true
		if a=="--qa-expect-canal": expect_canal=true
		if a.begins_with("--qa-out="): out_dir=a.substr(9)
	var order=[["start",sec_start],["issue42",sec_issue42],["matrix",sec_matrix],["controls",sec_controls],["hints",sec_hints],["endpoints",sec_endpoints],["save",sec_save],["combat",sec_combat],["graph",sec_graph],["reduced",sec_reduced]]
	for row in order:
		if want(row[0]) and not (only.is_empty() and row[0]=="reduced_cli"): await new_world();await row[1].call()
	if "reduced_cli" in only: await new_world();await sec_reduced_cli()
	if "capture" in only: await new_world();await sec_capture()
	await new_world()
	if want("hook_cinematic_completion"): await run_hook("hook_cinematic_completion")
	if want("hook_canal_containment"): await run_hook("hook_canal_containment")
	release_all()
	if is_instance_valid(w): w.queue_free()
	current_scene=null
	for i in 3: await process_frame
	print("QA SUMMARY: %d checks, %d failure(s), %d skip(s)"%[checks,failures,skips])
	quit(1 if failures else 0)
