extends Node2D
const Player = preload("res://scripts/player.gd")
const Guard = preload("res://scripts/guard.gd")
const Hud = preload("res://scripts/hud.gd")
var save_path = "user://canal_route_recovery_v1.json"
var player
var guard
var camera = Camera2D.new()
var geometry = Node2D.new()
var room = 0
var visited = [true,false]
var guard_defeated = false
var completed = false
var secret = false
var platforms: Array[Rect2] = []
var hud
var message = "The canal is sealed. Find a route to the rooftop relay."
var message_time = 7.0
var transition = 0.0
var pending_room = -1
var test_mode = false
func _ready():
	test_mode = "--test" in OS.get_cmdline_user_args()
	configure_input()
	add_child(geometry)
	player = Player.new()
	add_child(player)
	player.strike.connect(on_strike)
	player.hurt.connect(on_hurt)
	player.add_child(camera)
	camera.position.y = -110
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 8
	camera.limit_left = 0; camera.limit_right = 2600
	camera.limit_top = 0; camera.limit_bottom = 1440
	var layer = CanvasLayer.new()
	add_child(layer)
	hud = Hud.new()
	hud.world = self
	layer.add_child(hud)
	if not test_mode: load_progress()
	build_room(0)
	player.position = Vector2(220,1298)
	camera.reset_smoothing()
func configure_input():
	var keys = {"left":[KEY_A,KEY_LEFT],"right":[KEY_D,KEY_RIGHT],"jump":[KEY_SPACE,KEY_W,KEY_UP],"attack":[KEY_J],"parry":[KEY_F,KEY_K],"interact":[KEY_E],"map":[KEY_M],"pause":[KEY_ESCAPE]}
	for action in keys:
		if not InputMap.has_action(action): InputMap.add_action(action)
		for key in keys[action]:
			var event = InputEventKey.new(); event.physical_keycode = key
			InputMap.action_add_event(action,event)
	for pair in [["attack",MOUSE_BUTTON_LEFT],["parry",MOUSE_BUTTON_RIGHT]]:
		var event = InputEventMouseButton.new(); event.button_index = pair[1]
		InputMap.action_add_event(pair[0],event)
func build_room(index):
	room = index
	visited[room] = true
	for child in geometry.get_children():
		geometry.remove_child(child); child.queue_free()
	if is_instance_valid(guard):
		remove_child(guard); guard.queue_free()
	platforms.clear()
	for rect in [Rect2(0,1300,2600,140),Rect2(-40,0,40,1440),Rect2(2600,0,40,1440)]: add_platform(rect)
	if room == 0:
		for rect in [Rect2(480,1110,300,40),Rect2(860,780,420,48),Rect2(260,780,390,48),Rect2(1400,1080,300,40),Rect2(1850,900,300,40)]: add_platform(rect)
	else:
		for rect in [Rect2(370,1120,280,40),Rect2(1800,1100,270,40),Rect2(2140,880,320,40)]: add_platform(rect)
		if not guard_defeated:
			guard = Guard.new(); guard.player = player
			guard.position = Vector2(1100,1300)
			guard.defeated.connect(func():
				guard_defeated = true
				announce("The guard falls. Claim the Windstep scroll.",5)
			)
			add_child(guard)
	queue_redraw()
func add_platform(rect: Rect2):
	platforms.append(rect)
	var body = StaticBody2D.new()
	var shape = CollisionShape2D.new()
	var box = RectangleShape2D.new(); box.size = rect.size
	shape.shape = box; shape.position = rect.get_center()
	body.add_child(shape); geometry.add_child(body)
func announce(text,seconds=4.0):
	message = text; message_time = seconds
func on_strike(damage,reach):
	if not is_instance_valid(guard) or guard.hp <= 0: return
	var d = guard.position-player.position
	if absf(d.x) <= reach and absf(d.y) < 85 and d.x*player.facing > -15:
		guard.receive_hit(damage)
		player.hitstop = 0.055 if damage == 1 else 0.085
func on_hurt():
	if player.hp <= 0:
		# Defer collision changes until the physics server finishes the current step.
		call_deferred("respawn")
func respawn():
	player.hp = 3
	build_room(0)
	player.position = Vector2(220,1298)
	player.velocity = Vector2.ZERO
	player.attack_time = 0
	player.invulnerable = 1.5
	camera.reset_smoothing()
	announce("Back at the shrine. Your earned abilities are safe.")
func request_room(target):
	if transition > 0: return
	pending_room = target; transition = 0.65
	player.set_physics_process(false)
	hud.clear_touches()
func interact():
	if transition > 0: return
	if room == 0 and player.position.distance_to(Vector2(220,1300)) < 95:
		player.hp = 3; save_progress(); announce("Shrine restored. Journey saved.")
	elif room == 0 and player.position.distance_to(Vector2(2440,1300)) < 100: request_room(1)
	elif room == 1 and player.position.distance_to(Vector2(120,1300)) < 100: request_room(0)
	elif room == 0 and player.position.distance_to(Vector2(380,780)) < 110 and player.double_jump:
		completed = true; save_progress()
		announce("Relay opened. The families below can leave the canal. Route complete.",15)
func _physics_process(dt):
	message_time = maxf(0,message_time-dt)
	if transition > 0:
		transition -= dt
		if transition < 0.32 and pending_room >= 0:
			var target = pending_room; pending_room = -1
			build_room(target)
			player.position = Vector2(230,1298) if target == 1 else Vector2(2300,1298)
			player.velocity = Vector2.ZERO
			camera.reset_smoothing()
		if transition <= 0: player.set_physics_process(true)
	if Input.is_action_just_pressed("interact"): interact()
	if room == 1 and guard_defeated and not player.double_jump and player.position.distance_to(Vector2(1580,1260)) < 85:
		player.double_jump = true
		save_progress()
		announce("WINDSTEP — Jump again in midair. Return to the shrine and reach the rooftop relay.",9)
	if room == 1 and not secret and player.position.distance_to(Vector2(2300,830)) < 75:
		secret = true; player.hp = 3; save_progress()
		announce("Hidden letter: the next convoy leaves before dawn. Health restored.",7)
	queue_redraw()
func save_progress():
	if test_mode: return
	var file = FileAccess.open(save_path,FileAccess.WRITE)
	if file == null:
		announce("Could not save. Your current session can continue."); return
	file.store_string(JSON.stringify({"version":1,"double_jump":player.double_jump,"guard_defeated":guard_defeated,"completed":completed,"secret":secret,"visited":visited}))
func load_progress():
	if not FileAccess.file_exists(save_path): return
	var data = JSON.parse_string(FileAccess.get_file_as_string(save_path))
	if not data is Dictionary or data.get("version") != 1: return
	player.double_jump = data.get("double_jump",false)
	guard_defeated = data.get("guard_defeated",false)
	completed = data.get("completed",false)
	secret = data.get("secret",false)
	var saved_visited = data.get("visited",[true,false])
	if saved_visited is Array and saved_visited.size() == 2: visited = saved_visited
func _draw():
	if not is_instance_valid(player): return
	# Recovery scenery: legible blockout pending restoration of painted district art.
	draw_rect(Rect2(0,0,2600,1440),Color("211e32") if room == 0 else Color("1c2430"))
	for i in 15:
		var x = i*200
		var top = 500+(i%4)*65
		draw_rect(Rect2(x,top,140,1300-top),Color("302b40"))
		for y in range(top+25,1250,95):
			draw_rect(Rect2(x+24,y,22,30),Color("74604c"))
			draw_rect(Rect2(x+86,y,22,30),Color("514753"))
	for rect in platforms:
		if rect.position.x < 0 or rect.position.x >= 2600: continue
		draw_rect(rect,Color("252631"))
		draw_rect(Rect2(rect.position,Vector2(rect.size.x,7)),Color("aaa18b"))
		draw_rect(Rect2(rect.position+Vector2(0,7),Vector2(rect.size.x,9)),Color("54535c"))
	if room == 0:
		draw_rect(Rect2(190,1256,60,44),Color("63516e"))
		draw_circle(Vector2(220,1237),18,Color("c8d69f"))
		draw_door(Vector2(2440,1300))
		draw_door(Vector2(380,780),Color("b8c68b"))
		draw_string(ThemeDB.fallback_font,Vector2(820,714),"ROOFTOP RELAY",HORIZONTAL_ALIGNMENT_LEFT,-1,24,Color("e6dcc4"))
		draw_string(ThemeDB.fallback_font,Vector2(478,1067),"A second step through the air…",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("e6dcc4"))
	else:
		draw_door(Vector2(120,1300))
		if not player.double_jump:
			draw_circle(Vector2(1580,1240),22,Color("b8c68b") if guard_defeated else Color("665a70"))
			draw_string(ThemeDB.fallback_font,Vector2(1505,1188),"WINDSTEP",HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color("e6dcc4"))
		if not secret: draw_rect(Rect2(2284,815,32,20),Color("e9d8b5"))
func draw_door(at:Vector2,color=Color("d1b08e")):
	draw_rect(Rect2(at+Vector2(-37,-133),Vector2(74,133)),Color("171523"))
	draw_rect(Rect2(at+Vector2(-40,-136),Vector2(80,136)),color,false,4)
	draw_circle(at+Vector2(22,-58),4,color)
