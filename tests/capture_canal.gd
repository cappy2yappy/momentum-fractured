extends SceneTree
## LEVEL pilot graphical captures of the Canal-left exit (software GL when run under xvfb).
## Usage: godot --rendering-method gl_compatibility --script res://tests/capture_canal.gd -- <output dir>
func _init(): call_deferred("_run")
func shot(path):
	await process_frame
	RenderingServer.force_draw(false)
	await process_frame
	root.get_texture().get_image().save_png(path)
func _run():
	await process_frame
	var out = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(out)
	var world = load("res://scenes/main.tscn").instantiate()
	root.add_child(world);current_scene = world
	world.set_physics_process(false);world.player.set_physics_process(false)
	world.player.double_jump = true;world.player.tether_unlocked = true;world.player.dash_unlocked = true
	world.completed = true;world.boss_defeated = true;world.guard_defeated = true;world.message_time = 0.0
	world.build_room(13)
	for enemy in world.enemies: enemy.set_physics_process(false)
	print("CAPTURE driver=",RenderingServer.get_current_rendering_driver_name()," adapter=",RenderingServer.get_video_adapter_name()," viewport=",root.size)
	var overlay = Node2D.new();overlay.set_script(load("res://tests/fixtures/canal_overlay.gd"));overlay.z_index = 50;overlay.visible = false
	world.add_child(overlay)
	var views = [
		["arrival_184",Vector2(184,1198),Vector2.ONE,false,1],
		["at_door_threshold",Vector2(124,1198),Vector2.ONE,false,-1],
		["mouth_340",Vector2(340,1198),Vector2.ONE,false,-1],
		["ceiling_bump",Vector2(250,1082),Vector2.ONE,false,-1],
		["overview_wide",Vector2(450,900),Vector2(0.5,0.5),false,1],
		["contract_overlay",Vector2(184,1198),Vector2.ONE,true,-1],
		["overview_overlay",Vector2(450,900),Vector2(0.5,0.5),true,1],
	]
	for v in views:
		overlay.visible = v[3]
		world.player.position = v[1];world.player.velocity = Vector2.ZERO;world.player.facing = v[4]
		world.player.animate(0)
		world.camera.zoom = v[2]
		world.camera.position_smoothing_enabled = false;world.camera.reset_smoothing()
		world.queue_redraw();overlay.queue_redraw()
		await shot(out.path_join(v[0] + ".png"))
	world.queue_free();current_scene = null
	await process_frame
	print("CANAL CAPTURE: complete")
	quit()
