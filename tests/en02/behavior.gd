extends SceneTree
var failures := 0
var checks := 0
var w
func _init(): call_deferred("run")
func check(ok, label):
	checks += 1
	print("PASS: " if ok else "FAIL: ",label)
	if not ok: failures += 1
func ticks(n):
	for i in n: await physics_frame
func fresh(mode):
	if is_instance_valid(w): w.free(); current_scene = null; await process_frame
	w = load("res://scenes/en02/"+mode+".tscn").instantiate()
	root.add_child(w); current_scene=w
	if DisplayServer.get_name() != "headless":
		# Native automation fixture only; OS focus is outside this combat test.
		w.hud.free()
		paused=false
	await ticks(5)
func run():
	await process_frame
	for mode in ["skirmisher","slime"]:
		await fresh(mode)
		check(w.enemies.size()==1 and w.encounter.members[0]==w.enemies[0],mode+" registered through managed encounter/world spawn")
		var e = w.enemies[0]
		check(e.get_script().resource_path=="res://scripts/en02/enemy.gd",mode+" substitution isolated to lab factory")
		check(w.entry().hp>=4 and w.entry().hp<=8 and w.entry().windup>=0.5,mode+" production HP and warning bounds")
		check(e.state=="dormant",mode+" outside range remains dormant")
		w.player.position=Vector2(820,618); w.player.velocity=Vector2.ZERO
		await ticks(2)
		check(e.state=="awakening" and w.player.hp==3,mode+" wake is non-damaging")
		await ticks(30)
		check(w.player.hp==3 and e.state=="awakening",mode+" at least 0.8s activation grace")
		for i in 70:
			await ticks(1)
			if e.state=="windup": break
		check(e.state=="windup" and w.player.hp==3,mode+" full telegraph before first attack")
		var direction=e.facing
		w.player.position.x=e.position.x+60
		await ticks(8)
		check(e.facing==direction,mode+" side switch cannot retarget committed attack")
		# A control owner interrupt cancels the active commitment, then fresh grace.
		w.player.set_physics_process(false)
		await ticks(2)
		check(e.state=="awakening" and e.control_cancellations==1,mode+" input ownership cancels attack")
		var hp=w.player.hp
		await ticks(70)
		check(w.player.hp==hp and e.timer>=0.79,mode+" no hidden timer attack while input unavailable")
		w.player.set_physics_process(true); w.player.position=Vector2(e.position.x-65,618)
		await ticks(10)
		check(e.state=="awakening" and w.player.hp==hp,mode+" control return gets fresh grace")
		# Real facing parry exercises the inherited strike rather than custom damage.
		e.state="windup"; e.timer=0.02; e.facing=-1
		w.player.facing=1; w.player.parry_time=0.23; w.player.invulnerable=0
		await ticks(4 if mode=="skirmisher" else 12)
		check(e.state=="stunned" and w.player.hp==hp,mode+" approved facing parry stuns strike")
		# Real attack input/animation -> unchanged world's target list -> receive_hit.
		e.state="recover"; e.timer=1.0
		w.player.position=Vector2(e.position.x-60,618); w.player.velocity=Vector2.ZERO
		w.player.facing=1; w.player.attack_time=0; w.player.hitstop=0
		var old_hp=e.hp
		w.player.press("attack"); await ticks(18)
		check(e.hp<old_hp,mode+" actual melee signal damages candidate")
		# Existing dash immunity remains authoritative.
		await ticks(24)
		w.player.press("dash"); await ticks(2)
		check(w.player.dash_time>0 and w.player.invulnerable>0,mode+" approved dash retains protection")
		w.player.touch.clear(); w.player.dash_time=0; w.player.velocity=Vector2.ZERO
		# Queue a defeat during a transition, confirm same version-8 disk serializer.
		w.transition=0.4; e.state="recover"; e.receive_hit(100)
		await ticks(2)
		check(w.completed_events.is_empty() and not w.cleared_encounters.get("en01/en02/"+mode,false),mode+" completion and persistence defer during transition")
		w.save_path="user://en02-"+mode+"-fixture.json"; w.permit_test_disk=true; w.test_mode=false
		w.transition=0; await ticks(2)
		check(w.completed_events.size()==1 and w.cleared_encounters.get("en01/en02/"+mode,false),mode+" one managed deferred completion")
		var saved=JSON.parse_string(FileAccess.get_file_as_string(w.save_path))
		check(saved is Dictionary and saved.version==8 and saved.cleared_encounters.get("en01/en02/"+mode,false),mode+" actual serializer uses existing v8 defeat map")
		w.cleared_encounters.clear(); w.load_test_fixture()
		check(w.cleared_encounters.get("en01/en02/"+mode,false),mode+" actual loader restores defeat")
		w.encounter.dispose(); await ticks(2); w.configure_encounter(); await ticks(2)
		check(w.encounter.members.is_empty() and w.completed_events.size()==1,mode+" restored defeat suppresses respawn and duplicate completion")
		DirAccess.remove_absolute(ProjectSettings.globalize_path(w.save_path))
	await fresh("skirmisher")
	var e=w.enemies[0]
	e.state="pursue"; e.position.x=900
	w.player.position=Vector2(720,618); w.player.facing=1; w.player.press("dash")
	await ticks(2)
	check(e.state=="backstep" and e.reposition_count==1,"dash approach triggers one bounded backstep")
	await ticks(18)
	check(e.position.x<=960.1 and e.position.x>=900 and e.state=="recover","backstep at most 60px then committed recovery")
	e.state="pursue"; w.player.dash_time=0.18; await ticks(1)
	check(e.reposition_count==1,"two-second cooldown forbids repeated evasions")
	e.reposition_cooldown=0; e.position.x=1250; e.state="pursue"; w.player.position.x=1200; w.player.dash_time=0.18
	await ticks(1)
	check(e.state=="recover" and e.position.x==1250,"unsafe edge retreat falls back to recovery")
	await fresh("slime")
	e=w.enemies[0]; e.position.x=1250; e.state="windup"; e.timer=0; e.facing=1
	w.player.position=Vector2(1600,618)
	await ticks(2)
	var start=e.position.x
	await ticks(24)
	check(e.position.x<=1300 and e.position.y==620,"lunge is same-platform and territory constrained")
	check(e.state in ["landing","recover"] and w.player.hp==3,"landing and recovery are non-damaging")
	e.state="windup"; e.timer=0; e.facing=-1; await ticks(3)
	check(e.state=="lunge","second lunge entered for teardown probe")
	w.encounter.dispose(); await ticks(2)
	check(w.enemies.is_empty() and not is_instance_valid(e),"teardown during lunge removes member immediately")
	# Real inherited damage boundaries, compared with the displayed envelope.
	for mode in ["skirmisher","slime"]:
		await fresh(mode)
		e=w.enemies[0]; e.set_physics_process(false); e.state="windup"; e.facing=1
		var envelope=e.threat_rect()
		var reach=e.attack_range+e.hit_radius
		check(envelope.position.x<=-14 and envelope.end.x>=reach+(120 if mode=="slime" else 0),mode+" warning conservatively includes displacement plus reach and rear tolerance")
		for offset in [Vector2(reach-1,-2),Vector2(reach+1,-2),Vector2(-15,-2),Vector2(50,-86)]:
			w.player.position=e.position+offset; w.player.velocity=Vector2.ZERO
			w.player.hp=3; w.player.invulnerable=0; w.player.parry_time=0; w.player.dash_time=0
			e.state="strike"; e.strike_done=false; e.timer=0.16
			e._physics_process(0.0)
			var should_hit=offset.x==reach-1
			check((w.player.hp==2)==should_hit,mode+" actual inherited range boundary "+str(offset))
			if w.player.hp<3: check(envelope.has_point(offset),mode+" observed damaging target lies within warning envelope")
		if mode=="slime":
			for target_x in [1171.0,1173.0]:
				e.position=Vector2(900,620); e.state="windup"; e.timer=0; e.facing=1
				w.player.position=Vector2(target_x,618); w.player.hp=3; w.player.invulnerable=0
				var committed_warning=e.threat_rect()
				e._physics_process(0.0); e._physics_process(0.30)
				check((w.player.hp==2)==(target_x==1171.0),"long-step lunge actual outer boundary "+str(target_x))
				if w.player.hp<3: check(committed_warning.has_point(Vector2(target_x-900,-2)),"committed warning contains full-travel damaging edge")
	w.free(); current_scene=null
	print("EN02: %d checks, %d failure(s)" % [checks,failures])
	quit(1 if failures else 0)
