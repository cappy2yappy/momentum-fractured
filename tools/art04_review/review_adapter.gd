extends "res://scripts/embodied_transitions.gd"
## Review fixture only. Run against the pinned PR27 source, not the art branch game.
var art04 = false
var show_stairs = false
var stairs_at = Vector2.ZERO
var art_textures = {
	"roof": preload("res://assets/art04/environment/r14_roof_support.png"),
	"arch": preload("res://assets/art04/environment/r15_masonry_support.png"),
	"stairs": preload("res://assets/art04/environment/stair_flight_right.png"),
	"r14_door_interior": preload("res://assets/art04/environment/r14_door_interior.png"),
	"r14_door_back": preload("res://assets/art04/environment/r14_door_back.png"),
}

func draw_dressing(w):
	if not art04:
		super.draw_dressing(w)
		return
	if w.room == 14:
		w.draw_texture_rect(art_textures.roof, Rect2(706,922,488,186), false)
		if show_stairs:
			w.draw_texture_rect(art_textures.stairs,Rect2(stairs_at,Vector2(384,89.6)),false)
	elif w.room == 15:
		w.draw_texture_rect(art_textures.arch,Rect2(1292,970,456,338),false)

func draw_exit(w, at: Vector2) -> bool:
	if art04 and show_stairs and w.room == 14 and at == Vector2(1450,480):
		w.draw_string(ThemeDB.fallback_font,at+Vector2(-110,-132),"ART-04 / CONTACT KEY FIXTURE",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("d9ccb5"))
		return true
	if art04 and w.room == 14 and at == Vector2(120,1100):
		for part in ["r14_door_interior", "r14_door_back"]:
			w.draw_texture_rect(art_textures[part],Rect2(at-Vector2(120,208),Vector2(208,224)),false)
		return true
	return super.draw_exit(w,at)
