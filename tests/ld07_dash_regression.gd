extends "res://tools/ld05/room_probe.gd"
## Known GN-06 reproducer for PM/Transition. Expected RED on the recovered runtime.
## Keep separate from green ground geometry checks; do not waive its failed result.
func run():
	await process_frame
	w = load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene = w
	freeze();seed_fixture();automation_hud()
	await place(6,Vector2(2300,1108))
	var n = w.cinematic_transitions.request_count
	key(KEY_D,true);await wait_ticks(8)
	key(KEY_SHIFT,true);await wait_ticks(1);key(KEY_SHIFT,false)
	for t in 240:
		await wait_ticks(1)
		if w.cinematic_transitions.request_count > n: break
	release_all()
	print("GN06 room=",w.room," feet=",w.player.position," requests=",w.cinematic_transitions.request_count - n)
	check(w.cinematic_transitions.request_count == n + 1,"GN-06 dash across R6 sill should request R7 automatically")
	# Recover through ordinary input so the report distinguishes a missed trigger from a trap.
	key(KEY_A,true);await wait_ticks(40);key(KEY_A,false);await wait_ticks(12)
	key(KEY_D,true)
	for t in 180:
		await wait_ticks(1)
		if w.room == 7: break
	release_all();await wait_ticks(90)
	check(w.room == 7 and w.player.is_on_floor(),"GN-06 walking back inward then approaching recovers the exit")
	w.queue_free();current_scene = null
	for i in 3: await process_frame
	print("LD07 KNOWN DASH REGRESSION: %d checks, %d failure(s)" % [checks,failures])
	quit(1 if failures else 0)
