extends SceneTree
## Visible native InputEvent demo with a recorded cursor; no direct gesture callbacks.
var studio
var cursor: Control
var pointer = Vector2(-50,-50)
var down = false
var frames = []
var started = 0
var last_frame = -1.
var out = "res://build/cin_tools_03/fk_capture"
var playback_started = -1
var reused = []
var playback_error = 0.
func _init(): call_deferred("run")
func record_frame():
 RenderingServer.force_draw(false)
 var now = (Time.get_ticks_usec()-started)/1000000.
 if now-last_frame < 1./24.: return
 var path = "%s/frame_%05d.jpg" % [out,frames.size()]
 root.get_texture().get_image().save_jpg(path,.89)
 frames.append({"path":ProjectSettings.globalize_path(path),"time":now,"timeline":studio.slider.value})
 last_frame = now
 if playback_started > 0:
  var wall = (Time.get_ticks_usec()-playback_started)/1000000.
  playback_error = maxf(playback_error,absf(studio.slider.value-minf(wall,8.4)))
  var index = 2 if studio.slider.value >= 4.2 else 1
  if index not in reused and studio.actor.clip == studio.session_clip: reused.append(index)
func hold(seconds):
 var end = Time.get_ticks_usec()+int(seconds*1000000)
 while Time.get_ticks_usec() < end:
  await process_frame; record_frame()
func mouse(at,kind,pressed=false):
 pointer = at
 if kind == "motion":
  var event = InputEventMouseMotion.new(); event.position = at; event.global_position = at; event.button_mask = MOUSE_BUTTON_MASK_LEFT if down else 0
  Input.parse_input_event(event)
 else:
  down = pressed
  var event = InputEventMouseButton.new(); event.button_index = MOUSE_BUTTON_LEFT; event.pressed = pressed; event.position = at; event.global_position = at
  Input.parse_input_event(event)
 Input.flush_buffered_events(); cursor.queue_redraw()
 await process_frame; record_frame()
func click(at):
 await mouse(at,"motion"); await hold(.15); await mouse(at,"button",true); await hold(.12); await mouse(at,"button",false)
func ui_click(text_):
 for b in studio.find_children("*","Button",true,false):
  if b.text == text_: await click(b.get_global_rect().get_center()); return
 push_error("Missing demo button: "+text_)
func move_joint(path,delta):
 var joint = studio.actor.get_node(path); var transform_ = joint.get_parent().get_global_transform_with_canvas()
 var at = studio.handles.viewport_point(studio.handles.handle_layout()[path].point)
 var to = at+transform_*delta-transform_*Vector2.ZERO
 await mouse(at,"motion"); await hold(.3); await mouse(at,"button",true)
 for i in range(1,16): await mouse(at.lerp(to,i/15.),"motion"); await hold(.035)
 await mouse(to,"button",false)
func shot(name_):
 RenderingServer.force_draw(false); root.get_texture().get_image().save_png(out+"/"+name_+".png")
func run():
 await process_frame
 root.size = Vector2i(1280,720)
 DirAccess.make_dir_recursive_absolute(out)
 studio = load("res://tools/cin_tools_03/studio.tscn").instantiate(); root.add_child(studio); current_scene = studio
 studio.saved_path = "res://build/cin_tools_03/fk_creator_profile/sprint_stop.tres"
 var layer = CanvasLayer.new(); layer.layer = 500; root.add_child(layer)
 cursor = Control.new(); cursor.mouse_filter = Control.MOUSE_FILTER_IGNORE; layer.add_child(cursor)
 cursor.draw.connect(func():
  cursor.draw_circle(pointer,7,Color(1,1,1,.2)); cursor.draw_arc(pointer,7,0,TAU,28,Color("ffc875") if down else Color.WHITE,2,true)
  cursor.draw_line(pointer-Vector2(11,0),pointer+Vector2(11,0),Color.WHITE,1,true)
  cursor.draw_line(pointer-Vector2(0,11),pointer+Vector2(0,11),Color.WHITE,1,true))
 studio.scrub(1.9)
 for i in 6: await process_frame
 started = Time.get_ticks_usec()
 await hold(.8)
 var path = "Rig/Torso/Head"
 await move_joint(path,Vector2(20,-9)); shot("01_drag_preview"); await hold(.9)
 await ui_click("Undo"); await hold(.7)
 studio.select_canvas_joint("Rig/Torso")
 var joint = studio.actor.get_node("Rig/Torso"); var h = studio.handles
 var at = h.viewport_point(h.rotation_grip(h.handle_layout()))
 var transform_ = joint.get_parent().get_global_transform_with_canvas(); var v = transform_.affine_inverse()*at-joint.position
 await mouse(at,"motion"); await hold(.3); await mouse(at,"button",true)
 for i in range(1,17):
  var to = transform_*(joint.position+v.rotated(deg_to_rad(20.)*i/16.))
  await mouse(to,"motion"); await hold(.035)
 await mouse(pointer,"button",false); shot("02_rotate_preview"); await hold(.9)
 await ui_click("Undo"); await hold(.6)
 await move_joint(path,Vector2(12,-8)); await hold(.6)
 await ui_click("Key pose"); await hold(.6)
 await ui_click("Save clip + shots"); shot("03_keyed_saved"); await hold(.9)
 await ui_click("Reload"); await hold(.8)
 studio.preset = load(studio.preset_path("director")); studio.open_preset(); studio.scrub(1.9)
 await hold(.7); await ui_click("Shot 2"); shot("04_two_shot_reuse"); await hold(.9)
 studio.reduced_preview = true; studio.restart(); studio.scrub(6.1); shot("05_reduced"); await hold(.8)
 studio.reduced_preview = false; studio.restart(); await hold(.3)
 await ui_click("Play")
 playback_started = Time.get_ticks_usec()
 await hold(8.8)
 var okay = studio.actor.clip == studio.session_clip and reused == [1,2] and is_equal_approx(studio.slider.value,8.4) and playback_error < .3
 var metadata = {"frames":frames,"clock":"Time.get_ticks_usec after native force_draw; no fixed FPS/movie mode","input":"Input.parse_input_event mouse buttons/motion through GUI dispatch; visible recorded cursor","elapsed":(Time.get_ticks_usec()-started)/1000000.,"engine":Engine.get_version_info().string,"renderer":RenderingServer.get_video_adapter_name(),"speed":Engine.time_scale,"playback_max_clock_error":playback_error,"shared_clip_shots":reused,"saved_profile":"build/cin_tools_03/fk_creator_profile","saved_head_position":[23,-121],"status":"Direct FK creator prototype; no production art certification"}
 FileAccess.open(out+"/timing.json",FileAccess.WRITE).store_string(JSON.stringify(metadata,"  "))
 print("PASS: " if okay else "FAIL: ","Native FK input demonstration: samples=",frames.size()," wall=",metadata.elapsed," playback drift=",playback_error," shots=",reused)
 studio.queue_free(); layer.queue_free(); current_scene = null
 for i in 4: await process_frame
 quit(0 if okay else 1)
