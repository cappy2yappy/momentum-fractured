extends Control
var world
var map_open = false
var pause_open = false
var loadout_open = false
var font = ThemeDB.fallback_font
var touches: Dictionary = {}
var touch_buttons = {"left": Rect2(22, 602, 86, 86), "right": Rect2(118, 602, 86, 86), "dash": Rect2(900, 604, 90, 90), "tether": Rect2(908, 505, 80, 80), "attack": Rect2(1002, 604, 90, 90), "parry": Rect2(1012, 505, 80, 80), "jump": Rect2(1150, 588, 106, 106), "interact": Rect2(1160, 478, 80, 80), "kunai": Rect2(805, 604, 80, 90), "cycle_kunai": Rect2(805, 505, 80, 80)}
var show_touch = false
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	show_touch = DisplayServer.is_touchscreen_available() or "--touch" in OS.get_cmdline_user_args()
func _process(_dt): queue_redraw()
func toggle_map():
	map_open = not map_open
	pause_open = false
	loadout_open = false
	get_tree().paused = map_open
	clear_touches()
func toggle_pause():
	pause_open = not pause_open
	map_open = false
	loadout_open = false
	get_tree().paused = pause_open
	clear_touches()
func toggle_loadout():
	loadout_open = not loadout_open
	map_open = false
	pause_open = false
	get_tree().paused = loadout_open
	clear_touches()

func manual_save():
	if world.save_progress():
		world.announce("Journey saved at the current shrine.", 3)

func clear_touches():
	touches.clear()
	world.player.touch.clear()
func _notification(what):
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_instance_valid(world):
		clear_touches()
		pause_open = true
		map_open = false
		loadout_open = false
		get_tree().paused = true
func _input(event):
	if event is InputEventKey and event.echo: return
	if event.is_action_pressed("loadout"):
		toggle_loadout();get_viewport().set_input_as_handled()
	if loadout_open and event.is_action_pressed("cycle_kunai"):
		world.player.cycle_kunai();world.save_progress();get_viewport().set_input_as_handled()
	if event.is_action_pressed("map"): toggle_map();get_viewport().set_input_as_handled()
	if event.is_action_pressed("pause"): toggle_pause();get_viewport().set_input_as_handled()
	if event is InputEventScreenTouch:
		show_touch = true
		if event.pressed:
			if Rect2(890, 20, 80, 52).has_point(event.position): toggle_loadout();return
			if pause_open and Rect2(100, 480, 240, 50).has_point(event.position): manual_save();return
			if loadout_open: select_loadout_at(event.position);return
			if Rect2(1090, 20, 160, 116).has_point(event.position): toggle_map();return
			if Rect2(982, 20, 92, 52).has_point(event.position): toggle_pause();return
			if map_open or pause_open or loadout_open:
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
		if Rect2(890, 20, 80, 52).has_point(event.position):
			toggle_loadout();get_viewport().set_input_as_handled();return
		if pause_open and Rect2(100, 480, 240, 50).has_point(event.position):
			manual_save();get_viewport().set_input_as_handled();return
		if loadout_open:
			select_loadout_at(event.position);get_viewport().set_input_as_handled();return
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
	draw_rect(Rect2(890, 20, 80, 52), Color(0.06, 0.055, 0.09, 0.9))
	label(Vector2(900, 52), "KIT · I", 17)
	if is_instance_valid(world.active_enemy):
		label(Vector2(470, 78), world.active_enemy.display_name, 16, Color("efcf9f"))
	draw_rect(Rect2(982, 20, 92, 52), Color(0.06, 0.055, 0.09, 0.9))
	label(Vector2(992, 52), "PAUSE", 17)
	draw_rect(Rect2(1090, 20, 160, 116), Color(0.06, 0.055, 0.09, 0.9))
	draw_map(Vector2(1104, 42), Vector2(14, 14), false)
	label(Vector2(1102, 123), "MAP  ·  M", 15)
	if world.message_time > 0:
		draw_rect(Rect2(28, 148, 1224, 52), Color(0.06, 0.055, 0.09, 0.88))
		label(Vector2(44, 181), world.message, 18)
	if not show_touch:
		label(Vector2(28, 696), "A/D move · Space jump · Q tether · Shift dash · R kunai · T element · J attack · F parry · E use · M map · I kit", 14)
	else:
		for action in touch_buttons:
			var rect = touch_buttons[action]
			draw_rect(rect, Color(0.12, 0.1, 0.16, 0.8))
			draw_rect(rect, Color("968a9e"), false, 2)
			label(rect.position + Vector2(8, rect.size.y / 2 + 5), {"left": "←", "right": "→", "jump": "JUMP", "attack": "HIT", "parry": "PARRY", "interact": "USE", "tether": "Q", "dash": "DASH", "kunai": "KUNAI", "cycle_kunai": "CYCLE"}[action], 16)
	if map_open or pause_open or loadout_open:
		draw_rect(Rect2(0, 0, 1280, 720), Color(0.035, 0.03, 0.055, 0.96))
		label(Vector2(80, 92), "KAZE • TRAVEL KIT" if loadout_open else ("SILENT DISTRICT ATLAS" if map_open else "TAKE A BREATH"), 42)
		if loadout_open:
			draw_loadout()
		elif map_open:
			label(Vector2(82, 126), "MetSys survey · rooms reveal as Kaze explores", 17, Color("9ca9b7"))
			draw_rect(Rect2(70, 145, 820, 415), Color(0.055, 0.055, 0.085, 0.92))
			draw_rect(Rect2(920, 145, 290, 415), Color(0.055, 0.055, 0.085, 0.92))
			draw_map(Vector2(92, 185), Vector2(84, 72), true)
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
			draw_rect(Rect2(100, 480, 240, 50), Color("26312d"))
			label(Vector2(125, 512), "SAVE JOURNEY", 20)
			label(Vector2(100, 580), "I opens your kit. Earned abilities and exploration are saved.", 20)
		label(Vector2(80, 682), "Esc / M / I · On touch: tap to close", 18)
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
	draw_return_link(origin, cell_size, show_labels)
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
			draw_string(font, rect.position + Vector2(4, 19), "%02d  %s" % [index + 1, world.room_region(index)], HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 8, 9, Color("9ca9b7"))
			draw_multiline_string(font, rect.position + Vector2(4, 38), world.ROOM_NAMES[index], HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 8, 11, 2, Color("f1e4d1"))
		if index == world.room:
			var pulse = 2.0 + sin(Time.get_ticks_msec() * 0.008) * 1.5
			draw_rect(rect.grow(pulse), Color("c6f195"), false, 3)
			draw_circle(rect.get_center(), 5 if show_labels else 3, Color("d8ffad"))
		if show_labels:
			if index == 0 or index == 3: draw_circle(rect.position + Vector2(rect.size.x - 12, 12), 5, Color("c8d69f"))
			if index == 6 and not world.boss_defeated: draw_circle(rect.position + Vector2(rect.size.x - 12, 12), 6, Color("df8c83"))
			if index == 7: draw_rect(Rect2(rect.position + Vector2(rect.size.x - 17, 7), Vector2(10, 10)), Color("9bc5a0"), false, 2)
	if show_labels:
		for index in range(1, world.ROOM_COUNT):
			var gate = world.gate_label(index)
			if gate == "OPEN" or world.room_discovery_level(index-1) == 0 or world.room_discovery_level(index) == 0: continue
			var start = map_room_rect(origin,cell_size,index-1,show_labels).get_center()
			var finish = map_room_rect(origin,cell_size,index,show_labels).get_center()
			var midpoint = start.lerp(finish,0.5)
			if is_equal_approx(start.y,finish.y):
				draw_rect(Rect2(midpoint-Vector2(6,7),Vector2(12,14)),Color("352a36"))
				draw_string(font,midpoint+Vector2(-4,3),gate.left(1),HORIZONTAL_ALIGNMENT_LEFT,-1,8,Color("edc699"))
			else:
				draw_rect(Rect2(midpoint-Vector2(38,6),Vector2(76,12)),Color("352a36"))
				draw_string(font,midpoint+Vector2(-38,3),gate,HORIZONTAL_ALIGNMENT_CENTER,76,8,Color("edc699"))


func select_loadout_at(at: Vector2):
	for index in 3:
		var element = ["wind", "fire", "electric"][index]
		if Rect2(490 + index * 230, 385, 205, 110).has_point(at) and world.player.kunai_unlocked.get(element, false):
			world.player.selected_kunai = element
			world.save_progress()
			return
	if at.y > 650: toggle_loadout()

func draw_loadout():
	draw_rect(Rect2(70, 150, 320, 470), Color("191824"))
	var texture = world.player.clips["idle"]
	var portrait_region = Rect2(0, 223, texture.get_width() / 8.0, 368)
	var portrait_size = portrait_region.size * (250.0 / portrait_region.size.y)
	draw_texture_rect_region(texture, Rect2(Vector2(230 - portrait_size.x / 2.0, 185), portrait_size), portrait_region)
	label(Vector2(118, 494), "KAZE / SILENT DISTRICT", 20)
	label(Vector2(118, 535), "Health  %d / 3" % world.player.hp, 20)
	label(Vector2(118, 575), "Relay sigils  %d / 3" % world.relay_fragments.size(), 18, Color("c9f29d"))
	var abilities = [["WINDSTEP", world.player.double_jump, "Double jump"], ["WIND TETHER", world.player.tether_unlocked, "Hold Q; pump and release"], ["GALE DASH", world.player.dash_unlocked, "Shift; burst through danger"]]
	for index in 3:
		var ability = abilities[index]
		draw_rect(Rect2(470, 150 + index * 68, 720, 58), Color("242331"))
		label(Vector2(490, 181 + index * 68), ability[0], 20, Color("c9f29d") if ability[1] else Color("7f8994"))
		label(Vector2(740, 181 + index * 68), ability[2] if ability[1] else "LOCKED • continue the route", 17)
	label(Vector2(490, 373), "KUNAI • CLICK A SLOT OR PRESS T TO CYCLE", 17)
	for index in 3:
		var element = ["wind", "fire", "electric"][index]
		var unlocked = world.player.kunai_unlocked.get(element, false)
		var rect = Rect2(490 + index * 230, 385, 205, 110)
		draw_rect(rect, Color("242331"))
		draw_rect(rect, Color("c9f29d") if world.player.selected_kunai == element and unlocked else Color("68717c"), false, 2)
		label(rect.position + Vector2(15, 37), element.to_upper(), 21)
		label(rect.position + Vector2(15, 79), "EQUIPPED" if unlocked and world.player.selected_kunai == element else ("AVAILABLE" if unlocked else "LOCKED"), 15)
	label(Vector2(490, 545), "Explore annexes to restore the optional relay circuit.", 19)
	label(Vector2(490, 585), world.current_objective(), 16)
	label(Vector2(490, 620), "KEEPER RELAY • " + ("ATTUNED" if world.skyworks_restored else "UNRESTORED"), 17, Color("c9f29d") if world.skyworks_restored else Color("82909e"))

func draw_return_link(origin: Vector2, cell_size: Vector2, show_labels: bool):
	draw_keeper_return(origin, cell_size, show_labels)
	if world.room_discovery_level(3) == 0 or world.room_discovery_level(9) == 0: return
	var start = map_room_rect(origin, cell_size, 3, show_labels).get_center()
	var finish = map_room_rect(origin, cell_size, 9, show_labels).get_center()
	var top = origin.y - (20 if show_labels else 6)
	var outer_x = map_room_rect(origin, cell_size, 9, show_labels).end.x + (6 if show_labels else 1)
	var opened = world.opened_kunai_gates.get("terrace_return_relay", false)
	var color = Color("9bcf8b") if opened else Color("76d9ff")
	draw_polyline(PackedVector2Array([start, Vector2(start.x, top), Vector2(outer_x, top), Vector2(outer_x, finish.y), finish]), color, 3 if show_labels else 1)
	if show_labels:
		label(Vector2(start.x + 30, top - 5), "RETURN OPEN" if opened else "ELECTRIC RETURN", 12, color)


func draw_keeper_return(origin: Vector2, cell_size: Vector2, show_labels: bool):
	if world.room_discovery_level(8) == 0 or world.room_discovery_level(12) == 0: return
	var start = map_room_rect(origin, cell_size, 8, show_labels).get_center()
	var finish = map_room_rect(origin, cell_size, 12, show_labels).get_center()
	var bottom = start.y + cell_size.y / 2.0 + (32 if show_labels else 8)
	var color = Color("9bcf8b") if world.skyworks_restored else Color("d7b477")
	draw_polyline(PackedVector2Array([start, Vector2(start.x, bottom), Vector2(finish.x, bottom), finish]), color, 3 if show_labels else 1)
	if show_labels:
		label(Vector2(start.x + 10, bottom + 17), "KEEPER RETURN " + ("OPEN" if world.skyworks_restored else "LOCKED"), 10, color)
