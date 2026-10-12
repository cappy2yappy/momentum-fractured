extends RefCounted

const FRAGMENTS = {
	8: [{"id": "undercroft_sigil", "at": Vector2(1470, 690), "gate": ""}],
	9: [{"id": "terrace_west", "at": Vector2(1490, 600), "gate": ""}, {"id": "terrace_fire_cache", "at": Vector2(2240, 770), "gate": "terrace_fire_cache"}],
}
const RETURN_GATE = "terrace_return_relay"

func build_room(world, index):
	var layouts = {
		8: [Rect2(0, 1090, 310, 40), Rect2(350, 1110, 320, 40), Rect2(770, 920, 340, 40), Rect2(1300, 740, 340, 40), Rect2(1810, 900, 360, 40), Rect2(2220, 830, 380, 40)],
		9: [Rect2(0, 830, 650, 40), Rect2(80, 620, 440, 40), Rect2(380, 1040, 800, 40), Rect2(780, 850, 440, 40), Rect2(1360, 640, 400, 40), Rect2(1980, 810, 480, 40)],
	}
	for rect in layouts[index]: world.add_platform(rect)
	world.tether_anchors.assign([Vector2(750, 660), Vector2(1220, 500), Vector2(1800, 570), Vector2(2250, 530)] if index == 8 else [Vector2(670, 480), Vector2(1250, 400), Vector2(1850, 430)])
	var encounters = [["intake_sentinel", Vector2(1810, 1300)], ["terrace_sentinel", Vector2(800, 1040)]]
	var encounter = encounters[index - 8]
	if not world.cleared_encounters.get(encounter[0], false):
		var guard = world.spawn_enemy(encounter[1], false)
		guard.display_name = "INTAKE SENTINEL" if index == 8 else "TERRACE SENTINEL"
		guard.set_meta("persistent_id", encounter[0])
	if index == 9:
		world.create_kunai_gate("terrace_fire_cache", "fire", Vector2(2110, 810), 280)
		world.create_kunai_gate(RETURN_GATE, "electric", Vector2(360, 620), 280)

func interact(world) -> bool:
	if world.room == 8 and world.player.position.distance_to(Vector2(2060, 1300)) < 100:
		world.player.hp = 3
		world.checkpoint_room = 8
		world.checkpoint_position = Vector2(2060, 1298)
		world.save_progress()
		world.announce("Undercroft shrine restored. Journey saved.")
		return true
	var portal = Vector2(160, 620) if world.room == 9 else Vector2(2250, 790)
	if world.room in [3, 9] and world.player.position.distance_to(portal) < 100:
		if not world.opened_kunai_gates.get(RETURN_GATE, false):
			world.announce("Open the Electric return seal from Signal Terrace.", 4)
		elif world.room == 9:
			world.request_room(3, Vector2(2100, 788))
		else:
			world.request_room(9, Vector2(480, 618))
		return true
	return false

func update_progress(world):
	for fragment in FRAGMENTS.get(world.room, []):
		if world.relay_fragments.get(fragment.id, false): continue
		if not fragment.gate.is_empty() and not world.opened_kunai_gates.get(fragment.gate, false): continue
		if world.player.position.distance_to(fragment.at) < 75:
			world.relay_fragments[fragment.id] = true
			world.save_progress()
			world.announce("Relay sigil recovered • %d / 3" % world.relay_fragments.size(), 5)

func draw_room(world):
	var font = ThemeDB.fallback_font
	for fragment in FRAGMENTS.get(world.room, []):
		if world.relay_fragments.get(fragment.id, false): continue
		world.draw_circle(fragment.at - Vector2(0, 16), 15, Color("d8dda3"))
		world.draw_arc(fragment.at - Vector2(0, 16), 23, 0, TAU, 24, Color("9bc5a0"), 2)
		world.draw_string(font, fragment.at + Vector2(-54, -50), "RELAY SIGIL", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("e6dcc4"))
	if world.room == 8:
		world.draw_circle(Vector2(2060, 1250), 24, Color("b4c895"))
		world.draw_string(font, Vector2(1920, 1195), "UNDERCROFT SHRINE • E", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("e6dcc4"))
	if world.room in [3, 9]:
		var at = Vector2(160, 620) if world.room == 9 else Vector2(2250, 790)
		var opened = world.opened_kunai_gates.get(RETURN_GATE, false)
		world.draw_door(at, Color("9bc5a0") if opened else Color("5ec8ee"))
		world.draw_string(font, at + Vector2(-105, -165), "ECHO RETURN • E" if world.room == 9 else "TERRACE RETURN • E", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("e6dcc4"))
