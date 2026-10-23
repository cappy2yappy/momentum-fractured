extends SceneTree
const Contract = preload("res://tools/art10/contract.gd")
var checks := 0
var failures := 0
func check(value: bool, label: String):
	checks += 1
	if not value:
		failures += 1
		printerr("FAIL: ", label)

# Numeric test fixture only, no artwork. Never offered as an animation candidate.
func fixture() -> Dictionary:
	var frames: Array = []
	for i in 12:
		var phase = "approach" if i == 0 else ("sprint" if i == 1 else ("stairs" if i < 8 else ("brake" if i < 10 else "settle")))
		var contacts = [{"foot":"left" if i%2 == 0 else "right", "sole":[20 if i%2 == 0 else 30,60], "tread":0}]
		if i >= 10: contacts = [{"foot":"left","sole":[20,60],"tread":0},{"foot":"right","sole":[30,60],"tread":0}]
		frames.append({"phase":phase,"duration":0.1,"asset":"res://assets/art10/test.png","region":[i*64,0,64,64],"root":[0,0],"pivot":[0,0],"contacts":contacts})
	return {"frames":frames,"treads":[[0,100,60]]}

func _initialize():
	var valid = fixture()
	check(Contract.validate_clip(valid,false).is_empty(), "numeric fixture accepted")
	check(not Contract.validate_clip({"frames":[],"treads":[]},false).is_empty(), "empty clips rejected")
	var sparse = fixture()
	sparse.frames.resize(3)
	check(not Contract.validate_clip(sparse,false).is_empty(), "three-key study rejected")
	var repeated = fixture()
	for f in repeated.frames: f.region = [0,0,64,64]
	check("Repeated static keys are not a production cycle." in Contract.validate_clip(repeated,false), "static diagonal proxy rejected")
	var bad = fixture()
	bad.frames[4].contacts[0].sole[1] = 55
	check("Measured sole misses fixed tread." in Contract.validate_clip(bad,false), "floating sole rejected")
	bad = fixture()
	bad.frames[4].contacts[0].sole[1] = 66
	check("Measured sole misses fixed tread." in Contract.validate_clip(bad,false), "penetrating sole rejected")
	bad = fixture()
	bad.frames[4].contacts[0].sole[0] = 101
	check("Measured sole misses fixed tread." in Contract.validate_clip(bad,false), "contact beyond tread rejected")
	bad = fixture()
	bad.frames[11].contacts[0].sole[0] = 25
	check("Stance foot slides during consecutive contact." in Contract.validate_clip(bad,false), "sliding plant rejected")
	bad = fixture()
	for f in bad.frames:
		if f.phase == "stairs": f.contacts[0].foot = "left"
	check("At least four alternating stair contacts required." in Contract.validate_clip(bad,false), "nonalternating feet rejected")
	bad = fixture()
	bad.frames[11].root = [2,0]
	check("Settle must end without root drift." in Contract.validate_clip(bad,false), "settle drift rejected")
	bad = fixture()
	bad.frames[11].contacts[1].foot = "left"
	check("Final settle needs both feet grounded." in Contract.validate_clip(bad,false), "duplicate final foot rejected")
	for value in [0,-0.1,INF,NAN,"fast"]:
		bad = fixture()
		bad.frames[0].duration = value
		check("Duration must be finite and positive." in Contract.validate_clip(bad,false), "invalid duration rejected")
	bad = fixture()
	bad.frames[3].phase = "approach"
	check("Invalid phase order." in Contract.validate_clip(bad,false), "backward phase rejected")
	bad = fixture()
	bad.frames[0].asset = "res://assets/art10/../web/kaze.png"
	check("Only isolated ART10 art may be bound." in Contract.validate_clip(bad,false), "path escape rejected")
	bad = fixture()
	bad.frames[0].region[0] = 0.5
	check("Atlas region must contain integer pixels." in Contract.validate_clip(bad,false), "fractional region rejected")
	bad = fixture()
	bad.frames[0].contacts[0].tread = 3
	check("Invalid contact tread." in Contract.validate_clip(bad,false), "missing tread rejected")
	check(Contract.frame_at(valid.frames,-1) == 0,"negative time clamps")
	check(Contract.frame_at(valid.frames,0.099) == 0,"first frame duration")
	check(Contract.frame_at(valid.frames,0.1) == 1,"exact frame boundary")
	check(Contract.frame_at(valid.frames,999) == 11,"hold final pose")
	var manifest = JSON.parse_string(FileAccess.get_file_as_string("res://assets/art10/MANIFEST.json"))
	check(not manifest.production_enabled and not manifest.creator_approved,"production disabled")
	for candidate in ["grounded","expressive"]:
		for direction in ["ascent","descent"]:
			check(not Contract.validate_clip(manifest.candidates[candidate][direction]).is_empty(),"pending candidate fails closed")
	var viewer = load("res://tools/art10/viewer.tscn").instantiate()
	root.add_child.call_deferred(viewer)
	await process_frame
	await process_frame
	check(not viewer.errors.is_empty(),"viewer blocks incomplete candidate")
	viewer.candidate = "expressive"
	viewer.direction = "descent"
	viewer.select_clip()
	check(not viewer.errors.is_empty() and viewer.elapsed == 0,"switch resets without fallback art")
	print("ART10 contract/viewer checks=",checks," failures=",failures)
	quit(1 if failures else 0)
