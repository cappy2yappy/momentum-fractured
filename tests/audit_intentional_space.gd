extends SceneTree
var failures=0
func _init(): call_deferred("run")
func same_signature(a,b):
	if a.size()!=b.size(): return false
	for i in a.size():
		for j in 4:
			# Recorded JSON rounds generated Vector2 float32 thirds. Compare
			# geometry to a thousandth of a pixel, preserving order and count.
			if absf(float(a[i][j])-float(b[i][j]))>0.001: return false
	return true
func run():
	await process_frame
	var w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w;w.set_physics_process(false);w.player.set_physics_process(false)
	var before=JSON.parse_string(FileAccess.get_file_as_string("res://docs/tr04/evidence/geometry_after.json"))
	var rows=[]
	for index in 21:
		w.build_room(index)
		for e in w.enemies: e.set_physics_process(false)
		var rects=[]
		for r in w.platforms: rects.append([r.position.x,r.position.y,r.size.x,r.size.y])
		var unchanged=same_signature(rects,before[index].platforms)
		if index==13:
			# LEVEL pilot: every PR33 rectangle retained in order; the Canal-left gatehouse adds exactly its back pier and mass.
			var retained13=true
			for r in before[index].platforms:
				var found=false
				for q in rects: found=found or same_signature([q],[r])
				retained13=retained13 and found
			var ok13=retained13 and rects.size()==before[index].platforms.size()+2
			print("PASS: " if ok13 else "FAIL: ","Room 13 retains every PR33 rectangle and adds only the 2 Canal gatehouse rectangles")
			if not ok13: failures+=1
		elif index!=14:
			print("PASS: " if unchanged else "FAIL: ","Room %d PR33 collision signature (0.001px serialization tolerance)"%index)
			if not unchanged: failures+=1
		else:
			var retained=true
			for r in before[index].platforms: retained=retained and r in rects
			var ok=retained and rects.size()==before[index].platforms.size()+12
			print("PASS: " if ok else "FAIL: ","Bellroof retains every PR33 rectangle and adds only12 authored masses/steps")
			if not ok: failures+=1
		var lower=[]
		for r in w.platforms:
			if r.position.y>=1100 and r.size.x>40: lower.append([r.position.x,r.position.y,r.size.x,r.size.y])
		rows.append({"id":index,"name":w.ROOM_NAMES[index],"size":[w.room_size(index).x,w.room_size(index).y],"lower_surfaces":lower,"unchanged_from_pr33":unchanged,"platforms":rects})
	var out="res://build/ld03";DirAccess.make_dir_recursive_absolute(out)
	var f=FileAccess.open(out.path_join("space_audit.json"),FileAccess.WRITE);f.store_string(JSON.stringify(rows,"\t"));f.close()
	w.queue_free();current_scene=null
	for i in 3: await process_frame
	print("SPACE AUDIT: %d failure(s)"%failures);quit(1 if failures else 0)
