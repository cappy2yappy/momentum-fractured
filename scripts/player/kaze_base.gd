extends CharacterBody2D

# ============================================================
# MOMENTUM: FRACTURED — Core Player Movement
# Physics-only foundation for combat prototype
# Stripped: grapple, combo system, level-specific code
# ============================================================

# PHYSICS CONSTANTS
const GRAVITY := 1980.0
const HOLD_JUMP_GRAVITY_MULT := 0.28
const FALL_GRAVITY_MULT := 1.8
const JUMP_RELEASE_GRAVITY_MULT := 2.2
const APEX_GRAVITY_MULT := 0.25
const APEX_VELOCITY_THRESHOLD := 120.0
const MAX_FALL_SPEED := 900.0
const MAX_MOVE_SPEED := 420.0
const MOVE_ACCEL := 42.0
const AIR_ACCEL := 30.0
const GROUND_FRICTION := 0.70
const AIR_FRICTION := 0.97

# JUMP
const JUMP_IMPULSE := -630.0
const JUMP_MIN_VELOCITY := -780.0
const MAX_UPWARD_SPEED := -1080.0
const WALL_JUMP_IMPULSE_Y := -600.0
const WALL_JUMP_FORCE_X := 510.0
const WALL_SLIDE_SPEED := 60.0

# DASH
const DASH_SPEED := 1600.0
const DASH_DURATION := 0.12
const MAX_AIR_DASHES := 1
const DASH_COOLDOWN := 0.2

# FORGIVENESS
const COYOTE_TIME := 0.2
const JUMP_BUFFER_TIME := 0.2

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
var is_dead := false
var _was_on_floor := false

# SIGNALS
signal died

func _ready() -> void:
	_was_on_floor = is_on_floor()

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	# TIMERS
	coyote_timer = max(0.0, coyote_timer - delta)
	jump_buffer_timer = max(0.0, jump_buffer_timer - delta)
	dash_buffer_timer = max(0.0, dash_buffer_timer - delta)
	dash_cooldown_timer = max(0.0, dash_cooldown_timer - delta)
	
	# DASH
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			velocity.x = facing_dir * MAX_MOVE_SPEED
			dash_cooldown_timer = DASH_COOLDOWN
		else:
			velocity.x = DASH_SPEED * facing_dir
			velocity.y = 0
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
	
	if input_dir != 0:
		var accel = MOVE_ACCEL if is_on_floor() else AIR_ACCEL
		velocity.x = clamp(velocity.x + input_dir * accel, -MAX_MOVE_SPEED, MAX_MOVE_SPEED)
	else:
		var friction = GROUND_FRICTION if is_on_floor() else AIR_FRICTION
		velocity.x *= friction
		if abs(velocity.x) < 10:
			velocity.x = 0
	
	# COYOTE TIME
	var on_floor_now := is_on_floor()
	if on_floor_now:
		coyote_timer = COYOTE_TIME
		dash_count = MAX_AIR_DASHES
	_was_on_floor = on_floor_now
	
	# JUMP BUFFER
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	
	# DASH BUFFER
	if Input.is_action_just_pressed("dash"):
		dash_buffer_timer = JUMP_BUFFER_TIME
	
	# JUMP EXECUTION
	if jump_buffer_timer > 0:
		if coyote_timer > 0:
			# Ground jump
			velocity.y += JUMP_IMPULSE
			if velocity.y < MAX_UPWARD_SPEED:
				velocity.y = MAX_UPWARD_SPEED
			if velocity.y > JUMP_MIN_VELOCITY:
				velocity.y = JUMP_MIN_VELOCITY
			coyote_timer = 0
			jump_buffer_timer = 0
		elif is_touching_wall != 0:
			# Wall jump
			velocity.y += WALL_JUMP_IMPULSE_Y
			if velocity.y < MAX_UPWARD_SPEED:
				velocity.y = MAX_UPWARD_SPEED
			velocity.x = WALL_JUMP_FORCE_X * -is_touching_wall
			facing_dir = -is_touching_wall
			is_touching_wall = 0
			jump_buffer_timer = 0
	
	# DASH EXECUTION
	if dash_buffer_timer > 0 and dash_cooldown_timer <= 0:
		if is_on_floor() or dash_count > 0:
			if not is_on_floor():
				dash_count -= 1
			is_dashing = true
			dash_timer = DASH_DURATION
			dash_buffer_timer = 0
			velocity.y = 0
			velocity.x = DASH_SPEED * facing_dir
	
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
	
	velocity.y += GRAVITY * gravity_mult * delta
	
	# WALL SLIDE
	if is_touching_wall != 0 and velocity.y > 0 and not is_on_floor():
		velocity.y = min(velocity.y, WALL_SLIDE_SPEED)
	
	# MAX FALL SPEED
	velocity.y = min(velocity.y, MAX_FALL_SPEED)
	
	# MOVE
	move_and_slide()
	_check_wall_touch()

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
	dash_count = MAX_AIR_DASHES
	coyote_timer = 0
	jump_buffer_timer = 0
	dash_cooldown_timer = 0
	_was_on_floor = false

func get_dash_cooldown_ratio() -> float:
	if DASH_COOLDOWN <= 0.0:
		return 1.0
	return clampf(1.0 - dash_cooldown_timer / DASH_COOLDOWN, 0.0, 1.0)
