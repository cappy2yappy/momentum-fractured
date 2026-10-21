extends SceneTree
# Software-GL capture of the approved ST-04 copy: opening, R11 label, announcement, objective on map.
func _init(): call_deferred("_run")
func shot(path):
	await process_frame
	RenderingServer.force_draw(false)
	root.get_texture().get_image().save_png(path)
func _run():
	await process_frame
	var output = OS.get_cmdline_user_args()[0]
	var world = load("res://scenes/main.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	world.set_physics_process(false)
	world.player.set_physics_process(false)
	await shot(output.path_join("opening.png"))
	world.hud.toggle_map()
	await shot(output.path_join("opening_map_objective.png"))
	world.hud.toggle_map()
	world.hud.toggle_loadout()
	await shot(output.path_join("opening_kit_objective.png"))
	world.hud.toggle_loadout()
	world.player.double_jump = true
	world.player.tether_unlocked = true
	world.player.dash_unlocked = true
	world.boss_defeated = true
	world.completed = true
	for id in ["undercroft_sigil", "terrace_west", "terrace_fire_cache"]: world.relay_fragments[id] = true
	world.opened_kunai_gates["skyworks_wind_intake"] = true
	world.save_path = "user://st04_capture.json"
	world.build_room(11)
	world.player.position = Vector2(1720, 1298)
	world.player.velocity = Vector2.ZERO
	world.camera.position_smoothing_enabled = false
	world.camera.reset_smoothing()
	world.message_time = 0
	world.queue_redraw()
	await shot(output.path_join("r11_label.png"))
	world.interact()
	await shot(output.path_join("r11_announcement.png"))
	world.hud.toggle_map()
	await shot(output.path_join("r11_map_objective.png"))
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://st04_capture.json"))
	print("ST04 CAPTURE: complete")
	quit()
