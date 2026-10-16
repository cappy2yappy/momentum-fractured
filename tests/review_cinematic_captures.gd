extends SceneTree
func _init():
	var path="res://build/tr05/native"
	var out="res://docs/tr05/previews"
	DirAccess.make_dir_recursive_absolute(out)
	for name in ["passage_13-0_before","passage_13-0_after","passage_13-14_after","passage_14-13_after","stair_14-17_cinematic_moving","stair_14-17_cinematic_close","stair_14-17_reduced_close","stair_17-14_cinematic_close"]:
		var image=Image.load_from_file(ProjectSettings.globalize_path(path+"/"+name+".png"))
		if image==null: quit(1);return
		image.save_jpg(out+"/"+name+".jpg",0.82)
	print("Review JPGs saved from native fixture captures; not human playtest footage")
	quit()
