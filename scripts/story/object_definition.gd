extends RefCounted
## Pure data validation shared by runtime and future Room Creator exporters.
const KINDS = ["examine", "read", "investigate", "activate", "memorial"]

static func valid_id(value) -> bool:
	if not value is String or value.length() > 48: return false
	var pattern = RegEx.new()
	pattern.compile("^(disc|evt|trap|enc|obj)/[a-z][a-z0-9_]*(/[a-z][a-z0-9_]*)*$")
	return pattern.search(value) != null

static func validate(data) -> Array[String]:
	var errors: Array[String] = []
	if not data is Dictionary or data.get("contract") != 1 or not data.get("objects") is Array:
		return ["Expected contract 1 and objects array"]
	var ids = {}
	for row in data.objects:
		if not row is Dictionary:
			errors.append("Object must be a dictionary"); continue
		var id = row.get("id", "")
		if not valid_id(id) or ids.has(id): errors.append("Invalid or duplicate id: " + str(id))
		ids[id] = true
		if not row.get("kind") in KINDS: errors.append(str(id) + ": unknown kind")
		var room = row.get("room", -1)
		if not (room is int or room is float) or room != int(room) or room < 0 or room > 20: errors.append(str(id) + ": invalid room")
		var at = row.get("at")
		if not at is Array or at.size() != 2:
			errors.append(str(id) + ": at must contain x,y")
		else:
			for value in at:
				if not (value is float or value is int) or not is_finite(float(value)): errors.append(str(id) + ": invalid position")
		var radius = row.get("radius", 65)
		if not (radius is float or radius is int) or not is_finite(float(radius)) or radius <= 0 or radius > 200: errors.append(str(id) + ": invalid radius")
		for key in ["once", "persistent"]:
			if row.has(key) and not row[key] is bool: errors.append(str(id) + ": invalid " + key)
		if row.get("once", false) and not row.get("persistent", true): errors.append(str(id) + ": once requires persistence")
		for key in ["title", "prompt", "text_id", "description", "art", "audio"]:
			if row.has(key) and not row[key] is String: errors.append(str(id) + ": invalid " + key)
		for key in ["event", "cinematic", "objective"]:
			if row.has(key) and not valid_id(row[key]): errors.append(str(id) + ": invalid " + key)
		var required = row.get("requires", [])
		if not required is Array: errors.append(str(id) + ": requires must be an array")
		else:
			for flag in required:
				if not flag is String or flag.is_empty(): errors.append(str(id) + ": invalid prerequisite")
		var pages = row.get("pages", [])
		if not pages is Array: errors.append(str(id) + ": pages must be an array")
		else:
			for page in pages:
				if not page is String: errors.append(str(id) + ": invalid page")
	return errors

static func position(row: Dictionary) -> Vector2:
	return Vector2(row.at[0], row.at[1])

static func validate_rules(data, consumers: Dictionary = {}) -> Array[String]:
	var errors: Array[String] = []
	if not data is Dictionary or data.get("contract") != 1 or not data.get("rules") is Array:
		return ["Expected contract 1 and rules array"]
	for rule in data.rules:
		if not rule is Dictionary or not valid_id(rule.get("trigger", "")):
			errors.append("Rule needs valid event trigger"); continue
		if not rule.get("requires", []) is Array:
			errors.append("Rule requires must be an array"); continue
		for flag in rule.get("requires", []):
			if not flag is String or flag.is_empty(): errors.append("Invalid required flag")
		if not rule.get("effects") is Array:
			errors.append("Rule needs effects array"); continue
		for effect in rule.effects:
			if not effect is Dictionary:
				errors.append("Effect must be an object"); continue
			var kind = effect.get("kind", "")
			if not kind in ["set_flag","announce","objective","spawn_encounter","arm_hazard","request_cutin"]:
				errors.append("Unknown effect: " + str(kind)); continue
			if kind in ["set_flag","objective"] and not valid_id(effect.get("id", "")):
				errors.append("Invalid effect flag")
			if kind == "objective" and not str(effect.get("id", "")).begins_with("obj/"):
				errors.append("Objective must own an obj/ flag")
			if kind in ["announce","objective"] and not effect.get("text") is String:
				errors.append("Effect needs text")
			if kind in ["spawn_encounter","arm_hazard","request_cutin"] and (not effect.get("id") is String or effect.id.is_empty()):
				errors.append("Effect needs consumer ID")
			if kind in ["spawn_encounter","arm_hazard"] and not consumers.get(kind, {}).has(effect.get("id", "")):
				errors.append("Unknown consumer: " + str(effect.get("id", "")))
	return errors
