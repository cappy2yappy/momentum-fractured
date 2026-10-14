extends SceneTree
## Short paired native render samples; not a sustained frame-rate certification.
var intervals = []
var cpu_process = []
var cpu_physics = []
var dispatch_us = []
var previous = 0
var measuring = false
func _init(): call_deferred("run")
func _process(_dt):
	if measuring:
		var now = Time.get_ticks_usec()
		if previous: intervals.append((now-previous)/1000.0)
		previous = now
		cpu_process.append(Performance.get_monitor(Performance.TIME_PROCESS)*1000)
		cpu_physics.append(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)*1000)
	return false
func run():
	await process_frame
	var w = load("res://scenes/main.tscn").instantiate(); root.add_child(w); current_scene = w
	w.build_room(1); w.player.position = Vector2(1030,1300); w.player.invulnerable = 100
	w.audio.set_physics_process(false)
	for voice in w.audio.voices + w.audio.ambience + w.audio.music: voice.stop()
	if w.audio.ambience_tween: w.audio.ambience_tween.kill()
	var results = []
	for mode in ["silent_control", "audio_stress"]:
		if mode == "audio_stress":
			w.audio.set_physics_process(true); w.audio.profile = ""; w.audio.enter_room(1)
		await create_timer(1).timeout
		intervals.clear(); cpu_process.clear(); cpu_physics.clear(); dispatch_us.clear(); previous = 0; measuring = true
		for burst in 30:
			if mode == "audio_stress":
				var dispatch_start = Time.get_ticks_usec()
				for cue in ["swing", "dash", "contact", "impact_fire", "parry"]: w.audio.play(cue)
				dispatch_us.append(Time.get_ticks_usec()-dispatch_start)
			await create_timer(.2).timeout
		measuring = false; intervals.sort()
		var total = 0.0
		for value in intervals: total += value
		cpu_process.sort(); cpu_physics.sort(); dispatch_us.sort()
		results.append({"process_cpu_p95_ms": cpu_process[int(cpu_process.size()*.95)], "physics_cpu_p95_ms": cpu_physics[int(cpu_physics.size()*.95)], "five_cue_dispatch_p95_us": dispatch_us[int(dispatch_us.size()*.95)] if dispatch_us.size() else 0, "mode": mode, "frames": intervals.size(), "mean_ms": total / max(1,intervals.size()), "p95_ms": intervals[int(intervals.size()*.95)] if intervals.size() else 0, "max_ms": intervals.back() if intervals.size() else 0})
	var file = FileAccess.open("res://build/aud01/AUD01_PERFORMANCE.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"engine": Engine.get_version_info().string, "display": DisplayServer.get_name(), "audio_driver": AudioServer.get_driver_name(), "room": 1, "results": results, "voice_high_water": w.audio.high_water, "voice_drops": w.audio.dropped, "limitations": "Sequential six-second samples; scene state evolves; no sustained 60 FPS or audio-only causal claim."}, "  ")); file.close()
	w.queue_free(); current_scene = null
	for tick in 3: await process_frame
	print("AUDIO PERFORMANCE SAVED")
	quit()
