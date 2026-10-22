extends SceneTree
const Presenter = preload("res://scripts/story/cutin_presenter.gd")
var w
var p
var failures = 0
var checks = 0
var captures = "res://build/story_cinematics"
func _init(): call_deferred("run")
func check(ok, label):
 checks += 1
 if not ok: failures += 1
 print("PASS: " if ok else "FAIL: ", label)
func state():
 return [w.room, w.completed, w.expansion_flags.duplicate(true), w.cleared_encounters.duplicate(true), w.opened_kunai_gates.duplicate(true), w.checkpoint_room, w.checkpoint_position, w.player.hp, w.player.double_jump, w.player.tether_unlocked, w.player.dash_unlocked, w.camera.zoom, w.camera.position]
func tick(count):
 for i in count: p.update(w, 1.0/60)
func shot(name):
 if DisplayServer.get_name() == "headless": return
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(captures + "/" + name + ".png")
func run():
 await process_frame
 DirAccess.make_dir_recursive_absolute(captures)
 w = load("res://scenes/main.tscn").instantiate()
 w.save_path = "res://build/story_cinematics/disposable_save.json"
 root.add_child(w)
 current_scene = w
 w.set_physics_process(false)
 w.player.set_physics_process(true)
 for enemy in w.enemies: enemy.set_physics_process(false)
 p = Presenter.new()
 root.add_child(p)
 p.configure(w)
 var save = FileAccess.open(w.save_path, FileAccess.WRITE)
 save.store_string("{\"sentinel\":true}")
 save.close()
 var before = state()
 await shot("before")
 for id in Presenter.PRESETS:
  w.player.set_physics_process(true)
  p.request_cutin(id)
  tick(1)
  check(p.active_id == id and not w.player.is_physics_processing(), id + " suspends input once")
  tick(30)
  await shot(id)
  tick(200)
  check(p.active_id.is_empty() and w.player.is_physics_processing(), id + " completes and restores control")
  check(state() == before, id + " preserves progression and gameplay camera")
  check(FileAccess.get_file_as_string(w.save_path) == "{\"sentinel\":true}", id + " leaves save bytes intact")
 p.request_cutin("opening_review")
 tick(1)
 var key = InputEventKey.new()
 key.physical_keycode = KEY_SPACE
 key.pressed = true
 p._unhandled_input(key)
 check(p.last_outcome == "skipped" and w.player.is_physics_processing(), "keyboard skip restores control")
 p.request_cutin("opening_review")
 tick(1)
 var pad = InputEventJoypadButton.new()
 pad.button_index = JOY_BUTTON_B
 pad.pressed = true
 p._unhandled_input(pad)
 check(p.last_outcome == "skipped" and w.player.is_physics_processing(), "synthetic gamepad B skip restores control")
 p.request_cutin("record_review")
 tick(1)
 p._notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
 check(p.last_outcome == "focus_lost" and w.player.is_physics_processing(), "focus loss restores lease")
 p.request_cutin("record_review")
 tick(1)
 paused = true
 p._process(0)
 check(p.last_outcome == "paused" and w.player.is_physics_processing(), "pause releases input lease before resume")
 paused = false
 var starts = p.starts
 w.transition = 0.4
 w.player.set_physics_process(false)
 p.request_cutin("record_review")
 tick(30)
 check(p.starts == starts and p.pending.size() == 1, "request defers throughout loader")
 w.transition = 0
 tick(1)
 check(p.starts == starts, "zero timer alone does not imply restored control")
 w.player.set_physics_process(true)
 tick(1)
 check(p.starts == starts + 1, "queued request begins after control restored")
 w.transition = .4
 w.pending_room = 1
 p.update(w, 0.1)
 check(p.last_outcome == "transition_interrupted" and not w.player.is_physics_processing(), "interrupt leaves transition input ownership intact")
 w.transition = 0
 w.pending_room = -1
 w.player.set_physics_process(true)
 p.reduced = true
 p.request_cutin("opening_review")
 tick(40)
 check(p.active_id.is_empty() and w.player.is_physics_processing(), "reduced presentation completes")
 p.enabled = false
 starts = p.starts
 p.request_cutin("record_review")
 tick(1)
 check(p.starts == starts and state() == before, "disabled presentation has identical gameplay state")
 p.enabled = true
 p.request_cutin("not_registered")
 check(p.pending.is_empty(), "unknown cut-in rejected safely")
 p.request_cutin("record_review")
 tick(1)
 p.cancel("room_rebuilt")
 check(p.active_id.is_empty() and w.player.is_physics_processing(), "integration owner room-rebuild cancellation releases lease")
 await shot("after_control_restored")
 check(state() == before, "all interruption paths preserve progression")
 p.queue_free()
 w.queue_free()
 current_scene = null
 for i in 3: await process_frame
 print("STORY CINEMATICS: %d checks, %d failure(s)" % [checks, failures])
 quit(1 if failures else 0)
