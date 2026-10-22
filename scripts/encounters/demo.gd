extends "res://scripts/world.gd"
## Standalone developer arenas. Never load/write the campaign save.
const Encounter = preload("res://scripts/encounters/encounter.gd")
@export_enum("guard", "ranged", "ambush", "combined") var demo = "combined"
var encounter
func _ready():
	# Base _ready checks --test before loading. Redirect even interactive launches.
	save_path = "user://en01_demo_unused.json"
	super._ready()
	test_mode = true
	set_physics_process(false)
	for enemy in enemies: enemy.free()
	enemies.clear(); guard = null; active_enemy = null
	for child in geometry.get_children(): child.free()
	platforms.clear(); tether_anchors.clear(); kunai_gates.clear()
	room = 0
	add_platform(Rect2(0,620,2600,140))
	add_platform(Rect2(-40,0,40,760)); add_platform(Rect2(2600,0,40,760))
	# Solid cover in ranged demo; jump over or use the upper grapple anchor.
	if demo in ["ranged", "combined"]: add_platform(Rect2(1050,510,55,110))
	tether_anchors.append(Vector2(850,320))
	player.position = Vector2(250,618); player.velocity = Vector2.ZERO
	player.double_jump = true; player.dash_unlocked = true; player.tether_unlocked = true
	for element in player.kunai_unlocked: player.unlock_kunai(element)
	camera.limit_right = 2600; camera.limit_bottom = 760
	camera.position_smoothing_enabled = false; camera.reset_smoothing()
	message = "EN-01 / " + demo.to_upper() + " — TEMPORARY PROTOTYPES / J attack · F parry · R kunai · Space jump · Shift dash"
	message_time = 99999
	encounter = Encounter.new(); add_child(encounter)
	var data = JSON.parse_string(FileAccess.get_file_as_string("res://scenes/encounters/" + demo + ".json"))
	var errors = encounter.configure(self, data)
	if not errors.is_empty(): push_error(str(errors))
	encounter.completed.connect(func(event): announce("TEST COMPLETE: " + event, 99999))
func save_progress(): return true
func load_progress(): pass
func on_hurt():
	if player.hp <= 0: call_deferred("restart_demo")
func restart_demo(): get_tree().reload_current_scene()
func _draw():
	draw_rect(Rect2(0,0,2600,760), Color("172336"))
	for surface in platforms: draw_rect(surface, Color("4c626a"))
	for anchor in tether_anchors: draw_circle(anchor,12,Color("a5dedc"))
	for x in range(0,2600,100): draw_line(Vector2(x,620),Vector2(x,760),Color("687c80"))
	draw_string(ThemeDB.fallback_font, Vector2(240,430), "EN-01: NON-CANONICAL BEHAVIOR TEST", HORIZONTAL_ALIGNMENT_LEFT,-1,24,Color("e2e7ed"))
