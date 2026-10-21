extends RefCounted
## Only R18 is registered. Invalid scenes fail closed to the unchanged generator.
const Contract = preload("res://tools/ld_tools_02/layout_contract.gd")
const ProductionSurfaces = preload("res://tools/ld_tools_02/production_surfaces.gd")
const DEFAULT_LAYOUT = "res://tools/ld_tools_01/r18_layout.tscn"

static func prepare(world) -> bool:
	world.authored_room_active = false
	if world.room != 18 or not world.authored_r18_enabled: return false
	var path: String = world.authored_r18_path
	if not ResourceLoader.exists(path,"PackedScene"):
		push_error("Room Creator: missing PackedScene %s; using legacy R18" % path);return false
	var packed = ResourceLoader.load(path,"PackedScene",ResourceLoader.CACHE_MODE_IGNORE)
	if not packed is PackedScene:
		push_error("Room Creator: expected PackedScene; using legacy R18");return false
	var layout = packed.instantiate()
	if not layout is Node2D:
		layout.free();push_error("Room Creator: expected Node2D root; using legacy R18");return false
	var result = Contract.read(layout)
	if result.room_id != 18 or result.room_size != world.room_size(18):
		result.errors.append("Live pilot requires room_id=18 and room_size=2600x1440")
	if not result.errors.is_empty():
		push_error("Room Creator: %s; using legacy R18" % "; ".join(result.errors));layout.free();return false
	# Production terrain consumes the same support rectangles once. Hide authoring ink.
	for surface in layout.find_children("*","CollisionShape2D",true,false): surface.hide()
	for surface in layout.find_children("*","CollisionPolygon2D",true,false): surface.hide()
	var markers = layout.get_node_or_null("Markers")
	if markers: markers.hide()
	# Format 1 scenery was a disconnected placeholder, never part of the baseline room.
	if result.version == 1:
		for branch in ["Background","Foreground"]:
			var decoration = layout.get_node_or_null(branch)
			if decoration: decoration.hide()
	world.geometry.add_child(layout)
	for record in result.records:
		if not record.disabled: world.platforms.append(record.rect)
	var terrain = ProductionSurfaces.new();terrain.records.assign(world.platforms)
	layout.add_child(terrain);layout.move_child(terrain,0)
	var background = layout.get_node_or_null("Background")
	if background:
		background.z_index = 0;layout.move_child(background,0)
	world.authored_room_active = true
	return true
