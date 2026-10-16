extends RefCounted
## Pinned ART-04 assets. Four held keys, never animation cycles or physics input.
const Frames = preload("res://assets/art04/kaze/ART04_key_poses.tres")
const Roof = preload("res://assets/art04/environment/r14_roof_support.png")
const Masonry = preload("res://assets/art04/environment/r15_masonry_support.png")
const DoorInside = preload("res://assets/art04/environment/r14_door_interior.png")
const DoorBack = preload("res://assets/art04/environment/r14_door_back.png")
const DoorFront = preload("res://assets/art04/environment/r14_door_front.png")
const Stair = preload("res://assets/art04/environment/stair_flight_right.png")
const StairLip = preload("res://assets/art04/environment/stair_front_lip.png")
const KEY_SCALE = 0.303125
const KEY_OFFSET = Vector2(0,-238)
const SUPPORT_BOUNDS = {14:Rect2(706,922,488,186),15:Rect2(1292,970,456,338)}
const STAIR_ANCHORS = {14:Vector2(1450,480),17:Vector2(1680,1300)}
var selected_key = ""

func set_key(e, key:String):
	selected_key=key
	e.proxy.texture=Frames.get_frame_texture(key,0)
	e.proxy.hframes=1;e.proxy.vframes=1;e.proxy.frame=0
	e.proxy.offset=KEY_OFFSET;e.proxy.scale=Vector2.ONE*KEY_SCALE
	e.proxy.flip_h=false;e.proxy.modulate=Color.WHITE

func fallback(e,w,heading:int):
	selected_key=""
	e.proxy.texture=w.player.clips.idle;e.proxy.hframes=8;e.proxy.vframes=1;e.proxy.frame=0
	e.proxy.offset=Vector2(0,e.proxy.texture.get_height()/2.0-591)
	e.proxy.scale=Vector2.ONE*e.IDLE_SCALE;e.proxy.flip_h=heading<0;e.proxy.modulate=Color.WHITE

func update_pose(e,w,t:float) -> bool:
	if not e.production_active() or not e.mode in ["stair_up","stair_down","depth_door"]: return false
	# Missing outward/opposite-facing arrival art is an explicit approved-idle
	# fallback, never a mirrored rear key or squeezed character.
	if e.arrived_event:
		fallback(e,w,e.arrival_heading)
		e.proxy.position=e.arrival_anchor
		e.placeholder="ARRIVAL / OUTWARD KEY PENDING · APPROVED IDLE"
		return true
	var still=e.comparison=="reduced"
	if e.mode=="depth_door":
		if e.source_room!=14:
			fallback(e,w,e.exit_heading);e.proxy.position=e.departure
			e.placeholder="REVERSE / OUTWARD KEY PENDING · APPROVED IDLE"
		elif still or t>=0.3:
			set_key(e,"enter_depth_key" if still or t>=0.65 else "turn_depth_key")
			e.proxy.position=e.departure-Vector2(0,2 if still else 2+22*clampf((t-0.65)/0.35,0,1))
			e.placeholder="HELD ART-04 KEY · TURN / ENTRY CYCLE PENDING"
		else:
			fallback(e,w,e.exit_heading)
			e.proxy.position=e.initial_position.lerp(e.departure-Vector2(0,2),t/0.3)
			e.placeholder="APPROACH · FOUR KEYS ARE NOT CYCLES"
	else:
		set_key(e,"stair_up_key" if e.mode=="stair_up" else "stair_down_key")
		var contact=e.departure-Vector2(0,2)
		# Fixed, reviewed contact registration. No three-frame loop fabricated
		# from a single drawing; the inherited 0.65s loader remains authoritative.
		e.proxy.position=contact if still else e.initial_position.lerp(contact,clampf(t/0.3,0,1))
		e.placeholder="HELD ART-04 CONTACT · %s CYCLE PENDING"%e.mode.to_upper()
	return true

func suppresses_legacy(e,index:int,bounds:Rect2) -> bool:
	return e.production_active() and e.structural_dressing and index in SUPPORT_BOUNDS and SUPPORT_BOUNDS[index].intersects(bounds)

func draw_supports(e,w):
	if not e.production_active() or not e.structural_dressing: return
	if w.room==14: w.draw_texture(Roof,Vector2(706,922))
	elif w.room==15: w.draw_texture(Masonry,Vector2(1292,970))
	elif w.room==17:
		# Recessed wall return closes the cropped stair silhouette at the wall.
		# Same approved atlas; background only, never an extra collision column.
		var material=preload("res://assets/web/terrain-materials.png")
		w.draw_texture_rect_region(material,Rect2(1776,1210,24,130),Rect2(0,96,24,130),Color(0.5,0.52,0.6))

func is_door(e,w,at:Vector2) -> bool:
	if w.cinematic_transitions.automatic(w,w.room,13): return false
	return e.production_active() and e.depth_demo and w.room==14 and at==Vector2(120,1100)

func stair_rect(w) -> Rect2:
	var top=STAIR_ANCHORS[w.room]+Vector2(-120,-48.2)
	return Rect2(top,Vector2(minf(384,w.room_size(w.room).x-top.x),89.6))

func draw_stair(canvas,w,texture):
	var rect=stair_rect(w)
	# R17 is explicitly clipped at its existing right boundary, not reflected or
	# stretched to fit; same local contact registration as the R14 fixture.
	canvas.draw_texture_rect_region(texture,rect,Rect2(0,0,rect.size.x,112))

func draw_exit(e,w,at:Vector2) -> bool:
	if not e.production_active(): return false
	if is_door(e,w,at):
		w.draw_texture(DoorInside,at-Vector2(120,208))
		w.draw_texture(DoorBack,at-Vector2(120,208))
		return true
	if w.room in STAIR_ANCHORS and at==STAIR_ANCHORS[w.room]:
		draw_stair(w,w,Stair)
		return true
	return false

func draw_front(e):
	var w=e.world
	if not e.production_active() or not is_instance_valid(w): return
	if is_door(e,w,Vector2(120,1100)):
		var at=Vector2(120,1100)
		e.draw_texture(DoorFront,at-Vector2(120,208))
		draw_cue(e,w,at,13,"DEPTH DOOR · E")
	if w.room in STAIR_ANCHORS:
		draw_stair(e,w,StairLip)
		var target=17 if w.room==14 else 14
		draw_cue(e,w,STAIR_ANCHORS[w.room],target,"LOCAL STAIR · E")

func draw_cue(canvas,w,at:Vector2,target:int,label:String):
	var allowed=false
	for p in w.expansion.portals(w.room):
		if p.target==target: allowed=w.expansion.allowed(w,p.need)
	var color=Color("f4db96") if allowed else Color("d49b87")
	canvas.draw_rect(Rect2(at+Vector2(-78,18),Vector2(190,25)),Color("202532"))
	canvas.draw_string(ThemeDB.fallback_font,at+Vector2(-72,36),label if allowed else "LOCKED · "+label,HORIZONTAL_ALIGNMENT_LEFT,-1,13,color)
