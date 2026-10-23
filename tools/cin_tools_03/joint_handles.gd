extends Control
## Screen-sized FK controls. All editing is local to the Studio actor.
const HIT_RADIUS = 12.0
const SPACING = 23.0
var editor
var hover_joint = ""
var hovered_rotation = false
var drag_joint = ""
var drag_kind = ""
var press_viewport = Vector2.ZERO
var initial_position = Vector2.ZERO
var initial_rotation = 0.0
var initial_angle = 0.0
var linear_rotation = false
var gesture_snapshot = {}
var moved = false

func _ready():
 mouse_filter = Control.MOUSE_FILTER_PASS
 focus_mode = Control.FOCUS_NONE
 mouse_exited.connect(func():
  if drag_joint.is_empty(): hover_joint = ""; hovered_rotation = false; queue_redraw())
 get_window().focus_exited.connect(cancel_gesture)

func available():
 return is_instance_valid(editor) and is_instance_valid(editor.actor) and editor.show_guides and not editor.reduced_preview and editor.actor.get_node("Rig").visible and editor.actor.get_node("Rig").modulate.a > .01

func canvas_point(joint):
 return get_global_transform_with_canvas().affine_inverse() * joint.get_global_transform_with_canvas().origin

func viewport_point(local_point):
 return get_global_transform_with_canvas() * local_point

func canvas_rect():
 var frame = editor.preview_frame
 var transform_ = get_global_transform_with_canvas().affine_inverse() * frame.get_global_transform_with_canvas()
 return Rect2(transform_ * Vector2.ZERO,frame.size * transform_.get_scale())

func handle_layout():
 var result = {}
 if not available(): return result
 var canvas = canvas_rect()
 var bounds = canvas.grow(-HIT_RADIUS-2)
 for path in editor.JOINTS:
  var joint = editor.actor.get_node(path)
  var anchor = canvas_point(joint)
  if not canvas.has_point(anchor): continue
  var candidates = [Vector2.ZERO]
  for radius in [24.,36.,52.,72.]:
   for direction in [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN,Vector2(1,-1),Vector2(-1,-1),Vector2(1,1),Vector2(-1,1)]:
    candidates.append(direction.normalized()*radius)
  for offset in candidates:
   var at = anchor+offset
   if not bounds.has_point(at): continue
   var free = true
   for row in result.values():
    if at.distance_to(row.point) < SPACING: free = false; break
   if free:
    result[path] = {"point":at,"anchor":anchor}; break
 return result

func selected_path():
 if not is_instance_valid(editor.joint_picker) or editor.joint_picker.selected >= editor.JOINTS.size(): return ""
 return editor.JOINTS[editor.joint_picker.selected]

func rotation_grip(layout):
 var path = selected_path()
 if not layout.has(path): return Vector2(INF,INF)
 # Avoid covering another joint, including coincident head/hair and hip pivots.
 var bounds = canvas_rect().grow(-HIT_RADIUS-2)
 for radius in [42.,58.,76.]:
  for direction in [Vector2(1,-1),Vector2(-1,-1),Vector2(1,1),Vector2(-1,1),Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]:
   var at = layout[path].point+direction.normalized()*radius
   if not bounds.has_point(at): continue
   var free = true
   for row in layout.values():
    if at.distance_to(row.point) < HIT_RADIUS*2.+2.: free = false; break
   if free: return at
 return Vector2(INF,INF)

func hit_test(point):
 var layout = handle_layout()
 var path = selected_path()
 if layout.has(path) and point.distance_to(rotation_grip(layout)) <= HIT_RADIUS:
  return {"path":path,"kind":"rotate"}
 var closest = HIT_RADIUS; var chosen = ""
 for joint in layout:
  var distance = point.distance_to(layout[joint].point)
  if distance <= closest: closest = distance; chosen = joint
 return {"path":chosen,"kind":"move"}

func parent_pointer(path,point_viewport):
 var joint = editor.actor.get_node(path)
 return joint.get_parent().get_global_transform_with_canvas().affine_inverse()*point_viewport

func begin_gesture(path,kind,point_viewport):
 if not available() or path not in editor.JOINTS or not drag_joint.is_empty(): return false
 if editor.pending_pose and editor.pending_domain == "shot":
  editor.notice.text = "Key shot framing or scrub before posing joints."; return false
 editor.pause()
 editor.select_canvas_joint(path)
 drag_joint = path; drag_kind = kind; press_viewport = point_viewport
 var joint = editor.actor.get_node(path)
 initial_position = joint.position; initial_rotation = joint.rotation
 initial_angle = (parent_pointer(path,point_viewport)-initial_position).angle()
 linear_rotation = kind == "rotate" and point_viewport.distance_to(joint.get_global_transform_with_canvas().origin) < HIT_RADIUS
 gesture_snapshot = editor.pose_snapshot(); moved = false
 queue_redraw()
 return true

func update_gesture(point_viewport):
 if drag_joint.is_empty(): return
 if not available(): cancel_gesture(); return
 if not moved and point_viewport.distance_to(press_viewport) < 3.: return
 moved = true
 var joint = editor.actor.get_node(drag_joint)
 if drag_kind == "move":
  var delta = parent_pointer(drag_joint,point_viewport)-parent_pointer(drag_joint,press_viewport)
  joint.position = (initial_position+delta).clamp(Vector2(-2000,-2000),Vector2(2000,2000))
 elif linear_rotation:
  # At the pivot the starting polar angle is undefined. Horizontal Alt-drag is stable.
  joint.rotation = wrapf(initial_rotation+(point_viewport.x-press_viewport.x)*.01,-PI,PI)
 else:
  var vector = parent_pointer(drag_joint,point_viewport)-initial_position
  if vector.length_squared() > .0001:
   joint.rotation = wrapf(initial_rotation+angle_difference(initial_angle,vector.angle()),-PI,PI)
 editor.record_pending_joint(drag_joint)
 editor.sync_fields()
 editor.notice.text = "Unkeyed %s: %s. Key pose to keep it." % ["move" if drag_kind == "move" else "rotation",editor.joint_label(drag_joint)]
 queue_redraw()

func end_gesture():
 if drag_joint.is_empty(): return
 if moved: editor.push_preview_undo(gesture_snapshot)
 drag_joint = ""; drag_kind = ""; gesture_snapshot = {}; moved = false
 queue_redraw()

func cancel_gesture():
 if drag_joint.is_empty(): return
 if is_instance_valid(editor) and is_instance_valid(editor.actor):
  editor.restore_pose_snapshot(gesture_snapshot)
  editor.notice.text = "Drag cancelled. Nothing was keyed."
 drag_joint = ""; drag_kind = ""; gesture_snapshot = {}; moved = false
 queue_redraw()

func _gui_input(event):
 if event is InputEventMouseMotion and drag_joint.is_empty():
  var hit = hit_test(event.position)
  hover_joint = hit.path; hovered_rotation = hit.kind == "rotate" and not hit.path.is_empty()
  mouse_default_cursor_shape = Control.CURSOR_CROSS if not hover_joint.is_empty() else Control.CURSOR_ARROW
  queue_redraw()
 if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
  var hit = hit_test(event.position)
  if not hit.path.is_empty() and begin_gesture(hit.path,"rotate" if event.alt_pressed else hit.kind,viewport_point(event.position)):
   accept_event()

func _input(event):
 if drag_joint.is_empty(): return
 if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
  cancel_gesture(); get_viewport().set_input_as_handled()
 elif event is InputEventMouseMotion:
  update_gesture(event.position); get_viewport().set_input_as_handled()
 elif event is InputEventMouseButton:
  if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
   update_gesture(event.position); end_gesture()
  elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed: cancel_gesture()
  # Let GUI release bookkeeping run so the slider/buttons never inherit capture.
  if event.pressed: get_viewport().set_input_as_handled()

func _process(_dt):
 if not drag_joint.is_empty() and (not available() or not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)): cancel_gesture()
 queue_redraw()

func _draw():
 if not is_instance_valid(editor): return
 var font = ThemeDB.fallback_font
 draw_string(font,Vector2(8,16),"Drag dot: move   Gold grip / Alt-drag: rotate",HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("c9d7e4"))
 if not available():
  var reason = "Reduced motion: pose editing is disabled." if editor.reduced_preview else "Choose Rig only, or scrub past the sprite sprint to pose joints."
  if not is_instance_valid(editor.actor): reason = "Original Cut-In Maker preset: use its native timeline."
  draw_string(font,Vector2(8,34),reason,HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("ffc875"))
  return
 draw_string(font,Vector2(8,34),"Esc: cancel   Undo: one drag   Key pose: commit",HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("9bafc4"))
 var layout = handle_layout(); var selected = selected_path()
 for path in layout:
  var row = layout[path]; var node_ = editor.actor.get_node(path)
  var parent = node_.get_parent()
  if parent != editor.actor.get_parent() and parent is Node2D:
   draw_line(canvas_point(parent),row.anchor,Color(.45,.89,.76,.45),1,true)
  if row.anchor.distance_to(row.point) > 1:
   draw_line(row.anchor,row.point,Color(.8,.88,.92,.7),1,true)
   draw_circle(row.anchor,2,Color("d4e6ef"))
  var chosen = path == selected; var hover = path == hover_joint
  draw_circle(row.point,9 if chosen or hover else 7,Color("111d2b"))
  draw_arc(row.point,10 if chosen or hover else 8,0,TAU,28,Color("ffc875") if chosen else Color("72e2bb"),2,true)
  draw_circle(row.point,3,Color("ffc875") if chosen else Color("72e2bb"))
 if layout.has(selected):
  var grip = rotation_grip(layout)
  if not grip.is_finite(): return
  draw_line(layout[selected].point,grip,Color("ffc875"),2,true)
  draw_circle(grip,9,Color("111d2b"))
  draw_arc(grip,9,0,TAU,28,Color.WHITE if hovered_rotation else Color("ffc875"),2,true)
  draw_arc(grip,4,.2,TAU-.8,16,Color("ffc875"),2,true)
 var label_path = hover_joint if not hover_joint.is_empty() else selected
 if layout.has(label_path):
  var label = editor.joint_label(label_path)
  var at = layout[label_path].point+Vector2(14,22)
  var width = font.get_string_size(label,HORIZONTAL_ALIGNMENT_LEFT,-1,14).x+12
  at.x = clampf(at.x,4,size.x-width-4); at.y = clampf(at.y,62,size.y-20)
  draw_rect(Rect2(at-Vector2(4,15),Vector2(width,23)),Color(.025,.045,.075,.96))
  draw_string(font,at,label,HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("ffc875"))
