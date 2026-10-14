extends "res://scripts/world.gd"
# REVIEW-ONLY draw override; base gameplay source is untouched.
const CityPrototype = preload("res://assets/environment/alpha061/city_rooftop/city_rooftop_layered.svg")
const UndergroundPrototype = preload("res://assets/environment/alpha061/underground_approach/underground_approach_layered.svg")
func _draw():
	if not is_instance_valid(player): return
	var texture = CityPrototype if room == 14 else UndergroundPrototype
	draw_texture(texture, Vector2.ZERO)
	for rect in platforms:
		if rect.position.x < 0 or rect.position.x >= room_size(room).x: continue
		draw_rect(rect, Color("252631"))
		draw_rect(Rect2(rect.position, Vector2(rect.size.x, 7)), Color("aaa18b"))
		draw_rect(Rect2(rect.position + Vector2(0, 7), Vector2(rect.size.x, 9)), Color("54535c"))
	for gate in kunai_gates:
		if opened_kunai_gates.get(gate["id"], false): continue
		var color = {"wind": Color("79d69a"), "fire": Color("ed7852"), "electric": Color("5ec8ee")}[gate["element"]]
		var rect = Rect2(gate["position"] - Vector2(15, gate["height"]), Vector2(30, gate["height"]))
		draw_rect(rect, Color(color, 0.18))
		draw_rect(rect, color, false, 4)
		for y in range(int(rect.position.y) + 18, int(rect.end.y), 34): draw_line(Vector2(rect.position.x, y), Vector2(rect.end.x, y + 16), Color(color, 0.75), 3)
	if room == 2:
		for rect in [Rect2(640, 1260, 290, 180), Rect2(1350, 1260, 330, 180), Rect2(2200, 1260, 180, 180)]: draw_water(rect)
	elif room == 4:
		for rect in [Rect2(450, 1260, 550, 180), Rect2(1280, 1260, 770, 180)]: draw_water(rect)
	elif room == 5:
		for rect in [Rect2(500, 1260, 280, 180), Rect2(1500, 1260, 350, 180)]: draw_water(rect)
	for anchor in grapple_candidates():
		var in_range = player.tether_unlocked and player.can_tether_anchor(anchor)
		var pulse = 3.0 + sin(player.age * 7.0) * 2.0 if in_range else 0.0
		draw_circle(anchor, 25 + pulse, Color(0.68, 0.9, 0.57, 0.12 if in_range else 0.07))
		draw_arc(anchor, 20 + pulse, 0, TAU, 28, Color("d5ffb4") if in_range else Color("93b982"), 4 if in_range else 3)
		draw_circle(anchor, 7, Color("e9ffd6") if in_range else Color("a5ca90"))
		draw_line(anchor - Vector2(12, 0), anchor + Vector2(12, 0), Color("d5ffb4"), 2)
		draw_line(anchor - Vector2(0, 12), anchor + Vector2(0, 12), Color("d5ffb4"), 2)
	if tether_effect_time > 0:
		draw_tether_effect()
	if room > 0 and room < 13: draw_door(left_exit_position())
	if room < 12: draw_door(right_exit_position())
	if room == 0:
		draw_rect(Rect2(190, 1256, 60, 44), Color("63516e"));draw_circle(Vector2(220, 1237), 18, Color("c8d69f"))
		draw_string(ThemeDB.fallback_font, Vector2(105, 1185), "CANAL HAVEN", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("e6dcc4"))
	elif room == 1 and not player.double_jump:
		draw_circle(Vector2(1580, 1240), 22, Color("b8c68b") if guard_defeated else Color("665a70"))
		draw_string(ThemeDB.fallback_font, Vector2(1505, 1188), "WINDSTEP", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("e6dcc4"))
	elif room == 2 and not secret:
		draw_rect(Rect2(2284, 815, 32, 20), Color("e9d8b5"))
	elif room == 3:
		draw_circle(Vector2(1320, 1242), 34, Color("7e69a0"));draw_circle(Vector2(1320, 1242), 18, Color("c8d69f"))
		draw_string(ThemeDB.fallback_font, Vector2(1235, 1178), "WIND TETHER", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("e6dcc4"))
	elif room == 4 and not player.kunai_unlocked["fire"]:
		draw_circle(Vector2(1080, 980), 20, Color("ed7852"));draw_string(ThemeDB.fallback_font, Vector2(1010, 940), "FIRE KUNAI", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("ffd4b3"))
	elif room == 5:
		draw_circle(Vector2(1320, 1242), 30, Color("8cb6ca"));draw_line(Vector2(1288, 1242), Vector2(1352, 1242), Color("e4f5ff"), 5)
		draw_string(ThemeDB.fallback_font, Vector2(1255, 1178), "GALE DASH", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("e6dcc4"))
		if not player.kunai_unlocked["electric"]:
			draw_circle(Vector2(1510, 880), 20, Color("5ec8ee"));draw_string(ThemeDB.fallback_font, Vector2(1415, 840), "ELECTRIC KUNAI", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("d4f5ff"))
	elif room == 7:
		draw_rect(Rect2(2140, 1080, 120, 220), Color("2e3c4f"));draw_rect(Rect2(2160, 1110, 80, 120), Color("9bc5a0"), false, 5)
		draw_string(ThemeDB.fallback_font, Vector2(2080, 1035), "RELAY CONTROL", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("e6dcc4"))
	extension.draw_room(self)
	expansion.draw_room(self)
	draw_string(ThemeDB.fallback_font, Vector2(980, 260), ROOM_NAMES[room], HORIZONTAL_ALIGNMENT_CENTER, 640, 32, Color(0.9, 0.84, 0.75, 0.55))

