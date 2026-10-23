extends Node2D
## Read-only visual child. Never creates physics, timers for damage, or save state.
var bank
var mode = ""
var world
var subject
var clock = 0.0
var paused_motion = false
var overlay = false
var art_enabled = true
var surfaces: Array = []
var surface_art: Array = []
var label_zones: Array = []
var foliage: Array = []
var exclusions: Array = []
var backgrounds: Array = []
var protected_counts = {"doors":0,"anchors":0,"hazards":0,"checkpoints":0,"gates":0}
var observed: Dictionary = {}
var phase = "idle"
var rejected = 0
var use_orange = false
func _ready():
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	if mode == "hazard":
		subject.phase_changed.connect(on_phase)
		subject.enabled_changed.connect(on_enabled)
		on_phase(subject.phase)
func on_phase(value): phase = value; observed[value] = true; queue_redraw()
func on_enabled(_value): queue_redraw()
func _process(delta):
	if not paused_motion: clock += delta
	if mode == "enemy" and is_instance_valid(subject):
		phase = subject.state; observed[phase] = true
	queue_redraw()
func setup_room(host, style):
	world = host; mode = style
	for surface in host.platforms:
		if surface.position.x >= 0 and surface.position.x < host.room_size(host.room).x:
			surfaces.append(surface)
	for portal in host.expansion.portals(host.room):
		protected_counts.doors += 1
		label_zones.append(Rect2(portal.at+Vector2(-108,-8),Vector2(216,56)))
		exclusions.append(Rect2(portal.at-Vector2(200,200),Vector2(400,400)))
	for anchor in host.tether_anchors:
		exclusions.append(Rect2(anchor-Vector2(100,100),Vector2(200,200)))
	for anchor in host.get_tree().get_nodes_in_group("kaze_grapple_anchor"):
		if host.is_ancestor_of(anchor):
			var at = host.to_local(anchor.get_attachment_position())
			exclusions.append(Rect2(at-Vector2(100,100),Vector2(200,200)))
			protected_counts.anchors += 1
	for hazard in host.expansion.hazards:
		exclusions.append(hazard.grow(48)); protected_counts.hazards += 1
	for gate in host.kunai_gates:
		exclusions.append(Rect2(gate.position-Vector2(64,gate.height+48),Vector2(128,gate.height+96)))
		protected_counts.gates += 1
	if host.room == 16:
		# Checkpoint interaction and its marker: world_expansion.gd interact/draw_room.
		exclusions.append(Rect2(300,940,240,200)); protected_counts.checkpoints += 1
	if host.expansion.LORE.has(host.room):
		exclusions.append(Rect2(host.expansion.LORE[host.room]-Vector2(90,160),Vector2(180,180)))
	for enemy in host.enemies:
		exclusions.append(Rect2(enemy.position-Vector2(270,180),Vector2(540,200)))
	for surface in surfaces:
		if surface.size.x < 240 or surface.position.y < 550: continue
		for fraction in [0.31,0.68]:
			var at = Vector2(surface.position.x+surface.size.x*fraction,surface.position.y)
			var id = "grass" if fraction < 0.5 or mode == "cave" else "flower"
			var rect = bank.rect(id,at)
			var clear = true
			for exclusion in exclusions:
				if rect.intersects(exclusion): clear = false; break
			if clear: foliage.append({"id":id,"at":at})
			else: rejected += 1
	# Leave original doorway thresholds/underfoot status labels visible.
	for surface in surfaces:
		var pieces = [surface]
		for reserved in label_zones:
			var clipped = []
			for piece in pieces:
				if not piece.intersects(reserved): clipped.append(piece); continue
				if reserved.position.x > piece.position.x: clipped.append(Rect2(piece.position,Vector2(reserved.position.x-piece.position.x,piece.size.y)))
				if reserved.end.x < piece.end.x: clipped.append(Rect2(Vector2(reserved.end.x,piece.position.y),Vector2(piece.end.x-reserved.end.x,piece.size.y)))
			pieces = clipped
		surface_art.append_array(pieces)
	var proposed = [{"id":"column","at":Vector2(190,720)},{"id":"column","at":Vector2(1100,1300)},{"id":"hanging","at":Vector2(600,760)}] if mode=="moss" else [{"id":"cave_rocks","at":Vector2(730,1260)},{"id":"cave_rocks","at":Vector2(1750,1260)}]
	for item in proposed:
		var clear = true
		for zone in exclusions:
			if bank.rect(item.id,item.at).intersects(zone): clear = false; break
		if clear: backgrounds.append(item)
		else: rejected += 1
func tile(surface: Rect2, id: String):
	var tex = bank.frame(id,0)
	var row = bank.manifest.assets[id]
	var src = Rect2(2,2,row.content_size[0],row.content_size[1])
	draw_rect(surface,Color("1b2828") if mode == "moss" else Color("22252c"))
	var x = surface.position.x
	while x < surface.end.x:
		var width = minf(src.size.x,surface.end.x-x)
		var height = minf(40,surface.size.y)
		draw_texture_rect_region(tex,Rect2(x,surface.position.y,width,height),Rect2(src.position,Vector2(width,height)),Color("b2c2b7") if mode == "moss" else Color("abb7c1"))
		x += width
	draw_line(surface.position,Vector2(surface.end.x,surface.position.y),Color("bed3b5") if mode == "moss" else Color("b6c7ce"),2)
func _draw():
	if bank == null: return
	if mode in ["moss","cave"]:
		if art_enabled:
			# Recessed forms are low contrast; no art bridge spans a gameplay gap.
			for item in backgrounds: bank.paint(self,item.id,item.at,0,Color(0.36,0.48,0.44,0.28))
			for surface in surface_art: tile(surface,"moss_surface" if mode=="moss" else "cave_surface")
			for item in foliage: bank.paint(self,item.id,item.at,clock,Color("9dbba7"),paused_motion)
		if overlay:
			for surface in surfaces: draw_rect(surface,Color(0.35,0.94,1,0.9),false,2)
			for zone in exclusions: draw_rect(zone,Color(1,0.6,0.25,0.22),false,2)
	elif mode == "hazard" and is_instance_valid(subject):
		if not art_enabled: return
		var dims = subject.placement.dimensions
		var colors = {"idle":Color("9caf99"),"warning":Color("ffce66"),"active":Color("ff8a91"),"recovery":Color("8a9d9d")}
		var tint = colors.get(phase,Color.WHITE) if subject.available() else Color("64736d")
		# The plant stays inside the existing sensor; default warning/hatch/text draw above it.
		bank.paint(self,"poison",Vector2(dims.x/2,dims.y),clock,tint,paused_motion)
		if overlay: draw_rect(Rect2(Vector2.ZERO,dims),Color.CYAN,false,2)
	elif mode == "enemy" and is_instance_valid(subject):
		if art_enabled:
			bank.paint(self,"slime_orange" if use_orange else "slime_green",Vector2.ZERO,clock,Color("ddd6ab") if phase=="stunned" else Color.WHITE,paused_motion)
		if overlay:
			# Target circle, NOT a new collision body. Core radius at the existing projectile-query center (projectile margin is additional).
			draw_arc(Vector2(0,-50),subject.hit_radius,0,TAU,48,Color.CYAN,2)
