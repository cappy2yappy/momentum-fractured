extends Node2D
## Independent deterministic clock. Damage delegates to Kaze's existing i-frames.
signal phase_changed(phase: String)
signal enabled_changed(enabled: bool)
const Placement = preload("res://scripts/hazards/hazard_placement.gd")
@export var placement: Placement
var player: CharacterBody2D
var phase: String = "idle"
var elapsed: float = 0.0
var enabled: bool = true
var sensor: Area2D
var solid_shape: CollisionShape2D
var valid: bool = false

func _ready():
	if placement == null: placement = Placement.new()
	valid = placement.validation_errors().is_empty()
	if not valid:
		push_error("HAZ-01 invalid placement: %s" % placement.validation_errors())
		set_physics_process(false)
		return
	position = placement.at
	enabled = placement.initially_enabled
	sensor = Area2D.new()
	sensor.collision_layer = 0
	sensor.collision_mask = 2
	var shape = CollisionShape2D.new()
	var box = RectangleShape2D.new()
	box.size = placement.dimensions
	shape.shape = box
	shape.position = box.size / 2
	sensor.add_child(shape)
	add_child(sensor)
	if placement.kind == "collapse":
		var body = StaticBody2D.new()
		body.collision_layer = 1
		body.collision_mask = 2
		solid_shape = shape.duplicate()
		body.add_child(solid_shape)
		add_child(body)
	reset_room({})

func available() -> bool:
	return enabled and (placement.prerequisite.is_empty() or (is_instance_valid(player) and player.has_traversal_requirement(placement.prerequisite)))

func _physics_process(delta):
	advance(delta)
	if available() and phase == "active" and placement.kind != "collapse":
		for body in sensor.get_overlapping_bodies():
			if body == player: player.damage(global_position + placement.dimensions / 2)

func standing_on_platform() -> bool:
	if not is_instance_valid(player): return false
	var feet = to_local(player.global_position)
	return player.is_on_floor() and absf(feet.y) <= 3 and feet.x >= -14 and feet.x <= placement.dimensions.x + 14

func occupied() -> bool:
	# Synchronous query, including contact margin, before rematerializing collision.
	if not is_instance_valid(player) or not is_inside_tree(): return false
	var query = PhysicsShapeQueryParameters2D.new()
	var box = RectangleShape2D.new()
	box.size = placement.dimensions + Vector2(4, 4)
	query.shape = box
	query.transform = Transform2D(0, global_position + placement.dimensions / 2)
	query.collision_mask = 2
	return not get_world_2d().direct_space_state.intersect_shape(query).is_empty()

func advance(delta: float):
	if not valid or not is_finite(delta) or delta < 0: return
	if not available():
		if phase != "idle" and not (placement.kind == "collapse" and occupied()): change_phase("idle")
		return
	if placement.kind == "collapse" and phase == "idle":
		if standing_on_platform(): change_phase("warning")
		return
	elapsed += delta
	while elapsed + 0.0000001 >= duration():
		if placement.kind == "collapse" and phase == "recovery" and occupied():
			elapsed = duration()
			break
		elapsed = maxf(0.0, elapsed - duration())
		match phase:
			"idle": change_phase("warning", false)
			"warning": change_phase("active", false)
			"active": change_phase("recovery", false)
			"recovery": change_phase("idle", false)
		if placement.kind == "collapse" and phase == "idle":
			elapsed = 0
			break
	queue_redraw()

func duration() -> float:
	match phase:
		"warning": return placement.warning_seconds
		"active": return placement.active_seconds
		"recovery": return placement.recovery_seconds
	return placement.idle_seconds

func change_phase(next: String, clear_clock: bool = true):
	phase = next
	if clear_clock: elapsed = 0
	if is_instance_valid(solid_shape):
		solid_shape.set_deferred("disabled", phase in ["active", "recovery"])
	phase_changed.emit(phase)
	queue_redraw()

func set_enabled(value: bool):
	if enabled == value: return
	enabled = value
	# Disabling collapse restores only when clear; never materialize around Kaze.
	if placement.kind == "collapse" and occupied(): change_phase("recovery")
	else: change_phase("idle")
	enabled_changed.emit(enabled)
	queue_redraw()

func snapshot() -> Dictionary:
	return {"version": 1, "id": placement.placement_id, "disabled": not enabled}

func reset_room(saved: Dictionary):
	enabled = placement.initially_enabled
	if placement.reset_rule == "persist_disabled" and saved.get("version") == 1 and saved.get("id") == placement.placement_id and saved.get("disabled") is bool:
		enabled = not saved.disabled
	# Never resume an active hit volume after save load/re-entry.
	change_phase("recovery" if placement.kind == "collapse" and occupied() else "idle")

func _draw():
	if not valid: return
	var rect = Rect2(Vector2.ZERO, placement.dimensions)
	var color = Color("65cfb5")
	var label = "SAFE"
	if not available(): color = Color("8693a4"); label = "OFF"
	elif phase == "warning": color = Color("ffce66"); label = "! WARNING"
	elif phase == "active": color = Color("ff747c"); label = "DANGER" if placement.kind != "collapse" else "GAP"
	elif phase == "recovery": color = Color("9baac1"); label = "RECOVERY"
	draw_rect(rect, Color(color, 0.20))
	draw_rect(rect, color, false, 3)
	# Static hatch and text are readable without flashing, shaking, or particles.
	if phase in ["warning", "active"] and available():
		for x in range(8, int(rect.size.x)-8, 16): draw_line(Vector2(x, 8), Vector2(x-6, rect.size.y-8), color, 2)
	draw_string(ThemeDB.fallback_font, Vector2(0,-28), placement.kind.to_upper(), HORIZONTAL_ALIGNMENT_LEFT,-1,16,color)
	draw_string(ThemeDB.fallback_font, Vector2(0,-8), label, HORIZONTAL_ALIGNMENT_LEFT,-1,14,color)
	if phase != "idle" or placement.kind != "collapse":
		draw_rect(Rect2(0,rect.size.y+5,rect.size.x*clampf(elapsed/duration(),0,1),4),color)
