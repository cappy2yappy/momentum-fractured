extends Control
var world
var map_open = false
var pause_open = false
var font = ThemeDB.fallback_font
var touches: Dictionary = {}
var touch_buttons = {"left": Rect2(22, 602, 86, 86), "right": Rect2(118, 602, 86, 86), "dash": Rect2(900, 604, 90, 90), "tether": Rect2(908, 505, 80, 80), "attack": Rect2(1002, 604, 90, 90), "parry": Rect2(1012, 505, 80, 80), "jump": Rect2(1150, 588, 106, 106), "interact": Rect2(1160, 478, 80, 80)}
var show_touch = false
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	show_touch = DisplayServer.is_touchscreen_available() or "--touch" in OS.get_cmdline_user_args()
func _process(_dt): queue_redraw()
func toggle_map():
	map_open = not map_open
	pause_open = false
	get_tree().paused = map_open
	clear_touches()
func toggle_pause():
	pause_open = not pause_open
	map_open = false
	get_tree().paused = pause_open
	clear_touches()
func clear_touches():
	touches.clear()
	world.player.touch.clear()
func _notification(what):
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_instance_valid(world):
		clear_touches()
		pause_open = true
		get_tree().paused = true
func _input(event):
	if event.is_action_pressed("map"): toggle_map();get_viewport().set_input_as_handled()
	if event.is_action_pressed("pause"): toggle_pause();get_viewport().set_input_as_handled()
	if event is InputEventScreenTouch:
		show_touch = true
		if event.pressed:
			if Rect2(1090, 20, 160, 116).has_point(event.position): toggle_map();return
			if Rect2(982, 20, 92, 52).has_point(event.position): toggle_pause();return
			if map_open or pause_open:
				if pause_open: toggle_pause()
				else: toggle_map()
				return
			for action in touch_buttons:
				if touch_buttons[action].has_point(event.position):
					touches[event.index] = action
					world.player.touch[action] = true
					if action == "interact": world.interact()
					else: world.player.press(action)
		else:
			var action = touches.get(event.index, "")
			touches.erase(event.index)
			if not action in touches.values(): world.player.touch[action] = false
		get_viewport().set_input_as_handled()
	if event is InputEventMouseButton and event.pressed:
		if Rect2(1090, 20, 160, 116).has_point(event.position): toggle_map();get_viewport().set_input_as_handled()
		elif Rect2(982, 20, 92, 52).has_point(event.position): toggle_pause();get_viewport().set_input_as_handled()
func label(at, text, size = 20, color = Color("f1e4d1")):
	draw_string(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
func _draw():
	if not is_instance_valid(world.player): return
	draw_rect(Rect2(20, 20, 350, 108), Color(0.06, 0.055, 0.09, 0.9))
	label(Vector2(38, 47), "KAZE   /   CANAL ROUTE", 20)
	for i in 3: draw_circle(Vector2(48 + i * 28, 74), 8, Color("b9d48d") if i < world.player.hp else Color("4e3b50"))
	var ability_text = "Find Windstep →"
	if world.player.double_jump: ability_text = "Windstep"
	if world.player.tether_unlocked: ability_text += " · Tether"
	if world.player.dash_unlocked: ability_text += " · Gale Dash"
	label(Vector2(38, 112), ability_text, 16)
	if world.player.kunai_unlocked.values().has(true):
		var element = world.player.selected_kunai.to_upper()
		label(Vector2(390, 112), element + " KUNAI  ·  R throw / T cycle", 15, {"WIND": Color("9de5ad"), "FIRE": Color("ff9a70"), "ELECTRIC": Color("76d9ff")}[element])
	label(Vector2(390, 45), world.ROOM_NAMES[world.room], 22)
	if is_instance_valid(world.active_enemy):
		label(Vector2(470, 78), world.active_enemy.display_name, 16, Color("efcf9f"))
	draw_rect(Rect2(982, 20, 92, 52), Color(0.06, 0.055, 0.09, 0.9))
	label(Vector2(992, 52), "PAUSE", 17)
	draw_rect(Rect2(1090, 20, 160, 116), Color(0.06, 0.055, 0.09, 0.9))
	draw_map(Vector2(1104, 42), Vector2(20, 14), false)
	label(Vector2(1102, 123), "MAP  ·  M", 15)
	if world.message_time > 0:
		draw_rect(Rect2(28, 148, 1224, 52), Color(0.06, 0.055, 0.09, 0.88))
		label(Vector2(44, 181), world.message, 18)
	if not show_touch:
		label(Vector2(28, 696), "A/D move · Space jump · Q tether · Shift dash · R kunai · T element · J attack · F parry · E use · M map", 15)
	else:
		for action in touch_buttons:
			var rect = touch_buttons[action]
			draw_rect(rect, Color(0.12, 0.1, 0.16, 0.8))
			draw_rect(rect, Color("968a9e"), false, 2)
			label(rect.position + Vector2(8, rect.size.y / 2 + 5), {"left": "←", "right": "→", "jump": "JUMP", "attack": "HIT", "parry": "PARRY", "interact": "USE", "tether": "Q", "dash": "DASH"}[action], 16)
	if map_open or pause_open:
		draw_rect(Rect2(0, 0, 1280, 720), Color(0.035, 0.03, 0.055, 0.96))
		label(Vector2(80, 92), "SILENT DISTRICT ATLAS" if map_open else "TAKE A BREATH", 42)
		if map_open:
			label(Vector2(82, 126), "MetSys survey · rooms reveal as Kaze explores", 17, Color("9ca9b7"))
			draw_rect(Rect2(70, 145, 820, 415), Color(0.055, 0.055, 0.085, 0.92))
			draw_rect(Rect2(920, 145, 290, 415), Color(0.055, 0.055, 0.085, 0.92))
			draw_map(Vector2(120, 185), Vector2(112, 72), true)
			var explored = world.explored_room_count()
			label(Vector2(945, 184), "DISTRICT SURVEY", 18, Color("c9f29d"))
			label(Vector2(945, 220), "%d / %d rooms explored" % [explored, world.ROOM_COUNT], 18)
			draw_rect(Rect2(945, 238, 235, 10), Color("242331"))
			draw_rect(Rect2(945, 238, 235 * float(explored) / world.ROOM_COUNT, 10), Color("9bcf8b"))
			label(Vector2(945, 290), "CURRENT LOCATION", 14, Color("82909e"))
			label(Vector2(945, 320), world.ROOM_NAMES[world.room], 18)
			label(Vector2(945, 345), world.room_region(world.room), 14, Color("bda9c7"))
			label(Vector2(945, 386), "OBJECTIVE", 14, Color("82909e"))
			draw_multiline_string(font, Vector2(945, 414), world.current_objective(), HORIZONTAL_ALIGNMENT_LEFT, 235, 17, 18, Color("f1e4d1"))
			label(Vector2(945, 494), "● Kaze   ◇ mapped   ■ explored", 14, Color("aeb7c1"))
			label(Vector2(945, 524), "MetSys world state: ONLINE", 14, Color("9bcf8b"))
			label(Vector2(92, 598), "ABILITIES", 14, Color("82909e"))
			label(Vector2(92, 628), ("✓" if world.player.double_jump else "○") + " Windstep", 17)
			label(Vector2(270, 628), ("✓" if world.player.tether_unlocked else "○") + " Wind Tether", 17)
			label(Vector2(480, 628), ("✓" if world.player.dash_unlocked else "○") + " Gale Dash", 17)
			label(Vector2(690, 628), ("✓" if world.boss_defeated else "○") + " Tide Warden", 17)
			label(Vector2(92, 660), "KUNAI: " + (" / ".join(world.player.kunai_unlocked.keys().filter( func(key): return world.player.kunai_unlocked[key])) if world.player.kunai_unlocked.values().has(true) else "none"), 15, Color("a9d9c2"))
		else:
			label(Vector2(100, 250), "Double-tap a direction to run. Space to jump.", 25)
			label(Vector2(100, 305), "Click during recovery to queue the next combo hit.", 25)
			label(Vector2(100, 360), "Parry as the amber warning ends, then counterattack.", 25)
			label(Vector2(100, 415), "Use Q at green anchors. Shift activates Gale Dash.", 25)
		label(Vector2(80, 682), "Esc / M to return · On touch: tap to close", 18)
	if world.transition > 0:
		var alpha = 1.0 - absf(world.transition - 0.325) / 0.325
		draw_rect(Rect2(0, 0, 1280, 720), Color(0.015, 0.01, 0.025, alpha))
		draw_rect(Rect2(596, 240, 88, 180), Color(1, 0.96, 0.87, alpha), false, 5)
func map_room_rect(origin: Vector2, cell_size: Vector2, index: int, show_labels: bool) -> Rect2:
	var coords: Vector3i = world.ROOM_MAP_COORDS[index]
	var gap = Vector2(12, 12) if show_labels else Vector2(3, 3)
	return Rect2(origin + Vector2(coords.x, coords.y) * (cell_size + gap), cell_size)

func draw_map(origin: Vector2, cell_size: Vector2, show_labels: bool):
	for index in range(1, world.ROOM_COUNT):
		var previous_level = world.room_discovery_level(index - 1)
		var level = world.room_discovery_level(index)
		if previous_level == 0 or level == 0: continue
		var from = map_room_rect(origin, cell_size, index - 1, show_labels).get_center()
		var to = map_room_rect(origin, cell_size, index, show_labels).get_center()
		var gate = world.gate_label(index)
		draw_line(from, to, Color("7fbc8a") if gate == "OPEN" else Color("b88b66"), 5 if show_labels else 2)
		if show_labels and gate != "OPEN":
			var midpoint = from.lerp(to, 0.5)
			draw_rect(Rect2(midpoint - Vector2(38, 10), Vector2(76, 20)), Color("352a36"))
			draw_string(font, midpoint + Vector2(-36, 5), gate, HORIZONTAL_ALIGNMENT_CENTER, 72, 10, Color("edc699"))
	for index in world.ROOM_COUNT:
		var level = world.room_discovery_level(index)
		if level == 0: continue
		var rect = map_room_rect(origin, cell_size, index, show_labels)
		var fill = Color("252531") if level == 1 else world.ROOM_COLORS[index].lightened(0.18)
		draw_rect(rect, fill)
		draw_rect(rect, Color("68717c") if level == 1 else Color("aaa18b"), false, 2)
		if level == 1 and show_labels:
			draw_string(font, rect.position + Vector2(0, rect.size.y / 2 + 5), "MAPPED", HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 12, Color("7f8994"))
		elif show_labels:
			draw_string(font, rect.position + Vector2(4, 19), "%02d  %s" % [index + 1, world.room_region(index)], HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 8, 10, Color("9ca9b7"))
			draw_string(font, rect.position + Vector2(4, 48), world.ROOM_NAMES[index], HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 8, 12, Color("f1e4d1"))
		if index == world.room:
			var pulse = 2.0 + sin(Time.get_ticks_msec() * 0.008) * 1.5
			draw_rect(rect.grow(pulse), Color("c6f195"), false, 3)
			draw_circle(rect.get_center(), 5 if show_labels else 3, Color("d8ffad"))
		if show_labels:
			if index == 0 or index == 3: draw_circle(rect.position + Vector2(rect.size.x - 12, 12), 5, Color("c8d69f"))
			if index == 6 and not world.boss_defeated: draw_circle(rect.position + Vector2(rect.size.x - 12, 12), 6, Color("df8c83"))
			if index == 7: draw_rect(Rect2(rect.position + Vector2(rect.size.x - 17, 7), Vector2(10, 10)), Color("9bc5a0"), false, 2)
