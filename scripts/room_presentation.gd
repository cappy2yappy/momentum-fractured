extends RefCounted
# Noninteractive architecture. Never add these silhouettes to physics geometry.
# Bounded visual map; coordinates/targets/requirements come only from existing portals.
const PILOT_STYLES = {14: "rooftop", 15: "masonry"}
static func exit_style(index: int) -> String:
	return PILOT_STYLES.get(index, "")

static func pilot_portal(w, at: Vector2) -> Dictionary:
	if exit_style(w.room).is_empty(): return {}
	for portal in w.expansion.portals(w.room):
		if portal.at == at: return portal
	return {}

static func draw_exit(w, at: Vector2, color: Color):
	var portal = pilot_portal(w, at)
	if not portal.is_empty():
		draw_pilot_exit(w, at, portal)
		return
	draw_legacy_exit(w, at, color)

static func draw_legacy_exit(w, at: Vector2, color: Color):
	# Creator-requested modest size increase; feet anchor and activation stay unchanged.
	w.draw_rect(Rect2(at + Vector2(-56,-7),Vector2(112,14)),Color("565461"))
	w.draw_rect(Rect2(at + Vector2(-40,-108),Vector2(80,108)),Color("262535"))
	w.draw_rect(Rect2(at + Vector2(-30,-96),Vector2(60,89)),Color("171523"))
	w.draw_rect(Rect2(at + Vector2(-30,-96),Vector2(60,89)),color,false,3)
	w.draw_line(at+Vector2(-46,-108),at+Vector2(46,-108),Color("aaa18b"),5)
	w.draw_circle(at+Vector2(0,-53),11,color)
	w.draw_line(at+Vector2(-10,-53),at+Vector2(10,-53),Color("e6dcc4"),2)
	w.draw_string(ThemeDB.fallback_font,at+Vector2(-5,-18),"E",HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("e6dcc4"))

static func draw_background(w):
	var size=w.room_size(w.room)
	var font=ThemeDB.fallback_font
	if w.room==14:
		# Distant stepped roofs and antenna masts frame the horizontal roof route.
		w.draw_rect(Rect2(0,0,size.x,560),Color(0.12,0.12,0.20,0.28))
		for x in range(100,2500,390):
			w.draw_rect(Rect2(x,700,230,600),Color("272634"))
			w.draw_line(Vector2(x-30,700),Vector2(x+115,630),Color("60576a"),7)
			w.draw_line(Vector2(x+115,630),Vector2(x+260,700),Color("60576a"),7)
			w.draw_line(Vector2(x+80,630),Vector2(x+80,460),Color("474454"),5)
		w.draw_string(font,Vector2(1340,580),"UPPER WATCH",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("c4bda4"))
	elif w.room==15:
		# Retaining arches, canal depth bands and pipework behind the dry descent.
		for y in [420,680,940,1200]:
			w.draw_line(Vector2(40,y),Vector2(size.x-40,y),Color("354850"),12)
		for x in range(180,2100,420):
			w.draw_arc(Vector2(x,1250),150,PI,TAU,32,Color("465b62"),14)
			w.draw_line(Vector2(x-150,1250),Vector2(x-150,780),Color("2c3c43"),18)
		w.draw_string(font,Vector2(680,570),"DRY SERVICE ROUTE",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("b2c0b5"))
	elif w.room==17:
		# Two distant cable shafts and numbered landings reveal climb scale.
		for x in [430,1450]:
			w.draw_rect(Rect2(x-45,300,90,1650),Color("1f2530"))
			w.draw_line(Vector2(x,240),Vector2(x,1970),Color("60606a"),4)
		for y in [1800,1450,1100,750,400]:
			w.draw_line(Vector2(120,y),Vector2(1680,y),Color(0.34,0.36,0.43,0.35),5)
			w.draw_string(font,Vector2(140,y-30),"LIFT %02d" % (1+int((1800-y)/350)),HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color("999a9e"))
	elif w.room==19:
		# Coil bays and insulated conduit distinguish this from the canal/shrine.
		for x in range(240,2300,400):
			w.draw_rect(Rect2(x-80,420,160,830),Color("232936"))
			for y in range(480,1180,100):
				w.draw_arc(Vector2(x,y),55,0,TAU,24,Color("3d4e5b"),8)
		w.draw_line(Vector2(100,360),Vector2(2250,360),Color("667077"),10)
		w.draw_string(font,Vector2(1410,660),"UPPER SERVICE",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("a9bcc4"))
	# Route plaques sit beside existing portals, not at new destinations.
	if w.room in [14,15,17,19]:
		for p in w.expansion.portals(w.room):
			var at=p.at
			w.draw_rect(Rect2(at+Vector2(-62,-218 if w.room in PILOT_STYLES else -146),Vector2(124,30)),Color("23242f"))
			w.draw_string(font,at+Vector2(-54,-198 if w.room in PILOT_STYLES else -126),"ROUTE %02d"%p.target,HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("d7c9a6"))

# All artwork is procedural, noninteractive placeholder architecture.
static func draw_pilot_exit(w, at: Vector2, portal: Dictionary):
	var unlocked = w.expansion.allowed(w, portal.need)
	var near = w.player.position.distance_to(at) < 85
	var cue = Color("f4db96") if unlocked else Color("d49b87")
	var font = ThemeDB.fallback_font
	w.draw_rect(Rect2(at+Vector2(-86,-8),Vector2(172,16)),Color("55535e"))
	w.draw_line(at+Vector2(-86,-8),at+Vector2(86,-8),Color("ddd0ad"),4)
	if exit_style(w.room) == "rooftop":
		# Lit service stairwell: roof cap, solid uprights, recessed stairs and lamp.
		w.draw_rect(Rect2(at+Vector2(-74,-180),Vector2(148,174)),Color("343443"))
		w.draw_rect(Rect2(at+Vector2(-53,-153),Vector2(106,145)),Color("10151e"))
		w.draw_rect(Rect2(at+Vector2(-82,-190),Vector2(164,16)),Color("817982"))
		w.draw_line(at+Vector2(-53,-153),at+Vector2(53,-153),cue,5)
		for i in 5:
			w.draw_rect(Rect2(at+Vector2(-43,-20-i*19),Vector2(86-i*9,6)),Color("59616b"))
		w.draw_line(at+Vector2(42,-26),at+Vector2(12,-119),Color("9c9c9e"),3)
		w.draw_rect(Rect2(at+Vector2(-14,-176),Vector2(28,10)),cue)
	else:
		# Masonry tunnel: a filled recess bounded by thick segmented voussoirs.
		w.draw_rect(Rect2(at+Vector2(-55,-112),Vector2(110,104)),Color("0e1921"))
		w.draw_circle(at+Vector2(0,-112),55,Color("0e1921"))
		for side in [-1,1]:
			for y in 4:
				w.draw_rect(Rect2(at+Vector2(side*67-12,-106+y*25),Vector2(24,23)),Color("63777a"))
		for i in 9:
			var a = PI + float(i)*PI/9.0
			w.draw_arc(at+Vector2(0,-112),67,a,a+PI/9.0-0.025,5,Color("7c8c8b"),23,true)
		w.draw_arc(at+Vector2(0,-112),53,PI,TAU,24,cue,3,true)
		w.draw_line(at+Vector2(-52,-112),at+Vector2(-52,-8),cue,3)
		w.draw_line(at+Vector2(52,-112),at+Vector2(52,-8),cue,3)
	# Neutral warm cues never imitate the green/blue/red elemental seal geometry.
	w.draw_rect(Rect2(at+Vector2(-32,-143),Vector2(64,34)),Color("202532"))
	if unlocked:
		w.draw_string(font,at+Vector2(-23,-119),"E  >",HORIZONTAL_ALIGNMENT_LEFT,-1,22,cue)
	else:
		w.draw_rect(Rect2(at+Vector2(-10,-132),Vector2(20,17)),cue,false,3)
		w.draw_arc(at+Vector2(0,-132),7,PI,TAU,12,cue,3)
	var label = "E · ENTER" if unlocked and near else ("APPROACH" if unlocked else "LOCKED · "+portal.need.to_upper())
	w.draw_rect(Rect2(at+Vector2(-104,18),Vector2(208,28)),Color("202532"))
	w.draw_string(font,at+Vector2(-96,38),label,HORIZONTAL_ALIGNMENT_LEFT,-1,16,cue)
	if unlocked and near:
		w.draw_line(at+Vector2(-43,-5),at+Vector2(43,-5),cue,6)

static func uses_pilot_transition(w) -> bool:
	return w.transition > 0 and (w.pending_from_room in PILOT_STYLES or w.room in PILOT_STYLES or w.pending_room in PILOT_STYLES)

static func draw_transition(h, w, alpha: float) -> bool:
	if not uses_pilot_transition(w): return false
	# No player mutation, shader, timer, particles or persistent visual state.
	var still = "--tr01-reduced-motion" in OS.get_cmdline_user_args()
	var center = w.player.get_global_transform_with_canvas().origin - Vector2(0,55)
	if still:
		h.draw_arc(center,36,PI*0.15,PI*1.65,24,Color(0.96,0.86,0.65,alpha),3,true)
	else:
		for i in 3:
			var radius = 28.0+i*17.0+alpha*24.0
			var angle = (0.65-w.transition)*7.0+i*1.5
			h.draw_arc(center,radius,angle,angle+PI*1.1,24,Color(0.83,0.91,0.91,alpha*0.8),3,true)
	h.draw_string(ThemeDB.fallback_font,Vector2(520,550),"WIND THROUGH THE PASSAGE",HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color(0.96,0.86,0.65,alpha))
	return true
