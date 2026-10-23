extends SceneTree
## Dispatches actual mouse/key input through the viewport's normal Input pipeline.
var studio
var checks = 0
var failures = 0
func _init(): call_deferred("run")
func check(ok,label):
 checks += 1; print("PASS: " if ok else "FAIL: ",label)
 if not ok: failures += 1
func motion(at,held = false):
 var event = InputEventMouseMotion.new(); event.position = at; event.global_position = at
 event.button_mask = MOUSE_BUTTON_MASK_LEFT if held else 0
 Input.parse_input_event(event); Input.flush_buffered_events()
 await process_frame
func button(at,pressed,alt = false):
 var event = InputEventMouseButton.new(); event.position = at; event.global_position = at
 event.button_index = MOUSE_BUTTON_LEFT; event.pressed = pressed; event.alt_pressed = alt
 event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
 Input.parse_input_event(event); Input.flush_buffered_events()
 await process_frame
func click(at):
 await motion(at); await button(at,true); await button(at,false)
func key(code):
 var event = InputEventKey.new(); event.keycode = code; event.pressed = true
 Input.parse_input_event(event); Input.flush_buffered_events(); await process_frame
 event = InputEventKey.new(); event.keycode = code; event.pressed = false
 Input.parse_input_event(event); Input.flush_buffered_events(); await process_frame
func marker(path):
 var row = studio.handles.handle_layout().get(path,{})
 return studio.handles.viewport_point(row.point) if not row.is_empty() else Vector2(INF,INF)
func drag_move(path,delta,outside = false):
 var joint = studio.actor.get_node(path); var transform_ = joint.get_parent().get_global_transform_with_canvas()
 var at = marker(path)
 if not at.is_finite(): check(false,"Drag target must be visible: "+path); return
 var to = at+(transform_*delta-transform_*Vector2.ZERO)
 await motion(at); await button(at,true)
 await motion(to,true)
 await button(Vector2(1020,635) if outside else to,false)
func run():
 await process_frame
 root.size = Vector2i(1280,720)
 studio = load("res://tools/cin_tools_03/studio.tscn").instantiate(); root.add_child(studio)
 studio.saved_path = "res://build/cin_tools_03/pointer_profile/"+DisplayServer.get_name()+"/sprint_stop.tres"
 studio.scrub(1.9)
 for i in 6: await process_frame
 var h = studio.handles
 var layout = h.handle_layout()
 check(layout.size() == studio.JOINTS.size(),"All 18 FK pivots, including Hand/Boot children, have visible handles at Fit")
 for path in studio.JOINTS:
  var at = marker(path)
  if not at.is_finite(): check(false,"Missing handle "+path); continue
  await click(at)
  check(studio.JOINTS[studio.joint_picker.selected] == path,"Input click selects "+path)
 for selected in studio.JOINTS:
  studio.select_canvas_joint(selected)
  var all_reachable = true
  layout = h.handle_layout()
  for path in layout:
   if h.hit_test(layout[path].point).path != path: all_reachable = false
  check(all_reachable,"No rotation-grip occlusion with selected "+selected)
 check(not studio.pending_pose and studio.preview_undo.is_empty(),"Selection clicks never create pose edits or undo entries")
 var torso_path = "Rig/Torso"
 await motion(marker(torso_path))
 check(h.hover_joint == torso_path,"Normal mouse motion exposes hovered joint")
 var clip_before = studio.session_clip.duplicate(true)
 for path in ["Rig/Torso","Rig/Torso/Head","Rig/Torso/Hair","Rig/Torso/Ribbon","Rig/Torso/ArmNear","Rig/Torso/ArmFar/Forearm","Rig/LegNear","Rig/LegFar/Shin","Rig/Torso/ArmNear/Forearm/Hand","Rig/LegFar/Shin/Boot"]:
  studio.scrub(1.9)
  var joint = studio.actor.get_node(path); var before = joint.position; var history = studio.history.size()
  await drag_move(path,Vector2(11,-7))
  check(joint.position.is_equal_approx(before+Vector2(11,-7)),"Input drag moves in correct parent coordinates: "+path)
  check(studio.preview_undo.size() == 1 and studio.history.size() == history and studio.pending_pose,"One completed drag is one unkeyed undo: "+path)
  studio.undo_pose()
  check(joint.position.is_equal_approx(before) and not studio.pending_pose,"Undo restores pre-drag pose: "+path)
 # Native clip data remains untouched until Key pose.
 check(studio.session_clip.get_track_count() == clip_before.get_track_count(),"Unkeyed gestures add no animation tracks")
 studio.scrub(1.9)
 var joint = studio.actor.get_node("Rig/Torso/Head"); var before = joint.position
 await drag_move("Rig/Torso/Head",Vector2(13,9))
 check(not studio.save_clip(),"Save refuses an unkeyed pointer preview")
 studio.key_pose()
 check(studio.save_clip(),"Explicit Key pose permits save of the dragged joint")
 studio.scrub(1.9)
 check(joint.position.is_equal_approx(before+Vector2(13,9)),"Keyed pointer position survives scrub")
 studio.undo_pose(); studio.scrub(1.9)
 check(joint.position.is_equal_approx(before),"Undo after keying restores the prior native clip")
 check(studio.reload_clip(),"Reload restores saved pointer-authored session")
 studio.preset = load(studio.preset_path("director")); studio.open_preset()
 for t in [1.9,6.1]:
  studio.scrub(t)
  check(studio.actor.get_node("Rig/Torso/Head").position.is_equal_approx(before+Vector2(13,9)) and studio.actor.clip == studio.session_clip,"Pointer-authored clip reused at sequence %.1f" % t)
 # Inverse transforms include native shot pan, rotation, zoom and every FK ancestor.
 studio.scrub(6.1)
 studio.joint_picker.select(studio.JOINTS.size()); studio.sync_fields()
 studio.pos_x.value = -170; studio.pos_y.value = -355; studio.angle.value = 12; studio.zoom.value = 1.25; studio.key_pose()
 for dimensions in [Vector2i(1024,640),Vector2i(1440,900)]:
  root.size = dimensions
  for i in 6: await process_frame
  for zoom in [1.,1.5,2.]:
   studio.canvas_zoom = zoom; studio.fit_stage(); studio.scrub(6.1)
   var path = "Rig/Torso"; joint = studio.actor.get_node(path); var position_before = joint.position
   await drag_move(path,Vector2(8,-4))
   check(joint.position.is_equal_approx(position_before+Vector2(8,-4)),"Move transform correct at %s / canvas %.1fx / rotated Director" % [dimensions,zoom])
   studio.undo_pose()
 # Rotate a child about its own parent-space pivot, through transformed canvas.
 studio.canvas_zoom = 1.; studio.fit_stage(); studio.scrub(6.1)
 var path = "Rig/Torso/ArmNear/Forearm"; studio.select_canvas_joint(path)
 joint = studio.actor.get_node(path); var rotation_before = joint.rotation
 layout = h.handle_layout(); var at = h.viewport_point(h.rotation_grip(layout))
 var transform_ = joint.get_parent().get_global_transform_with_canvas()
 var parent_point = transform_.affine_inverse()*at
 var to = transform_*(joint.position+(parent_point-joint.position).rotated(deg_to_rad(25)))
 await motion(at); await button(at,true); await motion(to,true); await button(to,false)
 check(is_equal_approx(joint.rotation,wrapf(rotation_before+deg_to_rad(25),-PI,PI)),"Gold rotation grip uses the child pivot through all ancestor transforms")
 studio.undo_pose()
 check(is_equal_approx(joint.rotation,rotation_before),"Rotation gesture undo restores the whole gesture")
 # Alt-drag rotation uses the same pivot math, without requiring the gold grip.
 studio.scrub(6.1); path = "Rig/Torso/Head"; studio.select_canvas_joint(path)
 joint = studio.actor.get_node(path); rotation_before = joint.rotation
 at = marker(path); transform_ = joint.get_parent().get_global_transform_with_canvas()
 parent_point = transform_.affine_inverse()*at
 var near_pivot = at.distance_to(joint.get_global_transform_with_canvas().origin) < h.HIT_RADIUS
 to = at+Vector2(24,0) if near_pivot else transform_*(joint.position+(parent_point-joint.position).rotated(deg_to_rad(-18)))
 await motion(at); await button(at,true,true); await motion(to,true); await button(to,false)
 check(is_equal_approx(joint.rotation,wrapf(rotation_before+(.24 if near_pivot else deg_to_rad(-18)),-PI,PI)),"Alt-drag rotates a child; horizontal drag is stable at the exact pivot")
 studio.undo_pose()
 # Full affine inverse also handles non-uniformly scaled FK ancestors.
 studio.actor.get_node("Rig/Torso").scale = Vector2(1.1,.85)
 path = "Rig/Torso/ArmFar/Forearm/Hand"; joint = studio.actor.get_node(path); var hand_before = joint.position
 await drag_move(path,Vector2(10,-6))
 check(joint.position.is_equal_approx(hand_before+Vector2(10,-6)),"Move resolves non-uniformly scaled FK ancestors")
 studio.undo_pose(); studio.actor.get_node("Rig/Torso").scale = Vector2.ONE
 studio.scrub(6.1); var at_move = marker("Rig/Torso")
 var initial = studio.actor.get_node("Rig/Torso").position
 await button(at_move,true); await motion(at_move+Vector2(28,15),true); await key(KEY_ESCAPE); await button(at_move,false)
 check(h.drag_joint.is_empty() and studio.actor.get_node("Rig/Torso").position.is_equal_approx(initial) and not studio.pending_pose,"Escape cancels active drag without keying")
 await button(at_move,true); await motion(at_move+Vector2(21,9),true)
 root.focus_exited.emit()
 await process_frame
 await button(at_move,false)
 check(h.drag_joint.is_empty() and studio.actor.get_node("Rig/Torso").position.is_equal_approx(initial),"Window focus-loss signal cancels and restores active drag")
 # A resize/view change or hidden handles cancel rather than jump coordinates.
 await button(at_move,true); await motion(at_move+Vector2(18,10),true)
 studio.canvas_zoom = 1.5; studio.fit_stage(); await button(at_move,false)
 check(h.drag_joint.is_empty() and studio.actor.get_node("Rig/Torso").position.is_equal_approx(initial),"Changing canvas zoom cancels and restores a captured gesture")
 studio.canvas_zoom = 1.; studio.fit_stage(); studio.scrub(6.1); at_move = marker("Rig/Torso")
 await button(at_move,true); await motion(at_move+Vector2(18,10),true)
 studio.show_guides = false; await process_frame; await button(at_move,false)
 check(h.drag_joint.is_empty() and not studio.pending_pose,"Hiding handles cancels the active drag safely")
 studio.show_guides = true
 await drag_move("Rig/Torso",Vector2(9,3),true)
 check(h.drag_joint.is_empty() and studio.preview_undo.size() == 1,"Mouse release outside canvas ends capture as one gesture")
 studio.undo_pose(); studio.scrub(6.1)
 var buttons = studio.find_children("*","Button",true,false)
 for b in buttons:
  if b.text == "Play": await click(b.get_global_rect().get_center()); check(studio.running,"Canvas input does not consume Play button")
  if b.text == "Pause": await click(b.get_global_rect().get_center()); check(not studio.running,"Canvas input does not consume Pause button")
 var slider_at = studio.slider.get_global_rect().get_center()
 await click(slider_at)
 check(h.drag_joint.is_empty() and absf(studio.slider.value-4.2) < .3,"Native timeline receives mouse input after canvas release")
 studio.reduced_preview = true; studio.restart(); studio.scrub(6.1)
 check(h.handle_layout().is_empty() and studio.key_button.disabled,"Reduced motion disables pointer handles and editing")
 studio.reduced_preview = false; studio.restart(); studio.scrub(6.1)
 var position_before = studio.actor.get_node("Rig/Torso").position
 await drag_move("Rig/Torso",Vector2(5,5)); studio.scrub(6.1)
 check(studio.actor.get_node("Rig/Torso").position.is_equal_approx(position_before) and not studio.pending_pose,"Scrubbing discards unkeyed properties absent from animation tracks")
 # Keep joint and shot previews in separate domains, even for programmatic selection.
 studio.scrub(6.1); studio.select_canvas_joint("Rig/Torso")
 await drag_move("Rig/Torso",Vector2(5,4))
 var frame_before = studio.cutin.get_node("Framing").position
 studio.joint_picker.select(studio.JOINTS.size()); studio.selection_changed(studio.JOINTS.size())
 check(studio.joint_picker.selected < studio.JOINTS.size(),"UI blocks switching from pending joint preview to shot framing")
 studio.joint_picker.select(studio.JOINTS.size()); studio.sync_fields(); studio.pos_x.value += 30.
 check(studio.cutin.get_node("Framing").position == frame_before,"Wrong-domain numeric field cannot mutate shot framing")
 studio.key_pose()
 check(studio.pending_pose and not studio.pending_joints.is_empty() and not studio.save_clip(),"Wrong-domain Key pose cannot clear joint dirtiness or enable Save")
 studio.select_canvas_joint("Rig/Torso"); studio.key_pose()
 check(not studio.pending_pose and studio.key_button.text == "Key pose","Key confirms pending joints and clears its count")
 studio.joint_picker.select(studio.JOINTS.size()); studio.sync_fields(); studio.pos_x.value += 20.
 var torso_before = studio.actor.get_node("Rig/Torso").position
 studio.joint_picker.select(2); studio.sync_fields(); studio.pos_x.value += 20.
 check(studio.actor.get_node("Rig/Torso").position == torso_before,"Wrong-domain numeric edit cannot mutate a joint during a shot preview")
 studio.key_pose()
 check(studio.pending_domain == "shot" and studio.pending_pose and not studio.save_clip(),"Wrong-domain joint key retains pending shot dirtiness")
 studio.scrub(6.1)
 # A single Key confirms a batch of joint drags; Undo restores the prior native clip.
 studio.select_canvas_joint("Rig/Torso")
 await drag_move("Rig/Torso",Vector2(3,2)); await drag_move("Rig/Torso/Head",Vector2(2,3))
 check(studio.pending_joints.size() == 2 and studio.key_button.text == "Key 2 joint poses","Multiple joint previews remain explicit before Key pose")
 studio.key_pose()
 check(studio.pending_joints.is_empty() and studio.key_button.text == "Key pose","One explicit Key commits the whole joint batch")
 var seed = load(studio.preset_path("director")).instantiate()
 studio.session_shot = seed.get_node("AnimationPlayer").get_animation("standard").duplicate(true); seed.free()
 check(studio.session_shot.find_track(NodePath("Framing:rotation"),Animation.TYPE_VALUE) < 0,"Editing a Studio instance never pollutes its cached seed AnimationLibrary")
 studio.preset = load(studio.preset_path("director")); studio.open_preset(); studio.scrub(6.1)
 studio.joint_picker.select(studio.JOINTS.size()); studio.sync_fields(); studio.angle.value = 8.
 studio.scrub(6.1)
 check(is_zero_approx(studio.cutin.get_node("Framing").rotation),"Scrub discards unkeyed shot rotation even when the seed has no rotation track")
 studio.queue_free()
 for i in 4: await process_frame
 print("CIN-TOOLS-03 POINTER: %d checks, %d failure(s)" % [checks,failures])
 quit(1 if failures else 0)
