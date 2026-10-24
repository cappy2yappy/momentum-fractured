extends SceneTree
const ACTOR=preload("res://presets/cutins/studio/actor.tscn")
const G=preload("res://tools/anim_stop_01/generate.gd")
var out="res://docs/anim_stop_01/private-evidence"
func _init():call_deferred("run")
func visible_box(img):
	var xmin=img.get_width();var xmax=-1;var ymin=img.get_height();var ymax=-1
	for y in img.get_height():
		for x in img.get_width():
			if img.get_pixel(x,y).a>.5:xmin=mini(xmin,x);xmax=maxi(xmax,x);ymin=mini(ymin,y);ymax=maxi(ymax,y)
	return [xmin,ymin,xmax+1,ymax+1]
func p(v):return [v.x,v.y]
func run():
	DirAccess.make_dir_recursive_absolute(out)
	var vp=SubViewport.new();vp.size=Vector2i(512,512);vp.transparent_bg=true;vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(vp)
	var report={"alpha_threshold":.5,"root_in_measurement_viewport":[256,420],"variants":[]}
	for kind in ["seed_sprite","seed_rig","portable","calibrated"]:
		var a=ACTOR.instantiate();vp.add_child(a)
		if kind in ["portable","calibrated"]:a.bind_clip(load("res://tools/anim_stop_01/"+kind+"_stop.tres"))
		if kind=="calibrated":a.get_node("Rig").scale=Vector2.ONE*.68
		var rows=[]
		for t in [1.417,1.5,1.583,1.8,2.05,2.55,4.2]:
			a.sample(t);a.position=Vector2(256,420)
			a.set_view(1 if kind=="seed_sprite" else 0)
			await process_frame;RenderingServer.force_draw(false)
			var img=vp.get_texture().get_image()
			var filename="%s_%04d.png" %[kind,roundi(t*1000)]
			img.save_png(out+"/"+filename)
			var boot=a.get_node("Rig/LegNear/Shin/Boot")
			rows.append({"time":t,"alpha_bbox":visible_box(img),"near_heel_root_relative":p(boot.to_global(G.SOLE)-a.position),"near_forefoot_root_relative":p(boot.to_global(G.FOREFOOT)-a.position),"knee_root_relative":p(a.get_node("Rig/LegNear/Shin").global_position-a.position),"hip_root_relative":p(a.get_node("Rig/LegNear").global_position-a.position),"image":filename})
		report.variants.append({"name":kind,"measurements":rows});a.free()
	# Aligned true source pixels: cyan sprite + magenta rig, both at 50 percent alpha.
	for kind in ["seed","calibrated"]:
		var sprite=ACTOR.instantiate();vp.add_child(sprite);sprite.sample(1.417);sprite.position=Vector2(256,420);sprite.set_view(1);sprite.modulate=Color(.4,1,1,.5)
		var rig=ACTOR.instantiate();vp.add_child(rig)
		if kind=="calibrated":rig.bind_clip(load("res://tools/anim_stop_01/calibrated_stop.tres"));rig.get_node("Rig").scale=Vector2.ONE*.68
		rig.sample(1.583);rig.position=Vector2(256,420);rig.set_view(0);rig.modulate=Color(1,.4,1,.5)
		await process_frame;RenderingServer.force_draw(false)
		vp.get_texture().get_image().save_png(out+"/overlay_"+kind+".png")
		sprite.free();rig.free()
	vp.free()
	FileAccess.open("res://docs/anim_stop_01/transform_audit.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
	print("Native alpha/transform audit: 28 transparent phase captures and two aligned overlays")
	quit()
