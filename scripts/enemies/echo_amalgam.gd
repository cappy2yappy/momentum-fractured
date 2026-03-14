extends CharacterBody2D
class_name EchoAmalgam

## Shibuya mini-boss.
## Phase 1: summons Echo adds + dashes
## Phase 2: faster pressure, no summons
## Phase 3: enraged high-speed dashes and slam pressure

enum State { APPROACH, DASH_WINDUP, DASHING, SLAM_WINDUP, RECOVER, DEAD }

@export var move_speed: float = 85.0
@export var dash_damage: float = 20.0
@export var slam_damage: float = 25.0
@export var dash_windup_time: float = 0.42
@export var dash_duration: float = 0.34
@export var slam_windup_time: float = 0.56
@export var attack_recover_time: float = 0.3
@export var attack_cooldown: float = 1.35
@export var phase_three_cooldown: float = 0.9
@export var add_spawn_cooldown: float = 4.0
@export var phase_one_dash_speed: float = 620.0
@export var phase_two_dash_speed: float = 760.0
@export var phase_three_dash_speed: float = 940.0
@export var echo_scene: PackedScene = preload("res://scenes/enemies/echo.tscn")
@export var cell_pickup_scene: PackedScene = preload("res://scenes/pickups/cell_pickup.tscn")

const GRAVITY: float = 1980.0
const SEARCH_INTERVAL: float = 0.2
const DASH_CONTACT_INTERVAL: float = 0.2
const MAX_PHASE_ONE_ADDS: int = 2
const REWARD_CELLS: int = 100

var state: State = State.APPROACH
var phase: int = 1
var _player: Node2D = null
var _search_timer: float = 0.0
var _attack_cooldown_timer: float = 1.0
var _state_timer: float = 0.0
var _add_spawn_cooldown_timer: float = 1.6
var _dash_contact_timer: float = 0.0
var _dash_dir: int = 1
var _is_dying: bool = false
var _live_adds: Array[Node2D] = []

@onready var hurtbox: Area2D = $Hurtbox
@onready var health: Health = $Health
@onready var body_rect: ColorRect = $ColorRect


func _ready() -> void:
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

	_update_phase()
	_update_visual_for_phase()


func _physics_process(delta: float) -> void:
	if _is_dying:
		return

	_search_timer = maxf(0.0, _search_timer - delta)
	_attack_cooldown_timer = maxf(0.0, _attack_cooldown_timer - delta)
	_add_spawn_cooldown_timer = maxf(0.0, _add_spawn_cooldown_timer - delta)
	_dash_contact_timer = maxf(0.0, _dash_contact_timer - delta)

	if not is_on_floor():
		velocity.y += GRAVITY * delta

	_acquire_player_if_needed()
	_cleanup_dead_adds()
	_update_phase()

	match state:
		State.APPROACH:
			_state_approach(delta)
		State.DASH_WINDUP:
			_state_dash_windup(delta)
		State.DASHING:
			_state_dashing(delta)
		State.SLAM_WINDUP:
			_state_slam_windup(delta)
		State.RECOVER:
			_state_recover(delta)
		State.DEAD:
			velocity.x = move_toward(velocity.x, 0.0, 1200.0 * delta)

	move_and_slide()


func _state_approach(delta: float) -> void:
	if not _has_valid_player():
		velocity.x = move_toward(velocity.x, 0.0, 800.0 * delta)
		return

	var x_delta: float = _player.global_position.x - global_position.x
	if absf(x_delta) > 10.0:
		_dash_dir = 1 if x_delta > 0.0 else -1

	velocity.x = move_toward(velocity.x, float(_dash_dir) * move_speed, 600.0 * delta)

	if _attack_cooldown_timer > 0.0:
		return

	if phase == 1 and _add_spawn_cooldown_timer <= 0.0 and _alive_add_count() < MAX_PHASE_ONE_ADDS:
		_spawn_echo_adds()
		_add_spawn_cooldown_timer = add_spawn_cooldown
		_set_recover_state(0.22)
		_attack_cooldown_timer = 0.65
		return

	var dash_chance: float = 0.48
	if phase == 2:
		dash_chance = 0.62
	elif phase >= 3:
		dash_chance = 0.75

	if randf() <= dash_chance:
		_start_dash()
	else:
		_start_slam()


func _state_dash_windup(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 1400.0 * delta)
	_state_timer -= delta
	if _state_timer <= 0.0:
		state = State.DASHING
		_state_timer = dash_duration
		_dash_contact_timer = 0.0
		body_rect.color = Color(1.0, 0.38, 0.38, 1.0)


func _state_dashing(delta: float) -> void:
	velocity.x = float(_dash_dir) * _phase_dash_speed()
	_state_timer -= delta

	if _dash_contact_timer <= 0.0:
		if _try_damage_player(dash_damage, 560.0, 150.0):
			_dash_contact_timer = DASH_CONTACT_INTERVAL

	if _state_timer <= 0.0:
		_set_recover_state(attack_recover_time)
		_attack_cooldown_timer = _phase_attack_cooldown()


func _state_slam_windup(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 1600.0 * delta)
	_state_timer -= delta
	if _state_timer <= 0.0:
		_perform_ground_slam()
		_set_recover_state(attack_recover_time + 0.12)
		_attack_cooldown_timer = _phase_attack_cooldown() + 0.15


func _state_recover(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 1400.0 * delta)
	_state_timer -= delta
	if _state_timer <= 0.0:
		state = State.APPROACH
		_update_visual_for_phase()


func _start_dash() -> void:
	if _has_valid_player():
		var x_delta: float = _player.global_position.x - global_position.x
		if absf(x_delta) > 1.0:
			_dash_dir = 1 if x_delta > 0.0 else -1

	state = State.DASH_WINDUP
	_state_timer = dash_windup_time
	velocity.x = 0.0
	body_rect.color = Color(1.0, 0.58, 0.45, 1.0)


func _start_slam() -> void:
	state = State.SLAM_WINDUP
	_state_timer = slam_windup_time
	velocity.x = 0.0
	body_rect.color = Color(0.95, 0.78, 0.45, 1.0)


func _perform_ground_slam() -> void:
	body_rect.color = Color(1.0, 0.25, 0.25, 1.0)
	if not _has_valid_player():
		return

	var offset: Vector2 = _player.global_position - global_position
	if absf(offset.x) > 320.0 or absf(offset.y) > 120.0:
		return

	if _player.has_method("take_damage"):
		_player.call("take_damage", slam_damage)

	if _player is CharacterBody2D:
		var player_body := _player as CharacterBody2D
		var horizontal_push: float = 480.0 if offset.x >= 0.0 else -480.0
		player_body.velocity = Vector2(horizontal_push, -280.0)


func _try_damage_player(damage: float, knockback: float, hit_half_width: float) -> bool:
	if not _has_valid_player():
		return false

	var offset: Vector2 = _player.global_position - global_position
	if absf(offset.x) > hit_half_width:
		return false
	if absf(offset.y) > 120.0:
		return false

	if _player.has_method("take_damage"):
		_player.call("take_damage", damage)

	if _player is CharacterBody2D:
		var player_body := _player as CharacterBody2D
		player_body.velocity = Vector2(float(_dash_dir) * knockback, -knockback * 0.18)

	return true


func _set_recover_state(duration: float) -> void:
	state = State.RECOVER
	_state_timer = duration
	velocity.x = 0.0
	_update_visual_for_phase()


func _on_hit(_damage: float, _knockback: Vector2, _hitbox_node: Area2D) -> void:
	if _is_dying:
		return

	if body_rect:
		body_rect.color = Color(1.0, 1.0, 1.0, 1.0)
		var tween := create_tween()
		tween.tween_property(body_rect, "color", _phase_color(), 0.14)


func _on_health_changed(_old_health: float, _new_health: float) -> void:
	var previous_phase: int = phase
	_update_phase()
	if phase != previous_phase:
		_show_phase_transition()
		_update_visual_for_phase()


func _update_phase() -> void:
	if health == null:
		return

	if health.current_health <= 50.0:
		phase = 3
	elif health.current_health <= 100.0:
		phase = 2
	else:
		phase = 1


func _show_phase_transition() -> void:
	var hud: Node = get_tree().current_scene.get_node_or_null("HUD")
	if hud and hud.has_method("show_notification"):
		var message := "Echo Amalgam Phase %d" % phase
		hud.call("show_notification", message, Color(1.0, 0.84, 0.45, 1.0), 1.0)


func _phase_dash_speed() -> float:
	if phase == 1:
		return phase_one_dash_speed
	if phase == 2:
		return phase_two_dash_speed
	return phase_three_dash_speed


func _phase_attack_cooldown() -> float:
	if phase >= 3:
		return phase_three_cooldown
	return attack_cooldown


func _phase_color() -> Color:
	if phase == 1:
		return Color(0.86, 0.2, 0.28, 1.0)
	if phase == 2:
		return Color(0.95, 0.28, 0.2, 1.0)
	return Color(1.0, 0.16, 0.16, 1.0)


func _update_visual_for_phase() -> void:
	if body_rect == null:
		return
	body_rect.color = _phase_color()


func _spawn_echo_adds() -> void:
	if echo_scene == null:
		return

	var parent_node: Node = get_parent()
	if parent_node == null:
		parent_node = get_tree().current_scene
	if parent_node == null:
		return

	var spawn_count: int = 2 if _alive_add_count() == 0 else 1
	for i in range(spawn_count):
		var spawned_node: Node = echo_scene.instantiate()
		if not (spawned_node is Node2D):
			continue

		var spawned_echo := spawned_node as Node2D
		var x_offset: float = -190.0 if i == 0 else 190.0
		if spawn_count == 1:
			x_offset = 180.0 if randf() < 0.5 else -180.0
		spawned_echo.global_position = global_position + Vector2(x_offset, 0.0)

		if spawned_echo.has_method("set"):
			spawned_echo.set("patrol_points", [
				spawned_echo.global_position + Vector2(-90.0, 0.0),
				spawned_echo.global_position + Vector2(90.0, 0.0),
			])

		parent_node.add_child(spawned_echo)
		_live_adds.append(spawned_echo)

	var hud: Node = get_tree().current_scene.get_node_or_null("HUD")
	if hud and hud.has_method("show_notification"):
		hud.call("show_notification", "Echo Fragments Spawned", Color(1.0, 0.72, 0.58, 1.0), 0.9)


func _alive_add_count() -> int:
	_cleanup_dead_adds()
	return _live_adds.size()


func _cleanup_dead_adds() -> void:
	var survivors: Array[Node2D] = []
	for add_enemy in _live_adds:
		if add_enemy != null and is_instance_valid(add_enemy):
			survivors.append(add_enemy)
	_live_adds = survivors


func _acquire_player_if_needed() -> void:
	if _has_valid_player() and _search_timer > 0.0:
		return

	_search_timer = SEARCH_INTERVAL
	_player = null
	for candidate in get_tree().get_nodes_in_group("player"):
		if candidate is Node2D:
			_player = candidate as Node2D
			return


func _has_valid_player() -> bool:
	if _player == null or not is_instance_valid(_player):
		return false
	return not bool(_player.get("is_dead"))


func _on_death() -> void:
	if _is_dying:
		return

	_is_dying = true
	state = State.DEAD
	collision_layer = 0
	collision_mask = 0
	if hurtbox:
		hurtbox.monitoring = false
		hurtbox.monitorable = false
	velocity = Vector2.ZERO
	AudioManager.play_sfx("enemy_death")

	var hud: Node = get_tree().current_scene.get_node_or_null("HUD")
	if hud and hud.has_method("show_notification"):
		hud.call("show_notification", "Echo Amalgam Defeated!", Color(1.0, 0.9, 0.55, 1.0), 1.4)

	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	await tween.finished
	queue_free()


func spawn_cell_drop(_total_cells: int) -> void:
	if cell_pickup_scene == null:
		return

	var pickup: Node = cell_pickup_scene.instantiate()
	if pickup == null:
		return

	if pickup.has_method("set"):
		pickup.set("amount", REWARD_CELLS)
	if pickup is Node2D:
		(pickup as Node2D).global_position = global_position + Vector2(0.0, -36.0)

	get_tree().current_scene.add_child(pickup)
