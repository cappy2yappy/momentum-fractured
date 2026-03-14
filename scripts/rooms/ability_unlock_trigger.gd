extends Area2D
class_name AbilityUnlockTrigger

## One-time ability unlock pedestal trigger.

@export var ability_id: String = "grapple"
@export var custom_notification: String = ""
@export var destroy_after_unlock: bool = false

var _consumed: bool = false

@onready var label: Label = get_node_or_null("Label")
@onready var orb: ColorRect = get_node_or_null("ColorRect")


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_refresh_visual_state()


func _on_body_entered(body: Node2D) -> void:
	if _consumed:
		return
	if not body.is_in_group("player"):
		return

	if AbilityManager.has_ability(ability_id):
		_consume()
		return

	AbilityManager.unlock_ability(ability_id)
	_show_custom_notification_if_needed()
	_consume()


func _show_custom_notification_if_needed() -> void:
	if custom_notification.strip_edges().is_empty():
		return

	var hud := get_tree().current_scene.get_node_or_null("HUD")
	if hud and hud.has_method("show_notification"):
		hud.call("show_notification", custom_notification, Color(0.78, 1.0, 0.86, 1.0), 1.6)


func _consume() -> void:
	_consumed = true
	monitoring = false
	monitorable = false

	var shape: CollisionShape2D = get_node_or_null("CollisionShape2D")
	if shape:
		shape.disabled = true

	if destroy_after_unlock:
		queue_free()
		return

	if orb:
		orb.color = Color(0.22, 0.42, 0.35, 0.5)
	if label:
		label.text = "ABILITY ALREADY CLAIMED"


func _refresh_visual_state() -> void:
	if AbilityManager.has_ability(ability_id):
		_consume()
