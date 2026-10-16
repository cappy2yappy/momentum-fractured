extends "res://tests/native_cinematic_transitions.gd"
func _init():
	var pack=OS.get_environment("BUILD05_PACK")
	output=OS.get_environment("BUILD05_CAPTURE_DIR")
	if not ProjectSettings.load_resource_pack(pack,true):
		push_error("Cannot mount BUILD05 exported Mac PCK");quit(1);return
	call_deferred("run")

func shot(name):
	# Hosted macOS has no reliable foreground rendering lifecycle. Assertions
	# and key events are identical; only screenshot waits are skipped headlessly.
	if OS.get_environment("BUILD05_CAPTURE_MODE")=="headless":
		await process_frame
	else:
		await super.shot(name)
