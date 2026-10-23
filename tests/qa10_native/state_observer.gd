extends Node
## Read-only observation. Never changes input, pause, processing, or gameplay state.
var harness
var frame := 0
var last_state := ""
var keys_seen := 0
var last_sample_usec := 0

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event):
	if event is InputEventKey:
		keys_seen += 1

func _notification(what):
	if what in [NOTIFICATION_APPLICATION_FOCUS_IN, NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_WM_WINDOW_FOCUS_IN, NOTIFICATION_WM_WINDOW_FOCUS_OUT]:
		print("QA10_EVENT ", JSON.stringify({"notification": what, "frame": frame}))

func _process(_dt):
	frame += 1
	if not is_instance_valid(harness.w): return
	var w = harness.w
	if not is_instance_valid(w.player) or not is_instance_valid(w.hud): return
	var p = w.player
	var c = w.cinematic_transitions
	var state = "%s|%s|%s|%s|%s|%s|%s|%s" % [get_tree().paused, get_window().has_focus(), w.hud.pause_open, w.hud.map_open, p.can_process(), p.is_physics_processing(), w.room, c.tr08.phase()]
	var now = Time.get_ticks_usec()
	if state == last_state and now - last_sample_usec < 250000: return
	last_state = state
	last_sample_usec = now
	print("QA10_STATE ", JSON.stringify({
		"frame": frame, "physics_frame": Engine.get_physics_frames(),
		"drawn_frames": Engine.get_frames_drawn(), "render_loop_enabled": RenderingServer.render_loop_enabled,
		"window_mode": get_window().mode, "window_visible": get_window().visible,
		"world_id": w.get_instance_id(), "room": w.room,
		"position": [p.position.x, p.position.y], "velocity": [p.velocity.x, p.velocity.y],
		"floor": p.is_on_floor(), "player_age": p.age,
		"paused": get_tree().paused, "window_focus": get_window().has_focus(),
		"hud_pause": w.hud.pause_open, "hud_map": w.hud.map_open, "hud_loadout": w.hud.loadout_open,
		"hud_script": w.hud.get_script().resource_path,
		"world_can_process": w.can_process(), "player_can_process": p.can_process(),
		"world_physics": w.is_physics_processing(), "player_physics": p.is_physics_processing(),
		"player_process_mode": p.process_mode, "world_process_mode": w.process_mode,
		"physical_a": Input.is_physical_key_pressed(KEY_A), "physical_d": Input.is_physical_key_pressed(KEY_D),
		"action_left": Input.is_action_pressed("left"), "action_right": Input.is_action_pressed("right"),
		"held_left": p.held("left"), "held_right": p.held("right"), "key_events_seen": keys_seen,
		"armed": c.armed, "cooldown": c.cooldown, "requests": c.request_count,
		"phase": c.tr08.phase(), "transition": w.transition, "pending_room": w.pending_room
	}))
