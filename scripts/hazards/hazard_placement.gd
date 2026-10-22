@tool
extends Resource
## HAZ-01 contract v1. Coordinates are local top-left pixels; durations are seconds.
@export var placement_id: String = "hazard"
@export_enum("collapse", "steam", "electric") var kind: String = "steam"
@export var at: Vector2 = Vector2.ZERO
@export var dimensions: Vector2 = Vector2(96, 100)
@export_range(0.1, 30.0) var idle_seconds: float = 2.0
@export_range(0.3, 30.0) var warning_seconds: float = 1.0
@export_range(0.1, 30.0) var active_seconds: float = 1.0
@export_range(0.3, 30.0) var recovery_seconds: float = 1.0
@export var initially_enabled: bool = true
## Empty or an existing player.has_traversal_requirement key. No new abilities.
@export var prerequisite: String = ""
@export_enum("room_entry", "persist_disabled") var reset_rule: String = "room_entry"

func validation_errors() -> PackedStringArray:
	var errors = PackedStringArray()
	if placement_id.strip_edges().is_empty(): errors.append("placement_id must be nonempty")
	if kind not in ["collapse", "steam", "electric"]: errors.append("unknown kind")
	if not at.is_finite() or not dimensions.is_finite() or dimensions.x < 32 or dimensions.y < 16:
		errors.append("finite coordinates and dimensions >= 32 x 16 required")
	for duration in [idle_seconds, warning_seconds, active_seconds, recovery_seconds]:
		if not is_finite(duration) or duration < 0.1: errors.append("durations must be finite and >= 0.1")
	if warning_seconds < 0.3 or recovery_seconds < 0.3: errors.append("warning/recovery must be >= 0.3")
	if prerequisite not in ["", "double_jump", "tether", "dash", "stride_1", "wind", "fire", "electric"]: errors.append("unknown prerequisite")
	if reset_rule not in ["room_entry", "persist_disabled"]: errors.append("unknown reset rule")
	return errors
