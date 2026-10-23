extends RefCounted
## Decode/upload each selected frame exactly once before gameplay starts.
var manifest: Dictionary
var textures: Dictionary = {}
var root_path = ""
var decoded = 0
var bytes = 0
func open(path: String) -> bool:
	root_path = path
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path.path_join("runtime.json")))
	if not parsed is Dictionary or parsed.get("version") != 1: return false
	manifest = parsed
	for id in manifest.assets:
		var row = manifest.assets[id]
		var frames: Array[Texture2D] = []
		for frame in row.frames:
			var source = path.path_join(frame.path)
			if FileAccess.get_sha256(source) != frame.sha256: push_error("Changed cached frame"); return false
			var img = Image.load_from_file(source)
			if img == null or img.is_empty(): return false
			frames.append(ImageTexture.create_from_image(img))
			decoded += 1
			bytes += img.get_width()*img.get_height()*4
		textures[id] = frames
	return bytes <= 16*1024*1024
func frame(id: String, clock: float, frozen = false) -> Texture2D:
	var frames = textures[id]
	return frames[0 if frozen else posmod(int(clock*manifest.assets[id].fps),frames.size())]
func rect(id: String, feet: Vector2) -> Rect2:
	var row = manifest.assets[id]
	return Rect2(feet-Vector2(row.pivot[0],row.pivot[1]),Vector2(row.canvas_size[0],row.canvas_size[1]))
func paint(canvas: CanvasItem, id: String, feet: Vector2, clock: float, tint = Color.WHITE, frozen = false):
	canvas.draw_texture_rect(frame(id,clock,frozen),rect(id,feet),false,tint)
