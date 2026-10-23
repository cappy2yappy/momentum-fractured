extends "res://tests/tr08_canal_hang_probe.gd"
## Guards the harness correction: incidental notifications must not undo or replace
## deliberate production pause behavior. No processing writes during approaches.
func run():
	await process_frame
	await load_fixture()
	check(not paused and w.hud.has_method("simulated_notification"), "New fixture starts with isolated automation HUD and unpaused tree")
	var original = FileAccess.get_file_as_string("res://scripts/hud.gd")
	check(w.hud.get_script().source_code == original.replace("func _notification(what):", "func simulated_notification(what):"), "Automation retains exact current production HUD body with only notification callback renamed")
	key(KEY_A,true)
	w.hud.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	await wait_ticks(12)
	check(not paused and w.player.age > 0 and w.player.position.x < 330 and w.player.is_on_floor(), "Incidental focus notification leaves real-key player physics running")
	check(w.cinematic_transitions.armed.get(0,false), "Live fixture establishes support and arms doorway")
	w.hud.simulated_notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	var age = w.player.age
	await wait_ticks(12)
	check(paused and w.hud.pause_open and not w.player.can_process() and w.player.age == age, "Deliberate focus test still pauses through exact production handler")
	w.hud.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(paused and w.hud.pause_open, "Incidental focus cannot clear a deliberate pause")
	key(KEY_ESCAPE,true); await process_frame; key(KEY_ESCAPE,false)
	await wait_ticks(2)
	check(not paused and w.player.age > age, "Existing Esc input resumes deliberate focus pause")
	key(KEY_M,true); await process_frame; key(KEY_M,false)
	w.hud.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(paused and w.hud.map_open and not w.hud.pause_open, "Incidental focus preserves deliberate map pause and HUD state")
	await load_fixture()
	check(not paused and not w.hud.map_open and not w.hud.pause_open, "New-world boundary clears only discarded fixture pause state")
	# Positive control: normal game HUD behavior remains unchanged.
	w.hud.set_script(load("res://scripts/hud.gd")); w.hud.world = w
	w.hud.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(paused and w.hud.pause_open and not w.player.can_process(), "Unchanged production HUD still auto-pauses normal gameplay")
	key(KEY_ESCAPE,true); await process_frame; key(KEY_ESCAPE,false)
	check(not paused, "Production HUD resumes through its normal Esc action")
	key(KEY_A,false)
	w.queue_free(); current_scene = null
	for i in 3: await process_frame
	print("QA10 AUTOMATION: %d checks, %d failure(s)" % [checks, failures])
	quit(1 if failures else 0)
