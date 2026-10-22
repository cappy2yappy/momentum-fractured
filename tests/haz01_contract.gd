extends SceneTree
const Placement = preload("res://scripts/hazards/hazard_placement.gd")
const Probe = preload("res://scripts/hazards/production_placement.gd")
const Adapter = preload("res://scripts/hazards/story_hazard_adapter.gd")
const Hazard = preload("res://scripts/hazards/environmental_hazard.gd")
var failures = 0
func _init(): call_deferred("run")
func check(ok, label):
	print("PASS: " if ok else "FAIL: ", label)
	if not ok: failures += 1
func run():
	var p = Placement.new()
	for seconds in [0.3, 0.59]:
		p.warning_seconds=seconds
		check(not p.validation_errors().is_empty(),"Reject warning below 0.6 seconds")
	p.warning_seconds=0.6
	check(p.validation_errors().is_empty(),"Accept 0.6 second warning")
	p.at=Vector2(300,300)
	var floor_rect=Rect2(0,0,2000,1000)
	check(Probe.validate(p,[floor_rect],[],[],[],[],true).is_empty(),"Surveyed damage volume valid")
	for exclusions in [[ [Rect2(300,300,40,40)],[],[],[] ],[[],[Rect2(450,300,10,10)],[],[]],[[],[],[Rect2(300,300,40,40)],[]],[[],[],[],[Rect2(300,300,40,40)]]]:
		check(not Probe.validate(p,[floor_rect],exclusions[0],exclusions[1],exclusions[2],exclusions[3],true).is_empty(),"Reject surveyed exclusion overlap")
	check(not Probe.validate(p,[],[],[],[],[],true).is_empty(),"Reject new unsupported geometry")
	check(not Probe.validate(p,[floor_rect],[],[],[],[],false).is_empty(),"Reject unproven only route")
	p.kind="collapse"
	check(not Probe.validate(p,[floor_rect],[],[],[],[],true).is_empty(),"Reject collider-producing collapse from production")
	var course=load("res://scenes/haz01/course.tscn").instantiate()
	root.add_child(course); current_scene=course
	course.set_physics_process(false); course.player.set_physics_process(false)
	for hz in course.hazards: hz.set_physics_process(false)
	var h=course.hazards[1]
	var host=Node.new(); host.set_meta("unused",true)
	# Dictionary host proves adapter reads the existing map without owning storage.
	var world={"expansion_flags":{}}
	var adapter=Adapter.new(); adapter.bind(h,["trap/test_enabled"],["trap/test_disabled"])
	course.player.position=Vector2(90,620)
	await physics_frame; await physics_frame
	adapter.refresh(world); check(not h.enabled,"Missing enabling flag fails closed")
	world.expansion_flags["trap/test_enabled"]=true
	course.player.position=h.position+Vector2(40,50)
	await physics_frame; await physics_frame
	adapter.refresh(world); check(not h.enabled,"Enable waits while occupied")
	course.player.position=Vector2(90,620)
	await physics_frame; await physics_frame
	adapter.update(world); check(h.enabled,"Enable applies after player clears")
	course.player.position=h.position+Vector2(40,50)
	world.expansion_flags["trap/test_disabled"]=true
	await physics_frame; await physics_frame
	adapter.refresh(world); check(h.enabled,"Disable also waits while occupied")
	course.player.position=Vector2(90,620)
	await physics_frame; await physics_frame
	adapter.update(world); check(not h.enabled,"Disable applies after player clears")
	check(world.expansion_flags.size()==2,"Adapter does not mutate flag storage")
	host.free(); course.free(); current_scene=null
	print("HAZ01 CONTRACT: %d failures" % failures)
	quit(1 if failures else 0)
