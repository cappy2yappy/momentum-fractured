extends SceneTree
func _init(): call_deferred("_run")
func _run():
	await process_frame
	var world=load("res://scenes/main.tscn").instantiate()
	root.add_child(world)
	current_scene=world
	world.set_physics_process(false)
	world.player.set_physics_process(false)
	world.player.double_jump=true
	world.player.tether_unlocked=true
	world.player.dash_unlocked=true
	for element in ["wind","fire","electric"]: world.player.unlock_kunai(element)
	for id in ["undercroft_sigil","terrace_west","terrace_fire_cache"]: world.relay_fragments[id]=true
	world.completed=true;world.boss_defeated=true;world.message_time=0
	world.opened_kunai_gates["terrace_return_relay"]=true
	for index in 13: world.build_room(index)
	var output=OS.get_cmdline_user_args()[0]
	for index in [10,11,12]:
		world.build_room(index)
		world.player.position=Vector2(1900,808) if index==10 else (Vector2(1720,1298) if index==11 else Vector2(1060,1298))
		world.player.velocity=Vector2.ZERO
		world.player.animate(0)
		world.camera.position_smoothing_enabled=false
		world.camera.reset_smoothing()
		for enemy in world.enemies: enemy.set_physics_process(false)
		if index==12: world.active_enemy.begin_attack("pulse")
		world.queue_redraw()
		await process_frame
		RenderingServer.force_draw(false)
		root.get_texture().get_image().save_png(output.path_join("room_%02d.png"%index))
	world.hud.toggle_map()
	await process_frame
	RenderingServer.force_draw(false)
	root.get_texture().get_image().save_png(output.path_join("atlas.png"))
	world.hud.toggle_map()
	world.queue_free();current_scene=null
	await process_frame
	print("SKYWORKS CAPTURE: complete")
	quit()
