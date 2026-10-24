extends "res://scripts/world.gd"
## Private optional laboratory. Never loads or writes campaign profiles.
const ManagedEncounter = preload("res://scripts/encounters/encounter.gd")
const ManagedEnemy = preload("res://scripts/encounters/enemy.gd")
const CandidateEnemy = preload("res://scripts/en02/enemy.gd")
@export_enum("skirmisher", "slime") var behavior := "skirmisher"
var encounter
var experiment_ready := false
var permit_test_disk := false
var completed_events: Array = []

func spawn_enemy(at: Vector2, boss: bool, required := false, enemy_script = Guard):
	var use_candidate := experiment_ready and enemy_script == ManagedEnemy
	var enemy = super.spawn_enemy(at, boss, required, CandidateEnemy if use_candidate else enemy_script)
	if use_candidate: enemy.behavior = behavior
	return enemy

func _ready():
	save_path = "user://en02_lab_unused.json"
	super._ready()
	test_mode = true
	set_physics_process(false)
	for enemy in enemies: enemy.free()
	enemies.clear(); guard = null; active_enemy = null
	for child in geometry.get_children(): child.free()
	platforms.clear(); tether_anchors.clear(); kunai_gates.clear()
	room = 0
	add_platform(Rect2(0,620,1800,140))
	add_platform(Rect2(-40,0,40,760)); add_platform(Rect2(1800,0,40,760))
	player.position = Vector2(260,618); player.velocity = Vector2.ZERO
	player.double_jump = true; player.dash_unlocked = true; player.tether_unlocked = true
	for element in player.kunai_unlocked: player.unlock_kunai(element)
	camera.limit_right = 1800; camera.limit_bottom = 760
	camera.position_smoothing_enabled = false; camera.reset_smoothing()
	message = "EN-02 " + behavior.to_upper() + " / PROTOTYPE: J attack, F parry, Shift dash, Space jump, F6 replay"
	message_time = 99999
	experiment_ready = true
	configure_encounter()

func entry() -> Dictionary:
	return {"version":1,"id":"en02/"+behavior,"type":"guard","position":[900,620],"territory":[600,1300],"activation":"proximity","activation_distance":400,"aggression_distance":400,"recovery_distance":600,"speed":80,"hp":4,"attack_range":110 if behavior == "slime" else 88,"windup":0.70 if behavior == "slime" else 0.65,"spawn_grace":0.80,"recovery_time":1.10 if behavior == "slime" else 1.0,"persistent":true,"completion_event":"en02/complete"}

func configure_encounter():
	encounter = ManagedEncounter.new(); add_child(encounter)
	var errors = encounter.configure(self,[entry()])
	if not errors.is_empty(): push_error(str(errors))
	encounter.completed.connect(func(event): completed_events.append(event); announce("EN-02 complete / saved for this laboratory session",99999))

func save_progress():
	return super.save_progress() if permit_test_disk else true
func load_progress(): pass
func load_test_fixture(): super.load_progress()
func on_hurt():
	if player.hp <= 0: call_deferred("restart_demo")
func restart_demo(): get_tree().reload_current_scene()

func _unhandled_key_input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_F6: restart_demo()

func _draw():
	draw_rect(Rect2(0,0,1800,760),Color("172336"))
	for surface in platforms: draw_rect(surface,Color("4c626a"))
	draw_rect(Rect2(600,620,700,8),Color("ffe295"))
	for x in [600,642,1258,1300]: draw_line(Vector2(x,540),Vector2(x,640),Color("ffe295"),2)
	draw_string(ThemeDB.fallback_font,Vector2(520,300),"NON-CANONICAL LAB / ground plane fixed at y620",HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color.WHITE)
	draw_string(ThemeDB.fallback_font,Vector2(520,334),"Yellow: territory. Circle: 42px reference, not a collider. Retreat either side.",HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color.WHITE)
