@tool
extends Resource


@export var theme: MapTheme:
	set(t):
		if t == theme:
			return

		theme = t
		theme_changed.emit()

@export_custom(PROPERTY_HINT_SAVE_FILE, "") var map_data_file: String = "res://MapData.txt":
	set(mdf):
		if map_data_file == mdf:
			return
		map_data_file = mdf
		map_data_file_changed.emit()


@export_range(50, 1000) var map_extents: int = 100


@export_file("*.tscn", "*.scn") var scene_template: String


@export var in_game_cell_size: = Vector2(1152, 648)


@export var discover_whole_rooms: = false


@export var cache_group_reverse_lookup: = true


@export var custom_element_script: Script:
	set(elements):
		if elements == custom_element_script:
			return

		custom_element_script = elements
		if elements:
			custom_elements = elements.new()
		else:
			custom_elements = null

		custom_elements_changed.emit()

@export_storage var _last_scene_folder: String
@export_storage var _collectible_list: Array[Dictionary]

var custom_elements: MetroidvaniaSystem.CustomElementManager
var _legacy_map_root: String

signal theme_changed
signal map_data_file_changed
signal custom_elements_changed

func get_scene_folder() -> String:
	if _last_scene_folder.is_empty():
		return MetSys.settings.map_data_file.get_base_dir()
	else:
		return MetSys.settings._last_scene_folder



func _set(property: StringName, value: Variant) -> bool:
	if property == &"collectible_list":
		_collectible_list = value
		return true
	elif property == &"map_root_folder":
		var folder: = value as String
		_legacy_map_root = folder
		map_data_file = folder.path_join("MapData.txt")
		return true

	return false
