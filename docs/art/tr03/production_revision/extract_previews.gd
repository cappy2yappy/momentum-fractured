extends SceneTree
func _initialize():
	var image = Image.load_from_file("res://docs/art/tr03/production_revision/TR03_production_triptych.png")
	var regions = [Rect2i(0,0,1672,307),Rect2i(0,322,1672,283),Rect2i(0,622,1672,319)]
	var names = ["01_doorway","02_staircase","03_supported_crossing"]
	for i in range(3):
		image.get_region(regions[i]).save_png("res://docs/art/tr03/production_revision/"+names[i]+".png")
	quit()

