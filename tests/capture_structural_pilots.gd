extends SceneTree
func _init(): call_deferred("run")
func run():
	await process_frame
	var w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w
	w.set_physics_process(false);w.player.set_physics_process(false)
	w.camera.zoom=Vector2.ONE;w.camera.position_smoothing_enabled=false
	var output="res://build/tr03/capture";DirAccess.make_dir_recursive_absolute(output)
	for index in [14,15]:
		for comparison in ["original","refined"]:
			w.embodied_transitions.comparison=comparison;w.embodied_transitions.structural_dressing=comparison!="original"
			w.build_room(index);w.message_time=0
			for e in w.enemies: e.set_physics_process(false)
			w.player.position=Vector2(950 if index==14 else 1600,1298);w.player.velocity=Vector2.ZERO;w.player.animate(0);w.camera.reset_smoothing()
			for i in 4: await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(output.path_join("structure_R%d_%s.png"%[index,comparison]))
			print("STRUCTURE_FIXTURE room=%d comparison=%s zoom=%s colliders=%d"%[index,comparison,w.camera.zoom,w.geometry.get_child_count()])
	w.queue_free();current_scene=null;await process_frame;quit()
