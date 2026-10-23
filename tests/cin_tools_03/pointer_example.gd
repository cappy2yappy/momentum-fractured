extends SceneTree
var checks = 0
var failures = 0
func _init(): call_deferred("run")
func check(ok,label):
 checks += 1; print("PASS: " if ok else "FAIL: ",label)
 if not ok: failures += 1
func run():
 await process_frame
 var studio = load("res://tools/cin_tools_03/studio.tscn").instantiate(); root.add_child(studio)
 studio.saved_path = "res://presets/cutins/studio/pointer_example/sprint_stop.tres"
 check(studio.reload_clip(),"Fresh process reloads the actual saved native FK demo")
 var exported = studio.safe_load(studio.saved_path,"Animation")
 check(studio.valid_clip(exported),"FK demo standalone clip validates")
 var track = exported.find_track(NodePath("Rig/Torso/Head:position"),Animation.TYPE_VALUE)
 check(track >= 0 and exported.value_track_interpolate(track,1.9).is_equal_approx(Vector2(23,-121)),"Native recorded Head drag persists in the exported clip")
 studio.preset = load(studio.preset_path("director")); studio.open_preset()
 for t in [1.9,6.1]:
  studio.scrub(t)
  check(studio.actor.clip == studio.session_clip,"Native demo exact clip reused at %.1f" % t)
  check(studio.actor.get_node("Rig/Torso/Head").position.is_equal_approx(Vector2(23,-121)),"Native recorded pointer pose appears at %.1f" % t)
 studio.reduced_preview = true; studio.restart(); studio.scrub(6.1)
 check(studio.handles.handle_layout().is_empty() and studio.key_button.disabled,"Saved pointer demo retains static reduced-motion editing guard")
 studio.queue_free()
 for i in 4: await process_frame
 print("CIN-TOOLS-03 POINTER EXAMPLE: %d checks, %d failure(s)" % [checks,failures])
 quit(1 if failures else 0)
