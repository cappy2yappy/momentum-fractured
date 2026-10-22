extends RefCounted
## EN-01 v1: JSON-only metadata. Validate the entire batch before spawning.
const DEFAULTS = {
	"type": "guard", "activation": "proximity", "story_flag": "", "activation_distance": 500.0,
	"aggression_distance": 450.0, "recovery_distance": 650.0, "lose_sight_time": 0.8,
	"speed": 105.0, "hp": 6, "attack_range": 88.0, "windup": 0.65,
	"active_time": 0.16, "recovery_time": 1.0, "projectile_speed": 330.0,
	"projectile_lifetime": 3.0, "spawn_grace": 1.0, "persistent": false,
	"completion_event": ""
}
static func number(v) -> bool:
	return (v is int or v is float) and is_finite(float(v))
static func identifier(v) -> bool:
	if not v is String or v.is_empty() or v.length() > 96: return false
	for c in v:
		if not c in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-/": return false
	return true
static func validate(raw, surfaces: Array) -> Dictionary:
	var errors: Array[String] = []
	if not raw is Dictionary: return {"errors": ["Entry must be an object"], "config": {}}
	var c = DEFAULTS.duplicate(true)
	for key in raw:
		if not key in DEFAULTS and not key in ["version", "id", "position", "territory"]:
			errors.append("Unknown field: %s" % key)
		c[key] = raw[key]
	if c.get("version") != 1: errors.append("version must be 1")
	if not identifier(c.get("id")): errors.append("id must be a stable identifier")
	if not c.type in ["guard", "ranged", "ambush"]: errors.append("Unknown prototype type")
	if not c.activation in ["immediate", "proximity", "story"]: errors.append("Unknown activation")
	if not c.story_flag is String or (c.activation == "story" and not identifier(c.story_flag)):
		errors.append("story activation requires a flag identifier")
	if not c.persistent is bool: errors.append("persistent must be boolean")
	if not c.completion_event is String or (c.completion_event != "" and not identifier(c.completion_event)):
		errors.append("Invalid completion event")
	var bounds = {"activation_distance": [80, 1200], "aggression_distance": [80,1200],
		"recovery_distance": [80,1600], "lose_sight_time": [0.2,5], "speed": [0,240],
		"hp": [1,30], "attack_range": [40,130], "windup": [0.48,3], "active_time": [0.05,0.25],
		"recovery_time": [0.7,5], "projectile_speed": [100,500], "projectile_lifetime": [0.2,5], "spawn_grace": [0.8,5]}
	for key in bounds:
		if not number(c[key]) or c[key] < bounds[key][0] or c[key] > bounds[key][1]: errors.append("Out of range: " + key)
	if number(c.hp) and c.hp != int(c.hp): errors.append("hp must be an integer")
	if number(c.recovery_distance) and number(c.aggression_distance) and c.recovery_distance < c.aggression_distance:
		errors.append("recovery_distance must be >= aggression_distance")
	for key in ["position", "territory"]:
		var v = c.get(key)
		if not v is Array or v.size() != 2 or not number(v[0]) or not number(v[1]): errors.append(key + " requires two finite numbers")
	if errors.is_empty():
		var p = Vector2(c.position[0], c.position[1])
		if c.territory[0] > p.x or c.territory[1] < p.x or c.territory[1] - c.territory[0] < 60:
			errors.append("Spawn must lie within a territory at least 60px wide")
		var supported = false
		for surface in surfaces:
			if absf(surface.position.y - p.y) <= 2 and c.territory[0] >= surface.position.x + 42 and c.territory[1] <= surface.end.x - 42: supported = true
			if surface.intersects(Rect2(c.territory[0] - 20, p.y - 80, c.territory[1] - c.territory[0] + 40, 78)):
				errors.append("Territory crosses solid geometry")
		if not supported: errors.append("Territory must fit one authored surface with a 42px edge margin")
	return {"errors": errors, "config": c}
