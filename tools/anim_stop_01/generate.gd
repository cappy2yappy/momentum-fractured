extends SceneTree
## Adds native property-only clips. Never writes Studio seed resources.
const OUT = "res://tools/anim_stop_01/"
const SEED = preload("res://presets/cutins/studio/sprint_stop.tres")
const GROUND = 517.35
const SOLE = Vector2(-15,43) # actual opaque heel pixel (13,51), minus Art offset (28,8)
const FOREFOOT = Vector2(12,42) # actual opaque forefoot pixel (40,50); one source pixel higher
func _init(): call_deferred("run")
func lerp_keys(t, times, values):
	for i in range(times.size()-1):
		if t <= times[i+1]: return lerp(values[i],values[i+1],clampf((t-times[i])/(times[i+1]-times[i]),0,1))
	return values[-1]
func put(a, path, t, v):
	var idx = a.find_track(NodePath(path),Animation.TYPE_VALUE)
	if idx < 0:
		idx=a.add_track(Animation.TYPE_VALUE); a.track_set_path(idx,NodePath(path))
	a.track_insert_key(idx,t,v)
func solve(a, side, t, root_at, hip_at, sole_at, size):
	var local_hip = hip_at + Vector2(-7 if side == "Far" else 7,0)*size
	var target = (sole_at - SOLE*size-local_hip)/size
	var dist = minf(target.length(),129.8)
	var bend = acos(clampf(dist/130.,0,1))
	var angle = atan2(target.y,target.x)-PI/2.
	var upper = angle-bend
	var knee = bend*2.
	put(a,"Rig/Leg"+side+":rotation",t,upper)
	put(a,"Rig/Leg"+side+"/Shin:rotation",t,knee)
	put(a,"Rig/Leg"+side+"/Shin/Boot:rotation",t,-upper-knee)
func build(size):
	var a=SEED.duplicate(true)
	a.resource_name="ANIM-STOP-01 %s — blocking only" % ("portable" if size==1. else "calibrated")
	# Preserve seed root motion, sprite exposures and alpha handoff.
	for path in ["Rig:position","Rig/Torso:rotation","Rig/Torso/Head:rotation","Rig/Torso/Hair:rotation","Rig/Torso/Ribbon:rotation","Rig/LegNear:rotation","Rig/LegNear/Shin:rotation","Rig/LegFar:rotation","Rig/LegFar/Shin:rotation","Rig/LegNear/Shin/Boot:rotation","Rig/LegFar/Shin/Boot:rotation"]:
		var idx=a.find_track(NodePath(path),Animation.TYPE_VALUE)
		if idx>=0: a.remove_track(idx)
	for n in range(253):
		var t=minf(n/60.,4.2)
		var root_at=a.value_track_interpolate(a.find_track(NodePath(".:position"),Animation.TYPE_VALUE),t)
		var hip_y=GROUND-size*lerp_keys(t,[0.,1.42,1.58,1.8,2.05,2.55,3.,4.2],[166.,166.,157.,143.,132.,154.,160.,160.])
		var hip=Vector2(root_at.x,hip_y)
		put(a,"Rig:position",t,hip-root_at)
		var nx=lerp_keys(t,[0.,1.42,1.58,1.8,4.2],[float(root_at.x)+24.,float(root_at.x)+24.,float(root_at.x)+26.,788.,788.])
		var ny=lerp_keys(t,[0.,1.42,1.58,1.8,4.2],[GROUND-12.,GROUND-12.,GROUND-8.,GROUND,GROUND])
		var fx=lerp_keys(t,[0.,1.42,1.58,1.8,2.15,2.5,2.85,4.2],[float(root_at.x)-36.,float(root_at.x)-36.,float(root_at.x)-30.,715.,727.,752.,762.,762.])
		var fy=lerp_keys(t,[0.,1.42,1.58,1.8,2.15,2.5,2.85,4.2],[GROUND-5.,GROUND-5.,GROUND-2.,GROUND,GROUND-18.,GROUND-9.,GROUND,GROUND])
		solve(a,"Near",t,root_at,hip,Vector2(nx,ny),size)
		solve(a,"Far",t,root_at,hip,Vector2(fx,fy),size)
		var lean=lerp_keys(t,[0.,1.42,1.8,2.05,2.55,3.1,4.2],[-.22,-.22,.12,.19,-.025,0.,0.])
		put(a,"Rig/Torso:rotation",t,lean)
		put(a,"Rig/Torso/Head:rotation",t,-lean)
		put(a,"Rig/Torso/Hair:rotation",t,lerp_keys(t,[0.,1.42,1.85,2.2,2.7,3.3,4.2],[.20,.20,-.12,.08,-.03,0.,0.]))
		put(a,"Rig/Torso/Ribbon:rotation",t,lerp_keys(t,[0.,1.42,1.9,2.3,2.8,3.4,4.2],[.30,.30,-.2,.14,-.06,0.,0.]))
	return a
func run():
	for size in [1.,.68]:
		var name_="portable" if size==1. else "calibrated"
		var a=build(size)
		assert(ResourceSaver.save(a,OUT+name_+"_stop.tres")==OK)
	print("Generated two property-only 4.2s clips; calibrated clip REQUIRES isolated Rig.scale=0.68.")
	quit()
