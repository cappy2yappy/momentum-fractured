extends Node2D
## Attach at the world origin; call configure once after authored surfaces exist.
signal completed(event_id: String)
signal persistence_failed
const Config = preload("res://scripts/encounters/config.gd")
const Enemy = preload("res://scripts/encounters/enemy.gd")
var world
var source_room = -1
var members: Array = []
var event_members: Dictionary = {}
var finished: Dictionary = {}
var emitted_events: Dictionary = {}
var configured = false
func configure(host, entries) -> Array:
	if configured: return ["Encounter is already configured"]
	if not entries is Array or entries.is_empty(): return ["Expected a nonempty encounter array"]
	if get_parent() != host or transform != Transform2D.IDENTITY: return ["Encounter must be a direct world child at origin"]
	var configs: Array = []
	var ids = {}
	var errors: Array = []
	for raw in entries:
		var result = Config.validate(raw, host.platforms)
		errors.append_array(result.errors)
		if result.errors.is_empty():
			var c = result.config
			if ids.has(c.id): errors.append("Duplicate id: " + c.id)
			for sibling in host.get_children():
				if sibling != self and sibling.get_script() == get_script() and sibling.configured:
					for member in sibling.members:
						if is_instance_valid(member) and member.config.id == c.id: errors.append("Active id already registered: " + c.id)
			ids[c.id] = true; configs.append(c)
	if not errors.is_empty(): return errors
	world = host; source_room = world.room; configured = true
	for c in configs:
		if c.completion_event != "":
			if not event_members.has(c.completion_event): event_members[c.completion_event] = []
			event_members[c.completion_event].append(c.id)
		if c.persistent and world.cleared_encounters.get("en01/" + c.id, false):
			finished[c.id] = true
			continue
		var enemy = Enemy.new()
		enemy.config = c; enemy.encounter = self; enemy.player = world.player
		enemy.position = Vector2(c.position[0],c.position[1])
		enemy.defeated.connect(_defeated.bind(enemy))
		add_child(enemy); members.append(enemy); world.enemies.append(enemy)
	# Already-complete loads restore state silently, never replay rewards/events.
	for event in event_members:
		if _event_done(event): emitted_events[event] = true
	return []
func _event_done(event) -> bool:
	for id in event_members[event]:
		if not finished.get(id, false): return false
	return true
func _defeated(enemy):
	var c = enemy.config
	finished[c.id] = true
	world.enemies.erase(enemy); members.erase(enemy)
	if c.persistent:
		world.cleared_encounters["en01/" + c.id] = true
		if not world.save_progress(): persistence_failed.emit()
	for event in event_members:
		if not emitted_events.get(event, false) and _event_done(event):
			emitted_events[event] = true
			completed.emit(event)
func _physics_process(_dt):
	if configured and (not is_instance_valid(world) or world.room != source_room):
		dispose(); return
	for enemy in members:
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
			dispose(); return
func dispose():
	# Disable immediately, including projectiles, before deferred tree removal.
	process_mode = Node.PROCESS_MODE_DISABLED
	if is_instance_valid(world):
		for enemy in members: world.enemies.erase(enemy)
	queue_free()
func _exit_tree():
	if is_instance_valid(world):
		for enemy in members: world.enemies.erase(enemy)
