@tool
extends Node2D
## Presentation-only data. Property keys are harmless during native editor scrubbing.
## Framing is a canvas transform, never the gameplay Camera2D.
@export var handoff = false
@export var sample_time = 0.0:
	set(value):
		sample_time = value
		_update_shake()
@export_range(0, 30) var shake_strength = 0.0:
	set(value):
		shake_strength = value
		_update_shake()
@export var music_cue = ""
@export var sound_event = ""
@export_multiline var artwork_status = "ART-08 candidate; creator acceptance pending."
var audio_enabled = false
var _last_sound = ""
var _last_music = ""

func _update_shake():
	var rig = get_node_or_null("Framing/Shake")
	if rig:
		rig.position = Vector2(sin(sample_time * 83), sin(sample_time * 67)) * shake_strength

func _process(_dt):
	if Engine.is_editor_hint(): return
	var player = get_node_or_null("AnimationPlayer") as AnimationPlayer
	if not player or not player.is_playing() or not audio_enabled: return
	# Cue references are authoring labels; assign streams on these native nodes.
	if sound_event != _last_sound:
		_last_sound = sound_event
		if not sound_event.is_empty() and $SFX.stream: $SFX.play()
	if music_cue != _last_music:
		_last_music = music_cue
		if not music_cue.is_empty() and $Music.stream: $Music.play()

func _ready():
	if Engine.is_editor_hint(): return
	var actor = get_node_or_null("Framing/Shake/Character") as Sprite2D
	if not actor or actor.texture: return
	# Missing artwork never controls the room handoff. Repair only this instance's
	# native key values, keep timing and mark the approved idle as a stand-in.
	var fallback = load("res://assets/kaze/cleaned/kaze_idle_strip.png")
	actor.texture = fallback
	actor.hframes = 8
	actor.offset = Vector2(0,-229)
	artwork_status = "MISSING CLIP: approved idle stand-in; animation pending."
	$Status.text = artwork_status
	var player = $AnimationPlayer as AnimationPlayer
	var library = player.get_animation_library("").duplicate(true)
	player.remove_animation_library("")
	player.add_animation_library("",library)
	for name in library.get_animation_list():
		var anim = library.get_animation(name)
		for track in anim.get_track_count():
			var path = str(anim.track_get_path(track))
			for key in anim.track_get_key_count(track):
				if path == "Framing/Shake/Character:texture": anim.track_set_key_value(track,key,fallback)
				elif path == "Framing/Shake/Character:hframes": anim.track_set_key_value(track,key,8)
				elif path == "Framing/Shake/Character:offset": anim.track_set_key_value(track,key,Vector2(0,-229))
