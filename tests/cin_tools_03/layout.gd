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
 root.add_child(studio); studio.set_process(false)
 var out = "res://build/cin_tools_03/layout"
 DirAccess.make_dir_recursive_absolute(out)
 for dimensions in [Vector2i(1024,640),Vector2i(1280,720),Vector2i(1440,900)]:
  root.size = dimensions
  for i in 6: await process_frame
  studio.fit_stage()
  var bounds = Rect2(Vector2.ZERO,Vector2(dimensions))
  for entry in [["Timeline",studio.slider],["Joint selector",studio.joint_picker],["Key pose",studio.key_button],["Save",studio.save_button],["Reload",studio.reload_button],["Time entry",studio.playhead]]:
   check(bounds.encloses(entry[1].get_global_rect()),"%s visible at %s" % [entry[0],dimensions])
  check(studio.slider.size.y >= 28 and studio.slider.size.x >= dimensions.x-32,"Timeline remains large at %s" % dimensions)
  check(not studio.preview_frame.get_global_rect().intersects(studio.storage_panel.get_global_rect()),"Stage and storage do not overlap at %s" % dimensions)
  check(studio.save_button.get_theme_font_size("font_size") >= 18,"Readable control type at %s" % dimensions)
  if DisplayServer.get_name() != "headless":
   RenderingServer.force_draw(false)
   root.get_texture().get_image().save_png(out+"/%dx%d.png" % [dimensions.x,dimensions.y])
 studio.queue_free()
 for i in 4: await process_frame
 print("CIN-TOOLS-03 LAYOUT: %d checks, %d failure(s)" % [checks,failures])
 quit(1 if failures else 0)
