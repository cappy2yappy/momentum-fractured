extends SceneTree
const Factory = preload("res://tools/ld_tools_02/layout_factory.gd")
const Contract = preload("res://tools/ld_tools_02/layout_contract.gd")
var failures = 0
func _init(): call_deferred("run")
func check(ok,label):
	print("PASS: " if ok else "FAIL: ",label)
	if not ok: failures += 1
func run():
	var layout = Factory.create(21,Vector2(2600,1440))
	var shape = layout.get_node("Geometry/Floor/Surface")
	var original = shape.shape
	shape.shape = CircleShape2D.new();check(not Contract.read(layout).errors.is_empty(),"Reject nonrectangle collision")
	shape.shape = original
	layout.set_meta("format_version",99);check(not Contract.read(layout).errors.is_empty(),"Reject unsupported version")
	layout.set_meta("format_version",2)
	layout.set_meta("room_id",-1);check(not Contract.read(layout).errors.is_empty(),"Reject missing stable identity")
	layout.set_meta("room_id",21)
	layout.scale = Vector2(2,1);check(not Contract.read(layout).errors.is_empty(),"Reject root scale")
	layout.scale = Vector2.ONE
	layout.get_node("Geometry").rotation = 0.1;check(not Contract.read(layout).errors.is_empty(),"Reject ancestor rotation")
	layout.get_node("Geometry").rotation = 0
	shape.one_way_collision_margin = -1;check(not Contract.read(layout).errors.is_empty(),"Reject negative margin")
	shape.one_way_collision_margin = 1
	var slope = CollisionPolygon2D.new();slope.polygon = PackedVector2Array([Vector2.ZERO,Vector2(50,0),Vector2(50,50)])
	layout.get_node("Geometry/Floor").add_child(slope)
	check(not Contract.read(layout).errors.is_empty(),"Reject enabled slope instead of rectangle approximation")
	slope.disabled = true;check(Contract.read(layout).errors.is_empty(),"Disabled polygon contributes no rectangle record")
	slope.free()
	var body = layout.get_node("Geometry/Floor")
	body.constant_linear_velocity = Vector2(20,0);check(not Contract.read(layout).errors.is_empty(),"Reject moving surface")
	body.constant_linear_velocity = Vector2.ZERO
	layout.get_node("Geometry").position = Vector2(16,-8)
	check(Contract.read(layout).records[2].rect == Rect2(16,1292,2600,140),"Translated geometry ancestors preserve local rectangle coordinates")
	layout.get_node("Geometry").position = Vector2.ZERO
	layout.free()
	if "--test" not in OS.get_cmdline_user_args(): quit(2);return
	var w = load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene = w
	w.set_physics_process(false);w.player.set_physics_process(false)
	w.build_room(18);var original_rectangles = w.platforms.duplicate()
	w.authored_r18_enabled = true
	var bad = Factory.create(19,Vector2(2600,1440));var packed = PackedScene.new();packed.pack(bad)
	ResourceSaver.save(packed,"res://build/room-creator-wrong-id.tscn");bad.free()
	w.authored_r18_path = "res://build/room-creator-wrong-id.tscn"
	print("EXPECTED VALIDATION ERROR follows (wrong live room identity)")
	w.build_room(18)
	check(not w.authored_room_active and w.platforms == original_rectangles,"Invalid live layout fails closed to complete legacy geometry")
	w.authored_r18_path = "res://build/nonexistent-room-layout.tscn"
	print("EXPECTED VALIDATION ERROR follows (missing resource)")
	w.build_room(18)
	check(not w.authored_room_active and w.platforms == original_rectangles,"Missing live layout fails closed to complete legacy geometry")
	w.queue_free();current_scene = null;await process_frame;await process_frame
	quit(1 if failures else 0)
