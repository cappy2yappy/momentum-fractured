extends RefCounted
## QA-owned, test-only. Candidate-agnostic observer for Wave 3 embodied cinematics.
## It never touches candidate code paths: it watches the scene tree, the camera, the physics tick and (in rendered
## runs) the pixels. Everything a check needs is measured from outside, so the same hooks judge the controls
## (PR51, PR61) and every Wave 3 candidate without knowing the candidate's class names.
const KEEP=["kaze","art04","art06","art08"]
const SKIP=["environment","canal","door","wipe","stair_flight","stair_front","guard","keeper","prefab","kunai","badge","enemy","icon"]
var q
var w
var rendered=false
var samples=[]
var baseline_layers=[]
var out_dir=""
var bbox_cache={}
var analyzer=""
var project_dir=""
var grabs=[]
var label_hits={}
var max_zoom=1.0
var layers_seen={}

func setup(qa,hooks_dir):
	q=qa;w=qa.w
	rendered=DisplayServer.get_name()!="headless" and RenderingServer.get_current_rendering_driver_name()!="dummy"
	out_dir=qa.out_dir if qa.out_dir!="" else "user://w3_out"
	DirAccess.make_dir_recursive_absolute(out_dir)
	analyzer=hooks_dir.path_join("../true_animation.py").simplify_path()
	project_dir=ProjectSettings.globalize_path("res://")

func layers_now():
	var out=[]
	_walk_layers(q.root,out)
	return out
func _walk_layers(n,out):
	if n is CanvasLayer: out.append(n)
	for c in n.get_children(): _walk_layers(c,out)

func hud_layer():
	var n=w.hud
	while n!=null and not (n is CanvasLayer): n=n.get_parent()
	return n

func mark_baseline():
	# Baseline = the HUD's own CanvasLayer only. Any other visible CanvasLayer (a controller's overlay, a stage)
	# counts as candidate presentation, whether or not it existed before the sequence started.
	baseline_layers=[]
	var h=hud_layer()
	if h!=null: baseline_layers.append(h)
	label_hits={};grabs=[];samples=[];max_zoom=1.0;layers_seen={}

func tex_info(s):
	# Returns {} if not a Kaze-like frame, else path/frame/hframes/vframes/region/size.
	var tex=null;var frame=0;var hf=1;var vf=1;var region=[]
	if s is Sprite2D:
		tex=s.texture;frame=s.frame;hf=s.hframes;vf=s.vframes
		if s.region_enabled: region=[s.region_rect.position.x,s.region_rect.position.y,s.region_rect.size.x,s.region_rect.size.y]
	elif s is AnimatedSprite2D:
		if s.sprite_frames==null or not s.sprite_frames.has_animation(s.animation): return {}
		tex=s.sprite_frames.get_frame_texture(s.animation,s.frame)
	elif s is TextureRect:
		tex=s.texture
	if tex==null: return {}
	var path=tex.resource_path
	if tex is AtlasTexture:
		if tex.atlas==null: return {}
		path=tex.atlas.resource_path;region=[tex.region.position.x,tex.region.position.y,tex.region.size.x,tex.region.size.y]
	var low=path.to_lower()
	var ok=false
	for k in KEEP:
		if k in low: ok=true
	# Scenery art is excluded by keyword, but a Kaze clip (file name starting kaze_) is never scenery even if it says door.
	if not path.get_file().to_lower().begins_with("kaze_"):
		for k in SKIP:
			if k in low: ok=false
	if not ok: return {}
	var size=tex.get_size() if not (tex is AtlasTexture) else tex.region.size
	return {"tex":path,"frame":frame,"hframes":hf,"vframes":vf,"region":region,"cell":Vector2(size.x/hf,size.y/vf)}

func bbox_frac(info):
	# Alpha bounding box height of the drawn frame as a fraction of the cell height, read from the source PNG.
	var key=JSON.stringify([info.tex,info.frame,info.hframes,info.vframes,info.region])
	if bbox_cache.has(key): return bbox_cache[key]
	var res=1.0
	var p=ProjectSettings.globalize_path(info.tex)
	if FileAccess.file_exists(info.tex):
		var img=Image.load_from_file(p)
		if img!=null and not img.is_empty():
			var r:Rect2i
			if info.region.size()==4: r=Rect2i(int(info.region[0]),int(info.region[1]),int(info.region[2]),int(info.region[3]))
			else:
				var cw=img.get_width()/info.hframes;var ch=img.get_height()/info.vframes
				r=Rect2i((info.frame%info.hframes)*cw,(info.frame/info.hframes)*ch,cw,ch)
			var sub=img.get_region(r)
			var used=sub.get_used_rect()
			res=float(used.size.y)/maxf(1.0,float(r.size.y))
	bbox_cache[key]=res
	return res

func actors():
	var out=[]
	_walk_actors(q.root,out)
	return out
func _walk_actors(n,out):
	if n is CanvasItem and n.is_visible_in_tree():
		var info=tex_info(n)
		if not info.is_empty():
			var cell:Vector2=info.cell
			var rect:Rect2
			var centered=true;var off=Vector2.ZERO
			if n is Sprite2D: centered=n.centered;off=n.offset
			if n is TextureRect: rect=n.get_global_rect()
			else:
				var local=Rect2((-cell/2.0 if centered else Vector2.ZERO)+off,cell)
				var xf=n.get_global_transform_with_canvas()
				var pts=[xf*local.position,xf*Vector2(local.end.x,local.position.y),xf*local.end,xf*Vector2(local.position.x,local.end.y)]
				rect=Rect2(pts[0],Vector2.ZERO)
				for p in pts: rect=rect.expand(p)
			info["screen_rect"]=[rect.position.x,rect.position.y,rect.size.x,rect.size.y]
			info["node"]=str(n.get_path())
			info["flip"]=(n.flip_h if "flip_h" in n else false)
			info["is_player"]=(n==w.player.sprite)
			info["pos"]=[(n.global_position.x if n is Node2D else rect.position.x),(n.global_position.y if n is Node2D else rect.position.y)]
			out.append(info)
	for c in n.get_children(): _walk_actors(c,out)

func find_labels(target_name):
	# Evidence that the destination-room label exists. Reports the KIND of evidence; pixels are a human review item.
	var needle=target_name.to_lower()
	var kinds=[]
	if needle in w.message.to_lower(): kinds.append("hud_message")
	_walk_text(q.root,needle,kinds)
	var c=w.cinematic_transitions
	var e=w.embodied_transitions
	if e.active and e.target_room>=0 and e.target_room<w.ROOM_NAMES.size() and needle in String(w.ROOM_NAMES[e.target_room]).to_lower(): kinds.append("field:embodied_transitions.target_room(active overlay)")
	var nodes=[c,w.mixed_transitions]
	for n in c.get_children(): nodes.append(n)
	for node in nodes:
		for prop in ["destination","label_text","title_text","destination_label","label"]:
			var v=node.get(prop)
			if typeof(v)==TYPE_STRING and v!="" and needle in v.to_lower(): kinds.append("field:%s.%s"%[node.get_script().resource_path.get_file() if node.get_script() else str(node),prop])
	return kinds
func _walk_text(n,needle,kinds):
	if (n is Label or n is RichTextLabel) and n.is_visible_in_tree():
		var t=n.text if n is Label else n.get_parsed_text()
		if needle in t.to_lower(): kinds.append("node_text:"+str(n.get_path()))
	for c in n.get_children(): _walk_text(c,needle,kinds)

func controlled(extra_actors=0):
	var a=actors()
	var others=0
	for i in a:
		if not i.is_player: others+=1
	return w.transition<=0 and w.player.is_physics_processing() and w.player.sprite.visible and not q.paused and w.camera.zoom==Vector2.ONE and others<=extra_actors

func activity():
	var a=actors()
	for i in a:
		if not i.is_player: return true
	return w.transition>0 or not w.player.is_physics_processing() or not w.player.sprite.visible or w.camera.zoom!=Vector2.ONE

func new_layers():
	var out=[]
	for l in layers_now():
		if not (l in baseline_layers) and l.visible: out.append(l)
	return out

func clear_magenta(): RenderingServer.set_default_clear_color(Color(1,0,1))

func stage_alone():
	# Hide the world canvas and every baseline CanvasLayer (HUD etc.); what is left is the cinematic's own stage.
	if not rendered: return -1.0
	var hid=[]
	for l in baseline_layers:
		if is_instance_valid(l) and l.visible: l.visible=false;hid.append(l)
	var wv=w.visible;w.visible=false
	clear_magenta()
	await q.process_frame
	await RenderingServer.frame_post_draw
	var img=q.root.get_texture().get_image()
	w.visible=wv
	for l in hid: l.visible=true
	var W=img.get_width();var H=img.get_height();var n=0;var hit=0
	for y in range(0,H,6):
		for x in range(0,W,6):
			n+=1
			var c=img.get_pixel(x,y)
			if not (c.r>0.9 and c.g<0.12 and c.b>0.9): hit+=1
	return float(hit)/maxf(1.0,float(n))

func bars_frac(img):
	# Heuristic letterbox/pillarbox detector: contiguous near-uniform rows/columns from each edge of at least 20 px.
	var W=img.get_width();var H=img.get_height()
	var rows=0;var cols=0
	var edges=[[0,1],[H-1,-1]]
	for e in edges:
		var run=0;var y=e[0]
		var ref=img.get_pixel(W/2,y)
		while y>=0 and y<H:
			var uni=true
			for x in range(0,W,16):
				var c=img.get_pixel(x,y)
				if absf(c.r-ref.r)+absf(c.g-ref.g)+absf(c.b-ref.b)>0.10: uni=false;break
			if not uni: break
			run+=1;y+=e[1]
			if run>H/2: break
		if run>=20 and run<=H/2: rows+=run
	for e in [[0,1],[W-1,-1]]:
		var run=0;var x=e[0]
		var ref=img.get_pixel(x,H/2)
		while x>=0 and x<W:
			var uni=true
			for y in range(0,H,16):
				var c=img.get_pixel(x,y)
				if absf(c.r-ref.r)+absf(c.g-ref.g)+absf(c.b-ref.b)>0.10: uni=false;break
			if not uni: break
			run+=1;x+=e[1]
			if run>W/2: break
		if run>=20 and run<=W/2: cols+=run
	return float(rows*W+cols*H-(rows*cols))/float(W*H)

func flat_frac(img):
	# Fraction of 16x16 blocks that are near-uniform: a full-screen wipe/fade scores near 1.
	var W=img.get_width();var H=img.get_height();var flat=0;var n=0
	for by in range(0,H-16,16):
		for bx in range(0,W-16,16):
			n+=1
			var c0=img.get_pixel(bx,by);var same=true
			for dy in [3,8,13]:
				for dx in [3,8,13]:
					var c=img.get_pixel(bx+dx,by+dy)
					if absf(c.r-c0.r)+absf(c.g-c0.g)+absf(c.b-c0.b)>0.06: same=false
			if same: flat+=1
	return float(flat)/maxf(1.0,float(n))

func snap():
	return {"completed":w.completed,"boss":w.boss_defeated,"guard":w.guard_defeated,"relay":w.relay_fragments.duplicate(true),"gates":w.opened_kunai_gates.duplicate(true),
		"flags":w.expansion_flags.duplicate(true),"enc":w.cleared_encounters.duplicate(true),"dj":w.player.double_jump,"dash":w.player.dash_unlocked,"tether":w.player.tether_unlocked,
		"kunai":w.player.kunai_unlocked.duplicate(true),"hp":w.player.hp,"checkpoint":w.checkpoint_room}

## Drives one sequence. press/release are callables issuing REAL key events. Returns a result dictionary.
func drive(name,press,target_room,target_name,extra=null,max_ticks=900,grab_every=0):
	mark_baseline()
	var f0=Engine.get_physics_frames()
	var pf_end=-1
	var started=false;var quiet=0;var end=-1;var rooms=[w.room]
	var req0=w.cinematic_transitions.request_count
	var swap_tick=-1
	var bars0=-1.0
	if rendered:
		await q.process_frame
		await RenderingServer.frame_post_draw
		bars0=bars_frac(q.root.get_texture().get_image())
	await press.call()
	var viewport=q.root.get_visible_rect().size
	for tick in max_ticks:
		await q.wait_ticks(1)
		var a=actors()
		var main=null;var best=-1.0
		for i in a:
			var h=i.screen_rect[3]
			if h>best: best=h;main=i
		var rec={"t":tick/60.0,"visible":main!=null,"room":w.room,"transition":w.transition,"zoom":w.camera.zoom.x,"n_actors":a.size(),"non_player":0,"player_pos":[w.player.position.x,w.player.position.y]}
		for i in a:
			if not i.is_player: rec.non_player+=1
		if main!=null:
			for k in ["tex","frame","hframes","vframes","region","flip","pos","node","is_player"]: rec[k]=main[k]
			rec["screen_rect"]=main.screen_rect
			rec["kaze_h_frac"]=main.screen_rect[3]*bbox_frac(main)/viewport.y
		samples.append(rec)
		max_zoom=maxf(max_zoom,w.camera.zoom.x)
		if w.room!=rooms[-1]: rooms.append(w.room);swap_tick=tick
		for l in new_layers(): layers_seen[str(l.get_path())]=l.layer
		var lab=find_labels(target_name)
		for k in lab: label_hits[k]=label_hits.get(k,0)+1
		if rendered and grab_every>0 and tick>=10 and tick%grab_every==0 and grabs.size()<14:
			var g={"tick":tick}
			await q.process_frame
			await RenderingServer.frame_post_draw
			var img=q.root.get_texture().get_image()
			g["bars"]=bars_frac(img);g["flat"]=flat_frac(img)
			if tick%(grab_every*2)==0:
				var pth=out_dir.path_join("%s_t%03d.png"%[name,tick]);img.save_png(pth)
			if tick%(grab_every*2)==0 or grabs.size()<3:
				g["stage_alone"]=await stage_alone()
			grabs.append(g)
		if extra!=null: await extra.call(tick)
		if not started and activity(): started=true
		if started and controlled(): quiet+=1
		else: quiet=0
		if started and quiet>=15: end=tick-14;pf_end=Engine.get_physics_frames()-f0-14;break
	var secs=(Engine.get_physics_frames()-f0)/60.0
	return {"started":started,"ended":end>=0,"end_tick":end,"physics_frames_to_control":pf_end,"seconds":(end/60.0 if end>=0 else secs),"rooms":rooms,"swap_tick":swap_tick,"max_zoom":max_zoom,
		"requests":w.cinematic_transitions.request_count-req0,"labels":label_hits.duplicate(),"new_layers":layers_seen.duplicate(),"grabs":grabs.duplicate(true),"viewport":[viewport.x,viewport.y],"bars_before":bars0}

func export_samples(name):
	var path=out_dir.path_join("w3_samples_%s.json"%name)
	var f=FileAccess.open(path,FileAccess.WRITE)
	if f==null: return ""
	f.store_string(JSON.stringify({"fps":60,"samples":samples}));f.close()
	return ProjectSettings.globalize_path(path) if path.begins_with("user://") else path

func analyze(name,min_move=14.0):
	var p=export_samples(name)
	if p=="": return {"verdict":"ERROR","reason":"could not write samples"}
	var out=[]
	var rc=OS.execute("python3",["-I",analyzer,"--samples",p,"--root",project_dir],out,true)
	var txt="".join(out)
	var j=JSON.new()
	var start=txt.find("{")
	if start<0 or j.parse(txt.substr(start))!=OK: return {"verdict":"ERROR","reason":"analyzer output unreadable (rc %d): %s"%[rc,txt.left(200)]}
	return j.data

func median(a):
	if a.is_empty(): return -1.0
	var b=a.duplicate();b.sort();return b[b.size()/2]

func kaze_heights(res):
	var hs=[];var big=0;var vis=0
	var last=res.end_tick if res.end_tick>=0 else samples.size()
	for i in range(0,mini(last,samples.size())):
		var s=samples[i]
		if s.get("visible",false):
			vis+=1;hs.append(s.get("kaze_h_frac",0.0))
			if s.get("kaze_h_frac",0.0)>=0.45: big+=1
	return {"max":(hs.max() if not hs.is_empty() else 0.0),"visible_ticks":vis,"big_ticks":big,"share":(float(big)/float(vis) if vis>0 else 0.0),"total_ticks":last}

func fullscreen_eval(res):
	var kh=kaze_heights(res)
	var sa=[];var bars=[]
	for g in res.grabs:
		if res.end_tick>=0 and g.tick>res.end_tick: continue
		if g.has("stage_alone") and g.stage_alone>=0.0: sa.append(g.stage_alone)
		bars.append(g.bars)
	var med=median(sa);var maxbars=(bars.max() if not bars.is_empty() else 0.0)
	var delta=maxbars-maxf(0.0,res.bars_before)
	var nl=res.new_layers.size()
	var full_n=0
	for v in sa:
		if v>=0.95: full_n+=1
	var cov_share=(float(full_n)/float(sa.size()) if sa.size()>0 else 0.0)
	var stage_ok=nl>=1 and cov_share>=0.6
	var camera_ok=nl==0 and delta<=0.02 and kh.share>=0.5
	return {"kh":kh,"sa":sa,"med":med,"maxbars":maxbars,"delta":delta,"nl":nl,"cov_share":cov_share,"stage_ok":stage_ok,"camera_ok":camera_ok,
		"fullscreen":stage_ok or camera_ok,"letterbox":delta<=0.02,"kaze":(kh.max>=0.45 and kh.share>=0.5)}

func fullscreen_checks(tag,res):
	var kh=kaze_heights(res)
	if not rendered:
		q.skip("[W3-%s-FULLSCREEN] viewport coverage needs a rendered display (xvfb + software GL); headless cannot measure it. NOT a pass. (Kaze max height %.2f of viewport from sprite rects)"%[tag,kh.max])
		return
	var e=fullscreen_eval(res)
	print("QA W3 ",tag," fullscreen: new_layers=",res.new_layers," stage_alone_median=",e.med," stage_alone_all=",e.sa," bars_before=",res.bars_before," bars_max=",e.maxbars," kaze_h=",kh)
	q.check(e.fullscreen,"[W3-%s-FULLSCREEN] stage fills the viewport: dedicated stage layers=%d, stage-only coverage >=95%% on %.0f%% of %d grabs (median %.0f%%; need >=60%% of grabs), or camera-only with no bars and large Kaze (camera_ok=%s)"%[tag,e.nl,e.cov_share*100.0,e.sa.size(),e.med*100.0,e.camera_ok])
	q.check(e.letterbox,"[W3-%s-NO-LETTERBOX] letterbox/pillarbox bars added during the sequence: %.1f%% of viewport (before %.1f%%, max %.1f%%; need <=2%% added)"%[tag,e.delta*100.0,maxf(0.0,res.bars_before)*100.0,e.maxbars*100.0])
	q.check(e.kaze,"[W3-%s-KAZE-SCALE] Kaze alpha height reaches %.0f%% of viewport height, >=45%% on %.0f%% of %d visible ticks (need max>=45%%, share>=50%%)"%[tag,kh.max*100.0,kh.share*100.0,kh.visible_ticks])
