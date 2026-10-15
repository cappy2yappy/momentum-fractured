extends "res://tests/embodied_transitions.gd"
# Actual loader ticks; production preview only changes render resources/contacts.
func art_reset(index,comparison="art-preview"):
	reset(index)
	w.embodied_transitions.art_preview=true
	w.embodied_transitions.comparison=comparison
	w.embodied_transitions.depth_demo=true
	w.embodied_transitions.structural_dressing=true
func run():
	await process_frame
	w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w;freeze();seed_fixture()
	print("ART04_PROFILE=",OS.get_user_data_dir())
	var e=w.embodied_transitions;var a=e.production_art
	for key in ["turn_depth_key","enter_depth_key","stair_up_key","stair_down_key"]:
		check(a.Frames.get_frame_count(key)==1 and not a.Frames.get_animation_loop(key),key+" remains one nonlooping key")
		check(a.Frames.get_frame_texture(key,0).get_size()==Vector2(320,724),key+" has fixed 320x724 registration")
	for comparison in ["art-preview","reduced"]:
		for pair in [[14,17],[17,14],[14,13],[13,14]]:
			art_reset(pair[0],comparison)
			var p=portal(pair[0],pair[1]);w.player.position=p.at-Vector2(0,2);w.player.velocity=Vector2(173,-20);w.player.animate(0)
			var feet=w.player.position;var scale=w.player.sprite.scale;var offset=w.player.sprite.offset
			w.interact()
			check(w.transition==0.65 and e.active and not w.player.sprite.visible and e.proxy.visible,"%s %s starts exactly one proxy on unchanged clock"%[comparison,pair])
			for tick in 12: w._physics_process(1.0/60.0)
			check(w.player.position==feet and w.player.velocity==Vector2(173,-20),"%s %s leaves departure simulation untouched"%[comparison,pair])
			if pair[0]==14 and pair[1]==13:
				check(a.selected_key==("enter_depth_key" if comparison=="reduced" else "turn_depth_key"),"Depth uses authored turn before inward contact; reduced holds inward key")
				w._physics_process(1.0/60.0)
				check(a.selected_key=="enter_depth_key","Depth advances once to authored inward key")
			elif pair[1]==17 or pair[0]==17:
				check(a.selected_key==("stair_up_key" if pair[0]==14 else "stair_down_key"),"Distinct up/down art follows explicit local orientation")
				check(not e.proxy.flip_h and e.proxy.frame==0 and e.proxy.hframes==1,"Authored stair key is held, never mirrored or cycled")
			else:
				check(a.selected_key.is_empty() and e.proxy.texture==w.player.clips.idle,"Unsupported outward direction uses labelled approved-idle fallback")
			if not a.selected_key.is_empty():
				check(e.proxy.scale==Vector2.ONE*0.303125 and e.proxy.offset==Vector2(0,-238),"Production pose keeps uniform scale and fixed pivot without squeeze")
			if comparison=="reduced":
				var at=e.proxy.position;w._physics_process(1.0/60.0)
				check(e.proxy.position==at and e.proxy.frame==0,"Reduced art preview has no staged translation or cycling")
			while w.room==pair[0]: w._physics_process(1.0/60.0)
			check(w.room==pair[1] and w.player.position==p.arrival,"Production preview respects actual swap event and exact reciprocal arrival")
			check(a.selected_key.is_empty() and e.proxy.texture==w.player.clips.idle,"Arrival never invents a front-quarter/reversed-back pose")
			for tick in 24: w._physics_process(1.0/60.0)
			freeze()
			check(w.player.sprite.visible and not e.active and not e.proxy.visible,"Completion restores actual sprite and removes proxy")
			check(w.player.sprite.scale==scale and w.player.sprite.offset==offset,"Actual sprite registration remains untouched")
	# Unmodified loader tick threshold under production presentation.
	art_reset(14);w.player.position=portal(14,17).at;w.interact();finish()
	for reason in ["pause","death","rebuild","denied"]:
		art_reset(14);w.player.position=portal(14,17).at
		if reason=="denied": w.player.dash_unlocked=false
		w.interact()
		if reason=="pause":
			paused=true;await process_frame;await process_frame;paused=false
		elif reason=="death": w.checkpoint_room=0;w.respawn();freeze()
		elif reason=="rebuild": w.build_room(15);freeze()
		check(not e.active and not e.proxy.visible and w.player.sprite.visible,"Art cleanup restores representation on "+reason)
		check(a.selected_key.is_empty(),"Art key state clears on "+reason)
	for index in [14,15,17]:
		art_reset(index);var signature=JSON.stringify(w.platforms);var count=w.geometry.get_child_count();var gates=JSON.stringify(w.opened_kunai_gates)
		for comparison in ["original","refined","art-preview","reduced","plain"]:
			e.comparison=comparison;w.build_room(index);freeze()
			check(JSON.stringify(w.platforms)==signature and w.geometry.get_child_count()==count and JSON.stringify(w.opened_kunai_gates)==gates,"R%d %s retains exact collision/geometry/gates"%[index,comparison])
	art_reset(14)
	check(a.suppresses_legacy(e,14,Rect2(850,700,200,600)),"Overlapping R14 procedural roof is suppressed in art preview")
	check(not a.suppresses_legacy(e,14,Rect2(1500,700,200,600)),"Unrelated R14 procedural roof remains")
	check(a.suppresses_legacy(e,15,Rect2(1290,900,320,490)),"Overlapping R15 arch is suppressed")
	e.comparison="refined";e.art_preview=false
	check(not a.suppresses_legacy(e,14,Rect2(850,700,200,600)),"Original/refined drawing remains available byte-for-byte in legacy paths")
	art_reset(17)
	check(a.stair_rect(w).end.x==w.room_size(17).x,"R17 artwork clips at existing room boundary without stretching")
	# Both directions still gate; all 58 endpoints preserve original policy.
	check(e.policy(w,20,13).mode=="wind_fold","Art preview leaves exceptional wind-fold policy intact")
	w.queue_free();current_scene=null
	for tick in 3: await process_frame
	print("ART04 TRANSITIONS: %d assertions, %d failure(s)"%[assertions,failures]);quit(1 if failures else 0)
