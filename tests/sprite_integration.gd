extends SceneTree
var failures = 0
func _init(): call_deferred("run_checks")
func check(ok, message):
	print("PASS: " if ok else "FAIL: ", message)
	if not ok: failures += 1
func run_checks():
	await process_frame
	var world = load("res://scenes/main.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	world.set_physics_process(false)
	world.player.set_physics_process(false)
	var manifest = JSON.parse_string(FileAccess.get_file_as_string("res://assets/web/kaze_manifest.json"))
	for item in manifest["sprites"]:
		check(absf(item["visual_scale"] * item["cleaned_visible_height_source"] - item["previous_visible_height"]) < 0.01, item["clip"] + " restores previous visible size")
		var texture = world.player.clips[item["clip"]]
		check(texture.get_width() == item["width"] and texture.get_height() == 724, item["clip"] + " imports with correct frame geometry")
		var image = texture.get_image()
		for frame in 8:
			var cell = image.get_region(Rect2i(frame * item["width"] / 8, 0, item["width"] / 8, 724))
			check(cell.get_used_rect().has_area(), item["clip"] + " frame %d contains artwork" % frame)
	world.player.dash_time = 0.1
	world.player.facing = -1
	world.player.animate(0)
	check(world.player.sprite.texture == world.player.clips["traversal"] and world.player.sprite.frame == 7, "Dash retains traversal pose 7")
	check(world.player.sprite.flip_h, "Left-facing cleaned art mirrors correctly")
	check(is_equal_approx(world.player.sprite.scale.x, manifest["sprites"][3]["visual_scale"]) and is_equal_approx(world.player.sprite.offset.y, -148), "Dash uses restored scale and preserved floor pivot")
	world.hud.toggle_loadout()
	await process_frame
	var args = OS.get_cmdline_user_args()
	if "--capture" in args:
		RenderingServer.force_draw(false)
		root.get_texture().get_image().save_png(args[args.find("--capture") + 1])
	world.queue_free()
	current_scene = null
	await process_frame
	quit(1 if failures else 0)
