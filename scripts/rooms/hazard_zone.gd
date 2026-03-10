extends Area2D
class_name HazardZone

## Environmental hazard for platforming rooms.
## Applies damage (or instant death) when the player enters.

@export var damage: float = 35.0
@export var instant_kill: bool = true


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if instant_kill and body.has_method("die"):
		body.call("die")
		return

	if body.has_method("take_damage"):
		body.call("take_damage", damage)
		GameState.capture_player_state(body)
		return

	if body.has_method("die"):
		body.call("die")
