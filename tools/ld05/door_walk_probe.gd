extends "res://tools/ld05/room_probe.gd"
## LD-05 door walk probe: for every horizontal_walk endpoint, stand 220 px before the door on its support and hold the key
## toward it with real input. Records whether the passage fires, how long it takes, and the feet y at the trigger.
##   godot --headless --path . --fixed-fps 60 --script res://tools/ld05/door_walk_probe.gd -- --out=res://build/ld05/door_walk.json
func run():
	args()
	await process_frame
	w = load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene = w;freeze();seed_fixture()
	automation_hud()
	var rows = []
	for index in 21:
		reset(index)
		for p in w.cinematic_transitions.endpoints(w,index):
			reset(index)
			var dir = int(p.heading)
			# the walkable top under the door span
			var top = null;var support = Rect2()
			for r in w.platforms + (w.boundary_rects if "boundary_rects" in w else []):
				if r.position.x < 0 or r.position.x >= w.room_size(index).x or r.position.y < 0: continue
				if p.at.x >= r.position.x and p.at.x <= r.end.x and absf(r.position.y - p.at.y) <= 40:
					if top == null or r.position.y < top: top = r.position.y;support = r
			var feet = top if top != null else p.at.y
			var sx = clampf(p.at.x - dir * 220.0,support.position.x + 20,support.end.x - 20) if top != null else p.at.x - dir * 220.0
			var start = Vector2(sx,feet - 2)
			await place(index,start)
			var before = w.cinematic_transitions.request_count
			var walk = p.mode == "horizontal_walk"
			var fired = -1;var peak_y = feet
			if walk:
				key(KEY_D if dir > 0 else KEY_A,true)
			else:
				# depth door / wind fold: stand on the support under the door and press E
				await place(index,Vector2(p.at.x,feet - 2))
				before = w.cinematic_transitions.request_count
				key(KEY_E,true);await wait_ticks(3);key(KEY_E,false)
			for t in 240:
				await wait_ticks(1)
				if w.room != index or w.transition > 0 or w.pending_room >= 0: fired = t;break
				peak_y = minf(peak_y,w.player.position.y)
			var at_x = w.player.position.x;var at_y = w.player.position.y
			key(KEY_D,false);key(KEY_A,false)
			var arrived = {}
			if fired >= 0:
				for t in 200:
					await wait_ticks(1)
					if w.room == p.target and w.transition <= 0 and not w.cinematic_transitions.active: break
				await wait_ticks(60)
				var pos = w.player.position
				var cap = Rect2(pos - Vector2(14,60),Vector2(28,60))
				var inside = false
				for r in w.platforms + (w.boundary_rects if "boundary_rects" in w else []):
					if r.intersects(cap): inside = true
				arrived = {"room":w.room,"pos":[snappedf(pos.x,0.1),snappedf(pos.y,0.1)],"on_floor":w.player.is_on_floor(),"inside_solid":inside,"hp":w.player.hp}
			rows.append({"room":index,"target":p.target,"mode":p.mode,"at":[p.at.x,p.at.y],"support_top":top,"offset":(top - p.at.y) if top != null else null,"fired_tick":fired,"player_end":[snappedf(at_x,0.1),snappedf(at_y,0.1)],"arrival":arrived})
			print("DOORWALK R",index,"->R",p.target," ",p.mode," top=",top," at.y=",p.at.y," fired=",fired," arrival=",arrived)
			await wait_ticks(20)
	DirAccess.make_dir_recursive_absolute(out_path.get_base_dir())
	var f = FileAccess.open(out_path,FileAccess.WRITE);f.store_string(JSON.stringify(rows,"  "));f.close()
	w.queue_free();current_scene = null
	for i in 3: await process_frame
	quit(0)
