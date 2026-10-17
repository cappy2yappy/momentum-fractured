extends SceneTree
## ART-06: native Godot capture of R18 with the PROPOSED hooks applied
## (tools/art06/_patched/main.tscn from apply_proposed_hooks.py). Verifies the dressing
## adds no physics and renders gameplay-scale frames + overview.
const ROOM := 18
var out := "res://build/art06/integrated"
var checks := 0
var failures := 0
func _init(): call_deferred("run")
func check(ok: bool, label: String):
	checks += 1
	if not ok: failures += 1
	print("PASS: " if ok else "FAIL: ", label)
func shot(path: String):
	for i in 3: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(path)

func bodies(w) -> Array:
	var r := []
	for b in w.geometry.get_children():
		if b is StaticBody2D:
			for s in b.get_children():
				if s is CollisionShape2D: r.append([b.position + s.position, s.shape.size, s.one_way_collision])
	return r

func run():
	DirAccess.make_dir_recursive_absolute(out)
	# Baseline (unpatched) collider signature first.
	var base = load("res://scenes/main.tscn").instantiate(); root.add_child(base); await process_frame
	base.build_room(ROOM); await process_frame
	var sig: String = JSON.stringify(base.platforms); var shapes: String = JSON.stringify(bodies(base))
	var anchors: String = JSON.stringify(base.grapple_candidates()); var gates: int = base.kunai_gates.size()
	base.queue_free(); await process_frame
	var w = load("res://tools/art06/_patched/main.tscn").instantiate(); root.add_child(w); current_scene = w
	await process_frame
	w.build_room(ROOM); await process_frame
	w.player.tether_unlocked = true
	check(w.R18Dressing.enabled(w), "dressing enabled in R18 (layout + textures present)")
	check(JSON.stringify(w.platforms) == sig, "platform rectangles identical to unpatched runtime")
	check(JSON.stringify(bodies(w)) == shapes, "every CollisionShape2D identical (position, size, one-way)")
	check(w.kunai_gates.size() == gates, "gate count unchanged")
	var fg = w.geometry.get_node_or_null("ART06_R18_Foreground")
	check(fg != null and fg.z_index > w.player.z_index, "foreground occluder node above Kaze")
	check(fg != null and fg.get_child_count() == 0 and not (fg is CollisionObject2D), "foreground node carries no physics")
	var layout = w.R18Dressing.layout()
	var missing: Array = []
	for p in layout.props + layout.supports: if not ResourceLoader.exists(w.R18Dressing.DIR + p.asset + ".png"): missing.append(p.asset)
	for s in layout.surfaces: if not ResourceLoader.exists(w.R18Dressing.DIR + s.tile + ".png"): missing.append(s.tile)
	check(missing.is_empty(), "all layout textures load " + str(missing))
	var matched: int = 0
	for r in w.platforms:
		if r.position.x >= 0 and r.position.x < 2600:
			for s in layout.surfaces:
				var lr := Rect2(s.rect[0], s.rect[1], s.rect[2], s.rect[3])
				if lr.position.is_equal_approx(r.position) and lr.size.is_equal_approx(r.size): matched += 1; break
	check(matched == 16, "16/16 in-room colliders have registered surface art (got %d)" % matched)
	w.player.set_physics_process(false); w.player.set_process(false)
	for e in w.enemies: e.set_physics_process(false)
	w.message_time = 0.0
	var views := {"west_arrival":Vector2(260,1000),"guard_shelf":Vector2(950,800),"lower_bay":Vector2(1200,1180),"lore_shelf":Vector2(1600,620),"east_gate":Vector2(2250,760)}
	for k in views:
		w.player.position = views[k]; w.camera.reset_smoothing(); w.camera.force_update_scroll(); w.queue_redraw()
		await shot(out + "/r18_native_after_%s.png" % k)
	for c in w.get_children(): if c is CanvasLayer: c.visible = false
	w.camera.zoom = Vector2.ONE * (1280.0 / 2600.0); w.player.position = Vector2(1300, 830)
	w.camera.limit_left = -10000; w.camera.limit_right = 10000; w.camera.limit_top = -10000; w.camera.limit_bottom = 10000
	w.camera.reset_smoothing(); w.camera.force_update_scroll(); w.queue_redraw()
	await shot(out + "/r18_native_after_overview.png")
	# Leaving the room must remove the dressing node with the geometry.
	w.camera.zoom = Vector2.ONE
	w.build_room(16); await process_frame; await process_frame
	check(w.geometry.get_node_or_null("ART06_R18_Foreground") == null, "foreground node removed when leaving R18")
	print("ART06_INTEGRATED: %d checks, %d failure(s)" % [checks, failures])
	quit(1 if failures else 0)
