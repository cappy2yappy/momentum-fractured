extends SceneTree

## Run with -- --test-save-path=<isolated absolute save path>.
## Exercises authored collision geometry, real kunai impacts and door transitions.

const ROOM := "res://scenes/rooms/room_09_route.tscn"
var failures := 0
var checks := 0
var gate_events := 0
var map_events := 0


func _init() -> void:
	call_deferred("_run")


func _check(ok: bool, message: String) -> void:
	checks += 1
	print("PASS: " if ok else "FAIL: ", message)
	if not ok:
		failures += 1


func _frames(count: int = 4) -> void:
	for i in count:
		await physics_frame
		await process_frame


func _freeze_room(room: Node) -> void:
	room.get_node("Kaze").set_physics_process(false)
	var enemies := room.get_node_or_null("Enemies")
	if enemies:
		for enemy in enemies.get_children():
			enemy.set_physics_process(false)


func _transition(path: String, marker: String) -> Node:
	root.get_node("SceneNavigator").goto_scene(path, marker)
	for i in 180:
		await _frames(1)
		if current_scene != null and current_scene.scene_file_path == path and not root.get_node("SceneNavigator").is_transitioning:
			_freeze_room(current_scene)
			return current_scene
	_check(false, "Transition completed to " + path)
	return current_scene


func _door_transition(room: Node, door_name: String, target_path: String, arrival: String) -> Node:
	var door = room.get_node("Doors/" + door_name)
	var player = room.get_node("Kaze")
	door._cooldown_timer = 0.0
	player.global_position = door.global_position
	for i in 180:
		await _frames(1)
		if current_scene != null and current_scene.scene_file_path == target_path and not root.get_node("SceneNavigator").is_transitioning:
			_freeze_room(current_scene)
			var marker = current_scene.get_node("SpawnPoints/" + arrival)
			_check(current_scene.get_node("Kaze").global_position.distance_to(marker.global_position) < 45.0, "Real " + door_name + " arrives at " + arrival)
			return current_scene
	_check(false, "Real door collision transitions through " + door_name)
	return current_scene


func _shoot(room: Node2D, element: String) -> void:
	var projectile := Area2D.new()
	projectile.set_script(load("res://scripts/player/kunai_projectile.gd"))
	projectile.element = element
	projectile.direction = Vector2.LEFT
	projectile.position = Vector2(560, 650)
	room.add_child(projectile)
	await _frames(16)
	if is_instance_valid(projectile):
		projectile.queue_free()
	await _frames(2)


func _run() -> void:
	create_timer(35.0).timeout.connect(func() -> void:
		print("FAIL: Fire Return watchdog expired")
		quit(2)
	)
	await process_frame
	var state = root.get_node("GameState")
	if state.save_path == state.SAVE_PATH:
		print("FAIL: Isolated --test-save-path is required; no player save was changed")
		quit(2)
		return
	state.new_game()
	var navigator = root.get_node("SceneNavigator")
	navigator.fade_duration = 0.01
	var room := (load(ROOM) as PackedScene).instantiate()
	_check(room.get_node("RoomCamera").room_bounds == Rect2(0, 0, 1280, 1080), "Authored Fire Return has 1280x1080 camera bounds")
	_check(not room.build_default_environment and not room.spawn_default_grapple_anchors, "Room creates no procedural geometry or anchors")
	_check(room.get_node("Platforms").get_child_count() >= 14, "Dense authored traversal and seal partitions are explicit")
	_check(room.get_node("GrappleAnchors").get_child_count() >= 3, "Three deliberate return grapple anchors exist")
	_check(room.get_node("SpawnPoints/spawn_default").position == Vector2(1160, 936), "Canal intake default is exact")
	_check(room.get_node("SpawnPoints/entry_from_room8").position == Vector2(1160, 936), "Canal directional arrival is exact")
	_check(room.get_node("SpawnPoints/entry_from_room10").position.x > 451, "Campaign arrival remains east of the seal")
	var gate = room.get_node("Gates/FireSeal")
	_check(gate.position == Vector2(430, 650) and gate.blocker_size == Vector2(42, 260), "Fire gate spans the full 42x260 shortcut passage")
	_check(gate.get_node("CollisionShape2D").shape.size == gate.blocker_size, "Projectile detection covers entire Fire seal")
	var shortcut = room.get_node("Doors/ExitShortcut")
	_check(shortcut.required_gate_id == "gate_fire_return" and shortcut.target_spawn_marker == "entry_shortcut", "Shortcut requires persistent Fire gate and named Surface balcony")
	_check(room.get_node("Doors/ExitWater").position.x > 451 and room.get_node("Doors/ExitCampaign").position.x > 451, "Both required campaign exits remain on intake side")
	root.add_child(room)
	current_scene = room
	await _frames()
	_freeze_room(room)
	_check(shortcut.is_locked and not gate.is_open, "New game physically seals and locks shortcut")
	_check(not room.get_node("Doors/ExitWater").is_locked and not room.get_node("Doors/ExitCampaign").is_locked, "Canal retreat and forward campaign route remain open before Fire")
	shortcut._cooldown_timer = 0.0
	room.get_node("Kaze").global_position = shortcut.global_position
	await _frames(6)
	_check(current_scene == room and not navigator.is_transitioning, "Actual shortcut doorway overlap cannot transition while gate is closed")
	room.get_node("Kaze").global_position = Vector2(1160, 936)
	await _frames()
	# Real doorway overlaps verify the long campaign route remains available.
	room = await _door_transition(room, "ExitWater", "res://scenes/rooms/room_08_route.tscn", "entry_from_room9")
	room = await _transition(ROOM, "entry_from_room8")
	room = await _door_transition(room, "ExitCampaign", "res://scenes/rooms/room_10_route.tscn", "entry_from_room9")
	room = await _transition(ROOM, "entry_from_room10")
	gate = room.get_node("Gates/FireSeal")
	shortcut = room.get_node("Doors/ExitShortcut")
	var player = room.get_node("Kaze")
	player.global_position = Vector2(510, 650)
	await _frames()
	_check(player.test_move(player.global_transform, Vector2(-160, 0)), "Closed seal stops a real Kaze collision shape crossing its passage")
	var sealed_cross_sections := true
	for y in range(30, 1040, 10):
		var query := PhysicsRayQueryParameters2D.create(Vector2(470, y), Vector2(390, y), 1)
		if room.get_world_2d().direct_space_state.intersect_ray(query).is_empty():
			sealed_cross_sections = false
	_check(sealed_cross_sections, "Continuous ceiling-to-floor collision leaves no jump, dash or wall-jump gap")
	_check(not player.call("_has_grapple_line_of_sight", room.get_node("GrappleAnchors/return_anchor_03").global_position), "Sealed architecture blocks shortcut-anchor line of sight")
	player.global_position = Vector2(510, 725)
	player.velocity = Vector2(-900, -555)
	player.set_physics_process(true)
	Input.action_press("move_left")
	Input.action_press("jump")
	Input.action_press("dash")
	var stayed_east := true
	for i in 80:
		await _frames(1)
		if player.global_position.x < 451:
			stayed_east = false
	Input.action_release("move_left")
	Input.action_release("jump")
	Input.action_release("dash")
	player.set_physics_process(false)
	player.global_position = Vector2(510, 650)
	player.velocity = Vector2.ZERO
	await _frames()
	_check(stayed_east, "Live jump/dash and high incoming momentum cannot cross sealed architecture")
	state.gate_opened.connect(func(id: String) -> void:
		if id == "gate_fire_return":
			gate_events += 1
	)
	state.map_changed.connect(func() -> void: map_events += 1)
	await _shoot(room, "wind")
	_check(not gate.is_open and gate.blocker.collision_layer == 1, "Real Wind projectile collision cannot open Fire seal")
	await _shoot(room, "electric")
	_check(not gate.is_open and not state.is_gate_open("gate_fire_return"), "Real Electric projectile collision preserves closed gate state")
	await _shoot(room, "fire")
	_check(gate.is_open and gate.blocker.collision_layer == 0, "Real Fire projectile disables seal blocker")
	_check(state.is_gate_open("gate_fire_return") and not shortcut.is_locked, "Fire impact persists gate and immediately unlocks shortcut door")
	_check(gate_events == 1 and map_events >= 1, "Opening emits exactly one gate event and updates the map")
	_check(not player.test_move(player.global_transform, Vector2(-160, 0)), "Kaze collision shape can cross opened seal passage")
	await _shoot(room, "fire")
	_check(gate_events == 1, "Repeated Fire cannot duplicate gate unlock")
	state.manual_save()
	state.opened_gates.clear()
	_check(state.load_from_disk() and state.is_gate_open("gate_fire_return"), "Full disk save/load preserves opened Fire seal")
	for enemy in room.get_node("Enemies").get_children():
		enemy.get_node("Health").take_damage(10000)
	await _frames(24)
	_check(state.is_room_cleared("room_09_route"), "Authored return encounter records its clear state")
	state.set_checkpoint(ROOM, "entry_from_room8")
	state.restore_from_checkpoint()
	_check(state.is_gate_open("gate_fire_return"), "Checkpoint health restore preserves Fire gate progression")
	room = await _door_transition(room, "ExitShortcut", "res://scenes/rooms/room_05_route.tscn", "entry_shortcut")
	room = await _transition(ROOM, "entry_from_room8")
	gate = room.get_node("Gates/FireSeal")
	_check(gate.is_open and gate.blocker.collision_layer == 0, "Room re-entry starts with saved gate open")
	_check(gate_events == 1, "Re-entry does not replay gate unlock event")
	_check(room.get_node("Enemies").get_child_count() == 0, "Cleared return encounter does not respawn on re-entry")
	room.get_node("Kaze/Health").take_damage(10000)
	for i in 180:
		await _frames(1)
		if current_scene != room and current_scene != null and not navigator.is_transitioning:
			break
	_check(current_scene != room and current_scene.scene_file_path == ROOM, "Actual player death reloads the configured return checkpoint")
	room = current_scene
	_freeze_room(room)
	gate = room.get_node("Gates/FireSeal")
	_check(gate.is_open and gate.blocker.collision_layer == 0 and state.is_gate_open("gate_fire_return"), "Actual death/checkpoint reload preserves gate opening")
	_check(not room.get_node("Doors/ExitWater").is_locked and not room.get_node("Doors/ExitCampaign").is_locked, "Required campaign routes remain available after unlocking shortcut")
	current_scene = null
	room.queue_free()
	await _frames()
	print("FIRE RETURN REGRESSION: %d failure(s), %d checks" % [failures, checks])
	quit(1 if failures else 0)
