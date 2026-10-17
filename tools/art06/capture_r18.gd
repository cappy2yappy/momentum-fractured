extends SceneTree
## ART-06 evidence: real Godot 4.6.1 render of R18 Pump Gallery plus a JSON dump
## of every collider, anchor, gate, hazard and portal the runtime actually builds.
## Read-only: never edits geometry. Usage:
##   godot --path . --script res://tools/art06/capture_r18.gd -- --test [--overlay=res://...tscn]
const ROOM := 18
var out := "res://build/art06/native"

func _init(): call_deferred("run")

func shot(path: String):
	for i in 3: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(path)
	print("SHOT ", path)

func run():
	DirAccess.make_dir_recursive_absolute(out)
	var w = load("res://scenes/main.tscn").instantiate()
	root.add_child(w); current_scene = w
	await process_frame
	w.build_room(ROOM)
	await process_frame
	var overlay_path := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--overlay="): overlay_path = a.substr(10)
	var tag := "before"
	if overlay_path != "":
		var ov = load(overlay_path).instantiate()
		w.add_child(ov); tag = "after"
		if ov.has_method("attach"): ov.attach(w)
	# Collider dump straight from the instantiated physics bodies.
	var bodies := []
	for body in w.geometry.get_children():
		if body is StaticBody2D:
			for s in body.get_children():
				if s is CollisionShape2D and s.shape is RectangleShape2D:
					var r := Rect2(body.position + s.position - s.shape.size / 2.0, s.shape.size)
					bodies.append({"x":r.position.x,"y":r.position.y,"w":r.size.x,"h":r.size.y,"one_way":s.one_way_collision,"disabled":s.disabled})
	var anchors := []
	for a in w.grapple_candidates(): anchors.append([a.x, a.y])
	for n in w.geometry.get_children():
		if n.is_in_group("kaze_grapple_anchor"): anchors.append([n.position.x, n.position.y])
	var dump := {
		"engine": Engine.get_version_info().string, "room": ROOM,
		"name": w.ROOM_NAMES[ROOM], "size": [w.room_size(ROOM).x, w.room_size(ROOM).y],
		"bodies": bodies, "anchors": anchors,
		"gates": w.kunai_gates.map(func(g): return {"id":g.id,"element":g.element,"x":g.position.x,"y":g.position.y,"h":g.height}),
		"hazards": w.expansion.hazards.map(func(h): return [h.position.x,h.position.y,h.size.x,h.size.y]),
		"route_steps": w.expansion.route_steps.map(func(h): return [h.position.x,h.position.y,h.size.x,h.size.y]),
		"portals": w.expansion.portals(ROOM).map(func(p): return {"at":[p.at.x,p.at.y],"target":p.target,"need":p.need}),
		"lore": [w.expansion.LORE[ROOM].x, w.expansion.LORE[ROOM].y],
		"enemies": w.enemies.map(func(e): return [e.position.x, e.position.y]),
		"platform_signature": JSON.stringify(w.platforms),
	}
	if tag == "before":
		var f = FileAccess.open(out + "/r18_geometry.json", FileAccess.WRITE); f.store_string(JSON.stringify(dump, "  ")); f.close()
	else:
		var base = JSON.parse_string(FileAccess.get_file_as_string(out + "/r18_geometry.json"))
		print("SIGNATURE_MATCH ", base.platform_signature == dump.platform_signature, " BODIES ", base.bodies.size(), "->", bodies.size())
	# Freeze simulation so frames are deterministic stills.
	w.player.set_physics_process(false); w.player.set_process(false)
	for e in w.enemies: e.set_physics_process(false)
	w.message_time = 0.0
	# Gameplay-scale (zoom 1.0) samples at the room's meaningful positions.
	var views := {"west_arrival":Vector2(260,1000),"guard_shelf":Vector2(950,800),"lower_bay":Vector2(1200,1180),"lore_shelf":Vector2(1600,620),"east_gate":Vector2(2250,760)}
	for k in views:
		w.player.position = views[k]; w.camera.reset_smoothing(); w.camera.force_update_scroll()
		w.queue_redraw()
		await shot(out + "/r18_%s_%s.png" % [tag, k])
	# Whole-room overview, no HUD.
	for c in w.get_children():
		if c is CanvasLayer: c.visible = false
	w.camera.zoom = Vector2.ONE * (1280.0 / 2600.0)
	w.camera.position = Vector2.ZERO
	w.player.position = Vector2(1300, 720 + 110)
	w.camera.limit_left = -10000; w.camera.limit_right = 10000; w.camera.limit_top = -10000; w.camera.limit_bottom = 10000
	w.camera.reset_smoothing(); w.camera.force_update_scroll()
	w.queue_redraw()
	await shot(out + "/r18_%s_overview.png" % tag)
	quit(0)
