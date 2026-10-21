extends SceneTree
var w
func _init(): call_deferred("run")
func freeze():
	w.set_physics_process(false);w.player.set_physics_process(false)
	for enemy in w.enemies: enemy.set_physics_process(false);enemy.set_process(false)
func run():
	if "--test" not in OS.get_cmdline_user_args(): quit(2);return
	w = load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene = w
	w.player.double_jump = true;w.completed = true
	w.player.sprite.frame = 0
	for mode in ["before-legacy","after-authored","edited-authored"]:
		w.authored_r18_enabled = mode != "before-legacy"
		w.authored_r18_path = "res://tools/ld_tools_01/r_18_pump_gallery_layout.tscn" if mode == "edited-authored" else w.RoomCreatorPilot.DEFAULT_LAYOUT
		w.build_room(18);freeze()
		w.player.position = Vector2(1200,1148 if mode == "edited-authored" else 1178);w.player.velocity = Vector2.ZERO
		w.player.set_physics_process(true)
		for tick in 20: await physics_frame
		w.player.set_physics_process(false);w.player.animation_clock = 0;w.player.animate(0)
		w.player.set_process(false);w.player.age = 0
		w.camera.position_smoothing_enabled = false;w.camera.position = Vector2(0,-110);w.camera.zoom = Vector2.ONE
		w.camera.reset_smoothing();w.message_time = 0
		w.hud.set_process(false);w.hud.queue_redraw()
		w.queue_redraw()
		await process_frame;await process_frame;await RenderingServer.frame_post_draw
		var path = "res://docs/ld_tools_02/evidence/" + mode + ".png"
		var result = root.get_texture().get_image().save_png(path)
		print("PASS: " if result == OK else "FAIL: ","Native gameplay-scale capture ",mode)
	w.queue_free();current_scene = null
	await process_frame;await process_frame;quit()
