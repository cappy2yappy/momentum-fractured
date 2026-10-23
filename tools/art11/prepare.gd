extends SceneTree
## Derivatives stay outside Git. Run only after the launcher verifies intake hashes.
func _initialize(): run.call_deferred()
func run():
	var args = OS.get_cmdline_user_args()
	if args.size() != 3: push_error("Expected stage, selections.json, output"); quit(1); return
	var stage = args[0]
	var plan = JSON.parse_string(FileAccess.get_file_as_string(args[1]))
	var output = args[2]
	var inventory = JSON.parse_string(FileAccess.get_file_as_string(stage.path_join("gallery.json")))
	DirAccess.make_dir_recursive_absolute(output)
	var result = {"version":1, "source_commit":plan.source_commit, "assets":{}, "rgba_bytes":0, "frame_count":0}
	for selected in plan.selections:
		var seq = {}
		var slug = ""
		for pack in inventory.packs:
			for entry in pack.sequences:
				if entry.id == selected.sequence_id: seq = entry; slug = pack.slug
		if seq.is_empty(): push_error("Unknown selection"); quit(1); return
		var images: Array[Image] = []
		var source_hashes = []
		var used = Rect2i()
		for file in seq.frames:
			var path = stage.path_join("extracted").path_join(slug).path_join(file)
			var img = Image.load_from_file(path)
			if img == null or img.is_empty(): push_error("Undecodable " + path); quit(1); return
			img.convert(Image.FORMAT_RGBA8)
			if selected.region >= 0:
				var r = seq.regions[selected.region]
				img = img.get_region(Rect2i(r[0],r[1],r[2],r[3]))
			var bounds = img.get_used_rect()
			if not bounds.has_area(): push_error("Empty frame"); quit(1); return
			used = bounds if images.is_empty() else used.merge(bounds)
			images.append(img)
			source_hashes.append({"path":file,"sha256":FileAccess.get_sha256(path)})
		var scale_factor = float(selected.height) / used.size.y
		if selected.has("max_width"): scale_factor = minf(scale_factor,float(selected.max_width)/used.size.x)
		var size = Vector2i(maxi(1, roundi(used.size.x*scale_factor)),maxi(1,roundi(used.size.y*scale_factor)))
		var frames = []
		var alpha_bounds = []
		for i in images.size():
			var img = images[i].get_region(used)
			# Fix transparent RGB before filtering; a fixed union crop preserves each frame's pivot.
			img.fix_alpha_edges()
			img.resize(size.x,size.y,Image.INTERPOLATE_LANCZOS)
			var padded = Image.create(size.x+4,size.y+4,false,Image.FORMAT_RGBA8)
			padded.fill(Color.TRANSPARENT)
			padded.blit_rect(img,Rect2i(Vector2i.ZERO,size),Vector2i(2,2))
			padded.fix_alpha_edges()
			var file = selected.id + "_%03d.png" % i
			if padded.save_png(output.path_join(file)) != OK: push_error("Write failed"); quit(1); return
			frames.append({"path":file,"sha256":FileAccess.get_sha256(output.path_join(file))})
			var b = padded.get_used_rect()
			alpha_bounds.append([b.position.x,b.position.y,b.size.x,b.size.y])
			result.rgba_bytes += (size.x+4)*(size.y+4)*4
			result.frame_count += 1
		result.assets[selected.id] = {"selection":selected,"source_hashes":source_hashes,"frames":frames,
			"union_crop":[used.position.x,used.position.y,used.size.x,used.size.y],
			"canvas_size":[size.x+4,size.y+4],"pivot":[(size.x+4)/2.0,size.y+2],
			"content_size":[size.x,size.y],"alpha_bounds":alpha_bounds,
			"recipe":"fixed alpha union crop; fix_alpha_edges; Lanczos resize; 2px transparent gutter; fixed bottom-center pivot",
			"fps":selected.fps,"production_approved":false}
	var file = FileAccess.open(output.path_join("runtime.json"),FileAccess.WRITE)
	file.store_string(JSON.stringify(result,"\t")); file.close()
	print("ART11 PREPARE " + JSON.stringify({"frames":result.frame_count,"rgba_bytes":result.rgba_bytes,"selections":result.assets.size()}))
	quit()
