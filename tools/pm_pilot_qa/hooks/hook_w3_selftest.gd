extends RefCounted
## QA-owned. Self-test of the Wave 3 MEASUREMENT tools with synthetic stages, so a candidate verdict can be trusted:
## a positive control (a full-viewport stage with a large animated Kaze, no bars) must PASS the full-screen/scale
## measures; a negative control (a half-size window with letterbox bars and a small Kaze) must FAIL them.
## Also checks the true-animation analyzer on the shipped controls.
var q
var w
var L
var stage_nodes=[]

func art():
	# Textured stand-in background (a flat colour would be indistinguishable from huge bars).
	var rng=RandomNumberGenerator.new();rng.seed=7
	var img=Image.create(64,36,false,Image.FORMAT_RGBA8)
	for y in 36:
		for x in 64:
			img.set_pixel(x,y,Color(0.15+0.5*float(x)/64.0+rng.randf()*0.15,0.2+0.4*float(y)/36.0+rng.randf()*0.15,0.45+rng.randf()*0.2,1.0))
	return ImageTexture.create_from_image(img)

func build(kind):
	var layer=CanvasLayer.new();layer.layer=5
	w.add_child(layer);stage_nodes.append(layer)
	var vp=q.root.get_visible_rect().size
	var bg=TextureRect.new();bg.texture=art();bg.stretch_mode=TextureRect.STRETCH_SCALE;bg.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	var kaze=Sprite2D.new()
	kaze.texture=load("res://assets/kaze/cleaned/kaze_run_strip.png");kaze.hframes=8;kaze.vframes=1
	if kind=="positive":
		bg.position=Vector2.ZERO;bg.size=vp
		var sc=(vp.y*0.80)/float(kaze.texture.get_height())
		kaze.scale=Vector2(sc,sc)
	else:
		# bars top and bottom (96 px each) over a half-width window, small Kaze
		bg.position=Vector2(vp.x*0.25,96);bg.size=Vector2(vp.x*0.5,vp.y-192)
		var top=ColorRect.new();top.color=Color(0.05,0.05,0.1);top.position=Vector2.ZERO;top.size=Vector2(vp.x,96);layer.add_child(top)
		var bot=ColorRect.new();bot.color=Color(0.05,0.05,0.1);bot.position=Vector2(0,vp.y-96);bot.size=Vector2(vp.x,96);layer.add_child(bot)
		var sc2=(vp.y*0.25)/float(kaze.texture.get_height())
		kaze.scale=Vector2(sc2,sc2)
	layer.add_child(bg);layer.add_child(kaze)
	kaze.position=vp/2.0
	return kaze

func run(qa):
	q=qa;w=qa.w
	var hooks_dir=qa.hooks_dir
	L=load(hooks_dir.path_join("w3_lib.gd")).new();L.setup(qa,hooks_dir)
	if not L.rendered:
		q.skip("[W3-SELFTEST-FULLSCREEN] needs a rendered display. NOT a pass.")
	for kind in ["positive","negative"]:
		var holder={"k":null}
		var press=func():
			holder.k=build(kind)
		var tick=func(t):
			if holder.k!=null and is_instance_valid(holder.k):
				holder.k.frame=(t/6)%8
				holder.k.position.x+=1.0
			if t==110:
				for n in stage_nodes: n.queue_free()
				stage_nodes.clear()
		var res=await L.drive("selftest_"+kind,press,w.room,w.ROOM_NAMES[w.room],tick,300,10)
		if L.rendered:
			var e=L.fullscreen_eval(res)
			print("QA W3 SELFTEST ",kind," ",JSON.stringify({"fullscreen":e.fullscreen,"letterbox":e.letterbox,"kaze":e.kaze,"cov_share":e.cov_share,"delta":e.delta,"kh_max":e.kh.max,"kh_share":e.kh.share}))
			if kind=="positive": q.check(e.fullscreen and e.letterbox and e.kaze,"[W3-SELFTEST-POSITIVE] synthetic full-viewport stage passes all three presentation measures (stage-only coverage grabs>=95%%: %.0f%%, bars added %.1f%%, Kaze %.0f%%)"%[e.cov_share*100.0,e.delta*100.0,e.kh.max*100.0])
			else: q.check((not e.fullscreen) and (not e.letterbox) and (not e.kaze),"[W3-SELFTEST-NEGATIVE] synthetic letterboxed small-window stage fails all three measures (fullscreen=%s letterbox_ok=%s kaze_ok=%s)"%[e.fullscreen,e.letterbox,e.kaze])
		var an=L.analyze("selftest_"+kind)
		print("QA W3 SELFTEST ",kind," analyzer ",an.get("verdict")," moving=",an.get("moving_windows")," distinct=",an.get("distinct_poses_total"))
		if kind=="positive": q.check(String(an.get("verdict","")).begins_with("TRUE_ANIMATION"),"[W3-SELFTEST-ANIM-POS] the animated run-strip stage is judged true animation (%s)"%an.get("verdict"))
		await q.wait_ticks(20)
	var out=[]
	var rc=OS.execute("python3",["-I",L.analyzer,"--controls",L.project_dir],out,true)
	q.check(rc==0,"[W3-SELFTEST-ANIM-CONTROLS] analyzer controls: approved run strip passes; held/scaled/bobbed/ART-04 held keys fail (rc %d)"%rc)
