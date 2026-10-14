extends SceneTree
var failures = 0
func _init(): call_deferred("run")
func check(ok, message):
	print("PASS: " if ok else "FAIL: ", message)
	if not ok: failures += 1
func run():
	await process_frame
	var w = load("res://scenes/main.tscn").instantiate(); root.add_child(w); current_scene = w
	w.set_physics_process(false); w.player.set_physics_process(false)
	var p = w.player
	p.position = Vector2(800, 500); p.velocity = Vector2.ZERO; p.move_and_slide()
	p.tether_unlocked = true; p.dash_unlocked = true
	var anchor = p.tether_origin() + Vector2(120, -160)
	check(p.apply_tether(anchor), "Airborne transition fixture accepts a clear tether")
	p.velocity = Vector2(700, -200); p.press("dash")
	check(not p.tether_attached and not p.tether_taut, "Tether-to-dash releases rope before dash skips constraints")
	check(p.velocity == Vector2(920,0) and p.dash_time == 0.18 and p.dash_cooldown == 0.58, "Transition preserves approved dash impulse and timing")
	check(not p.apply_tether(anchor), "Dash-to-tether rejects attachment while dash skips rope physics")
	check(not p.can_tether_anchor(anchor), "Availability indicator uses the same dash attachment restriction")
	p.dash_time = 0; p.dash_cooldown = 0; p.tether_cooldown = 0
	check(p.apply_tether(anchor), "Finished dash permits the normal airborne tether")
	var release_velocity = Vector2(700,-200); p.velocity = release_velocity; p.release_tether()
	check(p.velocity == release_velocity, "Ordinary release still preserves exact incoming velocity")
	p.invulnerable = 0.24; var hp = p.hp
	check(not p.damage(Vector2.ZERO) and p.hp == hp, "Approved dash protection still rejects damage")
	w.queue_free(); current_scene = null
	for i in 3: await process_frame
	print("TRAVERSAL TRANSITIONS: %d failure(s)"%failures); quit(1 if failures else 0)
