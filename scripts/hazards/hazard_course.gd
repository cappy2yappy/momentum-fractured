extends Node2D
## Isolated harness: never loads or writes campaign saves/rooms.
const Player = preload("res://scripts/player.gd")
const Hazard = preload("res://scripts/hazards/environmental_hazard.gd")
const Placement = preload("res://scripts/hazards/hazard_placement.gd")
const Anchor = preload("res://scripts/grapple_anchor.gd")
var save_path = "user://haz01_course_only.json"
var player
var hazards: Array = []
var anchor
var status: Label
var room = 0
var capture_clock = 0.0
var capture_index = 0

func _ready():
	setup_input()
	floor_rect(Rect2(0,620,1280,100))
	floor_rect(Rect2(-30,0,30,720))
	floor_rect(Rect2(1280,0,30,720))
	player = Player.new()
	player.position = Vector2(90,620)
	player.dash_unlocked = true
	player.tether_unlocked = true
	add_child(player)
	player.hurt.connect(func():
		if player.hp <= 0: call_deferred("restart"))
	player.tether_requested.connect(func():
		if player.can_tether_anchor(anchor.global_position): player.apply_tether(anchor.global_position))
	anchor = Anchor.new()
	anchor.position = Vector2(930,330)
	add_child(anchor)
	for definition in ["collapse", "steam", "electric"]:
		var hazard = Hazard.new()
		hazard.placement = load("res://scenes/haz01/%s.tres" % definition)
		hazard.player = player
		add_child(hazard)
		hazards.append(hazard)
	var layer = CanvasLayer.new()
	add_child(layer)
	status = Label.new()
	status.position = Vector2(30,25)
	status.add_theme_font_size_override("font_size",19)
	layer.add_child(status)
	if "--haz01-capture" in OS.get_cmdline_user_args(): player.position = Vector2(300,430)
	queue_redraw()

func setup_input():
	var keys = {"left":KEY_A,"right":KEY_D,"jump":KEY_SPACE,"dash":KEY_SHIFT,"tether":KEY_Q,"attack":KEY_J,"parry":KEY_K,"kunai":KEY_R,"cycle_kunai":KEY_T}
	for action in keys:
		if not InputMap.has_action(action): InputMap.add_action(action)
		var event = InputEventKey.new()
		event.physical_keycode = keys[action]
		if not InputMap.action_has_event(action,event): InputMap.action_add_event(action,event)

func floor_rect(rect: Rect2):
	var body = StaticBody2D.new()
	var shape = CollisionShape2D.new()
	var box = RectangleShape2D.new()
	box.size = rect.size
	shape.shape = box
	shape.position = rect.get_center()
	body.add_child(shape)
	add_child(body)

func _unhandled_key_input(event):
	if not event.pressed or event.echo: return
	match event.physical_keycode:
		KEY_F5: save_course()
		KEY_F9: load_course()
		KEY_BACKSPACE: restart()
		KEY_F2:
			for hazard in hazards: hazard.set_enabled(not hazard.enabled)
		KEY_ESCAPE: get_tree().quit()

func _physics_process(delta):
	status.text = "HAZ-01  /  ISOLATED TRAVERSAL LAB     HP %d/3\nA/D walk · double tap sprint · Space jump · Shift dash · hold Q grapple\nBackspace re-enter · F2 enable/disable · F5 save · F9 restore · Esc exit\nAll lanes have a permanent recovery floor. Test abilities are local to this scene." % player.hp
	if player.position.y > 760: restart()
	if "--haz01-capture" in OS.get_cmdline_user_args():
		capture_clock += delta
		if capture_index < 3 and capture_clock >= [0.4,2.4,3.4][capture_index]:
			capture_index += 1
			capture.call_deferred(capture_index)
		if capture_clock > 4.0: get_tree().quit()

func restart(saved: Dictionary = {}):
	player.release_tether()
	player.position = Vector2(90,620)
	player.velocity = Vector2.ZERO
	player.hp = 3
	player.invulnerable = 1.5
	player.dash_time = 0
	player.dash_cooldown = 0
	player.tether_cooldown = 0
	player.jump_buffer = 0
	player.attack_time = 0
	for hazard in hazards:
		var state = saved.get(hazard.placement.placement_id,{})
		hazard.reset_room(state if state is Dictionary else {})

func save_course() -> bool:
	var data = {}
	for hazard in hazards: data[hazard.placement.placement_id] = hazard.snapshot()
	var file = FileAccess.open(save_path,FileAccess.WRITE)
	if file == null: return false
	file.store_string(JSON.stringify(data))
	return true

func load_course():
	var data = JSON.parse_string(FileAccess.get_file_as_string(save_path)) if FileAccess.file_exists(save_path) else {}
	restart(data if data is Dictionary else {})

func capture(index):
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://docs/haz01/evidence")
	get_viewport().get_texture().get_image().save_png("res://docs/haz01/evidence/course_%d.png" % index)

func _draw():
	draw_rect(Rect2(0,620,1280,100),Color("263e4b"))
	draw_line(Vector2(0,620),Vector2(1280,620),Color("73d6c6"),4)
	for x in [40,420,760,1120]:
		draw_string(ThemeDB.fallback_font,Vector2(x,685),"SAFE FLOOR",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("a8c4cb"))
	draw_circle(Vector2(930,330),13,Color("9ce7df"))
	draw_arc(Vector2(930,330),20,0,TAU,32,Color("9ce7df"),2)
	draw_string(ThemeDB.fallback_font,Vector2(860,295),"Q  GRAPPLE",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("9ce7df"))
	draw_string(ThemeDB.fallback_font,Vector2(190,390),"JUMP / WAIT / DROP",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("a8c4cb"))
	draw_string(ThemeDB.fallback_font,Vector2(1080,570),"CLEAR EXIT",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("a8c4cb"))
