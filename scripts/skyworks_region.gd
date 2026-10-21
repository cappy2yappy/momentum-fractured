extends RefCounted
const Keeper = preload("res://scripts/storm_keeper.gd")
const LAYOUTS = {
	10: [Rect2(0, 830, 300, 40), Rect2(350, 1040, 800, 40), Rect2(920, 830, 300, 40), Rect2(1400, 620, 360, 40), Rect2(1780, 810, 360, 40), Rect2(2240, 760, 360, 40)],
	11: [Rect2(0, 760, 310, 40), Rect2(420, 980, 600, 40), Rect2(1100, 780, 380, 40), Rect2(1500, 560, 400, 40), Rect2(2010, 760, 590, 40), Rect2(920, 560, 240, 40)],
	12: [Rect2(80, 830, 480, 40), Rect2(580, 1070, 320, 40), Rect2(1040, 850, 350, 40), Rect2(1700, 1030, 340, 40), Rect2(2180, 880, 300, 40)],
}

func build_room(world, index):
	for rect in LAYOUTS[index]: world.add_platform(rect)
	var anchors = {10: [Vector2(620, 560), Vector2(1220, 460), Vector2(1880, 480), Vector2(2320, 420)], 11: [Vector2(700, 560), Vector2(1300, 460), Vector2(1940, 460)], 12: [Vector2(760, 790), Vector2(1230, 590), Vector2(1870, 730)]}
	world.tether_anchors.assign(anchors[index])
	if index == 10:
		spawn_sentinel(world, "skyworks_sentinel", Vector2(800, 1040))
		world.create_kunai_gate("skyworks_wind_intake", "wind", Vector2(2110, 810), 280)
	elif index == 11:
		spawn_sentinel(world, "foundry_sentinel", Vector2(1100, 1300))
		world.create_kunai_gate("foundry_electric_relay", "electric", Vector2(2370, 760), 300)
	elif not world.cleared_encounters.get("storm_keeper", false):
		var keeper = world.spawn_enemy(Vector2(1320, 1300), true, true, Keeper)
		keeper.phase_changed.connect(func(_phase): world.announce("The Keeper accelerates. Watch the ground pulse.", 4))

func spawn_sentinel(world, id, at):
	if world.cleared_encounters.get(id, false): return
	var enemy = world.spawn_enemy(at, false)
	enemy.set_meta("persistent_id", id)

func interact(world) -> bool:
	if world.room == 11 and world.player.position.distance_to(Vector2(1720, 1300)) < 100:
		world.player.hp = 3
		world.checkpoint_room = 11
		world.checkpoint_position = Vector2(1720, 1298)
		world.save_progress()
		world.announce("Foundry Rest Station restored. The Keeper waits east.", 5)
		return true
	if world.room == 12 and world.player.position.distance_to(Vector2(2220, 1300)) < 120:
		if not world.cleared_encounters.get("storm_keeper", false):
			world.announce("The Storm Keeper still protects the relay.", 4)
		else:
			world.skyworks_restored = true
			world.checkpoint_room = 12
			world.checkpoint_position = Vector2(2220, 1298)
			world.player.hp = 3
			world.save_progress()
			world.announce("SkyWorks attuned. The Undercroft return is open.", 9)
		return true
	if world.room in [8, 12]:
		var portal = Vector2(1470, 740) if world.room == 8 else Vector2(220, 830)
		if world.player.position.distance_to(portal) < 95:
			if not world.skyworks_restored:
				world.announce("Attune the Keeper Relay to open this return.", 4)
			else:
				world.request_room(12 if world.room == 8 else 8, Vector2(430, 828) if world.room == 8 else Vector2(1590, 738))
			return true
	return false

func draw_room(world):
	var font = ThemeDB.fallback_font
	if world.room == 11:
		world.draw_circle(Vector2(1720, 1250), 24, Color("b4c895"))
		world.draw_string(font, Vector2(1575, 1195), "FOUNDRY REST STATION • E", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("e6dcc4"))
	elif world.room == 12:
		world.draw_rect(Rect2(2170, 1120, 100, 180), Color("2e3c4f"))
		world.draw_rect(Rect2(2190, 1150, 60, 110), Color("d7b477"), false, 4)
		world.draw_string(font, Vector2(2100, 1060), "KEEPER RELAY • E", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("e6dcc4"))
	if world.room in [8, 12]:
		var at = Vector2(1470, 740) if world.room == 8 else Vector2(220, 830)
		world.draw_door(at, Color("9bc5a0") if world.skyworks_restored else Color("d7b477"))
		world.draw_string(font, at + Vector2(-100, -165), "KEEPER RETURN • E" if world.room == 8 else "UNDERCROFT • E", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("e6dcc4"))
