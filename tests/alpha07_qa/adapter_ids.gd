extends SceneTree
const Consumers = preload("res://scripts/encounters/story_consumers.gd")
var failures = 0
func _init(): call_deferred("run")
func check(ok,label):
 print(("PASS: " if ok else "FAIL: ")+label)
 if not ok: failures += 1
func run():
 await process_frame
 var w = load("res://scenes/main.tscn").instantiate(); root.add_child(w); current_scene = w
 w.set_physics_process(false)
 for e in w.enemies:e.set_physics_process(false)
 var consumers = Consumers.new(w)
 var invalid_event = [{"version":1,"id":"qa_bad_event","position":[700,1300],"territory":[500,900],"completion_event":"evt/Invalid-Event"}]
 check(not consumers.register_encounter(w.story,"qa_bad_event",invalid_event),"production adapter rejects completion event incompatible with StoryDirector")
 var h = load("res://scripts/hazards/environmental_hazard.gd").new(); h.placement = load("res://scripts/hazards/hazard_placement.gd").new(); h.player = w.player; h.placement.at = Vector2(1000,1000); w.add_child(h)
 check(not consumers.register_hazard(w.story,"qa_bad_hazard",h,["trap/Invalid-Flag"],[]),"production adapter rejects invalid new story flag identifier")
 w.expansion_flags["old_route/qa"] = false
 check(consumers.register_hazard(w.story,"qa_legacy_hazard",h,["junction_return","old_route/qa"],[]),"actual director accepts explicit and stored boolean legacy read flags")
 var bindings = consumers.hazards.bindings.size()
 check(not consumers.register_hazard(w.story,"qa_legacy_hazard",h,[],[]) and consumers.hazards.bindings.size() == bindings,"actual director duplicate hazard registration has no hidden binding")
 consumers.dispose();w.queue_free();current_scene=null
 for i in 3: await process_frame
 print("ADAPTER IDENTIFIER CONTRACT: %d failure(s)" % failures)
 quit(1 if failures else 0)
