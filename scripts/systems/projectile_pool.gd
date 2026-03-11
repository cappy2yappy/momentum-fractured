extends Node

## Shared projectile pool to reduce allocations and cap active projectile count.

const MAX_PROJECTILES := 20
const DRONE_PROJECTILE_SCENE := preload("res://scenes/enemies/drone_projectile.tscn")

var _available: Array[Area2D] = []
var _active_count: int = 0


func can_spawn_projectile() -> bool:
	return _active_count < MAX_PROJECTILES


func spawn_drone_projectile(parent: Node, position: Vector2, direction: Vector2, speed: float, damage: float, lifetime: float) -> Area2D:
	if not can_spawn_projectile() or parent == null:
		return null

	var projectile := _acquire_projectile()
	if projectile == null:
		return null

	if projectile.get_parent() != parent:
		if projectile.get_parent():
			projectile.get_parent().remove_child(projectile)
		parent.add_child(projectile)

	_active_count += 1
	projectile.call("activate_projectile", position, direction, speed, damage, lifetime)
	return projectile


func recycle_projectile(projectile: Area2D) -> void:
	if projectile == null or not is_instance_valid(projectile):
		return

	if projectile.get_parent():
		projectile.get_parent().remove_child(projectile)

	add_child(projectile)
	projectile.call("deactivate_projectile")
	_available.append(projectile)
	_active_count = max(0, _active_count - 1)


func _acquire_projectile() -> Area2D:
	if not _available.is_empty():
		return _available.pop_back()

	var projectile := DRONE_PROJECTILE_SCENE.instantiate()
	if projectile == null:
		return null

	projectile.call("deactivate_projectile")
	add_child(projectile)
	return projectile
