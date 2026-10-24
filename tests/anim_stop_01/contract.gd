extends SceneTree
const ACTOR=preload("res://presets/cutins/studio/actor.tscn")
const G=preload("res://tools/anim_stop_01/generate.gd")
var checks=0
var failures=0
var report={"source":"6ab1454ea44e946265d2a65d1495d81e7aae840f","variants":[],"limitations":["Numeric supports do not certify anatomy or visual acceptance.","Calibrated clip requires isolated Rig.scale=0.68; Studio does not persist that calibration.","No physical controller, macOS, campaign, old-save or production integration test."]}
func check(ok, what):
	checks+=1
	if not ok:failures+=1;printerr("FAIL: "+what)
func _init():call_deferred("run")
func run():
	var studio=load("res://tools/cin_tools_03/studio.gd").new()
	var boot=Image.load_from_file("res://assets/cin_tools_03/rig_parts/boot.png")
	check(boot.get_pixel(13,51).a>.5,"heel marker is opaque source art")
	check(boot.get_pixel(40,50).a>.5,"forefoot marker is opaque source art")
	for size in [1.,.68]:
		var name_="portable" if size==1. else "calibrated"
		var path="res://tools/anim_stop_01/"+name_+"_stop.tres"
		var clip=load(path)
		check(studio.valid_clip(clip),name_+" passes unchanged Studio validator")
		var a=ACTOR.instantiate();root.add_child(a);a.bind_clip(clip);a.get_node("Rig").scale=Vector2.ONE*size
		var max_drift=0.;var max_ground=0.;var max_angle=0.;var max_far_ground=0.
		for n in range(432,1009): # 1.8–4.2s at 240 Hz, including interpolation between baked keys
			var t=n/240.;a.sample(t)
			var b=a.get_node("Rig/LegNear/Shin/Boot")
			var sole=b.to_global(G.SOLE)
			max_drift=maxf(max_drift,absf(sole.x-788.))
			max_ground=maxf(max_ground,absf(sole.y-G.GROUND))
			max_angle=maxf(max_angle,absf(b.global_rotation))
			if t>=2.85:max_far_ground=maxf(max_far_ground,absf(a.get_node("Rig/LegFar/Shin/Boot").to_global(G.SOLE).y-G.GROUND))
		check(max_drift<.08,name_+" planted heel x drift below 0.08 source px")
		check(max_ground<.08,name_+" planted heel ground error below 0.08 source px")
		check(max_angle<.0001,name_+" planted boot stays level")
		check(max_far_ground<.08,name_+" recovery heel lands at 2.85s")
		var original=load("res://presets/cutins/studio/sprint_stop.tres")
		for p in [".:position","Sprite:frame",".:rig_blend"]:
			var oldidx=original.find_track(NodePath(p),Animation.TYPE_VALUE);var idx=clip.find_track(NodePath(p),Animation.TYPE_VALUE)
			var same=original.track_get_key_count(oldidx)==clip.track_get_key_count(idx)
			for k in original.track_get_key_count(oldidx):same=same and original.track_get_key_time(oldidx,k)==clip.track_get_key_time(idx,k) and original.track_get_key_value(oldidx,k)==clip.track_get_key_value(idx,k)
			check(same,name_+" unchanged seed "+p)
		var savepath="user://anim_stop_01_contract_"+name_+".tres"
		check(ResourceSaver.save(clip,savepath)==OK,name_+" private-profile save")
		var reloaded=ResourceLoader.load(savepath,"Animation",ResourceLoader.CACHE_MODE_IGNORE)
		check(studio.valid_clip(reloaded),name_+" disk reload validator")
		# Same director instance consumes portable keys; calibration is explicit in-memory dependency.
		var director=load("res://presets/cutins/studio/director.tscn").instantiate();root.add_child(director)
		var actor=director.get_node("Framing/Shake/Actor");actor.bind_clip(reloaded);actor.get_node("Rig").scale=Vector2.ONE*size
		var player=director.get_node("AnimationPlayer");player.play("standard")
		for t in [2.05,6.25]:
			player.seek(t,true)
			check(actor.clip==reloaded and absf(director.clip_time-2.05)<.002,name_+" exact clip reused by Director at "+str(t))
		player.play("reduced");player.seek(1.,true)
		check(is_equal_approx(director.clip_time,4.2),name_+" reduced Director holds final pose")
		report.variants.append({"name":name_,"rig_scale":size,"planted_heel_x_error":max_drift,"planted_heel_y_error":max_ground,"boot_rotation_error":max_angle,"recovery_heel_y_error":max_far_ground})
		director.free();a.free()
	studio.free()
	report.checks=checks;report.failures=failures
	FileAccess.open("res://docs/anim_stop_01/contract_result.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
	print("ANIM-STOP-01: ",checks," checks / ",failures," failures")
	quit(1 if failures else 0)
