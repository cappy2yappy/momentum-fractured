extends CharacterBody2D
class_name Drone

## Flying ranged enemy.
## Patrols in air, shoots at player, retreats if the player gets too close.

enum State { IDLE, PATROL, ALERT, SHOOT, RETREAT, DEAD }

@export var detection_range: float = 250.0
@export var retreat_distance: float = 80.0
@export var patrol_distance: float = 140.0
@export var move_speed: float = 100.0
@export var retreat_speed: float = 150.0
@export var shoot_cooldown: float = 2.0
@export var shoot_windup: float = 0.24
@export var hover_amplitude: float = 12.0
@export var hover_speed: float = 2.2
@export var projectile_scene: PackedScene = preload("res://scenes/enemies/drone_projectile.tscn")
@export var cell_pickup_scene: PackedScene = preload("res://scenes/pickups/cell_pickup.tscn")

var state: State = State.PATROL
var _player: Node2D = null
var _search_timer: float = 0.0
var _shoot_cooldown_timer: float = 0.0
var _shoot_timer: float = 0.0
var _hover_time: float = 0.0
var _patrol_dir: int = 1
var _base_position: Vector2
var _is_dying: bool = false

@onready var hurtbox: Area2D = $Hurtbox
@onready var health = $Health
@onready var muzzle: Marker2D = $Muzzle
@onready var body_rect: ColorRect = $ColorRect

const SEARCH_INTERVAL := 0.2


func _ready() -> void:
	_base_position = global_position

	var on_hit := Callable(self, "_on_hit")
	if hurtbox and hurtbox.has_signal("hit_received") and not hurtbox.is_connected("hit_received", on_hit):
		hurtbox.connect("hit_received", on_hit)

	var on_death := Callable(self, "_on_death")
	if health and health.has_signal("died") and not health.is_connected("died", on_death):
		health.connect("died", on_death)


func _physics_process(delta: float) -> void:
	if _is_dying:
		return

	_search_timer = maxf(0.0, _search_timer - delta)
	_shoot_cooldown_timer = maxf(0.0, _shoot_cooldown_timer - delta)
	_hover_time += delta * hover_speed
	_acquire_player_if_needed()

	match state:
		State.IDLE:
			velocity = Vector2.ZERO
			if _player_in_range():
				state = State.ALERT
			else:
				state = State.PATROL
		State.PATROL:
			_state_patrol(delta)
		State.ALERT:
			_state_alert(delta)
		State.SHOOT:
			_state_shoot(delta)
		State.RETREAT:
			_state_retreat(delta)
		State.DEAD:
			velocity = Vector2.ZERO

	move_and_slide()


func _state_patrol(delta: float) -> void:
	if _player_in_range():
		state = State.ALERT
		return

	var patrol_target_x := _base_position.x + float(_patrol_dir) * patrol_distance
	var x_delta := patrol_target_x - global_position.x
	if absf(x_delta) < 8.0:
		_patrol_dir *= -1

	velocity.x = sign(x_delta) * move_speed
	global_position.y = lerpf(global_position.y, _hover_target_y(), clampf(delta * 4.0, 0.0, 1.0))


func _state_alert(delta: float) -> void:
	if not _has_valid_player():
		state = State.PATROL
		return

	var distance := global_position.distance_to(_player.global_position)
	if distance > detection_range * 1.3:
		state = State.PATROL
		return

	if distance <= retreat_distance:
		state = State.RETREAT
		return

	if _shoot_cooldown_timer <= 0.0:
		state = State.SHOOT
		_shoot_timer = shoot_windup
		velocity = Vector2.ZERO
		return

	var direction_to_player := (_player.global_position - global_position).normalized()
	velocity.x = direction_to_player.x * move_speed * 0.55
	global_position.y = lerpf(global_position.y, _hover_target_y(), clampf(delta * 4.0, 0.0, 1.0))


func _state_shoot(delta: float) -> void:
	if not _has_valid_player():
		state = State.PATROL
		return

	velocity = Vector2.ZERO
	_shoot_timer = maxf(0.0, _shoot_timer - delta)
	if _shoot_timer > 0.0:
		return

	_fire_projectile()
	_shoot_cooldown_timer = shoot_cooldown
	state = State.ALERT


func _state_retreat(delta: float) -> void:
	if not _has_valid_player():
		state = State.PATROL
		return

	var from_player := (global_position - _player.global_position).normalized()
	velocity.x = from_player.x * retreat_speed
	global_position.y = lerpf(global_position.y, _hover_target_y(), clampf(delta * 4.0, 0.0, 1.0))

	if global_position.distance_to(_player.global_position) > retreat_distance * 1.4:
		state = State.ALERT


func _fire_projectile() -> void:
	if not _has_valid_player() or projectile_scene == null:
		return

	var projectile := projectile_scene.instantiate()
	if projectile == null:
		return

	var spawn_position := muzzle.global_position if muzzle else global_position
	projectile.global_position = spawn_position
	projectile.direction = (_player.global_position - spawn_position).normalized()
	get_tree().current_scene.add_child(projectile)


func _on_hit(_damage: float, knockback: Vector2, _hitbox_node: Area2D) -> void:
	velocity = knockback * 0.12
	if body_rect:
		body_rect.color = Color(1.0, 1.0, 1.0, 1.0)
		var tween := create_tween()
		tween.tween_property(body_rect, "color", Color(0.42, 0.26, 0.92, 1.0), 0.12)


func _on_death() -> void:
	if _is_dying:
		return

	_is_dying = true
	AudioManager.play_sfx("enemy_death")
	state = State.DEAD
	collision_layer = 0
	collision_mask = 0
	hurtbox.monitoring = false

	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.26)
	await tween.finished
	queue_free()


func _acquire_player_if_needed() -> void:
	if _has_valid_player() and _search_timer > 0.0:
		return

	_search_timer = SEARCH_INTERVAL
	_player = null
	for candidate in get_tree().get_nodes_in_group("player"):
		if candidate is Node2D:
			_player = candidate
			return


func _has_valid_player() -> bool:
	if _player == null or not is_instance_valid(_player):
		return false
	return not bool(_player.get("is_dead"))


func _player_in_range() -> bool:
	return _has_valid_player() and global_position.distance_to(_player.global_position) <= detection_range


func _hover_target_y() -> float:
	return _base_position.y + sin(_hover_time) * hover_amplitude


func spawn_cell_drop(total_cells: int) -> void:
	if total_cells <= 0 or cell_pickup_scene == null:
		return

	var pickup = cell_pickup_scene.instantiate()
	if pickup == null:
		return

	pickup.amount = total_cells
	pickup.global_position = global_position + Vector2(0.0, -18.0)
	get_tree().current_scene.add_child(pickup)
