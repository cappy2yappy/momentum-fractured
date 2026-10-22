extends RefCounted
## Explicit consumer callbacks registered on the sole StoryDirector before load_data.
## Creator-surveyed placement/config data is provided by the composition root.
const Config = preload("res://scripts/encounters/config.gd")
const LEGACY_FLAGS = ["junction_return", "skyworks_wind_intake"]
const STORY_NAMESPACES = ["disc", "evt", "trap", "enc", "obj"]
const Encounter = preload("res://scripts/encounters/encounter.gd")
const HazardAdapter = preload("res://scripts/hazards/story_hazard_adapter.gd")
var world
var hazards = HazardAdapter.new()
var active: Dictionary = {}
func _init(host): world = host
static func contract_id(value) -> bool:
	if not value is String or value.length() > 48: return false
	var pattern = RegEx.new()
	pattern.compile("^(disc|evt|trap|enc|obj)/[a-z][a-z0-9_]*(/[a-z][a-z0-9_]*)*$")
	return pattern.search(value) != null
func flag_read_id(value) -> bool:
	if not value is String or value.is_empty(): return false
	# Reserved story namespaces always obey the new contract, even if a bad old
	# key happens to be in a loaded map. Legacy names are reads only.
	if value.get_slice("/", 0) in STORY_NAMESPACES: return contract_id(value)
	if value in LEGACY_FLAGS: return true
	for room in range(21):
		if value == "lore_%d" % room: return true
	var flags = world.get("expansion_flags")
	return flags is Dictionary and flags.has(value) and flags[value] is bool
func registry_valid(story, id) -> bool:
	return world is Object and is_instance_valid(world) and story is Object and is_instance_valid(story) and story.has_method("register_effect_consumer") and id is String and not id.is_empty()
func register_encounter(story, id, entries) -> bool:
	if not registry_valid(story, id) or not entries is Array or entries.is_empty(): return false
	var platforms = world.get("platforms")
	if not platforms is Array: return false
	var ids = {}
	for entry in entries:
		var result = Config.validate(entry, platforms)
		if not result.errors.is_empty(): return false
		var config = result.config
		if ids.has(config.id): return false
		ids[config.id] = true
		if config.completion_event != "" and not contract_id(config.completion_event): return false
	return story.register_effect_consumer("spawn_encounter", id, _spawn.bind(id, entries.duplicate(true)))
func register_hazard(story, id, hazard, enabled_when, disabled_when) -> bool:
	if not registry_valid(story, id) or not enabled_when is Array or not disabled_when is Array: return false
	if not hazard is Object or not is_instance_valid(hazard) or not hazard.has_method("occupied") or not hazard.has_method("set_enabled"): return false
	var placement = hazard.get("placement")
	if not placement is Object or not is_instance_valid(placement) or not placement.has_method("validation_errors") or not placement.validation_errors().is_empty(): return false
	for flag in enabled_when + disabled_when:
		if not flag_read_id(flag): return false
	# Duplicate/missing registry rejection must not leave a hidden binding behind.
	if not story.register_effect_consumer("arm_hazard", id, _arm): return false
	hazards.bind(hazard, enabled_when, disabled_when)
	return true
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
