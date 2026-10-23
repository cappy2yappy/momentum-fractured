extends "res://tools/ld05/room_probe.gd"

func signature():
	var rects=[]
	for r in w.boundary_rects:rects.append([r.position.x,r.position.y,r.size.x,r.size.y])
	return {"room":statics(w.room),"boundaries":rects,"polygons":w.boundary_polys.duplicate(true)}

func run():
	await process_frame
	w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w;freeze();seed_fixture();automation_hud()
	var ot=w.RoomBoundary.OpenTop
	var before={};var after={}
	ot.ENABLED=false
	for index in 21:
		reset(index);before[str(index)]=signature()
	ot.ENABLED=true
	for index in 21:
		reset(index);after[str(index)]=signature()
		check(JSON.stringify(before[str(index)].room)==JSON.stringify(after[str(index)].room),"R%d platforms, gates, anchors, enemies and endpoints unchanged"%index)
		if index not in [13,17]:
			check(before[str(index)].boundaries==after[str(index)].boundaries and before[str(index)].polygons==after[str(index)].polygons,"R%d other boundary geometry unchanged"%index)
			check(w.camera.limit_top==0,"R%d camera limit restored"%index)
		else:
			check(not w.RoomBoundary.roof_active(index) and w.camera.limit_top==-800,"R%d open top is default with visible overhead space"%index)
			var expected=ot.pieces(index)
			var oldroof=w.RoomBoundary.roof_rect(w)
			check(not w.boundary_rects.has(oldroof),"R%d wall-to-wall roof collider removed"%index)
			for r in expected:
				check(w.boundary_rects.has(r) and r.end.y<=0,"R%d upper structure %s is present and does not enter existing vertical routes"%[index,r])
			await physics_frame;await physics_frame
			var space=w.player.get_world_2d().direct_space_state
			var ray=PhysicsRayQueryParameters2D.create(Vector2(900,-1000),Vector2(900,0),1)
			check(space.intersect_ray(ray).is_empty(),"R%d central sky is physically open (ray from y=-1000 to y=0)"%index)
			for r in expected:
				var query=PhysicsPointQueryParameters2D.new();query.position=r.get_center();query.collision_mask=1
				check(not space.intersect_point(query).is_empty(),"R%d drawn rectangle %s has real collision"%[index,r])
	# Serialize valid target-room checkpoints and load a NEW world. The production save/clamp/respawn code is unchanged.
	for spec in [[13,Vector2(500,438),Vector2(500,438)],[17,Vector2(1300,418),Vector2(1300,418)]]:
		reset(spec[0]);seed_fixture();w.player.speed_upgrade_level=1
		w.checkpoint_room=spec[0];w.checkpoint_position=spec[1]
		w.save_path="user://ld08_checkpoint.json";w.test_mode=false
		check(w.save_progress(),"R%d checkpoint fixture serialized"%spec[0])
		var saved=JSON.parse_string(FileAccess.get_file_as_string(w.save_path))
		w.queue_free();current_scene=null
		await process_frame
		w=load("res://scenes/main.tscn").instantiate();w.save_path="user://ld08_checkpoint.json";root.add_child(w);current_scene=w;freeze();automation_hud()
		check(w.room==spec[0] and w.player.position==spec[2],"R%d startup load stages %s to %s"%[spec[0],spec[1],spec[2]])
		check(w.player.double_jump and w.player.dash_unlocked and w.player.tether_unlocked and w.player.speed_upgrade_level==1 and w.opened_kunai_gates.get("spire_wind_shutter",false) and w.expansion_flags.get("junction_return",false),"Earned kit, Stride and progression survive boundary checkpoint handling")
		check(saved==JSON.parse_string(FileAccess.get_file_as_string(w.save_path)),"Startup does not rewrite the saved file or its schema")
		w.respawn();freeze()
		check(w.player.position==spec[2] and w.room==spec[0],"Respawn stays supported in the same room")
		await physics_frame;await physics_frame
		var query=PhysicsShapeQueryParameters2D.new();query.shape=w.player.get_child(0).shape;query.transform=w.player.get_child(0).global_transform;query.collision_mask=1
		check(w.player.get_world_2d().direct_space_state.intersect_shape(query).is_empty(),"Restored capsule is clear of solids")
	var f=FileAccess.open("res://docs/ld08/evidence/geometry_contract.json",FileAccess.WRITE);f.store_string(JSON.stringify({"checks":checks,"failures":failures,"roof_reference":before,"candidate":after},"  "));f.close()
	w.queue_free();current_scene=null
	for i in 3:await process_frame
	print("LD08 CONTRACT: %d checks, %d failure(s)"%[checks,failures]);quit(1 if failures else 0)
