extends Node

## Centralized audio runtime.
## Uses real assets when present and synthesized fallback tones otherwise.

const SFX_POOL_SIZE := 10
const SAMPLE_RATE := 44100

const SFX_FILES := {
	"attack_swing": "res://assets/audio/sfx/attack_swing.wav",
	"hit_impact": "res://assets/audio/sfx/hit_impact.wav",
	"enemy_death": "res://assets/audio/sfx/enemy_death.wav",
	"door_unlock": "res://assets/audio/sfx/door_unlock.wav",
	"checkpoint": "res://assets/audio/sfx/checkpoint.wav",
	"cell_pickup": "res://assets/audio/sfx/cell_pickup.wav",
	"damage_taken": "res://assets/audio/sfx/damage_taken.wav",
	"jump": "res://assets/audio/sfx/jump.wav",
}

const MUSIC_FILES := {
	"combat_theme": "res://assets/audio/music/combat_theme.ogg",
	"exploration_theme": "res://assets/audio/music/exploration_theme.ogg",
	"boss_theme": "res://assets/audio/music/boss_theme.ogg",
}

const SFX_FALLBACK_PRESETS := {
	"attack_swing": {"freq": 460.0, "duration": 0.12, "volume": -9.0, "wave": "triangle"},
	"hit_impact": {"freq": 220.0, "duration": 0.1, "volume": -7.0, "wave": "square"},
	"enemy_death": {"freq": 280.0, "duration": 0.24, "volume": -7.0, "wave": "fall"},
	"door_unlock": {"freq": 520.0, "duration": 0.18, "volume": -9.0, "wave": "rise"},
	"checkpoint": {"freq": 860.0, "duration": 0.18, "volume": -7.0, "wave": "sine"},
	"cell_pickup": {"freq": 760.0, "duration": 0.12, "volume": -8.0, "wave": "rise"},
	"damage_taken": {"freq": 180.0, "duration": 0.2, "volume": -7.0, "wave": "fall"},
	"jump": {"freq": 640.0, "duration": 0.1, "volume": -10.0, "wave": "sine"},
}

const MUSIC_FALLBACK_FREQ := {
	"combat_theme": 156.0,
	"exploration_theme": 124.0,
	"boss_theme": 176.0,
}

var _sfx_volume_db: float = 0.0
var _music_volume_db: float = -8.0
var _current_music_track: String = ""

var _music_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx_index: int = 0

var _sfx_cache: Dictionary = {}
var _music_cache: Dictionary = {}

var _music_fallback_playback: AudioStreamGeneratorPlayback = null
var _music_fallback_freq: float = 120.0
var _music_phase: float = 0.0


func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.name = "MusicPlayer"
	_music_player.volume_db = _music_volume_db
	add_child(_music_player)

	for i in SFX_POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.name = "SFXPlayer_%d" % i
		add_child(player)
		_sfx_players.append(player)


func _process(_delta: float) -> void:
	if _music_fallback_playback == null:
		return

	var frames_available: int = _music_fallback_playback.get_frames_available()
	for _i in range(frames_available):
		var sample := sin(_music_phase) * 0.055
		_music_phase += TAU * _music_fallback_freq / float(SAMPLE_RATE)
		_music_fallback_playback.push_frame(Vector2(sample, sample))


func play_sfx(sound_name: String) -> void:
	if _sfx_players.is_empty():
		return

	var player := _sfx_players[_sfx_index]
	_sfx_index = (_sfx_index + 1) % _sfx_players.size()

	var stream: AudioStream = _get_cached_stream(sound_name, SFX_FILES, _sfx_cache)
	if stream:
		player.stop()
		player.stream = stream
		player.volume_db = _sfx_volume_db
		player.play()
		return

	if not SFX_FALLBACK_PRESETS.has(sound_name):
		return

	var config: Dictionary = SFX_FALLBACK_PRESETS[sound_name]
	player.volume_db = float(config.get("volume", -10.0)) + _sfx_volume_db
	_play_tone(player, config)


func play_music(track_name: String) -> void:
	if track_name.is_empty():
		return
	if _current_music_track == track_name and _music_player.playing:
		return

	var stream: AudioStream = _get_cached_stream(track_name, MUSIC_FILES, _music_cache)
	_current_music_track = track_name
	_music_player.volume_db = _music_volume_db

	if stream:
		_music_fallback_playback = null
		_music_player.stop()
		_music_player.stream = stream
		_music_player.play()
		return

	_play_music_fallback(track_name)


func stop_music() -> void:
	_current_music_track = ""
	_music_fallback_playback = null
	_music_player.stop()


func set_sfx_volume(volume: float) -> void:
	_sfx_volume_db = volume


func set_music_volume(volume: float) -> void:
	_music_volume_db = volume
	if _music_player:
		_music_player.volume_db = _music_volume_db


func _get_cached_stream(name: String, file_map: Dictionary, cache: Dictionary) -> AudioStream:
	if cache.has(name):
		return cache[name]
	if not file_map.has(name):
		cache[name] = null
		return null

	var path: String = String(file_map[name])
	if ResourceLoader.exists(path):
		var stream := load(path)
		if stream is AudioStream:
			cache[name] = stream
			return stream

	cache[name] = null
	return null


func _play_music_fallback(track_name: String) -> void:
	_music_fallback_freq = float(MUSIC_FALLBACK_FREQ.get(track_name, 130.0))
	_music_phase = 0.0

	var generator := AudioStreamGenerator.new()
	generator.mix_rate = SAMPLE_RATE
	generator.buffer_length = 1.2

	_music_player.stop()
	_music_player.stream = generator
	_music_player.play()

	var playback = _music_player.get_stream_playback()
	if playback is AudioStreamGeneratorPlayback:
		_music_fallback_playback = playback as AudioStreamGeneratorPlayback
	else:
		_music_fallback_playback = null


func _play_tone(player: AudioStreamPlayer, config: Dictionary) -> void:
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = SAMPLE_RATE
	stream.buffer_length = maxf(float(config.get("duration", 0.15)) + 0.1, 0.2)
	player.stream = stream
	player.play()

	var playback = player.get_stream_playback()
	if playback == null:
		return

	var duration := float(config.get("duration", 0.15))
	var base_freq := float(config.get("freq", 440.0))
	var wave := String(config.get("wave", "sine"))
	var sample_count := int(stream.mix_rate * duration)

	for i in sample_count:
		var t := float(i) / stream.mix_rate
		var normalized := t / maxf(duration, 0.0001)
		var freq := base_freq
		if wave == "rise":
			freq = lerpf(base_freq * 0.8, base_freq * 1.25, normalized)
		elif wave == "fall":
			freq = lerpf(base_freq * 1.25, base_freq * 0.7, normalized)

		var phase := TAU * freq * t
		var amplitude := (1.0 - normalized) * 0.25
		var sample := 0.0
		match wave:
			"square":
				sample = sign(sin(phase)) * amplitude
			"triangle":
				sample = asin(sin(phase)) * (2.0 / PI) * amplitude
			_:
				sample = sin(phase) * amplitude

		playback.push_frame(Vector2(sample, sample))
