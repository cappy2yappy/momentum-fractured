extends SceneTree
func _init(): call_deferred("run")
func run():
 await process_frame
 DirAccess.make_dir_recursive_absolute("res://build/cin04/stills")
 for id in ["aftermath","resistance","fallen_defenders"]:
  var s=load("res://presets/cutins/story/"+id+".tscn").instantiate()
  root.add_child(s)
  var a=s.get_node("AnimationPlayer")
  a.callback_mode_process=AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
  a.play("standard");a.advance(0)
  for t in [3.0,6.0,9.0]:
   a.seek(t,true)
   await process_frame
   await RenderingServer.frame_post_draw
   root.get_texture().get_image().save_png("res://build/cin04/stills/"+id+"_"+str(int(t))+".png")
  s.queue_free()
  await process_frame
 quit()
