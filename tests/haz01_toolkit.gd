extends SceneTree
const Hazard = preload("res://scripts/hazards/environmental_hazard.gd")
const Placement = preload("res://scripts/hazards/hazard_placement.gd")
var failures = 0
var checks = 0
var course
func _init(): call_deferred("run")
func check(ok, message):
	checks += 1
	if not ok: failures += 1
	print("PASS: " if ok else "FAIL: ", message)
func ticks(count):
	for i in count: await physics_frame
	await process_frame
func make_hazard(kind):
	var hazard = Hazard.new()
	hazard.placement = Placement.new()
	hazard.placement.kind = kind
	root.add_child(hazard)
	hazard.set_physics_process(false)
	return hazard
func run():
	await process_frame
	for kind in ["steam","electric","collapse"]:
		var reference = make_hazard(kind)
		if kind == "collapse": reference.change_phase("warning")
		reference.advance(17.345)
		for hz in [30,60,120,144]:
			var h = make_hazard(kind)
			if kind == "collapse": h.change_phase("warning")
			for i in int(17.345*hz): h.advance(1.0/hz)
			h.advance(17.345 - floor(17.345*hz)/hz)
			check(h.phase == reference.phase and absf(h.elapsed-reference.elapsed)<0.00001,"%s deterministic %d Hz" % [kind,hz])
			h.free()
		reference.free()
	var h = make_hazard("steam")
	h.advance(2.0);check(h.phase == "warning","warning begins exactly at idle boundary")
	h.advance(1.0);check(h.phase == "active","active begins exactly after warning")
	h.advance(1.0);check(h.phase == "recovery","recovery follows active")
	h.set_enabled(false);h.advance(40);check(h.phase == "idle" and h.elapsed == 0,"disabled clock is safe and stopped")
	h.set_enabled(true);check(h.phase == "idle","enable restarts safe cycle")
	h.placement.reset_rule = "persist_disabled"
	h.set_enabled(false)
	var encoded = JSON.parse_string(JSON.stringify(h.snapshot()))
	h.set_enabled(true);h.reset_room(encoded);check(not h.enabled,"disabled event survives JSON save restoration")
	h.placement.reset_rule = "room_entry";h.reset_room(encoded);check(h.enabled and h.phase == "idle","room-entry rule discards old phase and disable")
	h.reset_room({"version":1,"id":"wrong","disabled":true});check(h.enabled,"foreign save ID rejected")
	h.placement.warning_seconds = 0;check(not h.placement.validation_errors().is_empty(),"invalid zero warning rejected")
	h.free()
	course = load("res://scenes/haz01/course.tscn").instantiate()
	course.save_path = "/private/tmp/haz01-course-test.json"
	root.add_child(course);current_scene = course
	course.set_physics_process(false)
	for hazard in course.hazards: hazard.set_physics_process(false)
	var player = course.player
	await ticks(5)
	check(player.is_on_floor(),"safe spawn rests on permanent floor")
	# Real controller movement with touch inputs; no changes to physics.
	player.touch = {"right":true};player.press("right")
	await ticks(25)
	check(player.position.x > 150 and player.hp == 3,"walk through safe approach")
	course.restart();player.touch = {"right":true};player.press("right");player.press("right")
	await ticks(25)
	check(player.run and player.velocity.x >= 590,"sprint uses existing controller")
	player.touch = {};course.restart();await ticks(3)
	player.touch = {"jump":true};player.press("jump")
	await ticks(15)
	check(player.position.y < 500,"jump clears hazard-height zone")
	player.touch = {};course.restart();await ticks(3)
	player.press("dash");await ticks(6)
	check(player.position.x > 150 and player.invulnerable > 0,"dash preserves travel and immunity")
	# Damage boundaries use actual capsule overlaps, including its edge.
	var steam = course.hazards[1]
	player.touch = {};player.set_physics_process(false)
	player.position = Vector2(steam.position.x-15,610);player.hp=3;player.invulnerable=0
	steam.change_phase("active");await ticks(3);steam._physics_process(0)
	check(player.hp == 3,"capsule outside damage boundary is safe")
	player.position.x += 3;await ticks(3);steam._physics_process(0)
	check(player.hp == 2,"capsule edge overlap takes damage")
	steam._physics_process(0);check(player.hp == 2,"continuous overlap respects i-frames")
	player.invulnerable=0;steam.change_phase("warning");steam._physics_process(0)
	check(player.hp == 2,"warning never deals damage")
	steam.change_phase("active");player.dash_cooldown=0;player.press("dash");steam._physics_process(0)
	check(player.hp == 2,"dash immunity applies to hazards")
	steam.set_enabled(false);player.invulnerable=0;steam._physics_process(0)
	check(player.hp == 2,"disabled hazard cannot damage")
	steam.set_enabled(true);steam.placement = steam.placement.duplicate();steam.placement.prerequisite="double_jump"
	steam.change_phase("active");steam._physics_process(0);check(player.hp == 2,"unmet existing prerequisite disables danger")
	steam.placement.prerequisite=""
	# Cross each live damage volume using the unmodified controller.
	for hazard in [steam,course.hazards[2]]:
		for movement in ["walk","sprint","jump","dash"]:
			course.restart();player.touch={};player.set_physics_process(true)
			player.position=Vector2(hazard.position.x-65,620)
			await ticks(3)
			player.invulnerable=0
			hazard.change_phase("active")
			hazard.set_physics_process(true)
			player.touch={"right":true};player.press("right")
			if movement == "sprint": player.press("right")
			if movement == "jump": player.touch["jump"]=true;player.press("jump")
			if movement == "dash": player.press("dash")
			await ticks(14 if movement == "dash" else 36)
			if movement in ["walk","sprint"]:
				check(player.hp == 2,"%s active catches %s once through i-frames" % [hazard.placement.kind,movement])
			else:
				check(player.hp == 3 and player.position.x > hazard.position.x+hazard.placement.dimensions.x,"%s safely crossed by %s" % [hazard.placement.kind,movement])
			hazard.set_physics_process(false)
		player.touch={}
	# A lethal live hit uses the existing hurt signal and defers safe recovery.
	course.restart();player.touch={};player.set_physics_process(false)
	player.position=Vector2(600,610);player.hp=1;player.invulnerable=0
	steam.change_phase("active");await ticks(3);steam._physics_process(0)
	await ticks(3)
	check(player.hp == 3 and player.position == Vector2(90,620),"lethal hazard hit respawns at clear checkpoint")
	check(steam.phase == "idle" and player.invulnerable > 0,"death resets hazard cycle before control resumes")
	# Trigger platform with a genuine physics landing.
	course.restart();player.set_physics_process(true)
	player.position = Vector2(300,430)
	await ticks(30)
	var collapse = course.hazards[0]
	check(player.is_on_floor() and absf(player.position.y-480)<2,"collapse surface supports real player")
	collapse.advance(0.01);check(collapse.phase == "warning","standing triggers predictable collapse warning")
	collapse.advance(1);await ticks(3)
	check(collapse.solid_shape.disabled,"collapse removes solid collision")
	await ticks(40)
	check(player.is_on_floor() and absf(player.position.y-620)<2,"collapsed platform lands on safe escape floor")
	player.set_physics_process(false);player.position=Vector2(300,505)
	await ticks(3);collapse.advance(2)
	check(collapse.phase == "recovery" and collapse.solid_shape.disabled,"occupied reset volume delays rematerialization")
	player.position=Vector2(90,620);await ticks(3);collapse.advance(0.01);await ticks(2)
	check(collapse.phase == "idle" and not collapse.solid_shape.disabled,"clear reset restores collision")
	# Real tether eligibility and swing integration above electrical zone.
	course.restart();player.position=Vector2(770,480);player.facing=1;player.set_physics_process(true)
	await ticks(2);player.touch={"tether":true};player.press("tether")
	check(player.tether_attached,"existing grapple attaches to course anchor")
	await ticks(8);check(player.tether_attached and player.hp == 3,"grapple swing remains clear of danger zone")
	player.touch={};course.restart();player.set_physics_process(false)
	course.hazards[2].set_enabled(false)
	check(course.save_course(),"course writes isolated save")
	course.hazards[2].set_enabled(true);course.load_course()
	check(not course.hazards[2].enabled and player.position == Vector2(90,620),"load restores disable and safe checkpoint")
	check(course.hazards[1].phase == "idle" and player.invulnerable == 1.5,"load resets active cycles with recovery immunity")
	course.restart();check(course.hazards[2].enabled,"fresh room re-entry restores default enable state")
	player.position=Vector2(1170,620);player.set_physics_process(true);await ticks(20)
	check(player.hp == 3 and player.is_on_floor(),"exit area remains safely standable")
	course.queue_free();await process_frame
	print("HAZ01: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
