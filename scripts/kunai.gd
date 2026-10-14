extends Node2D

var element = "wind"
var direction = 1
var speed = 980.0
var lifetime = 1.4
var world

func _physics_process(dt):
	lifetime -= dt
	# Sample traveled collision path, not just its endpoint, during slow frames.
	var distance = direction * speed * dt
	var steps = maxi(1, ceili(absf(distance) / 16.0))
	for step in steps:
		position.x += distance / steps
		if world.resolve_kunai(self):
			queue_free()
			break
	if lifetime <= 0 or position.x < -40 or position.x > world.room_size(world.room).x + 40:
		queue_free()
	queue_redraw()

func _draw():
	var color = {"wind": Color("9de5ad"), "fire": Color("ff8b59"), "electric": Color("76d9ff")}.get(element, Color.WHITE)
	draw_line(Vector2( - direction * 24, 0), Vector2(direction * 15, 0), Color(color, 0.38), 9)
	draw_colored_polygon(PackedVector2Array([Vector2(direction * 18, 0), Vector2( - direction * 8, -7), Vector2( - direction * 8, 7)]), color)
	draw_circle(Vector2( - direction * 9, 0), 4, Color("f4f5dc"))
