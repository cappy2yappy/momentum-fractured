extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	await process_frame
	root.get_node("GameState").new_game()
	var navigator := root.get_node("SceneNavigator")
	var output := OS.get_cmdline_user_args()[0]
	for room_index in [5, 9]:
		navigator.goto_scene("res://scenes/rooms/room_%02d_route.tscn" % room_index, "spawn_default")
		await create_timer(0.8).timeout
		var player = current_scene.get_node("Kaze")
		player.set_physics_process(false)
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(output.path_join("room_%02d.png" % room_index))
		if room_index == 9:
			root.get_node("GameState").visit_room("room_06_route")
			root.get_node("GameState").visit_room("room_07_route")
			root.get_node("GameState").visit_room("room_08_route")
			current_scene.get_node("HUD").set_overlay("map")
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(output.path_join("survey_map.png"))
			current_scene.get_node("HUD").set_overlay("")
	current_scene.queue_free()
	current_scene = null
	await process_frame
	print("VISUAL CAPTURE: complete")
	quit()
