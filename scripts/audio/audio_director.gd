extends Node
## Audio observes events. Never changes gameplay, timers, input or profile data.
const CUES = ["step_stone", "step_wood", "jump", "land", "dash", "tether_fire", "tether_attach", "tether_release", "swing", "contact", "kunai_throw", "impact_wind", "impact_fire", "impact_electric", "parry", "damage", "death", "checkpoint", "room_passage", "reject"]
const CRITICAL = ["parry", "damage", "death", "checkpoint", "room_passage"]
const BUS_DB = {"Music": -8.0, "SFX": -4.0, "Ambience": -8.0, "UI": -6.0}
var world
var streams: Dictionary = {}
var voices: Array[AudioStreamPlayer] = []
var ambience: Array[AudioStreamPlayer] = []
var music: Array[AudioStreamPlayer] = []
var counts: Dictionary = {}
var last_times: Dictionary = {}
var clock = 0.0
var dropped = 0
var high_water = 0
var profile = ""
var ambience_slot = 0
var music_slot = 0
var ambience_tween: Tween
var music_tween: Tween
var walked = 0.0
var grounded = false
var last_position = Vector2.ZERO
var suspended = false
var bank = "aud01"
const AUD02_CUES = ["dash", "swing", "contact", "parry", "kunai_throw", "tether_fire", "tether_attach", "tether_release", "impact_wind", "impact_fire", "impact_electric", "room_passage"]

func _ready():
	process_physics_priority = 100 # Sample resolved movement after the controller.
	for cue in CUES:
		streams[cue] = load("res://assets/audio/%s.wav" % cue)
	for cue in ["amb_city", "amb_canal"]:
		var stream = load("res://assets/audio/%s.wav" % cue).duplicate() as AudioStreamWAV
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = stream.data.size() / 2
		streams[cue] = stream
	# AUD02 is an isolated listening candidate; established identity stays default.
	if "--audio-bank=aud02" in OS.get_cmdline_user_args():
		bank = "aud02"
		for cue in AUD02_CUES:
			var path = "res://assets/audio/aud02/%s.wav" % cue
			if ResourceLoader.exists(path):
				var candidate = load(path) as AudioStreamWAV
				if candidate != null and candidate.get_length() > 0:
					streams[cue] = candidate
	for i in 12: voices.append(make_player("SFX"))
	for i in 2:
		ambience.append(make_player("Ambience"))
		music.append(make_player("Music"))
	# Independent launch controls do not change gameplay save schema or HUD hierarchy.
	for bus in BUS_DB:
		set_volume(bus, 1.0)
		for arg in OS.get_cmdline_user_args():
			var prefix = "--audio-%s=" % bus.to_lower()
			if arg.begins_with(prefix) and arg.trim_prefix(prefix).is_valid_float():
				set_volume(bus, float(arg.trim_prefix(prefix)))

func make_player(bus: String) -> AudioStreamPlayer:
	var voice = AudioStreamPlayer.new()
	voice.bus = bus
	voice.max_polyphony = 1
	add_child(voice)
	return voice

func set_volume(bus: String, value: float):
	if not BUS_DB.has(bus): return
	var index = AudioServer.get_bus_index(bus)
	if index < 0: return
	var level = clampf(value, 0, 1)
	AudioServer.set_bus_mute(index, level <= 0)
	AudioServer.set_bus_volume_db(index, BUS_DB[bus] + linear_to_db(maxf(level, .0001)))

func play(cue: String) -> bool:
	if not streams.has(cue) or get_tree().paused or suspended: return false
	if is_instance_valid(world) and world.transition > 0 and cue != "room_passage": return false
	# Critical cues have a reserved four-voice pool; never steal damage for a step.
	var critical = cue in CRITICAL
	var gap = .04 if critical else (.16 if cue.begins_with("step_") else .07)
	if clock - float(last_times.get(cue, -100.0)) < gap: return false
	var begin = 8 if critical else 0
	var end = 12 if critical else 8
	var chosen: AudioStreamPlayer
	for i in range(begin, end):
		if not voices[i].playing:
			chosen = voices[i]
			break
	if chosen == null:
		if not critical:
			dropped += 1
			return false
		chosen = voices[begin]
		for i in range(begin, end):
			if float(voices[i].get_meta("started", 0.0)) < float(chosen.get_meta("started", 0.0)): chosen = voices[i]
		chosen.stop()
	chosen.bus = "UI" if cue in ["checkpoint", "reject"] else "SFX"
	chosen.stream = streams[cue]
	chosen.volume_db = -4.0 if cue.begins_with("step_") else 0.0
	chosen.pitch_scale = 1.0
	chosen.set_meta("started", clock)
	chosen.play()
	last_times[cue] = clock
	counts[cue] = int(counts.get(cue, 0)) + 1
	high_water = maxi(high_water, active_voice_count())
	return true

func active_voice_count() -> int:
	var active = 0
	for voice in voices:
		if voice.playing: active += 1
	return active

func profile_for_room(room: int) -> String:
	return "amb_canal" if room in [0, 2, 3, 8, 15, 16, 18, 19, 20] else "amb_city"

func enter_room(room: int):
	reset_motion()
	var next = profile_for_room(room)
	if next == profile: return
	profile = next
	if ambience_tween: ambience_tween.kill()
	var old = ambience[ambience_slot]
	ambience_slot = 1 - ambience_slot
	var incoming = ambience[ambience_slot]
	incoming.stop()
	incoming.stream = streams[next]
	incoming.volume_db = -60
	incoming.play()
	ambience_tween = create_tween().set_parallel(true)
	ambience_tween.tween_property(old, "volume_db", -60.0, .4)
	ambience_tween.tween_property(incoming, "volume_db", 0.0, .4)
	ambience_tween.chain().tween_callback(old.stop)

func reset_motion():
	walked = 0
	grounded = false
	if is_instance_valid(world) and is_instance_valid(world.player): last_position = world.player.position

func clear_action_voices():
	for voice in voices:
		if voice.stream != streams.get("death") and voice.stream != streams.get("damage") and voice.stream != streams.get("room_passage"): voice.stop()
	reset_motion()

func _physics_process(dt):
	clock += dt
	if not is_instance_valid(world) or not is_instance_valid(world.player): return
	var player = world.player
	if world.transition > 0 or not player.is_physics_processing():
		reset_motion()
		return
	var on_floor = player.is_on_floor()
	var distance = player.position.distance_to(last_position)
	# Teleports/respawns cannot produce landings or accumulate footsteps.
	if distance > 80:
		grounded = on_floor
		walked = 0
	else:
		if on_floor and not grounded: play("land")
		if on_floor and grounded and player.dash_time <= 0 and player.hitstop <= 0:
			walked += absf(player.position.x - last_position.x)
			if walked >= 125 and absf(player.velocity.x) > 40:
				play("step_wood" if world.room in [13, 14] else "step_stone")
				walked = 0
		else: walked = 0
		grounded = on_floor
	last_position = player.position

func set_music(stream: AudioStream):
	## Approved exports only. null fades to silence. Same resource does not restart.
	if music[music_slot].stream == stream: return
	if music_tween: music_tween.kill()
	var old = music[music_slot]
	music_slot = 1 - music_slot
	var incoming = music[music_slot]
	incoming.stop()
	incoming.stream = stream
	incoming.volume_db = -60
	if stream: incoming.play()
	music_tween = create_tween().set_parallel(true)
	music_tween.tween_property(old, "volume_db", -60.0, .6)
	if stream: music_tween.tween_property(incoming, "volume_db", 0.0, .6)
	music_tween.chain().tween_callback(old.stop)

func _notification(what):
	if what == NOTIFICATION_PAUSED:
		suspended = true
		for voice in voices: voice.stop()
		for voice in ambience + music: voice.stream_paused = true
	elif what == NOTIFICATION_UNPAUSED:
		suspended = false
		for voice in ambience + music: voice.stream_paused = false
		reset_motion()
