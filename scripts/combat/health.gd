extends Node
class_name Health

## Health component - tracks HP and handles death
## Attach to any entity that can take damage

signal health_changed(old_value: float, new_value: float)
signal damage_taken(amount: float)
signal died

@export var max_health: float = 100.0
@export var current_health: float = max_health

var is_dead: bool = false

func _ready():
	current_health = max_health

func take_damage(amount: float) -> void:
	if is_dead or amount <= 0:
		return
	
	var old_health = current_health
	current_health = max(0, current_health - amount)
	
	emit_signal("health_changed", old_health, current_health)
	emit_signal("damage_taken", amount)
	
	if current_health <= 0:
		die()

func heal(amount: float) -> void:
	if is_dead or amount <= 0:
		return
	
	var old_health = current_health
	current_health = min(max_health, current_health + amount)
	
	emit_signal("health_changed", old_health, current_health)


func set_health_values(current: float, max_value: float) -> void:
	var old_health := current_health
	var old_max_health := max_health
	max_health = maxf(max_value, 1.0)
	current_health = clampf(current, 0.0, max_health)
	is_dead = current_health <= 0.0
	if not is_equal_approx(old_health, current_health) or not is_equal_approx(old_max_health, max_health):
		emit_signal("health_changed", old_health, current_health)

func die() -> void:
	if is_dead:
		return
	
	is_dead = true
	emit_signal("died")

func reset() -> void:
	is_dead = false
	current_health = max_health

func get_health_percent() -> float:
	if max_health <= 0:
		return 0.0
	return current_health / max_health
