extends Node2D
signal defeated
var player
var hp = 6
var state = "patrol"
var timer = 0.0
var facing = -1
var strike_done = false
var home = 1100.0
var sprite = Sprite2D.new()
func _ready():
	add_child(sprite)
	sprite.texture = load("res://assets/guard.png")
	sprite.scale = Vector2.ONE*100.0/sprite.texture.get_height()
	sprite.position.y = -50
func _physics_process(dt):
	if hp <= 0: return
	timer -= dt
	var distance = player.position-position
	facing = 1 if distance.x > 0 else -1
	if state == "stunned" or state == "recover":
		if timer <= 0: state = "patrol"
	elif state == "windup":
		if timer <= 0:
			state = "strike"; timer = 0.16; strike_done = false
	elif state == "strike":
		if not strike_done:
			strike_done = true
			if absf(distance.x) < 120 and absf(distance.y) < 90:
				if player.parry_time > 0 and player.facing == -facing:
					state = "stunned"; timer = 1.1
					player.hitstop = 0.065
				else: player.damage(position)
		if timer <= 0: state = "recover"; timer = 0.7
	else:
		if absf(distance.x) < 95 and absf(distance.y) < 80:
			state = "windup"; timer = 0.48
		elif absf(distance.x) < 580:
			position.x = clampf(position.x+facing*115*dt,home-350,home+350)
	sprite.flip_h = facing < 0
	sprite.modulate = Color("d9dd99") if state == "stunned" else Color.WHITE
	queue_redraw()
func receive_hit(damage):
	if hp <= 0: return
	hp -= damage
	state = "stunned"; timer = 0.24
	if hp <= 0:
		defeated.emit()
		queue_free()
func _draw():
	if hp <= 0: return
	draw_rect(Rect2(-32,-133,64,5),Color("312937"))
	draw_rect(Rect2(-32,-133,64*hp/6.0,5),Color("d7b477"))
	if state == "windup":
		draw_circle(Vector2(0,-155),7,Color("efc56c"))
		draw_arc(Vector2(0,-50),68,0,TAU,32,Color(1,0.8,0.4,0.6),2)
	if state == "strike": draw_line(Vector2(0,-48),Vector2(facing*115,-48),Color("f1d3ba"),8)
