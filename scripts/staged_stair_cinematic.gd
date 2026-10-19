extends Node2D
## PM pilot (TRANSITION): staged ~2-3 s stair cinematic for ONE meaningful E entrance,
## R14 Bellroof Walk -> R17 Counterweight Spire (STORY_GUIDANCE.md pick).
## enter (render-only authored traversal) -> inherited 0.65 s loader -> arrive -> control.
## Never moves the collision body, never changes gates, graph, saves or the loader clock.
## Control ALWAYS returns: completion, pause, death/respawn, room rebuild, F6, watchdog.
const Data = preload("res://scripts/transition_pilot_data.gd")
const Art04 = preload("res://scripts/art04_presentation.gd")
const RUN_SCALE = 0.3825780535911868
const IDLE_SCALE = 0.2649908807267889

var enabled = false
var phase = ""            # "", "enter", "load", "arrive"
var key = ""
var source = -1
var target = -1
var arrival = Vector2.INF
var elapsed = 0.0          # time inside the current phase
var total = 0.0            # time since the E press (excluding paused frames)
var enter_time = 0.85
var arrive_time = 0.85
var releasing = false
var start_feet = Vector2.ZERO
var contact = Vector2.ZERO
var exit_heading = 1
var arrival_heading = 1
var rise = -1
var camera_state: Dictionary = {}
var proxy = Sprite2D.new()
var placeholder = ""
var destination = ""
var started = 0
var completed = 0
var aborted = 0
var last_result = ""
var last_duration = 0.0
var world
var cinematic
var layer = CanvasLayer.new()
var overlay = Node2D.new()

func configure(w,c,args:PackedStringArray):
	world=w;cinematic=c
	name="StagedStairCinematic"
	process_mode=Node.PROCESS_MODE_ALWAYS
	enabled=Data.STAGED_STAIR.flag in args
	proxy.visible=false
	add_child(proxy)
	layer.layer=2 # above the HUD fade: the wipe IS the transition composition.
	layer.process_mode=Node.PROCESS_MODE_ALWAYS
	add_child(layer)
	overlay.process_mode=Node.PROCESS_MODE_ALWAYS
	overlay.draw.connect(draw_overlay)
	layer.add_child(overlay)

func is_reduced() -> bool:
	return cinematic.reduced

func applies(w,t:int) -> bool:
	return enabled and cinematic.enabled and not cinematic.plain and "%d:%d"%[w.room,t] in Data.STAGED_STAIR.pairs

## Called by world.request_room after can_enter accepted. True = the request is
## owned (deferred into the enter phase, or swallowed while a sequence runs).
func intercept(w,t:int,at:Vector2) -> bool:
	if releasing: return false
	if phase!="": return true # no double trigger from repeated E presses
	if not applies(w,t): return false
	var pilot=w.embodied_transitions.PILOTS["%d:%d"%[w.room,t]]
	key="%d:%d"%[w.room,t];source=w.room;target=t;arrival=at
	exit_heading=int(pilot.exit_heading);arrival_heading=int(pilot.arrival_heading);rise=int(pilot.rise)
	contact=cinematic.endpoint(w,w.room,t).at-Vector2(0,2)
	start_feet=w.player.position
	destination=w.ROOM_NAMES[t]
	enter_time=Data.STAGED_STAIR.reduced_enter if is_reduced() else Data.STAGED_STAIR.enter
	arrive_time=Data.STAGED_STAIR.reduced_arrive if is_reduced() else Data.STAGED_STAIR.arrive
	phase="enter";elapsed=0.0;total=0.0;started+=1;last_result=""
	w.player.set_physics_process(false);w.player.velocity=Vector2.ZERO
	w.hud.clear_touches()
	camera_state={"zoom":w.camera.zoom,"position":w.camera.position,"offset":w.camera.offset,"smoothing":w.camera.position_smoothing_enabled}
	w.camera.position_smoothing_enabled=false
	w.player.sprite.visible=false;proxy.visible=true
	pose(w)
	return true

## Runs every world physics tick (from cinematic present()), AFTER the loader has
## re-enabled player physics, so the arrive hold takes effect in the same tick.
func tick(w):
	if phase=="": return
	var dt=get_physics_process_delta_time()
	elapsed+=dt;total+=dt
	if total>Data.STAGED_STAIR.watchdog and phase!="load":
		restore(w,"watchdog");return
	match phase:
		"enter":
			if elapsed>=enter_time-0.0001:
				phase="load";elapsed=0.0
				releasing=true
				w.player.sprite.visible=true # embodied captures a visible prior sprite
				w.request_room(target,arrival)
				releasing=false
				if w.transition<=0 or w.pending_room!=target:
					restore(w,"request_rejected");return
				w.player.sprite.visible=false
		"load":
			if w.transition<=0:
				if w.room==target:
					phase="arrive";elapsed=0.0
					w.player.set_physics_process(false)
				else:
					restore(w,"load_ended_elsewhere");return
			elif elapsed>2.0:
				restore(w,"watchdog");return
		"arrive":
			if elapsed>=arrive_time-0.0001:
				restore(w,"completed");return
	w.embodied_transitions.proxy.visible=false
	if phase in ["enter","arrive"]: w.player.sprite.visible=false
	pose(w)

func arrived(w):
	if phase!="load": return
	pose(w)

func room_loaded(w):
	if phase=="": return
	# The loader-owned swap into the target is the only rebuild a sequence survives.
	if phase=="load" and w.room==target and w.transition>0 and w.pending_room==-1: return
	restore(w,"room_changed")

func cancel(w):
	if phase!="": restore(w,"cancelled")

func reduced_changed(w):
	if phase=="": return
	if is_reduced():
		# Shorten what remains; never restart or extend a phase.
		if phase=="enter": enter_time=minf(enter_time,elapsed+Data.STAGED_STAIR.reduced_enter)
		arrive_time=minf(arrive_time,(elapsed if phase=="arrive" else 0.0)+Data.STAGED_STAIR.reduced_arrive)
		restore_camera(w)
	pose(w)

## Restores everything the sequence touched. In the load phase the inherited loader
## still owns player physics and re-enables it at its own clock expiry.
func restore(w,reason:String):
	var was=phase
	phase="";releasing=false
	if is_instance_valid(w.player):
		if was in ["enter","arrive"] and w.transition<=0: w.player.set_physics_process(true)
		w.player.sprite.visible=true
	proxy.visible=false;placeholder=""
	restore_camera(w)
	last_result=reason;last_duration=total
	if reason=="completed": completed+=1
	else: aborted+=1
	overlay.queue_redraw()

func restore_camera(w):
	if camera_state.is_empty(): return
	w.camera.zoom=camera_state.zoom;w.camera.position=camera_state.position
	w.camera.offset=camera_state.offset;w.camera.position_smoothing_enabled=camera_state.smoothing
	w.camera.reset_smoothing();camera_state.clear()

func _process(_dt):
	if phase=="" or not is_instance_valid(world): return
	if get_tree().paused: restore(world,"paused")
	elif world.player.hp<=0: restore(world,"died")
	overlay.queue_redraw()

func smooth(x:float) -> float:
	x=clampf(x,0,1);return x*x*(3.0-2.0*x)

func set_idle(w,heading:int,frame:int):
	proxy.texture=w.player.clips.idle;proxy.hframes=8;proxy.vframes=1;proxy.frame=frame
	proxy.scale=Vector2.ONE*IDLE_SCALE;proxy.offset=Vector2(0,proxy.texture.get_height()/2.0-591)
	proxy.flip_h=heading<0

func set_run(w,heading:int,frame:int):
	proxy.texture=w.player.clips.run;proxy.hframes=8;proxy.vframes=1;proxy.frame=frame
	proxy.scale=Vector2.ONE*RUN_SCALE;proxy.offset=Vector2(0,proxy.texture.get_height()/2.0-491)
	proxy.flip_h=heading<0

func set_key(name:String):
	proxy.texture=Art04.Frames.get_frame_texture(name,0);proxy.hframes=1;proxy.vframes=1;proxy.frame=0
	proxy.scale=Vector2.ONE*Art04.KEY_SCALE;proxy.offset=Art04.KEY_OFFSET;proxy.flip_h=false

## Render-only staging. Enter: approved run cycle to the contact, then the approved
## held ART-04 ascent key placed on three discrete treads (labelled, not a gait).
## Arrive: approved idle cycle on the landing while framing and wipe release.
func pose(w):
	proxy.modulate=Color.WHITE
	var still=is_reduced()
	var treads:Array=Data.STAGED_STAIR.treads
	if phase=="enter":
		var approach_time=0.25
		var dx=contact.x-start_feet.x
		if still:
			set_key("stair_up_key" if rise<0 else "stair_down_key");proxy.position=contact
			placeholder="REDUCED MOTION · HELD ART-04 STAIR KEY · FULL GAIT PENDING"
		elif elapsed<approach_time and absf(dx)>6:
			set_run(w,1 if dx>0 else -1,int(elapsed/0.08)%8)
			proxy.position=start_feet.lerp(contact,smooth(elapsed/approach_time))
			placeholder="APPROACH · APPROVED RUN CYCLE"
		else:
			set_key("stair_up_key" if rise<0 else "stair_down_key")
			var climb=clampf((elapsed-approach_time)/maxf(0.01,enter_time-approach_time),0,1)
			# Three measured treads: each contact eases in over 40% of its slot, then holds.
			var slot=minf(climb*treads.size(),treads.size()-0.001)
			var i=int(floorf(slot))
			var from:Vector2=Vector2.ZERO if i==0 else treads[i-1]
			proxy.position=contact+from.lerp(treads[i],smooth((slot-i)/0.4))
			placeholder="ASCENT · HELD ART-04 KEY ON 3 TREADS · FULL GAIT PENDING"
	elif phase=="load":
		if w.room==source: proxy.position=contact+treads[-1];set_key("stair_up_key" if rise<0 else "stair_down_key")
		else: set_idle(w,arrival_heading,0);proxy.position=w.player.position
		placeholder="LOADER 0.65 S (INHERITED)"
	elif phase=="arrive":
		set_idle(w,arrival_heading,int(elapsed/0.16)%8)
		proxy.position=w.player.position
		placeholder="ARRIVAL KEY PENDING · APPROVED IDLE CYCLE"
	frame_camera(w,still)
	overlay.queue_redraw()

func frame_camera(w,still:bool):
	if still or camera_state.is_empty(): return
	var amount=0.0
	if phase=="enter": amount=smooth(elapsed/maxf(0.01,enter_time*0.8))
	elif phase=="load": amount=1.0
	elif phase=="arrive": amount=1.0-smooth(elapsed/maxf(0.01,arrive_time))
	w.camera.zoom=camera_state.zoom*lerpf(1.0,Data.STAGED_STAIR.zoom,amount)
	var focus=proxy.position-w.player.position+Vector2(0,-70)
	w.camera.position=camera_state.position.lerp(focus,amount)
	w.camera.offset=camera_state.offset*(1.0-amount)
	w.camera.reset_smoothing()

## Sequence time in seconds from the E press, for the screen composition.
func timeline() -> float:
	if phase=="enter": return elapsed
	if phase=="load": return enter_time+clampf(0.65-world.transition,0,0.65)
	if phase=="arrive": return enter_time+0.65+elapsed
	return -1.0

## Leading edge of the wipe in AUTHORED (-x travel) screen space. Enters from the right
## late in the enter phase, covers the screen at the hidden swap (enter+0.33 s), holds
## through the loader, then exits left during the arrive phase.
func wipe_edge(s:float) -> float:
	var t0=enter_time-0.35
	var cover=enter_time+0.33
	var hold=enter_time+0.65
	if s<t0: return 2000.0
	if s<cover:
		var u=clampf((s-t0)/(cover-t0),0,1);return lerpf(1500,-300,1.0-(1.0-u)*(1.0-u))
	if s<hold: return lerpf(-300,-420,(s-cover)/(hold-cover))
	var v=clampf((s-hold)/0.45,0,1);return lerpf(-420,-2300,v*v)

## Kaze-original wind-cloth composition (TR02 direction: angled indigo/rose panels,
## pale thread lines, destination plate). Uses the Art Mane wipe kit when combined.
## No Persona artwork, font, logo or audio.
func draw_overlay():
	if phase=="" or not is_instance_valid(world): return
	var o=overlay
	var art=cinematic.art
	var font=ThemeDB.fallback_font
	var s=timeline()
	var full=enter_time+0.65+arrive_time
	var ivory=Color(0.95,0.9,0.8)
	var rose=Color(0.86,0.5,0.62)
	var indigo=Color(0.09,0.07,0.17)
	var title=("ASCEND  >  " if rise<0 else "DESCEND  >  ")+destination
	if is_reduced():
		# Static: one fixed plate, the inherited fade does the rest. No motion.
		draw_plate(o,art,Vector2(410,480),1.0,title,font,ivory,indigo)
		o.draw_string(font,Vector2(410,560),"TEMPORARY STAGING · "+placeholder,HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color(0.9,0.78,0.62))
		return
	# Letterbox: slanted bars in over 0.3 s, out over the final 0.4 s.
	var bars=smooth(s/0.3)*(1.0-smooth((s-(full-0.4))/0.4))
	var h=64.0*bars
	o.draw_colored_polygon(PackedVector2Array([Vector2(0,0),Vector2(1280,0),Vector2(1280,h-14*bars),Vector2(0,h+14*bars)]),Color(indigo,0.95))
	o.draw_colored_polygon(PackedVector2Array([Vector2(0,720),Vector2(1280,720),Vector2(1280,720-h-14*bars),Vector2(0,720-h+14*bars)]),Color(indigo,0.95))
	if bars>0.05:
		o.draw_line(Vector2(0,h+14*bars),Vector2(1280,h-14*bars),Color(rose,bars),3,true)
		o.draw_line(Vector2(0,720-h+14*bars),Vector2(1280,720-h-14*bars),Color(rose,bars),3,true)
	# Wind-cloth sweep, mirrored for a rightward exit so it travels with Kaze.
	var edge=wipe_edge(s)
	if edge>-2250 and edge<1600:
		if exit_heading>0: o.draw_set_transform(Vector2(1280,0),0,Vector2(-1,1))
		for row in Data.WIPE_ROWS:
			var x=edge+row[2];var y=row[0]
			if art.has("wipe_"+row[1]): o.draw_texture(art["wipe_"+row[1]],Vector2(x,y))
			else:
				# Procedural stand-in: 1822x488 band tilted about 6 degrees.
				var pts=PackedVector2Array([Vector2(x,y+96),Vector2(x+1822,y),Vector2(x+1822,y+392),Vector2(x,y+488)])
				o.draw_colored_polygon(pts,Color(0.2+0.04*row[0]/450.0,0.15,0.33,0.96))
				o.draw_line(Vector2(x,y+150),Vector2(x+1822,y+54),Color(rose,0.9),5,true)
				o.draw_line(Vector2(x,y+420),Vector2(x+1822,y+324),Color(ivory,0.5),2,true)
		o.draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
	# Destination plate fades in on enter, out at the end.
	var plate=smooth((s-0.1)/0.35)*(1.0-smooth((s-(full-0.35))/0.3))
	if plate>0.01: draw_plate(o,art,Vector2(lerpf(330,410,plate),480),plate,title,font,ivory,indigo)
	# Honest staging label, always legible inside the lower bar.
	if not placeholder.is_empty():
		o.draw_string(font,Vector2(470,708),"TEMPORARY STAGING · "+placeholder,HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color(0.9,0.78,0.62))

func draw_plate(o,art:Dictionary,at:Vector2,alpha:float,title:String,font,ivory:Color,indigo:Color):
	if art.has("wipe_badge"):
		o.draw_texture(art["wipe_badge"],at,Color(1,1,1,alpha))
		o.draw_string(font,at+Vector2(22,36),title,HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color(ivory,alpha))
	else:
		o.draw_colored_polygon(PackedVector2Array([at+Vector2(8,0),at+Vector2(460,0),at+Vector2(452,54),at+Vector2(0,54)]),Color(indigo,0.94*alpha))
		o.draw_line(at+Vector2(0,54),at+Vector2(452,54),Color(0.86,0.5,0.62,alpha),3)
		o.draw_string(font,at+Vector2(22,36),title,HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color(ivory,alpha))
