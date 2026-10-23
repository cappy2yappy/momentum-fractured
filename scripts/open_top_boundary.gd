extends RefCounted
## LD-08 creator-review geometry. Open sky between solid, visibly drawn side structures.
## Both renderer and collision consume the same rectangles. No player/control changes.
static var ENABLED = true
const ROOMS = [13, 17]
const CAMERA_TOP = -800
const TOP = -800.0
const SOFFIT = -240.0
const PROJECTION = 384.0

static func active(index: int) -> bool:
	return ENABLED and index in ROOMS and not "--ld08-roof-reference" in OS.get_cmdline_user_args() and not "--ld08-before" in OS.get_cmdline_user_args()

static func pieces(index: int) -> Array[Rect2]:
	if not index in ROOMS: return []
	var west_face = 296.0 if index == 13 else 0.0
	return [
		Rect2(-40, SOFFIT, west_face + 40, -SOFFIT),
		Rect2(-40, TOP, west_face + 40 + PROJECTION, SOFFIT - TOP),
		Rect2(1800, SOFFIT, 40, -SOFFIT),
		Rect2(1800 - PROJECTION, TOP, PROJECTION + 40, SOFFIT - TOP),
	]

static func build(w):
	# Reset on every room load so the expanded sky view cannot leak into other rooms.
	w.camera.limit_top = CAMERA_TOP if active(w.room) else 0
	if not active(w.room): return
	for rect in pieces(w.room): w.RoomBoundary.solid(w, rect)

static func draw_background(w):
	if not active(w.room): return
	for y in range(CAMERA_TOP, 0, 8):
		var weight = float(y - CAMERA_TOP) / float(-CAMERA_TOP)
		w.draw_rect(Rect2(0, y, 1800, 8), Color("111522").lerp(Color("30253f"), weight))
	# Blend the existing distant sky into the new height; always behind solid architecture.
	for y in range(0, 96, 4):
		w.draw_rect(Rect2(0, y, 1800, 4), Color(0.188, 0.145, 0.247, 1.0 - float(y) / 96.0))

static func draw(w):
	if not active(w.room): return
	var stone = w.room == 13
	var visible_pieces = pieces(w.room)
	# Give the existing side-wall colliders the same skin so the upper stories read
	# as supported architecture, including when review cameras show the outer edges.
	for rect in w.platforms:
		if rect.position.x < 0 or rect.position.x >= w.room_size(w.room).x: visible_pieces.append(rect)
	for rect in visible_pieces:
		if stone: w.Expansion.CanalGatehouse.tile(w, rect, Color(0.62, 0.66, 0.80))
		else: w.draw_rect(rect, Color("384956"))
		w.draw_rect(rect, Color("a0a3af") if stone else Color("97b5b9"), false, 3)
		if stone:
			for x in range(int(rect.position.x) + 40, int(rect.end.x) - 24, 128):
				w.draw_rect(Rect2(x, rect.position.y + 12, 16, rect.size.y - 24), Color(0.08, 0.10, 0.16, 0.3))
		else:
			for x in range(int(rect.position.x) + 18, int(rect.end.x) - 12, 52):
				w.draw_rect(Rect2(x, rect.position.y + 8, 12, rect.size.y - 16), Color("25323f"))
			for y in range(int(rect.position.y) + 24, int(rect.end.y), 96):
				w.draw_line(Vector2(rect.position.x + 4, y), Vector2(rect.end.x - 4, y), Color("607781"), 8)
		# The bright underside is the actual collision face, not a detached decoration.
		w.draw_line(Vector2(rect.position.x, rect.end.y - 4), rect.end - Vector2(0, 4), Color("b8aa88") if stone else Color("92b0b2"), 6)
