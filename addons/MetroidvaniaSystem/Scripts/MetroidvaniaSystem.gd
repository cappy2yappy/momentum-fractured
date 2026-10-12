@tool



class_name MetroidvaniaSystem extends Node

const DEFAULT_SYMBOL = -99
enum {DISPLAY_CENTER = 1, DISPLAY_OUTLINE = 2, DISPLAY_BORDERS = 4, DISPLAY_SYMBOLS = 8}

const MetSysSettings = preload("res://addons/MetroidvaniaSystem/Scripts/Settings.gd")
const MetSysSaveData = preload("res://addons/MetroidvaniaSystem/Scripts/SaveData.gd")
const MapData = preload("res://addons/MetroidvaniaSystem/Scripts/MapData.gd")
const CellView = preload("res://addons/MetroidvaniaSystem/Scripts/CellView.gd")
const MapBuilder = preload("res://addons/MetroidvaniaSystem/Scripts/MapBuilder.gd")
const RoomInstance = preload("res://addons/MetroidvaniaSystem/Scripts/RoomInstance.gd")
const CustomElementManager = preload("res://addons/MetroidvaniaSystem/Scripts/CustomElementManager.gd")

enum {R, 
		D, 
		L, 
		U, 
	}

var settings: MetSysSettings
var editor_plugin: Node


var CELL_SIZE: Vector2

var map_data: MapData
var save_data: MetSysSaveData

var last_player_position: = Vector3i.MAX
var exact_player_position: Vector2
var current_room: RoomInstance


var current_layer: int:
	set(layer):
		if layer == current_layer:
			return

		current_layer = layer
		cell_changed.emit(Vector3i(last_player_position.x, last_player_position.y, current_layer))


signal cell_changed(new_cell: Vector3i)

signal room_changed(new_room: String)


signal map_updated
signal room_assign_updated
signal theme_modified(changes: Array[String])

func _enter_tree() -> void :
	var settings_path: = "res://MetSysSettings.tres"

	if ProjectSettings.has_setting("addons/metroidvania_system/settings_file"):
		settings_path = ProjectSettings.get_setting("addons/metroidvania_system/settings_file")
	else:
		ProjectSettings.set_setting("addons/metroidvania_system/settings_file", settings_path)

	ProjectSettings.set_initial_value("addons/metroidvania_system/settings_file", "res://MetSysSettings.tres")
	ProjectSettings.add_property_info({"name": "addons/metroidvania_system/settings_file", "type": TYPE_STRING, "hint": PROPERTY_HINT_FILE, "hint_string": "*.tres"})

	if ResourceLoader.exists(settings_path):
		settings = load(settings_path)
	else:
		settings = MetSysSettings.new()
		settings.theme = load("res://addons/MetroidvaniaSystem/Themes/Exquisite/Theme.tres")
		ResourceSaver.save(settings, settings_path)

	settings.theme_changed.connect(_update_theme)
	_update_theme()

	map_data = MapData.new()
	map_data.load_data()

	if Engine.is_editor_hint():
		return

	if settings.cache_group_reverse_lookup:
		map_data.cache_groups()

func _update_theme():
	CELL_SIZE = settings.theme.center_texture.get_size()
	map_updated.emit()


func load_map_data(file: String):
	settings.map_data_file = file
	map_data = MapData.new()
	map_data.load_data()
	map_updated.emit()



func reset_state():
	save_data = null
	last_player_position = Vector3i.MAX
	exact_player_position = Vector2()
	current_room = null
	current_layer = 0


func get_layer_by_name(layer: String) -> int:
	var index: = map_data.layer_names.find(layer)
	if index == -1:
		push_error("Layer \"%s\" does not exist." % layer)
	return index


func get_layer_name(idx: int) -> String:
	if idx < 0:
		push_error("Layer index can't be negative.")
		return ""

	if idx >= map_data.layer_names.size():
		return ""

	return map_data.layer_names[idx]


func get_group_by_name(group: String) -> int:
	var index: = map_data.group_names.find(group)
	if index == -1:
		push_error("Group \"%s\" does not exist." % group)
	return index


func get_group_name(idx: int) -> String:
	if idx < 0:
		push_error("Group index can't be negative.")
		return ""

	if idx >= map_data.group_names.size():
		return ""

	return map_data.group_names[idx]


func get_save_data() -> Dictionary:
	return save_data.get_data()



func set_save_data(data: = {}):
	save_data = MetSysSaveData.new()
	save_data.set_data(data)

func visit_cell(coords: Vector3i):
	save_data.explore_cell(coords)

	var previous_map: = map_data.get_assigned_scene_at(Vector3i(last_player_position.x, last_player_position.y, current_layer))
	var new_map: = map_data.get_assigned_scene_at(coords)
	if not new_map.is_empty() and not previous_map.is_empty() and new_map != previous_map:
		room_changed.emit(new_map)


func is_cell_discovered(coords: Vector3i, include_mapped: = true) -> bool:
	if not save_data:
		return true

	var discovered: = save_data.is_cell_discovered(coords)
	return discovered == 2 or include_mapped and discovered == 1


func get_explored_ratio(layer: = -1):
	var all: float
	var discovered: float

	for coords in map_data.cells:
		if layer != -1 and coords.z != layer:
			continue

		all += 1
		discovered += int(is_cell_discovered(coords, false))

	return discovered / all



func set_player_position(position: Vector2):
	exact_player_position = position
	if not current_room:
		return

	var player_pos: = Vector2i((position / settings.in_game_cell_size).floor()) + current_room.min_cell
	var player_pos_3d: = Vector3i(player_pos.x, player_pos.y, current_layer)
	if player_pos_3d != last_player_position:
		visit_cell(Vector3i(player_pos.x, player_pos.y, current_layer))
		last_player_position = player_pos_3d
		cell_changed.emit(player_pos_3d)


func discover_cell(coords: Vector3i):
	assert (coords in map_data.cells)

	save_data.discover_cell(coords)
	map_updated.emit()


func discover_cell_group(group_id: int):
	assert (group_id in map_data.cell_groups)

	for coords in map_data.cell_groups[group_id]:
		save_data.discover_cell(coords)

	map_updated.emit()


func add_custom_marker(coords: Vector3i, symbol_id: int):
	assert (symbol_id >= 0 and symbol_id < mini(settings.theme.symbols.size(), 63))
	save_data.add_custom_marker(coords, symbol_id)


func remove_custom_marker(coords: Vector3i, symbol_id: int):
	save_data.remove_custom_marker(coords, symbol_id)




func register_storable_object_with_marker(object: Object, stored_callback: = Callable(), map_marker: = DEFAULT_SYMBOL) -> bool:
	if stored_callback.is_null():
		if object is Node:
			stored_callback = object.queue_free
		elif not object is RefCounted:
			stored_callback = Callable(object, &"free")

	if save_data.is_object_stored(object):
		stored_callback.call()
		return true

	if map_marker == DEFAULT_SYMBOL:
		map_marker = settings.theme.uncollected_item_symbol
		object.set_meta(&"map_marker", map_marker)
	elif map_marker > -1:
		object.set_meta(&"map_marker", map_marker)

	if save_data.register_storable_object(object) and map_marker > -1:
		save_data.add_custom_marker(get_object_coords(object), map_marker)

	return false


func register_storable_object(object: Object, stored_callback: = Callable()) -> bool:
	return register_storable_object_with_marker(object, stored_callback, -1)



func store_object(object: Object, map_marker: = DEFAULT_SYMBOL):
	save_data.store_object(object)
	if object.has_meta(&"map_marker"):
		save_data.remove_custom_marker(get_object_coords(object), object.get_meta(&"map_marker"))
	else:
		map_marker = -1

	if map_marker == DEFAULT_SYMBOL:
		map_marker = settings.theme.collected_item_symbol

	if map_marker > -1:
		save_data.add_custom_marker(get_object_coords(object), map_marker)


func is_object_id_stored(id: StringName) -> bool:
	return save_data.stored_objects.get(id, false)



func get_object_id(object: Object) -> StringName:
	var id: StringName = object.get_meta(&"object_id", StringName())
	if not id.is_empty():
		return id

	if object.has_method(&"_get_object_id"):
		id = object._get_object_id()
		object.set_meta(&"object_id", id)
	elif object is Node:
		id = object.owner.scene_file_path.get_file().get_basename() + "/" + (str(object.get_parent().name) if object.get_parent() != object.owner else ".") + "/" + object.name
		object.set_meta(&"object_id", id)

	return id



func get_object_coords(object: Object) -> Vector3i:
	if object.has_meta(&"object_coords"):
		return object.get_meta(&"object_coords")
	elif object.has_method(&"_get_object_coords"):
		var coords: Vector3i = object._get_object_coords()
		object.set_meta(&"object_coords", coords)
		return coords
	elif object is Node:
		var room_name: String = map_data.get_room_from_scene_path(object.owner.scene_file_path)

		var coords: Vector3i = map_data.assigned_scenes[room_name].front()
		for vec in map_data.assigned_scenes[room_name]:
			coords.x = mini(coords.x, vec.x)
			coords.y = mini(coords.y, vec.y)

		if object is CanvasItem:
			var position: Vector2 = object.position / settings.in_game_cell_size
			coords.x += int(position.x)
			coords.y += int(position.y)

		object.set_meta(&"object_coords", coords)
		return coords
	return Vector3i.MAX


func get_cell_groups(coords: Vector3i) -> PackedInt32Array:
	if not map_data.group_cache.is_empty():
		return map_data.group_cache.get(coords, PackedInt32Array())

	var groups: PackedInt32Array
	for group in map_data.cell_groups:
		if coords in map_data.cell_groups[group]:
			groups.append(group)

	return groups



func get_cell_position(coords: Vector2i, relative: = Vector2(0.5, 0.5), base_offset: = Vector2()) -> Vector2:
	return base_offset + (Vector2(coords) + relative) * CELL_SIZE




func get_cell_override(coords: Vector3i, auto_create: = true) -> MapData.CellOverride:
	var cell: = map_data.get_cell_at(coords)
	assert (cell, "Can't override non-existent cell")

	var existing: = cell.get_override()
	if existing:
		return existing
	elif auto_create:
		return save_data.add_cell_override(cell)
	else:
		push_error("No override found at %s" % coords)
		return null



func get_cell_override_from_group(group_id: int, auto_create: = true) -> MapData.CellOverride:
	assert (group_id in map_data.cell_groups)
	return get_cell_override(map_data.cell_groups[group_id].front(), auto_create)



func remove_cell_override(coords: Vector3i):
	var cell: = map_data.get_cell_at(coords)
	assert (cell, "Can't remove override of non-existent cell.")
	if save_data.remove_cell_override(cell):
		map_updated.emit()



func get_map_builder() -> MapBuilder:
	return MapBuilder.new()


func make_map_view(parent_item: CanvasItem, begin: Vector2i, size: Vector2i, layer: int) -> MapView:
	var mv: = MapView.new(parent_item.get_canvas_item())
	mv.begin = begin
	mv.size = size
	mv.layer = layer
	return mv



func add_player_location(canvas_item: CanvasItem, offset: = Vector2()) -> Node2D:
	var location_instance: Node2D = settings.theme.player_location_scene.instantiate()
	location_instance.set_script(load("res://addons/MetroidvaniaSystem/Scripts/PlayerLocationInstance.gd"))
	location_instance.offset = offset
	canvas_item.add_child(location_instance)
	return location_instance


func get_current_coords() -> Vector3i:
	return Vector3i(last_player_position.x, last_player_position.y, current_layer)


func get_current_flat_coords() -> Vector2i:
	return Vector2i(last_player_position.x, last_player_position.y)



func get_current_room_instance() -> RoomInstance:
	if is_instance_valid(current_room):
		return current_room
	return null


func get_current_room_id() -> String:
	if current_room:
		return current_room.room_id
	else:
		return ""


func get_current_room_name() -> String:
	if current_room:
		var id: = current_room.room_id
		var remap = map_data.scene_remaps.find_key(id)
		if remap:
			id = remap
		return map_data.get_room_friendly_name(id)
	else:
		return ""



func get_full_room_path(room_name: String) -> String:
	return ResourceUID.uid_to_path(room_name)
