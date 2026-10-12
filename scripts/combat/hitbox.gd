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
	set_deferred("monitoring", is_active)

func _process(delta):
	if is_active and auto_disable_time > 0:
		auto_disable_timer -= delta
		if auto_disable_timer <= 0:
			deactivate()

func _physics_process(_delta: float) -> void:
	if not is_active:
		return
	# A combo can restart while targets remain overlapped; entry signals alone
	# would miss that new window. Hurtbox enforces one hit per target/window.
	for area in get_overlapping_areas():
		if not is_active:
			break
		if area.has_method("_take_hit"):
			area.call("_take_hit", self)

func activate(duration: float = -1.0, restart: bool = false) -> void:
	if is_active and not restart:
		return

	# A restarted window is a new attack, so previously hit targets must not
	# leak into the next combo step.
	if restart:
		set_deferred("monitoring", false)
	is_active = true
	set_deferred("monitoring", true)
	auto_disable_timer = duration if duration >= 0.0 else auto_disable_time
	hit_targets.clear()

func deactivate():
	if not is_active:
		return
	
	is_active = false
	set_deferred("monitoring", false)
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
