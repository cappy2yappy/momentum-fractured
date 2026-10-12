extends SceneTree

var failures := 0

func _init() -> void:
	call_deferred("_run")

func check(condition: bool, message: String) -> void:
	print("PASS: " if condition else "FAIL: ", message)
	if not condition:
		failures += 1

func assert_overlay(hud: Node, expected: String, message: String) -> void:
	check(hud.active_overlay == expected and paused == not expected.is_empty(), message + " pause ownership")
	check(hud.get_node("MapOverlay").visible == (expected == "map") and hud.get_node("CharacterPanel").visible == (expected == "loadout") and hud.get_node("PauseMenu").visible == (expected == "pause"), message + " exclusive visibility")

func _run() -> void:
	var hud = load("res://scenes/ui/hud.tscn").instantiate()
	root.add_child(hud)
	hud.set_process(false)
	var menu = hud.get_node("PauseMenu")
	var escape := InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	escape.pressed = true
	assert_overlay(hud, "", "Initial state")
	hud.toggle_overlay("map")
	assert_overlay(hud, "map", "Map opens")
	menu._input(escape)
	assert_overlay(hud, "pause", "Escape replaces map")
	menu._input(escape)
	assert_overlay(hud, "", "Second Escape closes pause")
	menu.open_menu()
	hud.toggle_overlay("map")
	assert_overlay(hud, "map", "Map replaces pause")
	hud.toggle_overlay("map")
	assert_overlay(hud, "", "Map closes without stale pause")
	hud.toggle_overlay("loadout")
	hud.toggle_overlay("map")
	assert_overlay(hud, "map", "Map replaces loadout")
	hud.toggle_overlay("loadout")
	assert_overlay(hud, "loadout", "Loadout replaces map")
	menu._input(escape)
	assert_overlay(hud, "pause", "Escape replaces loadout")
	menu.close_menu()
	assert_overlay(hud, "", "Resume closes all overlays")
	hud.toggle_overlay("loadout")
	menu.close_menu()
	assert_overlay(hud, "", "New game close operation clears any overlay")
	hud.queue_free()
	await process_frame
	print("PAUSE OVERLAY REGRESSION: %d failure(s)" % failures)
	quit(1 if failures else 0)
