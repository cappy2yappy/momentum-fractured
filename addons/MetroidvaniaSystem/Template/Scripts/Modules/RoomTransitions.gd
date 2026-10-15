


extends "res://addons/MetroidvaniaSystem/Template/Scripts/MetSysModule.gd"

var player: Node2D

func _initialize():
	player = game.player
	assert (player)
	MetSys.room_changed.connect(_on_room_changed, CONNECT_DEFERRED)

func _on_room_changed(target_room: String):
	if target_room == MetSys.get_current_room_id():

		return

	var prev_room_instance: = MetSys.get_current_room_instance()
	if prev_room_instance:
		prev_room_instance.get_parent().remove_child(prev_room_instance)

	await game.load_room(target_room)

	if prev_room_instance:
		player.position -= MetSys.get_current_room_instance().get_room_position_offset(prev_room_instance)
		prev_room_instance.queue_free()
