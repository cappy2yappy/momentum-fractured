extends SceneTree
## Local-only source audit. Inputs are immutable; outputs are reference alignment only.
var records: Array = []
func info(image: Image) -> Dictionary:
	var zero := 0
	var partial := 0
	var opaque := 0
	for y in image.get_height():
		for x in image.get_width():
			var a = image.get_pixel(x,y).a
			if a == 0: zero += 1
			elif a == 1: opaque += 1
			else: partial += 1
	var rect = image.get_used_rect()
	return {"size":[image.get_width(),image.get_height()],"alpha_bbox":[rect.position.x,rect.position.y,rect.size.x,rect.size.y],"transparent":zero,"partial_alpha":partial,"opaque":opaque}
func _initialize():
	var args = OS.get_cmdline_user_args()
	if args.size()!=3:
		printerr("Provide local repository, Image4 reference directory, output directory.")
		quit(2); return
	var repo=args[0]; var refs=args[1]; var out=args[2]
	DirAccess.make_dir_recursive_absolute(out)
	var paths: Array = []
	for name in ["enter_depth_key","turn_depth_key","stair_up_key","stair_down_key"]:
		paths.append(repo+"/assets/art04/kaze/"+name+".png")
	var manifest = JSON.parse_string(FileAccess.get_file_as_string(repo+"/assets/art08/MANIFEST.json"))
	var clips: Array = []
	var frame_count := 0
	var matched := 0
	for c in manifest.clips:
		if not str(c.name).begins_with("stair"): continue
		var path=repo+"/"+c.strip
		paths.append(path)
		var im=Image.load_from_file(path)
		var cells: Array = []
		for i in int(c.hframes):
			cells.append(info(im.get_region(Rect2i(i*int(c.cell[0]),0,int(c.cell[0]),int(c.cell[1])))))
		var matches = FileAccess.get_sha256(path)==c.sha256
		if matches: matched+=1
		frame_count += cells.size()
		clips.append({"name":c.name,"frames":cells.size(),"fps":c.fps,"cell":c.cell,"pivot":c.pivot,"manifest_hash_matches":matches,"frames_audit":cells,"status":"existing ART08 candidate; not ART10 completion"})
	var aligned: Array = []
	var pivots=[Vector2i(43,74),Vector2i(49,71),Vector2i(54,72)]
	for i in 3:
		var name="pose_%d.png"%(138+i)
		var path=refs+"/"+name
		paths.append(path)
		var im=Image.load_from_file(path)
		im.convert(Image.FORMAT_RGBA8)
		var canvas=Image.create(128,128,false,Image.FORMAT_RGBA8)
		canvas.fill(Color.TRANSPARENT)
		var offset=Vector2i(64,112)-pivots[i]
		canvas.blit_rect(im,Rect2i(Vector2i.ZERO,im.get_size()),offset)
		assert(canvas.get_region(Rect2i(offset,im.get_size())).get_data()==im.get_data())
		var target=out+"/"+name
		assert(canvas.save_png(target)==OK)
		aligned.append({"source":name,"source_sha256":FileAccess.get_sha256(path),"output":name,"output_sha256":FileAccess.get_sha256(target),"cell":[128,128],"pivot":[64,112],"source_pivot":[pivots[i].x,pivots[i].y],"offset":[offset.x,offset.y],"pixels_preserved":true,"scale":1,"pivot_status":"PR85 bounding-box root, NOT measured sole","status":"reference only; no added drawings"})
	for path in paths:
		var before=FileAccess.get_sha256(path)
		var record=info(Image.load_from_file(path))
		record.path=path.trim_prefix(repo+"/").replace(refs+"/","local-reference/")
		record.sha256=before
		assert(before==FileAccess.get_sha256(path))
		records.append(record)
	var report={"status":"local audit; source pixels unchanged; no new animation","sources":records,"aligned_references":aligned,"art08_clips":clips,"source_preservation":true,"missing_local_rig_parts":not FileAccess.file_exists(repo+"/source_art/art08/profile/parts.json")}
	var f=FileAccess.open(out+"/audit.json",FileAccess.WRITE)
	f.store_string(JSON.stringify(report,"  "));f.close()
	print("ART10_LOCAL_AUDIT sources=",records.size()," clips=",clips.size()," frames=",frame_count," manifest_hash_matches=",matched," aligned=3 source_preservation=true")
	quit()
