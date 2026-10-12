extends SceneTree

## Runtime coverage for selectively recovered stability fixes.
## Run through tools/validate_recovery.py, which isolates logs and save files.
## Direct runs need --log-file and -- --test-save-path=<absolute isolated path>.
## This suite intentionally creates save data; keep it separate from play saves.

var failures := 0
var checks := 0


func _init() -> void:
	call_deferred("_run")


func _check(condition: bool, message: String) -> void:
	checks += 1
	print("PASS: " if condition else "FAIL: ", message)
	if not condition:
		failures += 1


func _frames(count: int = 4) -> void:
	for _index in count:
		await physics_frame
		await process_frame


func _run() -> void:
	# A script error must not silently strand a CI process indefinitely.
	var watchdog := create_timer(25.0)
	watchdog.timeout.connect(func() -> void:
		print("FAIL: Recovery regression exceeded its 25 second watchdog")
		quit(2)
	)
	await process_frame
	root.get_node("GameState").call("new_game")
	await _check_damage_numbers()
	await _check_melee_collisions()
	await _check_guard_veil_collisions()
	await _check_checkpoint_without_scene()
	await _check_checkpoint_round_trip()
	await _check_audio_teardown()
	_check_detached_helpers()
	print("RECOVERY REGRESSION: %d failure(s), %d checks" % [failures, checks])
	quit(1 if failures > 0 else 0)


func _check_damage_numbers() -> void:
	var camera := Camera2D.new()
	camera.position = Vector2(840.0, 430.0)
	root.add_child(camera)
	camera.make_current()
	var feedback := root.get_node("CombatFeedback")
	var target := Vector2(930.0, 550.0)
	for zoom_value in [1.0, 2.0]:
		camera.zoom = Vector2.ONE * zoom_value
		camera.force_update_scroll()
		await process_frame
		var transform := root.get_canvas_transform()
		_check(not transform.is_equal_approx(Transform2D.IDENTITY), "Camera creates a nonidentity canvas transform at %.1fx zoom" % zoom_value)
		var index: int = feedback.get("_pool_index")
		feedback.call("spawn_damage_number", target, 15.0, false)
		var labels: Array = feedback.get("_pool")
		var label := labels[index] as Label
		var center := transform * (target + Vector2(0.0, -42.0))
		_check(label.visible and label.text == "15", "Damage number is visible with actual damage text at %.1fx zoom" % zoom_value)
		_check(absf(label.position.y - center.y) < 0.01, "Damage number Y follows the translated/zoomed camera at %.1fx zoom (actual %.2f, expected %.2f)" % [zoom_value, label.position.y, center.y])
		_check(absf(label.position.x - center.x) <= 8.01 * zoom_value, "Damage number X stays inside the transformed jitter bounds at %.1fx zoom" % zoom_value)
	camera.queue_free()
	await process_frame


func _check_melee_collisions() -> void:
	var player = load("res://scenes/kaze.tscn").instantiate()
	player.position = Vector2(400.0, 400.0)
	root.add_child(player)
	player.set_physics_process(false)
	var enemy = load("res://scenes/enemies/echo.tscn").instantiate()
	enemy.position = Vector2(850.0, 400.0)
	root.add_child(enemy)
	enemy.set_physics_process(false)
	var health: Node = enemy.get_node("Health")
	var hurtbox: Area2D = enemy.get_node("Hurtbox")
	var hitbox: Area2D = player.get_node("Hitbox")
	health.call("set_health_values", 200.0, 200.0)
	var events := {"hits": 0}
	hurtbox.connect("hit_received", func(_damage: float, _knockback: Vector2, _hitbox: Area2D) -> void: events.hits += 1)
	await _frames()
	var initial_health := float(health.get("current_health"))
	player.call("_perform_attack")
	enemy.position = Vector2(445.0, 400.0)
	await _frames()
	_check(events.hits == 1, "Actual player melee produces one Hurtbox collision signal")
	_check(is_equal_approx(float(health.get("current_health")), initial_health - float(hitbox.get("damage"))), "Actual player melee reduces enemy health by its attack damage")
	_check(not bool(hitbox.get("is_active")), "Single-hit melee closes its window after a collision")
	await _frames(12)
	_check(events.hits == 1, "Persistent overlap does not repeatedly damage an enemy")

	# A window that permits multiple targets must still hit each target once.
	# Exit/reentry makes this a physics regression rather than a helper-only test.
	enemy.position = Vector2(850.0, 400.0)
	hurtbox.set("invincibility_duration", 0.0)
	hurtbox.set("invincibility_timer", 0.0)
	hitbox.set("single_hit", false)
	await _frames()
	hitbox.call("activate", 2.0, true)
	var window_health := float(health.get("current_health"))
	var window_damage := float(hitbox.get("damage"))
	enemy.position = Vector2(445.0, 400.0)
	await _frames()
	_check(is_equal_approx(float(health.get("current_health")), window_health - window_damage), "Multi-target melee window damages an entering target")
	enemy.position = Vector2(850.0, 400.0)
	await _frames()
	enemy.position = Vector2(445.0, 400.0)
	await _frames()
	_check(is_equal_approx(float(health.get("current_health")), window_health - window_damage), "Exit/reentry cannot damage the same target twice in one melee window")

	enemy.position = Vector2(850.0, 400.0)
	await _frames()
	hitbox.call("activate", 2.0, true)
	var next_window_health := float(health.get("current_health"))
	enemy.position = Vector2(445.0, 400.0)
	await _frames()
	_check(is_equal_approx(float(health.get("current_health")), next_window_health - window_damage), "A restarted melee window can damage a previously hit target")
	var overlapping_health := float(health.get("current_health"))
	hitbox.call("activate", 2.0, true)
	await _frames()
	_check(is_equal_approx(float(health.get("current_health")), overlapping_health - window_damage), "A consecutive attack window damages an already-overlapping target exactly once")
	enemy.position = Vector2(850.0, 400.0)
	await _frames()
	health.call("set_health_values", 5.0, 200.0)
	hitbox.call("activate", 2.0, true)
	enemy.position = Vector2(445.0, 400.0)
	await _frames()
	_check(bool(health.get("is_dead")), "A lethal physical melee collision kills the enemy")
	_check(not hurtbox.monitoring, "Lethal melee safely disables the enemy Hurtbox after its collision callback")
	hitbox.call("deactivate")
	player.queue_free()
	enemy.queue_free()
	await _frames()


func _enemy_hitbox(attacker: Node2D) -> Area2D:
	var area := Area2D.new()
	area.set_script(load("res://scripts/combat/hitbox.gd"))
	area.collision_layer = 32
	area.collision_mask = 2
	area.set("damage", 9.0)
	area.set("single_hit", false)
	var collision := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(30.0, 40.0)
	collision.shape = rectangle
	area.add_child(collision)
	attacker.add_child(area)
	area.owner = attacker
	area.set("owner_node", attacker)
	return area


func _check_guard_veil_collisions() -> void:
	var player = load("res://scenes/kaze.tscn").instantiate()
	player.position = Vector2(600.0, 400.0)
	root.add_child(player)
	player.set_physics_process(false)
	player.call("set_health_values", 100.0, 100.0)
	var attacker := Node2D.new()
	attacker.position = Vector2(1100.0, 400.0)
	root.add_child(attacker)
	var hitbox := _enemy_hitbox(attacker)
	var hurtbox: Area2D = player.get_node("Hurtbox")
	var events := {"hits": 0}
	hurtbox.connect("hit_received", func(_damage: float, _knockback: Vector2, _hitbox: Area2D) -> void: events.hits += 1)
	player.set("guard_veil_timer", 1.0)
	hitbox.call("activate", 2.0, true)
	await _frames()
	attacker.position = player.position
	await _frames()
	_check(hurtbox.get_overlapping_areas().has(hitbox), "Guard Veil is tested during a real enemy Hitbox overlap")
	_check(is_equal_approx(float(player.call("get_current_health")), 100.0) and events.hits == 0, "Guard Veil prevents both damage and accepted-hit feedback")
	attacker.position = Vector2(1100.0, 400.0)
	await _frames()
	player.set("guard_veil_timer", 0.0)
	attacker.position = player.position
	await _frames()
	_check(is_equal_approx(float(player.call("get_current_health")), 91.0) and events.hits == 1, "Enemy Hitbox damages the player once Guard Veil is inactive")
	_check(bool(hurtbox.call("is_invincible")), "An accepted enemy hit starts player Hurtbox invincibility")
	attacker.position = Vector2(1100.0, 400.0)
	await _frames(1)
	attacker.position = player.position
	await _frames(1)
	_check(is_equal_approx(float(player.call("get_current_health")), 91.0), "Real physics reentry during player invincibility cannot deal another hit")
	player.queue_free()
	attacker.queue_free()
	await _frames()


func _check_checkpoint_without_scene() -> void:
	current_scene = null
	var player = load("res://scenes/kaze.tscn").instantiate()
	player.position = Vector2(100.0, 400.0)
	root.add_child(player)
	player.set_physics_process(false)
	var checkpoint := Area2D.new()
	checkpoint.set_script(load("res://scripts/rooms/checkpoint.gd"))
	checkpoint.position = Vector2(600.0, 400.0)
	checkpoint.collision_layer = 0
	checkpoint.collision_mask = 2
	checkpoint.set("heal_to_full", false)
	var collision := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(80.0, 100.0)
	collision.shape = rectangle
	checkpoint.add_child(collision)
	root.add_child(checkpoint)
	var game_state := root.get_node("GameState")
	var previous_path: String = game_state.get("checkpoint_scene_path")
	var previous_marker: String = game_state.get("checkpoint_spawn_marker")
	await _frames()
	player.position = checkpoint.position
	await _frames()
	_check(checkpoint.get_overlapping_bodies().has(player), "Missing-scene checkpoint test exercises actual body overlap")
	_check(not bool(checkpoint.get("_activated")), "A checkpoint without current_scene does not claim activation")
	_check(game_state.get("checkpoint_scene_path") == previous_path and game_state.get("checkpoint_spawn_marker") == previous_marker, "Missing-scene checkpoint preserves the previous respawn destination")
	player.queue_free()
	checkpoint.queue_free()
	await _frames()


func _check_checkpoint_round_trip() -> void:
	var game_state := root.get_node("GameState")
	game_state.call("new_game")
	var path := "res://scenes/rooms/room_04_checkpoint.tscn"
	var room = load(path).instantiate()
	root.add_child(room)
	current_scene = room
	var player: Node2D = room.get_node("Kaze")
	player.set_physics_process(false)
	await _frames()
	player.call("set_health_values", 40.0, 100.0)
	var checkpoint := room.get_node("Environment/Checkpoint") as Area2D
	player.position = checkpoint.position
	await _frames()
	_check(bool(checkpoint.get("_activated")), "Authored Room 4 checkpoint activates through a physical player overlap")
	_check(is_equal_approx(float(player.call("get_current_health")), 100.0), "Checkpoint activation heals the player to full")
	_check(game_state.get("checkpoint_scene_path") == path and game_state.get("checkpoint_spawn_marker") == "spawn_checkpoint", "Checkpoint stores the actual Room 4 scene and authored marker")
	game_state.call("manual_save")
	game_state.set("checkpoint_scene_path", "res://scenes/rooms/room_01_combat.tscn")
	_check(bool(game_state.call("load_from_disk")), "Checkpoint save data reloads from disk")
	_check(game_state.get("checkpoint_scene_path") == path and is_equal_approx(float(game_state.get("checkpoint_health")), 100.0), "Checkpoint scene and healed health survive save/load")
	player.call("take_damage", 25.0)
	var navigator := root.get_node("SceneNavigator")
	navigator.set("fade_duration", 0.01)
	navigator.call("respawn_from_checkpoint")
	for _index in 60:
		await _frames(1)
		# Freeze the new player as soon as the saved scene appears. This checks
		# spawn placement independently of gravity advancing during the fade.
		if current_scene != null and current_scene != room:
			var candidate := current_scene.get_node_or_null("Kaze")
			if candidate:
				candidate.set_physics_process(false)
		if not bool(navigator.get("is_transitioning")):
			break
	_check(not bool(navigator.get("is_transitioning")), "Checkpoint respawn finishes its actual scene transition")
	_check(current_scene != null and current_scene.scene_file_path == path, "Checkpoint respawn loads the saved scene")
	if current_scene != null:
		var restored: Node2D = current_scene.get_node_or_null("Kaze")
		var marker := current_scene.get_node_or_null("SpawnPoints/spawn_checkpoint") as Marker2D
		_check(restored != null and marker != null and restored.global_position.distance_to(marker.global_position) < 4.0, "Checkpoint respawn places Kaze at the authored marker (actual %s, expected %s)" % [restored.global_position if restored else Vector2.ZERO, marker.global_position if marker else Vector2.ZERO])
		_check(restored != null and is_equal_approx(float(restored.call("get_current_health")), 100.0), "Checkpoint respawn restores saved full health")
		var loaded_room := current_scene
		current_scene = null
		loaded_room.queue_free()
	await _frames()


func _check_audio_teardown() -> void:
	var audio := Node.new()
	audio.set_script(load("res://scripts/systems/audio_manager.gd"))
	root.add_child(audio)
	audio.call("play_music", "combat")
	audio.call("play_sfx", "hit_impact")
	var music := audio.get("_music_player") as AudioStreamPlayer
	var sfx: Array = audio.get("_sfx_players")
	_check(music.stream != null and sfx[0].stream != null, "Audio teardown fixture starts music and an actual SFX stream")
	root.remove_child(audio)
	_check(not music.playing and music.stream == null, "Audio exit stops music and releases its stream")
	var all_cleared := true
	for player: AudioStreamPlayer in sfx:
		all_cleared = all_cleared and not player.playing and player.stream == null
	_check(all_cleared, "Audio exit stops and clears every pooled SFX player")
	audio.free()
	await process_frame


func _check_detached_helpers() -> void:
	for path in ["res://scripts/combat/hurtbox.gd", "res://scripts/rooms/checkpoint.gd"]:
		var detached := Area2D.new()
		detached.set_script(load(path))
		for helper in ["_game_state", "_audio_manager"]:
			var available := detached.has_method(helper)
			_check(available and detached.call(helper) == null, "%s %s safely returns null outside the scene tree" % [path.get_file(), helper])
		if path.ends_with("hurtbox.gd"):
			var available := detached.has_method("_combat_feedback")
			_check(available and detached.call("_combat_feedback") == null, "Detached Hurtbox feedback lookup safely returns null")
		detached.free()
