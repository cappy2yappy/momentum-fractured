extends SceneTree
var failures = 0
var checks = 0
func _init(): call_deferred("run")
func check(ok, label):
	checks += 1
	print("PASS: " if ok else "FAIL: ", label)
	if not ok: failures += 1
func run():
	await process_frame
	for name in ["special_transition", "major_biome", "boss_intro"]:
		var packed = load("res://presets/cutins/" + name + ".tscn")
		var scene = packed.instantiate()
		root.add_child(scene)
		var player = scene.get_node("AnimationPlayer")
		player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
		var anim = player.get_animation("standard")
		check(anim.get_track_count() >= 22, name + ": native camera/character/environment/presentation/audio tracks")
		var marker = anim.find_track(NodePath(".:handoff"), Animation.TYPE_VALUE)
		var event_time = anim.track_get_key_time(marker,1)
		player.play("standard"); player.seek(event_time-.05,true)
		check(not scene.handoff, name + ": scrubbing before marker has no request")
		player.seek(event_time+.01,true)
		check(scene.handoff, name + ": native marker moves with timeline")
		player.seek(.4,true)
		check(scene.get_node("Framing/Shake/Character").texture != null, name + ": existing registered Kaze sprite strip")
		player.play("reduced"); player.seek(.2,true)
		check(scene.get_node("Framing").scale == Vector2.ONE and scene.get_node("Framing").position == Vector2.ZERO and scene.shake_strength == 0, name + ": reduced preview removes spatial movement")
		# A real save/reload of an edited native timeline, independent of runtime.
		anim = anim.duplicate(true)
		anim.track_set_key_time(marker,1,event_time-.2)
		var lib = player.get_animation_library("").duplicate(true)
		lib.remove_animation("standard"); lib.add_animation("standard",anim)
		player.remove_animation_library(""); player.add_animation_library("",lib)
		player.stop()
		var saved = PackedScene.new()
		check(saved.pack(scene) == OK and ResourceSaver.save(saved,"/tmp/cin-tools-"+name+".tscn") == OK, name + ": edited timing persists as native scene")
		var loaded = load("/tmp/cin-tools-"+name+".tscn").instantiate()
		check(is_equal_approx(loaded.get_node("AnimationPlayer").get_animation("standard").track_get_key_time(marker,1),event_time-.2), name + ": saved timing reloads")
		loaded.free()
		var missing = packed.instantiate()
		missing.get_node("Framing/Shake/Character").texture = null
		root.add_child(missing)
		var missing_player = missing.get_node("AnimationPlayer")
		missing_player.play("standard"); missing_player.seek(.3,true)
		check("MISSING CLIP" in missing.artwork_status and missing.get_node("Framing/Shake/Character").texture != null, name + ": missing clip is a labelled approved-art stand-in")
		missing.queue_free(); scene.queue_free()
		await process_frame
	var preview = load("res://tools/cin_tools_01/preview.tscn").instantiate()
	root.add_child(preview)
	preview.scrub(.5); preview.step()
	check(is_equal_approx(preview.slider.value,.5+1.0/60), "Preview scrubs and steps at 60 Hz")
	preview.play(); preview._process(.1); preview.pause()
	check(not preview.running and preview.slider.value > .6, "Preview normal-speed play/pause works")
	preview.reduced_preview = true; preview.restart()
	check(preview.animation.current_animation == "reduced" and is_equal_approx(preview.slider.max_value,.4), "Preview reduced toggle changes animation")
	preview.queue_free()
	for i in 3: await process_frame
	print("CIN-TOOLS-01 AUTHORING: %d checks, %d failure(s)" % [checks,failures])
	quit(1 if failures else 0)
