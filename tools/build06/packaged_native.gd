extends "res://tests/native_cinematic_transitions.gd"
func _init():
	output=OS.get_environment("BUILD06_CAPTURE_DIR")
	if not ProjectSettings.load_resource_pack(OS.get_environment("BUILD06_PACK"),true):
		push_error("BUILD06: cannot mount exact exported pack");quit(1);return
	call_deferred("run")
func shot(name):
	if OS.get_environment("BUILD06_GRAPHICAL")=="1":
		await super.shot(name)
	else:
		await process_frame
