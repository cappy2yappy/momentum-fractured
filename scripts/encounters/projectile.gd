extends Node2D
## Swept, cover-blocked enemy projectile. Uses the approved player damage gate.
var player
var velocity = Vector2.ZERO
var lifetime = 3.0
func _physics_process(dt):
	if not is_instance_valid(player): queue_free(); return
	var travel = velocity * minf(dt, lifetime)
	lifetime -= dt
	var query = PhysicsRayQueryParameters2D.create(global_position, global_position + travel, 3)
	var hit = get_world_2d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		if hit.collider == player:
			if player.parry_time <= 0 or player.facing != -signf(velocity.x): player.damage(global_position)
		queue_free()
	else: position += travel
	if lifetime <= 0: queue_free()
	queue_redraw()
func _draw():
	draw_circle(Vector2.ZERO, 6, Color("ffab66"))
	draw_line(-velocity.normalized() * 22, Vector2.ZERO, Color("ffd49b"), 3)
