extends SceneTree
func _init(): call_deferred("run")
func endpoints(w,index):
	var points=[]
	if index>0 and index<13: points.append(w.left_exit_position())
	if index<12: points.append(w.right_exit_position())
	for p in w.expansion.portals(index): points.append(p.at)
	return points
func run():
	await process_frame
	var w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w
	w.set_physics_process(false);w.player.set_physics_process(false)
	w.camera.zoom=Vector2.ONE;w.camera.position_smoothing_enabled=false
	var rows=[]
	var phase="before" if "--before" in OS.get_cmdline_user_args() else "after"
	var output="res://docs/tr04/evidence";DirAccess.make_dir_recursive_absolute(output)
	for index in 21:
		w.build_room(index)
		for e in w.enemies: e.set_physics_process(false)
		var exits=[]
		for at in endpoints(w,index):
			var support=[]
			for r in w.platforms:
				if absf(r.position.y-at.y)<=24 and r.size.x>40 and at.x>=r.position.x-14 and at.x<=r.end.x+14:
					support.append([r.position.x,r.position.y,r.size.x,r.size.y])
			exits.append({"at":[at.x,at.y],"support":support})
		var rects=[]
		for r in w.platforms: rects.append([r.position.x,r.position.y,r.size.x,r.size.y])
		rows.append({"id":index,"name":w.ROOM_NAMES[index],"size":[w.room_size(index).x,w.room_size(index).y],"platforms":rects,"exits":exits})
		if phase=="after" and DisplayServer.get_name()!="headless":
			var size=w.room_size(index)
			w.camera.zoom=Vector2.ONE*minf(1280.0/size.x,720.0/size.y)*0.94
			w.player.position=size/2+Vector2(0,110);w.player.animate(0);w.message_time=0;w.camera.reset_smoothing()
			for i in 4: await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(output.path_join("room_%02d.png"%index))
		if index in [13,14] and not DisplayServer.get_name()=="headless":
			w.camera.zoom=Vector2.ONE
			w.player.position=Vector2(28,1200 if index==13 else 1100);w.player.velocity=Vector2.ZERO;w.player.animate(0);w.message_time=0
			w.camera.reset_smoothing()
			for i in 4: await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(output.path_join("R%d_left_%s.png"%[index,phase]))
	var file=FileAccess.open(output.path_join("geometry_%s.json"%phase),FileAccess.WRITE);file.store_string(JSON.stringify(rows,"\t"));file.close()
	print("AUDIT: 21 room definitions and exit supports recorded / ",phase)
	w.queue_free();current_scene=null
	for i in 3: await process_frame
	quit()
