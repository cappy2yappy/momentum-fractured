extends CanvasLayer

## Main HUD controller.
## Handles health, cells, combo text, notifications, and mini-map placeholder room name.

@export var player_path: NodePath

@onready var _health_bar: Control = $HealthBar
@onready var _cell_counter: Control = $CellCounter
@onready var _combo_label: Label = $ComboLabel
@onready var _notification_label: Label = $NotificationLabel
@onready var _room_name_label: Label = $MiniMapPanel/VBox/RoomName
@onready var _ability_status: Label = $AbilityStatus
@onready var _character_panel: PanelContainer = $CharacterPanel
@onready var _character_stats: Label = $CharacterPanel/Content/Stats
@onready var _map_overlay: PanelContainer = $MapOverlay

var _player: Node = null
var _notification_tween: Tween = null
var _combo_hide_timer: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not GameState.cells_changed.is_connected(_on_cells_changed):
		GameState.cells_changed.connect(_on_cells_changed)
	if not GameState.player_health_changed.is_connected(_on_player_health_changed):
		GameState.player_health_changed.connect(_on_player_health_changed)
	if GameState.has_signal("combo_changed") and not GameState.combo_changed.is_connected(_on_combo_changed):
		GameState.combo_changed.connect(_on_combo_changed)

	_resolve_player()
	_on_cells_changed(GameState.cells)
	_on_player_health_changed(GameState.player_health, GameState.player_max_health)
	if GameState.has_method("get_combo_count"):
		_on_combo_changed(int(GameState.call("get_combo_count")))
	_update_room_name()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("character_menu"):
		_map_overlay.visible = false
		_character_panel.visible = not _character_panel.visible
		get_tree().paused = _character_panel.visible
	if Input.is_action_just_pressed("map"):
		_character_panel.visible = false
		_map_overlay.visible = not _map_overlay.visible
		get_tree().paused = _map_overlay.visible
	_update_ability_status()
	if _combo_hide_timer <= 0.0:
		return

	_combo_hide_timer = maxf(0.0, _combo_hide_timer - delta)
	if _combo_hide_timer <= 0.0:
		_combo_label.visible = false


func _update_ability_status() -> void:
	if _player == null or not is_instance_valid(_player):
		_resolve_player()
	if _player == null:
		return
	var element := "wind"
	var veil_ratio := 1.0
	if _player.has_method("get_current_kunai_element"):
		element = String(_player.call("get_current_kunai_element"))
	if _player.has_method("get_guard_veil_ratio"):
		veil_ratio = float(_player.call("get_guard_veil_ratio"))
	var veil_text := "READY" if veil_ratio >= 0.999 else "%d%%" % roundi(veil_ratio * 100.0)
	_ability_status.text = "TETHER: Q / MMB   KUNAI: F [%s]\nVEIL: C [%s]   MAP: M   LOADOUT: I" % [element.to_upper(), veil_text]
	_character_stats.text = "HP %d / %d\n\nTRAVERSAL\nWind Tether — Q or Middle Mouse\nMomentum Dash — Shift\n\nEQUIPPED KUNAI\n%s\n\nGUARD VEIL\n%s" % [roundi(GameState.player_health), roundi(GameState.player_max_health), element.capitalize(), veil_text]


func _resolve_player() -> void:
	if not player_path.is_empty():
		_player = get_node_or_null(player_path)
	else:
		for candidate in get_tree().get_nodes_in_group("player"):
			_player = candidate
			break

func _on_cells_changed(total_cells: int) -> void:
	if _cell_counter and _cell_counter.has_method("set_cells"):
		_cell_counter.call("set_cells", total_cells)


func _on_player_health_changed(current: float, max_health: float) -> void:
	if _health_bar and _health_bar.has_method("set_health"):
		_health_bar.call("set_health", current, max_health)


func _on_combo_changed(combo_count: int) -> void:
	if combo_count < 2:
		_combo_label.visible = false
		return

	_combo_label.visible = true
	_combo_label.text = "%d HIT COMBO!" % combo_count
	if combo_count >= 10:
		_combo_label.modulate = Color(1.0, 0.82, 0.25, 1.0)
	elif combo_count >= 5:
		_combo_label.modulate = Color(1.0, 0.9, 0.55, 1.0)
	else:
		_combo_label.modulate = Color(1.0, 1.0, 1.0, 1.0)

	_combo_hide_timer = 2.0


func _update_room_name() -> void:
	var scene := get_tree().current_scene
	if scene:
		_room_name_label.text = "Room: %s" % scene.name


func show_notification(message: String, color: Color = Color(0.8, 1.0, 0.85, 1.0), duration: float = 1.2) -> void:
	if _notification_tween and _notification_tween.is_valid():
		_notification_tween.kill()

	_notification_label.visible = true
	_notification_label.text = message
	_notification_label.modulate = color
	_notification_label.modulate.a = 0.0

	_notification_tween = create_tween()
	_notification_tween.tween_property(_notification_label, "modulate:a", 1.0, 0.18)
	_notification_tween.tween_interval(duration)
	_notification_tween.tween_property(_notification_label, "modulate:a", 0.0, 0.3)
	await _notification_tween.finished
	_notification_label.visible = false
