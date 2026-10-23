extends Node2D
var bank
var clock = 0.0
var frozen = false
var capture = ""
var kaze: Texture2D
var captured = false
var nearest = false
func _ready():
	var cache = ""
	var code = ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--cache="): cache = arg.trim_prefix("--cache=")
		if arg.begins_with("--code="): code = arg.trim_prefix("--code=")
		if arg.begins_with("--capture="): capture = arg.trim_prefix("--capture=")
	if code.is_empty(): get_tree().quit(1); return
	bank = load(code.path_join("bank.gd")).new()
	if not bank.open(cache): get_tree().quit(1); return
	var img = Image.load_from_file(code.path_join("../../assets/kaze/cleaned/kaze_idle_strip.png"))
	kaze = ImageTexture.create_from_image(img.get_region(Rect2i(0,0,272,724)))
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
func _process(delta):
	if bank == null: return
	if not frozen: clock += delta
	queue_redraw()
	if not capture.is_empty() and clock > 1.0 and not captured:
		captured = true; take_capture.call_deferred()
func take_capture():
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(capture)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	queue_redraw()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(capture.get_basename()+"_nearest.png")
	get_tree().quit()
func _unhandled_key_input(event):
	if not event.is_pressed() or event.is_echo(): return
	if event.keycode == KEY_SPACE: frozen = not frozen
	if event.keycode == KEY_F:
		nearest = not nearest
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST if nearest else CanvasItem.TEXTURE_FILTER_LINEAR
	if event.keycode == KEY_ESCAPE: get_tree().quit()
func text(at: Vector2, value: String, size = 20, color = Color("d9e6dd")):
	draw_string(ThemeDB.fallback_font,at,value,HORIZONTAL_ALIGNMENT_LEFT,-1,size,color)
func reference(feet):
	draw_texture_rect(kaze,Rect2(feet+Vector2(-136,-591)*0.2649908807,Vector2(272,724)*0.2649908807),false)
func panel(rect, title, subtitle):
	draw_style_box(style(),rect)
	text(rect.position+Vector2(22,34),title,22)
	text(rect.position+Vector2(22,62),subtitle,15,Color("93aaa2"))
func style():
	var s = StyleBoxFlat.new()
	s.bg_color = Color("12232b"); s.border_color = Color("31514d")
	s.set_border_width_all(1); s.set_corner_radius_all(12)
	return s
func _draw():
	if bank == null or kaze == null: return
	text(Vector2(36,48),"KAZE  /  ENVIRONMENTAL ASSET REVIEW",30)
	text(Vector2(36,80),"ART-11     Selected-use pilots  /  Native Godot 4.6.1  /  Creator review pending",17,Color("94c8b2"))
	var panels = [Rect2(32,112,676,330),Rect2(732,112,676,330),Rect2(32,464,676,330),Rect2(732,464,676,330)]
	panel(panels[0],"01  Overgrown masonry","Moss inlay + sparse animation. Exact walkable top remains visible.")
	panel(panels[1],"02  Underground modules","Cave surface + recessed rock. No new collision from art.")
	panel(panels[2],"03  Poison plant presentation","88px-wide body inside the 96 x 100 sensor. Phase owns danger.")
	panel(panels[3],"04  Slime candidates","Green preferred / amber alternate. Combat poses remain provisional.")
	draw_texture_rect(bank.frame("column",0),Rect2(75,197,110,210),false,Color(0.35,0.48,0.48,0.75))
	draw_texture_rect(bank.frame("moss_surface",0),Rect2(58,364,624,40),true,Color("b1c0b9"))
	draw_line(Vector2(58,364),Vector2(682,364),Color("b6cdb1"),2)
	bank.paint(self,"flower",Vector2(352,364),clock,Color("c0d0c7"))
	bank.paint(self,"grass",Vector2(443,364),clock,Color("a5c6b3"))
	bank.paint(self,"hanging",Vector2(600,325),clock,Color("839d92"))
	reference(Vector2(240,364))
	bank.paint(self,"cave_rocks",Vector2(1190,364),0,Color("667e83"))
	draw_texture_rect(bank.frame("cave_surface",0),Rect2(756,364,626,40),true,Color("9eaeb0"))
	draw_line(Vector2(756,364),Vector2(1382,364),Color("b7c5bd"),2)
	bank.paint(self,"grass",Vector2(1050,364),clock,Color("8fac9d"))
	reference(Vector2(920,364))
	for i in 3:
		var at = Vector2(135+i*190,720)
		var colors = [Color("739b87"),Color("ffce66"),Color("ff747c")]
		bank.paint(self,"poison",at,clock,colors[i])
		draw_rect(Rect2(at+Vector2(-48,-100),Vector2(96,100)),colors[i],false,2)
		text(at+Vector2(-42,28),["SAFE","WARNING","ACTIVE"][i],14,colors[i])
	bank.paint(self,"slime_green",Vector2(970,720),clock)
	bank.paint(self,"slime_orange",Vector2(1190,720),clock,Color("c2baae"))
	reference(Vector2(820,720))
	text(Vector2(906,757),"GREEN / preferred",16)
	text(Vector2(1124,757),"AMBER / alternate",16)
	text(Vector2(36,834),"Space  pause motion    F  linear / nearest comparison    Esc  close",17)
	text(Vector2(36,866),"All source frames retained. Fixed pivots. " + str(bank.decoded) + " cached frames / %.2f MiB RGBA. No production replacement." % (bank.bytes/1048576.0),16,Color("94c8b2"))
