extends CharacterBody2D

const IDLE_TEXTURE := preload("res://assets/sprites/kaze/idle_strip.png")
const RUN_TEXTURE := preload("res://assets/sprites/kaze/run_strip.png")
const JUMP_TEXTURE := preload("res://assets/sprites/kaze/jump_strip.png")
const FALL_TEXTURE := preload("res://assets/sprites/kaze/fall_strip.png")
const DASH_TEXTURE := preload("res://assets/sprites/kaze/dash_strip.png")
const WALL_TEXTURE := preload("res://assets/sprites/kaze/wall_slide_strip.png")
const ATTACK_TEXTURE := preload("res://assets/sprites/kaze/attack_strip.png")

# ============================================================
# MOMENTUM: FRACTURED — Core Player Movement
# Web-parity controller: responsive platforming, combat, and momentum tether.
# ============================================================

# PHYSICS CONSTANTS
const GRAVITY := 1760.0
const HOLD_JUMP_GRAVITY_MULT := 0.62
const FALL_GRAVITY_MULT := 1.42
const JUMP_RELEASE_GRAVITY_MULT := 1.95
const APEX_GRAVITY_MULT := 0.72
const APEX_VELOCITY_THRESHOLD := 72.0
const MAX_FALL_SPEED := 820.0
const MAX_MOVE_SPEED := 340.0
const MOVE_ACCEL := 2850.0
const AIR_ACCEL := 1750.0
const GROUND_DECEL := 3300.0
const AIR_DECEL := 520.0

# JUMP
const JUMP_VELOCITY := -585.0
const WALL_JUMP_VELOCITY_Y := -555.0
const WALL_JUMP_FORCE_X := 430.0
const WALL_SLIDE_SPEED := 92.0

# DASH
const DASH_SPEED := 1040.0
const DASH_DURATION := 0.14
const MAX_AIR_DASHES := 1
const DASH_COOLDOWN := 0.2
const GRAPPLE_RANGE := 410.0
const GRAPPLE_MIN_LENGTH := 78.0
const GRAPPLE_GRAVITY_MULT := 0.86
const GRAPPLE_PUMP_ACCEL := 820.0
const GRAPPLE_MAX_SPEED := 900.0
const GRAPPLE_BELOW_ALLOWANCE := 54.0
const KUNAI_COOLDOWN := 0.32
const GUARD_VEIL_DURATION := 3.0
const GUARD_VEIL_COOLDOWN := 8.0

# FORGIVENESS
const COYOTE_TIME := 0.10
const JUMP_BUFFER_TIME := 0.12

# COMBAT
const ATTACK_COOLDOWN := 0.24
const ATTACK_DAMAGE := 14.0
const ATTACK_DAMAGE_2 := 17.0
const ATTACK_DAMAGE_3 := 22.0
const ATTACK_KNOCKBACK := 340.0
const COMBO_RESET_WINDOW := 0.5
const ATTACK_HIT_WINDOW := 0.15

# STATE
var facing_dir := 1
var is_touching_wall := 0
var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var dash_buffer_timer := 0.0
var dash_cooldown_timer := 0.0
var dash_timer := 0.0
var dash_count := MAX_AIR_DASHES
var is_dashing := false
var dash_velocity_x := 0.0
var is_dead := false
var _was_on_floor := false
var attack_cooldown_timer := 0.0
var is_attacking := false
var combo_reset_timer := 0.0
var combo_step := 0
var grapple_active := false
var grapple_point := Vector2.ZERO
var grapple_length := 0.0
var grapple_anchor: Node2D = null
var tether_visual_time := 0.0
var kunai_cooldown_timer := 0.0
var guard_veil_timer := 0.0
var guard_veil_cooldown_timer := 0.0
var afterimage_timer := 0.0
var current_kunai_element := 0
var kunai_elements: Array[String] = ["wind", "fire", "electric"]
var in_water := false

# NODES
@onready var hitbox: Area2D = $Hitbox
@onready var health = get_node_or_null("Health")
@onready var sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")

# SIGNALS
signal died
signal health_changed(current: float, max_health: float)

func _ready() -> void:
	add_to_group("player")
	_configure_sprite_frames()
	if health:
		var on_health_changed := Callable(self, "_on_health_node_changed")
		if health.has_signal("health_changed") and not health.is_connected("health_changed", on_health_changed):
			health.connect("health_changed", on_health_changed)
		var on_health_died := Callable(self, "_on_health_depleted")
		if health.has_signal("died") and not health.is_connected("died", on_health_died):
			health.connect("died", on_health_died)
		emit_signal("health_changed", get_current_health(), get_max_health())
	_was_on_floor = is_on_floor()

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	# TIMERS
	coyote_timer = max(0.0, coyote_timer - delta)
	jump_buffer_timer = max(0.0, jump_buffer_timer - delta)
	dash_buffer_timer = max(0.0, dash_buffer_timer - delta)
	dash_cooldown_timer = max(0.0, dash_cooldown_timer - delta)
	attack_cooldown_timer = max(0.0, attack_cooldown_timer - delta)
	combo_reset_timer = max(0.0, combo_reset_timer - delta)
	kunai_cooldown_timer = max(0.0, kunai_cooldown_timer - delta)
	guard_veil_timer = max(0.0, guard_veil_timer - delta)
	guard_veil_cooldown_timer = max(0.0, guard_veil_cooldown_timer - delta)
	afterimage_timer = max(0.0, afterimage_timer - delta)
	tether_visual_time += delta

	if Input.is_action_just_pressed("guard_veil") and GameState.has_ability("guard_veil") and guard_veil_cooldown_timer <= 0.0:
		guard_veil_timer = GUARD_VEIL_DURATION
		guard_veil_cooldown_timer = GUARD_VEIL_COOLDOWN
		modulate = Color(0.55, 1.0, 0.86, 1.0)
	if guard_veil_timer <= 0.0 and modulate != Color.WHITE:
		modulate = Color.WHITE

	if Input.is_action_just_pressed("throw_kunai") and kunai_cooldown_timer <= 0.0 and _can_throw_current_kunai():
		_throw_kunai()

	if Input.is_action_just_pressed("grapple") and GameState.has_ability(GameState.ABILITY_TETHER):
		_start_grapple()
	if grapple_active and not Input.is_action_pressed("grapple"):
		grapple_active = false
		grapple_anchor = null
		queue_redraw()
	
	# ATTACK
	if Input.is_action_just_pressed("attack_light") and attack_cooldown_timer <= 0:
		_perform_attack()
	
	# DASH
	if is_dashing:
		if afterimage_timer <= 0.0:
			_spawn_afterimage()
			afterimage_timer = 0.035
		dash_timer -= delta
		if dash_timer <= 0:
			_end_dash()
		else:
			velocity.x = dash_velocity_x
			move_and_slide()
			_check_wall_touch()
			return
	
	# MOVEMENT
	var input_dir := 0.0
	if Input.is_action_pressed("move_left"):
		input_dir = -1.0
		facing_dir = -1
	elif Input.is_action_pressed("move_right"):
		input_dir = 1.0
		facing_dir = 1
	if sprite:
		sprite.flip_h = facing_dir < 0
	
	if input_dir != 0:
		var accel := MOVE_ACCEL if is_on_floor() else AIR_ACCEL
		velocity.x = move_toward(velocity.x, input_dir * MAX_MOVE_SPEED, accel * delta)
	else:
		var decel := GROUND_DECEL if is_on_floor() else AIR_DECEL
		velocity.x = move_toward(velocity.x, 0.0, decel * delta)
	
	# COYOTE TIME
	var on_floor_now := is_on_floor()
	if on_floor_now:
		coyote_timer = COYOTE_TIME
		dash_count = MAX_AIR_DASHES
	_was_on_floor = on_floor_now
	
	# JUMP BUFFER
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
		if in_water:
			velocity.y = -320.0
			jump_buffer_timer = 0.0
	
	# DASH BUFFER
	if Input.is_action_just_pressed("dash"):
		dash_buffer_timer = JUMP_BUFFER_TIME
	
	# JUMP EXECUTION
	if jump_buffer_timer > 0:
		if coyote_timer > 0:
			velocity.y = JUMP_VELOCITY
			AudioManager.play_sfx("jump")
			coyote_timer = 0
			jump_buffer_timer = 0
		elif is_touching_wall != 0:
			velocity.y = WALL_JUMP_VELOCITY_Y
			velocity.x = WALL_JUMP_FORCE_X * -is_touching_wall
			facing_dir = -is_touching_wall
			AudioManager.play_sfx("jump")
			is_touching_wall = 0
			jump_buffer_timer = 0
	
	# DASH EXECUTION
	if dash_buffer_timer > 0 and dash_cooldown_timer <= 0 and GameState.has_ability(GameState.ABILITY_DASH):
		if is_on_floor() or dash_count > 0:
			if not is_on_floor():
				dash_count -= 1
			_begin_dash()
	
	# GRAVITY
	var gravity_mult := 1.0
	if velocity.y < 0 and Input.is_action_pressed("jump"):
		gravity_mult = HOLD_JUMP_GRAVITY_MULT
	elif velocity.y < 0 and not Input.is_action_pressed("jump"):
		gravity_mult = JUMP_RELEASE_GRAVITY_MULT
	elif abs(velocity.y) < APEX_VELOCITY_THRESHOLD:
		gravity_mult = APEX_GRAVITY_MULT
	elif velocity.y > 0:
		gravity_mult = FALL_GRAVITY_MULT
	
	var medium_gravity := 0.22 if in_water else 1.0
	velocity.y += GRAVITY * gravity_mult * (GRAPPLE_GRAVITY_MULT if grapple_active else 1.0) * medium_gravity * delta
	if in_water:
		velocity *= Vector2(0.985, 0.94)
	
	# WALL SLIDE
	if is_touching_wall != 0 and velocity.y > 0 and not is_on_floor():
		velocity.y = min(velocity.y, WALL_SLIDE_SPEED)
	
	# MAX FALL SPEED
	velocity.y = min(velocity.y, 240.0 if in_water else MAX_FALL_SPEED)
	if grapple_active:
		_apply_grapple_pump(input_dir, delta)
	
	# MOVE
	move_and_slide()
	_apply_grapple_constraint()
	_check_wall_touch()
	_update_animation()
	queue_redraw()

func _check_wall_touch() -> void:
	is_touching_wall = 0
	if is_on_wall():
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision.get_normal().x > 0.5:
				is_touching_wall = -1
			elif collision.get_normal().x < -0.5:
				is_touching_wall = 1

func die() -> void:
	if is_dead:
		return
	is_dead = true
	visible = false
	emit_signal("died")

func respawn(pos: Vector2) -> void:
	global_position = pos
	velocity = Vector2.ZERO
	is_dead = false
	visible = true
	is_dashing = false
	dash_velocity_x = 0.0
	dash_count = MAX_AIR_DASHES
	coyote_timer = 0
	jump_buffer_timer = 0
	dash_cooldown_timer = 0
	_was_on_floor = false
	grapple_active = false
	grapple_anchor = null
	guard_veil_timer = 0.0
	modulate = Color.WHITE
	if health:
		health.is_dead = false

func get_dash_cooldown_ratio() -> float:
	if DASH_COOLDOWN <= 0.0:
		return 1.0
	return clampf(1.0 - dash_cooldown_timer / DASH_COOLDOWN, 0.0, 1.0)

func _perform_attack() -> void:
	if not hitbox:
		return
	
	is_attacking = true
	attack_cooldown_timer = ATTACK_COOLDOWN
	combo_step = combo_step + 1 if combo_reset_timer > 0.0 else 1
	if combo_step > 3:
		combo_step = 1
	combo_reset_timer = COMBO_RESET_WINDOW
	
	# Set hitbox properties
	match combo_step:
		1:
			hitbox.damage = ATTACK_DAMAGE
		2:
			hitbox.damage = ATTACK_DAMAGE_2
		_:
			hitbox.damage = ATTACK_DAMAGE_3
	hitbox.set_knockback_direction(Vector2(facing_dir, -0.3), ATTACK_KNOCKBACK)
	hitbox.set_meta("is_final_combo_hit", combo_step == 3)
	var attack_shape := hitbox.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if attack_shape:
		attack_shape.position.x = absf(attack_shape.position.x) * facing_dir
	
	# Activate hitbox
	hitbox.activate(ATTACK_HIT_WINDOW, true)
	AudioManager.play_sfx("attack_swing")
	
	# Reset attacking flag after a short delay
	await get_tree().create_timer(0.15).timeout
	is_attacking = false


func take_damage(amount: float) -> void:
	if is_dead or amount <= 0.0:
		return
	if is_guard_veil_active():
		return

	GameState.reset_combo()

	if health:
		health.take_damage(amount)
	else:
		die()


func set_health_values(current: float, max_health_value: float) -> void:
	if health and health.has_method("set_health_values"):
		health.call("set_health_values", current, max_health_value)


func get_current_health() -> float:
	if health:
		return health.current_health
	return 0.0 if is_dead else 100.0


func get_max_health() -> float:
	if health:
		return health.max_health
	return 100.0


func _on_health_node_changed(_old_value: float, new_value: float) -> void:
	GameState.set_player_health(new_value, get_max_health())
	emit_signal("health_changed", new_value, get_max_health())


func _on_health_depleted() -> void:
	die()


func is_guard_veil_active() -> bool:
	return guard_veil_timer > 0.0


func set_in_water(value: bool) -> void:
	in_water = value


func get_guard_veil_ratio() -> float:
	if guard_veil_timer > 0.0:
		return 1.0
	return clampf(1.0 - guard_veil_cooldown_timer / GUARD_VEIL_COOLDOWN, 0.0, 1.0)


func get_current_kunai_element() -> String:
	var available := _available_kunai_elements()
	if available.is_empty():
		return ""
	current_kunai_element = clampi(current_kunai_element, 0, available.size() - 1)
	return available[current_kunai_element]


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var available := _available_kunai_elements()
		if available.is_empty():
			return
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			current_kunai_element = (current_kunai_element + 1) % available.size()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			current_kunai_element = wrapi(current_kunai_element - 1, 0, available.size())


func _available_kunai_elements() -> Array[String]:
	var available: Array[String] = []
	if GameState.has_ability(GameState.ABILITY_WIND_KUNAI):
		available.append("wind")
	if GameState.has_ability(GameState.ABILITY_FIRE_KUNAI):
		available.append("fire")
	if GameState.has_ability(GameState.ABILITY_ELECTRIC_KUNAI):
		available.append("electric")
	return available


func _start_grapple() -> void:
	if not GameState.has_ability(GameState.ABILITY_TETHER):
		return
	var best_anchor: Node2D = null
	var best_score := INF
	var aim_point := get_global_mouse_position()
	for anchor in get_tree().get_nodes_in_group("grapple_anchor"):
		if anchor is Node2D:
			var player_distance := global_position.distance_to(anchor.global_position)
			if player_distance > GRAPPLE_RANGE:
				continue
			if anchor.global_position.y > global_position.y + GRAPPLE_BELOW_ALLOWANCE:
				continue
			var cursor_distance := aim_point.distance_to(anchor.global_position)
			var forward_penalty := 0.0
			if signf(anchor.global_position.x - global_position.x) != float(facing_dir):
				forward_penalty = 70.0
			var score := cursor_distance * 0.7 + player_distance * 0.3 + forward_penalty
			if score < best_score:
				best_anchor = anchor
				best_score = score
	if best_anchor == null:
		return
	grapple_anchor = best_anchor
	grapple_active = true
	grapple_point = best_anchor.global_position
	grapple_length = maxf(GRAPPLE_MIN_LENGTH, global_position.distance_to(grapple_point))
	queue_redraw()


func _apply_grapple_constraint() -> void:
	if not grapple_active:
		return
	if not is_instance_valid(grapple_anchor):
		grapple_active = false
		grapple_anchor = null
		return
	grapple_point = grapple_anchor.global_position
	var offset := global_position - grapple_point
	var distance := offset.length()
	if distance <= grapple_length or distance <= 0.001:
		return
	var rope_direction := offset / distance
	global_position = grapple_point + rope_direction * grapple_length
	var outward_speed := velocity.dot(rope_direction)
	if outward_speed > 0.0:
		velocity -= rope_direction * outward_speed
	velocity = velocity.limit_length(GRAPPLE_MAX_SPEED)


func _apply_grapple_pump(input_dir: float, delta: float) -> void:
	if absf(input_dir) < 0.01:
		return
	var rope_direction := (global_position - grapple_point).normalized()
	var tangent := Vector2(-rope_direction.y, rope_direction.x)
	if tangent.x * input_dir < 0.0:
		tangent = -tangent
	velocity += tangent * GRAPPLE_PUMP_ACCEL * delta
	velocity = velocity.limit_length(GRAPPLE_MAX_SPEED)


func _spawn_afterimage() -> void:
	if sprite == null or not sprite.visible:
		return
	var ghost := sprite.duplicate() as AnimatedSprite2D
	ghost.global_position = sprite.global_position
	ghost.global_rotation = sprite.global_rotation
	ghost.scale = sprite.global_scale
	ghost.modulate = Color(0.35, 0.92, 1.0, 0.42)
	ghost.z_index = z_index - 1
	get_tree().current_scene.add_child(ghost)
	var tween := ghost.create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, 0.18)
	tween.finished.connect(ghost.queue_free)


func _throw_kunai() -> void:
	if not _can_throw_current_kunai():
		return
	kunai_cooldown_timer = KUNAI_COOLDOWN
	var projectile := Area2D.new()
	projectile.set_script(preload("res://scripts/player/kunai_projectile.gd"))
	projectile.set("direction", Vector2(facing_dir, 0.0))
	projectile.set("element", get_current_kunai_element())
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = global_position + Vector2(facing_dir * 34.0, -8.0)


func _can_throw_current_kunai() -> bool:
	return not _available_kunai_elements().is_empty()


func _begin_dash() -> void:
	if not GameState.has_ability(GameState.ABILITY_DASH):
		return
	var incoming_speed_in_dash_direction := velocity.x * float(facing_dir)
	dash_velocity_x = float(facing_dir) * maxf(DASH_SPEED, incoming_speed_in_dash_direction)
	velocity.x = dash_velocity_x
	is_dashing = true
	dash_timer = DASH_DURATION
	dash_buffer_timer = 0.0


func _end_dash() -> void:
	is_dashing = false
	dash_cooldown_timer = DASH_COOLDOWN


func _draw() -> void:
	if not grapple_active:
		return
	var local_anchor := to_local(grapple_point)
	var tether_points := PackedVector2Array()
	for point_index in range(13):
		var ratio := float(point_index) / 12.0
		var point := Vector2.ZERO.lerp(local_anchor, ratio)
		var normal := local_anchor.normalized().orthogonal()
		point += normal * sin(ratio * PI + tether_visual_time * 8.0) * 5.0 * sin(ratio * PI)
		tether_points.append(point)
	draw_polyline(tether_points, Color(0.10, 0.55, 0.82, 0.42), 7.0, true)
	draw_polyline(tether_points, Color(0.68, 0.98, 1.0, 0.96), 2.4, true)
	for pulse_index in range(3):
		var pulse_ratio := fposmod(tether_visual_time * 1.8 + pulse_index / 3.0, 1.0)
		var segment := mini(int(pulse_ratio * 12.0), 11)
		var segment_ratio := pulse_ratio * 12.0 - segment
		var pulse_point := tether_points[segment].lerp(tether_points[segment + 1], segment_ratio)
		draw_circle(pulse_point, 3.5, Color(0.86, 1.0, 1.0, 0.9))
	draw_circle(local_anchor, 10.0, Color(0.14, 0.72, 0.92, 0.38))
	draw_circle(local_anchor, 5.0, Color(0.86, 1.0, 1.0, 0.98))


func _configure_sprite_frames() -> void:
	if sprite == null:
		return
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	_add_strip_animation(frames, &"idle", IDLE_TEXTURE, 8, Vector2i(128, 160), 8.0, true)
	_add_strip_animation(frames, &"run", RUN_TEXTURE, 12, Vector2i(128, 160), 14.0, true)
	_add_strip_animation(frames, &"jump", JUMP_TEXTURE, 6, Vector2i(128, 160), 12.0, false)
	_add_strip_animation(frames, &"fall", FALL_TEXTURE, 3, Vector2i(128, 160), 10.0, true)
	_add_strip_animation(frames, &"dash", DASH_TEXTURE, 5, Vector2i(128, 160), 24.0, true)
	_add_strip_animation(frames, &"wall", WALL_TEXTURE, 2, Vector2i(128, 160), 8.0, true)
	_add_strip_animation(frames, &"attack", ATTACK_TEXTURE, 4, Vector2i(209, 178), 18.0, false)
	sprite.sprite_frames = frames
	sprite.play(&"idle")


func _add_strip_animation(frames: SpriteFrames, animation: StringName, texture: Texture2D, count: int, frame_size: Vector2i, fps: float, looped: bool) -> void:
	frames.add_animation(animation)
	frames.set_animation_speed(animation, fps)
	frames.set_animation_loop(animation, looped)
	for frame_index in count:
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(frame_index * frame_size.x, 0, frame_size.x, frame_size.y)
		frames.add_frame(animation, atlas)


func _update_animation() -> void:
	if sprite == null:
		return
	var next_animation := &"idle"
	if is_attacking:
		next_animation = &"attack"
	elif is_dashing:
		next_animation = &"dash"
	elif is_touching_wall != 0 and velocity.y > 0.0:
		next_animation = &"wall"
	elif not is_on_floor():
		next_animation = &"jump" if velocity.y < 0.0 else &"fall"
	elif absf(velocity.x) > 35.0:
		next_animation = &"run"
	if sprite.animation != next_animation:
		sprite.play(next_animation)
