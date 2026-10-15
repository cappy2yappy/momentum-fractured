



extends "res://addons/MetroidvaniaSystem/Template/Scripts/MetSysModule.gd"


var SCROLL_TIME = 0.5
var _SCREEN_SIZE: Vector2i

var _player: Node2D
var _prev_cell: Vector3i


func _initialize():
	_SCREEN_SIZE = Vector2i(
		ProjectSettings.get_setting("display/window/size/viewport_width"), 
		ProjectSettings.get_setting("display/window/size/viewport_height")
	)

	_player = game.player
	assert (_player)
	MetSys.room_changed.connect(_on_room_changed, CONNECT_DEFERRED)
	MetSys.cell_changed.connect(_on_cell_changed)

func _on_room_changed(target_room: String):
	if target_room == MetSys.get_current_room_id():

		return

	var camera: Camera2D = _player.get_viewport().get_camera_2d()

	var prev_room_instance: = MetSys.get_current_room_instance()
	if prev_room_instance:
		prev_room_instance.get_parent().remove_child(prev_room_instance)

	var prev_map: = game.map
	game.map = null

	await game.load_room(target_room)

	if prev_room_instance:
		var offset: = MetSys.get_current_room_instance().get_room_position_offset(prev_room_instance)
		var screen_delta: = game.player.get_global_transform_with_canvas().origin

		_player.position -= offset
		prev_room_instance.queue_free()

		if is_instance_valid(prev_map):
			game.get_tree().paused = true

			await game.get_tree().process_frame
			screen_delta = game.player.get_global_transform_with_canvas().origin - screen_delta

			prev_map.position -= offset

			var tween: = game.create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			tween.tween_property(camera, ^"offset", screen_delta, 0)
			if is_zero_approx(screen_delta.x) or is_zero_approx(screen_delta.y):
				tween.tween_property(camera, ^"offset", Vector2(), SCROLL_TIME)
			else:
				var total: = 1.0 / (absf(screen_delta.x) + absf(screen_delta.y))
				tween.tween_property(camera, ^"offset:x", 0.0, absf(screen_delta.x) * total * SCROLL_TIME)
				tween.tween_property(camera, ^"offset:y", 0.0, absf(screen_delta.y) * total * SCROLL_TIME)

			await tween.finished

			prev_map.queue_free()
			game.get_tree().paused = false

func _on_cell_changed(new_cell: Vector3i):


	_prev_cell = new_cell
