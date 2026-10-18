extends Node2D
## Geometry-only laboratory. No world, controller, map, progression or save writes.
var probes: Array[Node] = []
@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	if "--capture-layout" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		var filename := "edited-runtime.png" if scene_file_path.ends_with("preview_edited.tscn") else "layout-runtime.png"
		get_viewport().get_texture().get_image().save_png("res://tools/ld_tools_01/evidence/"+filename)
		get_tree().quit()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			spawn_probe(get_global_mouse_position())
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.zoom = (camera.zoom * 1.1).clamp(Vector2(0.2,0.2), Vector2(2,2))
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.zoom = (camera.zoom / 1.1).clamp(Vector2(0.2,0.2), Vector2(2,2))
	if event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_MIDDLE:
		camera.position -= event.relative / camera.zoom
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		for probe in probes:
			if is_instance_valid(probe): probe.queue_free()
		probes.clear()
		camera.position = Vector2(1300,720)
		camera.zoom = Vector2(0.43,0.43)

func spawn_probe(at: Vector2) -> void:
	var probe := RigidBody2D.new()
	probe.position = at
	probe.collision_layer = 2
	probe.collision_mask = 1
	var collider := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 12
	collider.shape = circle
	probe.add_child(collider)
	var visual := Polygon2D.new()
	var vertices := PackedVector2Array()
	for i in 16:
		vertices.append(Vector2.from_angle(TAU*i/16.0)*12)
	visual.polygon = vertices
	visual.color = Color("e3efff")
	probe.add_child(visual)
	add_child(probe)
	probes.append(probe)
	if probes.size() > 50:
		probes.pop_front().queue_free()
