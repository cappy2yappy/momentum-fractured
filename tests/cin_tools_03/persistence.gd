extends SceneTree
## Writer and reader are launched in separate OS processes by run_qa.py.
var checks = 0
var failures = 0
func _init(): call_deferred("run")
func check(ok,label):
 checks += 1
 print("PASS: " if ok else "FAIL: ",label)
 if not ok: failures += 1
func run():
 await process_frame
 var studio = load("res://tools/cin_tools_03/studio.tscn").instantiate()
 root.add_child(studio); studio.set_process(false)
 var writing = "--write-example" in OS.get_cmdline_user_args()
 if writing:
  studio.scrub(1.9); studio.joint_picker.select(2); studio.sync_fields()
  studio.angle.value = 12.; studio.key_pose()
  studio.preset = load(studio.preset_path("director")); studio.open_preset(); studio.set_process(false)
  studio.scrub(6.1); studio.joint_picker.select(studio.JOINTS.size()); studio.sync_fields()
  studio.pos_x.value = -70.; studio.pos_y.value = -35.; studio.zoom.value = 1.15; studio.angle.value = 0.; studio.key_pose()
  check(studio.save_clip(),"Writer saves native session and reusable exports")
 else:
  check(studio.reload_clip(),"Fresh process reloads saved native resources")
  var exported = studio.safe_load(studio.saved_path,"Animation")
  check(studio.valid_clip(exported),"Standalone exported Animation is reusable")
  var i = exported.find_track(NodePath("Rig/Torso:rotation"),Animation.TYPE_VALUE) if exported else -1
  check(i >= 0 and is_equal_approx(exported.value_track_interpolate(i,1.9),deg_to_rad(12.)),"Export contains the authored pose")
  studio.preset = load(studio.preset_path("director")); studio.open_preset(); studio.set_process(false)
 for t in [1.9,6.1]:
  studio.scrub(t)
  check(studio.actor.clip == studio.session_clip,"Exact same clip object bound in shot at %.1f s" % t)
  check(is_equal_approx(studio.actor.get_node("Rig/Torso").rotation_degrees,12.),"Authored pose at matching clip time %.1f s" % t)
 studio.scrub(1.9)
 check(studio.cutin.get_node("Framing").position == Vector2.ZERO and studio.cutin.get_node("Framing").scale == Vector2.ONE,"Shot one retains independent wide framing")
 studio.scrub(6.1)
 check(studio.cutin.get_node("Framing").position == Vector2(-70,-35) and is_equal_approx(studio.cutin.get_node("Framing").scale.x,1.15),"Shot two retains saved pan and zoom")
 studio.queue_free()
 for i in 4: await process_frame
 print("CIN-TOOLS-03 PERSISTENCE: %d checks, %d failure(s)" % [checks,failures])
 quit(1 if failures else 0)
