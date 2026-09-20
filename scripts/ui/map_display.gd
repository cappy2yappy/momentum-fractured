extends Control
class_name KazeMapDisplay

@export var compact := false

const ROOM_POSITIONS := {
	"room_01_combat": Vector2i(0, 2),
	"room_02_platforming": Vector2i(1, 2),
	"room_03_mixed": Vector2i(2, 2),
	"room_03_safe": Vector2i(2, 3),
	"room_04_checkpoint": Vector2i(3, 2),
	"room_05_route": Vector2i(4, 2),
	"room_06_route": Vector2i(4, 1),
	"room_07_route": Vector2i(5, 1),
	"room_08_route": Vector2i(5, 2),
	"room_09_route": Vector2i(6, 2),
	"room_10_route": Vector2i(5, 3),
	"room_11_route": Vector2i(6, 3),
	"room_12_route": Vector2i(7, 3),
}

const LINKS := [
	["room_01_combat", "room_02_platforming"],
	["room_02_platforming", "room_03_mixed"],
	["room_03_mixed", "room_04_checkpoint"],
	["room_04_checkpoint", "room_05_route"],
	["room_05_route", "room_06_route"],
	["room_06_route", "room_07_route"],
	["room_07_route", "room_08_route"],
	["room_08_route", "room_09_route"],
	["room_08_route", "room_10_route"],
	["room_10_route", "room_11_route"],
	["room_11_route", "room_12_route"],
]

var current_room_id := ""


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(190, 76) if compact else Vector2(640, 320)
	current_room_id = _scene_room_id()
	if GameState.has_signal("map_changed") and not GameState.map_changed.is_connected(queue_redraw):
		GameState.map_changed.connect(queue_redraw)
	queue_redraw()


func _scene_room_id() -> String:
	var scene := get_tree().current_scene
	if scene == null:
		return ""
	var path := scene.scene_file_path.get_file().get_basename()
	return path


func _draw() -> void:
	var step := Vector2(21, 17) if compact else Vector2(70, 62)
	var origin := Vector2(10, 4) if compact else Vector2(48, 42)
	var room_size := Vector2(15, 11) if compact else Vector2(47, 31)
	for link in LINKS:
		var from_id: String = link[0]
		var to_id: String = link[1]
		if not GameState.has_visited_room(from_id) or not GameState.has_visited_room(to_id):
			continue
		var from_center := origin + Vector2(ROOM_POSITIONS[from_id]) * step + room_size * 0.5
		var to_center := origin + Vector2(ROOM_POSITIONS[to_id]) * step + room_size * 0.5
		draw_line(from_center, to_center, Color(0.23, 0.68, 0.77, 0.72), 3.0 if not compact else 1.4)

	for key in ROOM_POSITIONS:
		var room_id := String(key)
		var visited := GameState.has_visited_room(room_id)
		if not visited and room_id != current_room_id:
			continue
		var room_rect := Rect2(origin + Vector2(ROOM_POSITIONS[room_id]) * step, room_size)
		var is_current := room_id == current_room_id
		var fill := Color(0.14, 0.76, 0.89, 0.94) if is_current else Color(0.09, 0.20, 0.30, 0.96)
		var outline := Color(0.82, 1.0, 1.0, 1.0) if is_current else Color(0.27, 0.72, 0.80, 0.88)
		draw_rect(room_rect, fill, true)
		draw_rect(room_rect, outline, false, 2.0 if not compact else 1.0)
		if not compact:
			var room_number := room_id.substr(5, 2)
			draw_string(ThemeDB.fallback_font, room_rect.position + Vector2(12, 22), room_number, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color.WHITE)

	if not compact:
		draw_string(ThemeDB.fallback_font, Vector2(48, 288), "Cyan: current room    Blue: explored    M: close map", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(0.64, 0.86, 0.90))
