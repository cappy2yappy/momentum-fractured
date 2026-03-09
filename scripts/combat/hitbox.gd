extends Area2D
class_name Hitbox

## Hitbox - damage dealer component
## Deals damage to hurtboxes on contact

@export var damage: float = 10.0
@export var knockback: Vector2 = Vector2.ZERO
@export var single_hit: bool = true
@export var auto_disable_time: float = 0.3
@export var is_active: bool = false

var owner_node: Node = null
var auto_disable_timer: float = 0.0
var hit_targets: Array = []

func _ready():
	owner_node = owner
	monitoring = is_active

func _process(delta):
	if is_active and auto_disable_time > 0:
		auto_disable_timer -= delta
		if auto_disable_timer <= 0:
			deactivate()

func activate():
	if is_active:
		return
	
	is_active = true
	monitoring = true
	auto_disable_timer = auto_disable_time
	hit_targets.clear()

func deactivate():
	if not is_active:
		return
	
	is_active = false
	monitoring = false
	hit_targets.clear()

func set_knockback_direction(direction: Vector2, force: float = 0.0):
	if force > 0:
		knockback = direction.normalized() * force
	else:
		knockback = direction

func has_hit(target: Node) -> bool:
	return target in hit_targets

func mark_hit(target: Node):
	if target not in hit_targets:
		hit_targets.append(target)
