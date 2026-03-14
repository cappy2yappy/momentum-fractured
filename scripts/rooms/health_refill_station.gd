extends Area2D
class_name HealthRefillStation

## One-time heal station per room visit.
## Restores player HP to max when activated.

@export var heal_notification_text: String = "Health restored"

var _used_this_visit: bool = false

@onready var _label: Label = get_node_or_null("Label")
@onready var _glow_rect: ColorRect = get_node_or_null("ColorRect")
@onready var _particles: CPUParticles2D = get_node_or_null("HealParticles")


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if _particles:
		_particles.emitting = false


func _process(_delta: float) -> void:
	if _particles == null:
		return

	# Keep particle cost modest if frame rate drops.
	_particles.amount = 16 if Engine.get_frames_per_second() < 55.0 else 32


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if _used_this_visit:
		return

	if body.has_method("get_max_health") and body.has_method("set_health_values"):
		var max_health := float(body.call("get_max_health"))
		body.call("set_health_values", max_health, max_health)
		GameState.capture_player_state(body)

	_used_this_visit = true
	if _label:
		_label.text = "HEAL STATION\n(spent)"
	if _glow_rect:
		_glow_rect.modulate = Color(0.5, 0.65, 0.58, 0.5)
	if _particles:
		_particles.restart()
		_particles.emitting = true

	_show_notification(body)


func _show_notification(body: Node2D) -> void:
	var scene := body.get_tree().current_scene
	if scene == null:
		return

	var hud := scene.find_child("HUD", true, false)
	if hud and hud.has_method("show_notification"):
		hud.call("show_notification", heal_notification_text, Color(0.8, 1.0, 0.9, 1.0), 0.9)
