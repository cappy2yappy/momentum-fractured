extends Area2D

var direction := Vector2.RIGHT
var element := "wind"
var speed := 850.0
var damage := 18.0
var lifetime := 1.4


func _ready() -> void:
	collision_layer = 16
	collision_mask = 4
	monitoring = true
	var shape := CollisionShape2D.new()
	var capsule := CapsuleShape2D.new()
	capsule.radius = 5.0
	capsule.height = 22.0
	shape.shape = capsule
	shape.rotation = PI * 0.5
	add_child(shape)
	area_entered.connect(_on_area_entered)
	queue_redraw()


func _physics_process(delta: float) -> void:
	global_position += direction.normalized() * speed * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox:
		var health: Node = area.health
		if health and health.has_method("take_damage"):
			health.call("take_damage", damage)
			GameState.register_combo_hit()
		queue_free()


func _draw() -> void:
	var color := Color(0.45, 0.95, 1.0)
	if element == "fire":
		color = Color(1.0, 0.35, 0.12)
	elif element == "electric":
		color = Color(1.0, 0.92, 0.2)
	draw_colored_polygon(PackedVector2Array([Vector2(13, 0), Vector2(-8, -5), Vector2(-4, 0), Vector2(-8, 5)]), color)
