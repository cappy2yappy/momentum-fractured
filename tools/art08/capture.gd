extends SceneTree
## ART-08 Sprite2D playback capture: loads each manifest strip, plays frames with the manifest hframes and the
## engine offset convention (0, h/2-600), saves one PNG per frame under user://art08_cap/<clip>_<n>.png
func _initialize():
	var man=JSON.parse_string(FileAccess.get_file_as_string("res://assets/art08/MANIFEST.json"))
	var vp=SubViewport.new();vp.size=Vector2i(480,600);vp.transparent_bg=false;vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(vp)
	var bg=ColorRect.new();bg.color=Color(0.38,0.44,0.48);bg.size=Vector2(480,600);vp.add_child(bg)
	var sp=Sprite2D.new();vp.add_child(sp)
	DirAccess.make_dir_recursive_absolute("user://art08_cap")
	var report=[]
	for c in man.clips:
		if c.status=="unfinished": continue
		var tex=load(c.strip)
		if tex==null: report.append([c.name,"LOAD FAIL"]);continue
		sp.texture=tex;sp.hframes=c.hframes;sp.vframes=1
		sp.position=Vector2(240,420);sp.offset=Vector2(0,tex.get_height()/2.0-c.pivot[1])
		for f in range(c.hframes):
			sp.frame=f
			await process_frame;await process_frame
			vp.get_texture().get_image().save_png("user://art08_cap/%s_%02d.png"%[c.name,f])
		report.append([c.name,c.hframes,tex.get_width(),tex.get_height()])
	print("ART08_CAPTURE ",JSON.stringify(report))
	quit()
