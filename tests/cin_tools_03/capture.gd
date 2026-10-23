extends SceneTree
## Real wall-clock capture after a synchronous native draw. No fixed-FPS/movie flags.
var studio
var frames = []
var out = "res://build/cin_tools_03/capture"
func _init(): call_deferred("run")
func shot(label):
 await process_frame
 RenderingServer.force_draw(false)
 root.get_texture().get_image().save_png(out+"/"+label+".png")
func run():
 await process_frame
 DirAccess.make_dir_recursive_absolute(out)
 studio = load("res://tools/cin_tools_03/studio.tscn").instantiate()
 root.add_child(studio); current_scene = studio
 studio.saved_path = "res://presets/cutins/studio/authoring_example/sprint_stop.tres"
 if not studio.reload_clip():
  push_error("Review must load the persisted authoring example"); quit(1); return
 studio.scrub(1.9); studio.joint_picker.select(2); studio.sync_fields()
 await shot("01_animator")
 await shot("02_keyed_pose")
 studio.preset = load(studio.preset_path("director")); studio.open_preset()
 studio.scrub(6.1)
 studio.joint_picker.select(studio.JOINTS.size()); studio.sync_fields()
 await shot("03_director_reuse")
 studio.reduced_preview = true; studio.restart(); studio.scrub(3.)
 await shot("04_reduced")
 studio.reduced_preview = false; studio.restart()
 for i in 3: await process_frame
 studio.play()
 var start = Time.get_ticks_usec(); var last = -1.; var sample_shots = {}
 var reused = []
 while Time.get_ticks_usec()-start < 8800000:
  await process_frame
  var t = (Time.get_ticks_usec()-start)/1000000.
  if t-last < 1./30.: continue
  RenderingServer.force_draw(false)
  var actual = (Time.get_ticks_usec()-start)/1000000.
  var path = "%s/frame_%05d.jpg" % [out,frames.size()]
  root.get_texture().get_image().save_jpg(path,.88)
  frames.append({"path":ProjectSettings.globalize_path(path),"time":actual,"timeline":studio.slider.value})
  var shot_index = 2 if studio.slider.value >= 4.2 else 1
  if shot_index not in reused and studio.actor.clip == studio.session_clip: reused.append(shot_index)
  last = actual
  var phase = "sprint" if studio.slider.value < 1.5 else ("brake" if studio.slider.value < 2.55 else "settle")
  if not sample_shots.has(phase):
   root.get_texture().get_image().save_png(out+"/"+phase+".png"); sample_shots[phase] = true
 var metadata = {"frames":frames,"clock":"Time.get_ticks_usec after RenderingServer.force_draw; no fixed FPS/movie mode","elapsed":(Time.get_ticks_usec()-start)/1000000.,"engine":Engine.get_version_info().string,"renderer":RenderingServer.get_video_adapter_name(),"resource":"res://presets/cutins/studio/authoring_example/studio_session.tres","speed":Engine.time_scale,"shared_clip_shots":reused,"status":"Candidate sprint-to-stop and shared clip in two shots; not finished production animation"}
 FileAccess.open(out+"/timing.json",FileAccess.WRITE).store_string(JSON.stringify(metadata,"  "))
 var error = 0.
 for frame in frames: error = maxf(error,absf(frame.timeline-minf(frame.time,8.4)))
 metadata["max_wall_clock_error_seconds"] = error
 FileAccess.open(out+"/timing.json",FileAccess.WRITE).store_string(JSON.stringify(metadata,"  "))
 var ok = frames.size() > 60 and is_equal_approx(studio.slider.value,8.4) and error < .3 and reused == [1,2] and is_equal_approx(Engine.time_scale,1.)
 print("PASS: " if ok else "FAIL: ","Native-speed capture samples=",frames.size()," timeline=",studio.slider.value," wall=",metadata.elapsed," max clock error=",error)
 studio.queue_free(); current_scene = null
 for i in 4: await process_frame
 quit(0 if ok else 1)
