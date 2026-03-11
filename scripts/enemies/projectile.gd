extends Area2D

## Enemy projectile - straight-line shot with timed despawn.

@export var speed: float = 300.0
@export var damage: float = 5.0
@export var lifetime: float = 3.0

var direction: Vector2 = Vector2.RIGHT


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	await get_tree().create_timer(lifetime).timeout
	queue_free()


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.call("take_damage", damage)
	queue_free()
