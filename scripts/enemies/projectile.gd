extends Area2D

## Enemy projectile - straight-line shot with timed despawn.

@export var speed: float = 300.0
@export var damage: float = 5.0
@export var lifetime: float = 3.0

var direction: Vector2 = Vector2.RIGHT
var _active: bool = false
var _life_timer: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	deactivate_projectile()


func _physics_process(delta: float) -> void:
	if not _active:
		return

	global_position += direction * speed * delta
	_life_timer -= delta
	if _life_timer <= 0.0:
		_recycle()


func activate_projectile(spawn_position: Vector2, move_direction: Vector2, new_speed: float, new_damage: float, new_lifetime: float) -> void:
	global_position = spawn_position
	direction = move_direction.normalized()
	speed = new_speed
	damage = new_damage
	lifetime = new_lifetime
	_life_timer = lifetime
	_active = true
	visible = true
	monitoring = true
	add_to_group("enemy_projectile")
	set_physics_process(true)


func deactivate_projectile() -> void:
	_active = false
	visible = false
	monitoring = false
	remove_from_group("enemy_projectile")
	set_physics_process(false)


func _on_body_entered(body: Node2D) -> void:
	if not _active:
		return

	if body.is_in_group("player") and body.has_method("take_damage"):
		body.call("take_damage", damage)
	_recycle()


func _recycle() -> void:
	var projectile_pool := _projectile_pool()
	if projectile_pool:
		projectile_pool.recycle_projectile(self)
	else:
		queue_free()


func _projectile_pool() -> Node:
	if not is_inside_tree():
		return null
	var tree := get_tree()
	return tree.root.get_node_or_null("ProjectilePool") if tree else null
