extends RefCounted
# Append-only LD-01 rooms. Portal endpoints are feet coordinates, not sprite centers.
const Anchor = preload("res://scripts/grapple_anchor.gd")
const SIZES = {13: Vector2(1800,1440), 14: Vector2(2600,1440), 15: Vector2(2200,1440), 16: Vector2(2000,1440), 17: Vector2(1800,2160), 18: Vector2(2600,1440), 19: Vector2(2400,1440), 20: Vector2(2200,1440)}
const NAMES = ["MOORING LOFT", "BELLROOF WALK", "LOWER SLUICE", "ROOT SHRINE", "COUNTERWEIGHT SPIRE", "PUMP GALLERY", "COIL SERVICE HALL", "RELAY JUNCTION"]
const COLORS = [Color("292434"), Color("302b3b"), Color("1b2a30"), Color("26352e"), Color("282c39"), Color("30352e"), Color("30313f"), Color("29372f")]
const COORDS = [Vector3i(-1,2,0),Vector3i(-1,1,0),Vector3i(2,3,0),Vector3i(3,3,0),Vector3i(4,2,0),Vector3i(4,3,0),Vector3i(5,3,0),Vector3i(5,2,0)]
const REGIONS = ["CANAL WARD","CANAL WARD","CANAL WARD","ROOT CONSERVATORY","ECHO WORKS","ROOT CONSERVATORY","SKYWORKS","ROOT CONSERVATORY"]
# Shared prerequisites apply in BOTH directions. No edge writes story progress.
const EDGES = [
	{"a":0,"b":13,"pa":Vector2(590,780),"pb":Vector2(120,1200),"need":"windstep"},
	{"a":13,"b":14,"pa":Vector2(1680,560),"pb":Vector2(120,1100),"need":"windstep"},
	{"a":14,"b":9,"pa":Vector2(2440,830),"pb":Vector2(1100,1040),"need":"relay"},
	{"a":14,"b":17,"pa":Vector2(1450,480),"pb":Vector2(1680,1300),"need":"climb"},
	{"a":5,"b":17,"pa":Vector2(2240,930),"pb":Vector2(120,1900),"need":"climb"},
	{"a":17,"b":20,"pa":Vector2(1500,420),"pb":Vector2(120,760),"need":"spire"},
	{"a":2,"b":15,"pa":Vector2(470,1120),"pb":Vector2(120,500),"need":"sluice"},
	{"a":15,"b":16,"pa":Vector2(2080,1120),"pb":Vector2(120,1120),"need":"relay"},
	{"a":16,"b":8,"pa":Vector2(1880,760),"pb":Vector2(550,1110),"need":"relay"},
	{"a":16,"b":18,"pa":Vector2(1000,430),"pb":Vector2(120,1000),"need":"relay"},
	{"a":18,"b":8,"pa":Vector2(1200,1180),"pb":Vector2(1090,920),"need":"relay"},
	{"a":18,"b":19,"pa":Vector2(2440,760),"pb":Vector2(120,760),"need":"pump"},
	{"a":19,"b":11,"pa":Vector2(2280,980),"pb":Vector2(890,980),"need":"regional"},
	{"a":19,"b":20,"pa":Vector2(1800,480),"pb":Vector2(2080,1120),"need":"coil"},
	{"a":20,"b":13,"pa":Vector2(600,520),"pb":Vector2(900,400),"need":"junction"},
]
# Ordered ordinary landing path, bottom to top. Intermediate stairs keep rises <=180.
const SHELVES = {
	13:[Rect2(200,1160,400,40),Rect2(720,940,360,40),Rect2(1220,720,400,40),Rect2(1400,560,360,40),Rect2(600,480,500,40),Rect2(300,440,400,40),Rect2(740,400,320,40)],
	14:[Rect2(100,1100,500,40),Rect2(650,1020,300,40),Rect2(750,900,400,40),Rect2(1190,830,320,40),Rect2(1590,830,320,40),Rect2(1900,830,650,40),Rect2(1560,660,340,40),Rect2(1300,480,380,40),Rect2(1300,720,450,40)],
	15:[Rect2(1800,1120,350,40),Rect2(1570,1080,300,40),Rect2(1320,940,400,40),Rect2(1020,830,300,40),Rect2(720,720,450,40),Rect2(470,610,300,40),Rect2(80,500,500,40)],
	16:[Rect2(80,1120,500,40),Rect2(700,900,450,40),Rect2(1300,760,650,40),Rect2(780,500,500,40),Rect2(840,430,320,40)],
	17:[Rect2(80,1900,520,40),Rect2(520,1780,320,40),Rect2(720,1660,400,40),Rect2(960,1480,340,40),Rect2(1200,1300,550,40),Rect2(940,1170,320,40),Rect2(650,1040,450,40),Rect2(830,900,320,40),Rect2(1100,760,450,40),Rect2(1440,590,300,40),Rect2(1200,420,450,40)],
	18:[Rect2(1040,1180,320,40),Rect2(80,1000,500,40),Rect2(700,800,500,40),Rect2(2000,760,550,40),Rect2(1380,620,450,40)],
	19:[Rect2(1850,980,500,40),Rect2(1370,980,400,40),Rect2(700,980,500,40),Rect2(430,870,300,40),Rect2(80,760,450,40),Rect2(670,760,320,40),Rect2(1050,760,320,40),Rect2(1370,760,450,40),Rect2(1850,640,300,40),Rect2(1550,520,600,40),Rect2(1640,480,320,40)],
	20:[Rect2(1400,1120,750,40),Rect2(750,900,450,40),Rect2(80,760,500,40),Rect2(350,560,500,40),Rect2(440,520,320,40)],
}
const ANCHORS = {13:[Vector2(900,690)],14:[Vector2(820,620),Vector2(1460,430),Vector2(2090,550)],15:[Vector2(960,480),Vector2(1550,660)],16:[Vector2(950,630),Vector2(1530,470)],17:[Vector2(900,1400),Vector2(950,780),Vector2(1320,250)],18:[Vector2(930,510),Vector2(1650,340),Vector2(2220,460)],19:[Vector2(890,670),Vector2(1580,430)],20:[Vector2(900,520),Vector2(1650,700)]}
const GATES = {15:["lower_sluice_wind","wind",Vector2(500,500)],17:["spire_wind_shutter","wind",Vector2(1430,420)],18:["pump_electric_isolator","electric",Vector2(2370,760)],19:["coil_fire_service","fire",Vector2(1730,480)]}
const LORE = {14:Vector2(1300,1220),15:Vector2(390,500),16:Vector2(1500,760),17:Vector2(1370,420),18:Vector2(1690,620),19:Vector2(1960,520),20:Vector2(1800,1120)}
const NOTES = {14:"Bellkeepers marked this roof as the convoy's quiet route.",15:"Inspection ledger: the lower pumps ran dry before the evacuation.",16:"Roots hold the old shrine together. Someone still tends its lamps.",17:"Counterweights once carried workers above the storm line.",18:"The pumps feed both the canal and the conservatory.",19:"Service crews isolated the coils before the Keeper arrived.",20:"The relay garden links the roof watch to the maintenance crews."}
var hazards: Array = []
var route_steps: Array = []

func portals(index: int) -> Array:
	var result = []
	for e in EDGES:
		if index == e.a: result.append({"at":e.pa,"target":e.b,"arrival":e.pb - Vector2(0,2),"need":e.need})
		elif index == e.b: result.append({"at":e.pb,"target":e.a,"arrival":e.pa - Vector2(0,2),"need":e.need})
	return result

func allowed(w, need: String) -> bool:
	match need:
		"windstep": return w.player.double_jump
		"relay": return w.completed
		"climb": return w.player.tether_unlocked and w.player.dash_unlocked
		"sluice": return w.player.kunai_unlocked.wind and w.opened_kunai_gates.get("cistern_wind_cache",false)
		"spire": return w.completed and w.player.tether_unlocked and w.player.dash_unlocked and w.opened_kunai_gates.get("spire_wind_shutter",false)
		"regional": return regional(w)
		"pump": return regional(w) and w.opened_kunai_gates.get("pump_electric_isolator",false)
		"coil": return regional(w) and w.opened_kunai_gates.get("coil_fire_service",false)
		"junction": return regional(w) and w.expansion_flags.get("junction_return",false)
	return false

func regional(w) -> bool:
	return w.completed and w.has_required_sigils() and w.opened_kunai_gates.get("skyworks_wind_intake",false)

func build_room(w, index):
	hazards.clear();route_steps.clear()
	if index < 13: return
	var previous = Rect2(SHELVES[index][0].position.x, SIZES[index].y - 140, SHELVES[index][0].size.x,40)
	for shelf in SHELVES[index]:
		# Conservative conventional lane; optional bell swings skip these landings.
		var delta = shelf.get_center() - previous.get_center()
		var count = maxi(1,maxi(ceili(absf(delta.x)/300.0),ceili(absf(delta.y)/180.0)))
		for step in range(1,count):
			var center = previous.get_center().lerp(shelf.get_center(),float(step)/count)
			var stair = Rect2(center - Vector2(150,20),Vector2(300,40))
			w.add_platform(stair);route_steps.append(stair)
		w.add_platform(shelf);route_steps.append(shelf);previous = shelf
	for p in portals(index):
		var pad = Rect2(clampf(p.at.x-160,40,SIZES[index].x-360),p.at.y,320,40)
		# Shelves already include the landing when possible; no duplicate solid shapes.
		var supported = false
		for r in w.platforms:
			if absf(r.position.y-p.at.y)<1 and p.at.x>r.position.x+20 and p.at.x<r.end.x-20: supported = true
		if not supported: w.add_platform(pad)
	for at in ANCHORS[index]:
		var anchor = Anchor.new();anchor.position = at;w.geometry.add_child(anchor)
	if index in GATES:
		var g = GATES[index];w.create_kunai_gate(g[0],g[1],g[2],240)
	# Encounters occupy broad shelves, with explicit bounds and no arrival overlap.
	var lane = {13:Rect2(720,940,360,40),14:Rect2(750,900,400,40),15:Rect2(1320,940,400,40),18:Rect2(700,800,500,40),19:Rect2(700,980,500,40)}
	if index in lane and not w.cleared_encounters.get("expansion_guard_%d"%index,false):
		var r = lane[index];var enemy = w.spawn_enemy(Vector2(r.get_center().x,r.position.y),false)
		enemy.patrol_min = r.position.x+55;enemy.patrol_max = r.end.x-55
		enemy.set_meta("persistent_id","expansion_guard_%d"%index)
	# Telegraphing vents are confined to lower side bays; ordinary ledges bypass them.
	if index in [15,18,19]: hazards.append(Rect2(650,SIZES[index].y-230,80,90))

func interact(w) -> bool:
	if w.room == 16 and w.player.position.distance_to(Vector2(420,1120))<85:
		w.checkpoint_room=16;w.checkpoint_position=Vector2(420,1118);w.player.hp=3;w.save_progress();w.announce("Root Shrine restored. Journey saved.");return true
	if w.room == 20 and w.player.position.distance_to(Vector2(600,520))<85 and not w.expansion_flags.get("junction_return",false):
		if regional(w): w.expansion_flags["junction_return"]=true;w.save_progress();w.announce("Mooring return activated. The Haven loop is open.")
		else: w.announce("The junction needs Archive restoration, three named sigils and the Wind intake.")
		return true
	for p in portals(w.room):
		if w.mixed_transitions.is_walk(w.room,p.target) or w.cinematic_transitions.automatic(w,w.room,p.target): continue
		if w.player.position.distance_to(p.at)<85:
			if allowed(w,p.need): w.request_room(p.target,p.arrival)
			else: w.announce("Route sealed: "+p.need.replace("_"," ").to_upper()+". Consult the atlas.")
			return true
	return false

func update(w,dt):
	if w.room==13 and w.player.position.distance_to(Vector2(450,440))<65 and w.player.unlock_speed_upgrade("stride_1"):
		w.save_progress();w.announce("STRIDE I - Permanent movement +5%. Ordinary routes need no speed upgrade.",7)
	if w.room in LORE and not w.expansion_flags.get("lore_%d"%w.room,false) and w.player.position.distance_to(LORE[w.room])<65:
		if w.room!=15 or w.opened_kunai_gates.get("lower_sluice_wind",false):
			w.expansion_flags["lore_%d"%w.room]=true;w.save_progress();w.announce(NOTES[w.room],8)
	if fmod(w.player.age,4.0)>=3.0:
		for h in hazards:
			if h.has_point(w.player.position-Vector2(0,30)): w.player.damage(h.get_center())

func draw_room(w):
	var font=ThemeDB.fallback_font
	if w.room>=13:
		var size=SIZES[w.room]
		# Lightweight identity silhouettes: roofs, retaining arches, roots and pump drums.
		for x in range(140,int(size.x),440):
			if w.room==14: continue # LD03 uses grounded service-walk architecture.
			var at=Vector2(x,size.y-400)
			if w.embodied_transitions.production_art.suppresses_legacy(w.embodied_transitions,w.room,Rect2(at-Vector2(160,225),Vector2(390,385))): continue
			if w.room in [13,14,17]:
				w.draw_line(at-Vector2(100,220),at+Vector2(100,-120),Color("62566b"),9)
				w.draw_line(at+Vector2(100,-120),at+Vector2(220,-220),Color("62566b"),9)
			elif w.room in [15,19]: w.draw_arc(at,150,PI,TAU,32,Color("4a565d"),14)
			else:
				w.draw_circle(at,90,Color("37463d"));w.draw_arc(at,65,0,TAU,32,Color("5d6a57"),8)
		if w.room==13 and w.player.speed_upgrade_level==0:
			w.draw_circle(Vector2(450,408),18,Color("d5d5aa"));w.draw_string(font,Vector2(380,365),"STRIDE I",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("e6dcc4"))
		if w.room==16:
			w.draw_circle(Vector2(420,1070),24,Color("b4c895"));w.draw_string(font,Vector2(300,1020),"ROOT SHRINE - E",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("e6dcc4"))
		for h in hazards:
			var phase=fmod(w.player.age,4.0)
			w.draw_rect(h,Color(0.9,0.72,0.38,0.5 if phase>=3 else (0.2 if phase>=2 else 0.05)))
			w.draw_rect(Rect2(h.position.x,h.end.y-12,h.size.x,12),Color("c6a568"))
		if w.room in LORE and not w.expansion_flags.get("lore_%d"%w.room,false): w.draw_rect(Rect2(LORE[w.room]-Vector2(12,32),Vector2(24,18)),Color("ddceb0"))
	for p in portals(w.room):
		w.draw_door(p.at,Color("9bc5a0") if allowed(w,p.need) else Color("b88b66"))
		w.draw_string(font,p.at+Vector2(-100,-248 if w.room in [14,15] else -158),w.cinematic_transitions.label(w,p),HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("e6dcc4"))
