extends Node2D
const Contract = preload("res://tools/art10/contract.gd")
var manifest: Dictionary = {}
var candidate := "grounded"
var direction := "ascent"
var elapsed := 0.0
var paused := false
var errors: Array = []
var clip: Dictionary = {}
var textures: Dictionary = {}
var contact_overlay := true

func _ready():
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	manifest = JSON.parse_string(FileAccess.get_file_as_string("res://assets/art10/MANIFEST.json"))
	select_clip()

func select_clip():
	clip = manifest.candidates[candidate][direction]
	errors = Contract.validate_clip(clip)
	elapsed = 0.0
	textures.clear()
	if errors.is_empty():
		for frame in clip.frames:
			if not textures.has(frame.asset):
				textures[frame.asset] = ImageTexture.create_from_image(Image.load_from_file(frame.asset))
	queue_redraw()

func _unhandled_key_input(event):
	if not event is InputEventKey or not event.pressed or event.echo: return
	match event.keycode:
		KEY_1: candidate = "grounded"; select_clip()
		KEY_2: candidate = "expressive"; select_clip()
		KEY_A: direction = "ascent"; select_clip()
		KEY_D: direction = "descent"; select_clip()
		KEY_SPACE: paused = not paused
		KEY_R: elapsed = 0.0
		KEY_C: contact_overlay = not contact_overlay
		KEY_RIGHT:
			if errors.is_empty():
				paused = true
				var index = Contract.frame_at(clip.frames, elapsed)
				elapsed = 0.0
				for i in mini(index+1, clip.frames.size()-1): elapsed += clip.frames[i].duration
				elapsed += 0.000001
	queue_redraw()

func _process(dt):
	if not paused and errors.is_empty(): elapsed += dt
	queue_redraw()

func label(at: Vector2, text: String, size := 20):
	draw_string(ThemeDB.fallback_font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color("#e6e2dd"))

func _draw():
	draw_rect(Rect2(0,0,1280,720), Color("#182131"))
	label(Vector2(36,44), "ART-10  /  " + candidate.to_upper() + "  /  " + direction.to_upper(), 26)
	label(Vector2(36,76), "Review only - creator approval required before live animation replacement.", 18)
	if not errors.is_empty():
		label(Vector2(36,190), "NEW ANIMATION DRAWINGS PENDING", 30)
		label(Vector2(36,230), "Playback is blocked until the production clip contract passes.")
		for i in mini(errors.size(), 8): label(Vector2(36,270+i*28), str(errors[i]), 17)
	else:
		var index = Contract.frame_at(clip.frames, elapsed)
		var frame = clip.frames[index]
		var root = Vector2(frame.root[0], frame.root[1])
		var pivot = Vector2(frame.pivot[0], frame.pivot[1])
		draw_set_transform(Vector2(640,430)-root)
		for tread in clip.treads:
			draw_rect(Rect2(tread[0],tread[2],tread[1]-tread[0],500),Color("#434b65"))
			draw_line(Vector2(tread[0],tread[2]),Vector2(tread[1],tread[2]),Color("#c1b39b"),3)
		var r = frame.region
		draw_texture_rect_region(textures[frame.asset],Rect2(root-pivot,Vector2(r[2],r[3])),Rect2(r[0],r[1],r[2],r[3]))
		if contact_overlay:
			for contact in frame.contacts:
				draw_circle(root+Vector2(contact.sole[0],contact.sole[1])-pivot,4,Color("#a3ef84"))
		draw_set_transform(Vector2.ZERO)
		label(Vector2(36,620), "%s / frame %d / %.2f s" % [frame.phase,index,elapsed])
	label(Vector2(36,674), "1 grounded  2 expressive  A ascent  D descent  Space pause  R restart  Right step  C contacts", 17)
