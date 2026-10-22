extends SceneTree
var frames: Array = []
var output = "res://build/story_cinematics/video"
func _init(): call_deferred("run")
func run():
 await process_frame
 DirAccess.make_dir_recursive_absolute(output)
 var demo = load("res://tools/story_cinematics/demo.tscn").instantiate()
 root.add_child(demo)
 current_scene = demo
 for enemy in demo.world.enemies: enemy.set_physics_process(false)
 var start = Time.get_ticks_usec()
 var last = -1.0
 var requested = 0
 while Time.get_ticks_usec() - start < 11500000:
  await process_frame
  var t = (Time.get_ticks_usec() - start)/1000000.0
  var ids = ["opening_review", "record_review", "fallen_clan_review"]
  if requested < 3 and t > .6 + requested * 3.2:
   demo.presenter.request_cutin(ids[requested])
   requested += 1
  if t - last >= 1.0/24:
   await RenderingServer.frame_post_draw
   var actual = (Time.get_ticks_usec() - start)/1000000.0
   var path = "%s/frame_%05d.jpg" % [output, frames.size()]
   root.get_texture().get_image().save_jpg(path,.85)
   frames.append({"time":actual,"path":ProjectSettings.globalize_path(path)})
   last = actual
 var file = FileAccess.open(output+"/timing.json", FileAccess.WRITE)
 file.store_string(JSON.stringify({"clock":"Time.get_ticks_usec / actual native rendered frames / no fixed-fps", "frames":frames},"  "))
 file.close()
 print("Native capture: ", frames.size(), " frames, control restored=",demo.world.player.is_physics_processing())
 demo.queue_free()
 current_scene = null
 for i in 3: await process_frame
 quit()
