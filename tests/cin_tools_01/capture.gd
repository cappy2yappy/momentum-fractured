extends SceneTree
## Real wall-clock playback, no --fixed-fps or movie mode. JPEG timestamps are
## recorded after actual post-draw; encoder resamples those times without speeding up.
var demo
var frames: Array = []
var started = 0
var last_capture = -1.0
var stage_seen = false
var before = 0
var checks = 0
var failures = 0
var capture_dir = "res://build/cin_tools_01/capture"
func _init(): call_deferred("run")
func check(ok,label):
	checks += 1
	print("PASS: " if ok else "FAIL: ",label)
	if not ok: failures += 1
func key(code, pressed):
	var e = InputEventKey.new()
	e.physical_keycode = code; e.keycode = code; e.pressed = pressed
	Input.parse_input_event(e); Input.flush_buffered_events()
func shot(label):
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(capture_dir + "/" + label + ".png")
func run():
	await process_frame
	DirAccess.make_dir_recursive_absolute(capture_dir)
	# Native preview: rendered example and UI, standard and reduced.
	var preview = load("res://tools/cin_tools_01/preview.tscn").instantiate()
	root.add_child(preview); current_scene = preview
	preview.scrub(.8)
	await process_frame
	await shot("authoring_preview")
	preview.reduced_preview = true; preview.restart(); preview.scrub(.2)
	await process_frame
	await shot("reduced_preview")
	preview.queue_free(); current_scene = null
	await process_frame
	demo = load("res://tools/cin_tools_01/demo.tscn").instantiate()
	root.add_child(demo); current_scene = demo
	var w = demo.world
	var c = w.cinematic_transitions
	before = c.request_count
	# Suppress unrelated encounter AI, preserve real player physics and input.
	for enemy in w.enemies: enemy.set_physics_process(false)
	await process_frame
	await shot("01_before_trigger")
	started = Time.get_ticks_usec()
	var did_walk = false
	var did_interact = false
	var released_walk = false
	var released_interact = false
	var shot_intro = false
	var shot_stair = false
	var finished_at = -1.0
	while Time.get_ticks_usec() - started < 14000000:
		await process_frame
		var t = (Time.get_ticks_usec() - started) / 1000000.0
		if t > .25 and not did_walk:
			key(KEY_D,true); did_walk = true
		if t > .55 and not released_walk:
			key(KEY_D,false); released_walk = true
		if t > .8 and not did_interact:
			key(KEY_E,true); did_interact = true
		if t > .9 and not released_interact:
			key(KEY_E,false); released_interact = true
		if c.owning and c.age > .55 and not shot_intro:
			await shot("02_native_timeline"); shot_intro = true
		if c.tr08.stair.phase == "climb" and c.tr08.stair.elapsed > .9 and not shot_stair:
			await shot("03_tr08_staircase"); shot_stair = true
		if w.room == 17 and not c.owning and not c.tr08.owns() and w.transition <= 0:
			if finished_at < 0:
				finished_at = t
				await shot("04_control_restored")
			if t > finished_at + .7: break
		if t - last_capture >= 1.0 / 30.0:
			await RenderingServer.frame_post_draw
			var actual = (Time.get_ticks_usec() - started) / 1000000.0
			var path = "%s/frame_%05d.jpg" % [capture_dir,frames.size()]
			root.get_texture().get_image().save_jpg(path,.83)
			frames.append({"time":actual,"path":ProjectSettings.globalize_path(path)})
			last_capture = actual
	check(shot_intro and shot_stair,"Real E input entered authored timeline and TR-08 staircase")
	check(w.room == 17 and c.request_count == before + 1,"Real-time captured playback completes one authorized transition")
	check(w.player.is_physics_processing() and w.player.sprite.visible,"Real-time playback restores Kaze control")
	var metadata = {"clock":"Time.get_ticks_usec, real post-draw captures, no fixed FPS","frames":frames,"renderer":RenderingServer.get_video_adapter_name(),"elapsed":(Time.get_ticks_usec()-started)/1000000.0}
	var file = FileAccess.open(capture_dir+"/timing.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(metadata,"  ")); file.close()
	demo.queue_free(); current_scene = null
	for i in 4: await process_frame
	print("CIN-TOOLS-01 CAPTURE: %d checks, %d failure(s)" % [checks,failures])
	quit(1 if failures else 0)
