extends RefCounted
## Format 1 is the immutable LD-TOOLS-01 R18 contract; format 2 generalizes identity/bounds.
const RectVisual = preload("res://tools/ld_tools_01/rectangle_surface.gd")
const SlopeVisual = preload("res://tools/ld_tools_01/slope_surface.gd")
const LayoutRoot = preload("res://tools/ld_tools_02/room_layout.gd")
const Marker = preload("res://tools/ld_tools_02/room_marker.gd")

static func read(layout: Node2D) -> Dictionary:
	var errors: Array[String] = []
	var records: Array = []
	var version = layout.get_meta("format_version", 0)
	var room_id = layout.get_meta("room_id", -1)
	var bounds = layout.get_meta("room_size", Vector2(2600,1440) if version == 1 else Vector2.ZERO)
	if version not in [1,2]: errors.append("Unsupported layout format: %s" % version)
	if not room_id is int or room_id < 0 or (version == 1 and room_id != 18):
		errors.append("A stable nonnegative integer room_id is required; format 1 is R18 only")
	if not bounds is Vector2 or not bounds.is_finite() or bounds.x <= 0 or bounds.y <= 0:
		errors.append("room_size must be a positive finite Vector2")
	if layout.transform != Transform2D.IDENTITY: errors.append("Layout root must have identity transform")
	var geometry = layout.get_node_or_null("Geometry")
	if geometry == null: errors.append("Missing Geometry branch")
	var allowed_scripts = [null, RectVisual, SlopeVisual, LayoutRoot, Marker]
	for node in [layout] + layout.find_children("*", "", true, false):
		if node.get_script() not in allowed_scripts: errors.append("Unsupported executable script at %s" % node.name)
		if node is CollisionObject2D:
			if not node is StaticBody2D or geometry == null or not geometry.is_ancestor_of(node):
				# The legacy disabled slope sample is allowed outside Geometry.
				if not (version == 1 and node.name == "SlopeExample_DISABLED" and node is StaticBody2D):
					errors.append("Physics belongs only in Geometry/StaticBody2D: %s" % node.name)
			if node is StaticBody2D:
				if node.collision_layer != 1 or node.collision_mask != 1:
					errors.append("Static bodies must retain layer 1 / mask 1: %s" % node.name)
				if node.constant_linear_velocity != Vector2.ZERO or node.constant_angular_velocity != 0:
					errors.append("Moving surfaces are unsupported: %s" % node.name)
		if node is CollisionPolygon2D:
			if not node.disabled: errors.append("Enabled slopes/arbitrary polygons require controller approval: %s" % node.name)
		elif node is CollisionShape2D:
			if not node.shape is RectangleShape2D or not node.get_parent() is StaticBody2D:
				errors.append("Expected RectangleShape2D under StaticBody2D: %s" % node.name)
				continue
			var transform = layout.transform.affine_inverse() * _relative_transform(layout, node)
			if not transform.x.is_equal_approx(Vector2.RIGHT) or not transform.y.is_equal_approx(Vector2.DOWN):
				errors.append("Rotation, scale, skew and mirroring are unsupported: %s" % node.name)
				continue
			if not transform.origin.is_finite() or not node.shape.size.is_finite() or node.shape.size.x <= 0 or node.shape.size.y <= 0:
				errors.append("Rectangle position/size must be finite and size positive: %s" % node.name)
				continue
			if not is_finite(node.one_way_collision_margin) or node.one_way_collision_margin < 0:
				errors.append("One-way margin must be finite and nonnegative")
			records.append({"rect":Rect2(transform.origin-node.shape.size/2,node.shape.size),
				"disabled":node.disabled,"one_way":node.one_way_collision,"margin":node.one_way_collision_margin,
				"layer":node.get_parent().collision_layer,"mask":node.get_parent().collision_mask})
	return {"records":records,"errors":errors,"room_id":room_id,"room_size":bounds,"version":version}

static func _relative_transform(layout: Node2D, node: Node2D) -> Transform2D:
	var result = node.transform
	var parent = node.get_parent()
	while parent != layout and parent != null:
		if parent is Node2D: result = parent.transform * result
		parent = parent.get_parent()
	return result
