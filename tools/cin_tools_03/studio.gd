extends "res://tools/cin_tools_01/preview.gd"
## A connected workspace using the original Cut-In Maker preview and transport.
const CLIP = "res://presets/cutins/studio/sprint_stop.tres"
var saved_path = "user://cin_tools_03/sprint_stop.tres"
const JOINTS = [".", "Rig", "Rig/Torso", "Rig/Torso/Head", "Rig/Torso/Hair", "Rig/Torso/Ribbon", "Rig/Torso/ArmNear", "Rig/Torso/ArmNear/Forearm", "Rig/Torso/ArmFar", "Rig/Torso/ArmFar/Forearm", "Rig/LegNear", "Rig/LegNear/Shin", "Rig/LegFar", "Rig/LegFar/Shin"]
var workspace_selector: OptionButton
var heading: Label
var session_shot: Animation
var session_clip: Animation
var history: Array = []
var actor
var joint_picker: OptionButton
var zoom: SpinBox
var angle: SpinBox
var pos_x: SpinBox
var pos_y: SpinBox
var notice: Label
var mode_override = -1
var show_guides = true
var busy_ui = false
var playhead: SpinBox
var stage_slot: Control
var save_button: Button
var reload_button: Button
var key_button: Button
var timeline_row: HBoxContainer
var inspector: VBoxContainer
var storage_panel: VBoxContainer
var context_label: Label
var storage_label: Label
var timeline_marks: Control
var pending_pose = false

func preset_path(choice):
 if choice in ["animator", "director"]: return "res://presets/cutins/studio/" + choice + ".tscn"
 return super.preset_path(choice)

func _ready():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--studio-save-dir="): saved_path = arg.trim_prefix("--studio-save-dir=").path_join("sprint_stop.tres")
 session_clip = load(CLIP).duplicate(true)
 var seed_shot = load("res://presets/cutins/studio/director.tscn").instantiate()
 session_shot = seed_shot.get_node("AnimationPlayer").get_animation("standard").duplicate(true)
 seed_shot.free()
 choices = ["animator", "director", "special_transition", "major_biome", "boss_intro"]
 preset = load(preset_path("animator"))
 super._ready()
 # Rehouse the existing Cut-In Maker controls. Its callbacks and transport stay intact.
 var legacy_layer = slider.get_parent().get_parent()
 var transport = slider.get_parent().get_child(0)
 workspace_selector = transport.get_child(0)
 get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
 get_window().min_size = Vector2i(1024,640)
 get_window().title = "Kaze — Cinematic Studio 2.0"
 var studio_theme = Theme.new(); studio_theme.default_font_size = 18; theme = studio_theme
 var margin = MarginContainer.new(); add_child(margin); margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 for side in ["left","right","top","bottom"]: margin.add_theme_constant_override("margin_"+side,12)
 var layout = VBoxContainer.new(); layout.add_theme_constant_override("separation",10); margin.add_child(layout)
 var header = HBoxContainer.new(); layout.add_child(header)
 var title = Label.new(); title.text = "KAZE / CINEMATIC STUDIO 2.0"; title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 title.add_theme_font_size_override("font_size",22); header.add_child(title)
 workspace_selector.reparent(header); workspace_selector.custom_minimum_size.x = 240
 var body = HBoxContainer.new(); body.size_flags_vertical = Control.SIZE_EXPAND_FILL; layout.add_child(body)
 stage_slot = Control.new(); stage_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL; stage_slot.size_flags_vertical = Control.SIZE_EXPAND_FILL; body.add_child(stage_slot)
 preview_frame.reparent(stage_slot); stage_slot.resized.connect(fit_stage)
 var panel = PanelContainer.new(); panel.custom_minimum_size.x = 344; body.add_child(panel)
 var inner = VBoxContainer.new(); inner.add_theme_constant_override("separation",8); panel.add_child(inner)
 var scroll = ScrollContainer.new(); scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL; scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED; inner.add_child(scroll)
 var box = VBoxContainer.new(); box.size_flags_horizontal = Control.SIZE_EXPAND_FILL; box.add_theme_constant_override("separation",8); scroll.add_child(box); inspector = box
 heading = Label.new(); heading.text = "CHARACTER ANIMATOR"; box.add_child(heading)
 var help = Label.new(); help.text = "Choose joint → pose → Key pose"; box.add_child(help)
 joint_picker = OptionButton.new()
 for joint in JOINTS: joint_picker.add_item("Actor root" if joint == "." else joint.replace("Rig/", ""))
 joint_picker.add_item("Shot framing • Director")
 joint_picker.item_selected.connect(func(_i): sync_fields()); box.add_child(joint_picker)
 pos_x = field(box,"Pivot / position X",-2000,2000)
 pos_y = field(box,"Pivot / position Y",-2000,2000)
 angle = field(box,"Rotation (degrees)",-180,180)
 zoom = field(box,"Shot zoom",.5,2.); zoom.step = .01
 for spin in [pos_x,pos_y,angle,zoom]: spin.value_changed.connect(pose_changed)
 var actions = HBoxContainer.new(); box.add_child(actions)
 key_button = button(actions,"Key pose",key_pose); button(actions,"Undo",undo_pose)
 button(box,"Remove rotation key at playhead",remove_key)
 var rendering = OptionButton.new()
 for label in ["Hybrid • follow clip", "Rig only • candidate", "Sprite only • approved sheet"]: rendering.add_item(label)
 rendering.item_selected.connect(func(i): mode_override = i-1; scrub(slider.value)); box.add_child(rendering)
 var guides_toggle = CheckButton.new(); guides_toggle.text = "Show joint handles"; guides_toggle.button_pressed = true
 guides_toggle.toggled.connect(func(v): show_guides = v; apply_actor_view()); box.add_child(guides_toggle)
 button(box,"Reset to seed (undoable)",reset_clip)
 actions.reparent(inner)
 # Storage never scrolls out of view, including on a 1024×640 window.
 storage_panel = VBoxContainer.new(); inner.add_child(storage_panel)
 var storage = HBoxContainer.new(); storage_panel.add_child(storage)
 save_button = button(storage,"Save clip + shots",save_clip); reload_button = button(storage,"Reload",reload_clip)
 notice = Label.new(); notice.add_theme_font_size_override("font_size",16); notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; notice.custom_minimum_size = Vector2(332,58)
 notice.text = "Seed loaded. Reload opens your saved session."
 storage_panel.add_child(notice)
 storage_label = Label.new(); storage_label.text = "user://cin_tools_03/"; storage_label.add_theme_font_size_override("font_size",14); storage_panel.add_child(storage_label)
 storage_label.tooltip_text = ProjectSettings.globalize_path(saved_path.get_base_dir())
 update_storage_location()
 button(storage_panel,"Open saved folder",func():
  var folder = ProjectSettings.globalize_path(saved_path.get_base_dir())
  if DirAccess.dir_exists_absolute(folder): OS.shell_open(folder)
  else: notice.text = "Save a clip first to create this folder.")
 transport.reparent(layout)
 var timeline_header = HBoxContainer.new(); layout.add_child(timeline_header); timeline_row = timeline_header
 var time_label = Label.new(); time_label.text = "Timeline (seconds)"; timeline_header.add_child(time_label)
 playhead = SpinBox.new(); playhead.step = 1./60.; playhead.custom_minimum_size.x = 142; timeline_header.add_child(playhead)
 playhead.value_changed.connect(func(v): if not busy_ui: scrub(v))
 context_label = Label.new(); context_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL; timeline_header.add_child(context_label)
 button(timeline_header,"Shot 1",func(): jump_shot(0)); button(timeline_header,"Shot 2",func(): jump_shot(1))
 slider.reparent(layout); slider.custom_minimum_size.y = 44
 timeline_marks = Control.new(); slider.add_child(timeline_marks); timeline_marks.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 timeline_marks.mouse_filter = Control.MOUSE_FILTER_IGNORE; timeline_marks.draw.connect(draw_timeline)
 status.reparent(layout); status.add_theme_font_size_override("font_size",16)
 legacy_layer.queue_free()
 fit_stage.call_deferred()
 sync_fields()

func fit_stage():
 if not is_instance_valid(stage_slot) or not is_instance_valid(cutin): return
 var factor = minf(stage_slot.size.x/1280.,stage_slot.size.y/720.)
 preview_frame.size = Vector2(1280,720)*factor
 preview_frame.position = (stage_slot.size-preview_frame.size)/2.
 cutin.scale = Vector2.ONE*factor

func jump_shot(index):
 if cutin.name != "CinematicDirector": return
 scrub(minf(cutin.clip_time,4.18)+index*4.2)

func draw_timeline():
 var font = get_theme_default_font()
 for second in range(int(slider.max_value)+1):
  var x = 8+(slider.size.x-16)*second/slider.max_value
  timeline_marks.draw_string(font,Vector2(x,12),str(second),HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("a4b5c9"))
 if cutin.name == "CinematicDirector":
  var x = slider.size.x/2.
  timeline_marks.draw_line(Vector2(x,14),Vector2(x,44),Color("ffc875"),2)
 if not is_instance_valid(actor) or joint_picker.selected >= JOINTS.size(): return
 var path = JOINTS[joint_picker.selected]+":rotation"
 var track = session_clip.find_track(NodePath(path),Animation.TYPE_VALUE)
 if track < 0: return
 for key in session_clip.track_get_key_count(track):
  var time = session_clip.track_get_key_time(track,key)
  for offset in ([0.,4.2] if cutin.name == "CinematicDirector" else [0.]):
   var x = 8+(slider.size.x-16)*(time+offset)/slider.max_value
   timeline_marks.draw_circle(Vector2(x,38),3,Color("72e2bb"))

func field(parent,label,minimum,maximum):
 var row = HBoxContainer.new(); parent.add_child(row)
 var text_ = Label.new(); text_.text = label; text_.size_flags_horizontal = Control.SIZE_EXPAND_FILL; row.add_child(text_)
 var spin = SpinBox.new(); spin.min_value = minimum; spin.max_value = maximum; spin.step = .1; spin.custom_minimum_size.x = 120; row.add_child(spin)
 return spin
func button(parent,label,action):
 var b = Button.new(); b.text = label; b.pressed.connect(action); parent.add_child(b)
 b.custom_minimum_size.y = 34
 return b

func open_preset():
 super.open_preset()
 fit_stage()
 if cutin.name == "CinematicDirector":
  if session_shot == null: session_shot = animation.get_animation("standard").duplicate(true)
  var lib = animation.get_animation_library("")
  lib.remove_animation("standard"); lib.add_animation("standard",session_shot)
  restart()
 actor = cutin.get_node_or_null("Framing/Shake/Actor")
 if actor:
  actor.bind_clip(session_clip)
  actor.sample(cutin.clip_time)
 apply_actor_view()
 if is_instance_valid(workspace_selector):
  for i in choices.size():
   if preset.resource_path == preset_path(choices[i]): workspace_selector.select(i)
 if is_instance_valid(heading): heading.text = "CINEMATIC DIRECTOR" if cutin.name == "CinematicDirector" else "CHARACTER ANIMATOR"
 sync_fields()

func apply_actor_view():
 if not is_instance_valid(actor): return
 actor.guides = show_guides
 actor.set_view(mode_override)
 if is_instance_valid(joint_picker) and joint_picker.selected < JOINTS.size(): actor.selected_joint = JOINTS[joint_picker.selected]
 actor.queue_redraw()

func scrub(value):
 pending_pose = false
 if reduced_preview and is_instance_valid(cutin): cutin.get_node("Framing").rotation = 0
 super.scrub(value)
 apply_actor_view()
 sync_fields()

func _process(dt):
 var advancing = running
 super._process(dt)
 apply_actor_view()
 if advancing: sync_fields()
 status.text = "%.2f / %.2f s  •  1.0× real time  •  %s" % [slider.value,slider.max_value,"Static reduced motion" if reduced_preview else "Candidate animation / creator review pending"]
 if is_instance_valid(timeline_marks): timeline_marks.queue_redraw()

func target():
 if not is_instance_valid(actor) or not is_instance_valid(joint_picker): return null
 if joint_picker.selected == JOINTS.size():
  return cutin.get_node("Framing") if cutin.name == "CinematicDirector" else null
 return actor if JOINTS[joint_picker.selected] == "." else actor.get_node(JOINTS[joint_picker.selected])

func sync_fields():
 if is_instance_valid(playhead):
  busy_ui = true; playhead.max_value = slider.max_value; playhead.value = slider.value; busy_ui = false
  context_label.text = ("Shot %d / 2  •  clip %.2f s" % [2 if slider.value >= 4.2 else 1,cutin.clip_time]) if cutin.name == "CinematicDirector" else "Clip %.2f s" % slider.value
 var joint = target()
 for spin in [pos_x,pos_y,angle,zoom]:
  if is_instance_valid(spin): spin.editable = joint != null and not reduced_preview
 if is_instance_valid(key_button): key_button.disabled = joint == null or reduced_preview
 if not joint: return
 busy_ui = true
 pos_x.value = joint.position.x; pos_y.value = joint.position.y; angle.value = joint.rotation_degrees
 zoom.value = joint.scale.x if joint_picker.selected == JOINTS.size() else 1.
 zoom.editable = joint_picker.selected == JOINTS.size() and not reduced_preview
 busy_ui = false

func pose_changed(_value):
 if busy_ui or reduced_preview: return
 pause()
 var joint = target()
 if not joint: return
 joint.position = Vector2(pos_x.value,pos_y.value); joint.rotation_degrees = angle.value
 if joint_picker.selected == JOINTS.size(): joint.scale = Vector2.ONE * zoom.value
 actor.queue_redraw()
 if notice: notice.text = "Pose preview • press Key pose to keep this change."
 pending_pose = true

func checkpoint():
 history.append({"clip":session_clip.duplicate(true),"shot":session_shot.duplicate(true) if session_shot else null})
 if history.size() > 32: history.pop_front()

func put_key(path,value,resource = null,time = -1.):
 if resource == null: resource = session_clip
 if time < 0: time = cutin.clip_time
 var index = resource.find_track(NodePath(path),Animation.TYPE_VALUE)
 if index < 0:
  index = resource.add_track(Animation.TYPE_VALUE); resource.track_set_path(index,NodePath(path))
  # Preserve the rest value before the first new pose key.
  resource.track_insert_key(index,0,actor.rest_values.get(path,value) if resource == session_clip else value)
 resource.track_insert_key(index,snappedf(time,1.0/60.0),value)

func key_pose():
 if reduced_preview: return
 var joint = target()
 if not joint: return
 var position_ = joint.position; var rotation_ = joint.rotation
 checkpoint()
 pending_pose = false
 if joint_picker.selected == JOINTS.size():
  var start = 4.2 if slider.value >= 4.2 else 0.
  var end = 8.4 if start > 0 else 4.199
  for property in ["position","rotation","scale"]:
   var path = "Framing:"+property
   var track = session_shot.find_track(NodePath(path),Animation.TYPE_VALUE)
   if track < 0: track = session_shot.add_track(Animation.TYPE_VALUE); session_shot.track_set_path(track,NodePath(path))
   # Separate constant framing per shot; a second-shot edit cannot leak into shot one.
   var previous = cutin.get_node("Framing").get(property)
   if session_shot.track_get_key_count(track) == 0:
    for t in [0.,4.199,4.2,8.4]: session_shot.track_insert_key(track,t,Vector2.ONE if property == "scale" else (Vector2.ZERO if property == "position" else 0.))
   for k in range(session_shot.track_get_key_count(track)-1,-1,-1):
    var t = session_shot.track_get_key_time(track,k)
    if t >= start-.0001 and t <= end+.0001: session_shot.track_remove_key(track,k)
   session_shot.track_insert_key(track,start,previous); session_shot.track_insert_key(track,end,previous)
   session_shot.value_track_set_update_mode(track,Animation.UPDATE_DISCRETE)
  notice.text = "Shot %d framing keyed. Save keeps both shots." % (2 if start > 0 else 1)
  return
 var path = JOINTS[joint_picker.selected]
 put_key(path+":position",position_); put_key(path+":rotation",rotation_)
 actor.sample(cutin.clip_time); apply_actor_view()
 notice.text = "Pose keyed at %.2f s.\nDirector shares it. Save keeps the edit." % cutin.clip_time

func remove_key():
 if not target() or joint_picker.selected == JOINTS.size(): return
 var index = session_clip.find_track(NodePath(JOINTS[joint_picker.selected]+":rotation"),Animation.TYPE_VALUE)
 if index < 0: return
 var key = session_clip.track_find_key(index,snappedf(cutin.clip_time,1.0/60.0),Animation.FIND_MODE_APPROX)
 if key < 0 or session_clip.track_get_key_count(index) <= 1:
  notice.text = "No rotation key here, or this is the last key. Scrub to an existing key."
  return
 checkpoint(); session_clip.track_remove_key(index,key)
 scrub(slider.value); notice.text = "Rotation key removed. Undo is available."

func replace_clip(value):
 session_clip = value
 if is_instance_valid(actor): actor.bind_clip(session_clip)
 scrub(slider.value)
func undo_pose():
 if history.is_empty(): return
 var previous = history.pop_back()
 session_shot = previous.shot
 if cutin.name == "CinematicDirector" and session_shot:
  var lib = animation.get_animation_library(""); lib.remove_animation("standard"); lib.add_animation("standard",session_shot)
 replace_clip(previous.clip)
 notice.text = "Edit undone."
func reset_clip():
 checkpoint(); replace_clip(load(CLIP).duplicate(true)); notice.text = "Seed restored. Undo is available."

func valid_clip(value):
 if not value is Animation or not is_equal_approx(value.length,4.2) or value.loop_mode != Animation.LOOP_NONE: return false
 if value.get_track_count() < 1 or value.get_track_count() > 128: return false
 var seen = []
 for i in value.get_track_count():
  if value.track_get_type(i) != Animation.TYPE_VALUE: return false
  var path = str(value.track_get_path(i))
  if path in seen: return false
  seen.append(path)
  var allowed = path in [".:mode",".:rig_blend","Sprite:frame"]
  for joint in JOINTS:
   if path in [joint+":position",joint+":rotation"]: allowed = true
  if not allowed or value.track_get_key_count(i) == 0 or value.track_get_key_count(i) > 10000: return false
  for k in value.track_get_key_count(i):
   var t = value.track_get_key_time(i,k); var v = value.track_get_key_value(i,k)
   if not is_finite(t) or t < 0 or t > value.length+.0001: return false
   if path.ends_with(":position"):
    if not v is Vector2 or not v.is_finite() or absf(v.x) > 2000 or absf(v.y) > 2000: return false
   elif not (v is float or v is int) or not is_finite(float(v)): return false
   if path == ".:mode" and v not in [0,1]: return false
   if path == ".:rig_blend" and (v < 0 or v > 1): return false
   if path == "Sprite:frame" and (v != int(v) or v < 0 or v > 7): return false
 return true

func valid_shot(value):
 if not value is Animation or not is_equal_approx(value.length,8.4) or value.loop_mode != Animation.LOOP_NONE: return false
 if value.get_track_count() < 1 or value.get_track_count() > 16: return false
 var paths = ["Framing/Shake/Background:position", "Framing/Shake/Foreground:position", ".:handoff", ".:shake_strength", ".:clip_time", "Framing:position", "Framing:rotation", "Framing:scale"]
 var clip_track = value.find_track(NodePath(".:clip_time"),Animation.TYPE_VALUE)
 if clip_track < 0 or value.track_get_key_count(clip_track) != 4: return false
 for k in 4:
  var local_time = value.track_get_key_value(clip_track,k)
  if not (local_time is float or local_time is int) or not is_finite(float(local_time)): return false
  if not is_equal_approx(value.track_get_key_time(clip_track,k),[0.,4.199,4.2,8.4][k]): return false
  if not is_equal_approx(local_time,[0.,4.199,0.,4.2][k]): return false
 var seen = []
 for i in value.get_track_count():
  var path = str(value.track_get_path(i))
  if path in seen: return false
  seen.append(path)
  if value.track_get_type(i) != Animation.TYPE_VALUE or path not in paths or value.track_get_key_count(i) == 0 or value.track_get_key_count(i) > 1000: return false
  for k in value.track_get_key_count(i):
   var t = value.track_get_key_time(i,k); var v = value.track_get_key_value(i,k)
   if not is_finite(t) or t < 0 or t > value.length+.0001: return false
   if path.ends_with(":position") or path.ends_with(":scale"):
    if not v is Vector2 or not v.is_finite() or absf(v.x) > 2000 or absf(v.y) > 2000: return false
    if path.ends_with(":scale") and (v.x < .5 or v.x > 2 or v.y < .5 or v.y > 2): return false
   elif path == ".:handoff":
    if typeof(v) != TYPE_BOOL or v != false: return false
   elif not (v is float or v is int) or not is_finite(float(v)): return false
   elif path == ".:shake_strength" and v != 0: return false
 return true

func session_path(): return saved_path.get_base_dir()+"/studio_session.tres"

func update_storage_location():
 storage_label.text = "user://cin_tools_03/" if saved_path.begins_with("user://") else saved_path.get_base_dir().get_file()+"/"
 storage_label.tooltip_text = ProjectSettings.globalize_path(saved_path.get_base_dir())

func safe_load(path,kind):
 # Reject executable/external dependencies BEFORE ResourceLoader can instantiate them.
 # Studio only writes text .tres resources containing scalar/vector Animation tracks.
 var file = FileAccess.open(path,FileAccess.READ)
 if not file or file.get_length() > 2000000: return null
 var source = file.get_as_text()
 var script_assignment = RegEx.new(); script_assignment.compile("(?m)^\\s*script\\s*=")
 if not source.begins_with('[gd_resource type="'+kind+'"') or "ext_resource" in source or "ExtResource(" in source or script_assignment.search(source): return null
 for raw_line in source.split("\n"):
  var line = raw_line.strip_edges()
  if line.begins_with("[sub_resource") and not line.begins_with('[sub_resource type="Animation" '): return null
 return ResourceLoader.load(path,kind,ResourceLoader.CACHE_MODE_IGNORE)

func atomic_save(resource,path):
 var temp = path.get_basename()+".pending.tres"
 var error = ResourceSaver.save(resource,temp)
 if error == OK: error = DirAccess.rename_absolute(temp,path)
 return error

func save_clip():
 pause()
 if pending_pose:
  notice.text = "Key pose before saving, or scrub to discard the preview."; return false
 if not valid_clip(session_clip) or not valid_shot(session_shot): notice.text = "Cannot save invalid tracks. Current edit kept."; return false
 var error = DirAccess.make_dir_recursive_absolute(saved_path.get_base_dir())
 # One atomic native library is the authoritative pair. Standalone files are reusable exports.
 var bundle = AnimationLibrary.new()
 bundle.add_animation("sprint_stop",session_clip.duplicate(true))
 bundle.add_animation("director_shots",session_shot.duplicate(true))
 if error == OK: error = atomic_save(bundle,session_path())
 if error != OK:
  notice.text = "Save failed (%d). Current edit kept." % error; return false
 var export_error = atomic_save(session_clip.duplicate(true),saved_path)
 if export_error == OK: export_error = atomic_save(session_shot.duplicate(true),saved_path.get_base_dir()+"/director_shots.tres")
 update_storage_location()
 notice.text = "Saved clip + both shots. Ready to reopen." if export_error == OK else "Session saved. Clip export failed (%d). Save again to retry." % export_error
 return export_error == OK

func reload_clip():
 pause()
 var value; var shot
 if FileAccess.file_exists(session_path()):
  var bundle = safe_load(session_path(),"AnimationLibrary")
  if not bundle is AnimationLibrary or bundle.get_animation_list().size() != 2 or not bundle.has_animation("sprint_stop") or not bundle.has_animation("director_shots"):
   notice.text = "Invalid saved session. Current edit kept."; return false
  value = bundle.get_animation("sprint_stop"); shot = bundle.get_animation("director_shots")
 else:
  # Read legacy Studio pairs, validate both before changing any session state.
  if not FileAccess.file_exists(saved_path): notice.text = "No saved clip yet. Use Save clip + shots."; return false
  value = safe_load(saved_path,"Animation")
  shot = safe_load(saved_path.get_base_dir()+"/director_shots.tres","Animation")
 if not valid_clip(value) or not valid_shot(shot):
  notice.text = "Invalid clip or shots. Current edit kept."; return false
 checkpoint()
 session_shot = shot.duplicate(true)
 if cutin.name == "CinematicDirector":
  var lib = animation.get_animation_library(""); lib.remove_animation("standard"); lib.add_animation("standard",session_shot)
  restart()
 replace_clip(value.duplicate(true))
 update_storage_location()
 notice.text = "Reloaded. Both Director shots share this clip."
 return true
