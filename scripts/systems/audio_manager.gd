extends Node

## Lightweight audio manager with synthesized placeholder tones.
## Uses pooled players to avoid runtime allocation churn.

const SFX_PRESETS := {
	"attack_swing": {"freq": 440.0, "duration": 0.12, "volume": -10.0, "wave": "triangle"},
	"hit_impact": {"freq": 220.0, "duration": 0.1, "volume": -8.0, "wave": "square"},
	"enemy_death": {"freq": 280.0, "duration": 0.24, "volume": -7.0, "wave": "fall"},
	"door_unlock": {"freq": 520.0, "duration": 0.18, "volume": -9.0, "wave": "rise"},
	"checkpoint": {"freq": 880.0, "duration": 0.18, "volume": -7.0, "wave": "sine"},
	"jump": {"freq": 660.0, "duration": 0.1, "volume": -11.0, "wave": "sine"},
}

const SFX_POOL_SIZE := 8

var _sfx_volume_db: float = 0.0
var _music_volume_db: float = -8.0
var _music_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx_index: int = 0


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


func play_sfx(sound_name: String) -> void:
	if not SFX_PRESETS.has(sound_name) or _sfx_players.is_empty():
		return

	var config: Dictionary = SFX_PRESETS[sound_name]
	var player := _sfx_players[_sfx_index]
	_sfx_index = (_sfx_index + 1) % _sfx_players.size()
	player.volume_db = float(config.get("volume", -10.0)) + _sfx_volume_db
	_play_tone(player, config)


func play_music(track_name: String) -> void:
	# Placeholder: map tracks to sustained tones until real music assets are available.
	var freq := 140.0
	if track_name == "combat":
		freq = 170.0
	elif track_name == "safe_room":
		freq = 120.0

	var stream := AudioStreamGenerator.new()
	stream.mix_rate = 44100
	stream.buffer_length = 1.0
	_music_player.stream = stream
	_music_player.play()

	var playback := _music_player.get_stream_playback()
	if playback == null:
		return

	var samples := int(stream.mix_rate * 0.8)
	for i in samples:
		var t := float(i) / stream.mix_rate
		var sample := sin(TAU * freq * t) * 0.08
		playback.push_frame(Vector2(sample, sample))


func set_sfx_volume(volume: float) -> void:
	_sfx_volume_db = volume


func set_music_volume(volume: float) -> void:
	_music_volume_db = volume
	if _music_player:
		_music_player.volume_db = _music_volume_db


func _play_tone(player: AudioStreamPlayer, config: Dictionary) -> void:
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = 44100
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
