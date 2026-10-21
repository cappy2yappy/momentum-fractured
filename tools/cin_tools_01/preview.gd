extends Control
## Read-only playback preview. Persist artwork/timing in the native scene editor.
@export var preset: PackedScene = preload("res://presets/cutins/special_transition.tscn")
var cutin
var preview_frame: Control
var animation: AnimationPlayer
var reduced_preview = false
var seeking = false
var slider: HSlider
var status: Label
var running = false
var choices = ["special_transition", "major_biome", "boss_intro"]

func _ready():
	preview_frame = Control.new()
	preview_frame.position = Vector2(109,0)
	preview_frame.size = Vector2(1062,598)
	preview_frame.clip_contents = true
	add_child(preview_frame)
	var layer = CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	var panel = VBoxContainer.new()
	var background = ColorRect.new()
	background.position = Vector2(0, 604)
	background.size = Vector2(1280,116)
	background.color = Color(.025,.035,.055,.98)
	layer.add_child(background)
	panel.position = Vector2(20, 616)
	panel.size = Vector2(1240, 120)
	layer.add_child(panel)
	var row = HBoxContainer.new()
	panel.add_child(row)
	var select = OptionButton.new()
	for item in choices: select.add_item(item.replace("_", " ").capitalize())
	select.item_selected.connect(func(i):
		preset = load("res://presets/cutins/" + choices[i] + ".tscn")
		open_preset())
	row.add_child(select)
	for item in [["Play", play], ["Pause", pause], ["Step 1/60 s", step], ["Restart", restart]]:
		var button = Button.new()
		button.text = item[0]
		button.pressed.connect(item[1])
		row.add_child(button)
	var toggle = CheckButton.new()
	toggle.text = "Reduced motion"
	toggle.toggled.connect(func(value): reduced_preview = value; restart())
	row.add_child(toggle)
	slider = HSlider.new()
	slider.step = 1.0 / 60.0
	slider.value_changed.connect(scrub)
	panel.add_child(slider)
	status = Label.new()
	panel.add_child(status)
	open_preset()

func open_preset():
	running = false
	if is_instance_valid(cutin):
		cutin.get_parent().remove_child(cutin)
		cutin.queue_free()
	cutin = preset.instantiate()
	cutin.scale = Vector2.ONE * .83
	cutin.position = Vector2.ZERO
	preview_frame.add_child(cutin)
	animation = cutin.get_node("AnimationPlayer")
	animation.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	restart()

func restart():
	running = false
	animation.stop()
	animation.play("reduced" if reduced_preview else "standard")
	animation.advance(0)
	seeking = true
	slider.max_value = animation.current_animation_length
	slider.value = 0
	seeking = false
	scrub(0)

func play():
	if animation.current_animation_position >= slider.max_value: restart()
	running = true
	cutin.audio_enabled = true

func pause():
	running = false
	cutin.audio_enabled = false
	cutin.get_node("Music").stop()
	cutin.get_node("SFX").stop()

func step():
	pause()
	scrub(minf(slider.max_value, animation.current_animation_position + 1.0 / 60.0))

func scrub(value):
	if seeking: return
	pause()
	animation.seek(value, true)
	seeking = true
	slider.value = value
	seeking = false

func _process(dt):
	if not is_instance_valid(animation): return
	if running:
		animation.advance(dt)
		if not animation.is_playing(): running = false
		seeking = true
		slider.value = animation.current_animation_position
		seeking = false
	status.text = "%.2f / %.2f s | ART-08 candidate • temporary staging • audio unassigned | Edit tracks and save in Godot’s Animation panel." % [slider.value, slider.max_value]
