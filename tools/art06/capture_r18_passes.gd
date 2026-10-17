extends SceneTree
## ART-06 native render passes of R18 for registered mockup compositing.
## For each view: plate (room as rendered, actors+HUD hidden, legacy pump circles
## suppressed through the existing production_art hook), actors (Kaze + enemies on
## transparent), hud (on transparent). Read-only: geometry signature is checked.
const ROOM := 18
const Suppress = preload("res://tools/art06/suppress_r18_legacy.gd")
var out := "res://build/art06/passes"

func _init(): call_deferred("run")

func grab(path: String):
	for i in 3: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(path)

var saved := {}
func set_markers(w, on: bool):
	if not on:
		saved = {"hazards": w.expansion.hazards.duplicate(), "gates": w.opened_kunai_gates.duplicate(), "lore": w.expansion_flags.duplicate(), "anchors": w.tether_anchors.duplicate()}
		w.expansion.hazards.clear()
		for g in w.kunai_gates: w.opened_kunai_gates[g.id] = true
		w.expansion_flags["lore_%d" % ROOM] = true
		w.tether_anchors.clear()
		for n in get_nodes_in_group("kaze_grapple_anchor"): n.remove_from_group("kaze_grapple_anchor"); n.set_meta("art06_hidden", true)
		w.expansion.hide_portals = true
	else:
		w.expansion.hazards.assign(saved.hazards); w.opened_kunai_gates = saved.gates; w.expansion_flags = saved.lore; w.tether_anchors.assign(saved.anchors)
		for n in w.geometry.get_children():
			if n.has_meta("art06_hidden"): n.add_to_group("kaze_grapple_anchor"); n.remove_meta("art06_hidden")
		w.expansion.hide_portals = false
	w.queue_redraw()

func run():
	DirAccess.make_dir_recursive_absolute(out)
	root.transparent_bg = false
	var w = load("res://scenes/main.tscn").instantiate()
	root.add_child(w); current_scene = w
	await process_frame
	w.embodied_transitions.production_art = Suppress.new()
	w.expansion = load("res://tools/art06/expansion_markers_off.gd").new()
	w.build_room(ROOM)
	# Anchors are drawn only when tether is unlocked; enable it visually so the
	# three R18 anchors appear in review frames (no physics/save effect: test mode).
	w.player.tether_unlocked = true
	await process_frame
	var sig := JSON.stringify(w.platforms)
	w.player.set_physics_process(false); w.player.set_process(false)
	for e in w.enemies: e.set_physics_process(false); e.set_process(false)
	w.message_time = 0.0
	var hud_layers := []
	for c in w.get_children(): if c is CanvasLayer: hud_layers.append(c)
	var views := {"west_arrival":Vector2(260,1000),"guard_shelf":Vector2(950,800),"lower_bay":Vector2(1200,1180),"lore_shelf":Vector2(1600,620),"east_gate":Vector2(2250,760),"overview":Vector2(1300,830)}
	var cams := {}
	for k in views:
		w.player.position = views[k]
		if k == "overview":
			w.camera.zoom = Vector2.ONE * (1280.0 / 2600.0)
			w.camera.limit_left = -10000; w.camera.limit_right = 10000; w.camera.limit_top = -10000; w.camera.limit_bottom = 10000
		w.camera.reset_smoothing(); w.camera.force_update_scroll()
		w.queue_redraw()
		# plate
		root.transparent_bg = false
		w.self_modulate.a = 1.0; w.geometry.visible = true
		w.player.visible = false
		for e in w.enemies: e.visible = false
		for h in hud_layers: h.visible = false
		await grab(out + "/%s_plate.png" % k)
		# Same frame with runtime interactive markers (doors, labels, gate bars, anchors,
		# hazard telegraph, lore marker) switched off; the diff isolates those markers,
		# which the real integration draws AFTER the dressing (draw_background hook).
		await set_markers(w, false)
		await grab(out + "/%s_plate_nomarkers.png" % k)
		await set_markers(w, true)
		# actors on transparent background
		root.transparent_bg = true
		w.self_modulate.a = 0.0
		w.player.visible = true
		for e in w.enemies: e.visible = true
		await grab(out + "/%s_actors.png" % k)
		# hud on transparent background
		if k != "overview":
			w.player.visible = false
			for e in w.enemies: e.visible = false
			for h in hud_layers: h.visible = true
			await grab(out + "/%s_hud.png" % k)
			for h in hud_layers: h.visible = false
		w.self_modulate.a = 1.0
		var c = w.camera.get_screen_center_position()
		cams[k] = {"center":[c.x,c.y],"zoom":w.camera.zoom.x,"player":[views[k].x,views[k].y]}
	var f = FileAccess.open(out + "/cameras.json", FileAccess.WRITE); f.store_string(JSON.stringify(cams, "  ")); f.close()
	print("GEOMETRY_UNCHANGED ", sig == JSON.stringify(w.platforms))
	quit(0 if sig == JSON.stringify(w.platforms) else 1)
