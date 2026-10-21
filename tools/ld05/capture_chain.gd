extends "res://tools/ld05/room_probe.gd"
## LD-05 before/after evidence: a real-key wall-jump chain, photographed with a camera that is allowed to look above the room.
## xvfb-run -a -s "-screen 0 1280x720x24" godot --rendering-method gl_compatibility --rendering-driver opengl3 --path . --fixed-fps 60 --script res://tools/ld05/capture_chain.gd -- <out dir> <label>
var out_dir = ""
func snap(name):
	await process_frame;await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out_dir.path_join(name + ".png"))
func chain_shot(name, index, start:Vector2, toward:int, zoom:float):
	await place(index,start)
	w.camera.limit_top = -900;w.camera.limit_left = -400;w.camera.limit_right = 6000
	w.camera.zoom = Vector2(zoom,zoom);w.camera.position_smoothing_speed = 30
	var kt = KEY_A if toward < 0 else KEY_D
	key(kt,true)
	var release = 0;var nextjump = 0;var top_tick = -1;var miny = start.y
	for t in 1500:
		if (w.player.is_on_wall() or w.player.is_on_floor()) and not held_keys.get(KEY_SPACE,false) and t >= nextjump:
			key(KEY_SPACE,true);release = t + 25;nextjump = t + 30
		if held_keys.get(KEY_SPACE,false) and t >= release: key(KEY_SPACE,false)
		await wait_ticks(1)
		miny = minf(miny,w.player.position.y)
		if miny < 116.5 and top_tick < 0: top_tick = t
		if top_tick >= 0 and t >= top_tick + 70: break
		if not still_here(index): break
	release_all()
	print("CHAIN ",name," miny=",miny," pos=",w.player.position)
	await snap(name)
func run():
	await process_frame
	var a = OS.get_cmdline_user_args();out_dir = a[0];var label = a[1]
	DirAccess.make_dir_recursive_absolute(out_dir)
	w = load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene = w;freeze();seed_fixture();automation_hud()
	await chain_shot("%s_R13_gatehouse_face" % label,13,Vector2(314.6,438.0),-1,0.55)
	await chain_shot("%s_R13_right_wall" % label,13,Vector2(1785.4,1298.0),1,0.35)
	await chain_shot("%s_R16_left_wall" % label,16,Vector2(14.6,1298.0),-1,0.33)
	await chain_shot("%s_R1_right_wall" % label,1,Vector2(2585.4,1298.0),1,0.33)
	quit(0)
