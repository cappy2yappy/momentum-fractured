extends CharacterBody2D
class_name Echo

# Basic humanoid enemy - tutorial/early game
# Behavior: Patrol between points, charge when player in range

enum State { IDLE, PATROL, ALERT, CHARGE, ATTACK, HITSTUN, DEAD }

@export var patrol_points: Array[Vector2] = []
@export var detection_range: float = 200.0
@export var attack_range: float = 40.0
@export var move_speed: float = 100.0
@export var charge_speed: float = 200.0

var state: State = State.PATROL
var current_patrol_index: int = 0
var hitstun_timer: float = 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var hurtbox: Area2D = $Hurtbox
@onready var health: Node = $Health

const GRAVITY = 1980.0

func _ready():
	# Default patrol if none set
	if patrol_points.is_empty():
		patrol_points = [global_position - Vector2(100, 0), global_position + Vector2(100, 0)]
	
	# Connect combat signals
	if hurtbox:
		hurtbox.hit_received.connect(_on_hit)
	
	if health:
		health.died.connect(_on_death)

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	# State machine
	match state:
		State.IDLE: _state_idle(delta)
		State.PATROL: _state_patrol(delta)
		State.ALERT: _state_alert(delta)
		State.CHARGE: _state_charge(delta)
		State.ATTACK: _state_attack(delta)
		State.HITSTUN: _state_hitstun(delta)
		State.DEAD: _state_dead(delta)
	
	move_and_slide()

func _state_idle(delta):
	velocity.x = 0
	# TODO: Check for player in range
	# For now, just patrol
	state = State.PATROL

func _state_patrol(delta):
	if patrol_points.is_empty():
		state = State.IDLE
		return
	
	var target = patrol_points[current_patrol_index]
	var dir = sign(target.x - global_position.x)
	
	if abs(target.x - global_position.x) < 10:
		# Reached patrol point, go to next
		current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
		velocity.x = 0
	else:
		velocity.x = dir * move_speed
	
	# Flip sprite
	if sprite and dir != 0:
		sprite.flip_h = dir < 0
	
	# TODO: Check for player in detection range → ALERT

func _state_alert(delta):
	velocity.x = 0
	# TODO: Turn to face player, then CHARGE
	state = State.CHARGE

func _state_charge(delta):
	# TODO: Move toward player
	# TODO: If in attack range → ATTACK
	# Placeholder: just charge in current direction
	velocity.x = charge_speed * (-1 if sprite.flip_h else 1)

func _state_attack(delta):
	velocity.x = 0
	# TODO: Play attack animation
	# TODO: Spawn hitbox
	# Return to CHARGE after attack
	await get_tree().create_timer(0.5).timeout
	state = State.CHARGE

func _state_hitstun(delta):
	velocity.x = 0
	hitstun_timer -= delta
	if hitstun_timer <= 0:
		state = State.CHARGE if health > 0 else State.DEAD

func _state_dead(delta):
	velocity.x = 0
	# TODO: Play death animation, then queue_free()
	queue_free()

func _on_hit(damage: float, knockback: Vector2, hitbox_node: Area2D):
	velocity = knockback
	hitstun_timer = 0.3
	if health and not health.is_dead:
		state = State.HITSTUN
	else:
		state = State.DEAD

func _on_death():
	state = State.DEAD
