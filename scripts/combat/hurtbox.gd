extends Area2D
class_name Hurtbox

## Hurtbox - damage receiver component
## Detects hitboxes and forwards damage to a Health node.

signal hit_received(damage: float, knockback: Vector2, hitbox: Area2D)

@export var health_component: NodePath
@export var knockback_multiplier: float = 1.0
@export var invincibility_duration: float = 0.0
@export var hit_pause_duration: float = 0.04
@export var hit_pause_scale: float = 0.05
@export var heavy_hit_threshold: float = 18.0
@export var screen_shake_duration: float = 0.08
@export var screen_shake_strength: float = 6.0

var invincibility_timer: float = 0.0
var health: Node = null
var _hit_pause_active: bool = false


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

	_apply_hit_feedback(owner_node, damage)


func is_invincible() -> bool:
	return invincibility_timer > 0.0


func _apply_hit_feedback(attacker: Node, damage: float) -> void:
	if attacker == null or not attacker.is_in_group("player"):
		return

	_trigger_hit_pause()
	if damage >= heavy_hit_threshold:
		var camera := get_viewport().get_camera_2d()
		if camera and camera.has_method("shake"):
			camera.call("shake", screen_shake_duration, screen_shake_strength)


func _trigger_hit_pause() -> void:
	if _hit_pause_active or hit_pause_duration <= 0.0:
		return

	_hit_pause_active = true
	var previous_time_scale := Engine.time_scale
	Engine.time_scale = clampf(hit_pause_scale, 0.01, 1.0)
	await get_tree().create_timer(hit_pause_duration, true, true).timeout
	Engine.time_scale = previous_time_scale
	_hit_pause_active = false
