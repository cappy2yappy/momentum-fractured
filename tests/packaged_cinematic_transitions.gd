extends "res://tests/native_cinematic_transitions.gd"
func _init():
	var workspace=ProjectSettings.globalize_path("res://")
	var path=workspace.path_join("build/tr05/windows/Kaze-TR05-Windows.exe")
	output=workspace.path_join("build/tr05/packaged-native")
	if not ProjectSettings.load_resource_pack(path,true):
		push_error("Could not mount actual Windows exported resources");quit(1);return
	call_deferred("run")
