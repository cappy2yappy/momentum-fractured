extends SceneTree
# ART-07 Phase 1 Godot validation (run headless):
#   godot --headless --path . --script res://tools/art07/validate_idle_godot.gd
# Checks the IMPORTED textures (Godot's own importer output), not the PNG files on disk.
# Does not touch player.gd, collision, movement or the default idle binding.

const CELL_W := 272
const CELL_H := 724
const BASELINE := 591.0
const ENGINE_SCALE := 0.2649908807267889
const APPROVED := "res://assets/kaze/cleaned/kaze_idle_strip.png"
const C8 := "res://assets/art07/idle_procedural/kaze_idle_procedural_8f_strip.png"
const C16 := "res://assets/art07/idle_procedural/kaze_idle_procedural_16f_strip.png"

var results: Array = []

func check(id: String, ok: bool, detail: String) -> void:
	results.append({"id": id, "pass": ok, "detail": detail})

func frame_img(img: Image, i: int) -> Image:
	return img.get_region(Rect2i(i * CELL_W, 0, CELL_W, CELL_H))

func _init() -> void:
	var approved: Texture2D = load(APPROVED)
	var c8: Texture2D = load(C8)
	var c16: Texture2D = load(C16)
	check("textures_load", approved != null and c8 != null and c16 != null, "approved, 8f and 16f import and load as Texture2D")
	if approved == null or c8 == null or c16 == null:
		_finish()
		return
	check("size_8f_matches_live_idle_strip", c8.get_size() == approved.get_size(),
		"8f %s vs approved %s (equal size means identical sprite.offset and drop-in hframes=8)" % [c8.get_size(), approved.get_size()])
	check("size_16f", c16.get_size() == Vector2(CELL_W * 16, CELL_H), "16f %s" % c16.get_size())
	# sprite contract math copied from scripts/player.gd animate(): offset = (0, tex_h/2 - baseline)
	var off_a := Vector2(0, approved.get_height() / 2.0 - BASELINE)
	var off_8 := Vector2(0, c8.get_height() / 2.0 - BASELINE)
	check("sprite_offset_unchanged", off_a == off_8, "approved offset %s, 8f offset %s, scale %s" % [off_a, off_8, ENGINE_SCALE])
	var ai := approved.get_image()
	var i8 := c8.get_image()
	var i16 := c16.get_image()
	for im in [ai, i8, i16]:
		im.convert(Image.FORMAT_RGBA8)
	# frame 0 of the candidate equals approved frame 1 after Godot's lossless import
	check("frame0_equals_approved_frame1", frame_img(i8, 0).get_data() == frame_img(ai, 1).get_data(),
		"RGBA bytes of candidate 8f frame 0 vs approved frame 1 read back from Godot textures")
	var feet_ok := true
	var src_feet := frame_img(ai, 1).get_region(Rect2i(0, 548, CELL_W, CELL_H - 548)).get_data()
	for i in 8:
		if frame_img(i8, i).get_region(Rect2i(0, 548, CELL_W, CELL_H - 548)).get_data() != src_feet:
			feet_ok = false
	for i in 16:
		if frame_img(i16, i).get_region(Rect2i(0, 548, CELL_W, CELL_H - 548)).get_data() != src_feet:
			feet_ok = false
	check("feet_rows_548_plus_identical_in_all_frames", feet_ok, "24 frames compared to the approved source feet region")
	# lowest opaque row per frame must stay on 590 (baseline 591 contract)
	var base_ok := true
	for i in 8:
		var f := frame_img(i8, i)
		var lowest := -1
		for y in range(CELL_H - 1, -1, -1):
			var hit := false
			for x in range(0, CELL_W):
				if f.get_pixel(x, y).a > 8.0 / 255.0:
					hit = true
					break
			if hit:
				lowest = y
				break
		if lowest != 590:
			base_ok = false
	check("baseline_row_590_8f", base_ok, "lowest opaque row of each 8f frame read from Godot textures")
	# SpriteFrames as a testbed would build it
	var sf := SpriteFrames.new()
	sf.add_animation("idle_proc_8f")
	sf.set_animation_speed("idle_proc_8f", 1.0 / 0.16)
	sf.set_animation_loop("idle_proc_8f", true)
	for i in 8:
		var at := AtlasTexture.new()
		at.atlas = c8
		at.region = Rect2(i * CELL_W, 0, CELL_W, CELL_H)
		sf.add_frame("idle_proc_8f", at)
	check("spriteframes_8f", sf.get_frame_count("idle_proc_8f") == 8 and is_equal_approx(sf.get_animation_speed("idle_proc_8f"), 6.25),
		"frames=%d speed=%.3f loop=%s" % [sf.get_frame_count("idle_proc_8f"), sf.get_animation_speed("idle_proc_8f"), sf.get_animation_loop("idle_proc_8f")])
	# Sprite2D stepping exactly as player.gd does it for the idle clip
	var sp := Sprite2D.new()
	sp.texture = c8
	sp.hframes = 8
	var seen := {}
	for step in 16:
		var clock := step * 0.08
		sp.frame = int(clock / 0.16) % sp.hframes
		seen[sp.frame] = true
	check("sprite2d_hframes8_cycle", seen.size() == 8, "player.gd style stepping visits %d distinct frames" % seen.size())
	_finish()

func _finish() -> void:
	var failed := 0
	for r in results:
		print("RESULT ", JSON.stringify(r))
		if not r["pass"]:
			failed += 1
	print("SUMMARY checks=%d failed=%d godot=%s" % [results.size(), failed, Engine.get_version_info()["string"]])
	quit(1 if failed > 0 else 0)
