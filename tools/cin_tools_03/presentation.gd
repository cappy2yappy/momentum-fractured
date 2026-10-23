@tool
extends "res://tools/cin_tools_01/presentation.gd"
@export var clip_time = 0.0:
	set(value):
		clip_time = value
		if has_node("Framing/Shake/Actor"): $Framing/Shake/Actor.sample(value)

func _ready():
	super._ready()
	clip_time = clip_time
