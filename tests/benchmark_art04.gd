extends "res://tests/embodied_transitions.gd"
# Native presentation intervals; no screenshots/encoding inside measurements.
func run():
	await process_frame
	w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w;freeze();seed_fixture()
	w.camera.zoom=Vector2.ONE;w.camera.position_smoothing_enabled=false
	print("ART04_RENDER adapter=",RenderingServer.get_video_adapter_name()," driver=",RenderingServer.get_current_rendering_driver_name()," viewport=",root.size)
	var rows=[]
	# Alternate order between scenes; measurements are bounded, not a campaign benchmark.
	for index in [14,15,17]:
		var modes=["original","refined","art-preview","reduced"] if index!=15 else ["reduced","art-preview","refined","original"]
		for comparison in modes:
			reset(index);var e=w.embodied_transitions;e.comparison=comparison;e.art_preview=comparison in ["art-preview","reduced"];e.depth_demo=true;e.structural_dressing=comparison!="original"
			w.mixed_transitions.graphic_mode="reduced" if comparison=="reduced" else "graphic"
			w.player.position=Vector2(1450,478) if index==14 else (Vector2(1600,1298) if index==15 else Vector2(1680,1298))
			w.player.animate(0);w.camera.reset_smoothing();w.message_time=0
			if index in [14,17]:
				w.request_room(17 if index==14 else 14,portal(index,17 if index==14 else 14).arrival)
			var samples=[];var calls=[];var before=Time.get_ticks_usec()
			for i in 150:
				if index in [14,17]:
					w.transition=0.65-float(i%18)/60.0;e.update_pose(w)
				w.queue_redraw();w.hud.queue_redraw();e.queue_redraw()
				await RenderingServer.frame_post_draw
				var now=Time.get_ticks_usec()
				if i>=30:
					samples.append((now-before)/1000.0);calls.append(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
				before=now
			samples.sort();calls.sort();var total=0.0
			for sample in samples: total+=sample
			var row={"room":index,"comparison":comparison,"samples":120,"mean_ms":total/120,"p95_ms":samples[113],"max_ms":samples[119],"average_fps":120000.0/total,"median_draw_calls":calls[60]}
			rows.append(row);print("ART04_METRIC ",JSON.stringify(row))
	var f=FileAccess.open("res://build/int-tr03/logs/performance.json",FileAccess.WRITE);f.store_string(JSON.stringify(rows,"\t"));f.close()
	w.transition=0;w.embodied_transitions.cancel(w);w.queue_free();current_scene=null
	for tick in 3: await process_frame
	quit()
