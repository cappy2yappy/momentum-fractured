extends SceneTree
# Seeded missed-shelf probes with real collision/gravity. No full campaign claim.
var failures=0
func _init(): call_deferred("run")
func check(ok,message):
	print("PASS: " if ok else "FAIL: ",message)
	if not ok: failures+=1
func run():
	await process_frame
	var w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w
	w.set_physics_process(false);w.player.set_physics_process(false)
	for mode in ["ordinary","stride","momentum"]:
		w.player.restore_speed_upgrade(0 if mode=="ordinary" else 1)
		w.player.momentum.enabled=mode=="momentum"
		for index in [14,15,17,19]:
			w.build_room(index);w.player.set_physics_process(false)
			for e in w.enemies: e.set_physics_process(false)
			var top=w.Expansion.SHELVES[index][0]
			for r in w.Expansion.SHELVES[index]:
				if r.position.y<top.position.y: top=r
			w.player.position=Vector2(top.end.x+36,top.position.y-30)
			w.player.velocity=Vector2.ZERO;w.player.dash_time=0;w.player.release_tether()
			w.player.set_physics_process(true)
			var landed=false
			for tick in 240:
				await physics_frame
				if tick>10 and w.player.is_on_floor(): landed=true;break
			w.player.set_physics_process(false)
			check(landed and w.player.position.y>top.position.y,"%s room %d missed top shelf falls to a lower collision landing at %s"%[mode,index,w.player.position])
			check(w.camera.zoom==Vector2.ONE,"%s room %d retains ordinary camera zoom"%[mode,index])
	# The existing vents warn during phase 2 and become damaging only in phase 3.
	w.build_room(15);w.player.set_physics_process(false)
	var h=w.expansion.hazards[0];w.player.position=h.get_center()+Vector2(0,30)
	w.player.hp=3;w.player.invulnerable=0;w.player.age=2.5;w.expansion.update(w,0)
	check(w.player.hp==3,"Vent warning phase is non-damaging")
	w.player.age=3.5;w.expansion.update(w,0)
	check(w.player.hp==2,"Vent active phase damages after warning")
	w.queue_free();current_scene=null
	for tick in 3: await process_frame
	print("INTEGRATION DESCENT: %d failure(s)"%failures);quit(1 if failures else 0)
