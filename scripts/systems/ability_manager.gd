extends Node

## Ability progression facade.
## Uses GameState for persistence and exposes unlock events + notifications.

signal ability_unlocked(ability_name: String)

const KNOWN_ABILITIES: Array[String] = ["grapple", "dash", "double_jump", "slide"]
const ABILITY_LABELS := {
	"grapple": "Grapple Hook",
	"dash": "Dash",
	"double_jump": "Double Jump",
	"slide": "Slide",
}


func unlock_ability(ability_name: String) -> void:
	if ability_name.is_empty():
		return
	if has_ability(ability_name):
		return

	GameState.unlock_ability(ability_name)
	emit_signal("ability_unlocked", ability_name)
	_show_unlock_notification(ability_name)


func has_ability(ability_name: String) -> bool:
	if ability_name.is_empty():
		return false
	return GameState.has_ability(ability_name)


func get_unlocked_map() -> Dictionary:
	var result: Dictionary = {}
	for ability_name in KNOWN_ABILITIES:
		result[ability_name] = has_ability(ability_name)
	return result


func _show_unlock_notification(ability_name: String) -> void:
	var scene := get_tree().current_scene
	if scene == null:
		return

	var hud := scene.get_node_or_null("HUD")
	if hud and hud.has_method("show_notification"):
		var label := String(ABILITY_LABELS.get(ability_name, ability_name.capitalize()))
		hud.call("show_notification", "%s unlocked!" % label, Color(0.72, 1.0, 0.8, 1.0), 1.6)
