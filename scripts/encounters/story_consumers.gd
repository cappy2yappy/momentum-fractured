extends RefCounted
## Explicit consumer callbacks registered on the sole StoryDirector before load_data.
## Creator-surveyed placement/config data is provided by the composition root.
const Encounter = preload("res://scripts/encounters/encounter.gd")
const HazardAdapter = preload("res://scripts/hazards/story_hazard_adapter.gd")
var world
var hazards = HazardAdapter.new()
var active: Dictionary = {}
func _init(host): world = host
func register_encounter(story, id: String, entries: Array) -> bool:
	return story.register_effect_consumer("spawn_encounter", id, _spawn.bind(id, entries.duplicate(true)))
func register_hazard(story, id: String, hazard, enabled_when: Array, disabled_when: Array) -> bool:
	hazards.bind(hazard, enabled_when, disabled_when)
	return story.register_effect_consumer("arm_hazard", id, _arm)
func _spawn(_context: Dictionary, id: String, entries: Array) -> void:
	if is_instance_valid(active.get(id)): return
	var encounter = Encounter.new()
	world.add_child(encounter)
	var errors = encounter.configure(world, entries)
	if not errors.is_empty():
		push_error("Encounter consumer rejected %s: %s" % [id, errors]); encounter.queue_free(); return
	active[id] = encounter
	encounter.completed.connect(func(event):
		if is_instance_valid(world) and world.get("story") != null:
			world.story.report(event, {"room": world.room}))
func _arm(_context: Dictionary) -> void:
	# The rule sets the authoritative expansion_flag before requesting this effect.
	hazards.refresh(world)
func update() -> void:
	hazards.update(world)
func dispose() -> void:
	for encounter in active.values():
		if is_instance_valid(encounter): encounter.dispose()
	active.clear(); hazards.bindings.clear()
