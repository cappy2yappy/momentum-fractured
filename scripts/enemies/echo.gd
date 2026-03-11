extends CharacterBody2D
class_name Echo

# Basic humanoid enemy with patrol/chase/attack loop.
# Designed for early-room combat readability.

enum State { IDLE, PATROL, ALERT, CHARGE, ATTACK, HITSTUN, DEAD }

@export var patrol_points: Array[Vector2] = []
@export var patrol_wait_duration: float = 1.0
@export var detection_range: float = 240.0
@export var attack_range: float = 48.0
@export var move_speed: float = 95.0
@export var move_accel: float = 480.0
@export var charge_speed: float = 180.0
@export var charge_accel: float = 640.0
@export var alert_duration: float = 0.2
@export var attack_damage: float = 10.0
@export var attack_knockback: float = 300.0
@export var attack_duration: float = 0.28
@export var attack_hitbox_start: float = 0.12
@export var attack_hitbox_duration: float = 0.1
@export var attack_cooldown: float = 0.8
@export var hitstun_duration: float = 0.3
@export var cell_pickup_scene: PackedScene = preload("res://scenes/pickups/cell_pickup.tscn")
@export var ai_sleep_distance: float = 960.0

var state: State = State.PATROL
var current_patrol_index: int = 0
var _player_search_timer: float = 0.0
var _alert_timer: float = 0.0
var _attack_timer: float = 0.0
var _attack_cooldown_timer: float = 0.0
var _hitstun_timer: float = 0.0
var _patrol_wait_timer: float = 0.0
var _is_dying: bool = false

var _player: Node2D = null

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var hurtbox: Area2D = $Hurtbox
@onready var health = $Health
@onready var body_rect: ColorRect = $ColorRect

const GRAVITY := 1980.0
const PLAYER_SEARCH_INTERVAL := 0.25


func _ready() -> void:
	if patrol_points.is_empty():
		patrol_points = [global_position - Vector2(90, 0), global_position + Vector2(90, 0)]

	var on_hit := Callable(self, "_on_hit")
	if hurtbox and hurtbox.has_signal("hit_received") and not hurtbox.is_connected("hit_received", on_hit):
		hurtbox.connect("hit_received", on_hit)

	var on_death := Callable(self, "_on_death")
	if health and health.has_signal("died") and not health.is_connected("died", on_death):
		health.connect("died", on_death)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	_player_search_timer = maxf(0.0, _player_search_timer - delta)
	_attack_cooldown_timer = maxf(0.0, _attack_cooldown_timer - delta)
	_acquire_player_if_needed()

	if _has_valid_player() and global_position.distance_to(_player.global_position) > ai_sleep_distance:
		state = State.PATROL
		velocity.x = move_toward(velocity.x, 0.0, move_accel * delta)
		move_and_slide()
		return

	match state:
		State.IDLE:
			_state_idle()
		State.PATROL:
			_state_patrol(delta)
		State.ALERT:
			_state_alert(delta)
		State.CHARGE:
			_state_charge(delta)
		State.ATTACK:
			_state_attack(delta)
		State.HITSTUN:
			_state_hitstun(delta)
		State.DEAD:
			_state_dead()

	move_and_slide()


func _state_idle() -> void:
	velocity.x = move_toward(velocity.x, 0.0, move_accel * get_physics_process_delta_time())
	if _is_player_in_detection_range():
		_enter_alert_state()


func _state_patrol(delta: float) -> void:
	if _is_player_in_detection_range():
		_enter_alert_state()
		return

	if patrol_points.is_empty():
		velocity.x = move_toward(velocity.x, 0.0, move_accel * delta)
		return

	if _patrol_wait_timer > 0.0:
		_patrol_wait_timer = maxf(0.0, _patrol_wait_timer - delta)
		velocity.x = move_toward(velocity.x, 0.0, move_accel * delta)
		return

	var target: Vector2 = patrol_points[current_patrol_index]
	var x_delta: float = target.x - global_position.x
	var dir: float = sign(x_delta)

	if absf(x_delta) < 8.0:
		current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
		_patrol_wait_timer = patrol_wait_duration
		velocity.x = move_toward(velocity.x, 0.0, move_accel * delta)
	else:
		velocity.x = move_toward(velocity.x, dir * move_speed, move_accel * delta)

	if sprite and dir != 0.0:
		sprite.flip_h = dir < 0.0


func _state_alert(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, move_accel * delta)
	if not _has_valid_player():
		state = State.PATROL
		return

	var direction_to_player: float = sign(_player.global_position.x - global_position.x)
	if sprite and direction_to_player != 0.0:
		sprite.flip_h = direction_to_player < 0.0

	_alert_timer = maxf(0.0, _alert_timer - delta)
	if _alert_timer <= 0.0:
		state = State.CHARGE


func _state_charge(delta: float) -> void:
	if not _has_valid_player():
		state = State.PATROL
		return

	var delta_x: float = _player.global_position.x - global_position.x
	var abs_delta_x: float = absf(delta_x)
	if abs_delta_x > detection_range * 1.8:
		state = State.PATROL
		return

	var direction: float = sign(delta_x)
	if direction == 0.0:
		direction = -1.0 if sprite.flip_h else 1.0

	if sprite:
		sprite.flip_h = direction < 0.0

	if abs_delta_x <= attack_range and _attack_cooldown_timer <= 0.0 and _is_player_in_front(direction):
		_start_attack(direction)
		return

	velocity.x = move_toward(velocity.x, direction * charge_speed, charge_accel * delta)


func _state_attack(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, charge_accel * delta)
	_attack_timer = maxf(0.0, _attack_timer - delta)
	if _attack_timer <= 0.0:
		state = State.CHARGE


func _state_hitstun(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, charge_accel * delta)
	_hitstun_timer = maxf(0.0, _hitstun_timer - delta)
	if _hitstun_timer > 0.0:
		return

	if health and health.is_dead:
		state = State.DEAD
	elif _is_player_in_detection_range():
		state = State.CHARGE
	else:
		state = State.PATROL


func _state_dead() -> void:
	velocity.x = move_toward(velocity.x, 0.0, charge_accel * get_physics_process_delta_time())


func _start_attack(direction: float) -> void:
	state = State.ATTACK
	_attack_timer = attack_duration
	_attack_cooldown_timer = attack_cooldown
	velocity.x = 0.0

	if hitbox and hitbox.has_method("set_knockback_direction"):
		hitbox.damage = attack_damage
		hitbox.set_knockback_direction(Vector2(direction, -0.1), attack_knockback)
		_enable_hitbox_timed(attack_hitbox_start, attack_hitbox_duration)


func _enable_hitbox_timed(delay_before: float, active_duration: float) -> void:
	await get_tree().create_timer(delay_before).timeout
	if hitbox and hitbox.has_method("activate") and state == State.ATTACK:
		hitbox.activate()
	await get_tree().create_timer(active_duration).timeout
	if hitbox and hitbox.has_method("deactivate"):
		hitbox.deactivate()


func _enter_alert_state() -> void:
	state = State.ALERT
	_alert_timer = alert_duration
	velocity.x = 0.0


func _on_hit(_damage: float, knockback: Vector2, _hitbox_node: Area2D) -> void:
	if _is_dying:
		return

	velocity = knockback
	_hitstun_timer = hitstun_duration
	if body_rect:
		body_rect.color = Color(1.0, 0.2, 0.2, 1.0)
		var tween := create_tween()
		tween.tween_property(body_rect, "color", Color(1.0, 0.3, 0.3, 1.0), 0.12)

	if health and health.is_dead:
		state = State.DEAD
	else:
		state = State.HITSTUN


func _on_death() -> void:
	if _is_dying:
		return

	state = State.DEAD
	_is_dying = true
	AudioManager.play_sfx("enemy_death")
	velocity = Vector2.ZERO
	collision_layer = 0
	collision_mask = 0

	if hitbox and hitbox.has_method("deactivate"):
		hitbox.deactivate()
	if hurtbox:
		hurtbox.monitoring = false

	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished
	queue_free()


func spawn_cell_drop(total_cells: int) -> void:
	if total_cells <= 0 or cell_pickup_scene == null:
		return

	var pickup = cell_pickup_scene.instantiate()
	if pickup == null:
		return

	pickup.amount = total_cells
	pickup.global_position = global_position + Vector2(0.0, -24.0)
	get_tree().current_scene.add_child(pickup)


func _acquire_player_if_needed() -> void:
	if _has_valid_player() and _player_search_timer > 0.0:
		return

	_player_search_timer = PLAYER_SEARCH_INTERVAL
	_player = null
	for candidate in get_tree().get_nodes_in_group("player"):
		if candidate is Node2D:
			_player = candidate
			return


func _has_valid_player() -> bool:
	if _player == null or not is_instance_valid(_player):
		return false
	return not bool(_player.get("is_dead"))


func _is_player_in_detection_range() -> bool:
	if not _has_valid_player():
		return false

	return global_position.distance_to(_player.global_position) <= detection_range


func _is_player_in_front(direction_to_player: float) -> bool:
	if direction_to_player == 0.0:
		return true
	return not (sprite and sprite.flip_h and direction_to_player > 0.0) and not (sprite and not sprite.flip_h and direction_to_player < 0.0)
