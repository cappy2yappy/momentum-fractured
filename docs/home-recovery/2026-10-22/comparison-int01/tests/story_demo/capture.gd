extends SceneTree
func _init(): call_deferred("run")
func shot(name):
	for frame in 5: await process_frame
	RenderingServer.force_draw(false)
	var destination = OS.get_cmdline_user_args()[0].path_join(name)
	root.get_texture().get_image().save_png(destination)
func run():
	var w = load("res://tests/story_demo/demo.tscn").instantiate()
	root.add_child(w); current_scene = w
	w.set_physics_process(false); w.player.set_physics_process(true)
	w.player.position = Vector2(700,1298)
	w.camera.position_smoothing_enabled = false
	w.camera.zoom = Vector2(0.8,0.8)
	w.camera.reset_smoothing()
	w.player.set_physics_process(false)
	await shot("before-inspection.png")
	w.story.interact(w)
	await shot("after-inspection.png")
	w.story.panel.close()
	w.player.position = Vector2(1420,1298)
	w.player.set_physics_process(true)
	w.story.interact(w)
	await shot("activation-inspection.png")
	w.story.panel.close()
	w.player.set_physics_process(false)
	await shot("after-activation.png")
	w.queue_free(); await process_frame
	quit()
