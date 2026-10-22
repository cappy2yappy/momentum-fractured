extends RefCounted
## Consumer owned by the sole StoryDirector. No saves, flag writes or event bus.
## Call refresh at room_loaded / on_flag, and update each tick for occupied deferral.
var bindings: Array = []
func bind(hazard, enabled_when: Array, disabled_when: Array) -> void:
	bindings.append({"hazard": hazard, "enabled_when": enabled_when.duplicate(), "disabled_when": disabled_when.duplicate()})
func refresh(world) -> void:
	for binding in bindings:
		var hazard = binding.hazard
		if not is_instance_valid(hazard): continue
		var enabled = hazard.placement.initially_enabled
		for flag in binding.enabled_when: enabled = enabled and world.expansion_flags.get(flag, false) == true
		for flag in binding.disabled_when: enabled = enabled and world.expansion_flags.get(flag, false) != true
		# Both directions wait; never alter a live volume beneath the player.
		if not hazard.occupied(): hazard.set_enabled(enabled)
func update(world) -> void:
	refresh(world)
