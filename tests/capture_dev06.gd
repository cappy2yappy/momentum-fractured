extends SceneTree
func _init(): call_deferred("run")
func run():
	await process_frame
	var w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w
	w.set_physics_process(false);w.player.set_physics_process(false)
	w.player.double_jump=true;w.player.tether_unlocked=true;w.player.dash_unlocked=true
	w.message_time=0;w.camera.position_smoothing_enabled=false
	var output=OS.get_cmdline_user_args()[0]
	for index in 21: w.build_room(index)
	for index in [13,14,15,16,17,18,19,20]:
		w.build_room(index);w.player.position=Vector2(w.room_size(index).x/2,900 if index!=17 else 1200)
		w.camera.zoom=Vector2(0.65,0.65);w.camera.reset_smoothing();w.player.animate(0)
		for e in w.enemies: e.set_physics_process(false)
		for frame in 4: await process_frame
		RenderingServer.force_draw(false);root.get_texture().get_image().save_png(output.path_join("room_%d.png"%index))
	w.hud.toggle_map();await process_frame;RenderingServer.force_draw(false)
	root.get_texture().get_image().save_png(output.path_join("atlas.png"))
	w.hud.toggle_map();w.queue_free();current_scene=null;await process_frame;quit()
