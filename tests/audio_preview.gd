extends SceneTree
## Seeded engine-mixer recording, not a human campaign recording or music.
var w
var effect: AudioEffectRecord
var timeline = []
var started = 0
var frame_times = []
var previous_frame = 0
var measuring = false
var peak_left = -100.0
var peak_right = -100.0
func _init(): call_deferred("run")
func mark(label):
	timeline.append({"seconds": (Time.get_ticks_msec() - started) / 1000.0, "event": label})
func wait(seconds): await create_timer(seconds).timeout
func freeze():
	w.set_physics_process(false); w.player.set_physics_process(false)
	for enemy in w.enemies: enemy.set_physics_process(false)
func _process(_dt):
	if measuring:
		var now = Time.get_ticks_usec()
		if previous_frame: frame_times.append((now - previous_frame) / 1000.0)
		previous_frame = now
		peak_left = maxf(peak_left, AudioServer.get_bus_peak_volume_left_db(0, 0))
		peak_right = maxf(peak_right, AudioServer.get_bus_peak_volume_right_db(0, 0))
	return false
func run():
	await process_frame
	w = load("res://scenes/main.tscn").instantiate(); root.add_child(w); current_scene = w
	freeze()
	effect = AudioEffectRecord.new(); effect.format = AudioStreamWAV.FORMAT_16_BITS
	AudioServer.add_bus_effect(0, effect)
	effect.set_recording_active(true)
	started = Time.get_ticks_msec()
	mark("Canal bed; silence is the music slot")
	w.player.position = Vector2(220,1298); w.player.set_physics_process(true)
	await wait(.4)
	mark("Real walk, jump, landing")
	w.player.touch["right"] = true; await wait(.75); w.player.touch.clear()
	w.player.touch["jump"] = true; w.player.press("jump"); await wait(.2); w.player.touch.clear(); await wait(1.0)
	w.player.dash_unlocked = true; mark("Accepted dash"); w.player.press("dash"); await wait(.6)
	freeze(); w.build_room(1); freeze()
	w.player.position = Vector2(1030,1300); w.player.facing = 1
	mark("Swing, confirmed contact, successful guard parry")
	w.player.start_attack(0); await wait(.12); w.on_strike(1,95); await wait(.45)
	w.player.parry_time = .2; w.guard.state = "strike"; w.guard.strike_done = false; w.guard.timer = .16; w.guard._physics_process(.01)
	await wait(.55)
	mark("Accepted damage then death")
	w.player.hp = 3; w.player.invulnerable = 0; w.player.damage(Vector2.ZERO); await wait(.65)
	w.player.hp = 1; w.player.invulnerable = 0; w.player.damage(Vector2.ZERO); await wait(.85); freeze()
	w.build_room(4); freeze(); w.player.position = Vector2(1190,900); w.player.velocity = Vector2(300,80)
	w.player.dash_time = 0; w.player.attack_time = 0; w.player.hitstop = 0; w.player.grapple_clearance_check = false
	w.player.set_physics_process(true); await wait(.05); w.player.set_physics_process(false)
	mark("Accepted tether fire/attach then release")
	w.player.tether_unlocked = true; w.on_tether_requested(); await wait(.3); w.player.release_tether(); await wait(.5)
	for element in ["wind", "fire", "electric"]:
		w.build_room(2); freeze(); w.create_kunai_gate("preview_" + element, element, Vector2(500,500),100)
		mark(element + " kunai throw then real seal impact")
		w.spawn_kunai(element,1,Vector2(350,450)); await wait(.6)
	w.build_room(0); freeze(); w.player.position = Vector2(220,1300)
	mark("Checkpoint interaction"); w.interact(); await wait(.8)
	mark("Accepted passage, canal to city crossfade")
	w.request_room(1); w.set_physics_process(true); await wait(.8); freeze()
	w.build_room(14); freeze(); mark("R14 roof bed, eight seconds across loop seam"); await wait(8.3)
	w.build_room(15); freeze(); mark("R15 canal crossfade, eight seconds across loop seam"); await wait(8.3)
	# Normal rendered busy-room sample, separate from deterministic showcase actions.
	w.build_room(1); w.player.position = Vector2(1030,1300); w.player.hp = 3; w.player.invulnerable = 100
	w.player.attack_time = 0; w.player.hitstop = 0; w.player.set_physics_process(true); w.set_physics_process(true)
	mark("Six-second busy-room sample, natural enemies plus audio overload")
	await wait(.5); measuring = true
	for burst in 30:
		w.audio.play("swing"); w.audio.play("dash"); w.audio.play("impact_fire"); w.audio.play("parry")
		await wait(.2)
	measuring = false
	effect.set_recording_active(false)
	var recording = effect.get_recording()
	var out = "res://build/aud01/"
	var rc = recording.save_to_wav(out + "AUD01_ENGINE_MIX.wav")
	frame_times.sort()
	var sum_ms = 0.0
	for time in frame_times: sum_ms += time
	var result = {"engine": Engine.get_version_info().string, "audio_driver": AudioServer.get_driver_name(), "display": DisplayServer.get_name(), "recording_result": rc, "timeline": timeline, "cue_counts": w.audio.counts, "pool_high_water": w.audio.high_water, "pool_dropped": w.audio.dropped, "sample_seconds": 6, "frame_count": frame_times.size(), "mean_ms": sum_ms / max(1,frame_times.size()), "p95_ms": frame_times[int(frame_times.size()*.95)] if frame_times.size() else 0, "max_ms": frame_times.back() if frame_times.size() else 0, "master_meter_peak_db": [peak_left,peak_right], "manual_listening": "not performed; creator review required", "sustained_60fps": "not certified"}
	var file = FileAccess.open(out + "AUD01_PREVIEW_RESULTS.json", FileAccess.WRITE); file.store_string(JSON.stringify(result,"  ")); file.close()
	AudioServer.remove_bus_effect(0, AudioServer.get_bus_effect_count(0)-1)
	w.queue_free(); current_scene = null
	for tick in 3: await process_frame
	print("AUDIO PREVIEW SAVED: ", rc)
	quit(0 if rc == OK else 1)
