extends SceneTree
var world
var player
var failures = 0
func _initialize(): call_deferred("run")
func check(value,message):
	if value: print("PASS: ",message)
	else: push_error("FAIL: "+message); failures += 1
func ticks(count):
	for i in count: await physics_frame
func tap(action):
	Input.action_press(action)
	await ticks(2)
	Input.action_release(action)
func walk_to(x):
	var action = "right" if x > player.position.x else "left"
	Input.action_press(action)
	for i in 600:
		await physics_frame
		if absf(player.position.x-x) < 10: break
	Input.action_release(action)
	await ticks(12)
func run():
	world = load("res://scenes/main.tscn").instantiate()
	root.add_child(world)
	player = world.player
	await ticks(12)
	check(player.is_on_floor(),"Spawn settles on real collision floor")
	await tap("right")
	await ticks(3)
	Input.action_press("right")
	await ticks(18)
	check(player.run and player.velocity.x > 500,"Double-tap enters run")
	Input.action_release("right")
	await ticks(15)
	var before = player.position.y
	Input.action_press("jump")
	await ticks(20)
	check(player.position.y < before-150,"Held jump reaches useful height")
	Input.action_release("jump")
	await ticks(5)
	await tap("jump")
	check(not player.air_used,"Double jump starts locked")
	await ticks(65)
	await walk_to(2430)
	await tap("interact")
	await ticks(50)
	check(world.room == 1,"Passage reaches guard station")
	if world.room != 1: quit(1); return
	Input.action_press("right")
	for i in 300:
		await physics_frame
		if world.guard.position.x-player.position.x < 85: break
	Input.action_release("right")
	await ticks(6)
	for i in 180:
		await physics_frame
		if world.guard.state == "windup" and world.guard.timer < 0.16: break
	player.facing = int(signf(world.guard.position.x-player.position.x))
	await tap("parry")
	await ticks(15)
	check(world.guard.state == "stunned" and player.hp == 3,"Timed parry prevents damage and stuns")
	for i in 12:
		await tap("attack")
		await ticks(10)
		if world.guard_defeated: break
	check(world.guard_defeated,"Combo attacks defeat guard")
	if not world.guard_defeated: quit(1); return
	await walk_to(1570)
	await ticks(5)
	check(player.double_jump,"Encounter and scroll unlock Windstep")
	await walk_to(130)
	await tap("interact")
	await ticks(50)
	check(world.room == 0,"Return passage reconnects to shrine")
	await walk_to(360)
	Input.action_press("right"); Input.action_press("jump")
	await ticks(34)
	Input.action_release("right"); Input.action_release("jump")
	await ticks(30)
	check(player.is_on_floor() and player.position.y < 1120,"Normal jump reaches first ascent")
	await walk_to(675)
	Input.action_press("jump")
	await ticks(24)
	Input.action_release("jump")
	await ticks(2)
	Input.action_press("right"); Input.action_press("jump")
	await ticks(32)
	Input.action_release("jump"); Input.action_release("right")
	await ticks(35)
	check(player.is_on_floor() and player.position.y < 790,"Double jump reaches upper route")
	await walk_to(915)
	Input.action_press("left"); Input.action_press("jump")
	await ticks(51)
	Input.action_release("left"); Input.action_release("jump")
	await ticks(25)
	await walk_to(390)
	await tap("interact")
	check(world.completed,"Relay completes exploration loop")
	player.position = Vector2(1500,600); player.velocity = Vector2.ZERO
	await ticks(3)
	player.air_used = false; player.coyote = 0
	player.velocity = Vector2(300,30)
	Input.action_press("right"); Input.action_press("jump")
	await ticks(3)
	check(player.air_used and player.velocity.y < -700 and player.velocity.x > 250,"Air jump retains momentum")
	Input.action_release("jump"); await ticks(2)
	Input.action_press("jump"); await ticks(2)
	check(player.velocity.y > -700,"Third jump rejected")
	Input.action_release("jump"); Input.action_release("right")
	player.position = Vector2(16,600); player.velocity = Vector2.ZERO
	Input.action_press("left"); await ticks(10)
	Input.action_press("jump"); await ticks(2)
	check(player.velocity.x > 0 and player.velocity.y < 0,"Boundary supports wall jump")
	Input.action_release("left"); Input.action_release("jump")
	world.hud.toggle_map()
	var pos = player.position
	await process_frame; await process_frame
	check(paused and player.position == pos,"Map pauses gameplay")
	world.hud.toggle_map()
	player.position = Vector2(1500,1200); player.velocity = Vector2.ZERO
	await ticks(40)
	var start = player.position
	var touch = InputEventScreenTouch.new()
	touch.index = 1; touch.position = Vector2(160,650); touch.pressed = true
	world.hud._input(touch)
	touch = InputEventScreenTouch.new()
	touch.index = 2; touch.position = Vector2(1200,650); touch.pressed = true
	world.hud._input(touch)
	await ticks(15)
	check(player.position.x > start.x+30 and player.position.y < start.y-100,"Multi-touch movement and jump")
	touch.pressed = false; world.hud._input(touch)
	check(world.player.touch.get("right",false),"Jump release preserves movement finger")
	world.hud.clear_touches()
	world.save_path = "user://canal_route_test.json"
	world.test_mode = false
	world.save_progress()
	player.double_jump = false; world.completed = false
	world.load_progress()
	check(player.double_jump and world.completed,"Save reload preserves earned progress")
	DirAccess.remove_absolute(world.save_path)
	print("RESULT: ",failures," failures")
	quit(1 if failures else 0)
