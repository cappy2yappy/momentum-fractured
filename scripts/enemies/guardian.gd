extends CharacterBody2D
class_name Guardian

## Guardian enemy: armored melee tank with directional shield blocking.
## Design goals from GDD:
## - Blocks frontal attacks while shield is raised
## - Vulnerable from behind
## - Becomes more aggressive below 50% HP (drops shield)

enum State { IDLE, APPROACH, WINDUP, ATTACK, COUNTER, HITSTUN, DEAD }

@export var detection_range: float = 360.0
@export var attack_range: float = 62.0
@export var move_speed: float = 95.0
@export var enraged_move_speed: float = 145.0
@export var attack_cooldown: float = 1.15
@export var heavy_windup_time: float = 0.42
@export var counter_windup_time: float = 0.16
@export var shield_bash_damage: float = 8.0
@export var heavy_slash_damage: float = 15.0
@export var counter_damage: float = 12.0
@export var shield_bash_knockback: float = 420.0
@export var heavy_slash_knockback: float = 560.0
@export var counter_knockback: float = 470.0
@export var hitstun_duration: float = 0.22
@export_range(30.0, 180.0, 1.0) var shield_block_angle_degrees: float = 120.0

const GRAVITY: float = 1980.0
const MOVE_ACCEL: float = 860.0
const BRAKE_FORCE: float = 1200.0

var state: State = State.IDLE
var facing_dir: int = -1
var is_enraged: bool = false
var shield_raised: bool = true
var attack_cooldown_timer: float = 0.0
var state_timer: float = 0.0
var _pending_counter: bool = false

var _attack_hit_time: float = 0.0
var _attack_hit_applied: bool = false
var _attack_damage: float = 0.0
var _attack_knockback: float = 0.0
var _attack_lunge_speed: float = 0.0

var _anim_timer: float = 0.0
var _player: Node2D = null

@onready var sprite: Sprite2D = $Sprite2D
@onready var hurtbox: Area2D = $Hurtbox
@onready var health: Health = $Health


func _ready() -> void:
	add_to_group("enemy")
	_player = _find_player()

	if hurtbox:
		var on_hit := Callable(self, "_on_hit")
		if hurtbox.has_signal("hit_received") and not hurtbox.is_connected("hit_received", on_hit):
			hurtbox.connect("hit_received", on_hit)

	if health:
		var on_death := Callable(self, "_on_death")
		if health.has_signal("died") and not health.is_connected("died", on_death):
			health.connect("died", on_death)

		var on_health_changed := Callable(self, "_on_health_changed")
		if health.has_signal("health_changed") and not health.is_connected("health_changed", on_health_changed):
			health.connect("health_changed", on_health_changed)

	_update_enrage_state()
	_change_state(State.APPROACH)


func _physics_process(delta: float) -> void:
	attack_cooldown_timer = maxf(0.0, attack_cooldown_timer - delta)

	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if not _has_valid_player():
		_player = _find_player()

	match state:
		State.IDLE:
			_state_idle(delta)
		State.APPROACH:
			_state_approach(delta)
		State.WINDUP:
			_state_windup(delta)
		State.ATTACK, State.COUNTER:
			_state_attack(delta)
		State.HITSTUN:
			_state_hitstun(delta)
		State.DEAD:
			_state_dead(delta)

	move_and_slide()
	_animate_sprite(delta)


func _state_idle(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, BRAKE_FORCE * delta)
	if _can_engage_player():
		_change_state(State.APPROACH)


func _state_approach(delta: float) -> void:
	if not _can_engage_player():
		_change_state(State.IDLE)
		return

	_face_player()
	var distance_x: float = absf(_player.global_position.x - global_position.x)

	if distance_x > attack_range * 0.9:
		velocity.x = move_toward(velocity.x, facing_dir * _get_move_speed(), MOVE_ACCEL * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, BRAKE_FORCE * delta)

	if _pending_counter and attack_cooldown_timer <= 0.0:
		_begin_windup(true)
		return

	if distance_x <= attack_range and attack_cooldown_timer <= 0.0:
		_begin_windup(false)


func _state_windup(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, BRAKE_FORCE * delta)
	_face_player()
	state_timer -= delta
	if state_timer <= 0.0:
		_start_attack(_pending_counter)


func _state_attack(delta: float) -> void:
	state_timer -= delta
	velocity.x = move_toward(velocity.x, facing_dir * _attack_lunge_speed, MOVE_ACCEL * delta)

	if not _attack_hit_applied and state_timer <= _attack_hit_time:
		_attack_hit_applied = true
		_try_hit_player(_attack_damage, _attack_knockback)

	if state_timer <= 0.0:
		velocity.x = 0.0
		if state == State.COUNTER:
			attack_cooldown_timer = 0.35
		else:
			var rage_mult := 0.65 if is_enraged else 1.0
			attack_cooldown_timer = attack_cooldown * rage_mult
		_change_state(State.APPROACH)


func _state_hitstun(delta: float) -> void:
	state_timer -= delta
	velocity.x = move_toward(velocity.x, 0.0, BRAKE_FORCE * delta)
	if state_timer <= 0.0:
		if _can_engage_player():
			_change_state(State.APPROACH)
		else:
			_change_state(State.IDLE)


func _state_dead(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, BRAKE_FORCE * delta)


func _begin_windup(counter: bool) -> void:
	_pending_counter = counter
	state_timer = counter_windup_time if counter else heavy_windup_time
	_change_state(State.WINDUP)


func _start_attack(counter: bool) -> void:
	_pending_counter = false
	_attack_hit_applied = false

	if counter:
		state_timer = 0.26
		_attack_damage = counter_damage
		_attack_knockback = counter_knockback
		_attack_lunge_speed = 260.0
		_attack_hit_time = state_timer * 0.5
		_change_state(State.COUNTER)
		return

	var use_shield_bash := _should_use_shield_bash()
	if use_shield_bash:
		state_timer = 0.24
		_attack_damage = shield_bash_damage
		_attack_knockback = shield_bash_knockback
		_attack_lunge_speed = 340.0
	else:
		state_timer = 0.36
		_attack_damage = heavy_slash_damage
		_attack_knockback = heavy_slash_knockback
		_attack_lunge_speed = 220.0

	_attack_hit_time = state_timer * 0.48
	_change_state(State.ATTACK)


func _should_use_shield_bash() -> bool:
	if is_enraged:
		return false
	if not _has_valid_player():
		return true

	var distance_x: float = absf(_player.global_position.x - global_position.x)
	return distance_x <= attack_range * 0.75


func _on_hit(damage: float, knockback: Vector2, hitbox_node: Area2D) -> void:
	if state == State.DEAD:
		return

	if _is_blocking_hit(hitbox_node):
		_on_successful_block()
		return

	if health:
		health.take_damage(damage)

	velocity = knockback * 0.72
	state_timer = hitstun_duration
	_change_state(State.HITSTUN)
	_update_enrage_state()


func _is_blocking_hit(hitbox_node: Area2D) -> bool:
	if not shield_raised or state == State.HITSTUN or state == State.DEAD:
		return false

	var attacker_pos := Vector2.ZERO
	var has_position := false
	var owner_node = hitbox_node.get("owner_node")

	if owner_node is Node2D:
		attacker_pos = owner_node.global_position
		has_position = true
	elif hitbox_node is Node2D:
		attacker_pos = hitbox_node.global_position
		has_position = true

	if not has_position:
		return false

	var to_attacker := attacker_pos - global_position
	if to_attacker.length_squared() <= 0.01:
		return false

	var block_threshold := cos(deg_to_rad(shield_block_angle_degrees * 0.5))
	var front_dot := Vector2(facing_dir, 0.0).dot(to_attacker.normalized())
	return front_dot >= block_threshold


func _on_successful_block() -> void:
	velocity.x = -facing_dir * 90.0
	if state in [State.ATTACK, State.COUNTER, State.HITSTUN, State.DEAD]:
		return

	if attack_cooldown_timer <= 0.2:
		_begin_windup(true)
	else:
		_pending_counter = true


func _try_hit_player(damage: float, knockback_force: float) -> void:
	if not _has_valid_player():
		return

	var offset := _player.global_position - global_position
	if abs(offset.x) > attack_range + 18.0:
		return
	if abs(offset.y) > 74.0:
		return
	if signf(offset.x) != float(facing_dir) and abs(offset.x) > 8.0:
		return

	if _player.has_method("take_damage"):
		_player.call("take_damage", damage)

	if _player is CharacterBody2D:
		var player_body := _player as CharacterBody2D
		player_body.velocity = Vector2(facing_dir * knockback_force, -knockback_force * 0.22)


func _on_health_changed(_old_health: float, _new_health: float) -> void:
	_update_enrage_state()


func _update_enrage_state() -> void:
	if health == null or is_enraged:
		return

	if health.current_health <= health.max_health * 0.5:
		is_enraged = true
		shield_raised = false


func _on_death() -> void:
	_change_state(State.DEAD)
	velocity = Vector2.ZERO
	collision_layer = 0
	collision_mask = 0

	if hurtbox:
		hurtbox.set_deferred("monitoring", false)
		hurtbox.set_deferred("monitorable", false)


func _face_player() -> void:
	if not _has_valid_player():
		return

	var x_delta := _player.global_position.x - global_position.x
	if abs(x_delta) < 1.0:
		return
	facing_dir = 1 if x_delta > 0.0 else -1


func _get_move_speed() -> float:
	return enraged_move_speed if is_enraged else move_speed


func _can_engage_player() -> bool:
	return _has_valid_player() and global_position.distance_to(_player.global_position) <= detection_range


func _has_valid_player() -> bool:
	return _player != null and is_instance_valid(_player) and _player.is_inside_tree()


func _find_player() -> Node2D:
	for candidate in get_tree().get_nodes_in_group("player"):
		if candidate is Node2D:
			return candidate as Node2D
	return null


func _change_state(new_state: State) -> void:
	if state == new_state:
		return

	state = new_state
	match state:
		State.IDLE, State.APPROACH:
			shield_raised = not is_enraged
		State.WINDUP, State.ATTACK, State.COUNTER, State.HITSTUN, State.DEAD:
			shield_raised = false


func _animate_sprite(delta: float) -> void:
	if sprite == null:
		return

	sprite.flip_h = facing_dir < 0

	var frame_count: int = maxi(1, sprite.hframes)
	if state == State.DEAD:
		sprite.frame = frame_count - 1
	else:
		var anim_speed := 9.0
		if state == State.HITSTUN:
			anim_speed = 0.0
		elif state in [State.ATTACK, State.COUNTER]:
			anim_speed = 13.0
		elif abs(velocity.x) > 20.0:
			anim_speed = 10.0
		else:
			anim_speed = 7.0

		if anim_speed <= 0.0:
			sprite.frame = 0
		else:
			_anim_timer += delta * anim_speed
			sprite.frame = int(_anim_timer) % frame_count

	if state == State.DEAD:
		sprite.modulate = Color(0.35, 0.35, 0.35, 0.85)
	elif state == State.HITSTUN:
		sprite.modulate = Color(1.0, 0.82, 0.82, 1.0)
	elif shield_raised:
		sprite.modulate = Color(1.0, 0.75, 0.45, 1.0)
	elif is_enraged:
		sprite.modulate = Color(1.0, 0.42, 0.35, 1.0)
	else:
		sprite.modulate = Color(0.97, 0.6, 0.35, 1.0)
