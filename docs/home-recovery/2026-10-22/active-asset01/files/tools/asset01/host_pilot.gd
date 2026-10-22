extends SceneTree
## Run from a separate PR87 checkout. Presentation children have no physics/save ownership.
var host
var stage = ""
var mode = ""
var check_mode = false
var capture_path = ""
var clock = 0.0
var topology: Array = []
var visuals: Array = []
var captured = false

class ReviewVisual extends Node2D:
	var stage_root: String
	var pack: String
	var sequence: Dictionary
	var region = -1
	var subject
	var timer = 0.0
	var frame = -1
	var texture: ImageTexture
	var states: Dictionary = {}
	var tag = ""
	func _process(delta):
		timer += delta
		var next = int(timer * 12.0) % sequence.frames.size()
		if next != frame:
			frame = next
			var source = stage_root.path_join("extracted").path_join(pack).path_join(sequence.frames[frame])
			var image = Image.load_from_file(source)
			if image.is_empty(): push_error("Missing verified pilot source"); get_tree().quit(1); return
			if region >= 0:
				var r = sequence.regions[region]
				image = image.get_region(Rect2i(r[0], r[1], r[2], r[3]))
			texture = ImageTexture.create_from_image(image)
		if is_instance_valid(subject):
			var key = "phase" if subject.get("phase") != null else "state"
			states[str(subject.get(key))] = true
		queue_redraw()
	func _draw():
		if texture != null:
			var size = Vector2(texture.get_size()) * 0.25
			draw_texture_rect(texture, Rect2(Vector2(-size.x / 2.0, -size.y), size), false)
		var state = "decoration"
		if is_instance_valid(subject):
			state = str(subject.get("phase") if subject.get("phase") != null else subject.get("state"))
		draw_string(ThemeDB.fallback_font, Vector2(-65, 20), tag + " / " + state, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("a8e5ea"))

func _initialize():
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--stage="): stage = arg.trim_prefix("--stage=")
		if arg.begins_with("--host-mode="): mode = arg.trim_prefix("--host-mode=")
		if arg == "--pilot-check": check_mode = true
		if arg.begins_with("--pilot-capture="): capture_path = arg.trim_prefix("--pilot-capture=")
	if stage.is_empty() or mode not in ["enemy", "hazard"] or not "--test" in OS.get_cmdline_user_args():
		push_error("Use verified review_pilot.py with --host-mode and --test"); quit(1); return
	start.call_deferred()

func shapes(node: Node) -> Array:
	var result: Array = []
	if node is CollisionShape2D:
		result.append([str(node.get_path()), str(node.position), node.shape.get_class(), str(node.shape.get_rect())])
	for child in node.get_children(): result.append_array(shapes(child))
	return result

func add_visual(parent: Node, slug: String, sequence_name: String, at: Vector2, label_text: String, slice = -1, subject = null):
	var inventory = JSON.parse_string(FileAccess.get_file_as_string(stage.path_join("gallery.json")))
	for pack in inventory.packs:
		if pack.slug != slug: continue
		for sequence in pack.sequences:
			if sequence.name != sequence_name: continue
			var visual = ReviewVisual.new()
			visual.stage_root = stage; visual.pack = slug; visual.sequence = sequence
			visual.position = at; visual.region = slice; visual.tag = label_text; visual.subject = subject
			visual.z_index = 1
			parent.add_child(visual); visuals.append(visual); return
	push_error("Curated host selection missing"); quit(1)

func start():
	var scene = "res://scenes/encounters/guard.tscn" if mode == "enemy" else "res://scenes/haz01/course.tscn"
	var packed = load(scene)
	if packed == null: push_error("Missing pinned EN-01/HAZ-01 host"); quit(1); return
	host = packed.instantiate()
	root.add_child(host); current_scene = host
	# Let the existing lab complete its own setup before adding presentation children.
	await process_frame
	topology = shapes(host)
	if check_mode and mode == "enemy":
		# Test arrangement only: observe the real combat cycle without synthesizing states.
		host.player.position = Vector2(620,618)
	add_visual(host, "plant-animations", "Plant Animations/BlueFlower1", Vector2(160,620), "FOL-01")
	add_visual(host, "plantsanimated", "Vegetation/Grass2", Vector2(480,620), "FOL-02")
	add_visual(host, "caveassetsmaaot", "Assets 1024 Cave/Cave - BigRocks1.png", Vector2(1220,620), "SCN-02", 1)
	add_visual(host, "mossy-assets", "Mossy Tileset/Mossy - Hanging Plants.png", Vector2(1180,400), "SCN-01", 0)
	if mode == "enemy":
		for enemy in host.encounter.members:
			# Companion comparison: retain the guard sprite, target, hit volume and original cues.
			add_visual(enemy, "slimes", "SlimeGreen", Vector2(110,0), "EN-VIS-01 COMPARE", -1, enemy)
	else:
		for hazard in host.hazards:
			if hazard.placement.kind == "steam":
				add_visual(hazard, "plant-animations", "Plant Animations/Plant 8 Poison", Vector2(180,0), "HAZ-VIS-01 COMPARE", -1, hazard)
	var layer = CanvasLayer.new(); root.add_child(layer)
	var title = Label.new(); title.position = Vector2(24,230)
	title.text = "ASSET-01 LOCAL PILOT / 12 FPS ASSUMPTION / NO PRODUCTION APPROVAL\nCompanion visuals only. Existing collision, targets, damage and state cues remain authoritative."
	title.add_theme_font_size_override("font_size", 16); layer.add_child(title)
	clock = 0.001

func _process(delta):
	if clock == 0.0 or not is_instance_valid(host): return false
	clock += delta
	if not capture_path.is_empty() and clock > 2.0 and not captured:
		captured = true; capture.call_deferred()
	if check_mode and clock > 8.0:
		var observed = {}
		for visual in visuals:
			if is_instance_valid(visual) and not visual.states.is_empty(): observed[visual.tag] = visual.states.keys()
		var same = topology == shapes(host)
		var enough_states = false
		for key in observed:
			if mode == "enemy": enough_states = "windup" in observed[key] and "strike" in observed[key]
			else: enough_states = "warning" in observed[key] and "active" in observed[key] and "recovery" in observed[key]
		print("ASSET01 HOST: " + JSON.stringify({"mode":mode,"collision_topology_unchanged":same,"observed_states":observed,"state_cycle_observed":enough_states,"production_placements":0}))
		quit(0 if same and enough_states else 1)
	return false

func capture():
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(capture_path)
