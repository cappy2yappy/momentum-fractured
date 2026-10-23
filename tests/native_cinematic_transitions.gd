extends "res://tests/cinematic_transitions.gd"
var output="res://build/tr05/native"
func automation_hud():
	load("res://tests/fixtures/native_automation_hud.gd").install(w)
func key(code,pressed):
	var event=InputEventKey.new();event.physical_keycode=code;event.keycode=code;event.pressed=pressed
	Input.parse_input_event(event);Input.flush_buffered_events()
func wait_ticks(count):
	for i in count: await physics_frame
func shot(name):
	# TR-08 reviewed change: a headless display never posts a drawn frame, so the
	# capture is skipped there (checks still run); rendered runs capture as before.
	if DisplayServer.get_name()=="headless": await process_frame;return
	await process_frame
	# A visible native window can stop drawing in the background. Connect before
	# forcing one real GPU draw; never wait indefinitely for an incidental frame.
	var drawn={"done":false}
	var mark=func(): drawn.done=true
	RenderingServer.frame_post_draw.connect(mark,CONNECT_ONE_SHOT)
	RenderingServer.force_draw(false)
	for tick in 120:
		if drawn.done: break
		await process_frame
	if not drawn.done:
		RenderingServer.frame_post_draw.disconnect(mark)
		check(false,"Native capture %s received a rendered frame"%name)
		return
	var image=root.get_texture().get_image()
	check(not image.is_empty() and image.save_png(output+"/"+name+".png")==OK,"Native capture %s saved rendered pixels"%name)
func live():
	w.set_physics_process(true);w.player.set_physics_process(true)
	for enemy in w.enemies: enemy.set_physics_process(false)
func run():
	await process_frame
	w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w;automation_hud();freeze();seed_fixture()
	DirAccess.make_dir_recursive_absolute(output)
	print("TR05_NATIVE GPU=",RenderingServer.get_video_adapter_name()," driver=",RenderingServer.get_current_rendering_driver_name()," viewport=",root.size)
	for running in [false,true]:
		for pair in [[13,0],[13,14],[14,13],[15,16],[16,15]]:
			reset(pair[0]);var p=w.cinematic_transitions.endpoint(w,pair[0],pair[1])
			w.player.position=p.at-Vector2(int(p.heading)*100,2);w.player.velocity=Vector2.ZERO;w.player.animate(0);w.camera.reset_smoothing();w.message_time=0
			await shot("passage_%d-%d_before"%pair+("_sprint" if running else ""))
			var before=w.cinematic_transitions.request_count
			live();await wait_ticks(5)
			if running:
				key(KEY_A if p.heading<0 else KEY_D,true);await wait_ticks(2);key(KEY_A if p.heading<0 else KEY_D,false);await wait_ticks(1)
			key(KEY_A if p.heading<0 else KEY_D,true)
			await wait_ticks(22)
			key(KEY_A if p.heading<0 else KEY_D,false)
			await wait_ticks(52)
			# TR-08 reviewed change: the embodied Canal doorway runs around the unchanged
			# loader; wait (bounded) until it hands back control before observing.
			for tick in 300:
				if not w.cinematic_transitions.tr08.owns() and w.transition<=0: break
				await wait_ticks(1)
			check(w.room==pair[1] and w.player.is_on_floor(),"Native physical input crosses %s without E and lands"%[pair])
			check(w.cinematic_transitions.request_count==before+1,"Native physical %s makes one request"%[pair])
			check(w.player.sprite.visible and not w.embodied_transitions.proxy.visible,"Native %s visible live Kaze restored"%[pair])
			await shot("passage_%d-%d_after"%pair+("_sprint" if running else ""))
			# Held E must not bounce ordinary reciprocal door. Real just-pressed state,
			# not repeated calls to interact (which would model multiple fresh presses).
			key(KEY_E,true);await wait_ticks(100);key(KEY_E,false)
			if w.cinematic_transitions.endpoint(w,pair[1],pair[0]).mode=="horizontal_walk":
				check(w.room==pair[1] and w.cinematic_transitions.request_count==before+1,"Native held E cannot loop reciprocal %s"%[pair])
				# After the real stop/cooldown, reverse through the same door in the
				# same scene. Separate seeded starts alone cannot prove retrigger/rearm.
				key(KEY_D if p.heading<0 else KEY_A,true);await wait_ticks(40)
				key(KEY_D if p.heading<0 else KEY_A,false);await wait_ticks(60)
				check(w.room==pair[0] and w.cinematic_transitions.request_count==before+2,"Native stopped reverse round trip %s succeeds once"%[pair])
			freeze()
	for still in [false,true]:
		for pair in [[14,17],[17,14]]:
			reset(pair[0]);var c=w.cinematic_transitions;c.reduced=still;c.tr08.reduced=still
			w.embodied_transitions.comparison="reduced" if still else "art-preview"
			var p=c.endpoint(w,pair[0],pair[1]);w.player.position=p.at-Vector2(0,2);w.player.velocity=Vector2.ZERO;w.player.animate(0);w.camera.reset_smoothing();w.message_time=0
			var prefix="stair_%d-%d_%s"%[pair[0],pair[1],"reduced" if still else "cinematic"]
			await shot(prefix+"_before")
			live();await wait_ticks(3);key(KEY_E,true);await wait_ticks(1);key(KEY_E,false)
			await wait_ticks(5);await shot(prefix+"_moving")
			await wait_ticks(6);await shot(prefix+"_close")
			await wait_ticks(44)
			# TR-08 reviewed change: the full-screen stair cinematic lasts about 2.9 s
			# (1.3 s reduced); wait (bounded) for it to hand back control.
			for tick in 300:
				if not c.tr08.owns() and w.transition<=0: break
				await wait_ticks(1)
			await wait_ticks(3)
			check(w.room==pair[1] and w.player.is_on_floor() and w.player.sprite.visible,"Native E %s staircase completes safely"%prefix)
			check(w.camera.zoom==Vector2.ONE and w.camera.position==Vector2(0,-110),"Native %s restores camera"%prefix)
			await shot(prefix+"_after");freeze()
	# Source endpoint inventory for LD coordination, derived from actual game state.
	var rows=[]
	for index in 21:
		for p in w.cinematic_transitions.endpoints(w,index): rows.append({"source":index,"target":p.target,"position":[p.at.x,p.at.y],"mode":p.mode,"heading":p.heading})
	var file=FileAccess.open(output+"/endpoint-matrix.json",FileAccess.WRITE);file.store_string(JSON.stringify(rows,"  "));file.close()
	w.queue_free();current_scene=null
	for i in 3: await process_frame
	print("TR05 NATIVE: %d checks, %d failure(s)"%[checks,failures]);quit(1 if failures else 0)
