extends "res://scripts/guard.gd"
signal phase_changed(phase)
var phase = 1
var attack_kind = "sweep"
var attack_counter = 0
var hit_flash = 0.0
var engaged = false
const SWEEP_REACH = 278.0
const PULSE_REACH = 520.0

func _ready():
	super._ready()
	hp = 18
	max_hp = 18
	display_name = "STORM KEEPER"
	set_meta("persistent_id", "storm_keeper")
	set_meta("progression_boss", "storm_keeper")

func begin_attack(kind):
	attack_kind = kind
	state = "windup"
	timer = 0.9 if phase == 1 else 0.68
	strike_done = false
	facing = 1 if player.position.x >= position.x else -1

func _physics_process(dt):
	if hp <= 0 or not is_instance_valid(player): return
	timer -= dt
	hit_flash = maxf(0, hit_flash - dt)
	var distance = player.position - position
	match state:
		"stunned", "recover":
			if timer <= 0: state = "patrol"
		"windup":
			if timer <= 0:
				state = "strike"
				timer = 0.18
				strike_done = false
		"strike":
			if not strike_done:
				strike_done = true
				resolve_attack()
			if state == "strike" and timer <= 0:
				state = "recover"
				timer = 0.95 if phase == 1 else 0.7
		_:
			facing = 1 if distance.x > 0 else -1
			if absf(distance.x) < PULSE_REACH and absf(distance.y) < 180:
				var kind = "pulse" if attack_counter % 2 == 1 or absf(distance.x) > 245 else "sweep"
				attack_counter += 1
				begin_attack(kind)
			elif engaged or absf(distance.x) < chase_distance:
				position.x = clampf(position.x + facing * move_speed * dt, 360.0, 2240.0)
	sprite.flip_h = facing < 0
	sprite.frame = 5 if state in ["windup", "strike"] else 0
	sprite.modulate = Color.WHITE if hit_flash > 0 else (Color("d9dd99") if state == "stunned" else (Color("c7d9ee") if phase == 1 else Color("efc586")))
	queue_redraw()

func resolve_attack():
	var distance = player.position - position
	var connects = absf(distance.x) <= SWEEP_REACH and absf(distance.y) < 105 and distance.x * facing >= -45
	if attack_kind == "pulse":
		connects = absf(distance.x) <= PULSE_REACH and absf(distance.y) < 70 and player.is_on_floor()
	if not connects: return
	if player.parry_time > 0 and player.facing == -facing:
		state = "stunned"
		timer = 1.2
		player.hitstop = 0.065
		audio_cue.emit("parry") # AUD01 audio-only
	else:
		player.damage(position)

func receive_hit(damage):
	if hp <= 0 or damage <= 0: return
	engaged = true
	hp = maxf(0, hp - damage)
	hit_flash = 0.12
	if phase == 1 and hp <= max_hp / 2.0:
		phase = 2
		phase_changed.emit(phase)
	if hp <= 0:
		defeated.emit()
		queue_free()

func _draw():
	if hp <= 0: return
	draw_rect(Rect2(-60, -214, 120, 7), Color("312937"))
	draw_rect(Rect2(-60, -214, 120 * hp / float(max_hp), 7), Color("d7b477"))
	draw_string(ThemeDB.fallback_font, Vector2(-65, -226), "KEEPER • PHASE %d" % phase, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("efcf9f"))
	if state not in ["windup", "strike"]: return
	var active = state == "strike"
	var color = Color("f1d3ba") if active else (Color("efc56c") if attack_kind == "sweep" else Color("76d9ff"))
	if attack_kind == "sweep":
		draw_line(Vector2(0, -48), Vector2(facing * SWEEP_REACH, -48), color, 10 if active else 3)
	else:
		draw_line(Vector2(-PULSE_REACH, -8), Vector2(PULSE_REACH, -8), color, 14 if active else 3)
		for x in range(-480, 481, 80): draw_line(Vector2(x, -8), Vector2(x, -24), color, 2)
	draw_string(ThemeDB.fallback_font, Vector2(-90, -172), "PARRY / EVADE" if attack_kind == "sweep" else "JUMP / TETHER", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, color)
