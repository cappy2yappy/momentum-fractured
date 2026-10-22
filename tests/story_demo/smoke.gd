extends SceneTree
var failures = 0
func _init(): call_deferred("run")
func check(value, label):
	print(("PASS " if value else "FAIL ") + label)
	if not value: failures += 1
func run():
	var w = load("res://tests/story_demo/demo.tscn").instantiate()
	root.add_child(w)
	current_scene = w
	w.set_physics_process(false)
	w.player.set_physics_process(false)
	check(w.story.objects.size() == 4, "four definitions")
	w.player.position = Vector2(700,1300)
	check(w.story.interact(w), "read opens")
	check(paused, "inspection suspends gameplay")
	w.story.panel.advance()
	check(w.story.panel.page == 1, "multiple pages")
	w.story.panel.close()
	check(not paused and w.hud.is_processing_input(), "input restored")
	check(w.story.interact(w), "repeat inspection")
	w.story.panel.close()
	w.player.position = Vector2(1420,1300)
	check(w.story.interact(w), "activate opens")
	check(w.story.has("trap/int01_power"), "activation flag")
	w.story.panel.close()
	check(not w.story.interact(w), "once only")
	w.build_room(0)
	check(w.story.has("trap/int01_power"), "reentry preserves state")
	w.player.position = Vector2(220,1300)
	check(not w.story.interact(w), "checkpoint yields to legacy")
	w.queue_free()
	await process_frame
	quit(failures)
