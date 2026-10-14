extends Node2D
signal audio_cue(cue: String) # AUD01 audio-only
signal defeated
var player
var hp = 6
var max_hp = 6
var display_name = "CANAL GUARD"
var move_speed = 115.0
var chase_distance = 580.0
var attack_range = 95.0
var is_boss = false
var is_required = false
var hit_radius = 42.0
var state = "patrol"
var timer = 0.0
var facing = -1
var strike_done = false
var home = 1100.0
var patrol_min = -INF
var patrol_max = INF
var sprite = Sprite2D.new()
func _ready():
	add_child(sprite)
	sprite.texture = load("res://assets/web/bosses_strip.png" if is_boss else "res://assets/web/sentinels_strip.png")
	sprite.hframes = 10 if is_boss else 8
	sprite.scale = Vector2.ONE * (176.0 if is_boss else 108.0) / sprite.texture.get_height()
	sprite.position.y = -88 if is_boss else -54
	if is_boss: hit_radius = 68.0
func _physics_process(dt):
	if hp <= 0: return
	timer -= dt
	var distance = player.position - position
	facing = 1 if distance.x > 0 else -1
	if state == "stunned" or state == "recover":
		if timer <= 0: state = "patrol"
	elif state == "windup":
		if timer <= 0:
			state = "strike";timer = 0.16;strike_done = false
	elif state == "strike":
		if not strike_done:
			strike_done = true
			if absf(distance.x) < attack_range + hit_radius and absf(distance.y) < 105:
				if player.parry_time > 0 and player.facing == - facing:
					state = "stunned";timer = 1.1
					player.hitstop = 0.065
					audio_cue.emit("parry") # AUD01 audio-only
				else: player.damage(position)
		if timer <= 0: state = "recover";timer = 0.7
	else:
		if absf(distance.x) < attack_range and absf(distance.y) < 80:
			state = "windup";timer = 0.48
		elif absf(distance.x) < chase_distance:
			position.x = clampf(position.x + facing * move_speed * dt, maxf(home - 350,patrol_min), minf(home + 350,patrol_max))
	sprite.flip_h = facing < 0
	sprite.modulate = Color("d9dd99") if state == "stunned" else Color.WHITE
	if is_boss:
		sprite.frame = 5 if state in ["windup", "strike"] else 0
	else:
		sprite.frame = 2 if state == "windup" else (3 if state == "strike" else (int(Time.get_ticks_msec() / 220) % 2))
	queue_redraw()
func receive_hit(damage):
	if hp <= 0: return
	hp -= damage
	state = "stunned";timer = 0.24
	if hp <= 0:
		defeated.emit()
		queue_free()
func _draw():
	if hp <= 0: return
	var bar_y = -210 if is_boss else -133
	draw_rect(Rect2(-32, bar_y, 64, 5), Color("312937"))
	draw_rect(Rect2(-32, bar_y, 64 * hp / float(max_hp), 5), Color("d7b477"))
	if state == "windup":
		draw_circle(Vector2(0, -155), 7, Color("efc56c"))
		draw_arc(Vector2(0, -50), 68, 0, TAU, 32, Color(1, 0.8, 0.4, 0.6), 2)
	if state == "strike": draw_line(Vector2(0, -48), Vector2(facing * 115, -48), Color("f1d3ba"), 8)
