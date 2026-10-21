extends "res://tests/automatic_passage_reliability.gd"
## Run only against pinned pre-repair 49ae3efe. PASS here means the documented
## defect was reproduced, not that this old runtime is correct.
func pose(index,at):
	for code in [KEY_A,KEY_D,KEY_SPACE,KEY_SHIFT,KEY_E]: key(code,false)
	reset(index);w.player.position = at;w.player.velocity = Vector2.ZERO
	w.player.run = false;w.player.last_tap = -10
	live();await wait_ticks(4)

func run():
	await process_frame
	w = load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene = w
	freeze();seed_fixture();automation_hud()
	await pose(6,Vector2(2250,1108))
	var n = w.cinematic_transitions.request_count
	key(KEY_D,true);await wait_ticks(240);key(KEY_D,false)
	print("BEFORE R6 feet=",w.player.position," requests=",w.cinematic_transitions.request_count - n)
	check(w.room == 6 and w.cinematic_transitions.request_count == n and w.player.position.x > 2500,"BEFORE DEFECT R6 walking reaches boundary without opening R7")
	await pose(8,Vector2(1130,760));await wait_ticks(90)
	print("BEFORE R8 feet=",w.player.position)
	check(w.player.position.y > 922,"BEFORE DEFECT R8 drop at x1130 falls past the unsupported door landing y920")
	await pose(13,Vector2(500,1298))
	key(KEY_A,true);await wait_ticks(100);key(KEY_A,false)
	print("BEFORE R13 feet=",w.player.position)
	check(w.room == 13 and w.player.is_on_floor() and w.player.position.x < 300 and absf(w.player.position.y - 1300) < 2,"BEFORE DEFECT R13 walking enters the 60px under-pad nook")
	w.queue_free();current_scene = null
	for i in 3: await process_frame
	print("LD07 BEFORE REPRODUCTION: %d checks, %d failure(s)" % [checks,failures])
	quit(1 if failures else 0)
