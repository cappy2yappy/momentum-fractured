extends "res://tests/automatic_passage_reliability.gd"
## LEVEL pilot, report only. For every endpoint: door visual vs trigger vs support vs wall, and a real-key
## wall-jump probe beside each wall-side walk-through exit. Writes build/canal/exit_audit.json.
var rows = []

func probe_climb(index, at:Vector2, toward):
	for code in [KEY_A,KEY_D,KEY_SPACE,KEY_SHIFT,KEY_E]: key(code,false)
	reset(index)
	var size = w.room_size(index)
	var x = 14.6 if toward < 0 else size.x - 14.6
	w.player.position = Vector2(x,at.y - 2);w.player.velocity = Vector2.ZERO
	live();await wait_ticks(4)
	var kt = KEY_A if toward < 0 else KEY_D
	key(kt,true)
	var release = 0;var nextjump = 0;var miny = w.player.position.y;var escaped = false
	for t in 360:
		if (w.player.is_on_wall() or w.player.is_on_floor()) and not held_keys.get(KEY_SPACE,false) and t >= nextjump:
			key(KEY_SPACE,true);release = t + 25;nextjump = t + 30
		if held_keys.get(KEY_SPACE,false) and t >= release: key(KEY_SPACE,false)
		await wait_ticks(1)
		if w.room != index or w.transition > 0: break
		miny = minf(miny,w.player.position.y)
		if w.player.position.x < -20 or w.player.position.x > size.x + 20: escaped = true
	for code in [kt,KEY_SPACE]: key(code,false)
	return {"miny":miny,"escaped":escaped,"left_room":w.room != index}

func analyse(index, p):
	var size = w.room_size(index)
	var heading = int(p.heading)
	var row = {"room":index,"target":p.target,"at":[p.at.x,p.at.y],"mode":p.mode}
	var platforms = w.platforms
	var support_ok = false;var support_to_wall = false;var support_rect = Rect2()
	for r in platforms:
		if r.position.x < 0 or r.position.x >= size.x: continue
		if absf(r.position.y - p.at.y) <= 20 and p.at.x >= r.position.x and p.at.x <= r.end.x:
			support_ok = absf(r.position.y - p.at.y) <= 2 and p.at.x - 48 >= r.position.x and p.at.x + 48 <= r.end.x
			support_rect = r
			support_to_wall = r.position.x <= 0 or r.end.x >= size.x
			break
	row.support = [support_rect.position.x,support_rect.position.y,support_rect.size.x,support_rect.size.y]
	row.door_span_supported = support_ok
	row.support_reaches_wall = support_to_wall
	row.support_top_offset = support_rect.position.y - p.at.y if support_rect.size.y > 0 else null
	# Dead space between the drawn door edge and the wall, where Kaze can stand after the door.
	var wall_side = p.at.x <= 160 or p.at.x >= size.x - 160
	row.wall_side = wall_side
	if wall_side:
		var wall_x = 14.0 if heading < 0 else size.x - 14.0
		row.dead_space_past_door_px = absf(wall_x - (p.at.x + heading * 48))
		row.trigger_to_wall_px = absf(wall_x - p.at.x)
	# Solid (non one-way) headroom above the door aperture.
	var head = 100000.0
	for r in platforms:
		if r.position.x < 0 or r.position.x >= size.x: continue
		if r.size.y == 40: continue # one-way ledges never block a jump
		if r.end.x > p.at.x - 48 and r.position.x < p.at.x + 48 and r.end.y <= p.at.y: head = minf(head,p.at.y - r.end.y)
	row.solid_headroom = head if head < 100000.0 else null
	row.enclosed_above = head < 100000.0
	row.trigger_x = p.at.x if p.mode == "horizontal_walk" else null
	row.interact_radius = null if p.mode == "horizontal_walk" else 85
	rows.append(row)
	return row

func run():
	await process_frame
	w = load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene = w;freeze();seed_fixture()
	automation_hud()
	var c = w.cinematic_transitions
	for index in 21:
		reset(index)
		for p in c.endpoints(w,index):
			var row = analyse(index,p)
			if p.mode == "horizontal_walk" and row.wall_side:
				var toward = p.heading
				var r = await probe_climb(index,p.at,toward)
				row.wall_jump_min_feet_y = r.miny;row.wall_jump_escaped_room = r.escaped
				reset(index)
	var file = FileAccess.open("res://build/canal/exit_audit.json",FileAccess.WRITE);file.store_string(JSON.stringify(rows,"  "));file.close()
	print("EXIT_AUDIT rows=",rows.size())
	w.queue_free();current_scene = null
	for i in 3: await process_frame
	quit(0)
