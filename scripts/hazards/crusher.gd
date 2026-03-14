extends Node2D
class_name CrusherHazard

@export var slam_distance: float = 220.0
@export var slam_speed: float = 850.0
@export var return_speed: float = 320.0
@export var top_wait: float = 1.5
@export var damage: float = 50.0

enum State { WAITING, SLAMMING, RETURNING }

var _state: State = State.WAITING
var _top_position: Vector2
var _bottom_position: Vector2
var _wait_timer: float = 0.0

@onready var block: AnimatableBody2D = $Block
@onready var trigger_zone: Area2D = $TriggerZone
@onready var hit_zone: Area2D = $Block/HitZone


func _ready() -> void:
	_top_position = block.global_position
	_bottom_position = _top_position + Vector2(0.0, slam_distance)
	_wait_timer = top_wait

	trigger_zone.body_entered.connect(_on_trigger_entered)
	hit_zone.body_entered.connect(_on_hit_zone_entered)


func _physics_process(delta: float) -> void:
	match _state:
		State.WAITING:
			_wait_timer = maxf(0.0, _wait_timer - delta)
			if _wait_timer <= 0.0:
				_state = State.SLAMMING
		State.SLAMMING:
			block.global_position.y = move_toward(block.global_position.y, _bottom_position.y, slam_speed * delta)
			if is_equal_approx(block.global_position.y, _bottom_position.y):
				_state = State.RETURNING
		State.RETURNING:
			block.global_position.y = move_toward(block.global_position.y, _top_position.y, return_speed * delta)
			if is_equal_approx(block.global_position.y, _top_position.y):
				_state = State.WAITING
				_wait_timer = top_wait


func _on_trigger_entered(body: Node2D) -> void:
	if body.is_in_group("player") and _state == State.WAITING:
		_wait_timer = minf(_wait_timer, 0.25)


func _on_hit_zone_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if body.has_method("take_damage"):
		body.call("take_damage", damage)
