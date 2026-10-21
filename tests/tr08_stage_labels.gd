extends "res://tests/native_cinematic_transitions.gd"
## TR08 B3b: the stair stage's top-bar clip line is a developer aid. Hidden for bound
## ART-08 clips unless --tr08-debug-labels; always shown for a true stand-in (interface
## rule). The bottom destination plate stays. Rendered runs also measure the top bar:
## it must be a clean uniform letterbox band (no text) during the climb.
const Library = preload("res://scripts/tr08_clip_library.gd")
var t8

func climb(index:int,feet:Vector2,sample:Callable):
	for k in [KEY_A,KEY_D,KEY_E]: key(k,false)
	reset(index);t8=w.cinematic_transitions.tr08
	w.cinematic_transitions.reduced=false;t8.reduced=false
	w.player.position=feet;w.player.velocity=Vector2.ZERO;w.camera.reset_smoothing();live()
	await wait_ticks(8)
	key(KEY_E,true);await wait_ticks(1);key(KEY_E,false)
	for tick in 400:
		await wait_ticks(1)
		if t8.stair.phase=="climb": await sample.call(tick)
		if tick>3 and t8.stair.phase=="" and w.transition<=0: break

func top_uniform_rows(img:Image) -> int:
	var W=img.get_width();var ref=img.get_pixel(W/2,0);var run=0
	for y in img.get_height()/2:
		for x in range(0,W,16):
			var c=img.get_pixel(x,y)
			if absf(c.r-ref.r)+absf(c.g-ref.g)+absf(c.b-ref.b)>0.10: return run
		run+=1
	return run

func run():
	await process_frame
	w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w;freeze();seed_fixture()
	t8=w.cinematic_transitions.tr08
	check(not t8.debug_labels,"Developer label flag is off by default")
	var rendered=DisplayServer.get_name()!="headless"
	for pair in [[14,Vector2(1420,478)],[17,Vector2(1650,1298)]]:
		var shown=[];var plate=[0.0];var rows=[]
		await climb(pair[0],pair[1],func(t):
			if t8.stair.kaze.is_standin(): return
			shown.append(t8.stair.top_label());plate[0]=maxf(plate[0],t8.stair.plate_alpha())
			if rendered and t%20==0 and t8.stair.elapsed>t8.stair.cover_at+t8.stair.open_out+0.05:
				await process_frame;await RenderingServer.frame_post_draw
				rows.append(top_uniform_rows(root.get_texture().get_image())))
		var any=false;for s in shown: any=any or not s.is_empty()
		check(shown.size()>10 and not any,"R%d stair: no top developer clip line for bound ART-08 clips (%d samples)"%[pair[0],shown.size()])
		check(plate[0]>0.99,"R%d stair: bottom destination plate is shown"%pair[0])
		if rendered:
			check(rows.size()>0 and rows.min()>=50,"R%d stair (rendered): top letterbox band is uniform, min %s rows"%[pair[0],rows])
	# A true stand-in is always labelled, without the flag.
	var standins=Library.build("res://does/not/exist.json")
	var saved=t8.table.stair_ascend_loop
	t8.table.stair_ascend_loop=standins.stair_ascend_loop
	var labels=[]
	await climb(14,Vector2(1420,478),func(t): if t8.stair.current=="stair_ascend_loop": labels.append(t8.stair.top_label()))
	var ok=labels.size()>5
	for s in labels: ok=ok and Library.STANDIN_LABEL in s
	check(ok,"A true stand-in clip keeps its STAND-IN label on the stage without the flag")
	t8.table.stair_ascend_loop=saved
	# Developer flag shows the bound clip names.
	t8.debug_labels=true
	labels=[]
	await climb(14,Vector2(1420,478),func(t): labels.append(t8.stair.top_label()))
	ok=labels.size()>5
	for s in labels: ok=ok and s.begins_with("ART-08 · stair_")
	check(ok,"--tr08-debug-labels shows the bound ART-08 clip names")
	t8.debug_labels=false
	w.queue_free();current_scene=null
	for i in 3: await process_frame
	print("TR08 LABELS: %d checks, %d failure(s)"%[checks,failures]);quit(1 if failures else 0)
