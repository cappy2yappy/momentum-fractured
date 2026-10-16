extends RefCounted
const Terrain = preload("res://assets/web/terrain-materials.png")
## TR-04: perimeter landing repairs only. No route, gate or controller policy.
const LANDINGS = {
	2:[Vector2(2440,850)],4:[Vector2(2440,1080)],9:[Vector2(2440,810)],
	13:[Vector2(120,1200),Vector2(1680,560)],
	14:[Vector2(120,1100),Vector2(2440,830)],
	15:[Vector2(120,500),Vector2(2080,1120)],
	16:[Vector2(120,1120),Vector2(1880,760)],
	17:[Vector2(120,1900),Vector2(1680,1300)],
	18:[Vector2(120,1000),Vector2(2440,760)],
	19:[Vector2(120,760),Vector2(2280,980)],
	20:[Vector2(120,760),Vector2(2080,1120)],
}
static func perimeter_landing(index:int, size:Vector2, rect:Rect2) -> Rect2:
	if rect.size.y!=40: return rect
	for at in LANDINGS.get(index,[]):
		if rect.position.y!=at.y or at.x<rect.position.x-80 or at.x>rect.end.x+80: continue
		if at.x<=160:
			return Rect2(0,rect.position.y,rect.end.x,rect.size.y)
		if at.x>=size.x-200:
			return Rect2(rect.position,Vector2(size.x-rect.position.x,rect.size.y))
	return rect

static func legacy_arrival(index:int, at:Vector2) -> Vector2:
	# R10 -> R9: the historical door is 20px below the solid shelf top.
	# Correct only this implicit loader spawn, never saved or explicit positions.
	if index==9 and at==Vector2(2300,828): return Vector2(2300,808)
	return at

static func draw_surface(w,rect:Rect2):
	# Reuse the approved material atlas inside the actual collider silhouette.
	# Caps mark walkable tops; this adds no decorative collision or fake animation.
	var tile=Vector2(0,0)
	if w.room in [0,1,2,13,14,15]: tile=Vector2(512,0)
	elif w.room in [16,18,20]: tile=Vector2(1024,0)
	elif w.room in [10,11,19]: tile=Vector2(0,512)
	elif w.room in [6,7,12]: tile=Vector2(1024,512)
	for offset in range(0,int(rect.size.x),512):
		var width=minf(512,rect.size.x-offset)
		w.draw_texture_rect_region(Terrain,Rect2(rect.position+Vector2(offset,0),Vector2(width,rect.size.y)),Rect2(tile+Vector2(0,96),Vector2(width,rect.size.y)),Color(0.72,0.75,0.8))
	w.draw_rect(Rect2(rect.position,Vector2(rect.size.x,5)),Color("a9a58c"))
	w.draw_line(rect.position+Vector2(0,5),Vector2(rect.position.x,rect.end.y),Color("555a64"),3)
	w.draw_line(Vector2(rect.end.x,rect.position.y+5),rect.end,Color("30343e"),3)
