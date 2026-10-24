extends "res://scripts/encounters/enemy.gd"
## Isolated behavior extension. Base Enemy remains the only strike/damage owner.
var behavior := "skirmisher"
var reposition_cooldown := 0.0
var move_from := 0.0
var move_to := 0.0
var motion_time := 0.0
var lunge_hit := false
var last_player_side := 0
var reposition_count := 0
var attack_count := 0
var control_cancellations := 0
const LUNGE_SECONDS := 0.30
const LUNGE_HIT_TIME := 0.16

func _physics_process(dt):
	if hp <= 0 or not is_instance_valid(player) or not is_instance_valid(encounter) or encounter.leaving:
		return
	if not encounter.control_ready():
		if state not in ["dormant", "awakening"]:
			control_cancellations += 1
			change("awakening", config.spawn_grace)
			motion_time = 0.0
			lunge_hit = false
		paint()
		return
	reposition_cooldown = maxf(0.0, reposition_cooldown - dt)
	var distance: float = player.global_position.x - global_position.x
	var side := 1 if distance >= 0 else -1
	if state == "backstep":
		motion_time += dt
		position.x = lerpf(move_from, move_to, minf(1.0, motion_time / 0.24))
		if motion_time >= 0.24: change("recover", config.recovery_time)
	elif state == "lunge":
		motion_time += dt
		position.x = lerpf(move_from, move_to, minf(1.0, motion_time / LUNGE_SECONDS))
		if not lunge_hit and motion_time >= LUNGE_HIT_TIME:
			lunge_hit = true
			# Reuse exact base strike: visibility, facing, parry and player.damage.
			strike_done = false
			change("strike", config.active_time)
			super._physics_process(0.0)
			attack_count += 1
			if state != "stunned": change("lunge")
		if state == "lunge" and motion_time >= LUNGE_SECONDS:
			change("landing", 0.12)
	elif state == "landing":
		timer -= dt
		if timer <= 0.0: change("recover", config.recovery_time)
	elif behavior == "slime" and state == "windup" and timer <= dt:
		# Fixed-y contract: honest ground lunge, no unsupported jumping collision.
		move_from = position.x
		move_to = clampf(position.x + facing * 120.0, patrol_min, patrol_max)
		motion_time = 0.0
		lunge_hit = false
		change("lunge")
	elif behavior == "skirmisher" and state in ["pursue", "patrol"] and reposition_cooldown <= 0.0 and player.dash_time > 0.0 and absf(distance) < 230.0 and visible_target():
		var destination := position.x - side * 60.0
		# Keep an extra standing pocket inside the already validated edge margin.
		if destination >= patrol_min + 42.0 and destination <= patrol_max - 42.0:
			move_from = position.x
			move_to = destination
			motion_time = 0.0
			facing = side
			reposition_cooldown = 2.0
			reposition_count += 1
			change("backstep", 0.24)
		else:
			change("recover", config.recovery_time)
	else:
		var was_strike := state == "strike" and not strike_done
		super._physics_process(dt)
		if was_strike: attack_count += 1
	last_player_side = side
	paint()

func paint():
	sprite.visible = behavior != "slime"
	queue_redraw()

func threat_rect() -> Rect2:
	# Conservative union of the inherited strike windows along committed travel.
	# A long physics step may evaluate the one hit anywhere up to the destination.
	var from_x := move_from - position.x if state == "lunge" else 0.0
	var to_x := from_x
	if behavior == "slime":
		to_x = move_to - position.x if state == "lunge" else clampf(position.x + facing * 120.0, patrol_min, patrol_max) - position.x
	var reach: float = attack_range + hit_radius
	var left := minf(from_x,to_x) - (reach if facing < 0 else 14.0)
	var right := maxf(from_x,to_x) + (reach if facing > 0 else 14.0)
	return Rect2(left,-85.0,right-left,170.0)

func _draw():
	if config.is_empty() or hp <= 0: return
	if state in ["windup","lunge","strike"]:
		var threat := threat_rect()
		draw_rect(threat,Color(1.0,0.6,0.15,0.12))
		draw_rect(threat,Color(1.0,0.72,0.3,0.85),false,2)
		draw_string(ThemeDB.fallback_font,Vector2(threat.position.x,104),"POTENTIAL STRIKE ENVELOPE",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("ffd58b"))
	if behavior != "slime": super._draw()
	else:
		# Debug placeholder only. Not a finished skin or new source artwork.
		var squash := 0.65 if state == "windup" else (0.85 if state == "landing" else 1.0)
		draw_set_transform(Vector2(0, -34 * squash), 0, Vector2(1.0 / squash, squash))
		draw_circle(Vector2.ZERO, 34, Color("69a6a0"))
		draw_arc(Vector2.ZERO, 34, 0, TAU, 32, Color("e1f4ec"), 2)
		draw_set_transform(Vector2.ZERO)
		draw_rect(Rect2(-32,-133,64,5),Color("312937"))
		draw_rect(Rect2(-32,-133,64 * hp / float(max_hp),5),Color("d7b477"))
		if state == "windup":
			draw_line(Vector2(0,-85), Vector2(facing*120,-85), Color("ffe295"), 4)
			draw_circle(Vector2(facing*120,-85),6,Color("ffe295"))
		if state == "lunge": draw_line(Vector2(0,-48),Vector2(facing*115,-48),Color("f1d3ba"),4)
	draw_string(ThemeDB.fallback_font, Vector2(-80,-180), behavior.to_upper() + " / " + state, HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color.WHITE)
	draw_line(Vector2(-12,0),Vector2(12,0),Color("ffcc66"),3)
	draw_circle(Vector2(0,-42),hit_radius,Color(1,1,1,0.06))
	draw_arc(Vector2(0,-42),hit_radius,0,TAU,32,Color(1,1,1,0.45),1)
