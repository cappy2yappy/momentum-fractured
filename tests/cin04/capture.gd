extends SceneTree
## Capture actual wall-clock playback. No fixed FPS and no retiming.
var output="res://build/cin04/video"
func _init(): call_deferred("run")
func run():
 await process_frame
 DirAccess.make_dir_recursive_absolute(output)
 var demo=load("res://tools/cin04/demo.tscn").instantiate()
 root.add_child(demo)
 current_scene=demo
 for enemy in demo.world.enemies: enemy.set_physics_process(false)
 await create_timer(.5).timeout
 var checks=[]
 for id in ["aftermath","resistance","fallen_defenders"]:
  var frames=[]
  var folder=output+"/"+id
  DirAccess.make_dir_recursive_absolute(folder)
  demo.presenter.request_cutin("cin04_"+id)
  var start=Time.get_ticks_usec()
  var last=-1.0
  var entered=false
  var end=-1.0
  while (Time.get_ticks_usec()-start)/1000000.0 < 20:
   await process_frame
   var now=(Time.get_ticks_usec()-start)/1000000.0
   if not demo.presenter.active_id.is_empty(): entered=true
   if entered and demo.presenter.active_id.is_empty() and end<0: end=now
   if now-last >= 1.0/24:
    await RenderingServer.frame_post_draw
    var actual=(Time.get_ticks_usec()-start)/1000000.0
    var file=folder+"/frame_%05d.jpg" % frames.size()
    root.get_texture().get_image().save_jpg(file,.88)
    frames.append({"time":actual,"path":ProjectSettings.globalize_path(file)})
    last=actual
   if end>=0 and now-end>.4: break
  var f=FileAccess.open(folder+"/timing.json",FileAccess.WRITE)
  f.store_string(JSON.stringify({"clock":"Time.get_ticks_usec; actual rendered playback; no fixed-fps","frames":frames,"completion_seconds":end,"outcome":demo.presenter.last_outcome}, "  "))
  f.close()
  var restored=demo.world.player.is_physics_processing()
  checks.append({"sequence":id,"seconds":end,"frames":frames.size(),"outcome":demo.presenter.last_outcome,"control_restored":restored})
  print("CAPTURE: ",checks[-1])
  if end<0 or demo.presenter.last_outcome!="completed" or not restored:
   quit(1);return
 var f=FileAccess.open(output+"/results.json",FileAccess.WRITE)
 f.store_string(JSON.stringify(checks,"  "));f.close()
 demo.queue_free()
 current_scene=null
 for i in 3: await process_frame
 quit()
