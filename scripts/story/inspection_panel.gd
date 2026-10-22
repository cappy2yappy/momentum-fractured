extends CanvasLayer
## Owns only a temporary tree pause and HUD input lease. Never changes player physics.
signal closed
var world
var pages: Array = []
var page = 0
var opened = false
var room_at_open = -1
var prior_pause = false
var prior_hud_input = true
var heading: Label
var body: RichTextLabel
var counter: Label
var next_button: Button
var opening_release = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 80
	var backdrop = ColorRect.new()
	backdrop.color = Color(0.025, 0.035, 0.06, 0.86)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)
	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right"]: margin.add_theme_constant_override("margin_" + side, 100)
	for side in ["top", "bottom"]: margin.add_theme_constant_override("margin_" + side, 90)
	add_child(margin)
	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 20)
	margin.add_child(box)
	heading = Label.new()
	heading.name = "Title"
	heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	heading.add_theme_font_size_override("font_size", 30)
	box.add_child(heading)
	body = RichTextLabel.new()
	body.bbcode_enabled = false
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_font_size_override("normal_font_size", 23)
	box.add_child(body)
	counter = Label.new()
	box.add_child(counter)
	var buttons = HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 24)
	box.add_child(buttons)
	next_button = Button.new()
	next_button.custom_minimum_size = Vector2(250, 54)
	next_button.pressed.connect(advance)
	buttons.add_child(next_button)
	var close_button = Button.new()
	close_button.text = "Close  ·  Esc / B"
	close_button.custom_minimum_size = Vector2(250, 54)
	close_button.pressed.connect(close)
	buttons.add_child(close_button)
	visible = false

func inspect(w, row: Dictionary):
	world = w
	pages = row.get("pages", []).duplicate()
	if pages.is_empty(): pages = [row.get("description", "No readable content is available.")]
	for i in pages.size():
		pages[i] = tr(pages[i]) if not pages[i].strip_edges().is_empty() else tr("No readable content is available.")
	page = 0
	heading.text = tr(row.get("title", "Unknown object"))
	room_at_open = world.room
	prior_pause = get_tree().paused
	prior_hud_input = world.hud.is_processing_input()
	world.hud.set_process_input(false)
	opening_release = Input.is_action_pressed("interact")
	opened = true
	visible = true
	get_tree().paused = true
	refresh()
	next_button.grab_focus()

func refresh():
	body.text = pages[page]
	body.scroll_to_line(0)
	counter.text = "%d / %d   ·   ↑↓ scroll   ·   ←→ choose control" % [page + 1, pages.size()]
	next_button.text = "Continue  ·  E / X / A" if page + 1 < pages.size() else "Done  ·  E / X / A"

func advance():
	if not opened: return
	if page + 1 < pages.size(): page += 1; refresh()
	else: close()

func close():
	if not opened: return
	opened = false
	visible = false
	if is_instance_valid(world) and is_instance_valid(world.hud): world.hud.set_process_input(prior_hud_input)
	get_tree().paused = prior_pause
	closed.emit()

func _process(_dt):
	if opened and (not is_instance_valid(world) or world.room != room_at_open or world.transition > 0 or world.player.hp <= 0): close()

func _notification(what):
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		close()

func _exit_tree():
	close()

func _input(event):
	if not opened: return
	# Release edges prevent the opening/closing E from reaching world polling.
	if event is InputEventKey and event.echo:
		get_viewport().set_input_as_handled(); return
	if event.is_action_released("pause") or event.is_action_released("ui_cancel"): close()
	elif event.is_action_released("interact"):
		if opening_release: opening_release = false
		else: advance()
	elif event.is_action_released("ui_accept"):
		var focused = get_viewport().gui_get_focus_owner()
		if focused is Button: focused.pressed.emit()
	elif event.is_action_pressed("ui_up"): body.get_v_scroll_bar().value -= 48
	elif event.is_action_pressed("ui_down"): body.get_v_scroll_bar().value += 48
	elif event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
		var focused = get_viewport().gui_get_focus_owner()
		if focused: focused.find_next_valid_focus().grab_focus()
	elif event is InputEventMouseButton or event is InputEventMouseMotion: return
	get_viewport().set_input_as_handled()
