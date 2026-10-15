extends SceneTree
var failures = 0
func _init(): call_deferred("run")
func check(ok, message):
	print("PASS: " if ok else "FAIL: ", message)
	if not ok: failures += 1
func run():
	await process_frame
	var w = load("res://scenes/main.tscn").instantiate()
	root.add_child(w); current_scene = w
	w.set_physics_process(false); w.player.set_physics_process(false)
	for enemy in w.enemies: enemy.set_physics_process(false)
	var a = w.audio
	var selected = "--audio-bank=aud02" in OS.get_cmdline_user_args()
	check(a.bank == ("aud02" if selected else "aud01"), "Candidate bank requires explicit opt-in")
	for cue in a.CUES:
		var expected = "res://assets/audio/" + ("aud02/" if selected and cue in a.AUD02_CUES else "") + cue + ".wav"
		check(a.streams[cue].resource_path == expected, cue + " resolves to expected bank or fallback")
		check(a.streams[cue].format == AudioStreamWAV.FORMAT_16_BITS and a.streams[cue].mix_rate == 22050, cue + " retains PCM16 / 22050 Hz")
	check(a.voices.size() == 12 and a.music.size() == 2 and a.ambience.size() == 2, "No player-budget increase")
	check(not a.music[0].playing and not a.music[1].playing, "Soundtrack remains silent")
	var velocity = w.player.velocity
	var hp = w.player.hp
	for cue in a.AUD02_CUES:
		a.clock += 1
		for voice in a.voices: voice.stop()
		check(a.play(cue), cue + " candidate dispatch succeeds")
	check(w.player.velocity == velocity and w.player.hp == hp, "Bank audition does not alter movement or damage")
	print("AUDIO CURATION: ", failures, " failure(s)")
	w.queue_free(); await process_frame; quit(1 if failures else 0)
