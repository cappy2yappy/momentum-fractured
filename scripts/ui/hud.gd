extends CanvasLayer

## Lightweight HUD for the vertical slice.
## Shows player HP (top-left), cell count (top-right), and room enemy status.

@export var player_path: NodePath

@onready var _health_bar: ProgressBar = $HealthPanel/VBoxContainer/HealthBar
@onready var _health_value_label: Label = $HealthPanel/VBoxContainer/HealthValue
@onready var _cells_label: Label = $CellsLabel

var _player: Node = null


func _ready() -> void:
	if not GameState.cells_changed.is_connected(_on_cells_changed):
		GameState.cells_changed.connect(_on_cells_changed)
	if not GameState.player_health_changed.is_connected(_on_player_health_changed):
		GameState.player_health_changed.connect(_on_player_health_changed)

	_resolve_player()
	_on_cells_changed(GameState.cells)
	_on_player_health_changed(GameState.player_health, GameState.player_max_health)


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
	_cells_label.text = "Cells: %d" % total_cells


func _on_player_health_changed(current: float, max_health: float) -> void:
	var clamped_max := maxf(max_health, 1.0)
	_health_bar.max_value = clamped_max
	_health_bar.value = clampf(current, 0.0, clamped_max)
	_health_value_label.text = "%d / %d" % [roundi(current), roundi(clamped_max)]
