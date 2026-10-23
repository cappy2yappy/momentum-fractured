extends SceneTree
var checks=0
var failures=0
func _init(): call_deferred("run")
func check(ok,label):
 checks+=1
 if not ok:failures+=1
 print("PASS: " if ok else "FAIL: ",label)
func run():
 await process_frame
 var preview=load("res://tools/cin04/preview.tscn").instantiate()
 root.add_child(preview)
 for i in 3:
  var select=preview.get_child(1).get_child(1).get_child(0).get_child(0)
  select.select(i);select.item_selected.emit(i)
  check(preview.animation.current_animation_length==[12.0,14.0,16.0][i],"selector loads authored "+str(i))
  preview.scrub(9.0)
  check(is_equal_approx(preview.animation.current_animation_position,9),"scrub remains read-only")
  preview.step()
  check(is_equal_approx(preview.animation.current_animation_position,9+1.0/60),"native frame step")
  preview.play();check(preview.running,"play")
  preview.pause();check(not preview.running,"pause")
  preview.reduced_preview=true;preview.restart()
  check(preview.animation.current_animation=="reduced","reduced preview")
  check(preview.animation.current_animation_length==[12.0,14.0,16.0][i],"reduced retains story pacing")
  preview.reduced_preview=false;preview.restart()
 preview.queue_free()
 for i in 3:await process_frame
 print("CIN04 AUTHORING: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
