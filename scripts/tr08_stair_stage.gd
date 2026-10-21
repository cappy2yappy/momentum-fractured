extends Node
## TR-08: dedicated FULL-SCREEN staircase cinematic for the R14 Bellroof Walk <-> R17
## Counterweight Spire stair (both directions, default for that E interaction).
## E -> stage opens over the world (supporting wind-cloth wipe) -> the real room request is
## released while the stage is opaque (the inherited 0.65 s loader runs hidden beneath it)
## -> Kaze climbs or descends a staircase built from the clip root motion, at cinematic
## scale, with a following stage camera -> the stage closes (wipe) onto the destination
## room with the bottom destination label -> control returns.
## Never moves the collision body, never changes gates, graph, saves or the loader clock.
## Control ALWAYS returns: completion, pause, death, room rebuild, F6, watchdog.
const Data = preload("res://scripts/transition_pilot_data.gd")
const Library = preload("res://scripts/tr08_clip_library.gd")
const ClipPlayer = preload("res://scripts/tr08_clip_player.gd")
const Terrain = preload("res://assets/web/terrain-materials.png")
const District = preload("res://assets/web/district-fidelity.png")

var host
var world
var phase = ""          # "", "open", "climb", "close"
var key = ""
var source = -1
var target = -1
var arrival = Vector2.INF
var heading = 1         # screen travel direction on the stage
var rise = -1           # -1 ascend, +1 descend
var elapsed = 0.0
var cover_at = 0.30
var open_out = 0.30
var close_in = 0.30
var close_out = 0.25
var close_start = -1.0
var request_time = -1.0
var swap_time = -1.0
var releasing = false
var still = false
var rate = 1.0
var queue: Array = []
var planned: Array = []
var shown: Array = []    # [elapsed, clip, bound, provenance]
var current = ""
var feet = Vector2.ZERO
var path = PackedVector2Array()
var levels: Array = []   # [x_from, x_to, y_top] per level, stage px
var cam = Vector2.ZERO
var zoom = 1.0
var figure_px = 430.0
var started = 0
var completed = 0
var aborted = 0
var last_result = ""
var last_duration = 0.0
var destination = ""
var layer = CanvasLayer.new()
var back = Node2D.new()
var stage = Node2D.new()
var kaze = ClipPlayer.new()
var front = Node2D.new()

func configure(w,h):
	world=w;host=h
	name="Tr08StairStage"
	process_mode=Node.PROCESS_MODE_ALWAYS
	layer.layer=Data.TR08.stair.layer
	layer.process_mode=Node.PROCESS_MODE_ALWAYS
	layer.visible=false
	add_child(layer)
	for n in [back,stage,front]:
		n.process_mode=Node.PROCESS_MODE_ALWAYS;layer.add_child(n)
	back.draw.connect(draw_back);stage.draw.connect(draw_stage);front.draw.connect(draw_front)
	stage.add_child(kaze)

func applies(w,t:int) -> bool:
	return "%d:%d"%[w.room,t] in Data.TR08.stair_pairs

## Owns the accepted E request (world.request_room already passed can_enter).
func begin(w,t:int,at:Vector2):
	var cfg=Data.TR08.stair
	var pilot=w.embodied_transitions.PILOTS["%d:%d"%[w.room,t]]
	key="%d:%d"%[w.room,t];source=w.room;target=t;arrival=at
	heading=int(pilot.exit_heading);rise=int(pilot.rise)
	destination=w.ROOM_NAMES[t]
	still=host.reduced
	rate=cfg.reduced_rate if still else 1.0
	cover_at=cfg.reduced_fade if still else cfg.cover
	open_out=cfg.reduced_fade if still else cfg.open_out
	close_in=cfg.reduced_fade if still else cfg.close_in
	close_out=cfg.reduced_fade if still else cfg.close_out
	figure_px=cfg.figure_px
	elapsed=0.0;close_start=-1.0;request_time=-1.0;swap_time=-1.0;releasing=false
	shown.clear();current="";feet=Vector2.ZERO
	var stem="stair_ascend" if rise<0 else "stair_descend"
	queue=[stem+"_enter"]
	for i in (cfg.reduced_loops if still else cfg.loops): queue.append(stem+"_loop")
	queue.append(stem+"_exit")
	if not still: queue.append("stair_descend_arrive_settle" if rise>0 else "stair_arrive_idle_settle")
	planned=queue.duplicate()
	plan()
	phase="open";started+=1;last_result=""
	w.player.set_physics_process(false);w.player.velocity=Vector2.ZERO
	w.hud.clear_touches()
	layer.visible=true
	kaze.visible=false
	frame_camera(true)
	redraw()

func queue_names() -> Array:
	return planned

func clip(name:String) -> Dictionary:
	return host.table[name]

func scale_of(c:Dictionary) -> float:
	return figure_px/maxf(64.0,float(c.figure))

## Precomputes the stage root path from the clip queue and builds stair levels from it,
## so tread tops follow whatever root motion the bound clips (stand-in or ART-08) carry.
func plan():
	path=PackedVector2Array();levels.clear()
	var p=Vector2.ZERO
	path.append(p)
	var loop_total=Vector2.ZERO
	var soles=[]
	for name in queue:
		var c=clip(name);var s=scale_of(c)
		if name.ends_with("_loop"): loop_total=Library.motion_total(c)*s
		for i in c.frames.size():
			var rm:Vector2=c.root_motion[i] if c.root_motion.size()>i else Vector2.ZERO
			if c.get("soles",[]).size()>i and c.soles[i]!=Vector2.INF and name!="stair_arrive_idle_settle" and name!="stair_descend_arrive_settle":
				soles.append(p+Vector2(c.soles[i].x*heading,c.soles[i].y)*s)
			for k in 4:
				p+=Vector2(rm.x*heading,rm.y)*s/4.0;path.append(p)
	var span=path[path.size()-1].y-path[0].y
	var step_y=loop_total.y/2.0 if absf(loop_total.y)>1 else signf(span)*maxf(1.0,absf(span))/5.0
	var count=maxi(1,int(roundf(span/step_y))) if absf(step_y)>0.5 else 1
	var height=span/count
	var risers=[]
	for k in range(1,count+1):
		var y=path[0].y+(k-0.5)*height
		var x=path[path.size()-1].x
		for q in path.size()-1:
			var a=path[q];var b=path[q+1]
			if (a.y-y)*(b.y-y)<=0 and absf(b.y-a.y)>0.0001:
				x=lerpf(a.x,b.x,(y-a.y)/(b.y-a.y));break
		risers.append(x)
	var far=4000.0
	var prev=path[0].x-far*heading
	for k in count+1:
		var to=risers[k] if k<count else path[path.size()-1].x+far*heading
		levels.append([prev,to,path[0].y+k*height])
		prev=to
	# Seat each tread under the lowest measured sole that falls on it (planted feet never
	# float above or sink into a tread). Root-path heights remain where no sole lands.
	for l in levels:
		var x0=minf(l[0],l[1]);var x1=maxf(l[0],l[1]);var best=-INF
		for q in soles:
			if q.x>=x0+6 and q.x<=x1-6: best=maxf(best,q.y)
		if best>-INF and absf(best-l[2])<absf(height)*1.5: l[2]=best

func release(w):
	if request_time>=0: return
	request_time=elapsed
	releasing=true
	# The inherited embodied adapter captures and later restores the sprite's prior
	# visibility; it must capture a visible character, never this hidden one.
	w.player.sprite.visible=true
	w.request_room(target,arrival)
	w.player.sprite.visible=false
	releasing=false
	if w.transition<=0 or w.pending_room!=target: restore(w,"request_rejected")

## Every world physics tick from CinematicTransitions.present().
func tick(w):
	if phase=="": return
	var dt=host.cinematic.last_dt
	elapsed+=dt
	if elapsed>Data.TR08.stair.watchdog:
		restore(w,"watchdog");return
	if request_time<0 and elapsed>=cover_at:
		release(w)
		if phase=="": return
	if swap_time<0 and request_time>=0 and w.room==target and w.pending_room==-1: swap_time=elapsed
	# The inherited presentation runs hidden beneath the opaque stage.
	w.embodied_transitions.proxy.visible=false
	if w.transition<=0 and request_time>=0: w.player.set_physics_process(false)
	match phase:
		"open":
			if elapsed>=cover_at:
				phase="climb";next_clip()
		"climb":
			feet+=kaze.advance(dt)*kaze.base_scale
			if kaze.finished:
				if queue.is_empty():
					if w.transition<=0 and w.room==target:
						phase="close";close_start=elapsed
				else: next_clip()
		"close":
			if kaze.clip.loop or not kaze.finished: feet+=kaze.advance(dt)*kaze.base_scale
			if elapsed>=close_start+close_in and stage.visible:
				stage.visible=false;back.visible=false
				w.player.sprite.visible=true;w.player.animate(0)
			if elapsed>=close_start+close_in+close_out:
				restore(w,"completed");return
	if phase in ["open","climb"] and elapsed>=cover_at: w.player.sprite.visible=false
	frame_camera(false)
	redraw()

func next_clip():
	current=queue.pop_front()
	var c=clip(current)
	kaze.base_scale=scale_of(c)
	kaze.play(c,heading,0,rate)
	kaze.visible=true
	shown.append([snappedf(elapsed,0.001),current,c.bound,c.provenance])

func frame_camera(snap:bool):
	var lo=Vector2(INF,INF);var hi=-lo
	for p in path: lo=lo.min(p);hi=hi.max(p)
	var center=(lo+hi)/2.0+Vector2(0,-figure_px*0.36)
	if still:
		cam=center;zoom=1.0
	else:
		var goal=feet+Vector2(heading*110,-figure_px*0.36)
		goal.x=clampf(goal.x,lo.x-60,hi.x+60)
		cam=goal if snap else cam.lerp(goal,0.12)
		var progress=clampf((elapsed-cover_at)/2.0,0,1)
		zoom=lerpf(1.0,Data.TR08.stair.zoom,progress*progress*(3.0-2.0*progress))
	stage.scale=Vector2.ONE*zoom
	stage.position=Vector2(640,372)-cam*zoom
	kaze.position=feet

func redraw():
	back.queue_redraw();stage.queue_redraw();front.queue_redraw()

func arrived(w):
	pass

func room_loaded(w):
	if phase=="": return
	# The loader-owned swap into the target is the only rebuild a sequence survives.
	if request_time>=0 and w.room==target and w.transition>0 and w.pending_room==-1: return
	restore(w,"room_changed")

func cancel(w):
	if phase!="": restore(w,"cancelled")

func reduced_changed(w):
	if phase=="": return
	if host.reduced and not still:
		# Shorten what remains, freeze the camera at once; never restart a phase.
		still=true;rate=Data.TR08.stair.reduced_rate
		while queue.size()>1 and queue[0].ends_with("_loop"): queue.pop_front()
		queue.erase("stair_arrive_idle_settle");queue.erase("stair_descend_arrive_settle")
		kaze.rate=rate
		close_in=minf(close_in,Data.TR08.stair.reduced_fade);close_out=minf(close_out,Data.TR08.stair.reduced_fade)
		frame_camera(true)

## Restores everything the sequence touched. While the inherited loader still runs it
## owns player physics and re-enables it at its own clock expiry.
func restore(w,reason:String):
	var was=phase
	phase="";releasing=false
	if is_instance_valid(w) and is_instance_valid(w.player):
		if was!="" and w.transition<=0:
			w.player.set_physics_process(true);w.player.velocity=Vector2.ZERO
		w.player.sprite.visible=true
	layer.visible=false;stage.visible=true;back.visible=true;kaze.visible=false
	last_result=reason;last_duration=elapsed
	if reason=="completed": completed+=1
	else: aborted+=1
	redraw()

func _process(_dt):
	if phase=="" or not is_instance_valid(world): return
	if get_tree().paused: restore(world,"paused")
	elif world.player.hp<=0: restore(world,"died")

func smooth(x:float) -> float:
	x=clampf(x,0,1);return x*x*(3.0-2.0*x)

## Stage opacity: fades in under the opening wipe, out under the closing wipe.
func stage_alpha() -> float:
	if close_start>=0: return 1.0-smooth((elapsed-close_start)/maxf(0.01,close_in))
	return smooth(elapsed/maxf(0.01,cover_at))

func room_tint(index:int) -> Color:
	return world.ROOM_COLORS[index] if index>=0 and index<world.ROOM_COLORS.size() else Color("282c39")

func draw_back():
	if phase=="": return
	var a=stage_alpha()
	var progress=clampf((elapsed-cover_at)/2.0,0,1)
	var drift=Vector2(-cam.x*0.08,-cam.y*0.05)
	back.draw_rect(Rect2(0,0,1280,720),Color(0.03,0.03,0.06,a))
	back.draw_texture_rect(District,Rect2(Vector2(-160,-150)+drift,Vector2(1600,1066)),false,Color(0.46,0.44,0.62,a))
	var tint=room_tint(source).lerp(room_tint(target),progress)
	back.draw_rect(Rect2(0,0,1280,720),Color(tint,0.55*a))

func tile_for(index:int) -> Vector2:
	return Vector2(512,0) if index in [0,1,2,13,14,15] else Vector2(0,0)

func draw_tiled(canvas:CanvasItem,rect:Rect2,tile:Vector2,tint:Color):
	var y=rect.position.y
	while y<rect.end.y:
		var h=minf(512.0,rect.end.y-y)
		var x=rect.position.x
		while x<rect.end.x:
			var wd=minf(512.0,rect.end.x-x)
			canvas.draw_texture_rect_region(Terrain,Rect2(x,y,wd,h),Rect2(tile,Vector2(wd,h)),tint)
			x+=512.0
		y+=512.0

## Stair architecture from the approved material atlas (same blue/purple masonry and
## walkable-cap colour as the in-game platforms). Treads are the planned root levels.
func draw_stage():
	if phase=="" or levels.is_empty(): return
	var a=stage_alpha()
	var top=INF;var bottom=-INF
	for l in levels: top=minf(top,l[2]);bottom=maxf(bottom,l[2])
	var tile=tile_for(target if progress_past_mid() else source)
	var lo=-2400.0+minf(path[0].x,path[path.size()-1].x)
	var hi=2400.0+maxf(path[0].x,path[path.size()-1].x)
	# Stairwell back wall (approved masonry tile) with tall bays opening onto the district
	# skyline (approved district-fidelity backdrop), pilasters and lamps. Background only.
	var wall_top=top-1100.0
	draw_tiled(stage,Rect2(lo,wall_top,hi-lo,bottom-top+1500),tile,Color(0.22,0.23,0.31,a))
	var x=floorf(lo/420.0)*420.0
	while x<hi:
		var bay=Rect2(x+120,top-figure_px*1.18,200,figure_px*0.80)
		stage.draw_texture_rect_region(District,bay,Rect2(fposmod(x*0.37,1100.0),180,220,300),Color(0.62,0.58,0.78,a))
		stage.draw_rect(bay,Color(0.08,0.07,0.16,0.35*a))
		stage.draw_rect(Rect2(bay.position-Vector2(14,22),Vector2(bay.size.x+28,22)),Color(0.55,0.56,0.62,a))
		stage.draw_rect(Rect2(bay.position.x-14,bay.end.y,bay.size.x+28,12),Color(0.48,0.49,0.55,a))
		stage.draw_rect(Rect2(x,wall_top,30,bottom-top+1500),Color(0.06,0.07,0.11,0.6*a))
		stage.draw_circle(Vector2(x+15,top-figure_px*0.98),7,Color(0.98,0.78,0.48,0.85*a))
		x+=420.0
	# Far-side handrail: a straight rail parallel to the nosing line at hip height.
	if levels.size()>=3:
		var first=Vector2(levels[1][0],levels[1][2]);var last=Vector2(levels[levels.size()-1][0],levels[levels.size()-1][2])
		var up=Vector2(0,-figure_px*0.44)
		var dirv=(last-first).normalized()
		stage.draw_line(first+up-dirv*60,last+up+dirv*40,Color(0.50,0.50,0.55,a),8,true)
		stage.draw_line(Vector2(levels[0][0],levels[0][2])+up,first+up-dirv*60,Color(0.50,0.50,0.55,a),8,true)
		stage.draw_line(last+up+dirv*40,Vector2(levels[levels.size()-1][1],last.y)+up,Color(0.50,0.50,0.55,a),8,true)
		for i in range(1,levels.size()):
			var at=Vector2(levels[i][0]+(levels[i][1]-levels[i][0])*0.5,levels[i][2])
			var slope=(last.y-first.y)/(last.x-first.x) if absf(last.x-first.x)>1 else 0.0
			var rail_y=first.y+up.y+(at.x-first.x)*slope if i<levels.size()-1 else last.y+up.y
			stage.draw_line(at,Vector2(at.x,rail_y),Color(0.36,0.36,0.41,a),5)
	# Treads and landings, each a solid masonry block down to the stair base.
	for l in levels:
		var x0=minf(l[0],l[1]);var x1=maxf(l[0],l[1])
		var r=Rect2(x0,l[2],x1-x0,bottom-l[2]+520)
		draw_tiled(stage,r,Vector2(512,0)+Vector2(0,96),Color(0.95,0.97,1.05,a))
		stage.draw_rect(Rect2(x0,l[2],x1-x0,8),Color(Color("a9a58c"),a))
		stage.draw_rect(Rect2(x0,l[2]+8,x1-x0,30),Color(0.02,0.03,0.06,0.30*a))
	# Riser faces: the step fronts between levels, in shade.
	for i in range(1,levels.size()):
		var rx=levels[i][0];var y0=minf(levels[i-1][2],levels[i][2]);var y1=maxf(levels[i-1][2],levels[i][2])
		stage.draw_rect(Rect2(rx-3,y0,6,y1-y0+8),Color(0.10,0.11,0.16,a))
	kaze.modulate=Color(1,1,1,a)

func progress_past_mid() -> bool:
	return swap_time>=0

## Screen-space composition: wipe panels (supporting effect), letterbox, destination
## plate (bottom) and the honest clip-status line.
func draw_front():
	if phase=="": return
	var o=front
	var font=ThemeDB.fallback_font
	var art=host.cinematic.art
	var ivory=Color(0.95,0.9,0.8);var rose=Color(0.86,0.5,0.62);var indigo=Color(0.09,0.07,0.17)
	var a=stage_alpha()
	var bars=smooth(elapsed/maxf(0.01,cover_at))*(1.0-smooth((elapsed-close_start-close_in)/maxf(0.01,close_out)) if close_start>=0 else 1.0)
	var h=58.0*bars
	o.draw_rect(Rect2(0,0,1280,h),Color(indigo,0.97))
	o.draw_rect(Rect2(0,720-h,1280,h),Color(indigo,0.97))
	if bars>0.05:
		o.draw_line(Vector2(0,h),Vector2(1280,h),Color(rose,bars),3)
		o.draw_line(Vector2(0,720-h),Vector2(1280,720-h),Color(rose,bars),3)
	if not still:
		var edge=wipe_edge()
		if edge>-2250 and edge<1600:
			if heading>0: o.draw_set_transform(Vector2(1280,0),0,Vector2(-1,1))
			for row in Data.WIPE_ROWS:
				var x=edge+row[2];var y=row[0]
				if art.has("wipe_"+row[1]): o.draw_texture(art["wipe_"+row[1]],Vector2(x,y))
				else:
					var pts=PackedVector2Array([Vector2(x,y+96),Vector2(x+1822,y),Vector2(x+1822,y+392),Vector2(x,y+488)])
					o.draw_colored_polygon(pts,Color(0.2+0.04*row[0]/450.0,0.15,0.33,0.96))
					o.draw_line(Vector2(x,y+150),Vector2(x+1822,y+54),Color(rose,0.9),5,true)
			o.draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
	# Bottom destination plate (the creator-accepted destination label).
	var plate=plate_alpha()
	var title=("ASCEND  >  " if rise<0 else "DESCEND  >  ")+destination
	if plate>0.01: draw_plate(o,art,Vector2(410,663),plate,title,font,ivory,indigo)
	# Clip status, top bar: always for a true stand-in (interface hard rule), otherwise
	# only with the developer flag (TR08 B3b: keeps the letterbox bars clean).
	var text=top_label()
	if not text.is_empty() and a>0.05:
		o.draw_string(font,Vector2(24,38),text,HORIZONTAL_ALIGNMENT_LEFT,1232,15,Color(1.0,0.82,0.45,a) if kaze.is_standin() else Color(0.8,0.78,0.72,0.7*a))
	if still and host.debug_labels and a>0.05: o.draw_string(font,Vector2(24,700),"REDUCED MOTION · FIXED FRAMING",HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color(0.85,0.8,0.7,a))

## Opacity of the bottom destination plate (creator-accepted label).
func plate_alpha() -> float:
	if phase=="": return 0.0
	var plate=smooth((elapsed-0.05)/0.3)
	if close_start>=0: plate*=1.0-smooth((elapsed-close_start-close_in-close_out*0.4)/maxf(0.01,close_out*0.6))
	return plate

## The top-bar clip line the stage draws now ("" when hidden).
func top_label() -> String:
	if phase=="" or not kaze.visible or kaze.clip.is_empty(): return ""
	if not kaze.is_standin() and not host.debug_labels: return ""
	var text=kaze.status()
	if kaze.is_standin(): text+="  ·  "+str(kaze.clip.provenance).trim_prefix("STAND-IN: ")
	return text

## Leading edge of the wind-cloth panels in authored (-x travel) screen space: in, cover
## the world at cover_at, clear; again in to cover at close_start+close_in, then clear.
func wipe_edge() -> float:
	if close_start>=0:
		var s=elapsed-close_start
		if s<close_in:
			var u=clampf(s/close_in,0,1);return lerpf(1500,-300,1.0-(1.0-u)*(1.0-u))
		var v=clampf((s-close_in)/maxf(0.01,close_out),0,1);return lerpf(-300,-2300,v*v)
	if elapsed<cover_at:
		var u=clampf(elapsed/cover_at,0,1);return lerpf(1500,-300,1.0-(1.0-u)*(1.0-u))
	var v=clampf((elapsed-cover_at)/maxf(0.01,open_out),0,1);return lerpf(-300,-2300,v*v)

func draw_plate(o,art:Dictionary,at:Vector2,alpha:float,title:String,font,ivory:Color,indigo:Color):
	if art.has("wipe_badge"):
		o.draw_texture(art["wipe_badge"],at,Color(1,1,1,alpha))
	else:
		o.draw_colored_polygon(PackedVector2Array([at+Vector2(8,0),at+Vector2(460,0),at+Vector2(452,54),at+Vector2(0,54)]),Color(indigo,0.94*alpha))
		o.draw_line(at+Vector2(0,54),at+Vector2(452,54),Color(0.86,0.5,0.62,alpha),3)
	o.draw_string(font,at+Vector2(22,36),title,HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color(ivory,alpha))
