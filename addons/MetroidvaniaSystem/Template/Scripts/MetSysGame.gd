


extends Node

const MetSysModule = preload("res://addons/MetroidvaniaSystem/Template/Scripts/MetSysModule.gd")

var player: Node2D
var map: Node2D
var map_changing: bool

var modules: Array[MetSysModule]


signal room_loaded


func set_player(p_player: Node2D):
	player = p_player
	player.get_tree().physics_frame.connect(_physics_tick, CONNECT_DEFERRED)


func add_module(module_name: String) -> MetSysModule:

	if not module_name.is_absolute_path():
		module_name = "res://addons/MetroidvaniaSystem/Template/Scripts/Modules/".path_join(module_name)

	var module: MetSysModule = load(module_name).new(self)
	modules.append(module)
	return module

func _physics_tick():
	if is_inside_tree() and can_process():
		MetSys.set_player_position(player.position)



func load_room(path: String):
	if map_changing:
		return

	map_changing = true

	if map:
		map.queue_free()
		await map.tree_exited
		map = null

	map = _load_room(path)
	add_child(map)

	MetSys.current_layer = MetSys.get_current_room_instance().get_layer()
	map_changing = false
	room_loaded.emit()


func _load_room(path: String) -> Node:
	return load(path).instantiate()

func get_save_data() -> Dictionary:
	var data: Dictionary
	data.merge(_get_save_data())

	for module in modules:
		data.merge(module._get_save_data())

	return data


func _get_save_data() -> Dictionary:
	return {}

func set_save_data(data: Dictionary):
	_set_save_data(data)

	for module in modules:
		module._set_save_data(data)


func _set_save_data(data: Dictionary):
	pass
