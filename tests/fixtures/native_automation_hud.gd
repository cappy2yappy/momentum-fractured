extends RefCounted
## Test-only HUD built from the current production source. Godot calls every
## inherited _notification; overriding it cannot suppress the base focus pause.
## Rename only that callback, preserving its exact body for deliberate focus tests.
static func install(world):
	var source = FileAccess.get_file_as_string("res://scripts/hud.gd")
	assert(source.count("func _notification(what):") == 1, "HUD notification signature changed; review the automation fixture")
	var script = GDScript.new()
	script.source_code = source.replace("func _notification(what):", "func simulated_notification(what):")
	assert(script.reload() == OK, "Automation HUD must compile")
	world.hud.set_script(script)
	world.hud.world = world
	world.hud._ready()
	# New world construction is the only reset boundary. Never unpause in a tick,
	# input helper, or assertion: intentional pause/map/focus tests retain authority.
	if world.get_tree().paused:
		print("HARNESS: clearing inherited pause at new-world boundary")
	world.get_tree().paused = false
