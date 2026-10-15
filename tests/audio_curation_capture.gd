extends SceneTree
## Technical mixer capture, not a creator listening montage or gameplay recording.
func _init(): call_deferred("run")
func run():
	await process_frame
	var w = load("res://scenes/main.tscn").instantiate()
	root.add_child(w); current_scene = w
	w.set_physics_process(false); w.player.set_physics_process(false)
	for enemy in w.enemies: enemy.set_physics_process(false)
	var a = w.audio
	if a.ambience_tween: a.ambience_tween.kill()
	for voice in a.ambience: voice.stop()
	var effect = AudioEffectRecord.new()
	effect.format = AudioStreamWAV.FORMAT_16_BITS
	AudioServer.add_bus_effect(0, effect); effect.set_recording_active(true)
	var started = Time.get_ticks_usec()
	var timeline = []
	var dispatch = []
	for cue in a.AUD02_CUES:
		timeline.append({"cue": cue, "seconds": (Time.get_ticks_usec() - started) / 1000000.0})
		a.play(cue); await create_timer(.48).timeout
	for burst in 20:
		var at = Time.get_ticks_usec()
		for cue in ["swing", "dash", "contact", "impact_fire", "parry"]: a.play(cue)
		dispatch.append(Time.get_ticks_usec() - at)
		await create_timer(.1).timeout
	await create_timer(.6).timeout
	effect.set_recording_active(false)
	var recording = effect.get_recording()
	DirAccess.make_dir_recursive_absolute("res://build/aud02")
	var rc = recording.save_to_wav("res://build/aud02/TECHNICAL_MIX.wav")
	dispatch.sort()
	var report = {"bank": a.bank, "audio_driver": AudioServer.get_driver_name(), "display": DisplayServer.get_name(), "recording_result": rc, "cue_counts": a.counts, "timeline": timeline, "dispatch_five_cues_p95_us": dispatch[int(dispatch.size() * .95)], "high_water": a.high_water, "dropped": a.dropped, "device_latency": "NOT MEASURED", "sustained_60fps": "NOT CERTIFIED", "manual_listening": "NOT PERFORMED"}
	var file = FileAccess.open("res://build/aud02/TECHNICAL_MIX.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "  ")); file.close()
	AudioServer.remove_bus_effect(0, AudioServer.get_bus_effect_count(0)-1)
	w.queue_free(); await process_frame
	print("AUD02 TECHNICAL CAPTURE: ", rc)
	quit(0 if rc == OK else 1)
