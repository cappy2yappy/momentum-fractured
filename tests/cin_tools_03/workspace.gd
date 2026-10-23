extends SceneTree
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
 root.add_child(studio)
 studio.set_process(false)
 studio.saved_path = "res://build/cin_tools_03/test_profile/sprint_stop.tres"
 check(studio.actor != null,"Animator loads native actor")
 check(studio.valid_clip(studio.session_clip),"Seed clip obeys bounded property-only contract")
 studio.scrub(.5)
 check(studio.actor.mode == 1 and studio.actor.get_node("Sprite").frame == 4,"Sprite keys sample approved run strip")
 studio.scrub(1.9)
 check(studio.actor.mode == 0 and studio.actor.get_node("Rig").visible,"Hybrid switches to editable cutout rig")
 var torso = studio.actor.get_node("Rig/Torso")
 studio.joint_picker.select(2); studio.sync_fields()
 studio.angle.value = 27.0
 studio.key_pose()
 check(is_equal_approx(torso.rotation_degrees,27.),"Pose inspector keys joint at playhead")
 var saved_path = studio.saved_path
 # Test runner redirects user:// to an ignored disposable profile before execution.
 studio.save_clip()
 check(FileAccess.file_exists(saved_path),"Edited native clip saves")
 var saved = ResourceLoader.load(saved_path,"Animation",ResourceLoader.CACHE_MODE_IGNORE)
 var index = saved.find_track(NodePath("Rig/Torso:rotation"),Animation.TYPE_VALUE)
 var key = saved.track_find_key(index,1.9,Animation.FIND_MODE_APPROX)
 check(key >= 0 and is_equal_approx(saved.track_get_key_value(index,key),deg_to_rad(27.)),"Edited key survives disk reload")
 studio.preset = load(studio.preset_path("director")); studio.open_preset(); studio.set_process(false)
 check(studio.actor.clip == studio.session_clip,"Director consumes the same session clip object")
 studio.scrub(1.9)
 check(is_equal_approx(studio.actor.get_node("Rig/Torso").rotation_degrees,27.),"Edited pose appears in first shot")
 studio.scrub(6.1)
 check(is_equal_approx(studio.actor.get_node("Rig/Torso").rotation_degrees,27.),"Same edited pose reused in second shot")
 studio.undo_pose(); studio.scrub(1.9)
 check(not is_equal_approx(studio.actor.get_node("Rig/Torso").rotation_degrees,27.),"Undo replaces shared clip and updates shot")
 studio.reload_clip(); studio.scrub(1.9)
 check(is_equal_approx(studio.actor.get_node("Rig/Torso").rotation_degrees,27.),"Reload saved clip updates Director")
 studio.remove_key(); studio.scrub(1.9)
 check(not is_equal_approx(studio.actor.get_node("Rig/Torso").rotation_degrees,27.),"Remove rotation key restores interpolation")
 studio.reset_clip()
 studio.scrub(2.55); var stopped = studio.actor.position
 studio.scrub(4.19)
 check(studio.actor.position == stopped,"Braking root stays fixed throughout final settle")
 studio.reduced_preview = true; studio.restart(); studio.scrub(.4)
 var reduced_pos = studio.actor.position; var reduced_rot = studio.actor.get_node("Rig/Torso").rotation
 studio.scrub(7.2)
 check(studio.actor.position == reduced_pos and studio.actor.get_node("Rig/Torso").rotation == reduced_rot and studio.cutin.get_node("Framing").scale == Vector2.ONE,"Reduced timeline holds pose and framing for equal duration")
 check(is_equal_approx(studio.slider.max_value,8.4),"Reduced Director retains standard shot duration")
 studio.reduced_preview = false; studio.restart(); studio.scrub(5.)
 studio.joint_picker.select(studio.JOINTS.size()); studio.sync_fields()
 studio.pos_x.value = -50.; studio.zoom.value = 1.2; studio.key_pose()
 studio.scrub(5.)

 check(is_equal_approx(studio.cutin.get_node("Framing").position.x,-50.) and is_equal_approx(studio.cutin.get_node("Framing").scale.x,1.2),"Director keys shot pan and zoom in native timeline")
 studio.save_clip()
 studio.undo_pose(); studio.scrub(5.)
 check(not is_equal_approx(studio.cutin.get_node("Framing").scale.x,1.2),"Shot framing edit supports undo")
 studio.reload_clip(); studio.scrub(5.)
 check(is_equal_approx(studio.cutin.get_node("Framing").scale.x,1.2),"Shot framing survives save and reload")
 studio.preset = load(studio.preset_path("animator")); studio.open_preset()
 studio.preset = load(studio.preset_path("director")); studio.open_preset(); studio.scrub(5.)
 check(is_equal_approx(studio.cutin.get_node("Framing").scale.x,1.2),"Director edit survives workspace switching")
 studio.scrub(.5); studio.step()
 check(is_equal_approx(studio.slider.value,.5+1./60.),"Inherited scrub and step remain 60 Hz")
 studio.play(); studio._process(.1); studio.pause()
 check(not studio.running and studio.slider.value > .6,"Inherited transport plays at unscaled delta")
 for choice in ["special_transition","major_biome","boss_intro"]:
  studio.preset = load(studio.preset_path(choice)); studio.open_preset(); studio.scrub(.2)
  check(studio.actor == null and studio.animation != null,"Original preset remains connected: "+choice)
 var invalid = Animation.new(); invalid.length = 4.2
 var track = invalid.add_track(Animation.TYPE_METHOD); invalid.track_set_path(track,NodePath("."))
 check(not studio.valid_clip(invalid),"Reject executable/non-property clip tracks")
 check(studio.valid_shot(studio.session_shot) and not studio.valid_shot(invalid),"Director shot persistence rejects executable tracks")
 var malformed = studio.session_clip.duplicate(true)
 malformed.track_insert_key(0,.5,Vector2(NAN,0))
 check(not studio.valid_clip(malformed),"Reject nonfinite transform values")
 check(studio.get_node_or_null("World") == null and studio.get_node_or_null("Player") == null,"Workspace has no gameplay scene owner")
 studio.queue_free()
 for i in 4: await process_frame
 print("CIN-TOOLS-03 WORKSPACE: %d checks, %d failure(s)" % [checks,failures])
 quit(1 if failures else 0)
