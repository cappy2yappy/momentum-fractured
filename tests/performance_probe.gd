extends SceneTree

const GRAPH := preload("res://scripts/rooms/room_graph.gd")
var samples: Array[Dictionary] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("PERFORMANCE PROBE requires a rendered display")
		quit(2)
		return
	root.get_node("GameState").new_game()
	for room_id in GRAPH.ROOM_SCENES:
		change_scene_to_file(GRAPH.scene_for_room(room_id))
		await scene_changed
		var player = current_scene.get_node("Kaze")
		player.set_health_values(100000.0, 100000.0)
		for i in 40:
			await process_frame
		var times: Array[float] = []
		var last := Time.get_ticks_usec()
		for i in 180:
			if i % 60 == 0:
				Input.action_release("move_left")
				Input.action_release("move_right")
				Input.action_press("move_right" if i % 120 == 0 else "move_left")
			await process_frame
			var now := Time.get_ticks_usec()
			times.append(float(now - last) / 1000.0)
			last = now
		Input.action_release("move_left")
		Input.action_release("move_right")
		var total := 0.0
		for ms in times:
			total += ms
		times.sort()
		var result := {"room": room_id, "frames": times.size(), "average_fps": 1000.0 * times.size() / total, "p95_frame_ms": times[int(times.size() * 0.95)], "max_frame_ms": times.back()}
		samples.append(result)
		print("PERFORMANCE SAMPLE: ", JSON.stringify(result))
	var path := "res://validation/2026-10-12/rendered-performance.json"
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify({"display": DisplayServer.get_name(), "renderer": RenderingServer.get_current_rendering_method(), "resolution": root.size, "samples": samples}, "\t"))
	print("RENDERED PERFORMANCE PROBE: 12 rooms sampled; hardware-specific, short-run measurement")
	quit()
