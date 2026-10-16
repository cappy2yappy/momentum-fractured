extends RefCounted
## LD03: a recoverable service walk below the unchanged roof route.
## Rectangles are both the collision source and the visible masonry silhouette.
const Terrain = preload("res://assets/web/terrain-materials.png")
const SOLIDS = [
	Rect2(520,1220,180,80),
	Rect2(750,1110,120,190),Rect2(1030,1110,120,190),
	Rect2(1200,1220,200,80),
	Rect2(1780,1220,200,80),Rect2(2000,1120,180,180),
]
const STEPS = [
	Rect2(240,1200,240,40),
	Rect2(1420,1120,240,40),Rect2(1480,980,240,40),
	Rect2(2200,1040,280,40),Rect2(2280,930,260,40),
	Rect2(2340,1200,260,40),
]
const LOG_POSITION = Vector2(1300,1220)
const ZONES = [
	{"id":"west_return","bounds":Rect2(0,1100,520,200),"purpose":"recovery; return to Haven landing"},
	{"id":"support_bays","bounds":Rect2(520,1020,650,280),"purpose":"jump challenge; grounded architecture"},
	{"id":"log_court","bounds":Rect2(1170,1110,250,190),"purpose":"optional existing bellkeeper log; exploration"},
	{"id":"central_return","bounds":Rect2(1420,830,360,470),"purpose":"recovery; conventional return to roof"},
	{"id":"east_service","bounds":Rect2(1780,1120,420,180),"purpose":"jump challenge; fall recovery"},
	{"id":"east_return","bounds":Rect2(2200,830,400,470),"purpose":"recovery; return to Terrace approach"},
]
static func build(w):
	if w.room!=14: return
	for rect in SOLIDS: w.add_platform(rect)
	for rect in STEPS: w.add_platform(rect)

static func stage_checkpoint(w,at:Vector2) -> Vector2:
	if w.room!=14: return at
	var blocked=false
	for rect in SOLIDS:
		if rect.intersects(Rect2(at-Vector2(14,60),Vector2(28,60))): blocked=true
	if not blocked: return at
	# Historical R14 fixture saves may lie inside new masonry. Keep x and all
	# flags; stage feet above the overlapping mass with capsule head clearance.
	var result=at
	for i in w.platforms.size():
		var previous=result
		for rect in w.platforms:
			if rect.intersects(Rect2(result-Vector2(14,60),Vector2(28,60))): result.y=minf(result.y,rect.position.y-2)
		if result==previous: break
	return result

static func draw_backdrop(w):
	# Recessed service wall: visibly dark, behind the actual platforms and player.
	# No opaque building blocks across the playable lower floor.
	for x in range(0,2600,400):
		w.draw_texture_rect_region(Terrain,Rect2(x,1190,minf(400,2600-x),110),Rect2(512,300,minf(400,2600-x),110),Color(0.3,0.34,0.4,0.68))
		w.draw_rect(Rect2(x+44,1210,72,70),Color("171e29"))
	# Thin background ties connect roof masses without pretending to be floors.
	for pair in [[Vector2(1200,830),Vector2(1410,1040)],[Vector2(1910,870),Vector2(2030,1120)]]:
		w.draw_line(pair[0],pair[1],Color("4b4c5a"),6)
	var font=ThemeDB.fallback_font
	for sign in [[Vector2(170,1155),"WEST RETURN"],[Vector2(1440,1070),"ROOF ACCESS"],[Vector2(2190,1180),"EAST STAIRS"]]:
		w.draw_rect(Rect2(sign[0]-Vector2(8,20),Vector2(154,28)),Color("242936"))
		w.draw_string(font,sign[0],sign[1],HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("d6c5a3"))
	w.draw_string(font,Vector2(40,1255),"BELLKEEPER SERVICE WALK",HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("a8b4b6"))
	for at in [Vector2(430,1160),Vector2(1540,1080),Vector2(2330,1000)]:
		w.draw_line(at,at+Vector2(0,24),Color("5b5c65"),4)
		w.draw_circle(at,5,Color("e4c18a"))
	# The unchanged optional lore pickup now occupies a deliberate lower alcove.
	w.draw_rect(Rect2(1235,1150,130,70),Color("293443"))
	w.draw_rect(Rect2(1244,1157,112,57),Color("74818a"),false,3)
	w.draw_string(font,Vector2(1212,1130),"BELLKEEPER LOG",HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("dfd0b1"))
