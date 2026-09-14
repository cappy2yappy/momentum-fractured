extends Control
var world
var map_open = false
var pause_open = false
var font = ThemeDB.fallback_font
var touches: Dictionary = {}
var touch_buttons = {"left":Rect2(22,602,86,86),"right":Rect2(118,602,86,86),"jump":Rect2(1150,588,106,106),"attack":Rect2(1038,604,90,90),"parry":Rect2(1048,495,80,80),"interact":Rect2(1160,478,80,80)}
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
	if event.is_action_pressed("map"): toggle_map(); get_viewport().set_input_as_handled()
	if event.is_action_pressed("pause"): toggle_pause(); get_viewport().set_input_as_handled()
	if event is InputEventScreenTouch:
		show_touch = true
		if event.pressed:
			if Rect2(1090,20,160,116).has_point(event.position): toggle_map(); return
			if Rect2(982,20,92,52).has_point(event.position): toggle_pause(); return
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
			var action = touches.get(event.index,"")
			touches.erase(event.index)
			if not action in touches.values(): world.player.touch[action] = false
		get_viewport().set_input_as_handled()
	if event is InputEventMouseButton and event.pressed:
		if Rect2(1090,20,160,116).has_point(event.position): toggle_map(); get_viewport().set_input_as_handled()
		elif Rect2(982,20,92,52).has_point(event.position): toggle_pause(); get_viewport().set_input_as_handled()
func label(at,text,size=20,color=Color("f1e4d1")):
	draw_string(font,at,text,HORIZONTAL_ALIGNMENT_LEFT,-1,size,color)
func _draw():
	if not is_instance_valid(world.player): return
	draw_rect(Rect2(20,20,350,108),Color(0.06,0.055,0.09,0.9))
	label(Vector2(38,47),"KAZE   /   CANAL ROUTE",20)
	for i in 3: draw_circle(Vector2(48+i*28,74),8,Color("b9d48d") if i < world.player.hp else Color("4e3b50"))
	label(Vector2(38,112),"Windstep · double jump" if world.player.double_jump else "Find the guard station →",16)
	label(Vector2(390,45),"CANAL SHRINE" if world.room == 0 else "GUARD STATION",22)
	draw_rect(Rect2(982,20,92,52),Color(0.06,0.055,0.09,0.9))
	label(Vector2(992,52),"PAUSE",17)
	draw_rect(Rect2(1090,20,160,116),Color(0.06,0.055,0.09,0.9))
	draw_map(Vector2(1104,42),0.025)
	label(Vector2(1102,123),"MAP  ·  M",15)
	if world.message_time > 0:
		draw_rect(Rect2(28,148,1224,52),Color(0.06,0.055,0.09,0.88))
		label(Vector2(44,181),world.message,18)
	if not show_touch:
		label(Vector2(28,696),"A/D move · double-tap run · Space jump · LMB/J attack · RMB/F parry · E interact · M map",17)
	else:
		for action in touch_buttons:
			var rect = touch_buttons[action]
			draw_rect(rect,Color(0.12,0.10,0.16,0.8))
			draw_rect(rect,Color("968a9e"),false,2)
			label(rect.position+Vector2(10,rect.size.y/2+5),{"left":"←","right":"→","jump":"JUMP","attack":"HIT","parry":"PARRY","interact":"USE"}[action],17)
	if map_open or pause_open:
		draw_rect(Rect2(0,0,1280,720),Color(0.035,0.03,0.055,0.96))
		label(Vector2(100,120),"CANAL DISTRICT" if map_open else "TAKE A BREATH",42)
		if map_open:
			draw_map(Vector2(180,220),0.16)
			label(Vector2(100,550),"● Kaze   ·   Explored rooms",20)
			label(Vector2(100,590),"Return to the rooftop relay after earning Windstep.",20)
		else:
			label(Vector2(100,250),"Double-tap a direction to run. Space to jump.",25)
			label(Vector2(100,305),"Click during recovery to queue the next combo hit.",25)
			label(Vector2(100,360),"Parry as the amber warning ends, then counterattack.",25)
			label(Vector2(100,415),"Use E at the shrine to heal and save.",25)
		label(Vector2(100,660),"Esc / M to return · On touch: tap to close",20)
	if world.transition > 0:
		var alpha = 1.0-absf(world.transition-0.325)/0.325
		draw_rect(Rect2(0,0,1280,720),Color(0.015,0.01,0.025,alpha))
		draw_rect(Rect2(596,240,88,180),Color(1,0.96,0.87,alpha),false,5)
func draw_map(origin,scale):
	for index in 2:
		if not world.visited[index]: continue
		var at = origin+Vector2(index*2700*scale,0)
		var rect = Rect2(at,Vector2(2600,1440)*scale)
		draw_rect(rect,Color("413749"))
		draw_rect(rect,Color("a899af"),false,1)
		draw_line(at+Vector2(0,1300)*scale,at+Vector2(2600,1300)*scale,Color("c4b49b"),2)
		if index == world.room:
			for platform in world.platforms:
				draw_rect(Rect2(at+platform.position*scale,platform.size*scale),Color("8a7f8c"))
			draw_circle(at+world.player.position*scale,3.5,Color("c6f195"))
