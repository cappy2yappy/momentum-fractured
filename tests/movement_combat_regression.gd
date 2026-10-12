extends SceneTree

var failures := 0

func _init() -> void:
	call_deferred("_run")

func check(ok: bool, message: String) -> void:
	print("PASS: " if ok else "FAIL: ", message)
	if not ok:
		failures += 1

func _run() -> void:
	await process_frame
	var state := root.get_node("GameState")
	state.new_game()
	var player = load("res://scenes/kaze.tscn").instantiate()
	root.add_child(player)
	player.set_physics_process(false)
	player.position = Vector2(400, 400)
	var anchor := Node2D.new()
	anchor.position = Vector2(400, 200)
	anchor.add_to_group("grapple_anchor")
	root.add_child(anchor)
	await physics_frame
	check(player._try_start_grapple(anchor.position), "Authored anchor accepts direct aim")
	player.velocity = Vector2(700, 0)
	for rate in [30, 60, 120]:
		player.velocity = Vector2(700, 0)
		for tick in rate:
			player._apply_horizontal_movement(1.0, 1.0 / rate)
		check(is_equal_approx(player.velocity.x, 700), "Run acceleration cannot damp an active swing at %d Hz" % rate)
	player._release_grapple()
	for rate in [30, 60, 120]:
		player.velocity = Vector2(700, -280)
		for tick in rate / 4:
			player._apply_horizontal_movement(0.0, 1.0 / rate)
		check(player.velocity.x > 675 and player.velocity.y == -280, "Release retains ballistic momentum at %d Hz" % rate)
	player.velocity = Vector2(700, 0)
	player._apply_horizontal_movement(-1.0, 0.25)
	check(player.velocity.x < 300, "Opposite input still brakes high-speed travel")
	player._try_start_grapple(anchor.position)
	player._begin_dash()
	check(player.is_dashing and not player.grapple_active, "Tether-to-dash releases rope instead of stretching it")
	check(not player._try_start_grapple(anchor.position), "Dash-to-tether cannot attach while dash skips rope constraints")
	var hp: float = player.get_current_health()
	check(not player.take_damage(10) and player.get_current_health() == hp, "Dash rejects projectile/hazard damage")
	var enemy_hit := Hitbox.new()
	enemy_hit.collision_layer = 32
	enemy_hit.collision_mask = 2
	enemy_hit.damage = 10
	enemy_hit.knockback = Vector2(220, -80)
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(40, 60)
	collision.shape = shape
	enemy_hit.add_child(collision)
	enemy_hit.position = player.position + Vector2(150, 0)
	root.add_child(enemy_hit)
	enemy_hit.activate(2.0)
	enemy_hit.position = player.position
	for tick in 4:
		await physics_frame
	check(player.get_current_health() == hp, "Real melee collision also respects dash immunity")
	enemy_hit.position.x += 150
	for tick in 3:
		await physics_frame
	player._end_dash()
	enemy_hit.activate(2.0, true)
	enemy_hit.position = player.position
	for tick in 4:
		await physics_frame
	check(player.get_current_health() == hp - 10, "Real melee collision deals exactly one hit")
	check(player.velocity == Vector2(220, -80), "Accepted melee applies authored knockback")
	check(not player.take_damage(12), "Melee and hazards share the damage immunity window")
	player.damage_invincibility_timer = 0.0
	check(player.take_damage(5), "Damage resumes after the immunity window")
	player._perform_attack()
	player.grapple_active = true
	player.die()
	check(not player.hitbox.is_active and not player.grapple_active and not player.is_dashing, "Death disables active attacks and traversal state")
	player.respawn(Vector2.ZERO)
	check(player.damage_invincibility_timer == 0 and player.combo_step == 0 and player.dash_buffer_timer == 0, "Respawn removes stale combat and buffered dash state")
	enemy_hit.queue_free()
	anchor.queue_free()
	player.queue_free()
	await create_timer(0.2).timeout
	print("MOVEMENT COMBAT REGRESSION: %d failure(s)" % failures)
	quit(1 if failures else 0)
