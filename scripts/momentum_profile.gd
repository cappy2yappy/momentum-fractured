extends RefCounted
# Units: world pixels, seconds, normalized meter points. Prototype balance.
var enabled = false
var meter = 0.0
var gain_per_second = 0.12
var moving_decay_per_second = 0.18
var stopped_decay_per_second = 0.45
var minimum_speed = 360.0
var maximum_bonus_fraction = 0.06
var transition_gain = 0.08
var damage_penalty = 0.5
var suppression = 0.0
var transition_cooldown = 0.0
var distance_since_reward = 0.0
var last_transition = ""

func reset():
	meter = 0.0
	suppression = 0.0
	transition_cooldown = 0.0
	distance_since_reward = 0.0
	last_transition = ""

func tick(dt: float, displacement: Vector2, direction: float, running: bool, interrupted: bool):
	if not enabled:
		reset()
		return
	if dt <= 0: return
	suppression = maxf(0.0, suppression - dt)
	transition_cooldown = maxf(0.0, transition_cooldown - dt)
	var purposeful = direction != 0 and displacement.x * direction > 0
	var speed = absf(displacement.x) / dt
	if purposeful and not interrupted: distance_since_reward += absf(displacement.x)
	if running and purposeful and speed >= minimum_speed and not interrupted and suppression <= 0:
		meter = clampf(meter + gain_per_second * dt, 0.0, 1.0)
	else:
		var decay = stopped_decay_per_second if speed < minimum_speed or interrupted else moving_decay_per_second
		meter = clampf(meter - decay * dt, 0.0, 1.0)

func reward_transition(kind: String, travel: float, speed: float):
	# Requires actual travel, useful exit speed, time, distance and a different technique.
	if not enabled or suppression > 0 or transition_cooldown > 0: return
	if travel < 96.0 or speed < minimum_speed or distance_since_reward < 150.0: return
	if kind == last_transition: return
	meter = clampf(meter + transition_gain, 0.0, 1.0)
	last_transition = kind
	transition_cooldown = 0.8
	distance_since_reward = 0.0

func take_damage():
	meter = maxf(0.0, meter - damage_penalty)
	suppression = 1.2
	distance_since_reward = 0.0

func speed_multiplier() -> float:
	return 1.0 + clampf(maximum_bonus_fraction, 0.0, 0.06) * clampf(meter, 0.0, 1.0) if enabled else 1.0
