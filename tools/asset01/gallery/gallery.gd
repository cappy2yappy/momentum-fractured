extends Node2D
## Local-only review subproject. No production world, actors, autoloads, or saves.
const BUDGET = 48 * 1024 * 1024
var stage = ""
var packs: Array = []
var pack_index = 0
var sequence_index = 0
var frame = 0
var region_index = -1
var elapsed = 0.0
var review_fps = 12.0
var playing = true
var nearest = false
var native_pixels = false
var user_scale = 0.25
var cache: Dictionary = {}
var lru: Array = []
var cache_bytes = 0
var peak_cache_bytes = 0
var decodes = 0
var decode_usec = 0
var missing: Array = []
var texture: Texture2D
var source_size: Vector2 = Vector2.ZERO
var kaze: Texture2D
var native_capture = false
var capture_root = ""
var samples: Array = []
var capture_start = 0
var phase = -1
var dwell = 0.0
var captures: Array = []
var capture_plan: Array = []
var telemetry: Array = []
func _ready():
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--stage="): stage = arg.trim_prefix("--stage=")
		if arg.begins_with("--capture="): capture_root = arg.trim_prefix("--capture="); native_capture = true
	if stage.is_empty():
		push_error("Pass -- --stage=/absolute/asset01-staging"); return
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(stage.path_join("gallery.json")))
	if not parsed is Dictionary or not parsed.get("packs") is Array: push_error("Invalid intake manifest"); return
	packs = parsed.packs
	# Read approved idle artwork without import or modifying it. Same runtime frame/scale.
	var path = ProjectSettings.globalize_path("res://../../../assets/kaze/cleaned/kaze_idle_strip.png")
	var image = Image.load_from_file(path)
	if not image.is_empty(): kaze = ImageTexture.create_from_image(image.get_region(Rect2i(0,0,272,724)))
	show_current()
	if native_capture:
		DirAccess.make_dir_recursive_absolute(capture_root)
		for pi in packs.size():
			for si in packs[pi].sequences.size():
				capture_plan.append([pi,si,-1])
				if not packs[pi].sequences[si].get("regions",[]).is_empty(): capture_plan.append([pi,si,0])
		capture_start = Time.get_ticks_usec()
func selection() -> Dictionary:
	return packs[pack_index].sequences[sequence_index]
func select_pack(index: int):
	pack_index = clampi(index,0,packs.size()-1); sequence_index = 0; reset()
func reset():
	frame = 0; region_index = -1; elapsed = 0; texture = null; show_current()
func show_current():
	if packs.is_empty(): return
	var seq = selection()
	frame = posmod(frame,seq.frames.size())
	var path = stage.path_join("extracted").path_join(packs[pack_index].slug).path_join(seq.frames[frame])
	var key = path + ("@full" if native_pixels else "@768")
	if cache.has(key):
		texture = cache[key].texture; source_size = cache[key].source_size
		lru.erase(key); lru.append(key); return
	var start = Time.get_ticks_usec()
	var image = Image.load_from_file(path)
	if image.is_empty():
		missing.append(path); texture = null; return
	source_size = Vector2(image.get_size())
	if not native_pixels and maxf(source_size.x,source_size.y)>768:
		var factor = 768.0/maxf(source_size.x,source_size.y)
		image.resize(maxi(1,roundi(source_size.x*factor)),maxi(1,roundi(source_size.y*factor)),Image.INTERPOLATE_LANCZOS)
	image.convert(Image.FORMAT_RGBA8)
	var bytes = image.get_width()*image.get_height()*4
	while cache_bytes+bytes > BUDGET and not lru.is_empty():
		var oldest = lru.pop_front(); cache_bytes -= cache[oldest].bytes; cache.erase(oldest)
	texture = ImageTexture.create_from_image(image)
	# Oversized original atlases remain displayed once; never enter the bounded cache.
	if bytes<=BUDGET:
		cache[key] = {"texture":texture,"bytes":bytes,"source_size":source_size}; lru.append(key); cache_bytes += bytes
	peak_cache_bytes = maxi(peak_cache_bytes,cache_bytes)
	decodes += 1; decode_usec += Time.get_ticks_usec()-start
func _process(dt):
	if packs.is_empty(): return
	telemetry.append(dt)
	if playing and selection().frames.size()>1:
		elapsed += dt
		var next = int(elapsed*review_fps)%selection().frames.size()
		if next != frame: frame = next; show_current()
	if native_capture: capture_step(dt)
	queue_redraw()
func _unhandled_key_input(event):
	if not event.pressed or event.echo or packs.is_empty(): return
	if event.keycode>=KEY_1 and event.keycode<=KEY_6: select_pack(event.keycode-KEY_1)
	match event.keycode:
		KEY_UP: sequence_index = posmod(sequence_index-1,packs[pack_index].sequences.size()); reset()
		KEY_DOWN: sequence_index = posmod(sequence_index+1,packs[pack_index].sequences.size()); reset()
		KEY_SPACE: playing = not playing
		KEY_LEFT: playing = false; frame -= 1; show_current()
		KEY_RIGHT: playing = false; frame += 1; show_current()
		KEY_F: review_fps = 24.0 if review_fps==12 else (30.0 if review_fps==24 else (6.0 if review_fps==30 else 12.0)); reset()
		KEY_N: nearest = not nearest
		KEY_V: native_pixels = not native_pixels; show_current()
		KEY_EQUAL: user_scale = minf(2.0,user_scale*1.25)
		KEY_MINUS: user_scale = maxf(0.015625,user_scale/1.25)
		KEY_R: user_scale = 0.25; reset()
		KEY_COMMA: region_index = maxi(-1,region_index-1)
		KEY_PERIOD: region_index = mini(selection().get("regions",[]).size()-1,region_index+1)
		KEY_ESCAPE: get_tree().quit()
func line(at: Vector2,text: String,size=20,color=Color("c8d5e3")):
	draw_string(ThemeDB.fallback_font,at,text,HORIZONTAL_ALIGNMENT_LEFT,-1,size,color)
func checker(rect: Rect2):
	draw_rect(rect,Color("17212d"))
	for y in range(int(rect.position.y),int(rect.end.y),24):
		for x in range(int(rect.position.x),int(rect.end.x),24):
			if ((x-int(rect.position.x))/24+(y-int(rect.position.y))/24)%2==0: draw_rect(Rect2(x,y,24,24),Color("202e3d"))
func _draw():
	line(Vector2(28,36),"KAZE / ASSET-01 / LOCAL THIRD-PARTY INTAKE",25)
	line(Vector2(28,65),"Review only. Original art remains staged; no rooms, collision, progression or Kaze replacement.",17)
	if packs.is_empty(): line(Vector2(28,120),"Supply --stage=/absolute/asset01-staging",24); return
	var pack = packs[pack_index]; var seq = selection()
	line(Vector2(28,108),"%d / %d   %s" % [pack_index+1,packs.size(),pack.name],23,Color("f5c978"))
	line(Vector2(28,138),"%d / %d   %s" % [sequence_index+1,pack.sequences.size(),seq.name],18)
	checker(Rect2(28,160,870,530)); checker(Rect2(920,160,490,530))
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST if nearest else CanvasItem.TEXTURE_FILTER_LINEAR
	if texture != null:
		var regions = seq.get("regions",[])
		var source_region = Rect2(Vector2.ZERO,source_size)
		if region_index>=0 and region_index<regions.size():
			var r = regions[region_index]; source_region = Rect2(r[0],r[1],r[2],r[3])
		var texture_region = Rect2(source_region.position/source_size*texture.get_size(),source_region.size/source_size*texture.get_size())
		var s = minf(800.0/source_region.size.x,480.0/source_region.size.y)
		var size = source_region.size*s
		draw_texture_rect_region(texture,Rect2(Vector2(463,425)-size/2,size),texture_region)
		# Full sequence canvas retains registration; candidate static slices lack authored pivots.
		var comparison_size = source_region.size*user_scale
		var comparison_at = Vector2(1100,588)-Vector2(comparison_size.x/2,comparison_size.y)
		draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
		# Clip oversized comparison images through explicit source crop.
		var area = Rect2(comparison_at,comparison_size).intersection(Rect2(920,180,490,410))
		if area.has_area():
			var uv = Rect2(texture_region.position+(area.position-comparison_at)/comparison_size*texture_region.size,area.size/comparison_size*texture_region.size)
			draw_texture_rect_region(texture,area,uv)
	if kaze != null: draw_texture_rect(kaze,Rect2(Vector2(1325-272*0.2649908807/2,588-591*0.2649908807),Vector2(272,724)*0.2649908807),false)
	draw_line(Vector2(940,588),Vector2(1390,588),Color("c5af7c"),2)
	line(Vector2(940,620),"Pack: %.4fx | Kaze: approved idle scale"%user_scale,16)
	line(Vector2(940,649),"Canvas preserved" if region_index<0 else "Candidate atlas slice; pivot not authored",16)
	line(Vector2(45,673),"Fit view / real alpha / %s"%("nearest" if nearest else "linear"),16)
	line(Vector2(28,724),"Frame %d/%d | review %.0f FPS (source timing unknown) | PNG %dx%d"%[frame+1,seq.frame_count,review_fps,source_size.x,source_size.y],19)
	line(Vector2(28,755),"Cache %.1f / 48 MiB | peak %.1f MiB | %d decodes | %s"%[cache_bytes/1048576.0,peak_cache_bytes/1048576.0,decodes,"FULL ORIGINAL" if native_pixels else "768px preview cap"],18)
	line(Vector2(28,787),"1-6 pack | Up/Down asset | Space pause | Left/Right frame | F review FPS | N filtering",17)
	line(Vector2(28,815),"+/- scale | V original decode | ,/. atlas region %d/%d | R reset | Esc quit"%[region_index+1,seq.get("regions",[]).size()],17)
	line(Vector2(28,856),"Original animation rates and pivot metadata are not supplied. These controls do not establish gameplay timing.",16,Color("f5c978"))
func capture_step(dt):
	dwell += dt
	var target_phase = int((Time.get_ticks_usec()-capture_start)/1000000.0/0.65)
	if target_phase>=capture_plan.size():
		var sorted = telemetry.duplicate(); sorted.sort()
		var result = {"engine":Engine.get_version_info().string,"renderer":RenderingServer.get_video_adapter_name(),"samples":samples,"cache_peak_bytes":peak_cache_bytes,"cache_budget_bytes":BUDGET,"decodes":decodes,"decode_usec":decode_usec,"frame_dt_p50_ms":sorted[int(sorted.size()*0.5)]*1000,"frame_dt_p95_ms":sorted[int(sorted.size()*0.95)]*1000,"missing":missing,"review_fps":review_fps,"preview_max_dimension":768,"texture_memory_bytes":RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TEXTURE_MEM_USED)}
		FileAccess.open(capture_root.path_join("performance.json"),FileAccess.WRITE).store_string(JSON.stringify(result,"  "))
		get_tree().quit(0 if missing.is_empty() else 1); native_capture = false; return
	if target_phase!=phase:
		phase = target_phase
		var entry = capture_plan[phase]
		select_pack(entry[0]); sequence_index = entry[1]; reset(); region_index = entry[2]; captures.append(phase)
		capture_after_draw(phase)
func capture_after_draw(index):
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var path = capture_root.path_join("%02d-%s-%02d.png"%[index+1,packs[pack_index].slug,sequence_index+1])
	get_viewport().get_texture().get_image().save_png(path)
	samples.append({"pack":packs[pack_index].name,"asset":selection().name,"region_index":region_index,"time":(Time.get_ticks_usec()-capture_start)/1000000.0,"path":path})
