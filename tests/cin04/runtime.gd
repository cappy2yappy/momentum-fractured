extends SceneTree
const Presenter = preload("res://scripts/story/cutin_presenter.gd")
const Director = preload("res://tests/cin04/int01_reference/story_director.gd")
class SinkProbe extends Node:
 var presenter
 var director
 var committed_before_request = false
 func update(w,dt):
  presenter.update(w,dt)
 func request_cutin(id):
  committed_before_request = director.has("disc/cin04_seen")
  presenter.request_cutin(id)
const IDS = ["cin04_aftermath", "cin04_resistance", "cin04_fallen_defenders"]
var w
var p
var checks = 0
var failures = 0
func _init(): call_deferred("run")
func check(ok, label):
 checks += 1
 if not ok: failures += 1
 print("PASS: " if ok else "FAIL: ", label)
func state():
 return [w.room,w.completed,w.expansion_flags.duplicate(true),w.cleared_encounters.duplicate(true),w.opened_kunai_gates.duplicate(true),w.checkpoint_room,w.checkpoint_position,w.player.hp,w.player.double_jump,w.player.tether_unlocked,w.player.dash_unlocked,w.camera.zoom,w.camera.position]
func tick(seconds):
 for i in int(seconds*60)+1: p.update(w,1.0/60)
func start(id):
 w.player.set_physics_process(true)
 p.request_cutin(id)
 p.update(w,0)
func run():
 await process_frame
 w = load("res://scenes/main.tscn").instantiate()
 w.save_path = "res://build/cin04/disposable.json"
 DirAccess.make_dir_recursive_absolute("res://build/cin04")
 root.add_child(w)
 w.set_physics_process(false)
 for enemy in w.enemies: enemy.set_physics_process(false)
 p = Presenter.new()
 root.add_child(p)
 p.configure(w)
 var f=FileAccess.open(w.save_path,FileAccess.WRITE)
 f.store_string('{"sentinel":true}')
 f.close()
 var before=state()
 for reduced in [false,true]:
  p.reduced=reduced
  for id in IDS:
   start(id)
   check(p.active_id==id and not w.player.is_physics_processing(),id+" takes control")
   var seq=p.sequence
   var length=seq.current_animation_length
   check(length>=12 and length<=16,id+" authored pacing")
   var frame=p.cutin.get_node("Framing")
   var camera_start=frame.transform
   tick(6)
   check(frame.transform==camera_start if reduced else frame.transform!=camera_start,id+" motion policy")
   p.request_cutin(id)
   check(p.pending.is_empty(),id+" active duplicate rejected")
   tick(length)
   check(p.active_id.is_empty() and w.player.is_physics_processing(),id+" natural restoration")
   check(state()==before,id+" no progression/camera mutation")
   check(FileAccess.get_file_as_string(w.save_path)=='{"sentinel":true}',id+" no save mutation")
 for id in IDS:
  for t in [0.1,5.0,10.0]:
   p.reduced=false
   start(id)
   tick(t)
   var e=InputEventKey.new()
   e.physical_keycode=KEY_SPACE;e.pressed=true
   p._unhandled_input(e)
   check(p.active_id.is_empty() and w.player.is_physics_processing(),id+" skip at "+str(t))
  start(id)
  var pad=InputEventJoypadButton.new()
  pad.button_index=JOY_BUTTON_B;pad.pressed=true
  p._unhandled_input(pad)
  check(p.last_outcome=="skipped" and w.player.is_physics_processing(),id+" synthetic B skip")
 start(IDS[0]);tick(4)
 var position=p.sequence.current_animation_position
 p.reduced=true;p.update(w,0)
 check(p.sequence.current_animation=="reduced" and is_equal_approx(p.sequence.current_animation_position,position),"live reduced switch preserves timeline position")
 check(p.cutin.get_node("Framing").position==Vector2.ZERO,"live reduced switch removes camera travel")
 p.reduced=false;p.update(w,0)
 check(is_equal_approx(p.sequence.current_animation_position,position),"standard switch preserves timeline position")
 p.cancel()
 for reason in ["focus","pause","rebuild","remove"]:
  start(IDS[1])
  p.request_cutin(IDS[0])
  if reason=="focus": p._notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
  elif reason=="pause":
   paused=true;p._process(0);paused=false
  elif reason=="rebuild": p.cancel("room_loaded")
  else: p.cancel("removed")
  check(p.active_id.is_empty() and p.pending.is_empty() and w.player.is_physics_processing(),reason+" clears queued playback and restores control")
 start(IDS[0]);w.transition=.5;w.pending_room=1;p.update(w,0)
 check(p.active_id.is_empty() and not w.player.is_physics_processing(),"loader retains control on interruption")
 w.transition=0;w.pending_room=-1;w.player.set_physics_process(true)
 start(IDS[0]);w.player.hp=0;p.update(w,0)
 check(p.active_id.is_empty() and not w.player.is_physics_processing(),"death does not restore dead body")
 w.player.hp=before[7];w.player.set_physics_process(true)
 w.transition=.5;p.request_cutin(IDS[0]);p.update(w,0)
 check(p.active_id.is_empty() and p.pending.size()==1,"loader defers queued presentation")
 w.room=1;w.transition=0;p.update(w,0)
 check(p.active_id.is_empty() and p.pending.is_empty(),"room change discards stale queue")
 w.room=before[0]
 start(IDS[0]);p.sequence.queue_free();await process_frame;p.update(w,0)
 check(p.last_outcome=="watchdog" and w.player.is_physics_processing(),"missing sequence restores control")
 start(IDS[0]);p.update(w,31)
 check(p.last_outcome=="watchdog" and w.player.is_physics_processing(),"watchdog restores control")
 start(IDS[0]);p.enabled=false;p.update(w,0)
 check(p.active_id.is_empty() and w.player.is_physics_processing(),"disable restores control")
 p.enabled=true;p.request_cutin("unknown")
 check(p.pending.is_empty(),"unknown id rejected")
 check(state()==before,"interruptions preserve campaign state")
 # Native authoring uses value tracks only, no method calls into world/progression.
 for id in IDS:
  var scene=Presenter.PRESETS[id].instantiate()
  root.add_child(scene)
  var ap=scene.get_node("AnimationPlayer")
  for name in ["standard","reduced","RESET"]:
   var a=ap.get_animation(name)
   var safe=true
   for track in a.get_track_count():
    if a.track_get_type(track)!=Animation.TYPE_VALUE: safe=false
   check(safe,id+" "+name+" has only presentation value tracks")
  scene.queue_free()
 # Actual pinned PR89 director, only its preload paths point to test fixtures.
 var director=Director.new()
 director.world=w
 var probe=SinkProbe.new()
 probe.presenter=p;probe.director=director
 root.add_child(probe)
 director.cutin_presenter=probe
 director.rules=[{"trigger":"evt/cin04_test","effects":[{"kind":"request_cutin","id":IDS[0]},{"kind":"set_flag","id":"disc/cin04_seen"}]}]
 director.report("evt/cin04_test")
 check(probe.committed_before_request,"PR89 commits story state before presentation despite effect row order")
 director.update(w,0)
 check(p.active_id==IDS[0],"PR89 dispatches production presentation through existing seam")
 p.cancel("skipped")
 check(director.has("disc/cin04_seen"),"skip does not roll back director-owned progression")
 check(FileAccess.get_file_as_string(w.save_path)=='{"sentinel":true}',"test-mode director/presentation leaves sentinel save untouched")
 w.expansion_flags.erase("disc/cin04_seen")
 probe.queue_free()
 p.queue_free();w.queue_free()
 for i in 3: await process_frame
 print("CIN04: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
