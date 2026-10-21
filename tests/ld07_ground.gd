extends "res://tools/ld05/room_probe.gd"
## Roof-independent ground regression. Real key events and physics; fixture poses
## are written only before each case. Item-to-door case has no intermediate warp.
var mode = ""
var room_rows = []

func run():
	await process_frame
	w = load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene = w
	freeze();seed_fixture();automation_hud()
	for roof in [false,true]:
		w.RoomBoundary.ROOF_ENABLED = roof
		mode = "roof-on" if roof else "open-top"
		await inspect_rooms()
		await shelf_seam()
		await plinth_return()
		await sill_controls()
		await pickup_to_exit()
		await restore_save()
	w.RoomBoundary.ROOF_ENABLED = true
	DirAccess.make_dir_recursive_absolute("res://build/ld07")
	var file = FileAccess.open("res://build/ld07/room_inventory.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(room_rows,"  "));file.close()
	release_all();w.queue_free();current_scene = null
	for i in 3: await process_frame
	print("LD07 GROUND: %d checks, %d failure(s)" % [checks,failures])
	quit(1 if failures else 0)

func inspect_rooms():
	var expected = JSON.parse_string(FileAccess.get_file_as_string("res://docs/ld05/base_platforms_49ae3efe.json"))
	for index in 21:
		reset(index)
		var sig = [];var shapes = [];var polygons = []
		for r in w.platforms: sig.append([r.position.x,r.position.y,r.size.x,r.size.y])
		check(JSON.stringify(sig) == JSON.stringify(expected[str(index)]),"%s R%d approved route/platforms retained" % [mode,index])
		for body in w.geometry.get_children():
			if not body is StaticBody2D: continue
			for child in body.get_children():
				if child is CollisionShape2D and child.shape is RectangleShape2D:
					var r = Rect2(child.position - child.shape.size / 2,child.shape.size)
					shapes.append({"rect":[r.position.x,r.position.y,r.size.x,r.size.y],"one_way":child.one_way_collision})
				if child is CollisionPolygon2D:
					var points = []
					for v in child.polygon: points.append([v.x,v.y])
					polygons.append(points)
		check(shapes.size() + polygons.size() >= w.platforms.size(),"%s R%d platform records have runtime collision shapes" % [mode,index])
		var floors = []
		for r in w.platforms:
			if r.position.x >= 0 and r.position.x < w.room_size(index).x and r.size.y == 140:
				floors.append(r)
		floors.sort_custom(func(a,b): return a.position.x < b.position.x)
		var gaps = [];var end = 0.0
		for r in floors:
			if r.position.x > end: gaps.append([end,r.position.x])
			end = maxf(end,r.end.x)
		if end < w.room_size(index).x: gaps.append([end,w.room_size(index).x])
		var intentional = {2:[[640.0,930.0],[1350.0,1680.0],[2200.0,2380.0]],4:[[450.0,1000.0],[1280.0,2050.0]],5:[[500.0,780.0],[1500.0,1850.0]]}
		check(gaps == intentional.get(index,[]),"%s R%d floor has only its intentional pit intervals: %s" % [mode,index,gaps])
		var row = statics(index)
		row["comparison"] = mode;row["floor_gaps"] = gaps;row["runtime_shapes"] = shapes;row["runtime_polygons"] = polygons
		room_rows.append(row)

func shelf_seam():
	# Land over the added R8 extension, stop at the edge, reverse across x=1110.
	await place(8,Vector2(1130,760))
	await wait_ticks(70)
	check(w.player.is_on_floor() and absf(w.player.position.y - 920.0) < 1.5,"%s R8 jump-height drop lands on extension at (1130,920)" % mode)
	key(KEY_A,true);await wait_ticks(25);key(KEY_A,false);await wait_ticks(20)
	check(w.player.is_on_floor() and w.player.position.x < 1110.0 and absf(w.player.position.y - 920.0) < 1.5,"%s R8 stop/reverse crosses the shelf seam without a fall" % mode)
	# A jump with no horizontal input lands over the same repaired seam.
	key(KEY_SPACE,true);await wait_ticks(22);key(KEY_SPACE,false);await wait_ticks(65)
	check(w.player.is_on_floor() and absf(w.player.position.y - 920.0) < 1.5,"%s R8 normal jump returns to the shelf" % mode)

func plinth_return():
	await place(13,Vector2(500,1298))
	key(KEY_A,true);await wait_ticks(80);key(KEY_A,false);await wait_ticks(20)
	check(w.player.is_on_floor() and w.player.position.x >= 373.0 and w.player.position.x <= 376.0,"%s R13 quay blocks entry into the former 60px nook at x=360" % mode)
	key(KEY_D,true);await wait_ticks(12);key(KEY_D,false);await wait_ticks(15)
	check(w.player.position.x > 410.0,"%s R13 reverse away from plinth remains free" % mode)
	key(KEY_SPACE,true);key(KEY_A,true);await wait_ticks(22);key(KEY_SPACE,false)
	var n = w.cinematic_transitions.request_count
	for t in 180:
		await wait_ticks(1)
		if w.cinematic_transitions.request_count > n: break
	release_all();await wait_ticks(90)
	check(w.room == 0 and w.player.is_on_floor(),"%s R13 quay jump over plinth reaches the automatic Canal exit" % mode)

func sill_controls():
	await place(6,Vector2(2320,1108))
	key(KEY_D,true);await wait_ticks(8);key(KEY_D,false);await wait_ticks(18)
	var n = w.cinematic_transitions.request_count
	check(w.room == 6 and w.player.is_on_floor(),"%s R6 stop before sill stays supported" % mode)
	key(KEY_A,true);await wait_ticks(10);key(KEY_A,false);await wait_ticks(12)
	check(w.room == 6 and w.cinematic_transitions.request_count == n,"%s R6 reversal before doorway does not trigger" % mode)
	key(KEY_D,true)
	for t in 200:
		await wait_ticks(1)
		if w.cinematic_transitions.request_count > n: break
	release_all();await wait_ticks(90)
	check(w.room == 7 and w.player.is_on_floor(),"%s R6 resume walks up sill and arrives supported in R7" % mode)

func pickup_to_exit():
	w.player.restore_speed_upgrade(0)
	await place(13,Vector2(330,438))
	key(KEY_D,true)
	for t in 80:
		await wait_ticks(1)
		if w.player.speed_upgrade_level == 1: break
	release_all()
	check(w.player.speed_upgrade_level == 1,"%s Stride I collected by walking at (450,440)" % mode)
	# Descend by walking off exposed shelf edges. No teleport after pickup.
	var target_x = w.player.position.x
	var previous_floor_y = -1.0
	for t in 1800:
		if w.room != 13: break
		if w.player.is_on_floor() and absf(previous_floor_y - w.player.position.y) > 3:
			previous_floor_y = w.player.position.y
			var left = INF;var right = -INF
			for r in w.platforms:
				if absf(r.position.y - w.player.position.y) < 2 and w.player.position.x >= r.position.x - 14 and w.player.position.x <= r.end.x + 14:
					left = minf(left,r.position.x);right = maxf(right,r.end.x)
			if w.player.position.y < 1020:
				target_x = right + 32 if left <= 310 else left - 32
			else:
				target_x = 100
		if w.player.position.y >= 1295 and w.player.position.x < 420 and w.player.is_on_floor():
			key(KEY_SPACE,true)
		else: key(KEY_SPACE,false)
		key(KEY_A,w.player.position.x > target_x);key(KEY_D,w.player.position.x < target_x)
		await wait_ticks(1)
	release_all();await wait_ticks(90)
	print("ITEM_RETURN ",mode," room=",w.room," feet=",w.player.position)
	check(w.room == 0 and w.player.is_on_floor() and w.player.speed_upgrade_level == 1,"%s uninterrupted Stride pickup -> shelf descent -> Canal exit" % mode)

func restore_save():
	await place(13,Vector2(184,1198))
	w.player.restore_speed_upgrade(1)
	w.checkpoint_room = 13;w.checkpoint_position = Vector2(184,1198)
	w.test_mode = false
	check(w.save_progress(),"%s repaired-landing fixture writes disposable save" % mode)
	freeze();w.player.restore_speed_upgrade(0);w.checkpoint_room = 0
	w.load_progress();w.respawn();live();await wait_ticks(25)
	check(w.room == 13 and w.player.is_on_floor() and w.player.speed_upgrade_level == 1 and w.player.double_jump,"%s save reload/respawn retains earned kit on Canal landing" % mode)
	key(KEY_A,true)
	for t in 180:
		await wait_ticks(1)
		if w.room == 0: break
	release_all();await wait_ticks(90)
	check(w.room == 0 and w.player.is_on_floor(),"%s restored Canal landing still exits automatically" % mode)
	w.test_mode = true
