extends RefCounted
## ART-06 R18 Pump Gallery dressing (PROPOSED runtime module, not wired into gameplay).
## Presentation only: draws textures inside/behind existing colliders, never adds
## bodies, shapes, anchors, gates or route data. Layout and collider registration
## come from res://assets/art06/r18/r18_layout.json (validated by
## tools/art06/validate_layout.py against the native collider dump).
##
## Hook points (see docs/art/art06/IMPLEMENTATION_HANDOFF.md):
##   RoomPresentation.draw_background(w)  -> R18Dressing.draw_back(w)
##   world._draw platform loop            -> if not R18Dressing.draw_surface(w, rect): LevelGeometry.draw_surface(w, rect)
##   world.build_room(index) end          -> R18Dressing.room_loaded(w)
const ROOM := 18
const DIR := "res://assets/art06/r18/"
const SELF_PATH := "res://tools/art06/proposed/r18_dressing.gd"  # update when moved into scripts/
const BACK_LAYERS := ["bg_far", "bg_wall", "bg_props", "support", "gate_dressing"]
const SUPPORT_DARKEN := 0.85
static var _layout: Dictionary = {}
static var _tex: Dictionary = {}

static func enabled(w) -> bool:
	return w.room == ROOM and FileAccess.file_exists(DIR + "r18_layout.json")

static func layout() -> Dictionary:
	if _layout.is_empty():
		_layout = JSON.parse_string(FileAccess.get_file_as_string(DIR + "r18_layout.json"))
	return _layout

static func tex(name: String) -> Texture2D:
	if not _tex.has(name): _tex[name] = load(DIR + name + ".png")
	return _tex[name]

static func _rect(a: Array) -> Rect2:
	return Rect2(a[0], a[1], a[2], a[3])

static func _mod(m) -> Color:
	return Color(m[0], m[1], m[2], m[3]) if m is Array else Color.WHITE

static func _tile_h(w: CanvasItem, t: Texture2D, r: Rect2, c := Color.WHITE):
	# Horizontal repeat clipped exactly to r.size.x; height scaled to r.size.y.
	var s := r.size.y / t.get_height()
	var step := t.get_width() * s
	var x := 0.0
	while x < r.size.x - 0.01:
		var cw := minf(step, r.size.x - x)
		w.draw_texture_rect_region(t, Rect2(r.position + Vector2(x, 0), Vector2(cw, r.size.y)), Rect2(0, 0, cw / s, t.get_height()), c)
		x += step

static func _pier(w: CanvasItem, t: Texture2D, x: float, top: float, bottom: float, width: float, c: Color):
	# Fixed capital/plinth, repeated shaft: piers stretch to any height without smearing.
	var s := width / t.get_width()
	var cap := 24.0; var base := 56.0
	var h := bottom - top
	if h <= (cap + base) * s:
		w.draw_texture_rect_region(t, Rect2(x, top, width, h), Rect2(0, t.get_height() - h / s, t.get_width(), h / s), c); return
	w.draw_texture_rect_region(t, Rect2(x, top, width, cap * s), Rect2(0, 0, t.get_width(), cap), c)
	var mid := Rect2(0, cap, t.get_width(), t.get_height() - cap - base)
	var y := top + cap * s
	while y < bottom - base * s - 0.01:
		var seg := minf(mid.size.y * s, bottom - base * s - y)
		w.draw_texture_rect_region(t, Rect2(x, y, width, seg), Rect2(0, cap, t.get_width(), seg / s), c)
		y += mid.size.y * s
	w.draw_texture_rect_region(t, Rect2(x, bottom - base * s, width, base * s), Rect2(0, t.get_height() - base, t.get_width(), base), c)

static func _prop(w: CanvasItem, p: Dictionary):
	var r := _rect(p.rect); var t := tex(p.asset); var c := _mod(p.get("modulate"))
	if p.get("tile", false): _tile_h(w, t, r, c); return
	if p.get("flip_h", false):
		w.draw_set_transform(Vector2(r.position.x * 2 + r.size.x, 0), 0, Vector2(-1, 1))
		w.draw_texture_rect(t, r, false, c)
		w.draw_set_transform(Vector2.ZERO)
	else:
		w.draw_texture_rect(t, r, false, c)

## Everything behind the walking plane. Called from RoomPresentation.draw_background,
## i.e. after the district background and BEFORE platforms, gates, anchors, doors.
static func draw_back(w):
	if not enabled(w): return
	var L := layout()
	for layer in BACK_LAYERS:
		if layer == "support":
			var dark := Color(SUPPORT_DARKEN, SUPPORT_DARKEN, SUPPORT_DARKEN)
			for s in L.supports:
				if s.has("x"): _pier(w, tex(s.asset), s.x, s.top, s.bottom, s.w, dark)
				else: w.draw_texture_rect(tex(s.asset), _rect(s.rect), false, dark)
		for p in L.props:
			if p.layer == layer: _prop(w, p)

## Replaces LevelGeometry.draw_surface for R18 colliders listed in the layout.
## Returns false for any rectangle not in the contract so the default draw still runs
## (a missing entry stays visible as placeholder instead of silently disappearing).
static func draw_surface(w, rect: Rect2) -> bool:
	if not enabled(w): return false
	for s in layout().surfaces:
		var r := _rect(s.rect)
		if r.position.is_equal_approx(rect.position) and r.size.is_equal_approx(rect.size):
			var t := tex(s.tile)
			var h := 140.0 if s.id == "floor" else float(t.get_height())
			_tile_h(w, t, Rect2(rect.position, Vector2(rect.size.x, h)))
			return true
	return false

## Foreground occluders live on their own node so they draw above Kaze and enemies.
## Parented to w.geometry, which build_room() already clears on every room change.
static func room_loaded(w):
	if not enabled(w): return
	var fg := Foreground.new(); fg.name = "ART06_R18_Foreground"; fg.z_index = 20
	fg.dressing = load(SELF_PATH)
	w.geometry.add_child(fg)

class Foreground extends Node2D:
	var dressing
	func _draw():
		for p in dressing.layout().props:
			if p.layer == "fg_occluder": dressing._prop(self, p)
