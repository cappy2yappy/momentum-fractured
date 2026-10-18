extends SceneTree
var failures := 0
var passes := 0
const Layout = preload("res://tools/ld_tools_01/r18_layout.tscn")
const RectVisual = preload("res://tools/ld_tools_01/rectangle_surface.gd")

func _init(): call_deferred("run")
func check(ok: bool, message: String):
	print(("PASS: " if ok else "FAIL: ") + message)
	if ok: passes += 1
	else: failures += 1

func make_probe(at: Vector2) -> CharacterBody2D:
	var b := CharacterBody2D.new()
	b.position = at
	b.collision_layer = 2
	b.collision_mask = 1
	var c := CollisionShape2D.new()
	var s := RectangleShape2D.new()
	s.size = Vector2(10,10)
	c.shape = s
	b.add_child(c)
	root.add_child(b)
	return b

func travel(b: CharacterBody2D, motion: Vector2) -> bool:
	await physics_frame
	var hit := b.move_and_collide(motion)
	return hit != null

func run():
	var layout := Layout.instantiate()
	root.add_child(layout)
	await process_frame
	var expected = JSON.parse_string(FileAccess.get_file_as_string("res://tools/ld_tools_01/r18_frozen.json"))
	var bodies := layout.get_node("Geometry").get_children()
	check(bodies.size() == 18, "Frozen layout contains 18 platform/wall/floor bodies")
	for i in bodies.size():
		var b = bodies[i]
		var c = b.get_node("Surface")
		var r = expected.shapes[i]
		var rect := Rect2(c.position-c.shape.size/2,c.shape.size)
		check(rect == Rect2(r.rect[0],r.rect[1],r.rect[2],r.rect[3]), "Exact frozen rectangle %d"%i)
		check(c.one_way_collision == r.one_way and c.one_way_collision_margin == r.margin and b.collision_layer == r.layer and b.collision_mask == r.mask,"Exact physics policy %d"%i)
		check(c.get_script() == RectVisual,"Drawing reads collider resource %d"%i)
	check(layout.get_node("Background").find_children("*","CollisionObject2D",true,false).is_empty(),"Background decorations have no physics body")
	check(layout.get_node("Foreground").find_children("*","CollisionObject2D",true,false).is_empty(),"Foreground decorations have no physics body")
	check(layout.get_node("Markers").find_children("*","CollisionObject2D",true,false).is_empty(),"Ladder is marker only")
	check(layout.get_node("SlopeExample_DISABLED/Surface").disabled,"Optional slope starts disabled")
	var adapter = load("res://tools/ld_tools_01/layout_records.gd")
	var result = adapter.read(layout)
	check(result.errors.is_empty() and result.records.size() == 18,"Read-only rectangle consumer accepts frozen layout")
	layout.get_node("Geometry/Platform_01").rotation = 0.2
	check(not adapter.read(layout).errors.is_empty(),"Consumer rejects rotated rectangle instead of inventing a bounding collider")
	layout.get_node("Geometry/Platform_01").rotation = 0
	layout.get_node("SlopeExample_DISABLED/Surface").disabled = false
	check(not adapter.read(layout).errors.is_empty(),"Legacy rectangle consumer rejects enabled slopes")
	layout.get_node("SlopeExample_DISABLED/Surface").disabled = true
	# Compare to actual game builder; game must be invoked with -- --test.
	check("--test" in OS.get_cmdline_user_args(),"Save-safe invocation")
	if "--test" in OS.get_cmdline_user_args():
		var w = load("res://scenes/main.tscn").instantiate()
		root.add_child(w)
		w.set_physics_process(false)
		w.player.set_physics_process(false)
		w.build_room(18)
		check(w.platforms.size() == bodies.size(),"Runtime generator count matches frozen layout")
		for i in w.platforms.size():
			var c = bodies[i].get_node("Surface")
			check(w.platforms[i] == Rect2(c.position-c.shape.size/2,c.shape.size),"Runtime R18 rectangle %d matches authored source"%i)
		check(w.ROOM_COUNT == 21 and w.world_edges().size() == 29,"21 rooms and 29 links remain")
		w.queue_free()
		await process_frame
	# Save edits to a disposable scene and reload with cache bypass.
	var editable = bodies[3].get_node("Surface")
	var untouched_size = bodies[4].get_node("Surface").shape.size
	editable.position += Vector2(23,-17)
	editable.shape.size = Vector2(370,52)
	editable.one_way_collision = false
	var decoration := Polygon2D.new()
	decoration.name = "QADecoration"
	decoration.polygon = PackedVector2Array([Vector2.ZERO,Vector2(10,0),Vector2(0,10)])
	layout.get_node("Foreground").add_child(decoration)
	decoration.owner = layout
	var packed := PackedScene.new()
	check(packed.pack(layout) == OK,"Edited scene packs")
	check(ResourceSaver.save(packed,"user://r18-roundtrip.tscn") == OK,"Edited layout saves")
	var restored = ResourceLoader.load("user://r18-roundtrip.tscn","PackedScene",ResourceLoader.CACHE_MODE_IGNORE).instantiate()
	var saved = restored.get_node("Geometry/Platform_01/Surface")
	check(saved.position == editable.position and saved.shape.size == Vector2(370,52) and not saved.one_way_collision,"Move, resize, solid checkbox persist after reload")
	check(restored.has_node("Foreground/QADecoration"),"Placed decoration persists after reload")
	check(restored.get_node("Geometry/Platform_02/Surface").shape.size == untouched_size,"Shape resources do not resize another platform")
	restored.free()
	layout.queue_free()
	await process_frame
	# Isolated native collision checks, away from game geometry.
	var body := StaticBody2D.new()
	var surface := CollisionShape2D.new()
	surface.set_script(RectVisual)
	surface.shape = RectangleShape2D.new()
	surface.shape.size = Vector2(200,40)
	surface.position = Vector2(500,500)
	body.add_child(surface)
	root.add_child(body)
	var probe := make_probe(Vector2(500,450))
	check(await travel(probe,Vector2(0,100)),"Solid blocks downward probe")
	probe.position = Vector2(500,550)
	check(await travel(probe,Vector2(0,-100)),"Solid blocks upward probe")
	surface.one_way_collision = true
	surface.one_way_collision_margin = 8
	probe.position = Vector2(500,550)
	check(not await travel(probe,Vector2(0,-100)),"One-way permits upward probe")
	probe.position = Vector2(500,450)
	check(await travel(probe,Vector2(0,100)),"One-way catches downward probe")
	surface.set_deferred("disabled",true)
	probe.position = Vector2(500,450)
	await process_frame
	check(not await travel(probe,Vector2(0,100)),"Disabled surface permits downward probe")
	body.queue_free()
	await process_frame
	var slope_body := StaticBody2D.new()
	var slope := CollisionPolygon2D.new()
	slope.set_script(load("res://tools/ld_tools_01/slope_surface.gd"))
	slope.polygon = PackedVector2Array([Vector2(400,500),Vector2(600,400),Vector2(600,500)])
	slope_body.add_child(slope)
	root.add_child(slope_body)
	probe.position = Vector2(500,390)
	check(await travel(probe,Vector2(0,140)),"Optional native polygon slope catches downward probe")
	check(probe.position.y > 430 and probe.position.y < 450,"Slope collision follows slanted visual edge, not rectangular bounds")
	slope_body.queue_free()
	probe.queue_free()
	await process_frame
	print("LD-TOOLS-01: %d passes; %d failure(s)"%[passes,failures])
	quit(1 if failures else 0)
