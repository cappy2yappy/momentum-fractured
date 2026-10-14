extends RefCounted
# Feature-scoped policy. No graph, save or player-controller ownership here.
const WALK = {15: {"target":16,"direction":1},16:{"target":15,"direction":-1}}
const SPECIAL = {20:13,13:20}
var previous = Vector2.ZERO
var sampled = false
var armed = false
var cooldown = 0.75
var active_walk = false
var active_special = false
var carried_x = 0.0
var direction = 1
var destination = ""
var graphic_mode = "graphic"

func configure(w):
	var args=OS.get_cmdline_user_args()
	# Explicit QA save override: schema/API/default creator save path stay unchanged.
	for arg in args:
		if arg.begins_with("--tr02-save="):
			var path=arg.trim_prefix("--tr02-save=")
			if path.is_absolute_path(): w.save_path=path
	if "--tr02-plain" in args: graphic_mode="plain"
	if "--tr02-reduced-motion" in args or "--tr01-reduced-motion" in args: graphic_mode="reduced"

func walk_portal(w) -> Dictionary:
	if not w.room in WALK: return {}
	for p in w.expansion.portals(w.room):
		if p.target==WALK[w.room].target: return p
	return {}

func is_walk(index:int,target:int) -> bool:
	return index in WALK and WALK[index].target==target

func is_special(index:int,target:int) -> bool:
	return index in SPECIAL and SPECIAL[index]==target

func room_loaded(w):
	sampled=false;armed=false;cooldown=0.75
	if w.transition<=0: clear_effect(w)

func clear_effect(w):
	active_walk=false;active_special=false;carried_x=0
	w.camera.offset.x=0

func cancel(w):
	clear_effect(w);sampled=false;armed=false;cooldown=0.75

func begin(w,target:int):
	# Called only AFTER world.can_enter accepted the request.
	active_special=is_special(w.room,target)
	if not active_walk and not active_special: return
	destination=w.ROOM_NAMES[target]
	if active_special: direction=w.player.facing

func arrived(w):
	if active_walk: w.player.velocity=Vector2(carried_x,0)
	cooldown=0.75;sampled=false;armed=false
	w.camera.offset.x=0

func update(w,dt:float):
	if w.transition>0:
		sampled=false
		if (active_walk or active_special) and graphic_mode=="graphic":
			var shift=direction*20.0*clampf((0.65-w.transition)/0.32,0,1) if w.pending_room>=0 else 0.0
			var center=w.camera.get_screen_center_position().x-w.camera.offset.x
			var half=640.0/w.camera.zoom.x
			w.camera.offset.x=clampf(shift,minf(0,half-center),maxf(0,w.room_size(w.room).x-half-center))
		return
	if active_walk or active_special: clear_effect(w)
	cooldown=maxf(0,cooldown-dt)
	var p=walk_portal(w)
	if p.is_empty() or not w.player.is_physics_processing(): sampled=false;return
	var pos=w.player.position
	if not sampled: previous=pos;sampled=true;return
	var dir=int(WALK[w.room].direction)
	var before=(previous.x-p.at.x)*dir
	var after=(pos.x-p.at.x)*dir
	var corridor=pos.y>=p.at.y-90 and pos.y<=p.at.y+8 and previous.y>=p.at.y-90 and previous.y<=p.at.y+8
	if cooldown<=0 and after<=-96 and corridor: armed=true
	var crosses=armed and cooldown<=0 and before<0 and after>=0 and corridor and w.player.velocity.x*dir>20 and not w.player.tether_attached
	previous=pos
	if not crosses: return
	armed=false
	if not w.can_enter(p.target):
		w.announce("PASSAGE LOCKED - RESTORE THE ARCHIVE.",3);return
	active_walk=true;direction=dir;carried_x=w.player.velocity.x
	w.request_room(p.target,p.arrival)
	if w.pending_room!=p.target: clear_effect(w)

func label(w,p:Dictionary) -> String:
	if is_walk(w.room,p.target): return w.ROOM_NAMES[p.target]+" - WALK THROUGH"
	if is_special(w.room,p.target): return w.ROOM_NAMES[p.target]+" - E WIND-FOLD"
	return w.ROOM_NAMES[p.target]+" - E"

func draw_exit(w,at:Vector2) -> bool:
	for p in w.expansion.portals(w.room):
		if p.at!=at: continue
		var walk=is_walk(w.room,p.target)
		var special=is_special(w.room,p.target)
		if not walk and not special: return false
		var allowed=w.expansion.allowed(w,p.need)
		var cue=Color("d9bba9") if allowed else Color("c48781")
		if walk:
			# Full-height culvert recess with load-bearing side architecture (art only).
			w.draw_rect(Rect2(at+Vector2(-66,-204),Vector2(132,204)),Color("14202b"))
			w.draw_line(at+Vector2(-78,-204),at+Vector2(-78,0),Color("69777b"),16)
			w.draw_line(at+Vector2(78,-204),at+Vector2(78,0),Color("69777b"),16)
			w.draw_line(at+Vector2(-86,-212),at+Vector2(86,-212),Color("8a9290"),16)
			w.draw_line(at+Vector2(-84,-5),at+Vector2(84,-5),cue,5)
			var dir=int(WALK[w.room].direction)
			w.draw_line(at+Vector2(-25*dir,-54),at+Vector2(25*dir,-54),cue,4)
			w.draw_polyline(PackedVector2Array([at+Vector2(8*dir,-69),at+Vector2(25*dir,-54),at+Vector2(8*dir,-39)]),cue,4)
			if not allowed:
				for x in range(-45,46,18): w.draw_line(at+Vector2(x,-184),at+Vector2(x,-12),cue,3)
		else:
			w.draw_rect(Rect2(at+Vector2(-76,-8),Vector2(152,16)),Color("60596e"))
			var center=at+Vector2(0,-88)
			w.draw_circle(center,68,Color("202136"))
			for radius in [46,61,74]: w.draw_arc(center,radius,PI*0.12,PI*1.92,48,cue,3,true)
			w.draw_line(center+Vector2(-26,20),center+Vector2(30,-24),Color("ce90a5"),5)
			w.draw_string(ThemeDB.fallback_font,at+Vector2(-46,-174),"WIND-FOLD",HORIZONTAL_ALIGNMENT_LEFT,-1,16,cue)
			w.draw_string(ThemeDB.fallback_font,at+Vector2(-6,-25),"E",HORIZONTAL_ALIGNMENT_LEFT,-1,20,cue)
		var text="WALK THROUGH" if walk else "E - WIND-FOLD"
		if not allowed: text="LOCKED - "+p.need.to_upper()
		w.draw_string(ThemeDB.fallback_font,at+Vector2(-90,36),text,HORIZONTAL_ALIGNMENT_LEFT,-1,14,cue)
		return true
	return false

func draw_transition(h,w,alpha:float) -> bool:
	if not active_walk and not active_special: return false
	var color=Color("d4b6ce")
	if graphic_mode=="graphic":
		var t=clampf(((0.65-w.transition)-0.1)/0.44,0,1)
		for i in 3:
			var x=lerpf(-760,1500,t) if direction>0 else lerpf(1500,-760,t)
			x+=i*190*direction
			var y=140+i*110
			h.draw_colored_polygon(PackedVector2Array([Vector2(x,y),Vector2(x+460,y-50),Vector2(x+650,y+90),Vector2(x+130,y+130)]),Color(0.20+0.12*i,0.16,0.31+0.06*i,alpha*0.88))
			h.draw_line(Vector2(x+40,y+20),Vector2(x+480,y-15),Color(0.82,0.51,0.62,alpha),4,true)
	# Static badge in plain/reduced mode; stays clear of upper HUD and bottom controls.
	h.draw_rect(Rect2(410,480,460,54),Color(0.08,0.08,0.17,alpha*0.9))
	h.draw_string(ThemeDB.fallback_font,Vector2(430,514),("→ " if direction>0 else "← ")+destination,HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color(color,alpha))
	return true
