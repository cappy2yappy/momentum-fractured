extends SceneTree
func _init(): call_deferred("run")
func run():
	await process_frame
	var w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w
	w.set_physics_process(false);w.player.set_physics_process(false);w.build_room(14)
	for e in w.enemies: e.set_physics_process(false)
	w.message_time=0;w.embodied_transitions.art_preview=true;w.embodied_transitions.comparison="art-preview"
	w.camera.position_smoothing_enabled=false
	var phase="before" if "--before" in OS.get_cmdline_user_args() else "after"
	var out="res://build/ld03/captures";DirAccess.make_dir_recursive_absolute(out)
	for name in ["overview","west","court","east"]:
		w.camera.zoom=Vector2.ONE
		w.player.position=Vector2({"overview":450,"west":350,"court":1300,"east":2190}[name],1298)
		if phase=="after" and name=="court": w.player.position.y=1218
		w.player.velocity=Vector2.ZERO
		for i in 5: await physics_frame;w.player._physics_process(1.0/60.0)
		w.player.animate(0)
		w.camera.global_position=Vector2({"overview":1300,"west":640,"court":1300,"east":1960}[name],1080)
		if name=="overview": w.camera.zoom=Vector2.ONE*0.46;w.camera.global_position=Vector2(1300,720)
		w.camera.reset_smoothing();w.queue_redraw()
		for i in 3: await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(out.path_join(name+"_"+phase+".png"))
		print("CAPTURE: ",name," ",phase," feet=",w.player.position," renderer=",RenderingServer.get_video_adapter_name())
	w.queue_free();current_scene=null
	for i in 3: await process_frame
	quit()
