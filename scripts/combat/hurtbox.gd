extends Area2D
class_name Hurtbox

## Hurtbox - damage receiver component
## Detects hitboxes and takes damage

signal hit_received(damage: float, knockback: Vector2, hitbox: Hitbox)

@export var health_component: NodePath
@export var knockback_multiplier: float = 1.0
@export var invincibility_duration: float = 0.0

var invincibility_timer: float = 0.0
var health: Health = null

func _ready():
	# Connect to hitboxes
	area_entered.connect(_on_area_entered)
	
	# Get health component
	if not health_component.is_empty():
		health = get_node_or_null(health_component)

func _process(delta):
	if invincibility_timer > 0:
		invincibility_timer -= delta

func _on_area_entered(area: Area2D):
	if area is Hitbox:
		_take_hit(area)

func _take_hit(hitbox: Hitbox):
	# Skip if invincible
	if invincibility_timer > 0:
		return
	
	# Skip if hitbox is disabled or from same owner
	if not hitbox.is_active:
		return
	
	if hitbox.owner_node and owner == hitbox.owner_node:
		return
	
	# Calculate knockback
	var knockback = hitbox.knockback * knockback_multiplier
	
	# Apply damage to health component if available
	if health:
		health.take_damage(hitbox.damage)
	
	# Emit signal
	emit_signal("hit_received", hitbox.damage, knockback, hitbox)
	
	# Start invincibility
	if invincibility_duration > 0:
		invincibility_timer = invincibility_duration
	
	# Disable hitbox if it's single-hit
	if hitbox.single_hit:
		hitbox.deactivate()

func is_invincible() -> bool:
	return invincibility_timer > 0
