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
@export var rig_blend = -1.0
var selected_joint = ""
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
	# Deleted/new tracks must not leave transforms from the previous clip behind.
	for path in rest_values:
		var node_path = path.get_slice(":",0)
		get_node(node_path).set(path.get_slice(":",1),rest_values[path])
	rig_blend = -1.
	if player.has_animation_library(""): player.remove_animation_library("")
	var library = AnimationLibrary.new()
	if clip: library.add_animation("sprint_stop", clip)
	player.add_animation_library("", library)
	if clip:
		player.play("sprint_stop")
		player.advance(0)

func sample(time: float):
	# Seeking must also discard unkeyed properties that have no animation track yet.
	for path in rest_values:
		get_node(path.get_slice(":",0)).set(path.get_slice(":",1),rest_values[path])
	if is_instance_valid(player) and clip:
		if player.current_animation != "sprint_stop": player.play("sprint_stop")
		player.seek(clampf(time, 0, clip.length), true)
	set_view(-1)
	queue_redraw()

func set_view(override_mode):
	var blend = rig_blend if rig_blend >= 0 else (1. if mode == 0 else 0.)
	if override_mode >= 0: blend = 1. if override_mode == 0 else 0.
	$Rig.visible = blend > 0; $Sprite.visible = blend < 1
	$Rig.modulate.a = blend; $Sprite.modulate.a = 1.-blend

func _draw():
	if not guides or not has_node("Rig"): return
	for path in ["Rig", "Rig/Torso", "Rig/Torso/Head", "Rig/Torso/Hair", "Rig/Torso/ArmNear", "Rig/Torso/ArmNear/Forearm", "Rig/LegNear", "Rig/LegNear/Shin", "Rig/LegFar", "Rig/LegFar/Shin"]:
		var joint = get_node(path)
		draw_circle(to_local(joint.global_position), 4, Color("72e2bb"))
	if not selected_joint.is_empty() and has_node(selected_joint):
		draw_arc(to_local(get_node(selected_joint).global_position),8,0,TAU,24,Color("ffc875"),2,true)
