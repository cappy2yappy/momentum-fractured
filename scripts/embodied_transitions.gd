extends Node2D
## TR-03 render adapter. The existing world owns gates, freeze, swap and arrivals.
## ART-04 is an explicit opt-in held-key comparison; legacy staging is retained.
const Art04Presentation = preload("res://scripts/art04_presentation.gd")
var production_art = Art04Presentation.new()
var art_preview = false
const PILOTS = {
	"14:17": {"mode":"stair_up","exit_heading":1,"arrival_heading":-1,"rise":-1},
	"17:14": {"mode":"stair_down","exit_heading":-1,"arrival_heading":1,"rise":1},
}
const DEPTH_DEMO = {"14:13":{"exit_heading":1,"arrival_heading":-1},"13:14":{"exit_heading":-1,"arrival_heading":1}}
const RUN_SCALE = 0.3825780535911868
const IDLE_SCALE = 0.2649908807267889
var comparison = "refined"
var depth_demo = false
var structural_dressing = true
var active = false
var mode = "fallback"
var approach_motion = "idle"
var source_room = -1
var target_room = -1
var departure = Vector2.ZERO
var arrival_anchor = Vector2.ZERO
var initial_position = Vector2.ZERO
var arrived_event = false
var exit_heading = 1
var arrival_heading = 1
var rise = 0
var clip_phase = 0.0
var prior_sprite_visible = true
var proxy = Sprite2D.new()
var world
var placeholder = ""

func configure(w):
	world=w
	process_mode=Node.PROCESS_MODE_ALWAYS
	z_index=4
	proxy.show_behind_parent=true
	proxy.visible=false
	add_child(proxy)
	var args=OS.get_cmdline_user_args()
	if "--tr03-original" in args: comparison="original"
	if "--tr03-plain" in args or (w.mixed_transitions.graphic_mode=="plain" and comparison!="original"): comparison="plain"
	if "--tr03-reduced-motion" in args or w.mixed_transitions.graphic_mode=="reduced": comparison="reduced"
	art_preview="--tr03-art-preview" in args
	if art_preview and comparison=="refined": comparison="art-preview"
	depth_demo="--tr03-depth-demo" in args
	structural_dressing=not "--tr03-no-dressing" in args and comparison!="original"
	if comparison in ["plain","reduced"]: w.mixed_transitions.graphic_mode=comparison
	for arg in args:
		if arg.begins_with("--tr03-save="):
			var path=arg.trim_prefix("--tr03-save=")
			if path.is_absolute_path(): w.save_path=path

func production_active() -> bool:
	return (art_preview or comparison=="art-preview") and not comparison in ["original","plain"]

func policy(w,index:int,target:int) -> Dictionary:
	var key="%d:%d"%[index,target]
	if w.mixed_transitions.is_special(index,target): return {"mode":"wind_fold","trigger":"interact"}
	if w.mixed_transitions.is_walk(index,target):
		return {"mode":"horizontal_walk","trigger":"directional","dynamic_run":true,"exit_heading":w.MixedTransitions.WALK[index].direction,"arrival_heading":w.MixedTransitions.WALK[index].direction}
	if key in PILOTS: return PILOTS[key].duplicate()
	if depth_demo and key in DEPTH_DEMO:
		var result=DEPTH_DEMO[key].duplicate();result.mode="depth_door";result.trigger="interact";return result
	return {"mode":"fallback","reason":"orientation not authored; preserve existing presentation"}

func begin(w,target:int):
	cancel(w)
	var selected=policy(w,w.room,target)
	mode=selected.mode
	if comparison in ["original","plain"] or mode in ["fallback","wind_fold"]: return
	# Air/dash/tether use the unchanged TR-02 graphic, never counterfeit ground steps.
	if mode=="horizontal_walk" and (not w.mixed_transitions.active_walk or not w.player.is_on_floor() or w.player.dash_time>0 or w.player.tether_attached):
		mode="fallback";return
	source_room=w.room;target_room=target
	initial_position=w.player.position;departure=initial_position
	for p in w.expansion.portals(w.room):
		if p.target==target: departure=p.at
	exit_heading=selected.get("exit_heading",w.player.facing)
	arrival_heading=selected.get("arrival_heading",exit_heading)
	rise=selected.get("rise",0)
	approach_motion="run" if w.player.run and absf(w.player.velocity.x)>w.player.movement_target_speed(false)+10 else "walk"
	if mode=="horizontal_walk" and approach_motion=="run": mode="horizontal_run"
	clip_phase=w.player.animation_clock
	placeholder="" if mode=="horizontal_run" else ("WALK POSES PENDING" if mode=="horizontal_walk" else ("TURN / REAR POSES PENDING" if mode=="depth_door" else "STAIR POSES PENDING"))
	prior_sprite_visible=w.player.sprite.visible
	proxy.hframes=8;proxy.vframes=1
	# Current clips keep their exact existing registration. New pack320x724/pivot160,600
	# is documented for the later accepted-art adapter, not applied to old textures.
	var is_run=mode=="horizontal_run" or mode in ["stair_up","stair_down"]
	proxy.texture=w.player.clips["run" if is_run else "idle"]
	proxy.scale=Vector2.ONE*(RUN_SCALE if is_run else IDLE_SCALE)
	proxy.offset=Vector2(0,proxy.texture.get_height()/2.0-(491 if is_run else 591))
	proxy.frame=w.player.sprite.frame if mode=="horizontal_run" else 0
	proxy.position=initial_position;proxy.flip_h=exit_heading<0;proxy.modulate=Color.WHITE
	w.player.sprite.visible=false;proxy.visible=prior_sprite_visible
	active=true;arrived_event=false
	if production_active(): production_art.update_pose(self,w,0)
	queue_redraw()

func arrived(w):
	if not active: return
	# The authoritative callback follows actual build_room and safe feet placement.
	arrived_event=true;arrival_anchor=w.player.position
	proxy.position=arrival_anchor
	update_pose(w)

func cancel(w):
	if active and is_instance_valid(w.player) and is_instance_valid(w.player.sprite): w.player.sprite.visible=prior_sprite_visible
	active=false;proxy.visible=false;arrived_event=false;placeholder=""
	production_art.selected_key=""
	queue_redraw()

func room_loaded(w):
	queue_redraw()
	# External rebuild/load must not leave a hidden character; the loader-owned swap
	# is the only build permitted to continue its proxy through the swap callback.
	if active and (w.transition<=0 or w.pending_room!=-1 or w.room!=target_room): cancel(w)

func _process(_dt):
	# Pause cancels only visual staging. The existing frozen loader resumes unchanged.
	if active and (get_tree().paused or not is_instance_valid(world) or world.player.hp<=0):
		if is_instance_valid(world): cancel(world)

func update_pose(w):
	if not active: return
	if w.transition<=0: cancel(w);return
	var elapsed=clampf(0.65-w.transition,0,0.65)
	var t=clampf((elapsed-0.34)/0.31,0,1) if arrived_event else clampf(elapsed/0.33,0,1)
	var anchor=arrival_anchor if arrived_event else departure
	var heading=arrival_heading if arrived_event else exit_heading
	if production_art.update_pose(self,w,t):
		queue_redraw();return
	proxy.flip_h=heading<0
	var base_scale=RUN_SCALE if mode in ["horizontal_run","stair_up","stair_down"] else IDLE_SCALE
	proxy.scale=Vector2.ONE*base_scale
	proxy.modulate=Color.WHITE
	if comparison=="reduced":
		proxy.position=anchor;proxy.frame=0;queue_redraw();return
	if mode in ["horizontal_walk","horizontal_run"]:
		# Display-only continuation bounded to the existing safe aperture. Physics
		# velocity is neither sampled back from this curve nor altered by it.
		proxy.position=anchor+Vector2(heading*lerpf(-24,0,t) if arrived_event else heading*24*t,0)
		if mode=="horizontal_run": proxy.frame=int((clip_phase+elapsed)/0.08)%8
		else: proxy.frame=int(elapsed/0.16)%2
	elif mode in ["stair_up","stair_down"]:
		var step=floorf((t if arrived_event else clampf((t-0.3)/0.7,0,1))*3.0)/3.0
		proxy.position=anchor+Vector2(heading*lerpf(-32,0,step),rise*lerpf(-24,0,step)) if arrived_event else initial_position.lerp(anchor,clampf(t/0.3,0,1))+Vector2(heading*32*step,rise*24*step)
		proxy.frame=int(elapsed/0.08)%8
		# Current run poses are an expressly labeled adapter; separate up/down final
		# clips are required. The three local contacts are not the entire staircase.
	elif mode=="depth_door":
		if arrived_event:
			proxy.position=anchor+Vector2(0,lerpf(-22,0,t))
			proxy.scale=Vector2(base_scale*lerpf(0.62,1,t),base_scale*lerpf(0.88,1,t))
		else:
			var approach=clampf(t/0.3,0,1)
			proxy.position=initial_position.lerp(anchor,approach)
			var turn=clampf((t-0.3)/0.35,0,1)
			var inward=clampf((t-0.65)/0.35,0,1)
			proxy.scale=Vector2(base_scale*lerpf(1,0.62,turn),base_scale*lerpf(1,0.88,inward))
			proxy.position.y-=22*inward
		proxy.frame=0
	queue_redraw()

func handles_overlay(w) -> bool:
	return active and w.transition>0 and mode!="wind_fold"

func draw_exit(w,at:Vector2) -> bool:
	if production_art.draw_exit(self,w,at): return true
	if not depth_demo or comparison=="original": return false
	var selected=false
	for p in w.expansion.portals(w.room):
		if p.at==at and policy(w,w.room,p.target).mode=="depth_door": selected=true
	if not selected: return false
	w.draw_rect(Rect2(at+Vector2(-60,-142),Vector2(120,142)),Color("34343e"))
	w.draw_rect(Rect2(at+Vector2(-43,-125),Vector2(86,125)),Color("11151f"))
	w.draw_line(at+Vector2(-43,0),at+Vector2(43,0),Color("d3c4a8"),5)
	w.draw_rect(Rect2(at+Vector2(40,-125),Vector2(16,125)),Color("68636a"))
	w.draw_line(at+Vector2(-43,0),at+Vector2(-28,-22),Color("847e7d"),3)
	w.draw_string(ThemeDB.fallback_font,at+Vector2(-80,-160),"INWARD DOOR · E / DEMO",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("d3c4a8"))
	return true

func draw_dressing(w):
	if production_active():
		production_art.draw_supports(self,w);return
	if not structural_dressing: return
	if w.room==14:
		# One existing shelf(750,900,400,40): beams end in a continuous roof backing.
		w.draw_rect(Rect2(714,932,472,160),Color("262b36"))
		for x in [732,1168]: w.draw_rect(Rect2(x-12,930,24,170),Color("363d47"))
		w.draw_line(Vector2(750,948),Vector2(1150,948),Color("48505a"),10)
		w.draw_line(Vector2(800,949),Vector2(732,1050),Color("54565b"),10)
		w.draw_line(Vector2(1100,949),Vector2(1168,1050),Color("54565b"),10)
	elif w.room==15:
		# One existing shelf(1320,940,400,40): masonry load paths reach recovery floor.
		w.draw_rect(Rect2(1300,978,440,322),Color("27393f"))
		for x in [1344,1688]:
			w.draw_rect(Rect2(x-18,1002,36,298),Color("354a50"))
			w.draw_colored_polygon(PackedVector2Array([Vector2(x-35,980),Vector2(x+35,980),Vector2(x+18,1040),Vector2(x-18,1040)]),Color("4e6265"))

func draw_overlay(h,w,alpha:float) -> bool:
	if not handles_overlay(w):
		# Plain selected pilots suppress inherited rotating stair accents as well.
		return comparison=="plain" and policy(w,w.pending_from_room,w.pending_room if w.pending_room>=0 else w.room).mode in ["stair_up","stair_down","depth_door"]
	h.draw_rect(Rect2(360,486,560,58),Color(0.06,0.07,0.11,alpha*0.92))
	var title={"horizontal_walk":"WALK THROUGH","horizontal_run":"RUN THROUGH","depth_door":"INWARD DOOR · DEMO","stair_up":"STAIR · ASCEND","stair_down":"STAIR · DESCEND"}.get(mode,mode)
	h.draw_string(ThemeDB.fallback_font,Vector2(380,510),title+"  /  "+w.ROOM_NAMES[target_room],HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color(0.9,0.86,0.78,alpha))
	if not placeholder.is_empty(): h.draw_string(ThemeDB.fallback_font,Vector2(380,533),"TEMPORARY STAGING · "+placeholder,HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color(0.84,0.72,0.58,alpha))
	return true

func _draw():
	if production_active():
		production_art.draw_front(self);return
	if not active: return
	var at=arrival_anchor if arrived_event else departure
	if mode=="depth_door":
		# Foreground near jamb masks the proxy's final inward edge, not live actors.
		draw_rect(Rect2(at+Vector2(26,-125),Vector2(18,125)),Color("45434b"))
		draw_line(at+Vector2(-42,0),at+Vector2(42,0),Color("c5b8a0"),3)
	elif mode in ["stair_up","stair_down"]:
		for i in 3:
			var x=exit_heading*float(i)*12
			var y=rise*float(i)*8
			draw_line(at+Vector2(x-10,y+3),at+Vector2(x+10,y+3),Color("a6a7a6"),3)
