extends SceneTree
var failures = 0
var checks = 0
func check(ok,label):
	checks += 1
	print("PASS: " if ok else "FAIL: ",label)
	if not ok: failures += 1
func _init(): call_deferred("run")
func run():
	var scene = load("res://gallery.tscn").instantiate()
	root.add_child(scene); current_scene = scene; scene.set_process(false)
	check(scene.packs.size()==6,"Six local candidate packs loaded")
	check(scene.kaze!=null,"Approved Kaze reference loaded without import or replacement")
	var entries = JSON.parse_string(FileAccess.get_file_as_string(scene.stage.path_join("inventory-initial.json")))
	var scanned = 0
	for pack in entries.packs:
		for e in pack.entries:
			if not e.extension in [".png",".jpg"]: continue
			var im = Image.load_from_file(scene.stage.path_join("extracted").path_join(pack.slug).path_join(e.path))
			check(not im.is_empty() and im.get_width()==e.width and im.get_height()==e.height,"Decode/dimensions: "+pack.slug+"/"+e.path)
			check(im.get_used_rect()==Rect2i(e.visible_bbox[0],e.visible_bbox[1],e.visible_bbox[2],e.visible_bbox[3]),"Alpha bounds agree between ImageIO and Godot: "+e.path)
			scanned += 1
	for pi in scene.packs.size():
		scene.select_pack(pi)
		for si in scene.packs[pi].sequences.size():
			scene.sequence_index = si; scene.reset()
			check(scene.texture!=null,"Gallery previews "+scene.selection().name)
			check(scene.cache_bytes<=scene.BUDGET,"Gallery LRU remains within 48 MiB")
			for r in scene.selection().get("regions",[]):
				check(r[2]>0 and r[3]>0 and r[0]>=0 and r[1]>=0 and r[0]+r[2]<=scene.source_size.x and r[1]+r[3]<=scene.source_size.y,"Atlas region remains within source pixels")
			if scene.selection().name.ends_with("Mossy - TileSet.png"):
				check(scene.selection().regions.size()==49,"Mossy authored 7x7 grid has 49 tiles at 512 pixels")
			if scene.selection().frames.size()>1:
				scene.frame=-1;scene.show_current();check(scene.frame==scene.selection().frames.size()-1,"Previous frame wraps safely")
	# Render original 4096 atlas once, but never cache it past the cap.
	scene.select_pack(2);scene.native_pixels=true;scene.show_current()
	check(scene.texture.get_width()==int(scene.source_size.x),"Original-resolution diagnostic works")
	check(scene.cache_bytes<=scene.BUDGET,"Oversized atlas does not violate bounded cache")
	check(scanned==1103,"All 1103 images decoded through actual Godot 4.6.1")
	check(scene.missing.is_empty(),"No missing/decode-failed preview images")
	check(ProjectSettings.get_setting("autoload",{})=={},"Isolated project has no production autoload")
	print("ASSET01 CHECKS: %d checks, %d failures"%[checks,failures])
	quit(failures)
