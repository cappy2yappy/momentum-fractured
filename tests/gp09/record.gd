extends SceneTree
const Demo = preload("res://scripts/gp09/vertical_slice.gd")
var w
var stage = 0
var age = 0.0
var total = 0.0
var pulse = 0
func _init(): call_deferred("start")
func start():
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--gp09-save="): DirAccess.remove_absolute(arg.trim_prefix("--gp09-save="))
	w = Demo.new(); root.add_child(w); current_scene = w
func release():
	for action in ["left","right","attack","parry","jump","interact"]: Input.action_release(action)
func next():
	release(); stage += 1; age = 0; print("RECORD stage ",stage)
func move_to(x):
	Input.action_release("left"); Input.action_release("right")
	if abs(w.player.position.x-x) > 15:
		Input.action_press("right" if w.player.position.x<x else "left")
		return false
	return abs(w.player.velocity.x)<80
func _process(dt):
	if not is_instance_valid(w): return false
	total += dt; age += dt; pulse += 1
	if total > 55:
		print("RECORD TIMEOUT stage ",stage," position ",w.player.position); release(); quit(1); return false
	match stage:
		0:
			if age > 1: next()
		1:
			if move_to(850): next()
		2:
			if age > 0.5:
				w.interact(); next()
		3:
			if age > 2.0: w.story.panel.advance(); next()
		4:
			if age > 2.0: w.story.panel.close(); next()
		5:
			if w.story.has(w.PRESENTED) and not w.enemies.is_empty(): next()
		6:
			var enemy = w.enemies[0] if not w.enemies.is_empty() else null
			if not is_instance_valid(enemy): next()
			else:
				move_to(enemy.position.x-65)
				if abs(w.player.position.x-enemy.position.x)<125:
					if pulse % 8 == 0: Input.action_press("attack")
					else: Input.action_release("attack")
					if enemy.state == "windup" and enemy.timer < 0.2: Input.action_press("parry")
					else: Input.action_release("parry")
		7:
			if move_to(1640): next()
		8:
			if age > 1 and w.steam.phase == "recovery" and w.steam.elapsed < 0.4: next()
		9:
			if move_to(2180): next()
		10:
			if age > 0.8: w.interact(); next()
		11:
			if age > 1.4: next()
		12:
			if move_to(2460): next()
		13:
			if age > 0.5: w.interact(); next()
		14:
			if w.exited: next()
		15:
			if age < 0.5: Input.action_press("right")
			elif age < 0.6: Input.action_release("right"); Input.action_press("jump")
			else: Input.action_release("jump")
			if age > 2.0:
				release(); print("RECORDED COMPLETE: normal movement, real combat, vent timing, recovery and exit")
				w.queue_free(); current_scene = null; quit(0)
	return false
