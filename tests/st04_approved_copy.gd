extends SceneTree
# ST-04 creator-approved copy: opening announcement, first objective, R11 "Foundry Rest Station".
const OPENING := "The refuge was attacked. I have to find the others."
const FIRST_OBJECTIVE := "Search for survivors. Defeat the Market sentinel for Windstep."
const R11_LABEL := "Foundry Rest Station"
var failures = 0
var boot_mode = false
func _init(): call_deferred("_run")
func check(ok, message):
	print("PASS: " if ok else "FAIL: ", message)
	if not ok: failures += 1
func make_world():
	var world = load("res://scenes/main.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	world.set_physics_process(false)
	world.player.set_physics_process(false)
	return world
func drop(world):
	root.remove_child(world)
	world.free()
func earn_all(world):
	world.player.double_jump = true
	world.player.tether_unlocked = true
	world.player.dash_unlocked = true
	world.boss_defeated = true
	world.completed = true
	for id in ["undercroft_sigil", "terrace_west", "terrace_fire_cache"]: world.relay_fragments[id] = true
func scan(path: String, hits: Array):
	var dir = DirAccess.open(path)
	if dir == null: return
	for entry in dir.get_files():
		if entry.get_extension() in ["gd", "tscn", "tres", "json", "cfg"]:
			var text = FileAccess.get_file_as_string(path.path_join(entry)).to_lower()
			if "foundry refuge" in text: hits.append(path.path_join(entry))
func _run():
	await process_frame
	boot_mode = not ("--test" in OS.get_cmdline_user_args())
	# 1. Fresh unseeded opening
	var world = make_world()
	check(world.message == OPENING, "Fresh opening announcement is the approved text")
	check(world.message_time > 0.0, "Opening announcement is visible at start")
	check(world.current_objective() == FIRST_OBJECTIVE, "Fresh first objective is the approved text")
	check(world.room == world.checkpoint_room and world.checkpoint_room == 0, "Fresh start is still room 0 with no progress")
	check(not world.player.double_jump and not world.completed, "Fresh start has no earned progression")
	check("canal" not in world.message.to_lower() and "rooftop" not in world.message.to_lower(), "Old opening text is gone")
	# 2. First objective until Windstep, then existing objectives unchanged
	world.player.tether_unlocked = true
	check(world.current_objective() == FIRST_OBJECTIVE, "First objective holds until Windstep regardless of later flags")
	world.player.tether_unlocked = false
	world.player.double_jump = true
	check(world.current_objective() == "Reach Echo Shrine and recover Wind Tether.", "After Windstep the Wind Tether objective is unchanged")
	world.player.tether_unlocked = true
	check(world.current_objective() == "Cross Broken Span and recover Gale Dash.", "Gale Dash objective unchanged")
	world.player.dash_unlocked = true
	check(world.current_objective() == "Break the Tide Warden's seal.", "Tide Warden objective unchanged")
	world.boss_defeated = true
	check(world.current_objective() == "Restore the Relay Archive.", "Relay Archive objective unchanged")
	world.completed = true
	check(world.current_objective() == "Survey the annexes: 0 / 3 relay sigils recovered.", "Annex survey objective unchanged")
	for id in ["undercroft_sigil", "terrace_west", "terrace_fire_cache"]: world.relay_fragments[id] = true
	world.room = 10
	check(world.current_objective() == "Use Wind Kunai to release the intake seal.", "R10 intake objective unchanged")
	world.room = 12
	check(world.current_objective() == "Storm Keeper: parry the sweep; jump the ground pulse.", "R12 Keeper objective unchanged")
	world.room = 0
	check(world.current_objective() == "Follow Signal Terrace east. Reach SkyWorks and face the Storm Keeper.", "Pre-Keeper route objective unchanged")
	# 3. R11 objective, checkpoint activation and revisit
	world.build_room(11)
	world.player.set_physics_process(false)
	check(world.current_objective() == "Save at Foundry Rest Station. Open the Electric relay.", "R11 objective uses Foundry Rest Station")
	check(world.ROOM_NAMES[11] == "STORM FOUNDRY", "Room 11 is still named STORM FOUNDRY (Storm Foundry)")
	world.save_path = "user://st04_copy_roundtrip.json"
	world.player.position = Vector2(1720, 1300)
	world.player.hp = 1
	world.interact()
	check(world.message == "Foundry Rest Station restored. The Keeper waits east.", "R11 activation announcement uses Foundry Rest Station")
	check(world.checkpoint_room == 11 and world.checkpoint_position == Vector2(1720, 1298) and world.player.hp == 3, "Checkpoint behaviour unchanged: room, exact position and full health")
	world.message = ""
	world.player.hp = 2
	world.interact()
	check(world.message == "Foundry Rest Station restored. The Keeper waits east." and world.player.hp == 3, "R11 revisit repeats the approved announcement and restores health")
	world.player.position = Vector2(1000, 1300)
	world.message = ""
	world.interact()
	check(world.message == "", "Interact away from the R11 shrine announces nothing")
	# 4. Drawn label fits
	var font = ThemeDB.fallback_font
	var label_size = font.get_string_size("FOUNDRY REST STATION • E", HORIZONTAL_ALIGNMENT_LEFT, -1, 18)
	var old_size = font.get_string_size("FOUNDRY REFUGE • E", HORIZONTAL_ALIGNMENT_LEFT, -1, 18)
	print("INFO: label width new %.1f old %.1f px at 18pt, starts x=1575 room width %d" % [label_size.x, old_size.x, int(world.room_size(11).x)])
	check(1575 + label_size.x < world.room_size(11).x - 40, "Drawn R11 label stays inside the room with margin")
	check(1575 + label_size.x < 2000, "Drawn R11 label does not run into the right half of the room beyond x=2000")
	var src = FileAccess.get_file_as_string("res://scripts/skyworks_region.gd")
	check("FOUNDRY REST STATION • E" in src and "FOUNDRY REFUGE" not in src, "Drawn label source uses uppercase Rest Station with E prompt")
	# 5. Save then reload keeps progression and shows new strings
	var save_file = "user://st04_copy_roundtrip.json"
	earn_all(world)
	world.opened_kunai_gates["skyworks_wind_intake"] = true
	world.save_path = save_file
	world.test_mode = false
	check(world.save_progress(), "Save writes after the R11 checkpoint")
	world.test_mode = true
	drop(world)
	world = make_world()
	world.save_path = save_file
	world.load_progress()
	check(world.checkpoint_room == 11 and world.checkpoint_position == Vector2(1720, 1298), "Reload restores R11 checkpoint exactly")
	check(world.player.double_jump and world.completed and world.relay_fragments.size() == 3, "Reload keeps progression")
	world.build_room(11)
	check(world.current_objective() == "Save at Foundry Rest Station. Open the Electric relay." or world.opened_kunai_gates.get("foundry_electric_relay", false), "Reloaded R11 objective shows new text")
	var saved = JSON.parse_string(FileAccess.get_file_as_string(save_file))
	check(saved.version == 8 and not ("Refuge" in JSON.stringify(saved)) and not ("Rest Station" in JSON.stringify(saved)), "Save schema version 8 holds no display strings, so it is unchanged")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(save_file))
	drop(world)
	# 6. Pre-change (PR51 build) save, synthesized from the real version 8 schema
	var legacy = {"version": 8, "expansion_flags": {}, "speed_upgrade_level": 0, "skyworks_restored": false, "checkpoint_position": [1720, 1298],
		"relay_fragments": {"undercroft_sigil": true, "terrace_west": true, "terrace_fire_cache": true}, "cleared_encounters": {"intake_sentinel": true},
		"double_jump": true, "tether_unlocked": true, "dash_unlocked": true, "kunai_unlocked": {"wind": true, "fire": true, "electric": false}, "selected_kunai": "wind",
		"opened_kunai_gates": {"skyworks_wind_intake": true}, "guard_defeated": true, "boss_defeated": true, "completed": true, "secret": false,
		"visited": [true,true,true,true,true,true,true,true,true,true,true,true,false,false,false,false,false,false,false,false,false], "checkpoint_room": 11, "metsys": {}}
	var legacy_file = "user://st04_copy_legacy.json"
	var f = FileAccess.open(legacy_file, FileAccess.WRITE)
	f.store_string(JSON.stringify(legacy))
	f.close()
	world = make_world()
	world.save_path = legacy_file
	world.load_progress()
	check(world.checkpoint_room == 11 and world.checkpoint_position == Vector2(1720, 1298), "Pre-change save keeps R11 checkpoint")
	check(world.player.double_jump and world.player.tether_unlocked and world.player.dash_unlocked and world.boss_defeated and world.completed and not world.skyworks_restored, "Pre-change save keeps progression unchanged")
	check(world.opened_kunai_gates.get("skyworks_wind_intake", false) and not world.opened_kunai_gates.get("foundry_electric_relay", false), "Pre-change save keeps gate state")
	world.build_room(11)
	check(world.current_objective() == "Save at Foundry Rest Station. Open the Electric relay.", "Pre-change save shows the new R11 objective")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(legacy_file))
	drop(world)
	# 7. True boot path with a pre-change save at the default location (only when run without --test)
	if boot_mode:
		var default_path = "user://silent_district_alpha_v3.json"
		var had_existing = FileAccess.file_exists(default_path)
		if not had_existing:
			world = make_world()
			check(world.message == OPENING and world.current_objective() == FIRST_OBJECTIVE, "Boot path, no save file: approved opening and first objective")
			drop(world)
			var g = FileAccess.open(default_path, FileAccess.WRITE)
			g.store_string(JSON.stringify(legacy))
			g.close()
			world = make_world()
			check(world.room == 11 and world.checkpoint_room == 11 and world.player.double_jump, "Boot path with pre-change save lands in R11 with progression")
			check(world.current_objective() == "Save at Foundry Rest Station. Open the Electric relay.", "Boot path with pre-change save shows new R11 objective")
			DirAccess.remove_absolute(ProjectSettings.globalize_path(default_path))
			drop(world)
		else:
			print("INFO: default save exists, boot-path section skipped")
	# 8. Text search consistency across runtime sources
	var hits = []
	for dir in ["res://scripts", "res://scenes", "res://tests"]: scan(dir, hits)
	hits = hits.filter(func(p): return not p.ends_with("st04_approved_copy.gd"))
	check(hits.is_empty(), "No remaining 'Foundry Refuge' display strings in scripts, scenes or tests %s" % str(hits))
	check('"STORM FOUNDRY"' in FileAccess.get_file_as_string("res://scripts/world.gd"), "Storm Foundry room name still present in ROOM_NAMES")
	print("ST04 copy failures: ", failures)
	quit(1 if failures > 0 else 0)
