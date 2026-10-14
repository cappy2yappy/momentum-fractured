extends CharacterBody2D
signal strike(damage, reach)
signal hurt
signal tether_requested
signal afterimage_requested(texture, frame, position, flip_h)
signal kunai_requested(element, direction, position)
const MomentumProfile = preload("res://scripts/momentum_profile.gd")
@export_range(80.0, 480.0, 1.0) var grapple_range = 440.0
@export var grapple_clearance_check = true
var speed_upgrade_level = 0
var momentum = MomentumProfile.new()
var technique_start = Vector2.ZERO
func unlock_speed_upgrade(id: String) -> bool:
	if id != "stride_1" or speed_upgrade_level >= 1: return false
	speed_upgrade_level = 1
	return true
func restore_speed_upgrade(value):
	speed_upgrade_level = 1 if (value is int or value is float) and value == 1 else 0
func movement_target_speed(sprinting: bool) -> float:
	var permanent = 1.05 if speed_upgrade_level == 1 else 1.0
	return (600.0 if sprinting else 400.0) * permanent * (momentum.speed_multiplier() if sprinting else 1.0)
func has_traversal_requirement(id: String) -> bool:
	match id:
		"double_jump": return double_jump
		"tether": return tether_unlocked
		"dash": return dash_unlocked
		"stride_1": return speed_upgrade_level == 1
		"wind", "fire", "electric": return bool(kunai_unlocked.get(id, false))
	return false
var facing = 1
var hp = 3
var double_jump = false
var tether_unlocked = false
var dash_unlocked = false
var air_used = false
var coyote = 0.0
var jump_buffer = 0.0
var invulnerable = 0.0
var parry_time = 0.0
var parry_cooldown = 0.0
var attack_time = 0.0
var combo = 0
var queued = false
var did_strike = false
var run = false
var last_tap = -10.0
var last_dir = 0
var age = 0.0
var touch: Dictionary = {}
var hitstop = 0.0
var tether_cooldown = 0.0
var tether_attached = false
var tether_anchor = Vector2.ZERO
var tether_length = 0.0
var tether_taut = false
var dash_time = 0.0
var dash_cooldown = 0.0
var afterimage_cooldown = 0.0
var kunai_cooldown = 0.0
var kunai_unlocked = {"wind": false, "fire": false, "electric": false}
var selected_kunai = "wind"
var sprite = Sprite2D.new()
var clips: Dictionary = {}
var animation_clock = 0.0
var last_clip = ""
func _ready():
	momentum.enabled = "--momentum-prototype" in OS.get_cmdline_user_args()
	collision_layer = 2
	collision_mask = 1
	var shape = CollisionShape2D.new()
	var capsule = CapsuleShape2D.new()
	capsule.radius = 14
	capsule.height = 60
	shape.shape = capsule
	shape.position.y = -30
	add_child(shape)
	add_child(sprite)
	clips["idle"] = load("res://assets/kaze/cleaned/kaze_idle_strip.png")
	clips["run"] = load("res://assets/kaze/cleaned/kaze_run_strip.png")
	clips["attack"] = load("res://assets/kaze/cleaned/kaze_combat_strip.png")
	clips["traversal"] = load("res://assets/kaze/cleaned/kaze_traversal_strip.png")
func held(action): return Input.is_action_pressed(action) or touch.get(action, false)
func press(action):
	if action == "jump": jump_buffer = 0.16
	if action == "attack":
		if attack_time <= 0: start_attack(0)
		elif attack_time > 0.1: queued = true
	if action == "parry" and parry_cooldown <= 0 and attack_time <= 0:
		parry_time = 0.23
		parry_cooldown = 0.48
	if action == "tether" and tether_unlocked and tether_cooldown <= 0 and not tether_attached and not is_on_floor():
		tether_requested.emit()
	if action == "dash" and dash_unlocked and dash_cooldown <= 0 and attack_time <= 0:
		# A dash skips rope integration: release the constraint before its impulse.
		release_tether()
		technique_start = position
		dash_time = 0.18
		dash_cooldown = 0.58
		invulnerable = maxf(invulnerable, 0.24)
		velocity = Vector2(facing * 920, 0)
	if action == "kunai" and kunai_unlocked.get(selected_kunai, false) and kunai_cooldown <= 0:
		kunai_cooldown = 0.32
		kunai_requested.emit(selected_kunai, facing, position + Vector2(facing * 30, -52))
	if action == "cycle_kunai": cycle_kunai()
	if action in ["left", "right"]:
		var dir = -1 if action == "left" else 1
		if last_dir == dir and age - last_tap < 0.25: run = true
		last_dir = dir
		last_tap = age
func start_attack(index):
	combo = index
	did_strike = false
	queued = false
	attack_time = [0.36, 0.41, 0.57][combo]
func _physics_process(dt):
	age += dt
	for action in ["left", "right", "jump", "attack", "parry", "tether", "dash", "kunai", "cycle_kunai"]:
		if Input.is_action_just_pressed(action): press(action)
	if hitstop > 0:
		hitstop -= dt
		return
	jump_buffer = maxf(0, jump_buffer - dt)
	invulnerable = maxf(0, invulnerable - dt)
	parry_time = maxf(0, parry_time - dt)
	parry_cooldown = maxf(0, parry_cooldown - dt)
	tether_cooldown = maxf(0, tether_cooldown - dt)
	dash_cooldown = maxf(0, dash_cooldown - dt)
	kunai_cooldown = maxf(0, kunai_cooldown - dt)
	if dash_time > 0:
		dash_time = maxf(0, dash_time - dt)
		velocity = Vector2(facing * 920, 0)
		var before_dash = position
		move_and_slide()
		momentum.tick(dt, position - before_dash, float(held("right")) - float(held("left")), false, false)
		if dash_time <= 0: momentum.reward_transition("dash", position.distance_to(technique_start), absf(velocity.x))
		animate(dt)
		afterimage_cooldown -= dt
		if afterimage_cooldown <= 0:
			afterimage_cooldown = 0.03
			afterimage_requested.emit(sprite.texture, sprite.frame, position + sprite.position, sprite.flip_h)
		queue_redraw()
		return
	if tether_attached and ( not held("tether") or jump_buffer > 0):
		release_tether()
	if tether_attached:
		var swing_direction = float(held("right")) - float(held("left"))
		if swing_direction != 0: facing = int(swing_direction)
		var before_swing = position
		integrate_tether_swing(dt, swing_direction)
		momentum.tick(dt, position - before_swing, swing_direction, false, false)
		animate(dt)
		queue_redraw()
		return
	if is_on_floor():
		coyote = 0.12
		air_used = false
	else: coyote = maxf(0, coyote - dt)
	var direction = float(held("right")) - float(held("left"))
	if direction == 0: run = false
	if direction != 0: facing = int(direction)
	var speed = movement_target_speed(run)
	if attack_time > 0 and is_on_floor(): speed *= 0.5
	if direction != 0 and (absf(velocity.x) < speed or signf(velocity.x) != signf(direction)):
		velocity.x = move_toward(velocity.x, direction * speed, 2600 * dt if is_on_floor() else 1200 * dt)
	elif direction == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, 2600 * dt)
	velocity.y += 1800 * dt
	if is_on_wall() and direction != 0 and velocity.y > 100: velocity.y = 100
	if jump_buffer > 0:
		if coyote > 0:
			velocity.y = -900;coyote = 0;jump_buffer = 0
		elif is_on_wall():
			velocity = Vector2(get_wall_normal().x * 480, -880);jump_buffer = 0
		elif double_jump and not air_used:
			velocity.y = -900;air_used = true;jump_buffer = 0
	if not held("jump") and velocity.y < -360: velocity.y = -360
	var before_move = position
	move_and_slide()
	momentum.tick(dt, position - before_move, direction, run, attack_time > 0 or invulnerable > 0)
	if attack_time > 0:
		var total = [0.36, 0.41, 0.57][combo]
		attack_time -= dt
		if total - attack_time >= [0.105, 0.12, 0.2][combo] and not did_strike:
			did_strike = true
			strike.emit(2 if combo == 2 else 1, 115 if combo == 2 else 95)
		if attack_time <= 0 and queued: start_attack((combo + 1) % 3)
	animate(dt)
	queue_redraw()
func animate(dt):
	var clip = "idle"
	var pose = -1
	if absf(velocity.x) > 40: clip = "run"
	if not is_on_floor():
		clip = "traversal"
		pose = 1 if velocity.y < -150 else (2 if velocity.y < 150 else 3)
	if is_on_wall() and not is_on_floor(): clip = "traversal";pose = 5
	if tether_attached and not is_on_floor(): clip = "traversal";pose = 6
	if attack_time > 0: clip = "attack"
	if dash_time > 0: clip = "traversal";pose = 7
	if clip != last_clip: animation_clock = 0
	last_clip = clip
	animation_clock += dt
	var tex = clips[clip]
	sprite.texture = tex
	sprite.hframes = 8
	if clip == "attack":
		var total = [0.36, 0.41, 0.57][combo]
		pose = clampi(int((total - attack_time) / total * 8.0), 0, 7)
	sprite.frame = pose if pose >= 0 else int(animation_clock / (0.16 if clip == "idle" else 0.08)) % sprite.hframes
	var visual_scale = {"idle": 0.2649908807267889, "run": 0.3825780535911868, "attack": 0.37875157200639, "traversal": 0.33919279345239656}[clip]
	sprite.scale = Vector2.ONE * visual_scale
	var baseline = {"idle": 591.0, "run": 491.0, "attack": 498.0, "traversal": 510.0}[clip]
	sprite.offset = Vector2(0, tex.get_height() / 2.0 - baseline)
	sprite.flip_h = facing < 0
	sprite.position = Vector2.ZERO
	sprite.modulate.a = 0.45 if invulnerable > 0 and int(age * 18) % 2 == 0 else 1.0
func damage(from: Vector2):
	if invulnerable > 0: return false
	momentum.take_damage()
	hp -= 1
	invulnerable = 1.2
	velocity = Vector2(signf(position.x - from.x) * 280, -240)
	hurt.emit()
	return true
func tether_origin() -> Vector2:
	return position + Vector2(0, -55)
func can_tether_anchor(anchor: Vector2) -> bool:
	var offset = anchor - tether_origin()
	var forward = offset.x * facing
	return dash_time <= 0 and not is_on_floor() and forward >= -100 and forward <= clampf(grapple_range, 80.0, 480.0) and offset.y <= -35 and offset.length() >= 80 and offset.length() <= clampf(grapple_range, 80.0, 480.0) and tether_path_clear(anchor)
func tether_path_clear(anchor: Vector2) -> bool:
	if not grapple_clearance_check or not is_inside_tree(): return true
	var query = PhysicsRayQueryParameters2D.create(global_position + Vector2(0, -55), anchor, 1, [get_rid()])
	return get_world_2d().direct_space_state.intersect_ray(query).is_empty()
func apply_tether(anchor: Vector2):
	if not can_tether_anchor(anchor): return false
	technique_start = position
	tether_anchor = anchor
	tether_length = maxf(80.0, tether_origin().distance_to(anchor))
	tether_taut = false
	tether_attached = true
	air_used = false
	return true
func release_tether():
	if not tether_attached: return
	momentum.reward_transition("tether", position.distance_to(technique_start), absf(velocity.x))
	tether_attached = false
	tether_taut = false
	tether_cooldown = 0.2
func unlock_kunai(element: String):
	kunai_unlocked[element] = true
	selected_kunai = element
func cycle_kunai():
	var types = ["wind", "fire", "electric"]
	var start = types.find(selected_kunai)
	for offset in range(1, 4):
		var candidate = types[(start + offset) % types.size()]
		if kunai_unlocked.get(candidate, false):
			selected_kunai = candidate
			return
func integrate_tether_swing(dt: float, direction: float):
	var next_position = position
	var next_velocity = velocity
	if tether_taut:
		var theta = atan2(position.x - tether_anchor.x, position.y - 55.0 - tether_anchor.y)
		var omega = (velocity.x * cos(theta) - velocity.y * sin(theta)) / tether_length
		var tension = 1800.0 * cos(theta) + omega * omega * tether_length
		if tension >= 0:
			var pump = direction * 130.0
			var accel = func(angle): return (-1800.0 * sin(angle) + pump * cos(angle)) / tether_length
			var next_theta = theta + omega * dt + 0.5 * accel.call(theta) * dt * dt
			omega += 0.5 * (accel.call(theta) + accel.call(next_theta)) * dt
			next_position = tether_anchor + Vector2(sin(next_theta) * tether_length, cos(next_theta) * tether_length + 55.0)
			next_velocity = Vector2(cos(next_theta) * tether_length * omega, - sin(next_theta) * tether_length * omega)
		else:
			tether_taut = false
	if not tether_taut:
		next_position += Vector2(velocity.x * dt, velocity.y * dt + 0.5 * 1800.0 * dt * dt)
		next_velocity.y += 1800.0 * dt
		var rope_offset = next_position + Vector2(0, -55) - tether_anchor
		var distance = rope_offset.length()
		if distance > tether_length:
			var normal = rope_offset / distance
			next_position = tether_anchor + normal * tether_length + Vector2(0, 55)
			var outward = next_velocity.dot(normal)
			if outward >= 0:
				next_velocity -= outward * normal
				tether_taut = true
	var movement = next_position - position
	velocity = next_velocity
	var collision = move_and_collide(movement)
	if collision:
		release_tether()
func _draw():
	if parry_time > 0:
		draw_arc(Vector2(0, -48), 54, -1.4 if facing > 0 else 1.74, 1.4 if facing > 0 else 4.54, 20, Color("c8f59c"), 4)
	if attack_time > 0 and did_strike:
		draw_arc(Vector2(facing * 24, -45), 65, -1.1 if facing > 0 else 2.0, 1.1 if facing > 0 else 4.3, 20, Color(0.95, 0.9, 0.7, clampf(attack_time * 3, 0, 0.8)), 5)
