extends RefCounted
## QA-owned. Combined-interaction checks for Level (roof course, w.boundary_rects) plus Transition cinematics:
## arrival and endpoint feet stay valid (supported, body clear of every boundary solid), Kaze's body never overlaps a
## boundary solid during any sequence, and whether the roof band is inside the camera view during a sequence
## (then the captures must be read by a human). Skips when the checkout has no boundary_rects (no Level candidate).
var q
var w
var c
var L

func body_hits(p,rects):
	var body=Rect2(p.x-14,p.y-60,28,60)
	for r in rects:
		if body.grow(-1).intersects(r): return true
	return false

func view_rect():
	var z=w.camera.zoom.x
	var vp=q.root.get_visible_rect().size/z
	var ctr=w.camera.get_screen_center_position()
	return Rect2(ctr-vp/2.0,vp)

func seq(tag,from,to,off,key_code,hold):
	q.release_all();q.reset(from)
	w.player.position=c.endpoint(w,from,to).at+Vector2(off,-2);w.player.velocity=Vector2.ZERO
	w.camera.reset_smoothing();q.live();await q.wait_ticks(6)
	var rects=w.boundary_rects
	var st={"overlap":0,"roof_in_view":0,"ticks":0,"roof_view_with_actor":0}
	var press=func(): q.key(key_code,true)
	var tick=func(t):
		if t==2 and not hold: q.key(key_code,false)
		st.ticks+=1
		if body_hits(w.player.position,rects): st.overlap+=1
		var vr=view_rect()
		for r in rects:
			if r.position.y<=0 and r.end.y>0 and vr.intersects(Rect2(r.position.x,0,r.size.x,56)) and vr.position.y<56:
				st.roof_in_view+=1;break
	var res=await L.drive("combined_"+tag,press,to,w.ROOM_NAMES[to],tick,900,8)
	q.key(key_code,false)
	q.check(res.ended and w.room==to and not body_hits(w.player.position,rects),"[W3-COMBINED-%s-ARRIVAL] sequence ends in R%d with Kaze's body clear of every boundary solid (feet %s)"%[tag,to,w.player.position])
	q.check(st.overlap==0,"[W3-COMBINED-%s-NO-OVERLAP] Kaze's body overlapped a boundary solid on %d of %d ticks"%[tag,st.overlap,st.ticks])
	print("QA W3 COMBINED ",tag," roof_band_in_camera_view_ticks=",st.roof_in_view," of ",st.ticks," max_zoom=",res.max_zoom)
	if st.roof_in_view>0: q.skip("[W3-COMBINED-%s-ROOF-VISIBLE] the roof band was inside the camera view on %d of %d ticks: read the captures; automated pixels cannot say whether it clips the cinematic. NOT a pass."%[tag,st.roof_in_view,st.ticks])

func run(qa):
	q=qa;w=qa.w;c=w.cinematic_transitions
	L=load(qa.hooks_dir.path_join("w3_lib.gd")).new();L.setup(qa,qa.hooks_dir)
	var rects=w.get("boundary_rects")
	if rects==null:
		q.skip("[W3-COMBINED] checkout has no w.boundary_rects (no Level roof course). NOT a pass.")
		return
	q.reset(14)
	q.check(w.boundary_rects.size()>0,"[W3-COMBINED-ROOF-PRESENT] roof/boundary solids exist in R14 (%d)"%w.boundary_rects.size())
	var bad=[]
	for room in 21:
		q.reset(room)
		for e in c.endpoints(w,room):
			var feet=e.at+Vector2(-int(e.heading)*64,-2)
			if body_hits(feet,w.boundary_rects) or body_hits(e.at+Vector2(0,-2),w.boundary_rects): bad.append("R%d %s"%[room,e.at])
			if e.arrival!=Vector2.INF and body_hits(e.arrival,w.boundary_rects): bad.append("R%d arrival %s"%[room,e.arrival])
	q.check(bad.is_empty(),"[W3-COMBINED-ENDPOINTS] all 58 endpoints, inward feet and explicit arrivals have their body clear of boundary solids; offenders: %s"%[bad])
	await seq("STAIR-ASCEND",14,17,-30.0,KEY_E,false)
	await seq("STAIR-DESCEND",17,14,0.0,KEY_E,false)
	await seq("CANAL-OUT",13,0,180.0,KEY_A,true)
	await seq("CANAL-IN",0,13,0.0,KEY_E,false)
