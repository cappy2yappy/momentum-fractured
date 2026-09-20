extends RefCounted
class_name RoomGraph

## Canonical topology for the currently implemented 12-room campaign.
## Static room scenes keep their authored doors, while generated route rooms
## and the map consume this graph directly.

const ROOM_SCENES := {
	"room_01_combat": "res://scenes/rooms/room_01_combat.tscn",
	"room_02_platforming": "res://scenes/rooms/room_02_platforming.tscn",
	"room_03_mixed": "res://scenes/rooms/room_03_mixed.tscn",
	"room_04_checkpoint": "res://scenes/rooms/room_04_checkpoint.tscn",
	"room_05_route": "res://scenes/rooms/room_05_route.tscn",
	"room_06_route": "res://scenes/rooms/room_06_route.tscn",
	"room_07_route": "res://scenes/rooms/room_07_route.tscn",
	"room_08_route": "res://scenes/rooms/room_08_route.tscn",
	"room_09_route": "res://scenes/rooms/room_09_route.tscn",
	"room_10_route": "res://scenes/rooms/room_10_route.tscn",
	"room_11_route": "res://scenes/rooms/room_11_route.tscn",
	"room_12_route": "res://scenes/rooms/room_12_route.tscn",
}

const ROOM_POSITIONS := {
	"room_01_combat": Vector2i(0, 2),
	"room_02_platforming": Vector2i(1, 2),
	"room_03_mixed": Vector2i(2, 2),
	"room_04_checkpoint": Vector2i(3, 2),
	"room_05_route": Vector2i(4, 2),
	"room_06_route": Vector2i(4, 1),
	"room_07_route": Vector2i(5, 1),
	"room_08_route": Vector2i(5, 2),
	"room_09_route": Vector2i(6, 2),
	"room_10_route": Vector2i(6, 3),
	"room_11_route": Vector2i(7, 3),
	"room_12_route": Vector2i(8, 3),
}

# The first eleven connections are bidirectional. Room 12's return loop to
# Room 5 is intentionally one-way until the campaign receives authored hubs.
const CONNECTIONS := [
	{"from": "room_01_combat", "to": "room_02_platforming", "bidirectional": true},
	{"from": "room_02_platforming", "to": "room_03_mixed", "bidirectional": true},
	{"from": "room_03_mixed", "to": "room_04_checkpoint", "bidirectional": true},
	{"from": "room_04_checkpoint", "to": "room_05_route", "bidirectional": true},
	{"from": "room_05_route", "to": "room_06_route", "bidirectional": true},
	{"from": "room_06_route", "to": "room_07_route", "bidirectional": true},
	{"from": "room_07_route", "to": "room_08_route", "bidirectional": true},
	{"from": "room_08_route", "to": "room_09_route", "bidirectional": true},
	{"from": "room_09_route", "to": "room_10_route", "bidirectional": true},
	{"from": "room_10_route", "to": "room_11_route", "bidirectional": true},
	{"from": "room_11_route", "to": "room_12_route", "bidirectional": true},
	{"from": "room_12_route", "to": "room_05_route", "bidirectional": false},
]


static func room_id_for_index(room_index: int) -> String:
	match room_index:
		1:
			return "room_01_combat"
		2:
			return "room_02_platforming"
		3:
			return "room_03_mixed"
		4:
			return "room_04_checkpoint"
		_:
			return "room_%02d_route" % room_index


static func scene_for_room(room_id: String) -> String:
	return String(ROOM_SCENES.get(room_id, ""))


static func room_id_from_scene(scene_path: String) -> String:
	for room_id in ROOM_SCENES:
		if ROOM_SCENES[room_id] == scene_path:
			return String(room_id)
	return ""


static func entry_marker_from(source_room_id: String) -> String:
	return "entry_from_room%d" % room_number(source_room_id)


static func room_number(room_id: String) -> int:
	if room_id.length() < 7:
		return -1
	return int(room_id.substr(5, 2))


static func has_transition(source_room_id: String, target_room_id: String) -> bool:
	for connection in CONNECTIONS:
		if connection.from == source_room_id and connection.to == target_room_id:
			return true
		if connection.bidirectional and connection.to == source_room_id and connection.from == target_room_id:
			return true
	return false


static func incoming_rooms(room_id: String) -> Array[String]:
	var incoming: Array[String] = []
	for connection in CONNECTIONS:
		if connection.to == room_id:
			incoming.append(String(connection.from))
		if connection.bidirectional and connection.from == room_id:
			incoming.append(String(connection.to))
	return incoming
