extends SceneTree

var failures := 0

func _init() -> void:
	call_deferred("_run")

func check(condition: bool, message: String) -> void:
	print("PASS: " if condition else "FAIL: ", message)
	if not condition:
		failures += 1

func _run() -> void:
	var player = load("res://scenes/kaze.tscn").instantiate()
	root.add_child(player)
	player.set_physics_process(false)
	var zone_a := Node.new()
	var zone_b := Node.new()
	root.add_child(zone_a)
	root.add_child(zone_b)
	player.global_position = Vector2(100, 500)
	player.set_water_zone(zone_a, true, 430.0)
	player.set_water_zone(zone_b, true, 430.0)
	player.set_water_zone(zone_a, false, 430.0)
	check(player.in_water, "Leaving one overlapping volume retains swimming")
	check(player._is_fully_submerged(), "Depth below the surface identifies full submersion")
	var anchor := Node2D.new()
	anchor.position = Vector2(100, 300)
	anchor.add_to_group("grapple_anchor")
	root.add_child(anchor)
	check(not player._try_start_grapple(anchor.position), "Submerged tether cannot attach even to an in-range anchor")
	player.velocity = Vector2(0, 240)
	for i in 60:
		player._apply_swim_vertical(1.0 / 60.0)
	check(is_zero_approx(player.velocity.y), "Neutral input settles instead of sinking indefinitely")
	Input.action_press("swim_down")
	for i in 60:
		player._apply_swim_vertical(1.0 / 60.0)
	check(is_equal_approx(player.velocity.y, 180.0), "Down input provides controlled descent")
	Input.action_release("swim_down")
	Input.action_press("swim_up")
	for rate in [30, 60, 120]:
		player.velocity.y = 180.0
		for i in rate:
			player._apply_swim_vertical(1.0 / rate)
		check(is_equal_approx(player.velocity.y, -180.0), "Ascent speed is consistent at %d physics ticks" % rate)
	Input.action_release("swim_up")
	player.global_position.y = 440.0
	check(not player._is_fully_submerged(), "Surface band allows an above-water tether")
	player.set_water_zone(zone_b, false, 430.0)
	check(not player.in_water, "Leaving the final volume restores air movement")
	player.set_water_zone(zone_a, true, 430.0)
	player.respawn(Vector2(0, 0))
	check(not player.in_water and player.water_surfaces.is_empty(), "Respawn clears stale underwater state")
	player.queue_free()
	zone_a.queue_free()
	zone_b.queue_free()
	anchor.queue_free()
	await process_frame
	print("SWIMMING REGRESSION: %d failure(s)" % failures)
	quit(1 if failures else 0)
