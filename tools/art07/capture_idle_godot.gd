extends SceneTree
# ART-07 Phase 1 native render capture. Needs a GL context (xvfb is fine):
#   xvfb-run -a -s "-screen 0 1280x720x24" godot --rendering-method gl_compatibility \
#     --rendering-driver opengl3 --resolution 960x540 --path . --script res://tools/art07/capture_idle_godot.gd
# Draws the approved idle, candidate 8f and candidate 16f with the exact scale and offset
# formula from scripts/player.gd, at 1x (real size, top row) and 3x (inspection, bottom row).
# This is a standalone fixture. It does not use or modify the player scene or default binding.

const OUT := "res://docs/art/art07/idle_procedural/godot_capture/"
const BASELINE := 591.0
const ENGINE_SCALE := 0.2649908807267889

var variants := []
var step := 0

func make_sprite(tex_path: String, hframes: int) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = load(tex_path)
	s.hframes = hframes
	s.scale = Vector2.ONE * ENGINE_SCALE
	s.offset = Vector2(0, s.texture.get_height() / 2.0 - BASELINE)
	return s

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	print("RENDERER adapter=", RenderingServer.get_video_adapter_name(), " api=", RenderingServer.get_video_adapter_api_version(), " method=", ProjectSettings.get_setting("rendering/renderer/rendering_method"), " window=", root.size)
	print("GODOT ", Engine.get_version_info()["string"])
	var bg := ColorRect.new()
	bg.color = Color(0.27, 0.27, 0.31)
	bg.size = Vector2(960, 540)
	root.add_child(bg)
	var defs := [
		["approved idle 8f", "res://assets/kaze/cleaned/kaze_idle_strip.png", 8],
		["candidate 8f", "res://assets/art07/idle_procedural/kaze_idle_procedural_8f_strip.png", 8],
		["candidate 16f", "res://assets/art07/idle_procedural/kaze_idle_procedural_16f_strip.png", 16],
	]
	for i in defs.size():
		var d: Array = defs[i]
		var cx := 160.0 + i * 320.0
		var small := Node2D.new()
		small.position = Vector2(cx, 150)  # ground at y=150, real gameplay size
		var s1 := make_sprite(d[1], d[2])
		small.add_child(s1)
		root.add_child(small)
		var big := Node2D.new()
		big.position = Vector2(cx, 500)  # ground at y=500, 3x inspection
		big.scale = Vector2(3, 3)
		var s3 := make_sprite(d[1], d[2])
		big.add_child(s3)
		root.add_child(big)
		var lab := Label.new()
		lab.text = d[0]
		lab.position = Vector2(cx - 70, 8)
		root.add_child(lab)
		variants.append({"s1": s1, "s3": s3, "n": d[2]})

var phase := 0

func _process(_delta: float) -> bool:
	if step >= 16:
		print("CAPTURE_DONE frames=16")
		quit(0)
		return true
	if phase == 0:
		# set this tick's frame; it is rendered during the next process pass
		for v in variants:
			var fr: int = (step / 2) % 8 if v["n"] == 8 else step % 16
			v["s1"].frame = fr
			v["s3"].frame = fr
		phase = 1
		return false
	# tick = 80 ms of simulated time: 8f clips advance every two ticks, the 16f clip every tick
	var img := root.get_texture().get_image()
	img.save_png(ProjectSettings.globalize_path(OUT + "tick_%02d.png" % step))
	step += 1
	phase = 0
	return false
