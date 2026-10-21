@tool
extends RefCounted
const RootScript = preload("res://tools/ld_tools_02/room_layout.gd")
const SurfaceScript = preload("res://tools/ld_tools_01/rectangle_surface.gd")
const MarkerScript = preload("res://tools/ld_tools_02/room_marker.gd")
const TEMPLATES = {"Standard 2600 x 1440":Vector2(2600,1440),"Tall 1800 x 2400":Vector2(1800,2400),"Wide 3200 x 1440":Vector2(3200,1440)}

static func create(room_id: int, size: Vector2) -> Node2D:
	var layout = Node2D.new()
	layout.name = "Room_%d_Layout" % room_id
	layout.set_script(RootScript)
	layout.set_meta("format_version",2)
	layout.set_meta("room_id",room_id)
	layout.set_meta("room_size",size)
	for branch in ["Geometry","Background","Foreground","Markers"]:
		var child = Node2D.new();child.name = branch;layout.add_child(child);child.owner = layout
	layout.get_node("Background").z_index = -10
	layout.get_node("Foreground").z_index = 10
	for entry in [["WallWest",Rect2(-40,0,40,size.y)],["WallEast",Rect2(size.x,0,40,size.y)],["Floor",Rect2(0,size.y-140,size.x,140)]]:
		var body = rectangle(entry[0],entry[1],false)
		layout.get_node("Geometry").add_child(body);own(body,layout)
	return layout

static func rectangle(label: String, rect: Rect2, one_way := true) -> StaticBody2D:
	var body = StaticBody2D.new();body.name = label
	var surface = CollisionShape2D.new();surface.name = "Surface"
	surface.set_script(SurfaceScript)
	var shape = RectangleShape2D.new();shape.resource_local_to_scene = true;shape.size = rect.size
	surface.shape = shape;surface.position = rect.get_center()
	surface.one_way_collision = one_way;surface.one_way_collision_margin = 8 if one_way else 1
	body.add_child(surface)
	return body

static func marker(kind: String) -> Marker2D:
	var node = Marker2D.new();node.name = kind + "_Proposal";node.set_script(MarkerScript);node.kind = kind
	return node

static func own(node: Node, layout: Node):
	node.owner = layout
	for child in node.get_children(): own(child,layout)
