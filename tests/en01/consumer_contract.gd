extends SceneTree
## Adapter boundary validation; no director substitute executes gameplay effects.
const Consumers = preload("res://scripts/encounters/story_consumers.gd")
const Hazard = preload("res://scripts/hazards/environmental_hazard.gd")
const Placement = preload("res://scripts/hazards/hazard_placement.gd")
class Registry extends RefCounted:
	var entries: Dictionary = {}
	func register_effect_consumer(kind: String, id: String, handler: Callable) -> bool:
		var key = kind + ":" + id
		if entries.has(key): return false
		entries[key] = handler
		return true
var failures = 0
var checks = 0
func _init(): call_deferred("run")
func check(ok, label):
	checks += 1
	print("PASS: " if ok else "FAIL: ", label)
	if not ok: failures += 1
func run():
	await process_frame
	var w=load("res://scenes/encounters/guard.tscn").instantiate()
	root.add_child(w); current_scene=w
	var consumers=Consumers.new(w)
	var registry=Registry.new()
	var entry={"version":1,"id":"Legacy-Guard","position":[700,620],"territory":[500,900],"completion_event":"evt/guard_complete"}
	for event in ["evt/Invalid-Event","evt/no-dashes","evt/no//empty","evt/9digit","evt/"+"a".repeat(45),"legacy_complete",42]:
		var bad=entry.duplicate(true); bad.completion_event=event
		check(not consumers.register_encounter(registry,"bad_event",[bad]) and registry.entries.is_empty(),"Reject malformed bridged event atomically: " + str(event))
	for entries in [null,{},[],[null],[entry,entry]]:
		check(not consumers.register_encounter(registry,"bad_entries",entries) and registry.entries.is_empty(),"Reject malformed/duplicate encounter batch atomically")
	check(not consumers.register_encounter(null,"target",[entry]) and not consumers.register_encounter(42,"target",[entry]) and not consumers.register_encounter(registry,42,[entry]),"Reject bad registry target or consumer key type")
	check(consumers.register_encounter(registry,"legacy_consumer_key",[entry]),"Valid bridge keeps legacy member and consumer identifiers")
	check(not consumers.register_encounter(registry,"legacy_consumer_key",[entry]) and registry.entries.size()==1,"Duplicate consumer registration remains atomic")
	var hazard=Hazard.new(); hazard.placement=Placement.new()
	for flags in [["trap/Invalid-Flag"],["obj/9bad"],["trap/"+"x".repeat(44)],[42],[null],"trap/not_array",{}]:
		var count=registry.entries.size()
		check(not consumers.register_hazard(registry,"bad_hazard",hazard,flags,[]) and registry.entries.size()==count and consumers.hazards.bindings.is_empty(),"Reject malformed enabling flags atomically")
	check(not consumers.register_hazard(registry,"bad_disabled",hazard,[],["trap/Invalid-Flag"]) and consumers.hazards.bindings.is_empty(),"Disabled flags obey same strict contract")
	w.expansion_flags["trap/Invalid-Flag"]=true
	check(not consumers.register_hazard(registry,"bad_existing",hazard,["trap/Invalid-Flag"],[]),"Existing malformed reserved key cannot bypass contract")
	w.expansion_flags["old_route/custom_flag"]=false
	w.expansion_flags["untyped_legacy"]="yes"
	check(not consumers.register_hazard(registry,"unknown_legacy",hazard,["unknown_legacy"],[]) and not consumers.register_hazard(registry,"untyped_legacy",hazard,["untyped_legacy"],[]),"Unknown and nonboolean legacy flags fail closed")
	check(not consumers.register_hazard(registry,"missing_target",null,[],[]) and consumers.hazards.bindings.is_empty(),"Missing hazard target leaves no registration or binding")
	var invalid_target=Node.new()
	check(not consumers.register_hazard(registry,"wrong_target",invalid_target,[],[]),"Wrong hazard target rejected before binding")
	invalid_target.free()
	hazard.placement.warning_seconds=0.1
	check(not consumers.register_hazard(registry,"bad_placement",hazard,[],[]),"Invalid hazard resource rejected before registration")
	hazard.placement.warning_seconds=0.6
	check(consumers.register_hazard(registry,"valid_hazard",hazard,["trap/valid_flag","junction_return","skyworks_wind_intake","lore_20","old_route/custom_flag"],[]),"Valid new flags and explicit/existing boolean legacy reads accepted")
	var bindings=consumers.hazards.bindings.size(); var registered=registry.entries.size()
	check(not consumers.register_hazard(registry,"valid_hazard",hazard,[],[]) and consumers.hazards.bindings.size()==bindings and registry.entries.size()==registered,"Duplicate hazard failure leaves bindings and registry unchanged")
	check(not consumers.register_hazard(registry,"bad_type",hazard,[],true) and consumers.hazards.bindings.size()==bindings,"Disabled list type validated before binding")
	consumers.dispose(); hazard.free(); w.free(); current_scene=null
	print("EN01 CONSUMER CONTRACT: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
