extends Node2D
## A presentation-only study over live pinned geometry. All reservations are world-space.
var world
var bank
var code = ''
var room = 0
var art_on = true
var guides = false
var reduced_motion = false
var motion_time = 0.0
var response_time = 0.0
var response_rect = Rect2()
var layer_enabled = [true,true,true,true]
var layers: Array = []
var surfaces: Array = []
var faces: Array = []
var recesses: Array = []
var air_cells: Array = []
var far_details: Array = []
var decor: Array = []
var exclusions: Array = []
var reserved: Array = []
var counts: Dictionary = {}
var rejected = 0
var palette: Array = []
var art11_layer
func reserve(id: String, rect: Rect2):
	exclusions.append(rect); reserved.append({'id':id,'rect':rect})
	counts[id] = counts.get(id,0)+1
func clear_of(rect: Rect2, zones: Array) -> bool:
	for zone in zones:
		if rect.intersects(zone): return false
	return true
func split_rect(rect: Rect2, cut: Rect2) -> Array:
	if not rect.intersects(cut): return [rect]
	var overlap=rect.intersection(cut)
	var parts=[Rect2(rect.position,Vector2(rect.size.x,overlap.position.y-rect.position.y)),Rect2(Vector2(rect.position.x,overlap.end.y),Vector2(rect.size.x,rect.end.y-overlap.end.y)),Rect2(Vector2(rect.position.x,overlap.position.y),Vector2(overlap.position.x-rect.position.x,overlap.size.y)),Rect2(Vector2(overlap.end.x,overlap.position.y),Vector2(rect.end.x-overlap.end.x,overlap.size.y))]
	return parts.filter(func(p): return p.size.x>1 and p.size.y>1)
func subtract(rect: Rect2,zones: Array) -> Array:
	var pieces=[rect]
	for zone in zones:
		var next: Array=[]
		for piece in pieces: next.append_array(split_rect(piece,zone))
		pieces=next
	return pieces
func configure(host, textures, script_dir, art11_dir):
	world=host;bank=textures;code=script_dir;room=host.room
	palette={0:[Color('233e48'),Color('779591'),Color('d4c5a4')],4:[Color('273b4d'),Color('7a7e87'),Color('cabfa3')],14:[Color('302f49'),Color('837d91'),Color('cbbb96')],16:[Color('1d3834'),Color('607b69'),Color('c5c8a0')]}[room]
	for r in world.platforms:
		if r.position.x>=0 and r.position.x<world.room_size(room).x: surfaces.append(r)
	var portals=world.expansion.portals(room)
	if room>0 and room<13: portals.append({'at':world.left_exit_position()})
	if room<12: portals.append({'at':world.right_exit_position()})
	for portal in portals:
		reserve('door_approach',Rect2(portal.at-Vector2(220,300),Vector2(440,360)))
		reserve('door_label',Rect2(portal.at-Vector2(180,270),Vector2(360,330)))
	var anchors=world.tether_anchors.duplicate()
	for anchor in world.get_tree().get_nodes_in_group('kaze_grapple_anchor'):
		if world.is_ancestor_of(anchor):
			var at=world.to_local(anchor.get_attachment_position())
			if not at in anchors:anchors.append(at)
	for at in anchors:reserve('grapple',Rect2(at-Vector2(110,110),Vector2(220,220)))
	reserve('room_title',Rect2(940,210,720,90))
	for hazard in world.expansion.hazards: reserve('hazard',hazard.grow(64))
	for gate in world.kunai_gates: reserve('gate',Rect2(gate.position-Vector2(90,gate.height+70),Vector2(180,gate.height+140)))
	for enemy in world.enemies:
		var left=minf(enemy.position.x-300,enemy.patrol_min-80)
		var right=maxf(enemy.position.x+300,enemy.patrol_max+80)
		reserve('enemy_lane',Rect2(left,enemy.position.y-210,right-left,250))
	if world.expansion.LORE.has(room): reserve('lore',Rect2(world.expansion.LORE[room]-Vector2(130,190),Vector2(260,230)))
	if room==0:
		reserve('checkpoint',Rect2(80,1120,300,240))
		# Whole existing gatehouse and its passage remain presentation-owned by TR08.
		reserve('canal_doorway',Rect2(240,430,1120,430))
	if room==4:
		reserve('pickup',Rect2(960,880,240,200))
		reserve('water_gap',Rect2(450,1240,550,200));reserve('water_gap',Rect2(1280,1240,770,200))
	if room==14:
		reserve('service_sign',Rect2(20,1210,430,85))
		for at in [Vector2(170,1155),Vector2(1440,1070),Vector2(2190,1180)]: reserve('service_sign',Rect2(at-Vector2(20,35),Vector2(200,65)))
		reserve('stair_framing',Rect2(1150,300,650,330))
	if room==16: reserve('checkpoint',Rect2(280,910,300,270))
	reserve('player',Rect2(world.player.position-Vector2(90,190),Vector2(180,230)))
	# Every real landing receives a walking/feet envelope. Never decorative foliage on it.
	var decor_zones=exclusions.duplicate()
	for r in surfaces: decor_zones.append(Rect2(r.position-Vector2(32,105),Vector2(r.size.x+64,125)))
	for r in surfaces:
		if r.size.y<20: continue
		var inset=Rect2(r.position+Vector2(4,6),r.size-Vector2(8,10))
		if inset.size.x>2 and inset.size.y>2: faces.append_array(subtract(inset,exclusions))
		if r.size.y>=100:
			var recess=Rect2(r.position+Vector2(24,42),Vector2(r.size.x-48,r.size.y-56))
			if recess.size.x>30 and recess.size.y>20: recesses.append_array(subtract(recess,exclusions))
	var air_zones=decor_zones.duplicate()
	for r in surfaces: air_zones.append(r.grow(4))
	air_cells=subtract(Rect2(Vector2.ZERO,world.room_size(room)),air_zones)
	for x in range(140,int(world.room_size(room).x),420):
		var r=Rect2(x,210,80,260)
		if clear_of(r,air_zones): far_details.append(r)
		else: rejected+=1
	# Cosmetic foreground envelopes are finite and collision-free. No branch/connector added.
	for r in surfaces:
		if r.size.x<250 or r.position.y<600: continue
		var at=r.position+Vector2(r.size.x*0.35,r.size.y+95)
		var rect=Rect2(at-Vector2(8,80),Vector2(20,80))
		if clear_of(rect,decor_zones) and clear_of(rect,surfaces): decor.append({'type':'cord','rect':rect})
		else: rejected+=1
	for at in [Vector2(80,620),Vector2(world.room_size(room).x-85,620)]:
		var rect=bank.rect('hanging',at)
		if clear_of(rect,decor_zones) and clear_of(rect,surfaces): decor.append({'type':'asset','id':'hanging','at':at,'rect':rect})
		else: rejected+=1
	if room==16:
		var lamp=Rect2(610,1030,50,50)
		if clear_of(lamp,decor_zones): decor.append({'type':'lamp','rect':lamp})
		# Exact inherited ART11 renderer, in memory only. Its source stays unchanged.
		art11_layer=load(art11_dir.path_join('presentation.gd')).new()
		art11_layer.bank=bank;add_child(art11_layer);art11_layer.setup_room(world,'moss')
		# Tighten exclusions for this comparison without changing ART11 source/placements.
		art11_layer.foliage=art11_layer.foliage.filter(func(item): return clear_of(bank.rect(item.id,item.at),decor_zones))
		art11_layer.backgrounds=art11_layer.backgrounds.filter(func(item): return clear_of(bank.rect(item.id,item.at),exclusions))
		var filtered: Array=[]
		for face in art11_layer.surface_art: filtered.append_array(subtract(face,exclusions))
		art11_layer.surface_art=filtered
	for i in 4:
		var layer=load(code.path_join('paint.gd')).new();layer.study=self;layer.kind=i;add_child(layer);layers.append(layer)
	for cell in air_cells:
		if cell.size.x>=80 and cell.size.y>=80 and cell.position.y>300:
			response_rect=Rect2(cell.position+Vector2(6,6),Vector2(60,60));break
	set_state(true,false)
func set_state(on: bool,overlay: bool):
	art_on=on;guides=overlay
	if is_instance_valid(art11_layer): art11_layer.art_enabled=on;art11_layer.paused_motion=reduced_motion
	queue_redraw()
func preview_response():
	if not reduced_motion: response_time=1.8
func _process(delta):
	if not reduced_motion: motion_time+=delta;response_time=maxf(0,response_time-delta)
	if is_instance_valid(art11_layer): art11_layer.paused_motion=reduced_motion
	queue_redraw()
func _draw():
	if not guides: return
	for r in surfaces: draw_rect(r,Color(0.2,0.95,1,0.85),false,2)
	for row in reserved: draw_rect(row.rect,Color(1,0.65,0.2,0.65),false,2)
	for item in decor: draw_rect(item.rect,Color(0.8,0.4,1,0.8),false,2)
func audit() -> Dictionary:
	var violations: Array=[]
	for kind in ['faces','recesses','far_details','air_cells']:
		for rect in get(kind):
			if not clear_of(rect,exclusions):violations.append(kind+' intersects reservation')
	for rect in faces:
		var inside=false
		for surface in surfaces:
			if surface.encloses(rect): inside=true;break
		if not inside: violations.append('face outside collision')
	for item in decor:
		if not clear_of(item.rect,exclusions):violations.append('decor intersects reservation')
		for r in surfaces:
			if item.rect.intersects(Rect2(r.position-Vector2(32,105),Vector2(r.size.x+64,125))):violations.append('decor intersects walk/feet envelope')
	var rects=[]
	for row in reserved:rects.append({'id':row.id,'rect':[row.rect.position.x,row.rect.position.y,row.rect.size.x,row.rect.size.y]})
	return {'room':room,'four_layers':layers.size(),'surfaces':surfaces.size(),'faces':faces.size(),'recesses':recesses.size(),'far_details':far_details.size(),'air_cells':air_cells.size(),'foreground_objects':decor.size(),'protected_counts':counts,'reservations':rects,'rejected_candidates':rejected,'violations':violations,'new_physics_nodes':0,'category_C_devices':0,'integration_enabled':false,'R16_comparison_only':room==16}
