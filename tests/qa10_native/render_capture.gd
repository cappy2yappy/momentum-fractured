extends "res://tests/native_cinematic_transitions.gd"
## Positive control for an awaited post-draw signal when normal rendering stops.
func legacy_capture(state):
	await process_frame
	await RenderingServer.frame_post_draw
	state.done = true

func run():
	await process_frame
	w=load("res://scenes/main.tscn").instantiate(); root.add_child(w); current_scene=w
	automation_hud(); freeze(); seed_fixture()
	var state = {"done": false}
	var previous = RenderingServer.render_loop_enabled
	RenderingServer.render_loop_enabled = false
	var before = Engine.get_frames_drawn()
	legacy_capture(state)
	for i in 8: await process_frame
	check(not state.done and Engine.get_frames_drawn() == before, "Legacy post-draw wait remains blocked while process frames continue without drawing")
	RenderingServer.force_draw(false)
	for i in 3: await process_frame
	print("QA10_FORCED_DRAW completed=", state.done, " engine_drawn_before=", before, " engine_drawn_after=", Engine.get_frames_drawn())
	check(state.done, "Explicit main-thread draw releases the pending post-draw signal")
	var image = root.get_texture().get_image()
	check(not image.is_empty() and image.get_width() > 0 and image.get_height() > 0, "Forced native frame has readable viewport pixels")
	image.save_png("res://build/qa10_native/render_control.png")
	output="res://build/qa10_native/corrected_capture"
	DirAccess.make_dir_recursive_absolute(output)
	var position_before = w.player.position
	await shot("render_loop_disabled")
	check(FileAccess.file_exists(output+"/render_loop_disabled.png") and w.player.position == position_before, "Corrected native capture completes without regular rendering or gameplay writes")
	RenderingServer.render_loop_enabled = previous
	w.queue_free(); current_scene = null
	for i in 3: await process_frame
	print("QA10 RENDER CAPTURE: %d checks, %d failure(s)" % [checks,failures])
	quit(1 if failures else 0)
