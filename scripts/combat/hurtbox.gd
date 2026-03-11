extends Area2D
class_name Hurtbox

## Hurtbox - damage receiver component
## Detects hitboxes and forwards damage to a Health node.

signal hit_received(damage: float, knockback: Vector2, hitbox: Area2D)

@export var health_component: NodePath
@export var knockback_multiplier: float = 1.0
@export var invincibility_duration: float = 0.0
@export var hit_pause_duration: float = 0.05
@export var heavy_hit_threshold: float = 20.0
@export var player_damage_shake_duration: float = 0.2
@export var player_damage_shake_strength: float = 5.0
@export var heavy_hit_shake_duration: float = 0.1
@export var heavy_hit_shake_strength: float = 6.0

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

	_apply_hit_feedback(owner_node, damage, hitbox)


func is_invincible() -> bool:
	return invincibility_timer > 0.0


func _apply_hit_feedback(attacker: Node, damage: float, hitbox: Area2D) -> void:
	CombatFeedback.flash_target(owner)
	CombatFeedback.spawn_damage_number(_damage_number_position(), damage, damage >= heavy_hit_threshold)

	if attacker and attacker.is_in_group("player"):
		GameState.register_combo_hit()
		var is_final_combo_hit := bool(hitbox.get_meta("is_final_combo_hit", false))
		if damage >= heavy_hit_threshold and is_final_combo_hit:
			CombatFeedback.hit_pause(hit_pause_duration)
			var camera := get_viewport().get_camera_2d()
			if camera and camera.has_method("shake"):
				camera.call("shake", heavy_hit_shake_duration, heavy_hit_shake_strength)
		return

	if owner and owner.is_in_group("player"):
		GameState.reset_combo()
		var camera := get_viewport().get_camera_2d()
		if camera and camera.has_method("shake"):
			camera.call("shake", player_damage_shake_duration, player_damage_shake_strength)


func _damage_number_position() -> Vector2:
	if owner and owner is Node2D:
		return (owner as Node2D).global_position
	if get_parent() and get_parent() is Node2D:
		return (get_parent() as Node2D).global_position
	return global_position
