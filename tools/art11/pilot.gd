extends SceneTree
## Isolated native presentation harness; production scripts and saves are untouched.
class Keys extends Node:
	signal pressed(key)
	func _unhandled_key_input(event):
		if event is InputEventKey and event.pressed and not event.echo: pressed.emit(event.physical_keycode)
var mode = "moss"
var code = ""
var cache = ""
var output = ""
var checks = false
var baseline_only = false
var host
var bank
var layer_script
var layers: Array = []
var before: Array = []
var topology_ok = false
var clock = 0.0
var samples: Array = []
var draws: Array = []
var active_room = -1
var capture_flags: Dictionary = {}
var report: Dictionary = {}
var title: Label
var finished = false
var last_tick = 0
func _initialize():
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--mode="): mode = arg.trim_prefix("--mode=")
		if arg.begins_with("--code="): code = arg.trim_prefix("--code=")
		if arg.begins_with("--cache="): cache = arg.trim_prefix("--cache=")
		if arg.begins_with("--output="): output = arg.trim_prefix("--output=")
		if arg == "--check": checks = true
		if arg == "--baseline": baseline_only = true
	if mode not in ["moss","cave","enemy","hazard"] or code.is_empty() or cache.is_empty() or not "--test" in OS.get_cmdline_user_args():
		push_error("Launch through tools/art11/launch.py"); quit(1); return
	start.call_deferred()
func shape_snapshot(node: Node) -> Array:
	var result: Array = []
	if node is CollisionShape2D:
		result.append([str(node.get_path()),str(node.transform),node.shape.get_class(),str(node.shape.get_rect()),node.disabled])
	if node is CollisionObject2D:
		result.append([str(node.get_path()),node.get_class(),node.collision_layer,node.collision_mask])
	for child in node.get_children(): result.append_array(shape_snapshot(child))
	return result
func add_visual(parent, visual_mode, subject = null):
	var layer = layer_script.new()
	layer.bank = bank; layer.mode = visual_mode; layer.subject = subject
	if visual_mode == "hazard": layer.z_index = -1
	parent.add_child(layer); layers.append(layer)
	return layer
func start():
	bank = load(code.path_join("bank.gd")).new()
	if not bank.open(cache): push_error("Invalid texture cache"); quit(1); return
	layer_script = load(code.path_join("presentation.gd"))
	if layer_script == null: quit(1); return
	var scene = "res://scenes/main.tscn"
	if mode == "enemy": scene = "res://scenes/encounters/guard.tscn"
	if mode == "hazard": scene = "res://scenes/haz01/course.tscn"
	host = load(scene).instantiate()
	host.save_path = "user://art11_" + mode + "_only.json"
	root.add_child(host); current_scene = host
	await process_frame
	if mode in ["moss","cave"]:
		host.build_room(16 if mode == "moss" else 15)
		host.player.position = Vector2(410,1120) if mode=="moss" else Vector2(1650,1080)
		host.player.velocity = Vector2.ZERO
		host.message_time = 0
		if checks:
			host.set_physics_process(false); host.player.set_physics_process(false)
			for enemy in host.enemies: enemy.set_physics_process(false)
			host.camera.reparent(host)
			host.camera.position = Vector2(1000,810) if mode=="moss" else Vector2(1100,810)
			host.camera.zoom = Vector2(0.56,0.56)
			host.camera.position_smoothing_enabled = false
			host.camera.reset_smoothing()
		await process_frame
	if mode == "enemy" and checks:
		host.player.position = Vector2(620,618)
		host.player.set_physics_process(false)
		# Keep the real encounter running without a death/restart disrupting capture.
		host.player.invulnerable = 99
	if checks and mode != "hazard": host.hud.visible = false
	if checks and mode == "hazard": host.status.visible = false
	before = shape_snapshot(host)
	attach()
	topology_ok = before == shape_snapshot(host)
	var keys = Keys.new(); root.add_child(keys); keys.pressed.connect(key)
	var hud = CanvasLayer.new(); hud.layer = 100; root.add_child(hud)
	var panel = ColorRect.new(); panel.position = Vector2(16,16); panel.size = Vector2(1248,84); panel.color = Color(0.025,0.05,0.07,0.94); hud.add_child(panel)
	title = Label.new(); title.position = Vector2(30,26); title.add_theme_font_size_override("font_size",17); hud.add_child(title)
	if mode == "hazard" and not checks:
		panel.position.y = 160; title.position.y = 170
	title.text = "ART-11 / " + mode.to_upper() + " / LOCAL PRESENTATION PILOT / CREATOR REVIEW PENDING\nF4 art on/off   F7 collision/target guides   F8 reduced motion   F10 slime color   Esc exit\nOriginal geometry, timing, controls and progression retained. Test saves only."
	if mode == "hazard": title.text += "\nPlant art on existing steam cycle; no new damage type."; panel.size.y = 108
	if not output.is_empty(): DirAccess.make_dir_recursive_absolute(output)
	report = {"mode":mode,"collision_topology_unchanged_on_attach":topology_ok,"cached_frames":bank.decoded,"texture_rgba_bytes":bank.bytes,"baseline_only":baseline_only,"production_placements":0,"host_engine":Engine.get_version_info().string}
	if mode in ["moss","cave"]:
		report.room = host.room
		report.surfaces = []
		for surface in layers[0].surfaces: report.surfaces.append([surface.position.x,surface.position.y,surface.size.x,surface.size.y])
		report.foliage_count = layers[0].foliage.size()
		report.protected_counts = layers[0].protected_counts
		report.backgrounds = []
		for item in layers[0].backgrounds: report.backgrounds.append({"id":item.id,"feet":[item.at.x,item.at.y]})
		report.rejected_exclusion_placements = layers[0].rejected
		report.foliage = []
		for item in layers[0].foliage: report.foliage.append({"id":item.id,"feet":[item.at.x,item.at.y]})
	clock = 0.001
	last_tick = Time.get_ticks_usec()
func attach():
	active_room = host.room
	if mode in ["moss","cave"]:
		var layer = add_visual(host,mode)
		host.move_child(layer,0)
		layer.setup_room(host,mode)
	elif mode == "hazard":
		for hazard in host.hazards:
			if hazard.placement.kind == "steam": add_visual(hazard,"hazard",hazard)
	elif mode == "enemy":
		for enemy in host.encounter.members:
			add_visual(enemy,"enemy",enemy)
			enemy.sprite.visible = false
	if baseline_only:
		for layer in layers: layer.art_enabled = false
		if mode == "enemy":
			for enemy in host.encounter.members: enemy.sprite.visible = true
func key(keycode):
	if keycode == KEY_ESCAPE: quit()
	for layer in layers:
		if not is_instance_valid(layer): continue
		if keycode == KEY_F4:
			layer.art_enabled = not layer.art_enabled
			if mode=="enemy" and is_instance_valid(layer.subject): layer.subject.sprite.visible = not layer.art_enabled
		if keycode == KEY_F7: layer.overlay = not layer.overlay
		if keycode == KEY_F8: layer.paused_motion = not layer.paused_motion
		if keycode == KEY_F10: layer.use_orange = not layer.use_orange
func _process(delta):
	if clock == 0 or finished: return false
	clock += delta
	var now = Time.get_ticks_usec()
	var wall_ms = (now-last_tick)/1000.0
	last_tick = now
	if current_scene != host and is_instance_valid(current_scene):
		# A host restart recreates its own behavior; reattach only to the new local host.
		host = current_scene; layers.clear()
		attach()
	if mode in ["moss","cave"] and host.room != active_room:
		for layer in layers:
			if is_instance_valid(layer): layer.queue_free()
		layers.clear()
		# Review art is restricted to the nominated room. Leaving restores ordinary presentation.
		if host.room == (16 if mode=="moss" else 15): attach()
		else: active_room = host.room
	if clock > 7.0:
		samples.append(wall_ms)
		draws.append(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
	if checks and not output.is_empty() and not baseline_only:
		if mode in ["moss","cave"]:
			if clock > 1 and not capture_flags.has("art"): shot("art")
			if clock > 2 and not capture_flags.has("baseline"):
				for layer in layers: layer.art_enabled = false
				shot("baseline")
			if clock > 3 and not capture_flags.has("collision"):
				for layer in layers: layer.art_enabled = true; layer.overlay = true
				shot("collision")
			if clock > 4:
				for layer in layers: layer.overlay = false
			if clock > 5 and not capture_flags.has("detail"):
				host.camera.position = Vector2(850,990) if mode=="moss" else Vector2(1500,1000)
				host.camera.zoom = Vector2(0.9,0.9)
				shot("detail")
			if clock > 6:
				host.camera.position = Vector2(1000,810) if mode=="moss" else Vector2(1100,810)
				host.camera.zoom = Vector2(0.56,0.56)
		else:
			for layer in layers:
				if not is_instance_valid(layer): continue
				if layer.phase in ["idle","warning","active","recovery","windup","strike","recover","stunned"] and not capture_flags.has(layer.phase):
					shot(layer.phase)
	if checks and clock > 12.0: finish.call_deferred(); finished = true
	return false
func shot(tag):
	capture_flags[tag] = true
	capture.call_deferred(tag)
func capture(tag):
	await RenderingServer.frame_post_draw
	var error = root.get_texture().get_image().save_png(output.path_join(mode+"_"+tag+".png"))
	if error != OK: push_error("Capture failed"); quit(1)
func finish():
	samples.sort(); draws.sort()
	report.samples = samples.size()
	report.frame_ms_p50 = samples[int(samples.size()*0.5)]
	report.frame_ms_p95 = samples[mini(samples.size()-1,int(samples.size()*0.95))]
	report.draw_calls_p95 = draws[mini(draws.size()-1,int(draws.size()*0.95))]
	report.decode_count_stable = bank.decoded == report.cached_frames
	report.states = []
	for layer in layers:
		if is_instance_valid(layer):
			for state in layer.observed:
				if not state in report.states: report.states.append(state)
	var valid = topology_ok and report.decode_count_stable
	if mode == "hazard": valid = valid and "warning" in report.states and "active" in report.states and "recovery" in report.states
	if mode == "enemy": valid = valid and "windup" in report.states and "strike" in report.states and "recover" in report.states
	if mode in ["moss","cave"]:
		report.no_occlusion_intersections = true
		for layer in layers:
			for item in layer.foliage + layer.backgrounds:
				for zone in layer.exclusions:
					if bank.rect(item.id,item.at).intersects(zone): report.no_occlusion_intersections = false
		valid = valid and report.no_occlusion_intersections
		valid = valid and report.protected_counts.anchors >= 2
		valid = valid and (report.protected_counts.hazards >= 1 if mode=="cave" else report.protected_counts.checkpoints == 1)
	# Detach and compare at the same phase, so a legitimate collapse transition is not a false failure.
	var pre_detach = shape_snapshot(host)
	for layer in layers:
		if is_instance_valid(layer):
			if mode == "enemy" and is_instance_valid(layer.subject): layer.subject.sprite.visible = true
			layer.get_parent().remove_child(layer); layer.free()
	report.collision_topology_unchanged_on_detach = pre_detach == shape_snapshot(host)
	valid = valid and report.collision_topology_unchanged_on_detach
	report.passed = valid
	if not output.is_empty():
		var file = FileAccess.open(output.path_join(mode+("_baseline" if baseline_only else "")+"_results.json"),FileAccess.WRITE)
		file.store_string(JSON.stringify(report,"\t")); file.close()
	print("ART11 RESULT " + JSON.stringify(report))
	quit(0 if valid else 1)
