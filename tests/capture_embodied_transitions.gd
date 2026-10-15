extends SceneTree
## Scripted fixture evidence at1280x720 /camera zoom1; not creator playtesting.
var w
func _init(): call_deferred("run")
func freeze():
	w.set_physics_process(false);w.player.set_physics_process(false)
	for e in w.enemies: e.set_physics_process(false)
func fixture():
	w.completed=true;w.player.double_jump=true;w.player.tether_unlocked=true;w.player.dash_unlocked=true
	w.relay_fragments={"undercroft_sigil":true,"terrace_west":true,"terrace_fire_cache":true}
	w.opened_kunai_gates["skyworks_wind_intake"]=true;w.expansion_flags["junction_return"]=true
func endpoint(a,b):
	for p in w.expansion.portals(a):
		if p.target==b: return p
	return {}
func run():
	await process_frame
	w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w;freeze();fixture()
	w.camera.zoom=Vector2.ONE;w.camera.position_smoothing_enabled=false
	var output="res://build/tr03/capture";DirAccess.make_dir_recursive_absolute(output)
	print("NATIVE_RENDER adapter=",RenderingServer.get_video_adapter_name()," driver=",RenderingServer.get_current_rendering_driver_name())
	var pilots={"walk":[15,16],"run":[15,16],"stair_up":[14,17],"stair_down":[17,14],"depth":[14,13],"wind_fold":[20,13]}
	for comparison in ["original","refined","reduced"]:
		for pilot in pilots:
			w.transition=0;w.pending_room=-1;w.mixed_transitions.cancel(w);w.embodied_transitions.cancel(w)
			w.embodied_transitions.comparison=comparison;w.embodied_transitions.structural_dressing=comparison!="original"
			w.embodied_transitions.depth_demo=pilot=="depth"
			w.mixed_transitions.graphic_mode="reduced" if comparison=="reduced" else "graphic"
			var pair=pilots[pilot];var p=endpoint(pair[0],pair[1]);w.build_room(pair[0]);freeze();fixture()
			w.player.position=p.at+Vector2(-128,-2) if pilot in ["walk","run"] else p.at-Vector2(0,2)
			w.player.velocity=Vector2.ZERO;w.player.run=false;w.player.last_tap=-10;w.player.age=0
			w.player.animate(0);w.camera.reset_smoothing();w.message_time=0
			for i in 3: await process_frame
			await RenderingServer.frame_post_draw
			var prefix=comparison+"_"+pilot
			root.get_texture().get_image().save_png(output.path_join(prefix+"_before.png"))
			var frames=output.path_join(prefix);DirAccess.make_dir_recursive_absolute(frames)
			w.player.set_physics_process(true)
			for i in 6: await physics_frame
			w.mixed_transitions.cooldown=0;w.set_physics_process(true)
			if pilot in ["walk","run"]:
				Input.action_press("right")
				if pilot=="run": w.player.run=true
			else: w.interact()
			var seen=false;var phase_captured=false
			for i in 90:
				await RenderingServer.frame_post_draw
				if w.transition>0: seen=true
				if i%3==0: root.get_texture().get_image().save_png(frames.path_join("frame_%03d.png"%i))
				if w.transition<0.5 and w.transition>0.43 and not phase_captured:
					root.get_texture().get_image().save_png(output.path_join(prefix+"_staging.png"));phase_captured=true
			Input.action_release("right");freeze()
			root.get_texture().get_image().save_png(output.path_join(prefix+"_after.png"))
			print("CAPTURE_FIXTURE comparison=%s pilot=%s seen=%s target=%d actual=%d proxy_clean=%s"%[comparison,pilot,seen,pair[1],w.room,not w.embodied_transitions.active and w.player.sprite.visible])
	# Bounded draw-only sample: no screenshots within timed intervals.
	for comparison in ["original","refined","reduced"]:
		w.transition=0;w.pending_room=-1;w.embodied_transitions.cancel(w);w.mixed_transitions.cancel(w)
		w.embodied_transitions.comparison=comparison;w.mixed_transitions.graphic_mode="reduced" if comparison=="reduced" else "graphic"
		w.embodied_transitions.structural_dressing=comparison!="original"
		w.embodied_transitions.depth_demo=false;w.build_room(14);freeze();w.player.position=Vector2(1450,478);w.player.animate(0);w.camera.reset_smoothing()
		w.request_room(17,Vector2(1680,1298))
		var samples=[];var draws=[];var previous=Time.get_ticks_usec()
		for i in 150:
			w.transition=0.65-float(i%18)/60.0;w.embodied_transitions.update_pose(w);w.queue_redraw();w.hud.queue_redraw()
			await RenderingServer.frame_post_draw
			var now=Time.get_ticks_usec()
			if i>=30:
				samples.append((now-previous)/1000.0);draws.append(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
			previous=now
		samples.sort();draws.sort();var total=0.0
		for sample in samples: total+=sample
		print("DRAW_SAMPLE comparison=%s n=120 mean_ms=%.3f p95_ms=%.3f max_ms=%.3f median_draw_calls=%.0f"%[comparison,total/120,samples[113],samples[119],draws[60]])
	w.transition=0;w.embodied_transitions.cancel(w);w.queue_free();current_scene=null
	for i in 3: await process_frame
	quit()
