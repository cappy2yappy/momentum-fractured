extends SceneTree
## Native wall-clock draw capture; scripted input, not human playtesting.
var w
var output := ""
var frame_index := 0
var records: Array = []
var start_us := 0
var previous_us := 0
var frame_ms: Array = []
var mode := "skirmisher"
var capture_enabled := true
func _init(): call_deferred("run")
func ticks(n):
	for i in n: await physics_frame
func run():
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output="): output=arg.trim_prefix("--output=")
		if arg.begins_with("--mode="): mode=arg.trim_prefix("--mode=")
		if arg=="--no-frames": capture_enabled=false
	if output.is_empty(): quit(2); return
	DirAccess.make_dir_recursive_absolute(output)
	w=load("res://scenes/en02/"+mode+".tscn").instantiate()
	root.add_child(w); current_scene=w
	# Test-only: remove the unrelated legacy HUD focus pause handler. Lab unchanged.
	w.hud.free()
	paused=false
	w.camera.zoom=Vector2.ONE
	w.camera.position=Vector2(0,-140)
	w.player.position=Vector2(570,618)
	await ticks(10)
	start_us=Time.get_ticks_usec(); previous_us=start_us
	var capture_mark := -1
	var last_state := ""
	var action := 0
	while Time.get_ticks_usec()-start_us < 14000000:
		await process_frame
		var now := Time.get_ticks_usec()
		frame_ms.append((now-previous_us)/1000.0); previous_us=now
		var e=w.enemies[0] if not w.enemies.is_empty() else null
		var elapsed=(now-start_us)/1000000.0
		if is_instance_valid(e):
			if elapsed<1.0: w.player.touch["right"]=true
			else: w.player.touch["right"]=false
			if e.state=="windup" and e.timer<0.18 and action==0:
				w.player.press("jump"); w.player.touch["jump"]=true; action=1
			if elapsed>4.0: w.player.touch["jump"]=false
			if elapsed>5.0 and action==1:
				w.player.facing=1; w.player.press("dash"); action=2
			if elapsed>7.0 and action==2:
				w.player.touch["left"]=true; action=3
			if elapsed>7.5: w.player.touch["left"]=false
			if elapsed>8.0 and e.state=="windup" and e.timer<0.2:
				w.player.facing=1 if e.position.x>w.player.position.x else -1
				w.player.press("parry")
			if elapsed>10.0:
				w.player.facing=1 if e.position.x>w.player.position.x else -1
				w.player.press("kunai")
			last_state=e.state
		var mark := int(elapsed*12.0)
		if capture_enabled and mark!=capture_mark:
			capture_mark=mark
			# Explicit draw is bounded and doesn't await a suppressed OS frame forever.
			RenderingServer.force_draw(false)
			var image=root.get_texture().get_image()
			var file="frame_%05d.png" % frame_index
			image.save_png(output.path_join(file))
			records.append({"file":file,"wall_seconds":elapsed,"state":last_state,"hp":w.player.hp})
			frame_index+=1
	frame_ms.sort()
	var report={"mode":mode,"wall_seconds":(Time.get_ticks_usec()-start_us)/1000000.0,"frames":records,"capture_enabled":capture_enabled,"render_draw_samples":frame_ms.size(),"frame_ms_p50":frame_ms[int(frame_ms.size()*0.5)],"frame_ms_p95":frame_ms[int(frame_ms.size()*0.95)],"note":"Native Windows OpenGL, scripted inputs. When capture_enabled, PNG readback overhead is included. Single-lab hardware measurement, not full-world certification."}
	var file=FileAccess.open(output.path_join("timing.json"),FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"  ")); file.close()
	print("EN02 CAPTURE: ",mode," frames=",frame_index," seconds=",report.wall_seconds)
	w.free(); current_scene=null; quit()
