extends "res://tests/expansion_traversal.gd"
# Reuse the collision/input harness; test return traversal of all refined routes.
func run():
	await process_frame
	w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w
	w.set_physics_process(false);w.player.set_physics_process(false)
	w.player.double_jump=true;w.player.tether_unlocked=true;w.player.dash_unlocked=true
	w.player.momentum.enabled=false;w.player.restore_speed_upgrade(0)
	for gate in ["lower_sluice_wind","spire_wind_shutter","pump_electric_isolator","coil_fire_service"]:
		w.opened_kunai_gates[gate]=true
	for index in [14,15,17,19]:
		w.build_room(index);w.player.set_physics_process(false)
		for e in w.enemies: e.set_physics_process(false)
		await process_frame
		var steps=w.expansion.route_steps.duplicate()
		for i in range(steps.size()-1,0,-1): await leap(steps[i],steps[i-1],index)
	w.queue_free();current_scene=null
	for tick in 3: await process_frame
	print("WORLD COHESION RETURN TRAVERSAL: %d failure(s)"%failures)
	quit(1 if failures else 0)
