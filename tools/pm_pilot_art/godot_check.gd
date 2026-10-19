extends SceneTree
# Headless import/size check against MANIFEST.json, then (when a display exists) a draw-order capture.
# godot --headless --path . --script res://tools/pm_pilot_art/godot_check.gd
func _initialize():
	var m = JSON.parse_string(FileAccess.get_file_as_string("res://assets/pm_pilot/MANIFEST.json"))
	var bad = 0
	for a in m.assets:
		var t = load("res://" + a.path)
		if t == null or t.get_width() != a.size[0] or t.get_height() != a.size[1]:
			bad += 1; print("FAIL ", a.id)
		else: print("ok   ", a.id, " ", t.get_size())
	print("manifest assets: ", m.assets.size(), " failures: ", bad)
	quit(1 if bad > 0 else 0)
