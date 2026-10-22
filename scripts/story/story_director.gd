extends RefCounted
const Definition = preload("res://scripts/story/object_definition.gd")
const InspectionPanel = preload("res://scripts/story/inspection_panel.gd")
var world
var panel
var objects: Array = []
var rules: Array = []
var pending: Array = []
var dirty = false
var lines: Array[String] = []

func configure(w):
	world = w
	panel = InspectionPanel.new()
	world.add_child(panel)
	load_data("res://data/story/objects.json", "res://data/story/rules.json")

func load_data(objects_path: String, rules_path: String) -> bool:
	var data = JSON.parse_string(FileAccess.get_file_as_string(objects_path))
	if not Definition.validate(data).is_empty(): return false
	var rule_data = JSON.parse_string(FileAccess.get_file_as_string(rules_path))
	if not rule_data is Dictionary or rule_data.get("contract") != 1 or not rule_data.get("rules") is Array: return false
	objects = data.objects
	rules = rule_data.rules
	return true

func has(flag_id: String) -> bool:
	return world.expansion_flags.get(flag_id, false) == true

func set_flag(flag_id: String) -> bool:
	if not Definition.valid_id(flag_id) or has(flag_id): return false
	world.expansion_flags[flag_id] = true
	dirty = true
	flush_save()
	return true

func flush_save():
	if dirty and world.transition <= 0 and not world.test_mode:
		dirty = not world.save_progress()

func report(event_id: String, context: Dictionary = {}) -> void:
	if not Definition.valid_id(event_id): return
	if world.transition > 0:
		pending.append([event_id, context.duplicate(true)]); return
	for rule in rules:
		if rule.get("trigger") != event_id or not meets(rule.get("requires", [])): continue
		for effect in rule.get("effects", []):
			match effect.get("kind", ""):
				"set_flag", "objective": set_flag(effect.get("id", ""))
				"announce":
					if lines.size() < 3: lines.append(effect.get("text", ""))
				"request_cutin": pass # Presentation never owns progression.

func meets(flags: Array) -> bool:
	for flag in flags:
		if not has(flag): return false
	return true

func objective_override() -> String:
	for rule in rules:
		for effect in rule.get("effects", []):
			if effect.get("kind") == "objective" and has(effect.get("id", "")):
				return effect.get("text", "")
	return ""

func room_loaded(w, _room: int) -> void:
	if world == null: configure(w)
	if is_instance_valid(panel): panel.close()

func safe_placement(row: Dictionary) -> bool:
	var at = Definition.position(row)
	var radius = row.get("radius", 65)
	for portal in world.cinematic_transitions.endpoints(world, row.room):
		if at.distance_to(portal.at) <= radius + 200: return false
	var checkpoints = {0:[Vector2(220,1300),95],3:[Vector2(1320,1300),115],7:[Vector2(2200,1300),140],8:[Vector2(2060,1300),100],11:[Vector2(1720,1300),100],12:[Vector2(2220,1300),120],16:[Vector2(420,1120),85],20:[Vector2(600,520),85]}
	if row.room in checkpoints:
		var c = checkpoints[row.room]
		if at.distance_to(c[0]) <= radius + c[1]: return false
	return true

func candidate() -> Dictionary:
	var selected: Dictionary = {}
	var distance = INF
	for row in objects:
		if row.room != world.room or not safe_placement(row) or not meets(row.get("requires", [])): continue
		if row.get("once", false) and has(row.id): continue
		var d = world.player.position.distance_to(Definition.position(row))
		if d <= row.get("radius",65) and (d < distance or (d == distance and row.id < selected.get("id", "~"))):
			selected = row; distance = d
	return selected

func interact(_w) -> bool:
	if world.transition > 0 or world.get_tree().paused or world.player.hp <= 0: return false
	var row = candidate()
	if row.is_empty(): return false
	if row.get("persistent", true): set_flag(row.id)
	if row.has("event"): report(row.event, {"object":row.id,"room":world.room})
	panel.inspect(world, row)
	return true

func update(_w, _dt) -> void:
	if world.transition > 0: return
	var queued = pending.duplicate(); pending.clear()
	for item in queued: report(item[0], item[1])
	flush_save()
	if world.message_time <= 0 and not lines.is_empty(): world.announce(lines.pop_front())

func draw_room(w):
	for row in objects:
		if row.room != w.room: continue
		var at = Definition.position(row)
		w.draw_rect(Rect2(at - Vector2(18,36), Vector2(36,36)), Color("74baa4") if has(row.id) else Color("c6a876"))
	var row = candidate()
	if not row.is_empty():
		w.draw_string(ThemeDB.fallback_font, Definition.position(row) + Vector2(-60,-55), row.get("prompt", row.kind.capitalize()) + " · E", HORIZONTAL_ALIGNMENT_LEFT, -1, 20)
