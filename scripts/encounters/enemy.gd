extends "res://scripts/guard.gd"
## Temporary behavior labels reuse the approved guard combat interface/art.
const Shot = preload("res://scripts/encounters/projectile.gd")
var config: Dictionary
var encounter
var elapsed = 0.0
var lost = 0.0
var patrol_direction = 1
var aim = Vector2.LEFT
var wake_elapsed = 0.0
func _ready():
	super._ready()
	if config.is_empty(): return
	initialize(config, encounter)
func initialize(settings: Dictionary, owner_encounter):
	config = settings; encounter = owner_encounter
	hp = int(config.hp); max_hp = hp
	home = position.x; patrol_min = config.territory[0]; patrol_max = config.territory[1]
	move_speed = config.speed; attack_range = config.attack_range
	display_name = "PROTO " + config.type.to_upper()
	state = "dormant"; timer = 0
func visible_target() -> bool:
	var q = PhysicsRayQueryParameters2D.create(global_position + Vector2(0,-50), player.global_position + Vector2(0,-40), 1)
	return get_world_2d().direct_space_state.intersect_ray(q).is_empty()
func change(next: String, duration = 0.0):
	state = next; timer = duration
func _physics_process(dt):
	if hp <= 0 or not is_instance_valid(player): return
	elapsed += dt
	timer -= dt
	var d = player.global_position - global_position
	var sees = visible_target()
	if state == "dormant":
		var active = config.activation == "immediate" or (config.activation == "proximity" and d.length() <= config.activation_distance and sees) or (config.activation == "story" and encounter.world.expansion_flags.get(config.story_flag, false) == true and encounter.control_ready() and player.is_on_floor() and d.length() >= 400.0)
		if active:
			wake_elapsed = elapsed
			change("awakening", config.spawn_grace)
	elif state == "awakening":
		if timer <= 0: change("patrol")
	elif state == "stunned" or state == "recover":
		if timer <= 0: change("patrol")
	elif state == "windup":
		if timer <= 0:
			if config.type == "ranged":
				# Aim is locked at telegraph start; do not track a dodging player.
				var shot = Shot.new(); shot.player = player
				shot.position = position + Vector2(0,-50)
				shot.velocity = aim * config.projectile_speed; shot.lifetime = config.projectile_lifetime
				encounter.add_child(shot)
				change("recover", config.recovery_time)
			else:
				strike_done = false; change("strike", config.active_time)
	elif state == "strike":
		if not strike_done:
			strike_done = true
			if sees and absf(d.x) < attack_range + hit_radius and absf(d.y) < 85 and d.x * facing >= -14:
				if player.parry_time > 0 and player.facing == -facing:
					change("stunned", 1.1); player.hitstop = 0.065
				else: player.damage(player.position - d)
		if timer <= 0: change("recover", config.recovery_time)
	elif state == "return":
		position.x = move_toward(position.x, home, move_speed * dt)
		if absf(position.x-home) < 1: lost = 0; change("patrol")
	else:
		if sees: lost = 0
		else: lost += dt
		var inside = player.global_position.x >= patrol_min + encounter.global_position.x and player.global_position.x <= patrol_max + encounter.global_position.x
		if state == "pursue" and (d.length() > config.recovery_distance or lost >= config.lose_sight_time or not inside): change("return")
		elif sees and d.length() <= config.aggression_distance and (inside or config.type == "ranged"):
			facing = 1 if d.x >= 0 else -1
			if (config.type == "ranged" or (absf(d.x) <= attack_range and absf(d.y) < 80)) and elapsed - wake_elapsed >= config.spawn_grace:
				aim = (d + Vector2(0,10)).normalized()
				change("windup", config.windup)
			elif config.type != "ranged":
				change("pursue"); position.x = clampf(position.x + facing * move_speed * dt, patrol_min, patrol_max)
		elif config.type == "guard":
			position.x = clampf(position.x + patrol_direction * move_speed * 0.45 * dt, patrol_min, patrol_max)
			if position.x <= patrol_min or position.x >= patrol_max: patrol_direction *= -1
			facing = patrol_direction
	sprite.flip_h = facing < 0
	sprite.frame = 2 if state in ["windup", "awakening"] else (3 if state == "strike" else 0)
	sprite.modulate = Color(0.45,0.5,0.6,0.45) if state == "dormant" else Color.WHITE
	queue_redraw()
func receive_hit(amount):
	# Dormant silhouettes remain safe and cannot be killed before activation.
	if state in ["dormant", "awakening"]: return
	super.receive_hit(amount)
func _draw():
	super._draw()
	if config.is_empty(): return
	draw_string(ThemeDB.fallback_font, Vector2(-55,-155), "PROTO " + config.type.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("a9cfe8"))
	if state == "awakening": draw_arc(Vector2(0,-50), 70, 0, TAU, 32, Color("ffe295"), 4)
	if state == "windup" and config.type == "ranged": draw_line(Vector2(0,-50), Vector2(0,-50) + aim * 240, Color(1,0.6,0.25,0.65), 2)
