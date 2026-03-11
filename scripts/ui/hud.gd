extends CanvasLayer

## Main HUD controller.
## Handles health, cells, combo text, notifications, and mini-map placeholder room name.

@export var player_path: NodePath

@onready var _health_bar: Control = $HealthBar
@onready var _cell_counter: Control = $CellCounter
@onready var _combo_label: Label = $ComboLabel
@onready var _notification_label: Label = $NotificationLabel
@onready var _room_name_label: Label = $MiniMapPanel/VBox/RoomName

var _player: Node = null
var _notification_tween: Tween = null
var _combo_hide_timer: float = 0.0


func _ready() -> void:
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
	if _combo_hide_timer <= 0.0:
		return

	_combo_hide_timer = maxf(0.0, _combo_hide_timer - delta)
	if _combo_hide_timer <= 0.0:
		_combo_label.visible = false


func _resolve_player() -> void:
	if not player_path.is_empty():
		_player = get_node_or_null(player_path)
	else:
		for candidate in get_tree().get_nodes_in_group("player"):
			_player = candidate
			break

	var on_player_health_changed := Callable(self, "_on_player_health_changed")
	if _player and _player.has_signal("health_changed") and not _player.is_connected("health_changed", on_player_health_changed):
		_player.connect("health_changed", on_player_health_changed)


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
