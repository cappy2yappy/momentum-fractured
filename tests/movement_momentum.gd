extends SceneTree
var failures = 0
var comparisons = 0
var world
var original
func _init(): call_deferred("_run")
func check(ok, message):
	print("PASS: " if ok else "FAIL: ", message)
	if not ok: failures += 1
func pair_reset(at = Vector2(220, 1298)):
	for p in [world.player, original]:
		p.position = at
		p.velocity = Vector2.ZERO
		p.run = false
		p.age = 0
		p.last_tap = -10
		p.dash_time = 0
		p.dash_cooldown = 0
		p.jump_buffer = 0
		p.air_used = false
		p.coyote = 0
		p.invulnerable = 0
		p.double_jump = true
		p.dash_unlocked = true
func ticks(count):
	for i in count:
		await physics_frame
		comparisons += 1
		if world.player.position.distance_to(original.position) > 0.01 or world.player.velocity.distance_to(original.velocity) > 0.01:
			failures += 1
			print("FAIL: differential frame ", comparisons, " position/velocity ", world.player.position, " / ", original.position)
			return
func _run():
	await process_frame
	world = load("res://scenes/main.tscn").instantiate()
	root.add_child(world); current_scene = world
	world.set_physics_process(false)
	original = load("res://tests/fixtures/player_alpha052.gd").new()
	world.add_child(original)
	world.player.momentum.enabled = false
	pair_reset()
	await ticks(5)
	Input.action_press("right"); await ticks(30); Input.action_release("right"); await ticks(20)
	check(comparisons == 55 and failures == 0, "Differential walk acceleration and braking match rollback controller")
	pair_reset(); await ticks(4)
	for p in [world.player, original]: p.run = true
	Input.action_press("right"); await ticks(35)
	print("METRIC: sprint=", world.player.velocity.x)
	check(is_equal_approx(world.player.velocity.x, 600), "Base sprint reaches 600 px/s")
	Input.action_release("right"); await ticks(20)
	pair_reset(); await ticks(4)
	var floor_y = world.player.position.y
	Input.action_press("jump"); await ticks(30)
	Input.action_release("jump"); await ticks(1)
	Input.action_press("jump"); await ticks(30); Input.action_release("jump")
	print("METRIC: double_jump_rise_at_second_apex=", floor_y - world.player.position.y)
	check(failures == 0, "Held and double jump trajectories match rollback")
	pair_reset(); await ticks(4)
	Input.action_press("jump"); await ticks(3); Input.action_release("jump"); await ticks(35)
	check(failures == 0, "Tap jump trajectory matches rollback")
	pair_reset(Vector2(2540, 900)); Input.action_press("right"); await ticks(12)
	Input.action_press("jump"); await ticks(18); Input.action_release("jump"); Input.action_release("right")
	check(failures == 0, "Wall slide and wall jump match rollback")
	pair_reset(); await ticks(4)
	var start_x = world.player.position.x
	Input.action_press("dash"); await ticks(12); Input.action_release("dash")
	print("METRIC: dash_ticks12_distance=", world.player.position.x - start_x)
	check(failures == 0, "Dash trajectory and cooldown match rollback")
	world.player.set_physics_process(false); original.set_physics_process(false)
	world.build_room(4)
	for enemy in world.enemies: enemy.set_physics_process(false)
	for p in [world.player, original]:
		p.position = Vector2(1190, 900); p.velocity = Vector2(300, 80); p.facing = 1
		p.move_and_slide()
		check(p.apply_tether(world.tether_anchors[1]), "Clear baseline swing attaches")
	for i in 60:
		for p in [world.player, original]: p.integrate_tether_swing(1.0 / 60, 1.0 if i < 30 else -1.0)
	check(world.player.position.distance_to(original.position) < 0.001 and world.player.velocity.distance_to(original.velocity) < 0.001, "Bidirectional swing pumping is identical to rollback")
	var release_velocity = world.player.velocity
	world.player.release_tether()
	check(world.player.velocity == release_velocity, "Release preserves exact velocity")
	world.build_room(0)
	world.player.position = Vector2(800, 500); world.player.facing = 1
	world.player.velocity = Vector2.ZERO; world.player.move_and_slide()
	var origin = world.player.tether_origin()
	for distance in [399.0, 400.0, 420.0, 440.0, 441.0, 480.0]:
		var anchor = origin + Vector2(distance * 0.6, -distance * 0.8)
		check(world.player.can_tether_anchor(anchor) == (distance <= 440), "Range boundary %.0f px" % distance)
	check(not world.player.can_tether_anchor(origin + Vector2(-101, -100)), "Behind-facing rejection preserved")
	check(not world.player.can_tether_anchor(origin + Vector2(100, -34)), "Anchor must remain above origin")
	check(not world.player.can_tether_anchor(origin + Vector2(20, -40)), "Minimum rope distance preserved")
	var near = origin + Vector2(120, -100)
	var far = origin + Vector2(200, -180)
	world.tether_anchors.assign([far, near])
	check(world.select_tether_anchor() == near, "Nearest valid target wins")
	world.add_platform(Rect2(origin + Vector2(50, -250), Vector2(30, 240)))
	await physics_frame; await physics_frame
	check(not world.player.can_tether_anchor(near), "Solid terrain blocks initial rope ray")
	world.player.grapple_clearance_check = false
	check(world.player.can_tether_anchor(near), "Clearance check can be reverted independently for feel review")
	world.player.grapple_clearance_check = true
	world.build_room(0)
	var object = load("res://scripts/grapple_anchor.gd").new()
	object.position = near; world.geometry.add_child(object)
	world.player.tether_unlocked = true
	check(world.grapple_candidates().has(near), "Reusable dedicated anchor enters candidate interface")
	object.enabled = false
	check(not world.grapple_candidates().has(near), "Disabled object cannot attach")
	object.enabled = true; object.required_ability = "unknown"
	check(not world.grapple_candidates().has(near), "Unknown object requirement fails closed")
	check(world.player.unlock_speed_upgrade("stride_1") and not world.player.unlock_speed_upgrade("stride_1"), "Explicit first upgrade unlocks once")
	check(not world.player.unlock_speed_upgrade("stride_99"), "Unknown upgrade rejected")
	check(world.player.movement_target_speed(false) == 420 and world.player.movement_target_speed(true) == 630, "Permanent caps are 420 walk / 630 run")
	var m = world.player.momentum
	m.enabled = true
	for i in 600: m.tick(1.0/60, Vector2.ZERO, 1.0, true, false)
	check(m.meter == 0, "Pressing movement against obstruction cannot farm meter")
	for i in 600: m.tick(1.0/60, Vector2(10, 0), 1.0, true, false)
	check(m.meter == 1, "Purposeful 600 px/s running fills and caps normalized meter")
	check(is_equal_approx(world.player.movement_target_speed(true), 667.8), "Combined driven run target capped at 667.8 px/s")
	check(world.player.movement_target_speed(false) == 420, "Temporary bonus never changes precision walk target")
	# Validate integration using real collision travel, not only meter unit inputs.
	world.build_room(0); world.player.position = Vector2(220, 1298)
	world.player.velocity = Vector2.ZERO; world.player.invulnerable = 0
	m.reset(); world.player.set_physics_process(true)
	for i in 5: await physics_frame
	world.player.run = true; Input.action_press("right")
	for i in 120: await physics_frame
	Input.action_release("right"); world.player.set_physics_process(false)
	print("METRIC: live_upgraded_run=", world.player.velocity.x, " meter=", m.meter)
	check(m.meter > 0.2 and world.player.velocity.x > 630 and world.player.velocity.x <= 667.8, "Real upgraded running builds meter and stays under driven cap")
	world.player.position = Vector2(2585, 1298); world.player.velocity = Vector2.ZERO
	m.reset(); world.player.set_physics_process(true); world.player.run = true
	Input.action_press("right")
	for i in 120: await physics_frame
	Input.action_release("right"); world.player.set_physics_process(false)
	check(m.meter == 0, "Real wall collision prevents stationary running exploit")
	m.meter = 1
	m.take_damage()
	check(is_equal_approx(m.meter, 0.5) and m.suppression == 1.2, "Damage penalty removes 0.5 and suppresses gain")
	for i in 60: m.tick(1.0/60, Vector2.ZERO, 0.0, false, false)
	check(m.meter < 0.06, "Idle decay is 0.45 per second")
	m.reset(); m.distance_since_reward = 200
	m.reward_transition("dash", 0, 920)
	check(m.meter == 0, "Stationary dash cannot earn a transition reward")
	m.reward_transition("dash", 160, 920)
	check(is_equal_approx(m.meter, 0.08), "Useful traveled dash earns one transition reward")
	m.distance_since_reward = 200; m.transition_cooldown = 0
	m.reward_transition("dash", 160, 920)
	check(is_equal_approx(m.meter, 0.08), "Repeating one technique cannot farm chain rewards")
	m.reward_transition("tether", 180, 500)
	check(is_equal_approx(m.meter, 0.16), "Different traveled technique earns chain reward")
	world.player.invulnerable = 0; world.player.hp = 3; m.meter = 1
	check(world.player.damage(Vector2.ZERO) and m.meter == 0.5, "Real damage path applies momentum penalty")
	world.save_path = "user://momentum_regression_only.json"; world.test_mode = false
	check(world.save_progress(), "Schema 7 saves prototype upgrade")
	world.test_mode = true; world.player.speed_upgrade_level = 0; world.load_progress()
	check(world.player.speed_upgrade_level == 1 and m.meter == 0, "Save restores permanent state and resets temporary meter")
	var data = JSON.parse_string(FileAccess.get_file_as_string(world.save_path))
	data.version = 6; data.erase("speed_upgrade_level")
	var file = FileAccess.open(world.save_path, FileAccess.WRITE); file.store_string(JSON.stringify(data)); file.close()
	world.load_progress()
	check(world.player.speed_upgrade_level == 0, "Schema 6 defaults to unchanged baseline speeds")
	world.player.restore_speed_upgrade(999)
	check(world.player.speed_upgrade_level == 0, "Invalid upgrade level cannot raise caps")
	for invalid in [true, "1", 1.5, -1]:
		world.player.restore_speed_upgrade(invalid)
		check(world.player.speed_upgrade_level == 0, "Invalid saved type/value rejected: %s" % str(invalid))
	m.meter = 1; world.build_room(0)
	check(m.meter == 0, "Room rebuild resets temporary momentum")
	world.player.unlock_speed_upgrade("stride_1"); m.meter = 1; world.respawn()
	world.player.set_physics_process(false)
	check(world.player.speed_upgrade_level == 1 and m.meter == 0, "Checkpoint respawn preserves upgrade and clears meter")
	world.room = 10; world.opened_kunai_gates.erase("skyworks_wind_intake")
	check(not world.can_enter(11), "Speed upgrade cannot bypass Wind progression flag")
	world.room = 11; world.opened_kunai_gates.erase("foundry_electric_relay")
	check(not world.can_enter(12), "Speed upgrade cannot bypass Electric progression flag")
	# Document pre-existing state gaps separately from successful progression checks.
	world.build_room(7); world.player.set_physics_process(false)
	world.opened_kunai_gates.erase("relay_electric_seal"); world.completed = false
	world.player.position = Vector2(2200, 1300); world.interact()
	print("KNOWN BASELINE GAP: relay completes behind unopened Electric seal=", world.completed)
	world.build_room(2); world.secret = false
	world.opened_kunai_gates.erase("cistern_wind_cache")
	world.player.position = Vector2(2300, 830); world._physics_process(0)
	print("KNOWN BASELINE GAP: proximity secret behind unopened Wind seal=", world.secret)
	print("METRIC: differential_frames=", comparisons)
	world.queue_free(); current_scene = null
	for i in 3: await process_frame
	print("MOVEMENT MOMENTUM: %d failure(s)" % failures)
	quit(1 if failures else 0)
