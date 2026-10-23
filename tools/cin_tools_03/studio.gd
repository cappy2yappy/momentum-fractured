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

func preset_path(choice):
 if choice in ["animator", "director"]: return "res://presets/cutins/studio/" + choice + ".tscn"
 return super.preset_path(choice)

func _ready():
 session_clip = load(CLIP).duplicate(true)
 var seed_shot = load("res://presets/cutins/studio/director.tscn").instantiate()
 session_shot = seed_shot.get_node("AnimationPlayer").get_animation("standard").duplicate(true)
 seed_shot.free()
 choices = ["animator", "director", "special_transition", "major_biome", "boss_intro"]
 preset = load(preset_path("animator"))
 super._ready()
 workspace_selector = find_children("*","OptionButton",true,false)[0]
 preview_frame.position = Vector2(0,42)
 preview_frame.size = Vector2(930,550)
 cutin.scale = Vector2.ONE * .72
 var title = Label.new(); title.text = "KAZE  /  CINEMATIC STUDIO 2.0     •     Character → Clip → Cutscene"
 title.position = Vector2(20,10); title.add_theme_font_size_override("font_size",22); add_child(title)
 var panel = PanelContainer.new(); panel.add_theme_font_size_override("font_size",16); panel.position = Vector2(940,48); panel.size = Vector2(325,544); add_child(panel)
 var box = VBoxContainer.new(); panel.add_child(box)
 heading = Label.new(); heading.text = "CHARACTER ANIMATOR"; box.add_child(heading)
 var help = Label.new(); help.text = "1  Choose a joint\n2  Scrub, pose, then Key pose\n3  Save clip → open Director"; box.add_child(help)
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
 button(actions,"Key pose",key_pose); button(actions,"Undo",undo_pose)
 button(box,"Remove rotation key at playhead",remove_key)
 var rendering = OptionButton.new()
 for label in ["Hybrid • follow clip", "Rig only • candidate", "Sprite only • approved sheet"]: rendering.add_item(label)
 rendering.item_selected.connect(func(i): mode_override = i-1; scrub(slider.value)); box.add_child(rendering)
 var guides_toggle = CheckButton.new(); guides_toggle.text = "Show joint handles"; guides_toggle.button_pressed = true
 guides_toggle.toggled.connect(func(v): show_guides = v; apply_actor_view()); box.add_child(guides_toggle)
 var storage = HBoxContainer.new(); box.add_child(storage)
 button(storage,"Save",save_clip); button(storage,"Reload",reload_clip)
 button(box,"Reset to seed (undoable)",reset_clip)
 notice = Label.new(); notice.add_theme_font_size_override("font_size",14); notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; notice.custom_minimum_size.x = 305
 notice.text = "Candidate FK cutouts; seams visible.\nSprite→rig switch needs art review."
 box.add_child(notice)
 sync_fields()

func field(parent,label,minimum,maximum):
 var row = HBoxContainer.new(); parent.add_child(row)
 var text_ = Label.new(); text_.text = label; text_.custom_minimum_size.x = 185; row.add_child(text_)
 var spin = SpinBox.new(); spin.min_value = minimum; spin.max_value = maximum; spin.step = .1; row.add_child(spin)
 return spin
func button(parent,label,action):
 var b = Button.new(); b.text = label; b.pressed.connect(action); parent.add_child(b)

func open_preset():
 super.open_preset()
 cutin.scale = Vector2.ONE * .72
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
 if mode_override >= 0: actor.mode = mode_override
 actor.queue_redraw()

func scrub(value):
 super.scrub(value)
 apply_actor_view()
 sync_fields()

func _process(dt):
 super._process(dt)
 apply_actor_view()
 if running: sync_fields()
 status.text = "%.2f / %.2f s  |  Cut-In Maker transport  •  1× real time  |  Edit full tracks in Godot’s Animation panel." % [slider.value,slider.max_value]

func target():
 if not is_instance_valid(actor) or not is_instance_valid(joint_picker): return null
 if joint_picker.selected == JOINTS.size():
  return cutin.get_node("Framing") if cutin.name == "CinematicDirector" else null
 return actor if JOINTS[joint_picker.selected] == "." else actor.get_node(JOINTS[joint_picker.selected])

func sync_fields():
 var joint = target()
 if not joint: return
 busy_ui = true
 pos_x.value = joint.position.x; pos_y.value = joint.position.y; angle.value = joint.rotation_degrees
 zoom.value = joint.scale.x if joint_picker.selected == JOINTS.size() else 1.
 zoom.editable = joint_picker.selected == JOINTS.size()
 busy_ui = false

func pose_changed(_value):
 if busy_ui: return
 pause()
 var joint = target()
 if not joint: return
 joint.position = Vector2(pos_x.value,pos_y.value); joint.rotation_degrees = angle.value
 if joint_picker.selected == JOINTS.size(): joint.scale = Vector2.ONE * zoom.value
 actor.queue_redraw()
 if notice: notice.text = "Pose preview • press Key pose to keep this change."

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
 var joint = target()
 if not joint: return
 var position_ = joint.position; var rotation_ = joint.rotation
 checkpoint()
 if joint_picker.selected == JOINTS.size():
  put_key("Framing:position",position_,session_shot,slider.value)
  put_key("Framing:rotation",rotation_,session_shot,slider.value)
  put_key("Framing:scale",joint.scale,session_shot,slider.value)
  notice.text = "Shot framing keyed. Save keeps clip and shot tracks."
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
 if not value is Animation or not is_finite(value.length) or value.length <= 0 or value.length > 60: return false
 for i in value.get_track_count():
  if value.track_get_type(i) != Animation.TYPE_VALUE: return false
  var path = str(value.track_get_path(i))
  var allowed = path in [".:mode","Sprite:frame"]
  for joint in JOINTS:
   if path in [joint+":position",joint+":rotation"]: allowed = true
  if not allowed or value.track_get_key_count(i) == 0: return false
  for k in value.track_get_key_count(i):
   var t = value.track_get_key_time(i,k)
   var v = value.track_get_key_value(i,k)
   if not is_finite(t) or t < 0 or t > value.length: return false
   if path.ends_with(":position"):
    if not v is Vector2 or not v.is_finite(): return false
   elif not (v is float or v is int) or not is_finite(float(v)): return false
   if path == ".:mode" and int(v) not in [0,1]: return false
   if path == "Sprite:frame" and (int(v) < 0 or int(v) > 7): return false
 return true

func valid_shot(value):
 if not value is Animation or not is_equal_approx(value.length,8.4): return false
 var paths = ["Framing/Shake/Background:position", "Framing/Shake/Foreground:position", ".:handoff", ".:shake_strength", ".:clip_time", "Framing:position", "Framing:rotation", "Framing:scale"]
 for i in value.get_track_count():
  var path = str(value.track_get_path(i))
  if value.track_get_type(i) != Animation.TYPE_VALUE or path not in paths or value.track_get_key_count(i) == 0: return false
  for k in value.track_get_key_count(i):
   var t = value.track_get_key_time(i,k); var v = value.track_get_key_value(i,k)
   if not is_finite(t) or t < 0 or t > value.length: return false
   if path.ends_with(":position") or path.ends_with(":scale"):
    if not v is Vector2 or not v.is_finite(): return false
   elif path == ".:handoff":
    if v != false: return false
   elif not (v is float or v is int) or not is_finite(float(v)): return false
 return true

func save_clip():
 if not valid_clip(session_clip) or not valid_shot(session_shot): notice.text = "Cannot save an invalid clip."; return
 DirAccess.make_dir_recursive_absolute(saved_path.get_base_dir())
 var error = ResourceSaver.save(session_clip,saved_path)
 if error == OK and session_shot: error = ResourceSaver.save(session_shot,saved_path.get_base_dir()+"/director_shots.tres")
 notice.tooltip_text = ProjectSettings.globalize_path(saved_path.get_base_dir())
 notice.text = "Saved clip + shot tracks.\nHover here to see the folder path." if error == OK else "Save failed (%d). Your edit is still here." % error
func reload_clip():
 if not FileAccess.file_exists(saved_path): notice.text = "No saved clip yet. Use Save clip first."; return
 var value = ResourceLoader.load(saved_path,"Animation",ResourceLoader.CACHE_MODE_IGNORE)
 if not valid_clip(value): notice.text = "Saved clip is invalid; current edit kept."; return
 checkpoint()
 var shot_path = saved_path.get_base_dir()+"/director_shots.tres"
 if FileAccess.file_exists(shot_path):
  var shot = ResourceLoader.load(shot_path,"Animation",ResourceLoader.CACHE_MODE_IGNORE)
  if not valid_shot(shot): notice.text = "Invalid shot file; current workspace kept."; return
  session_shot = shot
  if cutin.name == "CinematicDirector":
   var lib = animation.get_animation_library(""); lib.remove_animation("standard"); lib.add_animation("standard",session_shot)
 replace_clip(value)
 notice.text = "Saved clip loaded. Animator and Director now share it."
