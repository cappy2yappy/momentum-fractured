extends SceneTree
const Demo = preload("res://scripts/gp09/vertical_slice.gd")
var w
var failures = 0
var checks = 0
func _init(): call_deferred("run")
func check(ok, text):
	checks += 1
	if not ok: failures += 1
	print(("PASS " if ok else "FAIL ") + text)
func frames(n):
	for i in n: await physics_frame
func host():
	w = Demo.new()
	root.add_child(w); current_scene = w
	await frames(3)
func drop():
	w.story.panel.close()
	w.queue_free(); current_scene = null
	await frames(3)
func capture(file):
	if DisplayServer.get_name() == "headless": return
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://build/gp09/" + file + ".png")
func run():
	DirAccess.make_dir_recursive_absolute("res://build/gp09")
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--gp09-save="): DirAccess.remove_absolute(arg.trim_prefix("--gp09-save="))
	await host()
	check(w.player.get_script().resource_path == "res://scripts/player.gd","approved player controller instantiated")
	check(w.story.objects.size() == 1 and w.story.rules.size() == 3,"existing StoryDirector loads validated isolated content")
	check(w.story.effect_consumers.spawn_encounter.size() == 1,"one managed enemy consumer registered")
	check(w.story.effect_consumers.arm_hazard.size() == 1,"one HAZ01 consumer registered")
	check(w.enemies.is_empty() and not w.steam.enabled,"no premature encounter or hazard")
	await capture("01_exploration")
	w.player.position = Vector2(850,618)
	await frames(3)
	print("INSPECT DEBUG ",w.player.position," safe=",w.safe_to_leave()," candidate=",w.story.candidate()," transition=",w.transition," hp=",w.player.hp)
	w.interact()
	check(w.story.panel.opened and paused,"existing examination panel owns pause")
	check(w.story.has(w.DISC),"discovery recorded through StoryDirector")
	check(w.enemies.is_empty() and w.presenter.starts == 0,"inspection precedes cinematic and encounter")
	if not w.story.has(w.DISC):
		await drop(); quit(1); return
	var save = JSON.parse_string(FileAccess.get_file_as_string(w.save_path))
	check(save.version == 8 and save.expansion_flags.get(w.DISC,false),"real version8 disk save contains discovery")
	await capture("02_inspection")
	# Close and reload before the optional presentation can consume discovery.
	w.story.panel.close()
	await drop()
	await host()
	check(w.story.has(w.DISC),"discovery survives destruction and actual reload")
	await frames(5)
	check(w.presenter.starts == 1 and not w.player.is_physics_processing(),"reload resumes uncompleted presentation")
	w.story.request_cutin("record_review"); w.story.request_cutin("record_review")
	check(w.presenter.pending.is_empty(),"duplicate active requests cannot enqueue overlapping cinematic")
	await capture("03_cinematic")
	w.presenter.cancel("transition_interrupted")
	w.transition = 0.2
	await frames(3)
	check(not w.story.has(w.PRESENTED) and w.enemies.is_empty(),"interrupted presentation never advances encounter")
	w.transition = 0
	w.player.set_physics_process(true)
	await frames(5)
	check(w.presenter.starts == 2,"interrupted presentation retries after controls restore")
	# Deterministically complete real AnimationPlayer via approved director tick.
	for i in 600: w.story.update(w,1.0/60)
	await frames(5)
	check(w.story.has(w.PRESENTED) and w.player.is_physics_processing(),"cinematic handoff commits completion and restores controller")
	check(w.enemies.size() == 1 and w.consumers.active.size() == 1,"exactly one EN01 encounter dispatched")
	check(w.steam.enabled and w.steam.placement.warning_seconds >= 0.6,"registered HAZ01 vent armed with full warning")
	var starts = w.presenter.starts
	w.story.report("evt/gp09_examined")
	await frames(3)
	check(w.presenter.starts == starts and w.enemies.size() == 1,"repeated discovery cannot repeat completed presentation or enemy")
	var enemy = w.enemies[0]
	enemy.state = "patrol"
	w.transition = 0.3
	enemy.receive_hit(100)
	await frames(3)
	check(not is_instance_valid(enemy),"managed defeated enemy freed during transition")
	check(not w.cleared_encounters.get(w.DEFEATED,false),"enemy persistence waits during transition")
	w.transition = 0
	w.player.set_physics_process(false)
	await frames(3)
	check(not w.cleared_encounters.get(w.DEFEATED,false),"enemy state waits for control ownership")
	w.player.set_physics_process(true)
	await frames(5)
	check(w.cleared_encounters.get(w.DEFEATED,false) and w.story.has("enc/gp09_complete"),"ID-based deferred defeat and story completion flush")
	w.player.hp = 1; w.player.position = Vector2(180,618)
	w.interact()
	check(w.player.hp == 3,"safe shelter restores health outside enemy territory and vent")
	await capture("04_recovery")
	await drop()
	await host()
	await frames(5)
	check(w.story.has(w.DISC) and w.story.has(w.PRESENTED),"both story stages survive disk reload")
	check(w.enemies.is_empty() and w.cleared_encounters.get(w.DEFEATED,false),"defeated managed enemy does not respawn")
	check(w.presenter.starts == 0,"completed cinematic does not replay after reload")
	w.player.position = Vector2(1830,618); w.player.invulnerable = 0
	w.steam.change_phase("active")
	await frames(8)
	check(w.player.hp < 3,"real HAZ01 overlap damages approved controller")
	w.player.position = Vector2(2180,618); w.player.velocity = Vector2.ZERO
	await frames(5)
	w.interact()
	check(w.player.hp == 3,"far recovery area remains available after hazard damage")
	check(w.story.has("evt/gp09_crossed"),"crossing records progression")
	w.player.position = Vector2(2460,618); w.interact()
	check(w.exiting and not w.player.is_physics_processing(),"exit takes a bounded control lease")
	w.story.report("evt/gp09_guard_done")
	check(w.story.pending.size() == 1,"event raised during exit remains queued")
	await frames(40)
	check(w.exited and w.player.is_physics_processing() and w.transition == 0,"exit restores normal movement control")
	check(w.story.pending.is_empty() and w.story.has("evt/gp09_exited"),"exit drains queued event and persists completion")
	var x = w.player.position.x
	Input.action_press("right"); await frames(12); Input.action_release("right")
	check(w.player.position.x > x+20,"approved controller responds to movement after exit")
	await capture("05_exit_control")
	w.player.hp = 0; w.respawn(); await frames(3)
	check(w.player.hp == 3 and w.story.has(w.DISC) and w.enemies.is_empty(),"death recovery preserves discovery and defeated state")
	w.story.set_flag("evt/gp09_extra"); w.story.flush_save()
	save = JSON.parse_string(FileAccess.get_file_as_string(w.save_path))
	check(save.version == 8 and save.cleared_encounters.get(w.DEFEATED,false),"unchanged serializer writes persistent enemy state")
	await drop()
	print("GP09: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
