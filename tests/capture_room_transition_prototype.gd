extends SceneTree
func _init(): call_deferred("run")
func run():
	await process_frame
	var w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w
	w.set_physics_process(false);w.player.set_physics_process(false)
	w.camera.position_smoothing_enabled=false;w.camera.zoom=Vector2.ONE
	w.hud.set_process_input(false);w.hud.set_process(false)
	var phase="before" if "--before" in OS.get_cmdline_user_args() else "after"
	print("ADAPTER=",RenderingServer.get_video_adapter_name()," DRIVER=",RenderingServer.get_current_rendering_driver_name())
	for index in [14,15]:
		w.build_room(index);w.player.set_physics_process(false)
		for e in w.enemies: e.set_physics_process(false)
		w.message_time=0
		w.player.double_jump=true;w.completed=true;w.player.tether_unlocked=true;w.player.dash_unlocked=true
		w.player.kunai_unlocked.wind=true;w.opened_kunai_gates.cistern_wind_cache=true
		for n in w.expansion.portals(index).size():
			var p=w.expansion.portals(index)[n]
			w.player.position=p.at+Vector2(65,-2);w.player.animate(0);w.camera.reset_smoothing();w.queue_redraw();w.hud.queue_redraw()
			for i in 4: await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://docs/agent_handoffs/tr01_evidence/%s_r%d_exit%d.png"%[phase,index,n])
	if phase == "after":
		for index in [14,15]:
			w.build_room(index);w.player.set_physics_process(false)
			w.player.position=w.expansion.portals(index)[0].at+Vector2(65,-2)
			w.pending_from_room=index;w.pending_room=-1
			var samples=[]
			var before=Time.get_ticks_usec()
			for i in 150:
				w.transition=0.65-float(i%39)/60.0
				w.queue_redraw();w.hud.queue_redraw()
				await RenderingServer.frame_post_draw
				var now=Time.get_ticks_usec()
				if i>=30: samples.append((now-before)/1000.0)
				before=now
				if i==15:
					root.get_texture().get_image().save_png("res://docs/agent_handoffs/tr01_evidence/effect_r%d%s.png"%[index,"_reduced" if "--tr01-reduced-motion" in OS.get_cmdline_user_args() else ""])
			samples.sort();var total=0.0
			for sample in samples: total+=sample
			print("EFFECT_FRAME_METRIC room=%d n=120 mean_ms=%.3f p95_ms=%.3f max_ms=%.3f zoom=%s reduced=%s"%[index,total/120.0,samples[113],samples[119],w.camera.zoom,"--tr01-reduced-motion" in OS.get_cmdline_user_args()])
		w.transition=0
		# Capture real request_room timing and arrival, advanced one fixed physics tick per rendered frame.
		DirAccess.make_dir_recursive_absolute("res://build/tr01/effect_frames")
		w.build_room(14);w.player.set_physics_process(false)
		var portal=w.expansion.portals(14)[0]
		w.player.position=portal.at+Vector2(65,-2);w.interact()
		for i in 41:
			w._physics_process(1.0/60.0);w.player.set_physics_process(false);w.queue_redraw();w.hud.queue_redraw()
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://build/tr01/effect_frames/frame_%02d.png"%i)
		for index in [14,15]:
			w.build_room(index);w.player.set_physics_process(false)
			w.player.double_jump=false;w.player.kunai_unlocked.wind=false
			w.player.position=w.expansion.portals(index)[0].at+Vector2(65,-2)
			w.queue_redraw();w.hud.queue_redraw()
			for i in 4: await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://docs/agent_handoffs/tr01_evidence/locked_r%d.png"%index)
	w.queue_free();current_scene=null
	for i in 3: await process_frame
	quit()
