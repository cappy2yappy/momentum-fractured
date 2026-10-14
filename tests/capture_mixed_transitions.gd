extends SceneTree
var w
func _init(): call_deferred("run")
func freeze():
	w.set_physics_process(false);w.player.set_physics_process(false)
	for e in w.enemies: e.set_physics_process(false)
func seed_fixture():
	w.completed=true;w.player.double_jump=true;w.player.tether_unlocked=true;w.player.dash_unlocked=true
	w.relay_fragments={"undercroft_sigil":true,"terrace_west":true,"terrace_fire_cache":true}
	w.opened_kunai_gates["skyworks_wind_intake"]=true;w.expansion_flags["junction_return"]=true
func run():
	await process_frame
	w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w;freeze();seed_fixture()
	w.camera.zoom=Vector2.ONE;w.camera.position_smoothing_enabled=false
	var output="res://build/tr02/capture"
	DirAccess.make_dir_recursive_absolute(output)
	print("ADAPTER=",RenderingServer.get_video_adapter_name()," DRIVER=",RenderingServer.get_current_rendering_driver_name())
	for mode in ["plain","graphic","reduced"]:
		w.mixed_transitions.graphic_mode=mode
		for pilot in ["walk","stair","special"]:
			w.transition=0;w.pending_room=-1;w.mixed_transitions.cancel(w)
			w.build_room(15 if pilot=="walk" else (14 if pilot=="stair" else 20));freeze();seed_fixture()
			w.message_time=0
			w.player.position=Vector2(1950,1118) if pilot=="walk" else (Vector2(1450,478) if pilot=="stair" else Vector2(600,518))
			w.player.velocity=Vector2.ZERO;w.player.animate(0);w.camera.reset_smoothing()
			for i in 4: await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(output.path_join(mode+"_"+pilot+"_before.png"))
			var frames=output.path_join(mode+"_"+pilot);DirAccess.make_dir_recursive_absolute(frames)
			w.mixed_transitions.cooldown=0;w.player.set_physics_process(true);w.set_physics_process(true)
			if pilot=="walk": Input.action_press("right")
			else: w.interact()
			var seen=false
			for i in 90:
				await RenderingServer.frame_post_draw
				if w.transition>0: seen=true
				if i%2==0: root.get_texture().get_image().save_png(frames.path_join("frame_%03d.png"%i))
			Input.action_release("right");freeze()
			root.get_texture().get_image().save_png(output.path_join(mode+"_"+pilot+"_after.png"))
			print("LIVE_CAPTURE mode=%s pilot=%s effect_seen=%s destination=%d zoom=%s"%[mode,pilot,seen,w.room,w.camera.zoom])
		# Native draw-only effect sample; no image encoding inside timed intervals.
		w.build_room(15);freeze();w.player.position=Vector2(2080,1118);w.camera.reset_smoothing()
		w.mixed_transitions.active_walk=true;w.mixed_transitions.destination="ROOT SHRINE"
		var samples=[];var previous=Time.get_ticks_usec()
		for i in 150:
			w.transition=0.65-float(i%39)/60;w.queue_redraw();w.hud.queue_redraw()
			await RenderingServer.frame_post_draw
			var now=Time.get_ticks_usec()
			if i>=30: samples.append((now-previous)/1000.0)
			previous=now
			if i==15: root.get_texture().get_image().save_png(output.path_join(mode+"_effect.png"))
		# Initial screenshot at15 is excluded by30-frame warmup.
		samples.sort();var total=0.0
		for sample in samples: total+=sample
		print("DRAW_FRAME mode=%s n=120 mean_ms=%.3f p95_ms=%.3f max_ms=%.3f"%[mode,total/120,samples[113],samples[119]])
	w.transition=0;w.queue_free();current_scene=null
	for i in 3: await process_frame
	quit()
