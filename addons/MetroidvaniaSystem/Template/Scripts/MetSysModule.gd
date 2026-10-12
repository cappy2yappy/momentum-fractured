



extends RefCounted

const MetSysGame = preload("res://addons/MetroidvaniaSystem/Template/Scripts/MetSysGame.gd")


var game: MetSysGame

func _init(p_game: MetSysGame) -> void :
	game = p_game
	_initialize()


func _initialize():
	pass


func _get_save_data() -> Dictionary:
	return {}


func _set_save_data(data: Dictionary):
	pass
