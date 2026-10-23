extends RefCounted
## LD-05: intentional world boundaries. Visible, solid architecture only; no invisible barriers.
##  1. ROOF COURSE: every room gets a structural masonry/girder course along its top edge (y 0..COURSE_H, wall to wall).
##     Before this the room had a left wall, a right wall and a floor but no top, so a chain of wall jumps up any wall
##     (or a double jump from a high ledge) left the world (docs/pm_pilot/EXIT_AUDIT.md finding 3). The course is the
##     room's top: its collider is the drawn rectangle (plus an off-screen backing so its top face is unreachable).
##  2. SHELF SEATS: the R8 shelf under the R18 depth door ends 28 px short of the drawn door; it is extended.
##  3. R13 QUAY FOOTING: the 60 px crawlspace below the Canal hallway pad (x 0..360) is filled with a visible plinth.
##  4. DOOR SEATING: doors whose logical endpoint is 20 px off the walkable top (R6->R7, R9->R10) are DRAWN on the
##     surface Kaze stands on. Endpoints, triggers, saves and every platform rectangle stay exactly as they were.
## Nothing here touches w.platforms except the R8 shelf (same index, 40 px wider), so the approved eight-room
## signature, the Canal contract rectangles and the QA r13 platform diff are unchanged.
const LevelGeometry = preload("res://scripts/level_geometry.gd")
const Terrain = preload("res://assets/web/terrain-materials.png")
const OpenTop = preload("res://scripts/open_top_boundary.gd")
const COURSE_H = 56.0
const BACKING_TOP = -640.0
## Single switch. false = the pre-LD-05 open-top rooms, for A/B comparison or if the creator rejects the course.
static var ROOF_ENABLED = true
## R0..R7 are the creator-approved foundation. The course never edits their platform list; this switch lets the creator
## keep their top edge open while the new rooms stay closed.
static var ORIGINAL_ROOMS_ENABLED = true
## [new rect, left edge of the shelf it continues] (the texture phase continues from that shelf)
const EXTENSIONS = {8: [[Rect2(1110,920,40,40),770.0]]}
const FOOTINGS = {13: [Rect2(0,1240,360,60)]}
const DOOR_SEAT_RANGE = 24.0
## GN-01: the R6 -> R7 walk-through trigger only fires for feet y <= endpoint y + 8, but the shelf under the door is 20 px
## lower, so a walking Kaze never opened the exit. A visible stone sill (20 px rise over 50 px) lifts the walkable top at the
## door to the endpoint line. Polygon points are room pixels; "door" is the endpoint it seats.
## The ramp rises 16 px in its first 22 px so the walk-through arming window (feet within 90..-8 px of the endpoint and at
## least 16 px before it) is 17 px wide at run speed, not 4 px.
const SILLS = {6: {"poly": [Vector2(2390,1116),Vector2(2390,1110),Vector2(2412,1094),Vector2(2440,1090),Vector2(2600,1090),Vector2(2600,1116)], "door": Vector2(2440,1090), "phase": 2020.0}}
## GN-02: the legacy pits in R2, R4 and R5 are drawn as water whose surface sits 40 px ABOVE the floor lip they cut, so a
## pit reads as a raised wall instead of a drop. The collider is unchanged; only the drawn water surface moves below the lip.
static var PIT_WATER_ALIGNED = true
## false (or --ld05-no-sill) restores the pre-GN-01 shelf: the R6 -> R7 exit does not open for a walking Kaze.
static var SILLS_ENABLED = true
const PIT_WATER_TOP = 1372.0

static func roof_active(index:int) -> bool:
	if index in OpenTop.ROOMS:
		if "--ld08-before" in OS.get_cmdline_user_args(): return false
		if "--ld08-roof-reference" in OS.get_cmdline_user_args(): return true
		if OpenTop.active(index): return false
	if not ROOF_ENABLED or "--ld05-open-top" in OS.get_cmdline_user_args(): return false
	if index < 8 and not ORIGINAL_ROOMS_ENABLED: return false
	return true

static func roof_rect(w) -> Rect2:
	var size = w.room_size(w.room)
	return Rect2(-40,BACKING_TOP,size.x + 80,COURSE_H - BACKING_TOP)

static func solid(w, rect:Rect2):
	var body = StaticBody2D.new()
	var shape = CollisionShape2D.new()
	var box = RectangleShape2D.new();box.size = rect.size
	shape.shape = box;shape.position = rect.get_center()
	body.add_child(shape);w.geometry.add_child(body)
	w.boundary_rects.append(rect)

static func build_roof(w):
	w.boundary_rects.clear()
	w.boundary_polys.clear()
	if roof_active(w.room): solid(w,roof_rect(w))
	OpenTop.build(w)

static func sill_active(index:int) -> bool:
	return SILLS.has(index) and SILLS_ENABLED and not "--ld05-no-sill" in OS.get_cmdline_user_args()

static func solid_poly(w, points:PackedVector2Array):
	var body = StaticBody2D.new()
	var shape = CollisionPolygon2D.new()
	shape.polygon = points
	body.add_child(shape);w.geometry.add_child(body)
	var lo = points[0];var hi = points[0]
	for p in points:
		lo = Vector2(minf(lo.x,p.x),minf(lo.y,p.y));hi = Vector2(maxf(hi.x,p.x),maxf(hi.y,p.y))
	w.boundary_rects.append(Rect2(lo,hi - lo))
	w.boundary_polys.append(points)

static func build(w):
	# Seat extensions and footings: separate visible solids. They never edit or replace a platform rectangle.
	for rect in EXTENSIONS.get(w.room,[]): solid(w,rect[0])
	for rect in FOOTINGS.get(w.room,[]): solid(w,rect)
	if sill_active(w.room): solid_poly(w,PackedVector2Array(SILLS[w.room].poly))

static func pit_rect(rect:Rect2) -> Rect2:
	if not PIT_WATER_ALIGNED or "--ld05-legacy-water" in OS.get_cmdline_user_args(): return rect
	return Rect2(rect.position.x,PIT_WATER_TOP,rect.size.x,rect.end.y - PIT_WATER_TOP)

static func tile_for(index:int) -> Vector2:
	if index in [0,1,2,13,14,15]: return Vector2(512,0)
	if index in [16,18,20]: return Vector2(1024,0)
	if index in [10,11,19]: return Vector2(0,512)
	if index in [6,7,12]: return Vector2(1024,512)
	return Vector2(0,0)

static func masonry(w, rect:Rect2, tint:Color, phase:float = 0.0):
	var tile = tile_for(w.room)
	for offset in range(0,int(rect.size.x),512):
		var width = minf(512,rect.size.x - offset)
		w.draw_texture_rect_region(Terrain,Rect2(rect.position + Vector2(offset,0),Vector2(width,rect.size.y)),Rect2(tile + Vector2(fmod(phase + offset,512.0 - width),96),Vector2(width,rect.size.y)),tint)

static func draw(w):
	var size = w.room_size(w.room)
	OpenTop.draw(w)
	for pair in EXTENSIONS.get(w.room,[]):
		# Continue the neighbouring shelf: repaint its right edge shade, then the same masonry, cap and end shade.
		var rect:Rect2 = pair[0]
		var over = Rect2(rect.position.x - 4,rect.position.y,rect.size.x + 4,rect.size.y)
		masonry(w,over,Color(0.72,0.75,0.8),over.position.x - pair[1])
		w.draw_rect(Rect2(over.position.x,over.position.y,over.size.x,5),Color("a9a58c"))
		w.draw_line(Vector2(rect.end.x,rect.position.y + 5),rect.end,Color("30343e"),3)
	for rect in FOOTINGS.get(w.room,[]):
		masonry(w,rect,Color(0.50,0.54,0.66))
		w.draw_line(Vector2(rect.position.x,rect.position.y + 1),Vector2(rect.end.x,rect.position.y + 1),Color("30343e"),3)
		w.draw_line(Vector2(rect.end.x,rect.position.y),rect.end,Color("30343e"),3)
	if sill_active(w.room): draw_sill(w,SILLS[w.room])
	if not roof_active(w.room): return
	# R13: the gatehouse mass already owns x 0..296 of the top edge.
	var x0 = 296.0 if w.room == 13 else 0.0
	var course = Rect2(x0,0,size.x - x0,COURSE_H)
	masonry(w,course,Color(0.62,0.64,0.74))
	w.draw_rect(Rect2(course.position.x,COURSE_H - 8,course.size.x,8),Color(0.05,0.06,0.10,0.55))
	w.draw_line(Vector2(course.position.x,COURSE_H),Vector2(course.end.x,COURSE_H),Color("a9a58c"),4)
	for i in 6:
		w.draw_rect(Rect2(course.position.x,COURSE_H + 2 + i * 7,course.size.x,7),Color(0.02,0.03,0.06,0.30 - i * 0.05))
	# Bearing joints every 400 px so the course reads as laid stone, not a bar.
	var x = 400.0
	while x < size.x:
		if x > x0: w.draw_line(Vector2(x,2),Vector2(x,COURSE_H - 6),Color(0.05,0.06,0.10,0.5),3)
		x += 400.0

static func draw_sill(w, sill:Dictionary):
	var pts = PackedVector2Array(sill.poly)
	var tile = tile_for(w.room)
	var uvs = PackedVector2Array()
	var size = Terrain.get_size()
	for p in pts: uvs.append((tile + Vector2(fposmod(p.x - sill.phase,400.0),96.0 + (p.y - sill.door.y))) / size)
	w.draw_polygon(pts,PackedColorArray([Color(0.72,0.75,0.8)]),uvs,Terrain)
	# cap along the slope and the flat, then the shaded end face like every other shelf
	for i in range(1,pts.size() - 2): w.draw_line(pts[i] + Vector2(0,2),pts[i + 1] + Vector2(0,2),Color("a9a58c"),5)
	w.draw_line(pts[pts.size() - 2],pts[pts.size() - 1],Color("30343e"),3)

## Door seat: how far the DRAWN door must move so its feet rest on the walkable top it stands over.
static func seat_offset(w, at:Vector2) -> float:
	var size = w.room_size(w.room)
	if sill_active(w.room) and SILLS[w.room].door == at: return 0.0 # the sill is the support: the door already stands on it
	for r in w.platforms:
		if r.position.x < 0 or r.position.x >= size.x: continue
		if at.x - 48 < r.position.x or at.x + 48 > r.end.x: continue
		var d = r.position.y - at.y
		if d != 0.0 and absf(d) <= DOOR_SEAT_RANGE: return d
	return 0.0

## Background rails, arches and roof lines are scenery. Drawn dim and dashed (couplings) so they cannot be read as ledges.
static func scenery_line(w, a:Vector2, b:Vector2, color:Color, width:float = 5.0):
	var c = Color(color.r,color.g,color.b,color.a * 0.40)
	var length = a.distance_to(b)
	var dir = (b - a) / maxf(length,1.0)
	var d = 0.0
	while d < length:
		w.draw_line(a + dir * d,a + dir * minf(d + 56.0,length),c,width)
		d += 70.0

static func scenery_arc(w, center:Vector2, radius:float, from:float, to:float, color:Color, width:float = 6.0):
	w.draw_arc(center,radius,from,to,32,Color(color.r,color.g,color.b,color.a * 0.35),width)
