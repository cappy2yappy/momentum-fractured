extends SceneTree
var failures=0
var w
func _init(): call_deferred("run")
func check(ok,label):
	print("PASS: " if ok else "FAIL: ",label)
	if not ok: failures+=1
func key(code,pressed):
	var e=InputEventKey.new();e.physical_keycode=code;e.keycode=code;e.pressed=pressed;Input.parse_input_event(e);Input.flush_buffered_events()
func wait_ticks(count):
	for i in count: await physics_frame
func run():
	await process_frame
	w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w
	check(w.embodied_transitions.production_active(),"ART04 preview explicitly enabled for native fixture")
	w.camera.zoom=Vector2.ONE;w.camera.position_smoothing_enabled=false
	for running in [false,true]:
		w.build_room(13);w.player.double_jump=true;w.player.position=Vector2(150,1198);w.player.velocity=Vector2.ZERO
		for e in w.enemies: e.set_physics_process(false)
		await wait_ticks(5)
		key(KEY_A,true);await wait_ticks(2);key(KEY_A,false);await wait_ticks(1)
		if not running: await wait_ticks(18)
		key(KEY_A,true);await wait_ticks(40);key(KEY_A,false);await wait_ticks(60)
		check(w.player.is_on_floor() and absf(w.player.position.y-1200)<1,"Native Windows %s stop at Canal wall"%('run' if running else 'walk'))
		key(KEY_D,true);await wait_ticks(12);key(KEY_D,false);await wait_ticks(20)
		check(w.player.is_on_floor() and w.player.position.distance_to(Vector2(120,1200))<85,"Native key reapproach enters existing E radius")
		key(KEY_E,true);await wait_ticks(1);key(KEY_E,false);await wait_ticks(48)
		check(w.room==0 and w.player.is_on_floor(),"Native E Canal transition completes safely")
	# ART04 contact pilots exercise the actual E event and full loader clock.
	for pair in [[14,17],[17,14]]:
		w.build_room(pair[0]);w.player.tether_unlocked=true;w.player.dash_unlocked=true
		var at=Vector2(1450,480) if pair[0]==14 else Vector2(1680,1300)
		w.player.position=at-Vector2(0,2);w.player.velocity=Vector2.ZERO
		for e in w.enemies: e.set_physics_process(false)
		await wait_ticks(5);key(KEY_E,true);await wait_ticks(1);key(KEY_E,false);await wait_ticks(48)
		check(w.room==pair[1] and w.player.is_on_floor() and w.player.sprite.visible,"Native ART04 stair %d->%d cleanup and arrival"%pair)
	w.embodied_transitions.depth_demo=true
	for pair in [[14,13],[13,14]]:
		w.build_room(pair[0]);w.player.double_jump=true
		for portal in w.expansion.portals(pair[0]):
			if portal.target==pair[1]: w.player.position=portal.at-Vector2(0,2)
		w.player.velocity=Vector2.ZERO
		for e in w.enemies: e.set_physics_process(false)
		await wait_ticks(5);key(KEY_E,true);await wait_ticks(1);key(KEY_E,false);await wait_ticks(48)
		check(w.room==pair[1] and w.player.is_on_floor() and w.player.sprite.visible,"Native ART04 depth doorway %d->%d cleanup and arrival"%pair)
	print("WINDOWS SCRIPTED PLAYTEST: %d failure(s); not a human campaign playthrough"%failures)
	w.queue_free();current_scene=null
	for i in 3: await process_frame
	quit(1 if failures else 0)
