@tool
extends Node2D
## Native FK rig and intact sprite sheets; no live player dependency.
@export var clip: Animation
@export var mode = 0:
	set(value):
		mode = value
		if has_node("Rig"): $Rig.visible = mode == 0
		if has_node("Sprite"): $Sprite.visible = mode == 1
@export var guides = false
var player: AnimationPlayer
var rest_values = {}

func _ready():
	for joint in [self] + find_children("*", "Node2D", true, false):
		var path = str(get_path_to(joint))
		rest_values[path+":position"] = joint.position
		rest_values[path+":rotation"] = joint.rotation
	player = $AnimationPlayer
	player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	bind_clip(clip)
	mode = mode

func bind_clip(value: Animation):
	clip = value
	if not is_instance_valid(player): return
	if player.has_animation_library(""): player.remove_animation_library("")
	var library = AnimationLibrary.new()
	if clip: library.add_animation("sprint_stop", clip)
	player.add_animation_library("", library)
	if clip:
		player.play("sprint_stop")
		player.advance(0)

func sample(time: float):
	if is_instance_valid(player) and clip:
		if player.current_animation != "sprint_stop": player.play("sprint_stop")
		player.seek(clampf(time, 0, clip.length), true)
	queue_redraw()

func _draw():
	if not guides or not has_node("Rig"): return
	for path in ["Rig", "Rig/Torso", "Rig/Torso/Head", "Rig/Torso/Hair", "Rig/Torso/ArmNear", "Rig/Torso/ArmNear/Forearm", "Rig/LegNear", "Rig/LegNear/Shin", "Rig/LegFar", "Rig/LegFar/Shin"]:
		var joint = get_node(path)
		draw_circle(to_local(joint.global_position), 4, Color("72e2bb"))
