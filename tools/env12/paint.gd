extends Node2D
## One cosmetic layer. Geometry, progression and gameplay clocks are read-only.
var study
var kind = 0
func _ready():
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
func _process(_delta): queue_redraw()
func _draw():
	if study == null or not study.art_on or not study.layer_enabled[kind]: return
	var palette = study.palette
	if kind == 0:
		# Atmospheric glazing is clipped away from every solid and protected read.
		for area in study.air_cells:
			draw_rect(area,Color(palette[0],0.035))
		for item in study.far_details:
			var r: Rect2 = item
			# Slender faded ribs: no horizontal landing silhouette.
			draw_line(r.position+Vector2(r.size.x*0.5,0),r.end-Vector2(r.size.x*0.5,0),Color(palette[1],0.08),6)
			draw_arc(r.get_center(),r.size.x*0.3,PI*1.05,PI*1.95,20,Color(palette[1],0.06),3)
	elif kind == 1:
		for r in study.recesses:
			draw_rect(r,Color(palette[0],0.38))
			var inset = r.grow(-8)
			if inset.size.x>0 and inset.size.y>0:
				draw_rect(inset,Color(palette[1],0.26),false,2)
				for x in range(int(inset.position.x)+12,int(inset.end.x),72):
					draw_line(Vector2(x,inset.position.y),Vector2(x,inset.end.y),Color(palette[2],0.16),2)
	elif kind == 2:
		for r in study.faces:
			draw_rect(r,Color(palette[1],0.18))
			# Surface is only an inlay INSIDE actual collision, never a new top.
			for x in range(int(r.position.x)+28,int(r.end.x)-10,96):
				draw_line(Vector2(x,r.position.y+4),Vector2(x,r.end.y-3),Color(palette[0],0.3),1)
				draw_circle(Vector2(x+5,r.position.y+5),1.5,Color(palette[2],0.46))
	elif kind == 3:
		for item in study.decor:
			if item.type == 'asset':
				study.bank.paint(self,item.id,item.at,study.motion_time,Color(palette[2],0.78),study.reduced_motion)
			elif item.type == 'cord':
				var r: Rect2 = item.rect
				var sway = 0.0 if study.reduced_motion else sin(study.motion_time*0.8)*3.0
				draw_polyline(PackedVector2Array([r.position+Vector2(8,0),r.position+Vector2(8+sway,r.size.y*0.55),r.position+Vector2(8,r.size.y)]),Color(palette[2],0.38),2,true)
			elif item.type == 'lamp':
				var r: Rect2 = item.rect
				var alpha = 0.12 if study.reduced_motion else 0.12+sin(study.motion_time*0.7)*0.015
				draw_circle(r.get_center(),r.size.x/2,Color(1,0.72,0.36,alpha))
				draw_circle(r.get_center(),3,Color(1,0.78,0.48,0.7))
		# B is a manual gallery-only preview, never hooked to a gameplay event.
		if study.response_time>0 and study.response_rect.size.x>0:
			var t=1.8-study.response_time
			var r: Rect2=study.response_rect
			for i in 6:
				var at=r.position+Vector2(8+i*7,10+t*12)
				draw_circle(at,1.2,Color(palette[2],0.35*study.response_time/1.8))
