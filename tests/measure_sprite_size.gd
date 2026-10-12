extends SceneTree
func _init():
	for prefix in ["res://assets/web/", "res://assets/kaze/cleaned/"]:
		for clip in ["idle", "run", "combat", "traversal"]:
			var image = Image.load_from_file(prefix + "kaze_" + clip + "_strip.png")
			var heights = []
			var widths = []
			for frame in 8:
				var cell = image.get_region(Rect2i(frame * image.get_width() / 8, 0, image.get_width() / 8, image.get_height()))
				var low = Vector2i(cell.get_width(), cell.get_height())
				var high = Vector2i.ZERO
				for y in cell.get_height():
					for x in cell.get_width():
						if cell.get_pixel(x,y).a > 0.1:
							low = Vector2i(mini(low.x,x),mini(low.y,y))
							high = Vector2i(maxi(high.x,x+1),maxi(high.y,y+1))
				var bounds = Rect2i(low, high-low)
				heights.append(bounds.size.y)
				widths.append(bounds.size.x)
			print(prefix, clip, " canvas=", image.get_height(), " visible heights=", heights, " widths=", widths)
	quit()
