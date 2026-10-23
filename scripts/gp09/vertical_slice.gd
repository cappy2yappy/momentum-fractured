extends "res://scripts/world.gd"
## Isolated composition root. No campaign rooms, schema changes or controller edits.
const Consumers = preload("res://scripts/encounters/story_consumers.gd")
const Hazard = preload("res://scripts/hazards/environmental_hazard.gd")
const Placement = preload("res://scripts/hazards/hazard_placement.gd")
const Presenter = preload("res://scripts/gp09/presenter.gd")
const DISC = "disc/gp09_bundle"
const PRESENTED = "evt/gp09_presented"
const DEFEATED = "en01/gp09_guard"
var consumers
var presenter
var steam
var status: Label
var veil: ColorRect
var initialized = false
var exiting = false
var exited = false
var exit_clock = 0.0
var presentation_requested = false
var encounter_dispatched = false
var crossing_started = false
var reload_requested = false
var save_attempts = 0

func _ready():
	save_path = "user://gp09_vertical_slice_v1.json"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--gp09-save="): save_path = arg.trim_prefix("--gp09-save=")
	if "--gp09-fresh" in OS.get_cmdline_user_args() and not get_tree().root.has_meta("gp09_fresh_applied"):
		DirAccess.remove_absolute(save_path)
		get_tree().root.set_meta("gp09_fresh_applied",true)
	checkpoint_position = Vector2(180,618)
	super._ready()
	test_mode = false
	checkpoint_room = 0
	checkpoint_position = Vector2(180,618)
	player.position = checkpoint_position
	player.velocity = Vector2.ZERO
	message = "Your save is isolated from the campaign."
	message_time = 5
	hud.visible = false
	hud.set_process_input(false)
	camera.limit_right = 3000; camera.limit_bottom = 760
	camera.position_smoothing_enabled = false
	presenter = Presenter.new()
	add_child(presenter); presenter.configure(self)
	presenter.reduced = "--reduced-motion" in OS.get_cmdline_user_args()
	story.cutin_presenter = presenter
	consumers = Consumers.new(self)
	var entries = [{"version":1,"id":"gp09_guard","type":"guard","position":[1300,620],
		"territory":[1060,1500],"hp":4,"windup":0.85,"speed":85,
		"activation":"immediate","persistent":true,"completion_event":"evt/gp09_guard_done"}]
	assert(consumers.register_encounter(story,"gp09_guard",entries))
	steam = Hazard.new(); steam.placement = Placement.new()
	steam.placement.placement_id = "gp09_steam"
	steam.placement.at = Vector2(1740,230)
	steam.placement.dimensions = Vector2(180,390)
	steam.placement.idle_seconds = 2.0
	steam.placement.warning_seconds = 1.2
	steam.placement.active_seconds = 1.0
	steam.placement.recovery_seconds = 1.8
	steam.placement.initially_enabled = true
	steam.player = player; add_child(steam)
	assert(consumers.register_hazard(story,"gp09_steam",steam,["trap/gp09_steam"],[]))
	assert(story.load_data("res://data/gp09/objects.json","res://data/gp09/rules.json"))
	consumers.update()
	make_hud()
	initialized = true
	camera.reset_smoothing()

func build_room(_index):
	# Called by base setup; never invokes the production room builder.
	room = 0
	for child in geometry.get_children(): child.free()
	platforms.clear()
	for rect in [Rect2(0,620,3000,140),Rect2(-40,0,40,760),Rect2(3000,0,40,760),
			Rect2(720,510,100,28),Rect2(1450,490,140,28),Rect2(2130,500,180,28)]:
		add_platform(rect)
	story.room_loaded(self,room)

func room_size(_index: int) -> Vector2: return Vector2(3000,760)
func request_room(_target, _arrival = Vector2.INF): pass
func save_progress():
	save_attempts += 1
	return super.save_progress()

func make_hud():
	var layer = CanvasLayer.new(); layer.layer = 70; add_child(layer)
	var band = ColorRect.new(); band.color = Color(0.035,0.05,0.08,0.94)
	band.position = Vector2(0,0); band.size = Vector2(1280,103)
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE; layer.add_child(band)
	status = Label.new(); status.position = Vector2(24,15)
	status.add_theme_font_size_override("font_size",20); layer.add_child(status)
	var help = Label.new(); help.position = Vector2(24,664)
	help.text = "A/D move   Space jump   J attack   F parry   E examine / recover / exit\nF5 save   F9 reload   Esc close inspection   Space skip cut-in"
	help.add_theme_font_size_override("font_size",17); layer.add_child(help)
	veil = ColorRect.new(); veil.size = Vector2(1280,720)
	veil.color = Color(0.02,0.03,0.05,0); veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(veil)

func safe_to_leave() -> bool:
	return story.control_ready() and presenter.active_id.is_empty() and presenter.pending.is_empty() and not story.panel.opened

func reconcile_story():
	# Reconstruct pending work from existing persistent dictionaries after reload.
	# No additional save fields or transient Node references are serialized.
	if story.has(DISC) and not story.has("evt/gp09_discovered"):
		story.report("evt/gp09_examined")
	if story.has(DISC) and not story.has(PRESENTED):
		if presentation_requested and presenter.active_id.is_empty() and presenter.pending.is_empty():
			if presenter.last_outcome in ["completed","skipped","disabled"]:
				story.set_flag(PRESENTED)
			else:
				presentation_requested = false # interrupted: retry once control is safe
		if not presentation_requested and safe_to_leave():
			story.request_cutin("record_review")
			presentation_requested = true
	if story.has(PRESENTED) and not encounter_dispatched and safe_to_leave():
		story.report("evt/gp09_presentation_done")
		encounter_dispatched = true
	if cleared_encounters.get(DEFEATED,false) and not story.has("enc/gp09_complete"):
		story.report("evt/gp09_guard_done")

func _physics_process(dt):
	if not initialized: return
	message_time = maxf(0,message_time-dt)
	if exiting:
		exit_clock += dt
		transition = maxf(0,0.5-exit_clock)
		veil.color.a = sin(clampf(exit_clock/0.5,0,1)*PI)
		if exit_clock >= 0.5:
			exiting = false; exited = true; transition = 0
			player.position = Vector2(2640,618)
			player.velocity = Vector2.ZERO
			player.set_physics_process(true)
			story.set_flag("evt/gp09_exited")
			veil.color.a = 0
	story.update(self,dt)
	consumers.update()
	# Hazards/enemies cannot damage an actor whose input belongs to presentation.
	steam.set_physics_process(safe_to_leave())
	for enemy in enemies:
		if is_instance_valid(enemy): enemy.set_physics_process(safe_to_leave())
	if safe_to_leave():
		reconcile_story()
		if Input.is_action_just_pressed("interact"): interact()
		if player.position.x < 1720: crossing_started = true
		if crossing_started and player.position.x > 1970 and story.has(PRESENTED):
			story.set_flag("evt/gp09_crossed")
		if reload_requested:
			story.flush_encounters(); story.flush_save()
			if not story.dirty and story.pending.is_empty() and story.pending_encounters.is_empty():
				get_tree().reload_current_scene()
	update_status()
	queue_redraw()

func interact():
	if not safe_to_leave(): return
	if player.position.x < 380 or (player.position.x > 2040 and player.position.x < 2300):
		player.hp = 3
		story.flush_encounters(); story.flush_save()
		if save_progress(): announce("Recovered. Progress saved.",3)
		return
	if player.position.x > 2370 and player.position.x < 2570:
		if not story.has("enc/gp09_complete") or not story.has("evt/gp09_crossed"):
			announce("Resolve the encounter and cross the vent before leaving.",3); return
		# Drain ID-based completion work while control is still owned by gameplay.
		story.update(self,0)
		for encounter in consumers.active.values():
			if is_instance_valid(encounter): encounter.flush_defeats()
		story.flush_encounters(); story.flush_save()
		if story.dirty or not story.pending.is_empty() or not story.pending_encounters.is_empty():
			announce("Waiting for pending progress to save.",3); return
		exiting = true; exit_clock = 0; transition = 0.5
		player.velocity = Vector2.ZERO; player.set_physics_process(false)
		return
	story.interact(self)

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_F5 and safe_to_leave():
			if save_progress(): announce("Progress saved.",2)
		if event.physical_keycode == KEY_F9: reload_requested = true

func respawn():
	# Keep the sole director alive: queued ID-based events survive death recovery.
	if not initialized: return
	story.panel.close(); presenter.cancel("death")
	transition = 0; exiting = false; pending_room = -1; veil.color.a = 0
	player.hp = 3; player.position = Vector2(180,618); player.velocity = Vector2.ZERO
	player.invulnerable = 1.5; player.set_physics_process(true)
	camera.reset_smoothing()
	announce("Recovered at the shelter. Discovery and defeated enemies remain saved.",4)

func update_status():
	var goal = "Explore the damaged passage. Examine the abandoned bundle."
	if story.has(DISC): goal = "Close the inspection to continue."
	if story.has(PRESENTED): goal = "Resolve the encounter. Cross the vent during SAFE / RECOVERY."
	if story.has("enc/gp09_complete"): goal = "Cross the vent; recover at the sheltered bench; E at the exit."
	if exited: goal = "SLICE COMPLETE — control restored. You can still move and jump."
	status.text = "GP-09  /  THE DAMAGED PASSAGE  /  PROVISIONAL, NOT CANON\nHP %d/3   •   %s" % [player.hp,goal]
	if message_time > 0: status.text += "\n" + message

func _draw():
	draw_rect(Rect2(0,0,3000,760),Color("111c29"))
	for x in range(0,3000,320):
		draw_rect(Rect2(x,130,240,490),Color("1d2b38"))
		draw_rect(Rect2(x+22,180,195,310),Color("142331"))
		draw_line(Vector2(x+30,190),Vector2(x+195,460),Color("29434b"),2)
		draw_rect(Rect2(x+250,80,48,540),Color("34434a"))
	for x in range(30,3000,105):
		draw_line(Vector2(x,620),Vector2(x+35,760),Color("45515a"),2)
	for surface in platforms:
		draw_rect(surface,Color("3c4a51"))
		draw_line(surface.position,surface.position+Vector2(surface.size.x,0),Color("8b9694"),3)
	for x in [440,650,940,1510,2000]:
		draw_colored_polygon(PackedVector2Array([Vector2(x,620),Vector2(x+26,582),Vector2(x+65,600),Vector2(x+88,620)]),Color("596168"))
		draw_line(Vector2(x,315),Vector2(x+25,365),Color("78857f"),2)
		draw_line(Vector2(x+25,365),Vector2(x+15,420),Color("78857f"),2)
	for x in [180,2180]:
		draw_rect(Rect2(x-85,570,170,12),Color("76b9a5"))
		draw_rect(Rect2(x-70,582,12,38),Color("5d8179"))
		draw_rect(Rect2(x+58,582,12,38),Color("5d8179"))
		draw_string(ThemeDB.fallback_font,Vector2(x-100,540),"SHELTER / E RECOVER",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("a8e8d0"))
	draw_rect(Rect2(2390,400,130,220),Color("080e17"))
	draw_rect(Rect2(2376,386,158,234),Color("a1baaf"),false,8)
	draw_string(ThemeDB.fallback_font,Vector2(2395,365),"EXIT / E",HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color("d6eade"))
	draw_string(ThemeDB.fallback_font,Vector2(1690,180),"VENT: WAIT FOR THE SAFE WINDOW",HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("efca87"))
	draw_string(ThemeDB.fallback_font,Vector2(950,390),"DISTURBED PASSAGE",HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color("a1b5bb"))
	if story.world != null: story.draw_room(self)
