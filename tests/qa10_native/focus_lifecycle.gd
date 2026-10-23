extends "res://tests/tr08_canal_hang_probe.gd"
## Controlled positive/negative experiment for fixture lifetime versus SceneTree pause.
## Uses the real normal-save fixture, production HUD, and InputEventKey path.
## Keep the pre-correction construction here as a positive control on both pins.
func load_fixture():
	for code in [KEY_A,KEY_D,KEY_SPACE,KEY_SHIFT,KEY_E]: key(code,false)
	if is_instance_valid(w):
		w.queue_free(); await process_frame; await process_frame
	var file = FileAccess.open(save_path(),FileAccess.WRITE)
	file.store_string(FileAccess.get_file_as_string(FIXTURE)); file.close()
	w=load("res://scenes/main.tscn").instantiate(); root.add_child(w); current_scene=w

func run():
	await process_frame
	await load_fixture()
	# Establish the experiment's initial condition before any observations.
	paused = false
	w.hud.pause_open = false
	key(KEY_A, true)
	w.hud.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	await wait_ticks(12)
	check(paused and w.hud.pause_open, "Production focus loss pauses the tree and opens pause HUD")
	check(w.player.is_physics_processing() and not w.player.can_process(), "Enabled player physics cannot process while tree is paused")
	check(Input.is_physical_key_pressed(KEY_A) and Input.is_action_pressed("left") and w.player.held("left"), "Physical key, action, and player held input all remain active")
	check(w.player.age == 0 and w.player.position == Vector2(330,1158) and w.player.velocity == Vector2.ZERO and not w.player.is_on_floor(), "Paused fixture matches stationary unsupported Canal signature")
	check(not w.cinematic_transitions.armed.get(0,false), "Paused world never arms the doorway")
	w.hud.toggle_pause()
	w.hud.set_script(load("res://tests/fixtures/transition_test_hud.gd"))
	w.hud.world = w
	w.hud.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(paused and w.hud.pause_open, "Existing derived notification handler still invokes production base pause")
	await load_fixture()
	key(KEY_A,true)
	await wait_ticks(12)
	check(paused and not w.hud.pause_open, "Replacing the world inherits paused tree with a fresh closed pause HUD")
	check(w.player.age == 0 and w.player.position == Vector2(330,1158), "Replacement fixture also never receives player physics")
	w.hud.set_script(load("res://tests/fixtures/transition_test_hud.gd"))
	w.hud.world = w
	await wait_ticks(12)
	check(paused and w.player.age == 0, "Installing the existing automation HUD does not clear inherited pause")
	# Resume through the existing HUD/input behavior, not player/controller writes.
	key(KEY_ESCAPE,true); await process_frame; key(KEY_ESCAPE,false)
	check(paused and w.hud.pause_open, "First Esc opens the new HUD and leaves inherited pause in place")
	key(KEY_ESCAPE,true); await process_frame; key(KEY_ESCAPE,false)
	await wait_ticks(12)
	check(not paused and w.player.can_process() and w.player.age > 0, "Second Esc restores actual player physics")
	check(w.player.position.x < 330 and w.player.is_on_floor() and w.cinematic_transitions.armed.get(0,false), "Same held input moves, establishes floor support, and arms the doorway after resume")
	key(KEY_A,false)
	w.queue_free(); current_scene = null
	for i in 3: await process_frame
	print("QA10 LIFECYCLE: %d checks, %d failure(s)" % [checks, failures])
	quit(1 if failures else 0)
