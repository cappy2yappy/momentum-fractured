extends SceneTree
func _init(): call_deferred("run")
func run():
	await process_frame
	var output = "res://docs/art/alpha061/previews"
	for biome in ["city_rooftop", "underground_approach"]:
		var folder = "res://assets/environment/alpha061/" + biome
		for filename in DirAccess.get_files_at(folder):
			if not filename.ends_with(".svg"): continue
			var layer_image = Image.new()
			if layer_image.load_svg_from_string(FileAccess.get_file_as_string(folder.path_join(filename))) != OK: quit(1);return
			layer_image.save_png(folder.path_join(filename.replace(".svg", ".png")))
			var mismatches = 0
			for y in layer_image.get_height():
				if layer_image.get_pixel(0,y) != layer_image.get_pixel(layer_image.get_width()-1,y): mismatches += 1
			print("SEAM EDGE CHECK: ",biome,"/",filename," different edge rows=",mismatches)
		for suffix in ["_layered", ""]:
			if suffix == "": continue
			var file = "res://assets/environment/alpha061/" + biome + "/" + biome + suffix + ".svg"
			var image = Image.new()
			var error = image.load_svg_from_string(FileAccess.get_file_as_string(file))
			if error != OK: push_error("SVG render failed: " + file);quit(1);return
			image.save_png(output.path_join(biome + "_render.png"))
	for mode in ["baseline", "composition"]:
		var w = load("res://scenes/main.tscn").instantiate() if mode == "baseline" else load("res://docs/art/alpha061/composition_world.gd").new()
		root.add_child(w);current_scene = w
		w.set_physics_process(false);w.player.set_physics_process(false)
		w.player.double_jump=true;w.player.tether_unlocked=true;w.player.dash_unlocked=true
		w.message_time=0;w.camera.position_smoothing_enabled=false
		var canvas = CanvasLayer.new();w.add_child(canvas)
		var label = Label.new();label.position=Vector2(22,205)
		label.text = "BASELINE / NORMAL CAMERA 1.0" if mode == "baseline" else "ART COMPOSITION STUDY / NOT INTEGRATED / CAMERA 1.0"
		label.add_theme_color_override("font_color",Color("fff0cb"));label.add_theme_color_override("font_outline_color",Color("111c29"));label.add_theme_constant_override("outline_size",6)
		canvas.add_child(label)
		for index in [14,15]:
			w.build_room(index);w.player.position=Vector2(1300 if index==14 else 1100,900)
			w.camera.zoom=Vector2.ONE;w.camera.reset_smoothing();w.player.animate(0)
			for enemy in w.enemies: enemy.set_physics_process(false)
			for frame in 4: await process_frame
			RenderingServer.force_draw(false)
			root.get_texture().get_image().save_png(output.path_join(mode+"_R%d.png"%index))
		w.queue_free();current_scene=null;await process_frame
	print("ART REVIEW CAPTURE: completed two SVG raster previews and four native-camera captures; no performance claim.")
	quit()
