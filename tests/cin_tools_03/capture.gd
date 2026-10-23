extends SceneTree
## Real wall-clock/post-draw capture. No fixed-FPS/movie flags.
var studio
var frames = []
var out = "res://build/cin_tools_03/capture"
func _init(): call_deferred("run")
func shot(label):
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(out+"/"+label+".png")
func run():
 await process_frame
 DirAccess.make_dir_recursive_absolute(out)
 studio = load("res://tools/cin_tools_03/studio.tscn").instantiate()
 root.add_child(studio); current_scene = studio
 studio.scrub(1.9)
 await shot("01_animator")
 studio.joint_picker.select(2); studio.sync_fields(); studio.angle.value = 12.; studio.key_pose()
 await shot("02_keyed_pose")
 studio.undo_pose()
 studio.preset = load(studio.preset_path("director")); studio.open_preset()
 studio.scrub(6.1)
 studio.joint_picker.select(studio.JOINTS.size()); studio.sync_fields()
 await shot("03_director_reuse")
 studio.reduced_preview = true; studio.restart(); studio.scrub(3.)
 await shot("04_reduced")
 studio.reduced_preview = false; studio.restart(); studio.play()
 var start = Time.get_ticks_usec(); var last = -1.; var sample_shots = {}
 while Time.get_ticks_usec()-start < 8800000:
  await process_frame
  var t = (Time.get_ticks_usec()-start)/1000000.
  if t-last < 1./30.: continue
  await RenderingServer.frame_post_draw
  var actual = (Time.get_ticks_usec()-start)/1000000.
  var path = "%s/frame_%05d.jpg" % [out,frames.size()]
  root.get_texture().get_image().save_jpg(path,.88)
  frames.append({"path":ProjectSettings.globalize_path(path),"time":actual,"timeline":studio.slider.value})
  last = actual
  var phase = "sprint" if studio.slider.value < 1.5 else ("brake" if studio.slider.value < 2.55 else "settle")
  if not sample_shots.has(phase):
   root.get_texture().get_image().save_png(out+"/"+phase+".png"); sample_shots[phase] = true
 var metadata = {"frames":frames,"clock":"Time.get_ticks_usec after frame_post_draw; no fixed FPS/movie mode","elapsed":(Time.get_ticks_usec()-start)/1000000.,"engine":Engine.get_version_info().string,"renderer":RenderingServer.get_video_adapter_name(),"status":"Candidate sprint-to-stop and shared clip in two shots; not finished production animation"}
 FileAccess.open(out+"/timing.json",FileAccess.WRITE).store_string(JSON.stringify(metadata,"  "))
 var error = 0.
 for frame in frames: error = maxf(error,absf(frame.timeline-minf(frame.time,8.4)))
 metadata["max_wall_clock_error_seconds"] = error
 FileAccess.open(out+"/timing.json",FileAccess.WRITE).store_string(JSON.stringify(metadata,"  "))
 var ok = frames.size() > 60 and is_equal_approx(studio.slider.value,8.4) and error < .3
 print("PASS: " if ok else "FAIL: ","Native-speed capture samples=",frames.size()," timeline=",studio.slider.value," wall=",metadata.elapsed," max clock error=",error)
 studio.queue_free(); current_scene = null
 for i in 4: await process_frame
 quit(0 if ok else 1)
