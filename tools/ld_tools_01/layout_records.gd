extends RefCounted
## Read-only adapter for a future approved RECTANGLE migration. Never mutates a world.
## Instantiate the PackedScene to consume its native bodies. This adapter supplies
## legacy Rect2 queries/drawing with the same data, without guessing rotation bounds.
static func read(layout: Node2D) -> Dictionary:
	var records: Array = []
	var errors: Array[String] = []
	if layout.get_meta("format_version",0) != 1 or layout.get_meta("room_id",-1) != 18:
		errors.append("Expected R18 layout format 1")
	for c in layout.find_children("*","CollisionShape2D",true,false):
		if not c.shape is RectangleShape2D:
			errors.append("Unsupported rectangle shape: " + str(c.name))
			continue
		var t: Transform2D = layout.global_transform.affine_inverse() * c.global_transform
		if not t.x.is_equal_approx(Vector2.RIGHT) or not t.y.is_equal_approx(Vector2.DOWN):
			errors.append("Keep rectangle nodes and parents unrotated, unscaled and unskewed")
			continue
		if not c.get_parent() is StaticBody2D:
			errors.append("Surface requires a StaticBody2D parent")
			continue
		if c.shape.size.x <= 0 or c.shape.size.y <= 0:
			errors.append("Rectangle size must be positive")
			continue
		records.append({"rect":Rect2(t.origin-c.shape.size/2,c.shape.size),"disabled":c.disabled,
			"one_way":c.one_way_collision,"margin":c.one_way_collision_margin,
			"layer":c.get_parent().collision_layer,"mask":c.get_parent().collision_mask})
	for c in layout.find_children("*","CollisionPolygon2D",true,false):
		if not c.disabled:
			errors.append("Enabled slopes need a separately approved polygon consumer; do not approximate with Rect2")
	return {"records":records,"errors":errors}
