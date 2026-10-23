extends SceneTree
var failures: Array = []
var count = 0
var report = {"assets":{}}
func check(ok: bool, message: String):
	count += 1
	if not ok: failures.append(message); push_error(message)
func _initialize(): run.call_deferred()
func run():
	var args = OS.get_cmdline_user_args()
	if args.size()!=3: quit(1); return
	var code = args[0]; var cache = args[1]; var output = args[2]
	var bank = load(code.path_join("bank.gd")).new()
	check(bank.open(cache),"Hash-pinned cache opens")
	for id in bank.manifest.assets:
		var row = bank.manifest.assets[id]
		var bases: Array = []
		var unique = {}
		for frame in row.frames:
			var img = Image.load_from_file(cache.path_join(frame.path))
			check(img.get_size()==Vector2i(row.canvas_size[0],row.canvas_size[1]),id+" fixed canvas")
			var used = img.get_used_rect()
			check(used.position.x>=2 and used.position.y>=2 and used.end.x<=img.get_width()-2 and used.end.y<=img.get_height()-2,id+" transparent filtering gutter")
			check(img.detect_alpha()!=Image.ALPHA_NONE,id+" alpha retained")
			bases.append(used.end.y)
			unique[frame.sha256]=true
		bases.sort()
		var a = bank.textures[id][0].get_image()
		var b = bank.textures[id][-1].get_image()
		a.resize(32,32); b.resize(32,32)
		var error = 0.0
		for y in 32:
			for x in 32:
				var ca = a.get_pixel(x,y); var cb = b.get_pixel(x,y)
				error += (absf(ca.r*ca.a-cb.r*cb.a)+absf(ca.g*ca.a-cb.g*cb.a)+absf(ca.b*ca.a-cb.b*cb.a)+absf(ca.a-cb.a))/4.0
		report.assets[id] = {"frames":row.frames.size(),"unique_frames":unique.size(),"loop_edge_mean_error":error/1024.0,"base_variation_px":bases[-1]-bases[0],"content_size":row.content_size}
		if id in ["poison","slime_green","slime_orange"]:
			check(row.content_size[0]<=(88 if id=="poison" else 84),id+" gameplay footprint width")
		if row.frames.size()>1: check(unique.size()>1,id+" contains actual animation")
	check(bank.bytes<16*1024*1024,"Mixed selection fits 16 MiB budget")
	var hazard = load("res://scripts/hazards/environmental_hazard.gd").new()
	var placement = load("res://scripts/hazards/hazard_placement.gd").new()
	placement.reset_rule = "persist_disabled"
	hazard.placement = placement; root.add_child(hazard); hazard.set_physics_process(false)
	var layer = load(code.path_join("presentation.gd")).new()
	layer.bank = bank; layer.mode = "hazard"; layer.subject = hazard
	hazard.add_child(layer)
	for phase in ["warning","active","recovery","idle"]:
		hazard.advance(hazard.duration())
		check(hazard.phase==phase and layer.phase==phase,"Real hazard signal: "+phase)
		check(layer.observed.has(phase),"Observed hazard: "+phase)
	var state_before = hazard.snapshot()
	layer.paused_motion = true
	var clock_before = layer.clock
	layer._process(0.2)
	check(layer.clock==clock_before,"Reduced motion freezes body animation")
	check(hazard.snapshot()==state_before,"Reduced motion does not write hazard state")
	layer.paused_motion = false
	await process_frame
	paused = true
	clock_before = layer.clock
	await create_timer(0.08,true).timeout
	check(layer.clock==clock_before,"Scene pause stops presentation animation")
	paused = false
	hazard.set_enabled(false)
	var saved = hazard.snapshot()
	hazard.set_enabled(true); hazard.reset_room(saved)
	check(not hazard.enabled and hazard.phase=="idle","Disabled hazard survives existing snapshot/reset")
	check(not layer.subject.available(),"Disabled presentation follows real availability")
	hazard.set_enabled(true); hazard.advance(hazard.duration())
	check(hazard.phase=="warning" and layer.phase=="warning","Re-enabled hazard restores warning before danger")
	var signal_count = hazard.phase_changed.get_connections().size()
	layer.free()
	check(hazard.phase_changed.get_connections().size()==signal_count-1,"Presentation teardown disconnects signals")
	hazard.free()
	report.assertions = count; report.failures = failures; report.passed = failures.is_empty()
	report.texture_rgba_bytes = bank.bytes; report.cached_frames = bank.decoded
	var file = FileAccess.open(output,FileAccess.WRITE);file.store_string(JSON.stringify(report,"\t"));file.close()
	print("ART11 VALIDATION "+JSON.stringify({"assertions":count,"failures":failures,"frames":bank.decoded,"rgba_bytes":bank.bytes}))
	quit(0 if failures.is_empty() else 1)
