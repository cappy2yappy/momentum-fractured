extends "res://tests/embodied_transitions.gd"
# Seeded game fixtures, real loader, ordinary zoom. No human playtest claim.
var output="res://build/int-tr03/captures"
func shot(name):
	w.queue_redraw();w.hud.queue_redraw();w.embodied_transitions.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(output.path_join(name+".png"))
func run():
	await process_frame
	w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w;freeze();seed_fixture()
	DirAccess.make_dir_recursive_absolute(output)
	w.camera.zoom=Vector2.ONE;w.camera.position_smoothing_enabled=false
	print("ART04_NATIVE adapter=",RenderingServer.get_video_adapter_name()," driver=",RenderingServer.get_current_rendering_driver_name()," viewport=",root.size)
	for comparison in ["original","refined","art-preview","reduced","plain"]:
		for pair in [[14,17],[17,14],[14,13],[13,14]]:
			reset(pair[0]);var e=w.embodied_transitions
			e.comparison=comparison;e.art_preview=comparison in ["art-preview","reduced"];e.depth_demo=true;e.structural_dressing=comparison!="original"
			w.mixed_transitions.graphic_mode="reduced" if comparison=="reduced" else ("plain" if comparison=="plain" else "graphic")
			var p=portal(pair[0],pair[1]);w.player.position=p.at-Vector2(0,2);w.player.velocity=Vector2.ZERO;w.player.animate(0);w.camera.reset_smoothing();w.message_time=0
			var prefix="%s_%d-%d"%[comparison,pair[0],pair[1]]
			await shot(prefix+"_before")
			w.interact()
			for tick in 40:
				await physics_frame
				w._physics_process(1.0/60.0)
				if w.transition<=0: w.player.set_physics_process(false)
				if tick in [7,12,20,38]: await shot(prefix+"_tick%02d"%(tick+1))
			freeze();await shot(prefix+"_after")
			check(w.room==pair[1] and w.player.position==p.arrival and w.player.sprite.visible and not e.proxy.visible,"Native rendered %s exact destination and cleanup actual=%s expected=%s room=%d target=%d visible=%s proxy=%s"%[prefix,w.player.position,p.arrival,w.room,pair[1],w.player.sprite.visible,e.proxy.visible])
	for index in [14,15]:
		for comparison in ["original","refined","art-preview"]:
			reset(index);w.embodied_transitions.comparison=comparison;w.embodied_transitions.art_preview=comparison=="art-preview";w.embodied_transitions.structural_dressing=comparison!="original"
			w.player.position=Vector2(950 if index==14 else 1600,1298);w.player.velocity=Vector2.ZERO;w.player.animate(0);w.camera.reset_smoothing();w.message_time=0
			await shot("structure_R%d_%s"%[index,comparison])
			print("STRUCTURE room=%d mode=%s colliders=%d zoom=%s"%[index,comparison,w.geometry.get_child_count(),w.camera.zoom])
	w.queue_free();current_scene=null
	for tick in 3: await process_frame
	print("ART04 NATIVE CAPTURE: %d assertions, %d failure(s)"%[assertions,failures]);quit(1 if failures else 0)
