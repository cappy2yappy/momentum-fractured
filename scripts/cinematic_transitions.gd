extends Node2D
## TR-05: endpoint intent and cinematic presentation. Never owns world topology.
const PilotData = preload("res://scripts/transition_pilot_data.gd")
const StagedStair = preload("res://scripts/staged_stair_cinematic.gd")
const Tr08 = preload("res://scripts/tr08_embodied_cinematics.gd")
var staged = StagedStair.new()
var tr08 = Tr08.new()
var art: Dictionary = {}
var enabled = true
var reduced = false
var plain = false
var sampled = false
var previous = Vector2.ZERO
var armed: Dictionary = {}
var cooldown = 0.0
var active = false
var chosen: Dictionary = {}
var carried_x = 0.0
var camera_state: Dictionary = {}
var world
var request_count = 0
var arrival_count = 0
var last_dt = 1.0/60.0
const ARM_BELOW = 40.0  # GN-06: arming band reaches this far below the endpoint y

func configure(w):
	world=w
	process_mode=Node.PROCESS_MODE_ALWAYS
	z_index=3
	var args=OS.get_cmdline_user_args()
	enabled=not "--tr05-legacy" in args
	reduced="--tr05-reduced-motion" in args or w.embodied_transitions.comparison=="reduced"
	plain="--tr05-plain" in args or w.embodied_transitions.comparison=="plain"
	art=PilotData.load_art()
	add_child(staged);staged.configure(w,self,args)
	add_child(tr08);tr08.configure(w,self,args)
	if not enabled: return
	w.embodied_transitions.depth_demo=false # R13/R14 is a reciprocal SIDE passage.
	w.embodied_transitions.art_preview=true
	w.embodied_transitions.comparison="reduced" if reduced else ("plain" if plain else "art-preview")
	w.mixed_transitions.graphic_mode="reduced" if reduced else ("plain" if plain else "graphic")
	for arg in args:
		if arg.begins_with("--tr05-save="):
			var path=arg.trim_prefix("--tr05-save=")
			if path.is_absolute_path(): w.save_path=path

func endpoints(w,index:int) -> Array:
	var result=[]
	# Existing base-chain positions, independent of whichever room is currently built.
	if index<13:
		if index>0: result.append({"at":Vector2(120,[1300,1300,1300,850,1300,1080,1300,1090,1090,830,830,760,1300][index]),"target":index-1,"arrival":Vector2.INF,"need":""})
		if index<12: result.append({"at":Vector2(2440,[1300,1300,850,1300,1080,1300,1090,1300,830,830,760,1300,1300][index]),"target":index+1,"arrival":Vector2.INF,"need":""})
	result.append_array(w.expansion.portals(index))
	# Existing meaningful gated returns. Their separate interaction controllers
	# still own activation/attunement; never reinterpret the high R9 return as the
	# ordinary lower left doorway simply because both are near a side wall.
	var returns={
		3:{"at":Vector2(2250,790),"target":9,"arrival":Vector2(480,618),"need":"terrace_return_relay","explicit_depth":true},
		9:{"at":Vector2(160,620),"target":3,"arrival":Vector2(2100,788),"need":"terrace_return_relay","explicit_depth":true},
		8:{"at":Vector2(1470,740),"target":12,"arrival":Vector2(430,828),"need":"keeper_return","explicit_depth":true},
		12:{"at":Vector2(220,830),"target":8,"arrival":Vector2(1590,738),"need":"keeper_return","explicit_depth":true},
	}
	if index in returns: result.append(returns[index].duplicate())
	for p in result:
		var key="%d:%d"%[index,p.target]
		p.mode="depth_door"
		p.heading=0
		if p.get("explicit_depth",false): continue
		if key in w.embodied_transitions.PILOTS:
			p.mode=w.embodied_transitions.PILOTS[key].mode
		elif w.mixed_transitions.is_special(index,p.target): p.mode="wind_fold"
		elif p.at.x<=160:
			p.mode="horizontal_walk";p.heading=-1
		elif p.at.x>=w.room_size(index).x-160:
			p.mode="horizontal_walk";p.heading=1
	return result

func endpoint(w,index:int,target:int) -> Dictionary:
	for p in endpoints(w,index):
		if p.target==target: return p
	return {}

func automatic(w,index:int,target:int) -> bool:
	return enabled and endpoint(w,index,target).get("mode","")=="horizontal_walk"

func passage_allowed(w,p:Dictionary) -> bool:
	if not p.need.is_empty(): return w.expansion.allowed(w,p.need)
	match "%d:%d"%[w.room,p.target]:
		"1:2": return w.player.double_jump
		"3:4": return w.player.tether_unlocked
		"5:6": return w.player.dash_unlocked
		"7:8": return w.completed
		"9:10": return w.has_required_sigils()
		"10:11": return w.opened_kunai_gates.get("skyworks_wind_intake",false)
		"11:12": return w.opened_kunai_gates.get("foundry_electric_relay",false)
		"6:7": return w.boss_defeated
	return true

func policy(w,index:int,target:int) -> Dictionary:
	if not enabled: return {}
	var p=endpoint(w,index,target)
	if p.is_empty(): return {"mode":"fallback"}
	if p.mode in ["stair_up","stair_down"]: return w.embodied_transitions.PILOTS["%d:%d"%[index,target]].duplicate()
	if p.mode=="wind_fold": return {"mode":"wind_fold","trigger":"interact"}
	if p.mode=="horizontal_walk":
		var reciprocal=endpoint(w,target,index)
		var arrival_heading=-int(reciprocal.get("heading",-p.heading))
		if arrival_heading==0: arrival_heading=int(p.heading)
		return {"mode":"horizontal_walk","trigger":"automatic","exit_heading":p.heading,"arrival_heading":arrival_heading,"dynamic_run":true}
	return {"mode":"depth_door","trigger":"interact","exit_heading":w.player.facing,"arrival_heading":1 if p.arrival==Vector2.INF or p.arrival.x<w.room_size(target).x/2 else -1}

func room_loaded(w):
	staged.room_loaded(w)
	tr08.room_loaded(w)
	sampled=false;armed.clear()
	if active and (w.transition<=0 or w.room!=chosen.get("target",-1) or w.pending_room!=-1): cancel(w)
	if not active: cooldown=0.0
	queue_redraw()

func supported_exit(w,p:Dictionary,pos:Vector2) -> bool:
	# A missed airborne crossing may reach the wall beyond the 85px band.
	# Recover only on the endpoint's actual shelf, never on a nearby floor.
	if not w.player.is_on_floor(): return false
	var landing=arrival_position(w,p)
	for rect in w.platforms:
		if absf(rect.position.y-(landing.y+2))>1: continue
		if p.at.x<rect.position.x or p.at.x>rect.end.x: continue
		if pos.x<rect.position.x+14 or pos.x>rect.end.x-14: continue
		if absf(pos.y-rect.position.y)<=2: return true
	return false

func update(w,dt:float):
	last_dt=dt
	if not enabled: return
	if w.transition>0:
		sampled=false
		return
	if active: finish(w)
	if w.mixed_transitions.active_walk or w.mixed_transitions.active_special: w.mixed_transitions.clear_effect(w)
	cooldown=maxf(0,cooldown-dt)
	if not w.player.is_physics_processing() or w.player.hp<=0: sampled=false;return
	var pos=w.player.position
	if not sampled: previous=pos;sampled=true
	for p in endpoints(w,w.room):
		if p.mode!="horizontal_walk": continue
		var dir=int(p.heading)
		var before=(previous.x-p.at.x)*dir
		var after=(pos.x-p.at.x)*dir
		var corridor=pos.y>=p.at.y-90 and pos.y<=p.at.y+8 and previous.y>=p.at.y-90 and previous.y<=p.at.y+8
		# Arrival spawns safely INWARD. Rearm requires leaving the threshold behind;
		# cooldown alone never triggers a stationary or held-E return.
		# GN-06: arming (never the crossing) also accepts an inward approach floor seated up
		# to one platform thickness (40 px) BELOW the endpoint, e.g. the R6 floor at 1110
		# under the (2440,1090) sill. A 920 px/s dash steps about 15 px a tick and could
		# reach the corridor only inside the 16 px arm window, so it was never armed.
		var arm_band=pos.y>=p.at.y-90 and pos.y<=p.at.y+ARM_BELOW and previous.y>=p.at.y-90 and previous.y<=p.at.y+ARM_BELOW
		if after<=-16 and (corridor or arm_band): armed[p.target]=true
		var crossed=(before<0 and after>=0) or (after>=0 and after<=85)
		var direction=float(w.player.held("right"))-float(w.player.held("left"))
		var intent=w.player.velocity.x*dir>20 and direction*dir>=0
		var recovery=after>=0 and direction*dir>0 and w.player.velocity.x*dir>=-20 and supported_exit(w,p,pos)
		if w.player.tether_attached: continue
		if not (armed.get(p.target,false) and cooldown<=0 and ((corridor and crossed and intent) or recovery)): continue
		armed[p.target]=false
		var prior_message=w.message
		var prior_time=w.message_time
		w.message=""
		var allowed=w.can_enter(p.target)
		var hinted=not w.message.is_empty()
		if not hinted: w.message=prior_message;w.message_time=prior_time
		if not allowed:
			# can_enter owns authored prerequisite hints. Expansion gates return
			# only a bool; retain their existing meaningful need-id fallback.
			if not hinted:
				w.announce("Route sealed: "+p.need.replace("_"," ").to_upper()+". Consult the atlas." if not p.need.is_empty() else "PASSAGE LOCKED - CHECK THE ATLAS.",2)
			cooldown=0.4;continue
		w.request_room(p.target,p.arrival)
		break
	previous=pos

func begin(w,target:int):
	if not enabled: return
	finish(w)
	chosen=endpoint(w,w.room,target)
	if chosen.is_empty(): return
	active=true;request_count+=1
	carried_x=0
	if chosen.mode=="horizontal_walk":
		if w.player.is_on_floor() and w.player.dash_time<=0 and not w.player.tether_attached: carried_x=w.player.velocity.x
		w.mixed_transitions.active_walk=true
		w.mixed_transitions.direction=int(chosen.heading)
		w.mixed_transitions.carried_x=carried_x
	if chosen.mode in ["stair_up","stair_down"] and not reduced and not plain and staged.phase=="" and not tr08.owns():
		camera_state={"zoom":w.camera.zoom,"position":w.camera.position,"offset":w.camera.offset,"smoothing":w.camera.position_smoothing_enabled}
		w.camera.position_smoothing_enabled=false

func arrived(w):
	if not enabled or not active: return
	arrival_count+=1
	var reciprocal=endpoint(w,w.room,w.pending_from_room)
	if reciprocal.get("mode","")=="horizontal_walk":
		# Stay on the reviewed endpoint's shelf,64px inside its wall-side threshold.
		# No platform, graph or gate change; the existing320px landing supports this.
		w.player.position=arrival_position(w,reciprocal)
		w.player.facing=-int(reciprocal.heading)
	elif chosen.mode=="horizontal_walk":
		w.player.facing=int(chosen.heading)
	if chosen.mode=="horizontal_walk": w.player.velocity=Vector2(carried_x,0)
	elif chosen.mode in ["stair_up","stair_down"]:
		w.player.facing=int(w.embodied_transitions.PILOTS["%d:%d"%[w.pending_from_room,w.room]].arrival_heading)
	cooldown=0.45;armed.clear();sampled=false
	staged.arrived(w)

## Hook from world.request_room (after can_enter). TR-08 (default) owns the R14/R17 stair
## and the Canal doorway; the PM staged stair pilot only runs when TR-08 is off.
func intercept(w,target:int,arrival:Vector2) -> bool:
	if not enabled: return false
	if tr08.intercept(w,target,arrival): return true
	return staged.intercept(w,target,arrival)

func arrival_position(w,p:Dictionary) -> Vector2:
	var at=p.at-Vector2(int(p.heading)*64,2)
	# Existing R9 art/door feet are20px below their solid shelf. Choose the nearest
	# reviewed support top at the inward X; never relocate platforms or change saves.
	var nearest=40.0
	for rect in w.platforms:
		var distance=absf(rect.position.y-p.at.y)
		if at.x>=rect.position.x+16 and at.x<=rect.end.x-16 and distance<nearest:
			nearest=distance;at.y=rect.position.y-2
	return at

func label(w,p:Dictionary) -> String:
	if automatic(w,w.room,p.target): return w.ROOM_NAMES[p.target]+" - WALK THROUGH"
	return w.mixed_transitions.label(w,p)

func present(w):
	tr08.observe(w)
	if tr08.owns():
		# TR-08 owns camera, proxies and composition for its whole sequence.
		tr08.tick(w)
		if tr08.owns(): return
	if staged.phase!="":
		# The staged pilot owns camera and proxy for its whole sequence.
		staged.tick(w)
		if staged.phase!="": return
	if not enabled or not active: return
	if w.transition<=0: finish(w);return
	var e=w.embodied_transitions
	if not e.active or not chosen.mode in ["stair_up","stair_down"]: return
	if reduced or plain:
		restore_camera(w)
		return
	if camera_state.is_empty():
		camera_state={"zoom":w.camera.zoom,"position":w.camera.position,"offset":w.camera.offset,"smoothing":w.camera.position_smoothing_enabled}
		w.camera.position_smoothing_enabled=false
	var elapsed=clampf(0.65-w.transition,0,0.65)
	var t=clampf((elapsed-0.34)/0.31,0,1) if e.arrived_event else clampf(elapsed/0.33,0,1)
	var anchor=e.arrival_anchor if e.arrived_event else e.departure
	var heading=e.arrival_heading if e.arrived_event else e.exit_heading
	# Continuous render movement over three local steps; the held artwork is not
	# passed off as a completed gait. Simulation and reciprocal landing stay fixed.
	var travel=t-1.0 if e.arrived_event else t
	e.proxy.position=anchor+Vector2(heading*72*travel,e.rise*36*travel-2)
	e.placeholder="MOVING STAIR STUDY / FULL GAIT PENDING"
	var close=sin(PI*elapsed/0.65)
	w.camera.zoom=camera_state.get("zoom",Vector2.ONE)*lerpf(1.0,1.55,close)
	var focus=e.proxy.position-w.player.position+Vector2(0,-65)
	w.camera.position=camera_state.position.lerp(focus,close)
	w.camera.offset=camera_state.offset*(1.0-close)
	w.camera.reset_smoothing()
	e.queue_redraw();queue_redraw()

func restore_camera(w):
	if camera_state.is_empty(): return
	w.camera.zoom=camera_state.zoom;w.camera.position=camera_state.position
	w.camera.offset=camera_state.offset;w.camera.position_smoothing_enabled=camera_state.smoothing
	w.camera.reset_smoothing();camera_state.clear()

func finish(w):
	restore_camera(w)
	active=false;chosen.clear()
	queue_redraw()

func cancel(w):
	staged.cancel(w)
	tr08.cancel(w)
	finish(w);armed.clear();sampled=false;cooldown=0.45

func _process(_dt):
	if active and (get_tree().paused or world.player.hp<=0): cancel(world)

func _unhandled_key_input(event):
	if enabled and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F6:
		reduced=not reduced
		world.embodied_transitions.comparison="reduced" if reduced else ("plain" if plain else "art-preview")
		world.mixed_transitions.graphic_mode="reduced" if reduced else ("plain" if plain else "graphic")
		if reduced: restore_camera(world)
		staged.reduced_changed(world)
		tr08.reduced_changed(world)
		world.announce("REDUCED MOTION ON" if reduced else "CINEMATIC MOTION ON",2)
		get_viewport().set_input_as_handled()

func draw_exit(w,at:Vector2) -> bool:
	if not enabled: return false
	for p in endpoints(w,w.room):
		if p.at!=at or p.mode!="horizontal_walk": continue
		var allowed=passage_allowed(w,p)
		var color=Color("d9c9ad") if allowed else Color("c48e78")
		if "%d:%d"%[w.room,p.target]==PilotData.canal_key():
			draw_canal_door(w,p,allowed,color);return true
		w.draw_rect(Rect2(at-Vector2(48,132),Vector2(96,132)),Color("141c29"))
		for side in [-1,1]: w.draw_rect(Rect2(at+Vector2(side*52-6,-140),Vector2(12,140)),Color("677074"))
		w.draw_line(at+Vector2(-60,-140),at+Vector2(60,-140),Color("92908a"),8)
		w.draw_line(at+Vector2(-48,-3),at+Vector2(48,-3),color,4)
		var dir=int(p.heading)
		w.draw_line(at+Vector2(-18*dir,-55),at+Vector2(18*dir,-55),color,3)
		w.draw_polyline(PackedVector2Array([at+Vector2(4*dir,-67),at+Vector2(18*dir,-55),at+Vector2(4*dir,-43)]),color,3)
		w.draw_string(ThemeDB.fallback_font,at+Vector2(-70,28),"WALK THROUGH" if allowed else "LOCKED",HORIZONTAL_ALIGNMENT_LEFT,-1,13,color)
		return true
	return false

## PM pilot: Canal-left door drawn exactly on the contract aperture/frame, so the
## visible opening and the unchanged x=120 trigger coincide. Presentation only.
func draw_canal_door(w,p:Dictionary,allowed:bool,color:Color):
	var d=PilotData.CANAL_LEFT
	var ap:Rect2=d.aperture
	var fr:Rect2=d.frame
	if art.has("L1_door_frame"):
		# Combined Art Mane layers, absolute room positions, back to front.
		for row in PilotData.CANAL_ART:
			if not art.has(row[0]): continue
			var tint=PilotData.LOCKED_TINT if not allowed and row[0] in ["L1_door_interior","L1_door_leaf"] else Color.WHITE
			w.draw_texture(art[row[0]],row[2],tint)
		# The hall back wall is drawn after the world's platforms: repaint any walkable
		# surface it overlaps (R13 shelf 200,1160) so ledges stay legible.
		var hall=Rect2(72,1020,224,180)
		for rect in w.platforms:
			if rect.size.y==40 and rect.intersects(hall) and rect.position.y<hall.end.y-1: w.LevelGeometry.draw_surface(w,rect)
	else:
		# Procedural stand-in on the same contract rectangles.
		w.draw_rect(Rect2(fr.position,Vector2(ap.position.x-fr.position.x,fr.size.y)),Color("4d535e"))
		w.draw_rect(Rect2(Vector2(ap.end.x,fr.position.y),Vector2(fr.end.x-ap.end.x,fr.size.y)),Color("4d535e"))
		w.draw_rect(Rect2(fr.position,Vector2(fr.size.x,ap.position.y-fr.position.y)),Color("6a6e72"))
		for y in range(int(ap.position.y)+30,int(fr.end.y),33):
			w.draw_line(Vector2(fr.position.x,y),Vector2(ap.position.x,y),Color("3a3f49"),2)
			w.draw_line(Vector2(ap.end.x,y),Vector2(fr.end.x,y),Color("3a3f49"),2)
		w.draw_line(Vector2(fr.position.x,ap.position.y),Vector2(fr.end.x,ap.position.y),Color("92908a"),4)
		w.draw_rect(ap,Color("10161f") if allowed else Color("2a1a1c"))
	w.draw_line(Vector2(ap.position.x,ap.end.y-3),Vector2(ap.end.x,ap.end.y-3),color,4)
	# Threshold tick at the real trigger line (feet x = trigger_x).
	w.draw_line(Vector2(d.trigger_x,ap.end.y-12),Vector2(d.trigger_x,ap.end.y),Color(color,0.8),3)
	var dir=int(p.heading);var c=Vector2(ap.get_center().x,ap.position.y+60)
	w.draw_line(c+Vector2(-18*dir,0),c+Vector2(18*dir,0),color,3)
	w.draw_polyline(PackedVector2Array([c+Vector2(4*dir,-12),c+Vector2(18*dir,0),c+Vector2(4*dir,12)]),color,3)
	w.draw_string(ThemeDB.fallback_font,Vector2(ap.position.x-26,ap.end.y+28),"WALK THROUGH" if allowed else "LOCKED",HORIZONTAL_ALIGNMENT_LEFT,-1,13,color)

## L4 mouth corbel sits in front of Kaze (this node is z 3), never over the aperture.
func _draw():
	if not enabled or not is_instance_valid(world) or world.room!=PilotData.CANAL_LEFT.room: return
	var row=PilotData.CANAL_FRONT
	if art.has(row[0]): draw_texture(art[row[0]],row[2])
