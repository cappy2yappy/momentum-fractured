extends SceneTree
const Contract = preload("res://tools/ld_tools_02/layout_contract.gd")
const Factory = preload("res://tools/ld_tools_02/layout_factory.gd")
const Plugin = preload("res://addons/room_creator/plugin.gd")
var failures = 0
var passes = 0
var w
func _init(): call_deferred("run")
func check(ok, label):
	print("PASS: " if ok else "FAIL: ",label)
	if ok: passes += 1
	else: failures += 1
func freeze():
	w.set_physics_process(false);w.player.set_physics_process(false)
	for enemy in w.enemies: enemy.set_physics_process(false)
func signature():
	var records = []
	for shape in w.geometry.find_children("*","CollisionShape2D",true,false):
		var body = shape.get_parent()
		var transform = w.geometry.global_transform.affine_inverse() * shape.global_transform
		records.append([Rect2(transform.origin-shape.shape.size/2,shape.shape.size),shape.disabled,shape.one_way_collision,shape.one_way_collision_margin,body.collision_layer,body.collision_mask])
	return records
func snapshot():
	return [w.platforms.duplicate(),signature(),w.expansion.route_steps.duplicate(),w.expansion.hazards.duplicate(),w.enemies.size(),w.kunai_gates.map(func(g): return [g.id,g.element,g.position,g.height]),w.geometry.get_children().filter(func(node): return node.get_script() == w.Expansion.Anchor).map(func(node): return [node.position,node.enabled,node.attachment_offset,node.required_ability])]
func seed_fixture():
	w.completed = true;w.guard_defeated = true;w.boss_defeated = true
	w.player.double_jump = true;w.player.dash_unlocked = true;w.player.tether_unlocked = true
	w.relay_fragments = {"undercroft_sigil":true,"terrace_west":true,"terrace_fire_cache":true}
	w.expansion_flags = {"junction_return":true,"lore_13":true}
	w.opened_kunai_gates = {"skyworks_wind_intake":true,"pump_electric_isolator":true}
	for element in ["wind","fire","electric"]: w.player.kunai_unlocked[element] = true
func reset(index):
	w.cinematic_transitions.cancel(w);w.embodied_transitions.cancel(w);w.mixed_transitions.cancel(w)
	w.transition = 0;w.pending_room = -1;w.pending_arrival = Vector2.INF
	w.build_room(index);freeze();w.cinematic_transitions.cooldown = 0
func run():
	check("--test" in OS.get_cmdline_user_args(),"Save-safe invocation required")
	if "--test" not in OS.get_cmdline_user_args(): quit(2);return
	for size in Factory.TEMPLATES.values():
		var layout = Factory.create(21,size)
		var result = Contract.read(layout)
		check(result.errors.is_empty() and result.room_id == 21 and result.room_size == size,"Reusable template contract %s" % size)
		layout.get_node("Geometry/Floor/Surface").rotation = 0.1
		check(not Contract.read(layout).errors.is_empty(),"Reject rotated collider")
		layout.get_node("Geometry/Floor/Surface").rotation = 0
		layout.get_node("Geometry/Floor").collision_layer = 2
		check(not Contract.read(layout).errors.is_empty(),"Reject layer drift")
		layout.get_node("Geometry/Floor").collision_layer = 1
		var actor = Area2D.new();layout.get_node("Foreground").add_child(actor)
		check(not Contract.read(layout).errors.is_empty(),"Reject decoration physics")
		actor.free()
		for kind in ["Entrance","Exit","Pickup","Checkpoint","Hazard"]:
			var marker = Factory.marker(kind);layout.get_node("Markers").add_child(marker);Factory.own(marker,layout)
		var packed = PackedScene.new();packed.pack(layout)
		var temp = "res://build/room-creator-roundtrip.tscn"
		ResourceSaver.save(packed,temp)
		var restored = ResourceLoader.load(temp,"PackedScene",ResourceLoader.CACHE_MODE_IGNORE).instantiate()
		check(Contract.read(restored).errors.is_empty() and restored.get_node("Markers").get_child_count() == 5,"Template/marker save reload")
		check(restored.get_node("Geometry/Floor/Surface").shape != layout.get_node("Geometry/Floor/Surface").shape,"Independent layout shape resources")
		restored.free();layout.free()
	var editable = load("res://tools/ld_tools_02/r18_editable.tscn").instantiate()
	check(Contract.read(editable).errors.is_empty(),"Editable R18 version 2 contract")
	editable.free()
	w = load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene = w;freeze()
	check(not w.authored_r18_enabled and not w.authored_room_active,"Feature defaults off")
	check(w.ROOM_COUNT == 21 and w.world_edges().size() == 29,"21 rooms / 29 links retained")
	var baseline = []
	for index in 21:
		reset(index);baseline.append(snapshot());await process_frame
	for enabled in [false,true]:
		w.authored_r18_enabled = enabled
		w.guard_defeated = false;w.boss_defeated = false;w.completed = false
		w.opened_kunai_gates.clear()
		for index in 21:
			reset(index)
			check(snapshot() == baseline[index],"R%d geometry/support/route/encounter parity enabled=%s" % [index,enabled])
			check(w.authored_room_active == (enabled and index == 18),"R%d only pilot registration enabled=%s" % [index,enabled])
			await process_frame
		seed_fixture();w.opened_kunai_gates.erase("pump_electric_isolator");reset(18);await physics_frame;await physics_frame
		check(w.platforms.size() == 18 and signature().size() == 19,"18 geometry surfaces plus one independently owned electric gate")
		if enabled:
			var layout = w.geometry.get_child(0)
			check(layout.get_child(1).get_script() == w.RoomCreatorPilot.ProductionSurfaces,"Single production terrain renderer between background and geometry")
			check(layout is Node2D and layout.has_meta("format_version"),"Native authored scene owns collision")
			check(layout.get_node("Geometry/Platform_01/Surface").visible == false,"Pilot ink hidden; single production renderer draws surfaces once")
			check(not layout.get_node("Markers").visible,"Markers have no runtime presentation")
		# Exercise real player physics with the unchanged controller.
		w.player.position = Vector2(950,798);w.player.velocity = Vector2.ZERO
		w.player.set_physics_process(true)
		for tick in 25: await physics_frame
		check(w.player.is_on_floor() and abs(w.player.position.y-800) < 1,"Actual Kaze lands on R18 one-way surface enabled=%s" % enabled)
		freeze()
		# Both normal automatic R18 exits and reciprocals, native input and loader.
		for pair in [[18,16],[16,18],[18,8],[8,18],[18,19],[19,18]]:
			seed_fixture();reset(pair[0]);await physics_frame;await physics_frame
			var endpoint = w.cinematic_transitions.endpoint(w,pair[0],pair[1])
			check(not endpoint.is_empty(),"R18 normal exit metadata %s" % [pair])
			w.player.position = endpoint.at + Vector2(-65*endpoint.heading,-2)
			w.player.velocity = Vector2.ZERO;w.player.set_physics_process(true);w.set_physics_process(true)
			if endpoint.mode == "horizontal_walk": Input.action_press("right" if endpoint.heading > 0 else "left")
			else: Input.action_press("interact")
			for tick in 90:
				await physics_frame
				if w.room == pair[1] and w.transition <= 0: break
			Input.action_release("right");Input.action_release("left");Input.action_release("interact");freeze()
			check(w.room == pair[1],"Real input normal transition %s enabled=%s" % [pair,enabled])
			await physics_frame;await physics_frame
			var arrival = w.player.position
			w.player.velocity = Vector2.ZERO;w.player.set_physics_process(true)
			for tick in 30: await physics_frame
			freeze()
			check(w.player.is_on_floor() and w.player.position.distance_to(arrival) < 8,"R18 route arrival supported and stable %s" % [pair])
		reset(18);w.checkpoint_room = 18;w.checkpoint_position = Vector2(260,998)
		w.player.unlock_speed_upgrade("stride_1");w.opened_kunai_gates["pump_electric_isolator"] = true
		w.save_path = "res://build/room-creator-save-%s.json" % enabled
		w.test_mode = false;w.save_progress();w.test_mode = true
		var saved = JSON.parse_string(FileAccess.get_file_as_string(w.save_path))
		check(not saved.has("authored_r18_enabled"),"Opt-in never enters save schema")
		w.expansion_flags.clear();w.opened_kunai_gates.clear();w.player.double_jump = false
		w.load_progress();w.respawn();freeze();await process_frame
		check(w.room == 18 and w.player.position == Vector2(260,998) and w.player.double_jump and w.player.speed_upgrade_level == 1,"Save reload respawn retains checkpoint/earned abilities")
		check(w.expansion_flags.get("lore_13",false) and w.opened_kunai_gates.get("pump_electric_isolator",false),"Saved lore and gate state retained")
		check(w.kunai_gates[0].body == null,"Opened gate stays open after authored rebuild")
		w.opened_kunai_gates.clear()
	# Edit/save/reload and restore from the immutable source, with legacy support updated.
	var edited = load("res://tools/ld_tools_01/r18_layout.tscn").instantiate()
	var surface = edited.get_node("Geometry/Platform_01/Surface")
	surface.position += Vector2(32,-16);surface.shape.size = Vector2(352,40);surface.one_way_collision = false
	edited.get_node("Geometry/Platform_02/Surface").disabled = true
	var packed = PackedScene.new();packed.pack(edited);ResourceSaver.save(packed,"res://build/room-creator-edited.tscn");edited.free()
	w.authored_r18_enabled = true;w.authored_r18_path = "res://build/room-creator-edited.tscn";reset(18)
	check(w.authored_room_active and w.platforms.size() == 17,"Disabled geometry omitted from support queries")
	check(w.platforms.has(Rect2(1056,1164,352,40)),"Edited platform precise coordinates reach gameplay support queries")
	check(not w.geometry.get_child(0).get_node("Geometry/Platform_01/Surface").one_way_collision,"Solid choice is not rewritten by legacy generator")
	w.opened_kunai_gates.clear();w.authored_r18_path = w.RoomCreatorPilot.DEFAULT_LAYOUT;reset(18)
	check(snapshot() == baseline[18],"Restore original layout without changing progression")
	w.authored_r18_enabled = false;w.opened_kunai_gates.clear();reset(18)
	check(snapshot() == baseline[18],"Rollback returns to exact legacy R18")
	w.queue_free();current_scene = null
	for tick in 3: await process_frame
	print("ROOM CREATOR: %d passes / %d failures" % [passes,failures]);quit(1 if failures else 0)
