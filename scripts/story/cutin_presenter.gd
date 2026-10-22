extends Node
## Presentation sink only. INT-01 owns all rules, flags and persistence.
const PRESETS = {
 "opening_review": preload("res://presets/cutins/major_biome.tscn"),
 "record_review": preload("res://presets/cutins/special_transition.tscn"),
 "fallen_clan_review": preload("res://presets/cutins/major_biome.tscn")
}
const COPY = {
 "opening_review": "[TEST FIXTURE] APPROVED OPENING\nThe refuge was attacked. I have to find the others.",
 "record_review": "[TEST FIXTURE] EXISTING RECORD / R14\nBellkeepers marked this roof as the convoy's quiet route.",
 "fallen_clan_review": "[TEST FIXTURE] B06 PROVISIONAL / CREATOR APPROVAL REQUIRED\nNo body or new story assertion is depicted.\nTiming and dismissal study only."
}
var world
var pending: Array[String] = []
var active_id = ""
var source_room = -1
var source_player
var screen: CanvasLayer
var cutin
var sequence: AnimationPlayer
var age = 0.0
var starts = 0
var last_outcome = "idle"
var enabled = true
var reduced = false
var prior_physics = true

func configure(w):
 world = w
 process_mode = Node.PROCESS_MODE_ALWAYS
 screen = CanvasLayer.new()
 screen.layer = 96
 add_child(screen)

func request_cutin(id: String) -> void:
 if not PRESETS.has(id):
  last_outcome = "unknown_id"
  return
 if not enabled:
  last_outcome = "disabled"
  return
 if pending.size() < 3 and not pending.has(id): pending.append(id)

func control_available() -> bool:
 return is_instance_valid(world) and not get_tree().paused and world.transition <= 0 and world.pending_room < 0 and world.player.hp > 0 and world.player.is_physics_processing() and not world.cinematic_transitions.active and not world.cinematic_transitions.tr08.owns() and world.cinematic_transitions.staged.phase == "" and not world.embodied_transitions.active and not world.mixed_transitions.active_walk and not world.mixed_transitions.active_special

func update(_w, dt: float) -> void:
 if not enabled:
  pending.clear()
  finish("disabled")
  return
 if active_id.is_empty():
  if not pending.is_empty() and control_available(): begin(pending.pop_front())
  return
 if world.player != source_player or world.room != source_room or world.player.hp <= 0:
  finish("superseded")
  pending.clear()
  return
 if world.transition > 0 or world.pending_room >= 0 or world.cinematic_transitions.tr08.owns():
  finish("transition_interrupted")
  return
 age += dt
 if age >= 8.0 or not is_instance_valid(sequence):
  finish("watchdog")
  return
 sequence.advance(dt)
 # These labels override generic authoring-template titles, not canonical prose.
 apply_labels(active_id)
 cutin.get_node("Status").text = "ISOLATED REVIEW • approved Kaze art / ART-08 animation candidate"
 if cutin.handoff or not sequence.is_playing(): finish("completed")

func apply_labels(id: String):
 cutin.get_node("Title").text = COPY[id]
 cutin.get_node("Title").add_theme_font_size_override("font_size", 28)
 cutin.get_node("Destination").text = "[TEST FIXTURE] Presentation review only; no world placement approved."

func begin(id: String):
 active_id = id
 source_room = world.room
 source_player = world.player
 prior_physics = source_player.is_physics_processing()
 source_player.set_physics_process(false)
 world.hud.clear_touches()
 cutin = PRESETS[id].instantiate()
 screen.add_child(cutin)
 sequence = cutin.get_node("AnimationPlayer")
 sequence.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
 sequence.play("reduced" if reduced else "standard")
 sequence.advance(0)
 apply_labels(id)
 age = 0.0
 starts += 1
 last_outcome = "presenting"

func finish(reason: String):
 if active_id.is_empty(): return
 if is_instance_valid(sequence): sequence.stop()
 if is_instance_valid(cutin):
  cutin.visible = false
  cutin.queue_free()
 # Never steal input back from a transition, death or replacement player.
 if is_instance_valid(world) and is_instance_valid(source_player) and world.player == source_player and world.room == source_room and world.transition <= 0 and world.pending_room < 0 and world.player.hp > 0 and not world.cinematic_transitions.tr08.owns():
  source_player.set_physics_process(prior_physics)
 active_id = ""
 sequence = null
 cutin = null
 last_outcome = reason

func cancel(reason: String = "world_cancelled") -> void:
 pending.clear()
 finish(reason)

func _process(_dt):
 if get_tree().paused: finish("paused")

func _notification(what):
 if what == NOTIFICATION_APPLICATION_FOCUS_OUT: finish("focus_lost")

func _unhandled_input(event):
 var skip_key = event is InputEventKey and event.pressed and event.physical_keycode == KEY_SPACE
 var skip_pad = event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_B
 if (skip_key or skip_pad) and not active_id.is_empty():
  finish("skipped")
  get_viewport().set_input_as_handled()

func _exit_tree(): finish("removed")
