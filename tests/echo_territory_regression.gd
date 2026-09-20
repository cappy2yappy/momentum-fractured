extends SceneTree

var failures := 0


func _init() -> void:
	call_deferred("_run")


func _check(condition: bool, message: String) -> void:
	if condition:
		print("PASS: ", message)
	else:
		failures += 1
		push_error("FAIL: " + message)


func _run() -> void:
	var echo := (load("res://scenes/enemies/echo.tscn") as PackedScene).instantiate()
	root.add_child(echo)
	echo.set_physics_process(false)
	echo.global_position = Vector2(100.0, 100.0)
	await physics_frame

	_check(echo.call("_can_move_horizontally", 1.0, 1.0 / 60.0), "Unset territory preserves legacy movement without floor support")

	echo.territory_min_x = 80.0
	echo.territory_max_x = 120.0
	echo.global_position.x = 80.0
	_check(not echo.call("_can_move_horizontally", -1.0, 1.0 / 60.0), "Authored minimum blocks outward movement")
	echo.global_position.x = 120.0
	_check(not echo.call("_can_move_horizontally", 1.0, 1.0 / 60.0), "Authored maximum blocks outward movement")

	var floor := StaticBody2D.new()
	floor.collision_layer = 1
	floor.global_position = Vector2(100.0, 145.0)
	var floor_shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(160.0, 10.0)
	floor_shape.shape = rectangle
	floor.add_child(floor_shape)
	root.add_child(floor)
	await physics_frame

	echo.global_position.x = 100.0
	_check(echo.call("_can_move_horizontally", 1.0, 1.0 / 60.0), "Floor probe permits movement over supported territory")
	rectangle.size.x = 42.0
	await physics_frame
	_check(not echo.call("_can_move_horizontally", 1.0, 1.0 / 60.0), "Floor probe blocks movement toward a ledge")

	rectangle.size.x = 160.0
	echo.global_position.x = 118.0
	echo.velocity.x = 180.0
	await physics_frame
	_check(not echo.call("_can_move_horizontally", 1.0, 1.0 / 60.0), "Current speed cannot carry Echo past the authored maximum")

	floor.queue_free()
	echo.queue_free()
	await process_frame
	print("ECHO TERRITORY REGRESSION: %d failure(s)" % failures)
	quit(1 if failures > 0 else 0)
