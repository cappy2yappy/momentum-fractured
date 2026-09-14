extends CharacterBody2D
signal strike(damage, reach)
signal hurt
var facing = 1
var hp = 3
var double_jump = false
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
var sprite = Sprite2D.new()
var clips: Dictionary = {}
var animation_clock = 0.0
var last_clip = ""
func _ready():
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
	for clip in ["idle","run","jump","fall","attack","wall_slide"]:
		clips[clip] = load("res://assets/" + clip + "_strip.png")
func held(action): return Input.is_action_pressed(action) or touch.get(action,false)
func press(action):
	if action == "jump": jump_buffer = 0.16
	if action == "attack":
		if attack_time <= 0: start_attack(0)
		elif attack_time > 0.10: queued = true
	if action == "parry" and parry_cooldown <= 0 and attack_time <= 0:
		parry_time = 0.23
		parry_cooldown = 0.48
	if action in ["left","right"]:
		var dir = -1 if action == "left" else 1
		if last_dir == dir and age-last_tap < 0.25: run = true
		last_dir = dir
		last_tap = age
func start_attack(index):
	combo = index
	did_strike = false
	queued = false
	attack_time = [0.36,0.41,0.57][combo]
func _physics_process(dt):
	age += dt
	for action in ["left","right","jump","attack","parry"]:
		if Input.is_action_just_pressed(action): press(action)
	if hitstop > 0:
		hitstop -= dt
		return
	jump_buffer = maxf(0,jump_buffer-dt)
	invulnerable = maxf(0,invulnerable-dt)
	parry_time = maxf(0,parry_time-dt)
	parry_cooldown = maxf(0,parry_cooldown-dt)
	if is_on_floor():
		coyote = 0.12
		air_used = false
	else: coyote = maxf(0,coyote-dt)
	var direction = float(held("right"))-float(held("left"))
	if direction == 0: run = false
	if direction != 0: facing = int(direction)
	var speed = 600.0 if run else 400.0
	if attack_time > 0 and is_on_floor(): speed *= 0.5
	velocity.x = move_toward(velocity.x,direction*speed,2600*dt if is_on_floor() else 1200*dt)
	velocity.y += 1800*dt
	if is_on_wall() and direction != 0 and velocity.y > 100: velocity.y = 100
	if jump_buffer > 0:
		if coyote > 0:
			velocity.y = -900; coyote = 0; jump_buffer = 0
		elif is_on_wall():
			velocity = Vector2(get_wall_normal().x*480,-880); jump_buffer = 0
		elif double_jump and not air_used:
			velocity.y = -900; air_used = true; jump_buffer = 0
	if not held("jump") and velocity.y < -360: velocity.y = -360
	move_and_slide()
	if attack_time > 0:
		var total = [0.36,0.41,0.57][combo]
		attack_time -= dt
		if total-attack_time >= [0.105,0.12,0.20][combo] and not did_strike:
			did_strike = true
			strike.emit(2 if combo == 2 else 1,115 if combo == 2 else 95)
		if attack_time <= 0 and queued: start_attack((combo+1)%3)
	animate(dt)
	queue_redraw()
func animate(dt):
	var clip = "idle"
	if absf(velocity.x) > 40: clip = "run"
	if not is_on_floor(): clip = "jump" if velocity.y < 0 else "fall"
	if is_on_wall() and not is_on_floor(): clip = "wall_slide"
	if attack_time > 0: clip = "attack"
	if clip != last_clip: animation_clock = 0
	last_clip = clip
	animation_clock += dt
	var tex = clips[clip]
	# Legacy strips are temporary. Frame registration must be visually reviewed.
	sprite.texture = tex
	sprite.hframes = maxi(1,roundi(float(tex.get_width())/tex.get_height()))
	sprite.frame = int(animation_clock/(0.16 if clip == "idle" else 0.08))%sprite.hframes
	sprite.scale = Vector2.ONE*106.0/tex.get_height()
	sprite.flip_h = facing < 0
	sprite.position = Vector2(0,-53)
	sprite.modulate.a = 0.45 if invulnerable > 0 and int(age*18)%2 == 0 else 1.0
func damage(from: Vector2):
	if invulnerable > 0: return false
	hp -= 1
	invulnerable = 1.2
	velocity = Vector2(signf(position.x-from.x)*280,-240)
	hurt.emit()
	return true
func _draw():
	if parry_time > 0:
		draw_arc(Vector2(0,-48),54,-1.4 if facing > 0 else 1.74,1.4 if facing > 0 else 4.54,20,Color("c8f59c"),4)
	if attack_time > 0 and did_strike:
		draw_arc(Vector2(facing*24,-45),65,-1.1 if facing > 0 else 2.0,1.1 if facing > 0 else 4.3,20,Color(0.95,0.9,0.7,clampf(attack_time*3,0,0.8)),5)
