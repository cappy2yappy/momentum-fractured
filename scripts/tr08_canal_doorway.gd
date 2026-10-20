extends Node
## TR-08: embodied Canal doorway passage, R13 Mooring Loft left exit <-> R0 Canal Haven.
## R13 -> R0 (automatic walk-through, trigger unchanged at x=120) and R0 -> R13 (E at the
## R0 door). Kaze turns into the opening, crosses the threshold into the aperture
## occlusion, the inherited 0.65 s loader (supporting wipe + bottom destination label)
## swaps the room, and Kaze emerges from the destination door and turns to travel.
## The doorway and Kaze are drawn on a viewport-following layer ABOVE the loader fade, so
## the passage stays readable while the room around it fades. Door art and positions are
## the creator-approved contract rectangles, drawn unchanged.
## Never moves the collision body, never changes the trigger, gates, graph or saves.
const Data = preload("res://scripts/transition_pilot_data.gd")
const Library = preload("res://scripts/tr08_clip_library.gd")
const ClipPlayer = preload("res://scripts/tr08_clip_player.gd")
const RoomPresentation = preload("res://scripts/room_presentation.gd")

var host
var world
var phase = ""            # "", "approach", "turn", "cross", "hold", "emerge", "turn_out", "walk_out"
var key = ""
var source = -1
var target = -1
var arrival = Vector2.INF
var elapsed = 0.0
var phase_time = 0.0
var request_at = 0.0
var request_time = -1.0
var swap_time = -1.0
var releasing = false
var still = false
var rate = 1.0
var feet = Vector2.ZERO
var door: Dictionary = {}
var travel = -1           # heading into the source door
var out_heading = 1       # facing after arrival
var started = 0
var completed = 0
var aborted = 0
var last_result = ""
var last_duration = 0.0
var shown: Array = []
var inside = false
var layer = CanvasLayer.new()
var back = Node2D.new()
var mask = Node2D.new()
var kaze = ClipPlayer.new()
var front = Node2D.new()

func configure(w,h):
	world=w;host=h
	name="Tr08CanalDoorway"
	process_mode=Node.PROCESS_MODE_ALWAYS
	layer.layer=Data.TR08.canal.layer
	layer.follow_viewport_enabled=true
	layer.process_mode=Node.PROCESS_MODE_ALWAYS
	layer.visible=false
	add_child(layer)
	for n in [back,mask,front]:
		n.process_mode=Node.PROCESS_MODE_ALWAYS;layer.add_child(n)
	mask.clip_children=CanvasItem.CLIP_CHILDREN_ONLY
	back.draw.connect(draw_back);mask.draw.connect(draw_mask);front.draw.connect(draw_front)
	layer.add_child(kaze)
	layer.move_child(front,-1)

func applies(w,t:int) -> bool:
	if not "%d:%d"%[w.room,t] in Data.TR08.canal_pairs: return false
	# Ground steps only: an airborne, tethered or wall-sliding crossing keeps the
	# inherited passage instead of counterfeit footsteps.
	return w.player.is_on_floor() and not w.player.tether_attached

func door_for(index:int) -> Dictionary:
	var c=Data.TR08.canal
	if index==Data.CANAL_LEFT.room:
		var d=Data.CANAL_LEFT
		return {"room":index,"kind":"canal","at":Vector2(d.door_x,d.floor_y),"aperture":d.aperture,"clip":true,"lane":Vector2(d.aperture.position.x+14,d.aperture.end.x-14)}
	return {"room":index,"kind":"legacy","at":c.r0_door,"aperture":c.r0_opening,"clip":false,"lane":Vector2(c.r0_door.x,c.r0_door.x)}

## Owns the accepted request (world.request_room already passed can_enter).
func begin(w,t:int,at:Vector2):
	key="%d:%d"%[w.room,t];source=w.room;target=t;arrival=at
	still=host.reduced
	rate=Data.TR08.canal.reduced_rate if still else 1.0
	door=door_for(source)
	feet=w.player.position
	feet.y=door.at.y
	travel=-1 if source==Data.CANAL_LEFT.room else (1 if door.at.x>=feet.x else -1)
	if source!=Data.CANAL_LEFT.room and absf(door.at.x-feet.x)<2: travel=w.player.facing
	elapsed=0.0;request_time=-1.0;swap_time=-1.0;releasing=false;shown.clear()
	started+=1;last_result=""
	w.player.set_physics_process(false);w.player.velocity=Vector2.ZERO
	if w.player.dash_time>0: w.player.dash_time=0
	w.hud.clear_touches()
	w.player.sprite.visible=false
	layer.visible=true;kaze.visible=true
	set_inside(false)
	# Exact clip schedule: the crossing ends at the hidden swap (loader 0.33 s).
	var turn=Library.duration(clip("door_turn_to_rear"))/rate
	var cross=Library.duration(clip("door_cross"))/rate
	var lead=approach_time(w)
	request_at=lead+maxf(turn,turn+cross-Data.TR08.canal.loader_cover)
	if lead>0: start_phase("approach","door_approach_walk",travel)
	else: start_phase("turn","door_turn_to_rear",travel)
	redraw()

func clip(name:String) -> Dictionary:
	return host.table[name]

func world_scale(c:Dictionary) -> float:
	return float(c.world_scale)

func approach_time(w) -> float:
	var lane:Vector2=door.lane
	var goal=clampf(feet.x,lane.x,lane.y)
	var dx=absf(goal-feet.x)
	if dx<6: feet.x=goal;return 0.0
	return dx/walk_speed()

func walk_speed() -> float:
	var c=clip("door_approach_walk")
	var per=Library.motion_total(c).x*world_scale(c)/maxf(0.01,Library.duration(c))
	return maxf(40.0,per)*rate

func start_phase(p:String,name:String,h:int):
	phase=p;phase_time=0.0
	var c=clip(name)
	kaze.base_scale=world_scale(c)
	kaze.play(c,h,0,rate)
	shown.append([snappedf(elapsed,0.001),name,c.bound,c.provenance])

func set_inside(v:bool):
	if inside==v and kaze.get_parent()!=null: return
	inside=v
	var parent=mask if v and door.get("clip",false) else layer
	if kaze.get_parent()!=parent:
		if kaze.get_parent(): kaze.get_parent().remove_child(kaze)
		parent.add_child(kaze)
		if parent==layer: layer.move_child(kaze,front.get_index())

func release(w):
	request_time=elapsed
	releasing=true
	# The inherited embodied adapter captures and later restores the sprite's prior
	# visibility; it must capture a visible character, never this hidden one.
	w.player.sprite.visible=true
	w.request_room(target,arrival)
	w.player.sprite.visible=false
	releasing=false
	if w.transition<=0 or w.pending_room!=target: restore(w,"request_rejected")

## Loader fade alpha drawn by the HUD (unchanged formula), 0 outside the loader.
func fade(w) -> float:
	if w.transition<=0: return 0.0
	return clampf(1.0-absf(w.transition-0.325)/0.325,0,1)

func tick(w):
	if phase=="": return
	var dt=host.cinematic.last_dt
	elapsed+=dt;phase_time+=dt
	if elapsed>Data.TR08.canal.watchdog:
		restore(w,"watchdog");return
	if request_time<0 and elapsed>=request_at-0.0001:
		release(w)
		if phase=="": return
	w.embodied_transitions.proxy.visible=false
	if w.embodied_transitions.active: w.embodied_transitions.placeholder=status_line()
	if w.transition<=0 and request_time>=0: w.player.set_physics_process(false)
	w.player.sprite.visible=false
	if swap_time<0 and request_time>=0 and w.room==target and w.pending_room==-1:
		swap_time=elapsed;arrive(w)
	var moved=kaze.advance(dt)
	match phase:
		"approach":
			var goal=clampf(feet.x,door.lane.x,door.lane.y)
			feet.x=move_toward(feet.x,goal,walk_speed()*dt)
			if kaze.finished and kaze.clip.loop: kaze.play(kaze.clip,travel,0,rate)
			if absf(feet.x-goal)<0.5: start_phase("turn","door_turn_to_rear",travel)
		"turn":
			if kaze.finished: start_phase("cross","door_cross",travel);set_inside(true)
		"cross":
			if kaze.finished: phase="hold"
		"emerge":
			if door.clip and kaze.index>=int(kaze.clip.frames.size()*0.6): set_inside(false)
			if kaze.finished:
				set_inside(false)
				start_phase("turn_out","door_turn_to_side",out_heading)
		"turn_out":
			if kaze.finished:
				if absf(arrival_feet().x-feet.x)>2: start_phase("walk_out","door_walk_out",out_heading)
				else: finish_when_ready(w)
		"walk_out":
			var goal=arrival_feet().x
			var c=kaze.clip
			var speed=maxf(40.0,Library.motion_total(c).x*world_scale(c)/maxf(0.01,Library.duration(c)))*rate
			feet.x=move_toward(feet.x,goal,speed*dt)
			if kaze.finished and c.loop: kaze.play(c,out_heading,0,rate)
			if absf(feet.x-goal)<0.5: finish_when_ready(w)
		"done":
			finish_when_ready(w)
	if phase=="": return
	stage_pose(w)
	redraw()

func arrival_feet() -> Vector2:
	return world.player.position

func arrive(w):
	door=door_for(target)
	out_heading=int(w.player.facing) if w.player.facing!=0 else 1
	feet=Vector2(door.at.x,door.at.y)
	start_phase("emerge","door_emerge",out_heading)
	set_inside(door.clip)

func finish_when_ready(w):
	if w.transition>0: phase="done";return
	feet=arrival_feet()
	restore(w,"completed")

## Depth staging around the real frames: a small recession, scale and shade while the
## character is inside the aperture plane. Documented as staging, not as animation.
func stage_pose(w):
	var c=Data.TR08.canal
	var u=0.0
	if phase=="cross": u=clampf(kaze.index/maxf(1.0,kaze.clip.frames.size()-1.0)+kaze.into/maxf(0.001,kaze.frame_time())/maxf(1.0,kaze.clip.frames.size()-1.0),0,1)
	elif phase=="hold": u=1.0
	elif phase=="emerge": u=1.0-clampf((kaze.index+kaze.into/maxf(0.001,kaze.frame_time()))/maxf(1.0,kaze.clip.frames.size()),0,1)
	if still: u=0.0 if phase in ["approach","turn","turn_out","walk_out","done"] else (1.0 if phase in ["cross","hold"] else 0.0)
	kaze.depth=lerpf(1.0,c.depth_scale,u)
	kaze.apply()
	# ART-08 door clips carry their depth travel as root motion in cell y (cross recedes
	# up, emerge advances down); the stand-ins have none, so a fixed recession is used.
	var lift=-c.depth_px*u
	if phase in ["cross","hold","emerge"] and kaze.has_depth_motion():
		var total=Library.motion_total(kaze.clip).y
		lift=(kaze.travelled.y if phase!="emerge" else kaze.travelled.y-total)*kaze.base_scale
		if phase=="hold": lift=total*kaze.base_scale
	kaze.position=feet+Vector2(0,lift)
	var shade=lerpf(1.0,c.shade,pow(u,0.8))
	kaze.modulate=Color(shade,shade,shade*1.08,1.0)
	# The doorway layer outlives the room fade, then follows it to black at the swap.
	var a=1.0-pow(fade(w),3.0)
	for n in [back,mask,front,kaze]: n.self_modulate=Color(1,1,1,a)

func status_line() -> String:
	if kaze.clip.is_empty(): return ""
	return kaze.status()+("  ·  "+str(kaze.clip.provenance).trim_prefix("STAND-IN: ") if kaze.is_standin() else "")

func redraw():
	back.queue_redraw();mask.queue_redraw();front.queue_redraw()

func arrived(w):
	pass

func room_loaded(w):
	if phase=="": return
	if request_time>=0 and w.room==target and w.transition>0 and w.pending_room==-1: return
	restore(w,"room_changed")

func cancel(w):
	if phase!="": restore(w,"cancelled")

func reduced_changed(w):
	if phase=="": return
	if host.reduced and not still:
		still=true;rate=Data.TR08.canal.reduced_rate;kaze.rate=rate

func restore(w,reason:String):
	var was=phase
	phase="";releasing=false
	if is_instance_valid(w) and is_instance_valid(w.player):
		if was!="" and w.transition<=0:
			w.player.set_physics_process(true);w.player.velocity=Vector2.ZERO
		w.player.sprite.visible=true
		if reason=="completed": w.player.animate(0)
	set_inside(false)
	layer.visible=false
	last_result=reason;last_duration=elapsed
	if reason=="completed": completed+=1
	else: aborted+=1
	redraw()

func _process(_dt):
	if phase=="" or not is_instance_valid(world): return
	if get_tree().paused: restore(world,"paused")
	elif world.player.hp<=0: restore(world,"died")

## Door art, repeated on the layer above the fade at the same room positions.
func draw_back():
	if phase=="" or door.is_empty(): return
	if door.kind=="canal":
		var art=host.cinematic.art
		var d=Data.CANAL_LEFT
		var allowed=true
		if art.has("L1_door_interior"): back.draw_texture(art["L1_door_interior"],d.aperture.position)
		else: back.draw_rect(d.aperture,Color("10161f"))
		if art.has("L1_door_leaf"): back.draw_texture(art["L1_door_leaf"],d.aperture.position)
		if art.has("L1_door_frame"): back.draw_texture(art["L1_door_frame"],d.frame.position)
		else:
			var fr:Rect2=d.frame;var ap:Rect2=d.aperture
			back.draw_rect(Rect2(fr.position,Vector2(ap.position.x-fr.position.x,fr.size.y)),Color("4d535e"))
			back.draw_rect(Rect2(Vector2(ap.end.x,fr.position.y),Vector2(fr.end.x-ap.end.x,fr.size.y)),Color("4d535e"))
			back.draw_rect(Rect2(fr.position,Vector2(fr.size.x,ap.position.y-fr.position.y)),Color("6a6e72"))
		back.draw_line(Vector2(d.aperture.position.x,d.aperture.end.y-3),Vector2(d.aperture.end.x,d.aperture.end.y-3),Color("d9c9ad") if allowed else Color("c48e78"),4)
	else:
		RoomPresentation.draw_legacy_exit(back,door.at,Color("9bc5a0"))

func draw_mask():
	if phase=="" or door.is_empty() or not door.clip: return
	mask.draw_rect(door.aperture,Color.WHITE)

func draw_front():
	if phase=="" or kaze.clip.is_empty(): return
	if not kaze.is_standin(): return
	var font=ThemeDB.fallback_font
	var at=Vector2(door.at.x-60,door.aperture.position.y-46)
	front.draw_rect(Rect2(at-Vector2(6,15),Vector2(270,40)),Color(0.05,0.05,0.09,0.85))
	front.draw_string(font,at,Library.STANDIN_LABEL,HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color(1.0,0.82,0.45))
	front.draw_string(font,at+Vector2(0,16),kaze.clip.name,HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color(0.95,0.85,0.7))
