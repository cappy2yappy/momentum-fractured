extends SceneTree
## Run with -- --test. Snapshot actual post-TR04 geometry, not a second generator.
func _init():
	call_deferred("run")

func run():
	if not "--test" in OS.get_cmdline_user_args():
		push_error("Use -- --test to prevent reading personal saves")
		quit(1)
		return
	var w = load("res://scenes/main.tscn").instantiate()
	root.add_child(w)
	w.set_physics_process(false)
	w.player.set_physics_process(false)
	w.build_room(18)
	var rows = []
	for r in w.platforms:
		var matches = []
		for b in w.geometry.get_children():
			if b is StaticBody2D:
				for c in b.get_children():
					if c is CollisionShape2D and c.shape is RectangleShape2D and c.position == r.get_center() and c.shape.size == r.size:
						matches.append({"rect":[r.position.x,r.position.y,r.size.x,r.size.y], "one_way":c.one_way_collision,"margin":c.one_way_collision_margin,"layer":b.collision_layer,"mask":b.collision_mask})
		assert(matches.size() == 1, "Each platform must have exactly one native collider")
		rows.append(matches[0])
	var data = {"baseline":"5dfc4c4f077c5408ecbe49f1cafafea1dcb1003c", "room":18,"bounds":[2600,1440],"shapes":rows,"excluded":"Gate, enemies, hazards, anchors, exits and progression remain owned by existing world code."}
	var f = FileAccess.open("res://tools/ld_tools_01/r18_frozen.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(data,"\t")+"\n")
	f.close()
	print("R18 frozen: ", rows.size(), " exact platform/wall/floor colliders")
	w.queue_free()
	await process_frame
	quit()
