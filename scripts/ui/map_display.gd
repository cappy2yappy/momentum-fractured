extends Control
class_name KazeMapDisplay

@export var compact := false
const ROOM_GRAPH := preload("res://scripts/rooms/room_graph.gd")

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
	for connection in ROOM_GRAPH.CONNECTIONS:
		var from_id: String = connection.from
		var to_id: String = connection.to
		if not GameState.has_visited_room(from_id) or not GameState.has_visited_room(to_id):
			continue
		var from_center := origin + Vector2(ROOM_GRAPH.ROOM_POSITIONS[from_id]) * step + room_size * 0.5
		var to_center := origin + Vector2(ROOM_GRAPH.ROOM_POSITIONS[to_id]) * step + room_size * 0.5
		var gate_id := String(connection.get("gate_id", ""))
		var locked := not gate_id.is_empty() and not GameState.is_gate_open(gate_id)
		var link_color := Color(0.96, 0.38, 0.14, 0.9) if locked else Color(0.23, 0.68, 0.77, 0.72)
		draw_line(from_center, to_center, link_color, 3.0 if not compact else 1.4)
		if not connection.bidirectional:
			var tip := from_center.lerp(to_center, 0.7)
			var direction := (to_center - from_center).normalized()
			var normal := direction.orthogonal()
			var arrow_size := 4.0 if compact else 9.0
			draw_colored_polygon(PackedVector2Array([tip, tip - direction * arrow_size + normal * arrow_size * 0.5, tip - direction * arrow_size - normal * arrow_size * 0.5]), link_color)

	for key in ROOM_GRAPH.ROOM_POSITIONS:
		var room_id := String(key)
		var visited := GameState.has_visited_room(room_id)
		if not visited and room_id != current_room_id:
			continue
		var room_rect := Rect2(origin + Vector2(ROOM_GRAPH.ROOM_POSITIONS[room_id]) * step, room_size)
		var is_current := room_id == current_room_id
		var fill := Color(0.14, 0.76, 0.89, 0.94) if is_current else Color(0.09, 0.20, 0.30, 0.96)
		var outline := Color(0.82, 1.0, 1.0, 1.0) if is_current else Color(0.27, 0.72, 0.80, 0.88)
		draw_rect(room_rect, fill, true)
		draw_rect(room_rect, outline, false, 2.0 if not compact else 1.0)
		if not compact:
			var room_number := room_id.substr(5, 2)
			draw_string(ThemeDB.fallback_font, room_rect.position + Vector2(12, 22), room_number, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color.WHITE)

	if not compact:
		draw_string(ThemeDB.fallback_font, Vector2(48, 288), "Cyan: current    Blue: explored    Orange: sealed route    M: close", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(0.64, 0.86, 0.90))
