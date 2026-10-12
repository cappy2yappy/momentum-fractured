extends Node2D
# LD-01 can attach this to a dedicated object. No art or level placements here.
@export var enabled = true
@export var attachment_offset = Vector2.ZERO
@export var required_ability = "tether"
func _ready(): add_to_group("kaze_grapple_anchor")
func get_attachment_position() -> Vector2: return global_position + attachment_offset
func is_available_for(player) -> bool:
	return enabled and player.has_traversal_requirement(required_ability)
