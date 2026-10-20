extends SceneTree
# Engine draw-order capture of the Canal exit at zoom 1.0 (software GL under xvfb). Writes docs/pm_pilot/art/previews/canal_exit_godot_capture.png
# xvfb-run -a -s "-screen 0 1280x720x24" godot --rendering-method gl_compatibility --rendering-driver opengl3 --path . --script res://tools/pm_pilot_art/godot_capture.gd
const VIEW = Vector2(0, 720)
class Canvas extends Node2D:
	var keep = {}   # textures must stay referenced until the frame is rendered
	func tex(path: String) -> Texture2D:
		if not keep.has(path): keep[path] = ImageTexture.create_from_image(Image.load_from_file(ProjectSettings.globalize_path(path)))
		return keep[path]
	func _draw():
		var m = JSON.parse_string(FileAccess.get_file_as_string("res://assets/pm_pilot/MANIFEST.json"))
		draw_texture_rect(tex("res://assets/web/district-fidelity.png"), Rect2(-VIEW, Vector2(1800, 1440)), false, Color(0.72, 0.7, 0.86, 0.92))
		for r in [Rect2(0, 1200, 360, 40), Rect2(200, 1160, 120, 40)]:
			draw_rect(Rect2(r.position - VIEW, r.size), Color("26343e")); draw_line(r.position - VIEW, r.position + Vector2(r.size.x, 0) - VIEW, Color("d9c9ad"), 3)
		var back = m.assets.filter(func(a): return a.has("draw_order_back_to_front") and a.draw_order_back_to_front is float and not a.in_front_of_kaze)
		back.sort_custom(func(a, b): return a.draw_order_back_to_front < b.draw_order_back_to_front)
		for a in back: draw_texture(tex("res://" + a.path), Vector2(a.room_rect[0], a.room_rect[1]) - VIEW)
		# Kaze idle strip frame 0, registered as player.gd does (scale 0.265, baseline 591, facing left)
		var kt: Texture2D = tex("res://assets/kaze/cleaned/kaze_idle_strip.png")
		var sc = 0.2649908807267889; var fw = kt.get_width() / 8.0
		draw_set_transform(Vector2(200, 1200) - VIEW, 0, Vector2(-sc, sc))
		draw_texture_rect_region(kt, Rect2(-fw / 2.0, -591, fw, kt.get_height()), Rect2(0, 0, fw, kt.get_height()))
		draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
		for a in m.assets:
			if a.get("in_front_of_kaze", false): draw_texture(tex("res://" + a.path), Vector2(a.room_rect[0], a.room_rect[1]) - VIEW)
func _initialize():
	root.size = Vector2i(1280, 720)
	var c = Canvas.new(); root.add_child(c)
	for i in 6: await process_frame
	c.queue_redraw()
	for i in 6: await process_frame
	var img = root.get_texture().get_image()
	img.save_png("res://docs/pm_pilot/art/previews/canal_exit_godot_capture.png")
	print("saved ", img.get_size())
	quit()
