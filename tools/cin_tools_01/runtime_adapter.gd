extends "res://scripts/cinematic_transitions.gd"
## Installed only by the isolated demo. Existing game and TR-08 stay unchanged.
@export var preset: PackedScene = preload("res://presets/cutins/special_transition.tscn")
var cutin: Node2D
var screen: CanvasLayer
var sequence: AnimationPlayer
var source_room = -1
var accepted_target = -1
var accepted_arrival = Vector2.INF
var owning = false
var delegating = false
var handoffs = 0
var age = 0.0
var prior_physics = true
var max_duration = 12.0
var last_outcome = ""

func configure(w):
	super.configure(w)
	screen = CanvasLayer.new()
	screen.layer = 95
	add_child(screen)

func intercept(w, target: int, arrival: Vector2) -> bool:
	if delegating: return super.intercept(w, target, arrival)
	if owning: return true
	if tr08.owns(): return super.intercept(w, target, arrival)
	# Only this explicitly opted-in stair pilot; automatic door semantics unchanged.
	if not enabled or not tr08.enabled or not tr08.stair.applies(w, target):
		return super.intercept(w, target, arrival)
	if not w.player.is_physics_processing(): return true
	source_room = w.room
	accepted_target = target
	accepted_arrival = arrival
	prior_physics = w.player.is_physics_processing()
	owning = true
	age = 0.0
	last_outcome = "presenting"
	w.player.set_physics_process(false)
	w.hud.clear_touches()
	if not preset:
		finish_presentation(true)
		return true
	var instance = preset.instantiate()
	if not instance is Node2D:
		instance.free()
		finish_presentation(true)
		return true
	cutin = instance
	screen.add_child(cutin)
	sequence = cutin.get_node_or_null("AnimationPlayer") as AnimationPlayer
	var animation_name = "reduced" if reduced else "standard"
	if not sequence or not sequence.has_animation(animation_name) or not "handoff" in cutin or not "audio_enabled" in cutin:
		finish_presentation(true)
		return true
	cutin.audio_enabled = true
	# Native animations are advanced by the existing world presentation tick so
	# pause/focus handling and tests use the same bounded clock as TR-08.
	sequence.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	sequence.play(animation_name)
	sequence.advance(0)
	return true

func present(w):
	if owning:
		age += last_dt
		if w.player.hp <= 0 or w.room != source_room:
			abandon("superseded")
		elif age >= max_duration or not is_instance_valid(sequence):
			finish_presentation(true)
		else:
			sequence.advance(last_dt)
			if cutin.handoff or not sequence.is_playing(): finish_presentation(false)
	super.present(w)

func remove_presentation():
	if is_instance_valid(sequence): sequence.stop()
	if is_instance_valid(cutin):
		cutin.visible = false
		cutin.queue_free()
	cutin = null
	sequence = null

func finish_presentation(skip_rest: bool):
	if not owning: return
	if world.room != source_room or world.player.hp <= 0:
		abandon("superseded")
		return
	# Drop ownership BEFORE re-entry. TR-08 takes the lease and loader request.
	owning = false
	remove_presentation()
	world.player.set_physics_process(prior_physics)
	delegating = true
	handoffs += 1
	world.request_room(accepted_target, accepted_arrival)
	delegating = false
	last_outcome = "handed_to_tr08"
	if skip_rest: skip_tr08()

func skip_tr08():
	# Commit the accepted request before restoring presentation; cancel alone
	# intentionally aborts an uncommitted TR-08 sequence.
	var stair = tr08.stair
	if stair.phase != "":
		if stair.request_time < 0: stair.release(world)
		if stair.phase != "": stair.restore(world, "cin_tools_skip")
	last_outcome = "skipped"

func skip():
	if owning: finish_presentation(true)
	elif tr08.stair.phase != "": skip_tr08()

func abandon(reason: String):
	if not owning: return
	owning = false
	remove_presentation()
	if is_instance_valid(world.player) and world.transition <= 0:
		world.player.set_physics_process(prior_physics)
	last_outcome = reason

func room_loaded(w):
	if owning: abandon("room_rebuilt")
	super.room_loaded(w)

func cancel(w):
	# Explicit world cancellation (respawn/reset) supersedes the requested trip.
	abandon("cancelled_by_world")
	super.cancel(w)

func _notification(what):
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_instance_valid(world): skip()

func _process(dt):
	# Always-process mode lets this commit a pending handoff before pause cancels
	# TR-08. The loader itself remains paused until normal game resume.
	if is_instance_valid(world) and get_tree().paused: skip()
	super._process(dt)

func _unhandled_key_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_SPACE and (owning or tr08.stair.phase != ""):
			skip()
			get_viewport().set_input_as_handled()
			return
		if event.physical_keycode == KEY_F6 and owning:
			super._unhandled_key_input(event)
			if reduced:
				sequence.stop()
				sequence.play("reduced")
				sequence.advance(0)
			return
	super._unhandled_key_input(event)

func _exit_tree():
	abandon("removed")
