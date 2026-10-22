extends SceneTree
const Encounter = preload("res://scripts/encounters/encounter.gd")
var failures = 0
func _init(): call_deferred("run")
func check(ok, label):
	print("PASS: " if ok else "FAIL: ",label)
	if not ok: failures += 1
func run():
	await process_frame
	var w=load("res://scenes/main.tscn").instantiate(); root.add_child(w); current_scene=w
	w.set_physics_process(false); w.player.set_physics_process(false)
	# Unique disposable path; the campaign profile is never opened for writing.
	var temporary=OS.get_environment("TMPDIR")
	if temporary.is_empty(): temporary="/tmp"
	w.save_path=temporary.path_join("en01-%d.json" % OS.get_process_id())
	w.test_mode=false
	var c={"version":1,"id":"regression/disk","type":"guard","position":[700,1300],"territory":[500,900],"persistent":true,"activation":"immediate","completion_event":"regression/complete"}
	var runtime=Encounter.new(); w.add_child(runtime)
	check(runtime.configure(w,[c]).is_empty(),"Persistent prototype attaches to actual campaign host")
	var e=runtime.members[0]; e.state="patrol"; e.receive_hit(100)
	await process_frame
	var saved=JSON.parse_string(FileAccess.get_file_as_string(w.save_path))
	check(saved is Dictionary and saved.version==8 and saved.cleared_encounters.get("en01/regression/disk",false),"Actual version-8 serializer stores defeat in existing map")
	w.cleared_encounters.clear(); w.load_progress()
	check(w.cleared_encounters.get("en01/regression/disk",false),"Actual loader restores prototype defeat")
	runtime.dispose(); await process_frame
	runtime=Encounter.new(); w.add_child(runtime); runtime.configure(w,[c])
	check(runtime.members.is_empty(),"Disk-restored defeat suppresses respawn")
	runtime.dispose(); await process_frame
	c.id="regression/save-failure"
	runtime=Encounter.new(); w.add_child(runtime); runtime.configure(w,[c])
	var failures_observed=[]
	runtime.persistence_failed.connect(func(): failures_observed.append(true))
	var saved_path=w.save_path; w.save_path=temporary.path_join("en01-missing-%d/save.json" % OS.get_process_id())
	e=runtime.members[0]; e.state="patrol"; e.receive_hit(100)
	check(failures_observed.size()==1 and w.cleared_encounters.get("en01/regression/save-failure",false),"Write failure signals caller while retaining session defeat")
	DirAccess.remove_absolute(saved_path)
	w.free(); current_scene=null; await process_frame
	print("EN01 PERSISTENCE: %d failure(s)" % failures)
	quit(1 if failures else 0)
