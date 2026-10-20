extends SceneTree
## Freezes the LD-05 additions per room from the actual runtime builder, in the schema PR #49 used for
## tools/ld_tools_01/r18_frozen.json (rect, layer, mask, one_way, margin), plus a role. Read-only use of PR #49's idea;
## nothing from that branch is imported.
## godot --headless --path . --script res://tools/ld05/freeze_additions.gd -- res://docs/ld05/ld05_frozen_shapes.json
func _init(): call_deferred("run")
func role_of(w, r:Rect2) -> String:
	if r.position.y < 0: return "roof_course_with_offscreen_backing (visible band y 0..56)"
	if w.room == 13 and r == Rect2(0,1240,360,60): return "quay_footing_under_hallway_pad"
	if w.room == 8: return "door_shelf_seat_extension (continues shelf 770,920,340,40)"
	return "unknown"
func run():
	await process_frame
	var out = OS.get_cmdline_user_args()[0]
	var w = load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene = w
	w.set_physics_process(false);w.player.set_physics_process(false)
	var rooms = []
	for index in 21:
		w.build_room(index)
		var shapes = []
		for r in w.boundary_rects:
			var body = null
			for b in w.geometry.get_children():
				if b is StaticBody2D and b.get_child_count() == 1 and b.get_child(0) is CollisionShape2D:
					var s = b.get_child(0)
					if s.shape is RectangleShape2D and s.position == r.get_center() and s.shape.size == r.size: body = b;break
			shapes.append({"rect":[r.position.x,r.position.y,r.size.x,r.size.y],"layer":body.collision_layer if body else -1,"mask":body.collision_mask if body else -1,"one_way":false,"margin":1.0,"role":role_of(w,r)})
		rooms.append({"room":index,"bounds":[w.room_size(index).x,w.room_size(index).y],"added_shapes":shapes})
	var doc = {"baseline":"49ae3efe21dea6a9eba556ce2fbc8299b00412b9","schema":"PR49 r18_frozen.json (rect, layer, mask, one_way, margin) + role","excluded":"platforms, gates, enemies, anchors, exits and progression remain owned by existing world code and are unchanged","rooms":rooms}
	var f = FileAccess.open(out,FileAccess.WRITE);f.store_string(JSON.stringify(doc,"\t"));f.close()
	print("FROZEN rooms=",rooms.size())
	quit(0)
