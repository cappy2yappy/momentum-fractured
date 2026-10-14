extends RefCounted
# Noninteractive architecture. Never add these silhouettes to physics geometry.
static func draw_exit(w, at: Vector2, color: Color):
	w.draw_rect(Rect2(at + Vector2(-48,-7),Vector2(96,14)),Color("565461"))
	w.draw_rect(Rect2(at + Vector2(-32,-84),Vector2(64,84)),Color("262535"))
	w.draw_rect(Rect2(at + Vector2(-24,-72),Vector2(48,65)),Color("171523"))
	w.draw_rect(Rect2(at + Vector2(-24,-72),Vector2(48,65)),color,false,3)
	w.draw_line(at+Vector2(-38,-84),at+Vector2(38,-84),Color("aaa18b"),5)
	w.draw_circle(at+Vector2(0,-39),9,color)
	w.draw_line(at+Vector2(-8,-39),at+Vector2(8,-39),Color("e6dcc4"),2)
	w.draw_string(ThemeDB.fallback_font,at+Vector2(-5,-16),"E",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("e6dcc4"))

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
			w.draw_rect(Rect2(at+Vector2(-62,-128),Vector2(124,30)),Color("23242f"))
			w.draw_string(font,at+Vector2(-54,-108),"ROUTE %02d"%p.target,HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("d7c9a6"))
