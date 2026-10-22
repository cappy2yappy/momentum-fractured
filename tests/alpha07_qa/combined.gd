extends SceneTree
const Presenter = preload("res://scripts/story/cutin_presenter.gd")
const Host = preload("res://tests/alpha07_qa/counting_world.gd")
var failures = 0
var checks = 0
var w
var p
func _init(): call_deferred("run")
func check(ok, label):
 checks += 1
 if not ok: failures += 1
 print(("PASS: " if ok else "FAIL: ") + label)
func tick(n):
 for i in n: w.story.update(w,1.0/60.0)
func capture(name):
 if DisplayServer.get_name() == "headless": return
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://build/alpha07_qa/" + name + ".png")
func snapshot():
 return [w.room,w.completed,w.checkpoint_room,w.checkpoint_position,w.player.hp,w.player.double_jump,w.player.tether_unlocked,w.player.dash_unlocked,w.opened_kunai_gates.duplicate(true)]
func run():
 await process_frame
 DirAccess.make_dir_recursive_absolute("res://build/alpha07_qa")
 w = Host.new()
 root.add_child(w); current_scene = w
 w.set_physics_process(false)
 w.player.set_physics_process(true)
 for enemy in w.enemies: enemy.set_physics_process(false)
 w.test_mode = false
 w.save_path = "res://build/alpha07_qa/disposable.json"
 DirAccess.remove_absolute(w.save_path)
 w.expansion_flags.clear(); w.cleared_encounters.clear()
 p = Presenter.new(); root.add_child(p); p.configure(w)
 w.story.cutin_presenter = p
 var before = snapshot()
 await capture("before")
 var ids = ["opening_review","record_review","fallen_clan_review"]
 for i in 3:
  var flag = "evt/qa_committed_%d" % i
  w.story.rules = [{"trigger":"evt/qa_trigger", "effects":[{"kind":"request_cutin","id":ids[i]},{"kind":"set_flag","id":flag}]}]
  var count = w.qa_save_calls
  w.transition = .3
  w.story.report("evt/qa_trigger")
  check(not w.story.has(flag) and w.qa_save_calls == count and p.pending.is_empty(), ids[i] + " event and presentation defer together")
  w.transition = 0; w.player.set_physics_process(false); tick(1)
  check(not w.story.has(flag), ids[i] + " waits for input ownership restoration")
  w.player.set_physics_process(true); tick(1)
  check(w.story.has(flag) and w.qa_save_calls == count + 1 and p.pending.size() == 1, ids[i] + " state saved exactly once before request")
  tick(1)
  check(p.active_id == ids[i] and not w.player.is_physics_processing(), ids[i] + " director starts real presenter")
  tick(30)
  await capture(ids[i])
  var disk = FileAccess.get_file_as_bytes(w.save_path)
  var skip = InputEventJoypadButton.new(); skip.button_index = JOY_BUTTON_B; skip.pressed = true
  p._unhandled_input(skip)
  tick(1)
  check(p.active_id.is_empty() and w.player.is_physics_processing() and w.qa_save_calls == count + 1 and disk == FileAccess.get_file_as_bytes(w.save_path), ids[i] + " gamepad skip preserves committed disk state")
  w.story.report("evt/qa_trigger"); tick(2); p.cancel("qa_repeat")
  check(w.qa_save_calls == count + 1, ids[i] + " repeated event cannot resave existing flag")
 # Real same-room rebuild cancellation via production StoryDirector hook.
 p.request_cutin("record_review"); tick(1)
 w.build_room(w.room)
 check(p.active_id.is_empty() and w.player.is_physics_processing(), "production same-room rebuild cancels presenter and restores input")
 for enemy in w.enemies: enemy.set_physics_process(false)
 w.story.rules = [{"trigger":"evt/qa_disabled", "effects":[{"kind":"request_cutin","id":"record_review"},{"kind":"set_flag","id":"evt/qa_disabled_committed"}]}]
 p.enabled = false
 w.story.report("evt/qa_disabled"); tick(2)
 check(w.story.has("evt/qa_disabled_committed") and p.active_id.is_empty(), "disabled presentation keeps identical progression effect")
 p.enabled = true; p.reduced = true
 p.request_cutin("record_review"); tick(1); tick(60)
 check(p.active_id.is_empty() and w.player.is_physics_processing(), "reduced presentation restores input through director tick")
 w.story.rules = [{"trigger":"evt/qa_unknown_cutin", "effects":[{"kind":"request_cutin","id":"missing_review"},{"kind":"set_flag","id":"evt/qa_unknown_committed"}]}]
 w.story.report("evt/qa_unknown_cutin"); tick(1)
 check(w.story.has("evt/qa_unknown_committed") and p.last_outcome == "unknown_id", "missing cinematic cannot prevent progression")
 var count = w.qa_save_calls
 var disk = FileAccess.get_file_as_bytes(w.save_path)
 w.transition = .4
 w.story.record_encounter("en01/qa_deferred")
 w.story.record_encounter("en01/qa_deferred")
 check(not w.cleared_encounters.has("en01/qa_deferred") and w.qa_save_calls == count and disk == FileAccess.get_file_as_bytes(w.save_path), "duplicate managed defeat has no transition writes")
 w.transition = 0; w.player.set_physics_process(false); tick(2)
 check(not w.cleared_encounters.has("en01/qa_deferred"), "managed defeat waits for control restoration")
 w.player.set_physics_process(true); tick(2)
 check(w.cleared_encounters.get("en01/qa_deferred",false) and w.qa_save_calls == count + 1, "managed defeat flushes exactly one real save")
 w.story.record_encounter("en01/qa_deferred"); tick(2)
 check(w.qa_save_calls == count + 1, "replayed managed defeat does not resave")
 # Explicit real encounter and hazard consumers on the sole director.
 var Consumers = load("res://scripts/encounters/story_consumers.gd")
 var consumers = Consumers.new(w)
 var entries = [{"version":1,"id":"qa_encounter","type":"guard","position":[700,1300],"territory":[500,900],"persistent":true,"activation":"immediate","completion_event":"evt/qa_encounter_complete"}]
 check(consumers.register_encounter(w.story,"qa_encounter",entries), "encounter registers sole-director consumer")
 check(not consumers.register_encounter(w.story,"qa_encounter",entries), "duplicate encounter consumer rejected")
 var Hazard = load("res://scripts/hazards/environmental_hazard.gd")
 var Placement = load("res://scripts/hazards/hazard_placement.gd")
 var hazard = Hazard.new(); hazard.placement = Placement.new(); hazard.placement.placement_id = "qa_hazard"; hazard.placement.at = Vector2(1000,1150); hazard.placement.dimensions = Vector2(96,100); hazard.player = w.player
 w.add_child(hazard); hazard.set_physics_process(false)
 check(consumers.register_hazard(w.story,"qa_hazard",hazard,["trap/qa_hazard"],[]), "hazard registers sole-director consumer")
 consumers.update()
 check(not hazard.enabled, "hazard consumer reads unmet authoritative flag")
 var unknown = {"contract":1,"rules":[{"trigger":"evt/qa_bad","effects":[{"kind":"spawn_encounter","id":"not_registered"}]}]}
 check(not w.story.Definition.validate_rules(unknown,w.story.effect_consumers).is_empty(), "unknown closed effect consumer rejected at validation")
 w.story.rules = [{"trigger":"evt/qa_spawn", "effects":[{"kind":"spawn_encounter","id":"qa_encounter"}]},{"trigger":"evt/qa_encounter_complete", "effects":[{"kind":"set_flag","id":"enc/qa_complete"}]},{"trigger":"evt/qa_arm", "effects":[{"kind":"set_flag","id":"trap/qa_hazard"},{"kind":"arm_hazard","id":"qa_hazard"}]}]
 w.transition = .5; w.story.report("evt/qa_spawn")
 check(consumers.active.is_empty(), "consumer dispatch waits during transition")
 w.transition = 0; tick(1)
 check(consumers.active.has("qa_encounter"), "director dispatch creates real encounter through shared spawn path")
 var encounter = consumers.active.get("qa_encounter")
 encounter.set_physics_process(false)
 var enemy = encounter.members[0]; enemy.set_physics_process(false); enemy.state = "patrol"
 count = w.qa_save_calls
 w.transition = .5; enemy.receive_hit(100)
 await process_frame
 await process_frame
 check(not is_instance_valid(enemy), "actual defeated enemy freed before transition restoration")
 check(not w.cleared_encounters.get("en01/qa_encounter",false) and not w.story.has("enc/qa_complete") and w.qa_save_calls == count, "real enemy defeat defers persistence and completion during transition")
 w.transition = 0; w.player.set_physics_process(false); encounter.flush_defeats(); tick(1)
 check(not w.story.has("enc/qa_complete") and w.qa_save_calls == count, "real enemy completion waits for restored controls")
 w.player.set_physics_process(true); tick(1); encounter.flush_defeats(); tick(1)
 check(w.cleared_encounters.get("en01/qa_encounter",false) and w.story.has("enc/qa_complete") and w.qa_save_calls == count + 2, "real enemy deferred defeat saves once and completion flag saves once")
 count = w.qa_save_calls; encounter.flush_defeats(); tick(1)
 check(w.qa_save_calls == count, "real enemy completion has no replay writes")
 w.story.report("evt/qa_arm"); consumers.update()
 check(w.story.has("trap/qa_hazard") and hazard.enabled, "director flag effect enables registered hazard consumer")
 await capture("encounter_hazard_consumers")
 consumers.dispose(); hazard.queue_free()
 var expected = w.expansion_flags.duplicate(true)
 w.expansion_flags.clear(); w.cleared_encounters.clear(); w.load_progress()
 check(w.expansion_flags == expected and w.cleared_encounters.get("en01/qa_deferred",false), "real version-8 disk reload restores story and encounter dictionaries")
 check(snapshot() == before, "story/presenter/save integration preserves progression snapshot")
 await capture("after_control_restored")
 p.queue_free(); w.queue_free(); current_scene = null
 for i in 3: await process_frame
 print("ALPHA07 COMBINED: %d checks, %d failure(s)" % [checks,failures])
 quit(1 if failures else 0)
