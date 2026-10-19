extends RefCounted
## LEVEL pilot: Room 13 left exit enclosure (Mooring Loft -> Canal Haven).
## Visible solid masonry only: a back pier and a gatehouse mass whose underside is the
## hallway ceiling. The graph point (120,1200), the trigger and the landing are unchanged.
## Numbers are the published contract in docs/pm_pilot/CANAL_CONTRACT.md.
const ROOM = 13
const DOOR_X = 120.0
const FLOOR_Y = 1200.0
const APERTURE = Rect2(72,1068,96,132)
const CEILING_Y = 1020.0
const PIER = Rect2(0,1020,72,180)
const MASS = Rect2(0,0,296,1020)
const HALL = Rect2(72,1020,224,180)

static func active(w) -> bool:
	return w.room == ROOM

static func build(w):
	# Neither rect is 40 px thick, so add_platform keeps both fully solid.
	w.add_platform(PIER)
	w.add_platform(MASS)

static func owns(index:int, rect:Rect2) -> bool:
	return index == ROOM and (rect == PIER or rect == MASS)

static func tile(w, rect:Rect2, tint:Color):
	# Same approved blue masonry tile the R13 shelves use, repeated inside the collider silhouette.
	var Terrain = preload("res://assets/web/terrain-materials.png")
	var y = int(rect.position.y)
	while y < rect.end.y:
		var h = minf(512.0,rect.end.y - y)
		var x = int(rect.position.x)
		while x < rect.end.x:
			var wd = minf(512.0,rect.end.x - x)
			w.draw_texture_rect_region(Terrain,Rect2(x,y,wd,h),Rect2(512,0,wd,h),tint)
			x += 512
		y += 512

static func suppresses_silhouette(index:int, box:Rect2) -> bool:
	return index == ROOM and box.intersects(MASS)

static func draw(w):
	if not active(w): return
	var edge = Color("a9a58c")
	# L0 hall back wall (rear plane): the same masonry, pushed dark so the hall reads as recessed.
	tile(w,HALL,Color(0.30,0.32,0.42))
	# L2 gatehouse mass, then the lintel course and its shadow on the hall.
	tile(w,MASS,Color(0.62,0.66,0.80))
	w.draw_rect(Rect2(72,968,224,52),Color(0.08,0.09,0.14,0.45))
	w.draw_rect(Rect2(72,960,224,6),Color(0.66,0.68,0.78,0.85))
	w.draw_line(Vector2(72,1021),Vector2(296,1021),edge,5)
	for i in 5:
		w.draw_rect(Rect2(72,1023 + i * 8,224,8),Color(0.02,0.03,0.06,0.34 - i * 0.07))
	w.draw_line(Vector2(296,0),Vector2(296,1020),Color("14161e"),5)
	w.draw_line(Vector2(292,0),Vector2(292,1020),Color(0.7,0.72,0.8,0.25),2)
	# L3 back pier at the hallway's rear end.
	tile(w,PIER,Color(0.62,0.66,0.80))
	w.draw_line(Vector2(72,1020),Vector2(72,1200),Color("14161e"),5)
	w.draw_line(Vector2(76,1020),Vector2(76,1200),Color(0.7,0.72,0.8,0.22),2)
