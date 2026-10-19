extends SceneTree
## LD-05 captures (software GL under xvfb). Spec JSON: [{"name","room","center":[x,y],"zoom":z,"overlay":bool,"player":[x,y]?}, ...]
## xvfb-run -a -s "-screen 0 1280x720x24" godot --rendering-method gl_compatibility --rendering-driver opengl3 --path . --script res://tools/ld05/capture.gd -- <spec.json> <out dir>
func _init(): call_deferred("_run")
func shot(path):
	await process_frame
	RenderingServer.force_draw(false)
	await process_frame
	root.get_texture().get_image().save_png(path)
func _run():
	await process_frame
	var args = OS.get_cmdline_user_args()
	var spec = JSON.parse_string(FileAccess.get_file_as_string(args[0]))
	var out = args[1]
	DirAccess.make_dir_recursive_absolute(out)
	var world = load("res://scenes/main.tscn").instantiate()
	root.add_child(world);current_scene = world
	world.set_physics_process(false);world.player.set_physics_process(false)
	world.player.double_jump = true;world.player.tether_unlocked = true;world.player.dash_unlocked = true
	world.completed = true;world.boss_defeated = true;world.guard_defeated = true;world.message_time = 0.0
	var overlay = Node2D.new();overlay.set_script(load("res://tools/ld05/overlay.gd"));overlay.z_index = 50;overlay.world = world
	world.add_child(overlay)
	var cam = world.camera
	for v in spec:
		world.build_room(int(v.room))
		for enemy in world.enemies: enemy.set_physics_process(false)
		overlay.visible = v.get("overlay",false)
		var c = Vector2(v.center[0],v.center[1])
		world.player.position = Vector2(v.player[0],v.player[1]) if v.has("player") else c + Vector2(0,110)
		world.player.velocity = Vector2.ZERO;world.player.animate(0)
		cam.limit_left = -2000;cam.limit_top = -2000;cam.limit_right = 6000;cam.limit_bottom = 6000
		cam.zoom = Vector2(v.zoom,v.zoom)
		cam.position = Vector2(0,-110)
		if v.has("player"): cam.position = c - world.player.position
		cam.position_smoothing_enabled = false;cam.reset_smoothing()
		world.message_time = 0
		world.queue_redraw();overlay.queue_redraw()
		await shot(out.path_join(v.name + ".png"))
		print("CAPTURED ",v.name)
	world.queue_free();current_scene = null
	await process_frame
	quit()
