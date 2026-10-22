extends SceneTree
const Config = preload("res://scripts/encounters/config.gd")
const Encounter = preload("res://scripts/encounters/encounter.gd")
var failures = 0
var w
var events: Array = []
func _init(): call_deferred("run")
func check(ok, label):
	print("PASS: " if ok else "FAIL: ", label)
	if not ok: failures += 1
func ticks(n):
	for i in n: await physics_frame
func fresh(mode):
	if is_instance_valid(w):
		w.free(); await process_frame
	w = load("res://scenes/encounters/" + mode + ".tscn").instantiate()
	root.add_child(w); current_scene = w
	await ticks(3)
func run():
	await process_frame
	await fresh("guard")
	var c = JSON.parse_string(FileAccess.get_file_as_string("res://scenes/encounters/guard.json"))[0]
	check(Config.validate(c,w.platforms).errors.is_empty(), "Authored metadata validates against actual arena surface")
	for pair in [["type","unknown"],["hp","six"],["windup",0.1],["position",[700]],["territory",[0,100]],["persistent","true"],["completion_event",42],["version",2],["speed",INF],["activation","unknown"],["story_flag",false]]:
		var bad = c.duplicate(true); bad[pair[0]]=pair[1]
		check(not Config.validate(bad,w.platforms).errors.is_empty(), "Reject invalid " + pair[0])
	var batch = Encounter.new(); w.add_child(batch)
	check(not batch.configure(w,[c,c]).is_empty() and batch.get_child_count()==0, "Invalid/duplicate batch is atomic: no partial spawns")
	batch.free()
	var e = w.enemies[0]
	w.player.position=Vector2(650,618); w.player.velocity=Vector2.ZERO
	await ticks(1)
	check(e.state == "awakening" and w.player.hp==3,"Proximity wake cannot deal contact damage")
	await ticks(35)
	check(w.player.hp==3,"Spawn grace protects overlapping melee approach")
	await ticks(35)
	check(e.state == "windup" and w.player.hp==3,"First melee attack must telegraph after activation")
	w.player.facing=1; w.player.press("parry")
	# Align the approved 0.23s parry with the end of the telegraph.
	await ticks(20)
	w.player.parry_time=0.23
	await ticks(15)
	check(e.state=="stunned" and w.player.hp==3,"Facing parry stuns prototype through real controller/damage interface")
	# Real player attack signal -> unchanged world targeting -> new enemy receive_hit.
	w.player.position=Vector2(e.position.x-65,618); w.player.velocity=Vector2.ZERO
	w.player.facing=1; w.player.hitstop=0; w.player.attack_time=0
	var hp=e.hp; w.player.press("attack"); await ticks(20)
	check(e.hp<hp,"Actual controller melee animation timing damages prototype")
	w.player.position=Vector2(200,618); w.player.velocity=Vector2.ZERO
	await ticks(80)
	check(e.position.x>=500 and e.position.x<=900,"Guard stays on authored patrol surface")
	# Explicitly exercise chase loss and return under real physics ticks.
	e.position.x=850; e.state="pursue"; w.player.position.x=200
	await ticks(100)
	check(e.state in ["patrol","return"] and e.position.x<850,"Territory loss returns guard toward authored home")
	await fresh("ambush")
	e=w.enemies[0]; await ticks(80)
	check(e.state=="dormant" and w.player.hp==3,"Ambush stays dormant outside activation radius")
	w.player.position=Vector2(650,618); await ticks(2)
	check(e.state=="awakening","Ambush gives visible anticipation on proximity trigger")
	await fresh("ranged")
	e=w.enemies[0]; w.player.position=Vector2(1000,618); await ticks(100)
	check(e.state=="dormant","Cover blocks sight-based activation")
	w.player.position=Vector2(1200,618); w.player.velocity=Vector2.ZERO
	await ticks(80)
	check(e.state=="windup","Ranged attacker shows a locked aim telegraph")
	var old_aim=e.aim
	await ticks(15)
	w.player.touch["jump"]=true; w.player.press("jump"); await ticks(35)
	check(w.player.position.y<560 and e.aim==old_aim,"Actual jump clears locked projectile aim without tracking")
	w.player.touch["jump"]=false
	await ticks(15)
	check(w.player.hp==3,"Jump evades the first telegraphed projectile")
	# Projectile sweeps must hit cover before player even at a long frame.
	var shot=load("res://scripts/encounters/projectile.gd").new()
	shot.player=w.player; shot.position=Vector2(1300,565); shot.velocity=Vector2(-500,0)
	w.encounter.add_child(shot); shot.set_physics_process(false)
	w.player.position=Vector2(950,618); w.player.velocity=Vector2.ZERO
	await ticks(2); shot._physics_process(0.9)
	check(shot.is_queued_for_deletion() and w.player.hp==3,"Swept projectile stops at cover during 900ms step")
	await fresh("guard")
	e=w.enemies[0]; e.state="patrol"; e.set_physics_process(false)
	w.player.position=Vector2(540,618); w.player.facing=1
	for element in ["wind","fire","electric"]:
		var hp_before=e.hp; w.player.selected_kunai=element; w.player.kunai_cooldown=0
		w.player.press("kunai"); await ticks(15)
		check(e.hp==hp_before-1,"Actual " + element + " kunai preserves damage behavior")
	w.player.press("dash"); await ticks(5)
	check(w.player.dash_time>0 and w.player.invulnerable>0,"Actual dash keeps approved protection window")
	# Story condition, completion once, and existing persistence map.
	w.encounter.dispose(); await process_frame
	c.persistent=true; c.activation="story"; c.story_flag="en01/test/story"; c.id="test/persistent"
	var runtime=Encounter.new(); w.add_child(runtime); check(runtime.configure(w,[c]).is_empty(),"Story encounter config accepted")
	e=runtime.members[0]; await ticks(3)
	check(e.state=="dormant","Missing story flag fails closed")
	w.expansion_flags[c.story_flag]=true; await ticks(2)
	check(e.state=="awakening","Story flag activates with anticipation")
	runtime.completed.connect(func(event): events.append(event))
	await ticks(65); e.receive_hit(100); await process_frame
	check(w.cleared_encounters.get("en01/test/persistent",false) and events.size()==1,"Defeat uses namespaced existing save flags and emits completion once")
	runtime.dispose(); await process_frame
	runtime=Encounter.new(); w.add_child(runtime); runtime.completed.connect(func(event):events.append(event))
	runtime.configure(w,[c]); await ticks(2)
	check(runtime.members.is_empty() and events.size()==1,"Cleared encounter respawn suppressed and completion not replayed")
	runtime.dispose(); await process_frame
	c.persistent=false; runtime=Encounter.new(); w.add_child(runtime); runtime.configure(w,[c])
	check(runtime.members.size()==1,"Nonpersistent entry respawns despite stored flag")
	w.room=1; await ticks(2); await process_frame
	check(not is_instance_valid(runtime) and w.enemies.is_empty(),"Room exit removes owned enemies and projectiles")
	await fresh("combined")
	check(w.enemies.size()==3,"Combined arena registers all three reusable behaviors")
	var combined_events=[]
	w.encounter.completed.connect(func(event): combined_events.append(event))
	for enemy in w.enemies: enemy.set_physics_process(false); enemy.state="patrol"
	var targets=w.enemies.duplicate()
	for index in targets.size():
		var target=targets[index]
		w.player.position=target.position-Vector2(120,2); w.player.velocity=Vector2.ZERO; w.player.facing=1
		for shot_index in 6:
			w.player.kunai_cooldown=0; w.player.press("kunai"); await ticks(15)
		check(combined_events.size()==(1 if index==2 else 0),"Combined completion waits for member %d" % (index+1))
	check(w.enemies.is_empty(),"Actual controller kunai can clear every combined arena member")
	w.free(); current_scene=null
	print("EN01 FRAMEWORK: %d failure(s)" % failures)
	quit(1 if failures else 0)
