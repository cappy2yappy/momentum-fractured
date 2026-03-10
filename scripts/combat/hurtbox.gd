extends Area2D
class_name Hurtbox

## Hurtbox - damage receiver component
## Detects hitboxes and forwards damage to a Health node.

signal hit_received(damage: float, knockback: Vector2, hitbox: Area2D)

@export var health_component: NodePath
@export var knockback_multiplier: float = 1.0
@export var invincibility_duration: float = 0.0

var invincibility_timer: float = 0.0
var health: Node = null


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	if not health_component.is_empty():
		health = get_node_or_null(health_component)


func _process(delta: float) -> void:
	if invincibility_timer > 0.0:
		invincibility_timer -= delta


func _on_area_entered(area: Area2D) -> void:
	if not area.has_method("deactivate"):
		return
	_take_hit(area)


func _take_hit(hitbox: Area2D) -> void:
	if invincibility_timer > 0.0:
		return
	if not bool(hitbox.get("is_active")):
		return

	var owner_node = hitbox.get("owner_node")
	if owner_node and owner == owner_node:
		return

	var damage := float(hitbox.get("damage"))
	var knockback: Vector2 = hitbox.get("knockback") * knockback_multiplier

	if health and health.has_method("take_damage"):
		health.call("take_damage", damage)

	emit_signal("hit_received", damage, knockback, hitbox)

	if invincibility_duration > 0.0:
		invincibility_timer = invincibility_duration

	if bool(hitbox.get("single_hit")) and hitbox.has_method("deactivate"):
		hitbox.call("deactivate")


func is_invincible() -> bool:
	return invincibility_timer > 0.0
