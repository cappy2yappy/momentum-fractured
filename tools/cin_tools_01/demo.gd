extends Node
## F6 reduced motion; Space skip; Esc existing pause/resume. Save is disposable.
const Adapter = preload("res://tools/cin_tools_01/runtime_adapter.gd")
@export var preset: PackedScene = preload("res://presets/cutins/special_transition.tscn")
var world
var banner: Label
var overlay: CanvasLayer

func _ready():
	world = load("res://scenes/main.tscn").instantiate()
	world.save_path = "user://cin_tools_01_demo_only.json"
	add_child(world)
	# Dispose the fully configured controller, including all owned presentation nodes.
	world.cinematic_transitions.cancel(world)
	world.remove_child(world.cinematic_transitions)
	world.cinematic_transitions.free()
	world.cinematic_transitions = Adapter.new()
	world.cinematic_transitions.preset = preset
	world.add_child(world.cinematic_transitions)
	world.cinematic_transitions.configure(world)
	# This is an isolated fixture, not an earned-progress start or new story event.
	world.completed = true
	world.player.double_jump = true
	world.player.tether_unlocked = true
	world.player.dash_unlocked = true
	world.message_time = 0
	world.expansion_flags = {"junction_return": true}
	world.build_room(14)
	world.player.position = Vector2(1300, 478)
	world.player.velocity = Vector2.ZERO
	world.checkpoint_room = 14
	world.checkpoint_position = world.player.position
	world.camera.reset_smoothing()
	var layer = CanvasLayer.new()
	layer.layer = 110
	overlay = layer
	add_child(layer)
	var band = ColorRect.new()
	band.position = Vector2(0,680)
	band.size = Vector2(1280,40)
	band.color = Color(.02,.03,.05,.95)
	layer.add_child(band)
	banner = Label.new()
	banner.position = Vector2(24, 690)
	banner.add_theme_font_size_override("font_size", 14)
	layer.add_child(banner)

func _process(_dt):
	var c = world.cinematic_transitions
	overlay.visible = not c.tr08.owns()
	banner.text = "CIN-TOOLS-01 ISOLATED FIXTURE | D toward stair, E enter | SPACE skip | F6 reduced | ESC pause | R%d | %s" % [world.room, c.last_outcome]
