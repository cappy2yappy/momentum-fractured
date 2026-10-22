extends SceneTree
var scene
var age=0.0
var index=0
var output=""
func _initialize():
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output="): output=arg.trim_prefix("--output=")
	call_deferred("begin")
func begin():
	var hazard = "--hazard" in OS.get_cmdline_user_args()
	scene=load("res://scenes/haz01/course.tscn" if hazard else "res://scenes/encounters/combined.tscn").instantiate()
	root.add_child(scene); current_scene=scene
	if not hazard:
		scene.camera.zoom=Vector2(0.48,0.48)
		scene.camera.position=Vector2(1300,360)-scene.player.position
	print("NATIVE SCENE READY")
func _process(delta):
	if not is_instance_valid(scene): return false
	age+=delta
	if index<3 and age>float(index+1):
		index+=1
		root.get_texture().get_image().save_png(output.path_join(("hazard_%d.png" if "--hazard" in OS.get_cmdline_user_args() else "combined_%d.png") % index))
		print("CAPTURE ",index)
	if age>3.5: quit()
	return false
