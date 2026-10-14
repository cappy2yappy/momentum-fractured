extends SceneTree
var failures = 0
var w
var a
func _init(): call_deferred("run")
func check(ok, message):
	print("PASS: " if ok else "FAIL: ", message)
	if not ok: failures += 1
func count(cue): return int(a.counts.get(cue, 0))
func reset_audio():
	a.clock += 1
	for voice in a.voices: voice.stop()
func freeze():
	w.set_physics_process(false)
	w.player.set_physics_process(false)
	for enemy in w.enemies: enemy.set_physics_process(false)
func run():
	await process_frame
	w = load("res://scenes/main.tscn").instantiate()
	root.add_child(w); current_scene = w
	a = w.audio
	freeze()
	for bus in ["Music", "SFX", "Ambience", "UI"]:
		var index = AudioServer.get_bus_index(bus)
		check(index > 0 and AudioServer.get_bus_send(index) == "Master", bus + " routes to Master")
	check(AudioServer.get_bus_effect(0, 0) is AudioEffectLimiter and AudioServer.is_bus_effect_enabled(0, 0), "Master limiter loaded and enabled")
	for cue in a.CUES:
		check(a.streams[cue] is AudioStreamWAV and a.streams[cue].get_length() > 0 and a.streams[cue].format == AudioStreamWAV.FORMAT_16_BITS, cue + " imports as nonempty PCM16")
	for cue in ["amb_city", "amb_canal"]:
		check(a.streams[cue].loop_mode == AudioStreamWAV.LOOP_FORWARD and a.streams[cue].loop_end == 176400 and is_equal_approx(a.streams[cue].get_length(), 8), cue + " loops exactly eight seconds")
	check(a.voices.size() == 12 and a.ambience.size() == 2 and a.music.size() == 2, "Fixed player budget: 12 effects, two ambience, two music")
	check(not a.music[0].playing and not a.music[1].playing, "Music slot starts silent")
	check(not a.play("missing"), "Unknown cues fail quietly")
	reset_audio()
	var before = count("dash")
	w.player.dash_unlocked = false; w.player.press("dash")
	check(count("dash") == before, "Locked dash makes no success sound")
	w.player.dash_unlocked = true; w.player.dash_cooldown = 0; w.player.attack_time = 0
	w.player.press("dash"); w.player.press("dash")
	check(count("dash") == before + 1, "Successful dash sounds once; cooldown rejection stays silent")
	reset_audio(); w.player.dash_time = 0
	before = count("swing"); w.player.start_attack(0)
	check(count("swing") == before + 1, "Actual melee start emits swing")
	reset_audio(); w.build_room(1); freeze()
	w.player.position = Vector2(1030, 1300); w.player.facing = 1
	before = count("contact"); w.on_strike(1, 95)
	check(count("contact") == before + 1, "Confirmed melee contact emits hit cue")
	reset_audio(); w.player.position.x = 50; before = count("contact"); w.on_strike(1, 95)
	check(count("contact") == before, "Melee miss has no false hit confirmation")
	reset_audio(); w.player.position = Vector2(1030, 1300)
	w.player.hp = 3; w.player.parry_time = .2; w.guard.state = "strike"; w.guard.strike_done = false; w.guard.timer = .16
	before = count("parry"); w.guard._physics_process(.01)
	check(count("parry") == before + 1 and w.player.hp == 3, "Guard successful parry emits cue without damage")
	reset_audio(); w.build_room(12); freeze()
	w.player.position = Vector2(1120, 1300); w.player.facing = 1; w.player.parry_time = .2
	before = count("parry"); w.active_enemy.begin_attack("sweep"); w.active_enemy.resolve_attack()
	check(count("parry") == before + 1, "Storm Keeper success uses same parry interface")
	reset_audio(); w.player.invulnerable = 0; w.player.hp = 3
	before = count("damage"); w.player.damage(Vector2.ZERO); w.player.damage(Vector2.ZERO)
	check(count("damage") == before + 1 and w.player.hp == 2, "Damage cue only for accepted hit; invulnerability suppresses repeats")
	reset_audio(); w.player.invulnerable = 0; w.player.hp = 1
	before = count("death"); w.player.damage(Vector2.ZERO)
	check(count("death") == before + 1, "Lethal damage emits death")
	await process_frame; freeze()
	reset_audio(); w.build_room(4); freeze()
	w.player.position = Vector2(1190, 900); w.player.velocity = Vector2(300, 80); w.player.grapple_clearance_check = false
	w.player.hitstop = 0; w.player.attack_time = 0; w.player.dash_time = 0; w.player.touch.clear()
	w.player.set_physics_process(true)
	for tick in 2: await physics_frame
	w.player.set_physics_process(false)
	before = count("tether_attach"); var accepted = w.player.apply_tether(w.tether_anchors[1])
	check(accepted and count("tether_attach") == before + 1, "Accepted tether emits attach")
	var velocity = w.player.velocity; before = count("tether_release")
	w.player.release_tether(); w.player.release_tether()
	check(count("tether_release") == before + 1 and w.player.velocity == velocity, "Release cue once; exact release velocity preserved")
	reset_audio(); w.player.tether_unlocked = true
	before = count("tether_fire"); w.on_tether_requested()
	check(count("tether_fire") == before + 1, "Successful world tether hook fires line cue")
	reset_audio(); w.player.release_tether(); w.player.position = Vector2(20, 1300)
	before = count("reject"); w.on_tether_requested()
	check(count("reject") == before + 1, "No-anchor attempt emits quiet rejection")
	for element in ["wind", "fire", "electric"]:
		reset_audio(); w.build_room(2); freeze()
		w.create_kunai_gate("audio_" + element, element, Vector2(500, 500), 100)
		w.player.kunai_cooldown = 0; w.player.kunai_unlocked[element] = true; w.player.selected_kunai = element
		before = count("kunai_throw"); w.player.press("kunai")
		check(count("kunai_throw") == before + 1, element + " successful throw emits common cue")
		var projectile = w.Kunai.new(); projectile.element = element; projectile.position = Vector2(500, 450)
		before = count("impact_" + element); var collided = w.resolve_kunai(projectile)
		check(collided and count("impact_" + element) == before + 1, element + " real seal contact emits distinct impact")
		projectile.free()
	reset_audio(); w.build_room(1); freeze(); w.player.double_jump = false; w.transition = 0
	before = count("room_passage"); w.request_room(2)
	check(count("room_passage") == before and w.transition == 0, "Locked room emits no passage cue")
	w.player.double_jump = true; w.request_room(2); w.request_room(2)
	check(count("room_passage") == before + 1 and w.transition > 0, "Accepted passage sounds once during repeated requests")
	w.transition = 0; w.pending_room = -1
	for room in [0, 3, 8, 11, 12, 16]:
		reset_audio(); w.build_room(room); freeze(); w.cleared_encounters["storm_keeper"] = true
		var positions = {0:Vector2(220,1300),3:Vector2(1320,1300),8:Vector2(2060,1300),11:Vector2(1720,1300),12:Vector2(2220,1300),16:Vector2(420,1120)}
		w.player.position = positions[room]; before = count("checkpoint"); w.interact()
		check(count("checkpoint") == before + 1, "R%d shrine interaction emits checkpoint" % room)
	reset_audio(); before = count("checkpoint"); w.save_progress()
	check(count("checkpoint") == before, "Automatic persistence has no checkpoint chime")
	a.enter_room(14); await create_timer(.5).timeout
	check(a.profile == "amb_city" and a.ambience[a.ambience_slot].playing and not a.ambience[1-a.ambience_slot].playing, "City profile crossfade completes with one loop")
	var slot = a.ambience_slot; a.enter_room(14)
	check(a.ambience_slot == slot, "Same biome entry does not restart ambience")
	a.enter_room(15); a.enter_room(14); a.enter_room(15); await create_timer(.5).timeout
	check(a.profile == "amb_canal" and a.ambience[a.ambience_slot].playing and not a.ambience[1-a.ambience_slot].playing, "Rapid profile changes leave one canal loop")
	reset_audio(); a.play("dash"); paused = true; await process_frame
	check(a.active_voice_count() == 0 and a.ambience[a.ambience_slot].stream_paused and not a.play("damage"), "Pause stops effects, pauses ambience and blocks gameplay playback")
	paused = false; await process_frame
	check(not a.ambience[a.ambience_slot].stream_paused, "Unpause resumes ambient bed")
	a.set_music(a.streams["amb_city"]); await create_timer(.7).timeout
	check(a.music[a.music_slot].playing, "Music handoff accepts stream (test-only ambience fixture)")
	a.set_music(null); await create_timer(.7).timeout
	check(not a.music[0].playing and not a.music[1].playing, "Music null handoff fades back to silence")
	a.set_volume("SFX", 0); check(AudioServer.is_bus_mute(AudioServer.get_bus_index("SFX")), "Independent SFX zero volume mutes bus")
	a.set_volume("SFX", 1); check(not AudioServer.is_bus_mute(AudioServer.get_bus_index("SFX")), "Independent SFX volume restores bus")
	reset_audio()
	for cue in ["step_stone", "step_wood", "jump", "land", "dash", "swing", "contact", "kunai_throw", "impact_fire", "impact_wind"]: a.play(cue)
	check(a.active_voice_count() <= 8 and a.dropped > 0, "Ordinary pool caps at eight and drops overload")
	check(a.play("damage") and a.play("parry") and a.active_voice_count() <= 12, "Critical reserve remains available under ordinary overload")
	reset_audio(); before = count("dash"); a.play("dash"); a.play("dash")
	check(count("dash") == before + 1, "Rate limit prevents duplicate same-tick cue")
	# Real grounded movement/jump/landing; isolate from enemies and transitions.
	w.build_room(0); freeze(); w.player.position = Vector2(220,1298); w.player.velocity = Vector2.ZERO
	w.player.dash_time = 0; w.player.attack_time = 0; w.player.hitstop = 0; w.player.touch.clear()
	w.player.set_physics_process(true)
	for tick in 8: await physics_frame
	reset_audio(); before = count("step_stone"); w.player.touch["right"] = true
	for tick in 30: await physics_frame
	w.player.touch.clear()
	check(count("step_stone") > before and count("step_stone") - before <= 3, "Real resolved walking produces sparse distance-based footfalls")
	reset_audio(); before = count("jump"); w.player.touch["jump"] = true; w.player.press("jump")
	for tick in 3: await physics_frame
	check(count("jump") == before + 1, "Real grounded jump produces accepted-jump cue")
	var steps = count("step_stone"); w.player.touch.clear(); before = count("land")
	for tick in 75: await physics_frame
	check(count("land") > before, "Real airborne-to-ground transition produces landing")
	check(count("step_stone") == steps, "Idle and airborne movement do not create footfalls")
	w.queue_free(); current_scene = null
	for tick in 3: await process_frame
	print("AUDIO FOUNDATION: %d failure(s)" % failures)
	quit(1 if failures else 0)
