extends Node2D
## LD-05 capture-only annotation (never shipped, no collision). Draws the live collider set of the current room:
## solid = teal outline, one-way = gold, boundary/roof = magenta, anchors = green, endpoints = red with target.
var world
func _draw():
	if world == null: return
	var size = world.room_size(world.room)
	for r in world.platforms:
		var one_way = world.room >= 13 and r.size.y == 40 and r.position.x >= 0
		var boundary = r.position.x < 0 or r.position.x >= size.x or r.position.y < 0
		var col = Color(1,0.3,0.9,0.9) if boundary else (Color(0.95,0.8,0.3,0.95) if one_way else Color(0.3,0.9,0.9,0.95))
		draw_rect(r,col,false,4)
		draw_rect(r,Color(col.r,col.g,col.b,0.10))
	if "boundary_rects" in world:
		for r in world.boundary_rects:
			draw_rect(r,Color(1,0.3,0.9,0.9),false,4);draw_rect(r,Color(1,0.3,0.9,0.10))
	for a in world.tether_anchors: draw_circle(a,12,Color(0.4,1,0.4,0.9))
	for p in world.cinematic_transitions.endpoints(world,world.room):
		draw_line(p.at + Vector2(0,-150),p.at + Vector2(0,10),Color(1,0.2,0.2,0.95),4)
		draw_string(ThemeDB.fallback_font,p.at + Vector2(-30,-160),"->R%d %s" % [p.target,p.mode],HORIZONTAL_ALIGNMENT_LEFT,-1,28,Color(1,0.5,0.5))
	draw_rect(Rect2(Vector2.ZERO,size),Color(1,1,1,0.5),false,3)
