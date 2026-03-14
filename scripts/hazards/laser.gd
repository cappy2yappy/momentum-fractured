extends Node2D
class_name LaserHazard

@export var damage: float = 100.0
@export var active_duration: float = 2.0
@export var inactive_duration: float = 2.0
@export var warning_duration: float = 0.35

var _running: bool = true

@onready var beam: ColorRect = $Beam
@onready var area: Area2D = $Beam/HitArea


func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	_set_active(false)
	_cycle_loop()


func _exit_tree() -> void:
	_running = false


func _cycle_loop() -> void:
	while _running:
		_set_warning_state()
		await get_tree().create_timer(warning_duration).timeout
		if not _running:
			return
		_set_active(true)
		await get_tree().create_timer(active_duration).timeout
		if not _running:
			return
		_set_active(false)
		await get_tree().create_timer(inactive_duration).timeout


func _set_warning_state() -> void:
	beam.visible = true
	beam.color = Color(1.0, 0.2, 0.2, 0.45)
	area.monitoring = false
	var tween := create_tween()
	tween.tween_property(beam, "modulate:a", 0.95, warning_duration * 0.5)
	tween.tween_property(beam, "modulate:a", 0.45, warning_duration * 0.5)


func _set_active(active: bool) -> void:
	area.monitoring = active
	beam.visible = active
	beam.color = Color(1.0, 0.1, 0.1, 0.85) if active else Color(1.0, 0.2, 0.2, 0.25)
	beam.modulate.a = beam.color.a


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if body.has_method("take_damage"):
		body.call("take_damage", damage)
