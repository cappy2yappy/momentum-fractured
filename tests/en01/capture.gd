extends SceneTree
## Render actual controller/enemy ticks; no mocked player or fabricated combat poses.
var w
var output = ""
func _init(): call_deferred("run")
func ticks(n):
	for i in n: await physics_frame
func capture(label):
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(output.path_join(label + ".png"))
func run():
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output="): output = arg.trim_prefix("--output=")
	if output.is_empty(): push_error("Provide --output=<absolute folder>"); quit(2); return
	DirAccess.make_dir_recursive_absolute(output)
	for mode in ["guard","ranged","ambush","combined"]:
		w=load("res://scenes/encounters/"+mode+".tscn").instantiate()
		root.add_child(w); current_scene=w
		await ticks(5)
		if mode=="combined":
			w.camera.zoom=Vector2(0.48,0.48)
			w.camera.position=Vector2(1300,360)-w.player.position
			await capture("combined_overview")
			w.camera.zoom=Vector2.ONE; w.camera.position=Vector2(0,-110)
		w.player.touch["right"]=true
		# Walk into activation with the real controller.
		for i in 95 if mode=="ranged" else 45: await physics_frame
		w.player.touch["right"]=false
		if mode=="ranged":
			# The cover is solid. Jump it before approaching the attacker.
			w.player.touch["jump"]=true; w.player.press("jump"); w.player.touch["right"]=true
			await ticks(48); w.player.touch["right"]=false; w.player.touch["jump"]=false
		await capture(mode+"_approach")
		var enemy=w.enemies[0]
		for i in 240:
			await physics_frame
			if enemy.state=="windup": break
		await capture(mode+"_telegraph")
		if mode=="ranged":
			while enemy.state=="windup" and enemy.timer>0.2: await physics_frame
			w.player.touch["jump"]=true; w.player.press("jump")
			await ticks(20); await capture(mode+"_jump_dodge")
		else:
			w.player.press("dash"); await ticks(5); await capture(mode+"_dash")
		w.free(); current_scene=null; await process_frame
	print("EN01 RENDERED CAPTURES COMPLETE")
	quit()
