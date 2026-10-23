extends SceneTree
## Writer and reader are launched in separate OS processes by run_qa.py.
var checks = 0
var failures = 0
func _init(): call_deferred("run")
func check(ok,label):
 checks += 1
 print("PASS: " if ok else "FAIL: ",label)
 if not ok: failures += 1
func dispatch(event):
 Input.parse_input_event(event); Input.flush_buffered_events()
 await process_frame
func pointer_hand(studio):
 var path = "Rig/Torso/ArmNear/Forearm/Hand"
 var h = studio.handles; var point = h.viewport_point(h.handle_layout()[path].point)
 var joint = studio.actor.get_node(path); var transform_ = joint.get_parent().get_global_transform_with_canvas()
 var to = point+transform_*Vector2(14,-10)-transform_*Vector2.ZERO
 var press = InputEventMouseButton.new(); press.button_index = MOUSE_BUTTON_LEFT; press.pressed = true; press.position = point; press.global_position = point
 await dispatch(press)
 var move = InputEventMouseMotion.new(); move.position = to; move.global_position = to; move.button_mask = MOUSE_BUTTON_MASK_LEFT
 await dispatch(move)
 var release = InputEventMouseButton.new(); release.button_index = MOUSE_BUTTON_LEFT; release.position = to; release.global_position = to
 await dispatch(release)
 check(studio.pending_pose and joint.position.is_equal_approx(Vector2(14,36)),"Writer authors a Hand child through normal mouse input")
 studio.key_pose()
func run():
 await process_frame
 var studio = load("res://tools/cin_tools_03/studio.tscn").instantiate()
 root.add_child(studio); studio.set_process(false)
 var writing = "--write-example" in OS.get_cmdline_user_args()
 if writing:
  studio.scrub(1.9); studio.joint_picker.select(2); studio.sync_fields()
  studio.angle.value = 12.; studio.key_pose()
  for i in 6: await process_frame
  await pointer_hand(studio)
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
  var hand_track = exported.find_track(NodePath("Rig/Torso/ArmNear/Forearm/Hand:position"),Animation.TYPE_VALUE)
  check(hand_track >= 0 and exported.value_track_interpolate(hand_track,1.9).is_equal_approx(Vector2(14,36)),"Fresh process export retains mouse-authored leaf-joint key")
  studio.preset = load(studio.preset_path("director")); studio.open_preset(); studio.set_process(false)
 for t in [1.9,6.1]:
  studio.scrub(t)
  check(studio.actor.clip == studio.session_clip,"Exact same clip object bound in shot at %.1f s" % t)
  check(is_equal_approx(studio.actor.get_node("Rig/Torso").rotation_degrees,12.),"Authored pose at matching clip time %.1f s" % t)
  check(studio.actor.get_node("Rig/Torso/ArmNear/Forearm/Hand").position.is_equal_approx(Vector2(14,36)),"Mouse-authored Hand survives process/reuse at %.1f s" % t)
 studio.scrub(1.9)
 check(studio.cutin.get_node("Framing").position == Vector2.ZERO and studio.cutin.get_node("Framing").scale == Vector2.ONE,"Shot one retains independent wide framing")
 studio.scrub(6.1)
 check(studio.cutin.get_node("Framing").position == Vector2(-70,-35) and is_equal_approx(studio.cutin.get_node("Framing").scale.x,1.15),"Shot two retains saved pan and zoom")
 studio.queue_free()
 for i in 4: await process_frame
 print("CIN-TOOLS-03 PERSISTENCE: %d checks, %d failure(s)" % [checks,failures])
 quit(1 if failures else 0)
