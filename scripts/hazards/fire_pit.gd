extends Area2D
class_name FirePitHazard

@export var damage_per_tick: float = 20.0
@export var tick_interval: float = 0.5
@export var upward_boost: float = 220.0

var _tick_timers: Dictionary = {}


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if not (body is Node2D) or not body.is_in_group("player"):
			continue

		var id := body.get_instance_id()
		var timer := float(_tick_timers.get(id, 0.0)) - delta
		if timer <= 0.0:
			_apply_fire_tick(body)
			timer = tick_interval
		_tick_timers[id] = timer


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_apply_fire_tick(body)
		_tick_timers[body.get_instance_id()] = tick_interval


func _on_body_exited(body: Node2D) -> void:
	_tick_timers.erase(body.get_instance_id())


func _apply_fire_tick(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.call("take_damage", damage_per_tick)
	if body.get("velocity") != null:
		body.velocity.y = minf(body.velocity.y, -upward_boost)
